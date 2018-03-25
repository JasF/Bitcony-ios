import os
import sys
import threading
import traceback
from rubicon.objc import ObjCClass, NSObject, objc_method
from decimal import Decimal

from electrum import keystore, simple_config
from electrum.bitcoin import COIN, is_address, TYPE_ADDRESS
from electrum import constants
from electrum.plugins import run_hook
from electrum.i18n import _
from electrum.util import (format_time, format_satoshis, PrintError,
                           format_satoshis_plain, NotEnoughFunds,
                           UserCancelled, NoDynamicFeeEstimates, profiler,
                           export_meta, import_meta, bh2u, bfh, InvalidPassword)
from electrum import Transaction
from electrum import util, bitcoin, commands, coinchooser
from electrum import paymentrequest
from electrum.wallet import Multisig_Wallet, AddTransactionException
from .transaction_dialog import show_transaction
from .waitingdialog import WaitingDialog
from .passworddialog import PasswordDialog
from .yesnodialog import YesNoDialog
from functools import partial
    
from .paytoedit import PayToEdit
from .amountedit import BTCAmountEdit

from .history_list import HistoryList

class WalletHandler(NSObject):
    @objc_method
    def init_(self):
        return self
    
    @objc_method
    def viewDidLoad_(self, viewController):
        self.viewController = viewController
    
    @objc_method
    def timerAction_(self):
        if self.electrumWindow.need_update.is_set():
            self.electrumWindow.need_update.clear()
            self.electrumWindow.update_wallet()

    @objc_method
    def transactionsData_(self):
        listOfItems = self.electrumWindow.historyList.on_update()
        return str(listOfItems)

    @objc_method
    def transactionTapped_(self, txHash):
        tx = self.electrumWindow.wallet.transactions.get(txHash)
        print('txHash: ' + txHash + '; tx: ' + str(tx))
        show_transaction(tx, self.electrumWindow, None)

class ReceiveHandler(NSObject):
    @objc_method
    def init_(self):
        return self

    @objc_method
    def receivingAddress_(self):
        return self.addr

class SendHandler(NSObject):
    @objc_method
    def init_(self):
        return self

    @objc_method
    def viewDidLoad_(self, viewController):
        self.viewController = viewController

    @objc_method
    def previewTapped_(self):
        self.electrumWindow.do_preview()
    
    @objc_method
    def sendTapped_(self):
        self.electrumWindow.do_send(preview = False)

    @objc_method
    def feePosChanged_(self, pos):
        self.electrumWindow.feeSliderMoved(pos)

class SettingsHandler(NSObject):
    @objc_method
    def init_(self):
        return self

class MenuHandler(NSObject):
    @objc_method
    def init_(self):
        return self
    
    @objc_method
    def walletTapped_(self):
        self.electrumWindow.showWalletViewController()
        pass

    @objc_method
    def receiveTapped_(self):
        addr = self.electrumWindow.wallet.get_unused_address()
        handler = ReceiveHandler.alloc().init()
        handler.addr = addr
        handler.electrumWindow = self.electrumWindow
        self.electrumWindow.screensManager.showReceiveViewController(handler)
        pass

    @objc_method
    def sendTapped_(self):
        handler = SendHandler.alloc().init()
        handler.electrumWindow = self.electrumWindow
        self.electrumWindow.sendHandler = handler
        self.electrumWindow.screensManager.showSendViewController(handler)
        self.electrumWindow.feeSliderMoved(0)
        pass

    @objc_method
    def settingsTapped_(self):
        handler = SettingsHandler.alloc().init()
        handler.electrumWindow = self.electrumWindow
        self.electrumWindow.screensManager.showSettingsViewController(handler)
        pass

