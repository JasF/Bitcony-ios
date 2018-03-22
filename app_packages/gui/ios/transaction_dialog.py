
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
    
    @objc_method
    def amount_(self):
        return self.amount

    @objc_method
    def formattedAmount_(self):
        if self.amount > 0:
            return self.electrumWindow.format_amount(self.amount, whitespaces = True)
        else:
            return self.electrumWindow.format_amount(-self.amount, whitespaces = True)

    @objc_method
    def baseUnit_(self):
        return self.electrumWindow.base_unit()
    
    @objc_method
    def size_(self):
        size = self.dialog.tx.estimated_size()
        print('size is ' + str(size))
        return size

    @objc_method
    def fee_(self):
        return self.fee
    
    @objc_method
    def formattedFee_(self):
        return self.electrumWindow.format_amount(self.fee, whitespaces = True)

    @objc_method
    def inputsJson_(self):
        list = []
        for x in self.dialog.tx.inputs():
            dict = {}
            if x['type'] == 'coinbase':
                dict['left'] = 'coinbase'
            else:
                prevout_hash = x.get('prevout_hash')
                prevout_n = x.get('prevout_n')
                leftString = prevout_hash[0:8] + '...'
                leftString = leftString + (prevout_hash[-8:] + ":%-4d " % prevout_n)
                dict['left'] = leftString
                addr = x.get('address')
                if addr == "(pubkey)":
                    _addr = self.dialog.wallet.find_pay_to_pubkey_address(prevout_hash, prevout_n)
                    if _addr:
                        addr = _addr
                if addr is None:
                    addr = _('unknown')
                dict['right'] = addr
                dict['color'] = self.dialog.text_format(addr)
                if x.get('value'):
                    dict['value'] = self.dialog.format_amount(x['value'])
            list.append(dict)
        return str(list)
    
    @objc_method
    def outputsJson_(self):
        list = []
        for addr, v in self.dialog.tx.get_outputs():
            dict = {}
            dict['left'] = addr
            dict['color'] = self.dialog.text_format(addr)
            if v is not None:
                dict['right'] = self.dialog.format_amount(v)
            list.append(dict)
        return str(list)

    @objc_method
    def lockTime_(self):
        return self.dialog.tx.locktime



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


    def text_format(self, addr):
        if self.wallet.is_mine(addr):
            return "yellow" if self.wallet.is_change(addr) else "green"
        return "clear"
        
    def format_amount(self, amt):
        return self.main_window.format_amount(amt, whitespaces = True)
