import os
import sys
import threading
import traceback
from rubicon.objc import ObjCClass, NSObject, objc_method

from electrum import Wallet, WalletStorage
from electrum.util import UserCancelled, InvalidPassword
from electrum.base_wizard import BaseWizard, HWD_SETUP_DECRYPT_WALLET
from electrum.i18n import _


class ElectrumWindow:
    def __init__(self, wallet):
        self.wallet = wallet
        Managers = ObjCClass("Managers")
        self.runLoop = ObjCClass("RunLoop").shared();
        self.screensManager = Managers.shared().screensManager()

    def exec(self):
        self.runLoop.exec()
