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
from electrum.util import UserCancelled, print_error

from .installwizard import InstallWizard, GoBack
from .mainwindow import ElectrumWindow
from objc import runloop

class ElectrumGui:
    def __init__(self, config, daemon, plugins):
        print('Hello ElectrumGui ios!')
        self.config = config
        self.daemon = daemon
        self.plugins = plugins
        pass
    def init_network(self):
        if self.daemon.network:
            if self.config.get('auto_connect') is None:
                wizard = InstallWizard(self.config, self.plugins, None, self.daemon)
                wizard.init_network(self.daemon.network)
                wizard.terminate()

    def create_window_for_wallet(self, wallet, callback):
        self.wallet = wallet
        electrumWindow = ElectrumWindow(self, self.wallet, callback)
        electrumWindow.exec()

    def start_new_window(self, path, uri):
        try:
            wallet = None#self.daemon.load_wallet(path, '1')
        except BaseException as e:
            traceback.print_exc(file=sys.stdout)
            print('Cannot load wallet: ' + str(e))
            return
        if not wallet:
            storage = WalletStorage(path, manual_upgrades=True)
            wizard = InstallWizard(self.config, self.plugins, storage, self.daemon)
            
            def getWalletCallback(wallet):
                wizard.terminate()
                if not wallet:
                    print('wallet not created. return ')
                    return
                wallet.start_threads(self.daemon.network)
                print('adding wallet: ' + str(wallet))
                self.daemon.add_wallet(wallet)
                
                def electrumWindowCallback():
                    print('electrumWindowCallback called')
                    pass
                try:
                    w = self.create_window_for_wallet(wallet, electrumWindowCallback)
                except BaseException as e:
                    traceback.print_exc(file=sys.stdout)
                    print('Cannot create window for wallet: ' + str(e))
            
            try:
                wallet = wizard.run_and_get_wallet(getWalletCallback)
            except UserCancelled:
                pass
            except GoBack as e:
                print_error('[start_new_window] Exception caught (GoBack)', e)

    def main(self):
        try:
            print('initializing network')
            self.init_network()
        except UserCancelled:
            return
        except GoBack:
            return
        except BaseException as e:
            traceback.print_exc(file=sys.stdout)
            return
        self.config.open_last_wallet()
        path = self.config.get_wallet_path()
        self.start_new_window(path, self.config.get('url'))
        print('exiting from gui')
        runloop.exec()
        print('do exiting from gui')
        traceback.print_stack()

