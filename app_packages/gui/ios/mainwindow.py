import os
import sys
import threading
import traceback
from rubicon.objc import ObjCClass, NSObject, objc_method

from electrum import util, bitcoin, commands, coinchooser
from electrum import Wallet, WalletStorage
from electrum.util import UserCancelled, InvalidPassword
from electrum.base_wizard import BaseWizard, HWD_SETUP_DECRYPT_WALLET
from electrum.i18n import _
from .transaction_dialog import show_transaction
    
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
        self.electrumWindow.screensManager.showSendViewController(handler)
        pass

    @objc_method
    def settingsTapped_(self):
        handler = SettingsHandler.alloc().init()
        handler.electrumWindow = self.electrumWindow
        self.electrumWindow.screensManager.showSettingsViewController(handler)
        pass

class ElectrumWindow:
    def __init__(self, gui_object, wallet):
        self.num_zeros = 2
        self.decimal_point = 8
        self.wallet = wallet
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
        print('$$$ PREPARE FOR DO_SEND $$$')
        if run_hook('abort_send', self):
            return
        r = self.read_send_tab()
        if not r:
            return
        outputs, fee_estimator, tx_desc, coins = r
        print('do_send outputs: ' + str(outputs) + '; fee_estimator: ' + str(fee_estimator) + '; tx_desc: ' + str(tx_desc) + '; coins: ' + str(coins))
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
                    self.do_clear()
                else:
                    self.broadcast_transaction(tx, tx_desc)
        self.sign_tx_with_password(tx, sign_done, password)


'''
    def do_send(self, preview = False):
        if run_hook('abort_send', self):
            return
        r = self.read_send_tab()
        if not r:
            return
        outputs, fee_estimator, tx_desc, coins = r
        print('do_send outputs: ' + str(outputs) + '; fee_estimator: ' + str(fee_estimator) + '; tx_desc: ' + str(tx_desc) + '; coins: ' + str(coins))
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

        if fee < self.wallet.relayfee() * tx.estimated_size() / 1000:
            self.show_error('\n'.join([
                _("This transaction requires a higher fee, or it will not be propagated by your current server"),
                _("Try to raise your transaction fee, or use a server with a lower relay fee.")
            ]))
            return

        if preview:
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
                    self.do_clear()
                else:
                    self.broadcast_transaction(tx, tx_desc)
        self.sign_tx_with_password(tx, sign_done, password)

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
                self.do_clear()
                else:
                    self.broadcast_transaction(tx, tx_desc)
        self.sign_tx_with_password(tx, sign_done, password)
        '''
