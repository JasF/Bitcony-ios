#!/usr/bin/env python
#
# Electrum - lightweight Bitcoin client
# Copyright (C) 2012 thomasv@gitorious
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import signal
import sys
import traceback

from electrum.i18n import _, set_language
from electrum.plugins import run_hook
from electrum import WalletStorage
# from electrum.synchronizer import Synchronizer
# from electrum.verifier import SPV
# from electrum.util import DebugMem
from electrum.util import UserCancelled, print_error
# from electrum.wallet import Abstract_Wallet

from .installwizard import InstallWizard, GoBack
from rubicon.objc import ObjCClass, NSObject, objc_method

'''
from .util import *   # * needed for plugins
from .main_window import ElectrumWindow
from .network_dialog import NetworkDialog

class OpenFileEventFilter(QObject):
    def __init__(self, windows):
        self.windows = windows
        super(OpenFileEventFilter, self).__init__()

    def eventFilter(self, obj, event):
        if event.type() == QtCore.QEvent.FileOpen:
            if len(self.windows) >= 1:
                self.windows[0].pay_to_URI(event.url().toEncoded())
                return True
        return False


class QElectrumApplication(QApplication):
    new_window_signal = pyqtSignal(str, object)


class QNetworkUpdatedSignalObject(QObject):
    network_updated_signal = pyqtSignal(str, object)
'''

class ElectrumGui:
    def __init__(self, config, daemon, plugins):
        print('Hello ElectrumGui ios!')
        self.config = config
        self.daemon = daemon
        self.plugins = plugins
        pass
    def init_network(self):
        # Show network dialog if config does not exist
        if self.daemon.network:
            if self.config.get('auto_connect') is None:
                wizard = InstallWizard(self.config, self.plugins, None)
                wizard.init_network(self.daemon.network)
                wizard.terminate()


    def start_new_window(self, path, uri):
        traceback.print_stack()
        try:
            wallet = self.daemon.load_wallet(path, "om universe bodhisattva")
            print('wallet is: ')
            print(wallet)
        except BaseException as e:
            traceback.print_exc(file=sys.stdout)
            print('Cannot load wallet: ' + str(e))
            return
        if not wallet:
            storage = WalletStorage(path, manual_upgrades=True)
            wizard = InstallWizard(self.config, self.plugins, storage)
            try:
                wallet = wizard.run_and_get_wallet()
            except UserCancelled:
                pass
            except GoBack as e:
                print_error('[start_new_window] Exception caught (GoBack)', e)
            wizard.terminate()
            if not wallet:
                print('wallet not created. return ')
                return
            wallet.start_threads(self.daemon.network)
            self.daemon.add_wallet(wallet)
        try:
            w = self.create_window_for_wallet(wallet)
        except BaseException as e:
            traceback.print_exc(file=sys.stdout)
            print('Cannot create window for wallet:' + str(e))
            #d.exec_()
            return
        #Raises the window for the wallet if it is open.  Otherwise opens the wallet and creates a new window for it.
        '''
        for w in self.windows:
            if w.wallet.storage.path == path:
                w.bring_to_top()
                break
        else:
            try:
                wallet = self.daemon.load_wallet(path, None)
            except BaseException as e:
                traceback.print_exc(file=sys.stdout)
                d = QMessageBox(QMessageBox.Warning, _('Error'),
                                _('Cannot load wallet:') + '\n' + str(e))
                d.exec_()
                return
            if not wallet:
                storage = WalletStorage(path, manual_upgrades=True)
                wizard = InstallWizard(self.config, self.app, self.plugins, storage)
                try:
                    wallet = wizard.run_and_get_wallet()
                except UserCancelled:
                    pass
                except GoBack as e:
                    print_error('[start_new_window] Exception caught (GoBack)', e)
                wizard.terminate()
                if not wallet:
                    return
                wallet.start_threads(self.daemon.network)
                self.daemon.add_wallet(wallet)
            try:
                w = self.create_window_for_wallet(wallet)
            except BaseException as e:
                traceback.print_exc(file=sys.stdout)
                d = QMessageBox(QMessageBox.Warning, _('Error'),
                                _('Cannot create window for wallet:') + '\n' + str(e))
                d.exec_()
                return
        if uri:
            w.pay_to_URI(uri)
        w.bring_to_top()
        w.setWindowState(w.windowState() & ~QtCore.Qt.WindowMinimized | QtCore.Qt.WindowActive)

        # this will activate the window
        w.activateWindow()
        return w
        '''

    def main(self):
        try:
            self.init_network()
        except UserCancelled:
            return
        except GoBack:
            return
        except BaseException as e:
            traceback.print_exc(file=sys.stdout)
            return
        #self.timer.start()
        self.config.open_last_wallet()
        path = self.config.get_wallet_path()
        print('wallet path: ' + path)
        if not self.start_new_window(path, self.config.get('url')):
            return
#signal.signal(signal.SIGINT, lambda *args: self.app.quit()) // AV: Не останавливаем выполнение скрипта
#signal.signal(signal.SIGINT, lambda *args: self.app.quit())


