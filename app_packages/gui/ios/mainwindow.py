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
    
from .history_list import HistoryList

class TransactionDetailHandler(NSObject):
    @objc_method
    def init_(self):
        return self

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
        print('txHash: ' + txHash)
        handler = TransactionDetailHandler.alloc().init()
        handler.electrumWindow = self.electrumWindow
        handler.txHash = txHash
        self.electrumWindow.screensManager.showTransactionDetailViewController(handler)

class ReceiveHandler(NSObject):
    @objc_method
    def init_(self):
        return self

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
        handler = ReceiveHandler.alloc().init()
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