class ElectrumWindow:
    def __init__(self, gui_object, wallet):
        self.tx_external_keypairs = {}
        self.is_max = False
        self.pay_from = False
        self.payment_request = None
        self.num_zeros = 2
        self.config = config = gui_object.config
        self.decimal_point = config.get('decimal_point', 8)
        self.wallet = wallet
        self.invoices = wallet.invoices
        self.contacts = wallet.contacts
        self.historyList = HistoryList(self)
        self.network = gui_object.daemon.network
        self.fx = gui_object.daemon.fx
        Managers = ObjCClass("Managers")
        self.runLoop = ObjCClass("RunLoop").shared();
        self.screensManager = Managers.shared().screensManager()
    
    
        interests = ['updated', 'new_transaction', 'status', 'banner', 'verified', 'fee']
        # To avoid leaking references to "self" that prevent the
        # window from being GC-ed when closed, callbacks should be
        # methods of this class only, and specifically not be
        # partials, lambdas or methods of subobjects.  Hence...
        self.network.register_callback(self.on_network, interests)
        self.network.register_callback(self.on_quotes, ['on_quotes'])
        self.network.register_callback(self.on_history, ['on_history'])
        #self.need_update = threading.Event()
        self.tx_notifications = []
        self.need_update = threading.Event()

    def exec(self):
        handler = MenuHandler.alloc().init()
        handler.electrumWindow = self
        self.screensManager.showMainViewController(handler)
        self.showWalletViewController()
        self.runLoop.exec()
    
    def showWalletViewController(self):
        self.handler = WalletHandler.alloc().init();
        self.handler.electrumWindow = self
        self.screensManager.showWalletViewController(self.handler)

    def on_network(self, event, *args):
        if event == 'updated':
            self.need_update.set()
        elif event == 'new_transaction':
            self.tx_notifications.append(args[0])
        elif event in ['status', 'banner', 'verified', 'fee']:
            pass # Handle in GUI thread
        else:
            self.print_error("unexpected network message:", event, args)

    def base_unit(self):
        assert self.decimal_point in [2, 5, 8]
        if self.decimal_point == 2:
            return 'bits'
        if self.decimal_point == 5:
            return 'mBTC'
        if self.decimal_point == 8:
            return 'BTC'
        raise Exception('Unknown base unit')

    def update_status(self):
        print('broadcast to gui network status! [connected, connecting, disconnected, uninitialized]')
        '''
        if not self.wallet:
            return

        if self.network is None or not self.network.is_running():
            text = _("Offline")
            icon = QIcon(":icons/status_disconnected.png")

        elif self.network.is_connected():
            server_height = self.network.get_server_height()
            server_lag = self.network.get_local_height() - server_height
            # Server height can be 0 after switching to a new server
            # until we get a headers subscription request response.
            # Display the synchronizing message in that case.
            if not self.wallet.up_to_date or server_height == 0:
                text = _("Synchronizing...")
                icon = QIcon(":icons/status_waiting.png")
            elif server_lag > 1:
                text = _("Server is lagging ({} blocks)").format(server_lag)
                icon = QIcon(":icons/status_lagging.png")
            else:
                c, u, x = self.wallet.get_balance()
                text =  _("Balance" ) + ": %s "%(self.format_amount_and_units(c))
                if u:
                    text +=  " [%s unconfirmed]"%(self.format_amount(u, True).strip())
                if x:
                    text +=  " [%s unmatured]"%(self.format_amount(x, True).strip())

                # append fiat balance and price
                if self.fx.is_enabled():
                    text += self.fx.get_fiat_status_text(c + u + x,
                        self.base_unit(), self.get_decimal_point()) or ''
                if not self.network.proxy:
                    icon = QIcon(":icons/status_connected.png")
                else:
                    icon = QIcon(":icons/status_connected_proxy.png")
        else:
            text = _("Not connected")
            icon = QIcon(":icons/status_disconnected.png")

        self.tray.setToolTip("%s (%s)" % (text, self.wallet.basename()))
        self.balance_label.setText(text)
        self.status_button.setIcon( icon )
'''
    
    
    def update_tabs(self):
        print('broadcast to gui update_tabs [reload_data]')
        self.handler.viewController.updateAndReloadData()
        '''
        self.history_list.update()
        self.request_list.update()
        self.address_list.update()
        self.utxo_list.update()
        self.contact_list.update()
        self.invoice_list.update()
        self.update_completions()
        '''

    def update_wallet(self):
        self.update_status()
        if self.wallet.up_to_date or not self.network or not self.network.is_connected():
            self.update_tabs()


    def on_history(self, b):
        #self.new_fx_history_signal.emit() // AV: Похоже просто передать в WalletViewController
        '''
            self.history_list.refresh_headers()
            self.history_list.update()
            self.address_list.update()
        '''
            
    
    
    def on_quotes(self, b):
        '''  // AV: Похоже просто передать в WalletViewController
        #self.new_fx_quotes_signal.emit()
        self.update_status()
        # Refresh edits with the new rate
        edit = self.fiat_send_e if self.fiat_send_e.is_last_edited else self.amount_e
        edit.textEdited.emit(edit.text())
        edit = self.fiat_receive_e if self.fiat_receive_e.is_last_edited else self.receive_amount_e
        edit.textEdited.emit(edit.text())
        # History tab needs updating if it used spot
        if self.fx.history_used_spot:
        self.history_list.update()
            '''
    
    def show_message(self, message):
        self.handler.viewController.showMessage(message)
        pass
    
    def show_error(self, message):
        self.handler.viewController.showError(message)
        pass
    
    def show_warning(self, message):
        self.handler.viewController.showWarning(message)

    def format_amount(self, x, is_diff=False, whitespaces=False):
        return util.format_satoshis(x, is_diff, self.num_zeros, self.decimal_point, whitespaces)

    def format_amount_and_units(self, amount):
        text = self.format_amount(amount) + ' '+ self.base_unit()
        x = self.fx.format_amount_and_units(amount) if self.fx else None
        if text and x:
            text += ' (%s)'%x
        return text

    def format_fee_rate(self, fee_rate):
        return util.format_satoshis(fee_rate/1000, False, self.num_zeros, 0, False)  + ' sat/byte'

    def do_preview(self):
        self.do_send(preview = True)
    

    def do_send(self, preview = False):
        print('$$$ PREPARE FOR DO_SEND $$$, preview: ' + str(preview))
        r = self.read_send_tab()
        if not r:
            return
        
        self.do_update_fee()
        
        outputs, fee_estimator, tx_desc, coins = r
        try:
            is_sweep = bool(self.tx_external_keypairs)
            tx = self.wallet.make_unsigned_transaction(
                coins, outputs, self.config, fixed_fee=fee_estimator,
                is_sweep=is_sweep)
        except NotEnoughFunds:
            self.show_message(_("Insufficient funds"))
            return
        except BaseException as e:
            traceback.print_exc(file=sys.stdout)
            self.show_message(str(e))
            return

        amount = tx.output_value() if self.is_max else sum(map(lambda x:x[2], outputs))
        fee = tx.get_fee()

        use_rbf = self.config.get('use_rbf', True)
        if use_rbf:
            tx.set_rbf(True)
        print('amount: ' + str(amount) + '; fee: ' + str(fee) + '; use_rbf: ' + str(use_rbf))

        if fee < self.wallet.relayfee() * tx.estimated_size() / 1000:
            self.show_error('\n'.join([
                _("This transaction requires a higher fee, or it will not be propagated by your current server"),
                _("Try to raise your transaction fee, or use a server with a lower relay fee.")
            ]))
            return

        if preview:
            print('preview')
            self.show_transaction(tx, tx_desc)
            return

        if not self.network:
            self.show_error(_("You can't broadcast a transaction without a live network connection."))
            return

        # confirmation dialog
        msg = [
            _("Amount to be sent") + ": " + self.format_amount_and_units(amount),
            _("Mining fee") + ": " + self.format_amount_and_units(fee),
        ]

        x_fee = run_hook('get_tx_extra_fee', self.wallet, tx)
        if x_fee:
            x_fee_address, x_fee_amount = x_fee
            msg.append( _("Additional fees") + ": " + self.format_amount_and_units(x_fee_amount) )

        confirm_rate = simple_config.FEERATE_WARNING_HIGH_FEE
        if fee > confirm_rate * tx.estimated_size() / 1000:
            msg.append(_('Warning') + ': ' + _("The fee for this transaction seems unusually high."))

        print('keystore_encrypted: ' + str(self.wallet.has_keystore_encryption()))
        print('storage_encrypted: ' + str(self.wallet.has_storage_encryption()))
        if self.wallet.has_keystore_encryption():
            msg.append("")
            msg.append(_("Enter your password to proceed"))
            password = self.password_dialog('\n'.join(msg))
            if not password:
                return
        else:
            msg.append(_('Proceed?'))
            password = None
            if not self.question('\n'.join(msg)):
                return

        def sign_done(success):
            if success:
                if not tx.is_complete():
                    self.show_transaction(tx)
                    #self.do_clear()
                else:
                    self.broadcast_transaction(tx, tx_desc)

        print('signing...');
        self.sign_tx_with_password(tx, sign_done, password)


    def broadcast_transaction(self, tx, tx_desc):

        def broadcast_thread():
            # non-GUI thread
            print('entering broadcast thread')
            pr = self.payment_request
            if pr and pr.has_expired():
                self.payment_request = None
                return False, _("Payment request has expired")
            status, msg =  self.network.broadcast(tx)
            print('broadcast status: ' + str(status))
            if pr and status is True:
                self.invoices.set_paid(pr, tx.txid())
                self.invoices.save()
                self.payment_request = None
                refund_address = self.wallet.get_receiving_addresses()[0]
                ack_status, ack_msg = pr.send_ack(str(tx), refund_address)
                if ack_status:
                    msg = ack_msg
            print('broadcast msg: ' + str(msg))
            return status, msg

        # Capture current TL window; override might be removed on return

        def broadcast_done(result):
            # GUI thread
            if result:
                status, msg = result
                if status:
                    if tx_desc is not None and tx.is_complete():
                        self.wallet.set_label(tx.txid(), tx_desc)
                    self.show_message(_('Payment sent.') + '\n' + msg)
                    #self.invoice_list.update()
                    self.do_clear()
                else:
                    self.show_error(msg)

        WaitingDialog(self, _('Broadcasting transaction...'),
                      broadcast_thread, broadcast_done, self.on_error)

    def get_decimal_point(self):
        return self.decimal_point
        '''
        def broadcast_thread():
            # non-GUI thread
            pr = self.payment_request
            if pr and pr.has_expired():
                self.payment_request = None
                return False, _("Payment request has expired")
            status, msg =  self.network.broadcast(tx)
            if pr and status is True:
                self.invoices.set_paid(pr, tx.txid())
                self.invoices.save()
                self.payment_request = None
                refund_address = self.wallet.get_receiving_addresses()[0]
                ack_status, ack_msg = pr.send_ack(str(tx), refund_address)
                if ack_status:
                    msg = ack_msg
            return status, msg

        # Capture current TL window; override might be removed on return
        parent = self.top_level_window()

        def broadcast_done(result):
            # GUI thread
            if result:
                status, msg = result
                if status:
                    if tx_desc is not None and tx.is_complete():
                        self.wallet.set_label(tx.txid(), tx_desc)
                    parent.show_message(_('Payment sent.') + '\n' + msg)
                    self.invoice_list.update()
                    self.do_clear()
                else:
                    parent.show_error(msg)
                '''

    def read_send_tab(self):
        if self.payment_request and self.payment_request.has_expired():
            self.show_error(_('Payment request has expired'))
            return
        label = self.sendHandler.viewController.descriptionText()
        payToText = self.sendHandler.viewController.payToText()
        amountText = self.sendHandler.viewController.amountText()

        self.amount_e = BTCAmountEdit(self.get_decimal_point, text=amountText)
        self.payto_e = PayToEdit(self, payToText)
        
        if self.payment_request:
            outputs = self.payment_request.get_outputs()
        else:
            errors = self.payto_e.get_errors()
            if errors:
                self.show_warning(_("Invalid Lines found:") + "\n\n" + '\n'.join([ _("Line #") + str(x[0]+1) + ": " + x[1] for x in errors]))
                return
            outputs = self.payto_e.get_outputs(self.is_max)

            if self.payto_e.is_alias and self.payto_e.validated is False:
                alias = self.payto_e.toPlainText()
                msg = _('WARNING: the alias "{}" could not be validated via an additional '
                        'security check, DNSSEC, and thus may not be correct.').format(alias) + '\n'
                msg += _('Do you wish to continue?')
                if not self.question(msg):
                    return

        if not outputs:
            self.show_error(_('No outputs'))
            return

        for _type, addr, amount in outputs:
            if addr is None:
                self.show_error(_('Bitcoin Address is None'))
                return
            if _type == TYPE_ADDRESS and not bitcoin.is_address(addr):
                self.show_error(_('Invalid Bitcoin Address'))
                return
            if amount is None:
                self.show_error(_('Invalid Amount'))
                return

        fee_estimator = None#self.get_send_fee_estimator()
        coins = self.get_coins()
        return outputs, fee_estimator, label, coins


    def get_coins(self):
        if self.pay_from:
            return self.pay_from
        else:
            return self.wallet.get_spendable_coins(None, self.config)

    def pay_to_URI(self, URI):
        print('Unimplemented feature')
        pass

    def lock_amount(self, b):
        pass

    def show_transaction(self, tx, tx_desc = None):
        '''tx_desc is set only for txs created in the Send tab'''
        show_transaction(tx, self, tx_desc)

    def fee_cb(self, dyn, pos, fee_rate):
        pos = int(pos)
        if dyn:
            if self.config.use_mempool_fees():
                self.config.set_key('depth_level', pos, False)
            else:
                self.config.set_key('fee_level', pos, False)
        else:
            self.config.set_key('fee_per_kb', fee_rate, False)

        if fee_rate:
            self.feeAmount = fee_rate // 1000
        else:
            self.feeAmount = None

    def get_send_fee_estimator(self):
        return None
    
    def feeSliderMoved(self, pos):
        self.dyn = True
        if self.dyn:
            fee_rate = self.config.depth_to_fee(pos) if self.config.use_mempool_fees() else self.config.eta_to_fee(int(pos))
        else:
            fee_rate = self.config.static_fee(pos)
        self.fee_rate = fee_rate
        self.fee_cb(True, pos, fee_rate)
        self.do_update_fee()


    def is_send_fee_frozen(self):
        return False#self.fee_e.isVisible() and self.fee_e.isModified() and (self.fee_e.text() or self.fee_e.hasFocus())
    
    def is_send_feerate_frozen(self):
        return False#self.feerate_e.isVisible() and self.feerate_e.isModified() and (self.feerate_e.text() or self.feerate_e.hasFocus())


    def get_payto_or_dummy(self):
        #r = self.payto_e.get_recipient()
        #if r:
        #    return r
        return (TYPE_ADDRESS, self.wallet.dummy_address())

    def do_update_fee(self):
        print('$$$$$ DO_UPDATE_FEE')
        '''Recalculate the fee.  If the fee was manually input, retain it, but
        still build the TX to see if there are enough funds.
        '''
        freeze_fee = self.is_send_fee_frozen()
        freeze_feerate = self.is_send_feerate_frozen()
        
        
        amountText = self.sendHandler.viewController.amountText()
        self.amount_e = BTCAmountEdit(self.get_decimal_point, text=amountText)
        amnt = self.amount_e.get_amount()
        payToText = self.sendHandler.viewController.payToText()
        self.payto_e = PayToEdit(self, payToText)
        
        amount = '!' if self.is_max else self.amount_e.get_amount()
        if amount is None:
            #if not freeze_fee:
            #    self.fee_e.setAmount(None)
            self.not_enough_funds = False
            self.statusBar().showMessage('')
        else:
            fee_estimator = self.get_send_fee_estimator()
            outputs = self.payto_e.get_outputs(self.is_max)
            if not outputs:
                _type, addr = self.get_payto_or_dummy()
                outputs = [(_type, addr, amount)]
            is_sweep = bool(self.tx_external_keypairs)
            
            make_tx = lambda fee_est: \
                self.wallet.make_unsigned_transaction(
                    self.get_coins(), outputs, self.config,
                    fixed_fee=fee_est, is_sweep=is_sweep)
            try:
                tx = make_tx(fee_estimator)
                self.not_enough_funds = False
            except (NotEnoughFunds, NoDynamicFeeEstimates) as e:
                if not freeze_fee:
                    self.fee_e.setAmount(None)
                if not freeze_feerate:
                    self.feerate_e.setAmount(None)
                #self.feerounding_icon.setVisible(False)

                if isinstance(e, NotEnoughFunds):
                    self.not_enough_funds = True
                elif isinstance(e, NoDynamicFeeEstimates):
                    try:
                        tx = make_tx(0)
                        size = tx.estimated_size()
                    except BaseException:
                        pass
                return
            except BaseException:
                traceback.print_exc(file=sys.stderr)
                return
            size = tx.estimated_size()
            fee = tx.get_fee()

    def on_error(self, exc_info):
        print('exc_info: ' + str(type(exc_info)));
        if not isinstance(exc_info[1], UserCancelled):
            self.show_error(str(exc_info[1]))

    def sign_tx_with_password(self, tx, callback, password):
        '''Sign the transaction in a separate thread.  When done, calls
        the callback with a success code of True or False.
        '''

        def on_signed(result):
            print('on_signed!')
            callback(True)
        def on_failed(exc_info):
            print('on_failed!')
            self.on_error(exc_info)
            callback(False)

        if self.tx_external_keypairs:
            # can sign directly
            task = partial(Transaction.sign, tx, self.tx_external_keypairs)
        else:
            # call hook to see if plugin needs gui interaction
            run_hook('sign_tx', self, tx)
            task = partial(self.wallet.sign_transaction, tx, password)
        WaitingDialog(self, _('Signing transaction...'), task,
                      on_signed, on_failed)

    def password_dialog(self, msg):
        dialog = PasswordDialog(msg)
        password = dialog.show()
        return password

    def question(self, msg):
        dialog = YesNoDialog(self, msg)
        result = dialog.show()
        return result
#self.amount_e.setAmount(amount)

