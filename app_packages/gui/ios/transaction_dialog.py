
import copy
import datetime
import json
import traceback
from rubicon.objc import ObjCClass, NSObject, objc_method

from electrum.bitcoin import base_encode
from electrum.i18n import _
from electrum.plugins import run_hook
from electrum import simple_config

from electrum.util import bfh
from electrum.wallet import AddTransactionException
from electrum.transaction import SerializationError

class TransactionDetailHandler(NSObject):
    @objc_method
    def init_(self):
        return self

    @objc_method
    def transactionID_(self):
        return self.tx_hash
    
    @objc_method
    def status_(self):
        return self.status
    
    @objc_method
    def date_(self):
        time_str = datetime.datetime.fromtimestamp(self.timestamp).isoformat(' ')[:-3]
        return time_str


def show_transaction(tx, parent, desc=None, prompt_if_unsaved=False):
    try:
        d = TxDialog(tx, parent, desc, prompt_if_unsaved)
    except SerializationError as e:
        traceback.print_exc(file=sys.stderr)
        parent.show_critical(_("Electrum was unable to deserialize the transaction:") + "\n" + str(e))
    else:
        d.show()


class TxDialog:

    def __init__(self, tx, parent, desc, prompt_if_unsaved):
        self.tx = copy.deepcopy(tx)
        try:
            self.tx.deserialize()
        except BaseException as e:
            raise SerializationError(e)
        
        self.main_window = parent
        self.wallet = parent.wallet
        self.prompt_if_unsaved = prompt_if_unsaved
        self.saved = False
        self.desc = desc

    def show(self):
        handler = TransactionDetailHandler.alloc().init()
        handler.electrumWindow = self.main_window
        handler.dialog = self
        
        tx_hash, status, label, can_broadcast, can_rbf, amount, fee, height, conf, timestamp, exp_n = self.wallet.get_tx_info(self.tx)
        handler.tx_hash = tx_hash
        handler.status = status
        handler.label = label
        handler.can_broadcast = can_broadcast
        handler.can_rbf = can_rbf
        handler.amount = amount
        handler.fee = fee
        handler.height = height
        handler.conf = conf
        handler.timestamp = timestamp
        handler.exp_n = exp_n
        
        self.main_window.screensManager.showTransactionDetailViewController(handler)

