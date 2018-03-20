
import os
import sys
import threading
import traceback
from rubicon.objc import ObjCClass, NSObject, objc_method

from electrum import Wallet, WalletStorage
from electrum.util import UserCancelled, InvalidPassword
from electrum.base_wizard import BaseWizard, HWD_SETUP_DECRYPT_WALLET
from electrum.i18n import _

'''
from .seed_dialog import SeedLayout, KeysLayout
from .network_dialog import NetworkChoiceLayout
from .util import *
from .password_dialog import PasswordLayout, PasswordLayoutForHW, PW_NEW
'''

class EnterWalletPasswordHandler(NSObject):
    @objc_method
    def init_(self):
        return self

    @objc_method
    def continueTapped_(self, password):
        self.installWizard.processPassword(password)

'''
    
    '''

class ConfirmSeedHandler(NSObject):
    @objc_method
    def init_(self):
        return self

    @objc_method
    def continueTapped_(self):
        self.installWizard.processSeed(self.installWizard.seedText) # Next in InstallWizard.request_password

    @objc_method
    def generatedSeed_(self):
        return self.installWizard.seedText

class HaveASeedHandler(NSObject):
    @objc_method
    def init_(self):
        return self

    @objc_method
    def createNewSeedTapped_(self):
        pass

class CreateNewSeedHandler(NSObject):
    @objc_method
    def init_(self):
        return self

    @objc_method
    def continueTapped_(self, newSeed):
        print('newSeed is: ' + newSeed)
        handler = ConfirmSeedHandler.alloc().init()
        handler.installWizard = self.installWizard
        self.installWizard.seedText = newSeed
        self.installWizard.screensManager.showConfirmSeedViewController(handler)
        pass

    @objc_method
    def generatedSeed_(self):
        seed = self.installWizard.createSeed()
        return seed

class CreateWalletHandler(NSObject):
    @objc_method
    def init_(self):
        return self

    @objc_method
    def createNewSeedTapped_(self):
        handler = CreateNewSeedHandler.alloc().init()
        handler.installWizard = self.installWizard
        self.installWizard.screensManager.showCreateNewSeedViewController(handler)
        print("create new seed handled in python")

    @objc_method
    def haveASeedTapped_(self):
        handler = HaveASeedHandler.alloc().init()
        handler.installWizard = self.installWizard
        self.installWizard.screensManager.showHaveASeedViewController(handler)
        print("have a seed handled in python")

class EnterOrCreateWalletHandler(NSObject):
    @objc_method
    def init_(self):
        return self
    
    @objc_method
    def createWalletTapped_(self):
        handler = CreateWalletHandler.alloc().init()
        handler.installWizard = self.installWizard
        self.installWizard.screensManager.showCreateWalletViewController(handler)


class GoBack(Exception):
    pass

class InstallWizard(BaseWizard):
    pass
    def __init__(self, config, plugins, storage):
        BaseWizard.__init__(self, config, storage)
        print('Hello InstallWizard')
        Managers = ObjCClass("Managers")
        self.runLoop = ObjCClass("RunLoop").shared();
        self.screensManager = Managers.shared().screensManager()
        self.config = config
        self.plugins = plugins
        self.storage = storage
    
    def request_password(self):
        handler = EnterWalletPasswordHandler.alloc().init()
        handler.installWizard = self
        self.screensManager.showEnterWalletPasswordViewController(handler)
    
    def run_and_get_wallet(self):
        handler = EnterOrCreateWalletHandler.alloc().init()
        handler.installWizard = self
        self.screensManager.showEnterOrCreateWalletViewController(handler)
        result = self.runLoop.exec()
        print('Show EnterOrCreateWalletViewController result: ' + str(result));
        return self.wallet
    
    def terminate(self):
        print('InstallWizard terminate')
    
    def init_network(self, network):
        self.config.set_key('auto_connect', True, True)
        pass

    def waiting_dialog(self, task, msg):
        t = threading.Thread(target = task)
        t.start()
        t.join()

