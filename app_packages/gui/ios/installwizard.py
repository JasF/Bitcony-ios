
import os
import sys
import threading
import traceback
from os import listdir
from os.path import isfile, join

from lib import bitcoin
from electrum import Wallet, WalletStorage
from electrum.util import UserCancelled, InvalidPassword
from electrum.base_wizard import BaseWizard, HWD_SETUP_DECRYPT_WALLET
from electrum.i18n import _
from .textfielddialog import TextFieldDialog
from .passworddialog import PasswordDialog
from .waitingdialog import WaitingDialog
from functools import partial
from electrum import i18n

from objc import runloop as RunLoop
from objc import managers as Managers

class EnterWalletPasswordHandlerProtocol():
    def continueTapped(self, password):
        self.installWizard.processPassword(password)

class ConfirmSeedHandlerProtocol():
    def continueTapped(self):
        self.installWizard.processSeed(self.installWizard.seedText) # Next in InstallWizard.request_password

    def generatedSeed(self):
        return self.installWizard.seedText

class HaveASeedHandlerProtocol():
    def continueTapped(self, seed):
        self.installWizard.seedText = seed
        self.installWizard.seed_type = 'standard'
        self.installWizard.haveASeed = True
        self.installWizard.processSeed(seed)
        pass

    def seedType(self, seed):
        result = bitcoin.seed_type(seed)
        print('seedType result is: ' + str(result))
        return result

class CreateNewSeedHandlerProtocol():
    def init_(self):
        return self

    def continueTapped(self, newSeed):
        print('newSeed is: ' + newSeed)
        handler = ConfirmSeedHandlerProtocol()
        handler.installWizard = self.installWizard
        self.installWizard.seedText = newSeed
        self.installWizard.screensManager.showConfirmSeedViewController(handler)
        pass

    def generatedSeed(self):
        seed = self.installWizard.createSeed()
        return seed

class CreateWalletHandlerProtocol():
    def createNewSeedTapped(self):
        self.haveASeed = False
        handler = CreateNewSeedHandlerProtocol()
        handler.installWizard = self.installWizard
        self.installWizard.screensManager.showCreateNewSeedViewController(handler)
        print("create new seed handled in python")

    def haveASeedTapped(self):
        handler = HaveASeedHandlerProtocol()
        handler.installWizard = self.installWizard
        self.installWizard.screensManager.showHaveASeedViewController(handler)
        print("have a seed handled in python")

class EnterOrCreateWalletHandlerProtocol():
    def createWalletTapped(self):
        self.installWizard.beginCreateNewWallet()

    def openWalletTapped(self, walletName):
        self.installWizard.openWalletWithName(walletName)

    def walletsNames(self):
        self.namesList = self.installWizard.walletsNames()
        return self.namesList

    def deleteWalletAtIndex(self, index):
        try:
            walletName = self.namesList[index]
            self.installWizard.deleteWalletWithName(walletName)
        except:
            print('exc!');
            pass



class GoBack(Exception):
    pass

class InstallWizard(BaseWizard):
    pass
    def __init__(self, config, plugins, storage, daemon):
        BaseWizard.__init__(self, config, storage)
        print('Hello InstallWizard')
        self.daemon = daemon
        self.callback = None
        self.screensManager = Managers.shared().screensManager()
        self.config = config
        self.plugins = plugins
        self.storage = storage
        print('InstallWizard storage: ' + str(storage))
    
    def request_password(self):
        handler = EnterWalletPasswordHandlerProtocol()
        handler.installWizard = self
        self.screensManager.showEnterWalletPasswordViewController(handler)
    
    def run_and_get_wallet(self, callback):
        handler = EnterOrCreateWalletHandlerProtocol()
        handler.installWizard = self
        self.screensManager.showEnterOrCreateWalletViewController(handler)
        self.callback = callback
    
    def terminate(self):
        if self.callback:
            cb = self.callback
            self.callback = None
            print('wallet: ' + str(self.wallet) + '; type: ' + str(type(self.wallet).__name__))
            cb(self.wallet)
    
    def init_network(self, network):
        self.config.set_key('auto_connect', True, True)
        pass

    def waiting_dialog(self, task, msg):
        def empty(self):
            pass
        dialog = WaitingDialog(self, msg, task, empty, empty)

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
                self.terminate()
        else:
            message = _('Enter password for wallet:') + ' ' + walletName
            def passwordCallback(password):
                if len(password) == 0:
                    return
                try:
                    self.wallet = self.daemon.load_wallet(path, password)
                except:
                    self.wallet = None
                if self.wallet:
                    print('Successfully opened wallet with password')
                    self.terminate()
                else:
                    dialog = PasswordDialog(message, passwordCallback)
                    password = dialog.show()
        
            dialog = PasswordDialog(message, passwordCallback)
            password = dialog.show()
                

    def beginCreateNewWallet(self):
        walletName = "default_wallet"
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
        
        dialogCaption = _("Enter wallet name")
        
        def textFieldCallback(newName):
            if len(newName) == 0:
                return
        
            if newName not in names:
                self.processCreateNewWallet(newName)
                return
            
            dialog = TextFieldDialog(dialogCaption, newName, textFieldCallback)
            dialog.show()
                        
                        
        dialog = TextFieldDialog(dialogCaption, newName, textFieldCallback)
        dialog.show()
                        
    def processCreateNewWallet(self, walletName):

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
                
        handler = CreateWalletHandlerProtocol()
        handler.installWizard = self
        self.screensManager.showCreateWalletViewController(handler)

    def walletsNames(self):
        path = self.config.walletsPath()
        onlyfiles = [f for f in listdir(path) if isfile(join(path, f))]
        print('path: ' + path + '; onlyfiles: ' + str(onlyfiles))
        return onlyfiles

    def deleteWalletWithName(self, walletName):
        path = self.config.walletsPath()
        path = path + '/' + walletName
        os.remove(path)
