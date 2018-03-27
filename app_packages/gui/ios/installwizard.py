
import os
import sys
import threading
import traceback
from os import listdir
from os.path import isfile, join

from rubicon.objc import ObjCClass, NSObject, objc_method

from lib import bitcoin
from electrum import Wallet, WalletStorage
from electrum.util import UserCancelled, InvalidPassword
from electrum.base_wizard import BaseWizard, HWD_SETUP_DECRYPT_WALLET
from electrum.i18n import _
from .textfielddialog import TextFieldDialog
from .passworddialog import PasswordDialog

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
    
        if self.installWizard.haveASeed == True:
            self.installWizard.password = password;
            seed = self.installWizard.seedText
            print('seed: ' + seed + '; pass: ' + password)
            self.installWizard.wallet_type = 'standard'
            self.installWizard.create_keystore(seed, password)
        else:
            self.installWizard.processPassword(password)

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
    def continueTapped_(self, seed):
        self.installWizard.seedText = seed
        self.installWizard.seed_type = 'standard'
        self.installWizard.haveASeed = True
        self.installWizard.processSeed(seed)
        pass

    @objc_method
    def seedType_(self, seed):
        return bitcoin.seed_type(seed)

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
        self.haveASeed = False
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
        self.installWizard.beginCreateNewWallet()

    @objc_method
    def openWalletTapped_(self, walletName):
        self.installWizard.openWalletWithName(walletName)

    @objc_method
    def walletsNames_(self):
        namesList = self.installWizard.walletsNames()
        return namesList


class GoBack(Exception):
    pass

class InstallWizard(BaseWizard):
    pass
    def __init__(self, config, plugins, storage, daemon):
        BaseWizard.__init__(self, config, storage)
        print('Hello InstallWizard')
        self.daemon = daemon
        Managers = ObjCClass("Managers")
        self.runLoop = ObjCClass("RunLoop").shared();
        self.screensManager = Managers.shared().screensManager()
        self.config = config
        self.plugins = plugins
        self.storage = storage
        print('InstallWizard storage: ' + str(storage))
    
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

    def openWalletWithName(self, walletName):
        path = self.config.walletsPath()
        path += '/' + walletName
        try:
            print('trying: ' + path)
            self.storage = WalletStorage(path, manual_upgrades=True)
        except BaseException:
            traceback.print_exc(file=sys.stderr)
            self.storage = None
    

        if self.storage:
            if not self.storage.file_exists():
                '''
                msg =_("This file does not exist.") + '\n' \
                      + _("Press 'Next' to create this wallet, or choose another file.")
                '''
                pw = False
            else:
                if self.storage.is_encrypted_with_user_pw():
                    '''
                    msg = _("This file is encrypted with a password.") + '\n' \
                          + _('Enter your password or choose another file.')
                          '''
                    print('needs enter password for wallet')
                    pw = True
                else:
                    '''
                    msg = _("Press 'Next' to open this wallet.")
                    '''
                    print('can open file without password')
                    pw = False
        else:
            msg = _('Cannot read file')
            pw = False

        if pw == False:
            try:
                self.wallet = self.daemon.load_wallet(path, None)
            except:
                self.wallet = None
            if self.wallet:
                print('Successfully opened wallet without password')
                self.runLoop.exit(0)
        else:
            while True:
                dialog = PasswordDialog('Enter password for wallet: ' + walletName)
                password = dialog.show()
                if len(password) == 0:
                    break
                try:
                    self.wallet = self.daemon.load_wallet(path, password)
                except:
                    self.wallet = None
                if self.wallet:
                    print('Successfully opened wallet with password')
                    self.runLoop.exit(0)
                    return
                

    def beginCreateNewWallet(self):
        walletName = "Default_wallet"
        names = self.walletsNames()
        walletsIndex = 1
        while True:
            if walletName not in names:
                break
            newName = walletName + str(walletsIndex)
            if newName not in names:
                walletName = newName
                break
            walletsIndex = walletsIndex + 1

        newName = walletName
        while True:
            dialog = TextFieldDialog("Enter wallet name", newName);
            newName = dialog.show()
            if len(newName) == 0:
                return
            if newName not in names:
                walletName = newName
                break

        print('walletName is: ' + walletName)
        
        path = self.config.walletsPath()
        path += '/' + walletName
        
        try:
            print('trying: ' + path)
            self.storage = WalletStorage(path, manual_upgrades=True)
        except BaseException:
            traceback.print_exc(file=sys.stderr)
            self.storage = None
            return
                
        handler = CreateWalletHandler.alloc().init()
        handler.installWizard = self
        self.screensManager.showCreateWalletViewController(handler)

    def walletsNames(self):
        path = self.config.walletsPath()
        onlyfiles = [f for f in listdir(path) if isfile(join(path, f))]
        print('path: ' + path + '; onlyfiles: ' + str(onlyfiles))
        return onlyfiles
