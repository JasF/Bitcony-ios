#!/usr/bin/env python
#
# Electrum - lightweight Bitcoin client
# Copyright (C) 2015 Thomas Voegtlin
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

import webbrowser
import datetime

from electrum.wallet import AddTransactionException, TX_HEIGHT_LOCAL
from electrum.i18n import _
from electrum.util import block_explorer_URL, profiler

try:
    from electrum.plot import plot_history, NothingToPlotException
except:
    plot_history = None

# note: this list needs to be kept in sync with another in kivy
TX_ICONS = [
    "unconfirmed.png",
    "warning.png",
    "unconfirmed.png",
    "offline_tx.png",
    "clock1.png",
    "clock2.png",
    "clock3.png",
    "clock4.png",
    "clock5.png",
    "confirmed.png",
]


class HistoryList:
    filter_columns = [2, 3, 4]  # Date, Description, Amount

    def __init__(self, parent):
        self.parent = parent
        '''
        MyTreeWidget.__init__(self, parent, self.create_menu, [], 3)
        AcceptFileDragDrop.__init__(self, ".txn")
        self.setColumnHidden(1, True)
        self.setSortingEnabled(True)
        self.sortByColumn(0, Qt.AscendingOrder)
        '''
        self.start_timestamp = None
        self.end_timestamp = None
        self.years = []

    def format_date(self, d):
        return str(datetime.date(d.year, d.month, d.day)) if d else _('None')


    def get_domain(self):
        '''Replaced in address_dialog.py'''
        return self.wallet.get_addresses()

    def on_combo(self, x):
        self.update()

    @profiler
    def on_update(self):
        self.wallet = self.parent.wallet
        fx = self.parent.fx
        r = self.wallet.get_full_history(domain=self.get_domain(), from_timestamp=self.start_timestamp, to_timestamp=self.end_timestamp, fx=fx)
        self.transactions = r['transactions']
        self.summary = r['summary']
        if not self.years and self.transactions:
            from datetime import date
            start_date = self.transactions[0].get('date') or date.today()
            end_date = self.transactions[-1].get('date') or date.today()
            self.years = [str(i) for i in range(start_date.year, end_date.year + 1)]
        self.clear()
        entries = list()
        if fx: fx.history_used_spot = False
        for tx_item in self.transactions:
            tx_hash = tx_item['txid']
            height = tx_item['height']
            conf = tx_item['confirmations']
            timestamp = tx_item['timestamp']
            value = tx_item['value'].value
            balance = tx_item['balance'].value
            label = tx_item['label']
            status, status_str = self.wallet.get_tx_status(tx_hash, height, conf, timestamp)
            has_invoice = self.wallet.invoices.paid.get(tx_hash)
            v_str = self.parent.format_amount(value, True, whitespaces=True)
            balance_str = self.parent.format_amount(balance, whitespaces=True)
            entry = ['', tx_hash, status_str, label, v_str, balance_str]
            dict = {'tx_hash': tx_hash, 'date': status_str, 'amount': v_str, 'balance': balance_str, 'status': status}
            entries.append(dict)
            fiat_value = None
            if value is not None and fx and fx.show_history():
                fiat_value = tx_item['fiat_value'].value
                value_str = fx.format_fiat(fiat_value)
                entry.append(value_str)
                # fixme: should use is_mine
                if value < 0:
                    entry.append(fx.format_fiat(tx_item['acquisition_price'].value))
                    entry.append(fx.format_fiat(tx_item['capital_gain'].value))
        return entries;
    def clear(self):
        pass
    
    def update_item(self, tx_hash, height, conf, timestamp):
        status, status_str = self.wallet.get_tx_status(tx_hash, height, conf, timestamp)
        print('update_item: ' + tx_hash)
        '''
        icon = QIcon(":icons/" +  TX_ICONS[status])
        items = self.findItems(tx_hash, Qt.UserRole|Qt.MatchContains|Qt.MatchRecursive, column=1)
        if items:
            item = items[0]
            item.setIcon(0, icon)
            item.setData(0, SortableTreeWidgetItem.DataRole, (status, conf))
            item.setText(2, status_str)
            '''

    def remove_local_tx(self, delete_tx):
        print('Can remove transaction')
        '''
        to_delete = {delete_tx}
        to_delete |= self.wallet.get_depending_transactions(delete_tx)
        question = _("Are you sure you want to remove this transaction?")
        if len(to_delete) > 1:
            question = _(
                "Are you sure you want to remove this transaction and {} child transactions?".format(len(to_delete) - 1)
            )
        answer = QMessageBox.question(self.parent, _("Please confirm"), question, QMessageBox.Yes, QMessageBox.No)
        if answer == QMessageBox.No:
            return
        for tx in to_delete:
            self.wallet.remove_transaction(tx)
        self.wallet.save_transactions(write=True)
        # need to update at least: history_list, utxo_list, address_list
        self.parent.need_update.set()
        '''

