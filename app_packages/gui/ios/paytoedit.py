import re
from decimal import Decimal
from electrum import bitcoin

RE_ADDRESS = '[1-9A-HJ-NP-Za-km-z]{26,}'
RE_ALIAS = '(.*?)\s*\<([1-9A-HJ-NP-Za-km-z]{26,})\>'

class PayToEdit:

    def __init__(self, win, text):
        self.win = win
        self.text = text
        self.amount_edit = win.amount_e
        self.outputs = []
        self.errors = []
        self.is_pr = False
        self.is_alias = False
        self.scan_f = win.pay_to_URI
        self.payto_address = None
        self.previous_payto = ''
        self.check_text()

    def parse_address_and_amount(self, line):
        x, y = line.split(',')
        out_type, out = self.parse_output(x)
        amount = self.parse_amount(y)
        return out_type, out, amount

    def parse_output(self, x):
        try:
            address = self.parse_address(x)
            return bitcoin.TYPE_ADDRESS, address
        except:
            script = self.parse_script(x)
            return bitcoin.TYPE_SCRIPT, script

    def parse_script(self, x):
        from electrum.transaction import opcodes, push_script
        script = ''
        for word in x.split():
            if word[0:3] == 'OP_':
                assert word in opcodes.lookup
                script += chr(opcodes.lookup[word])
            else:
                script += push_script(word).decode('hex')
        return script

    def parse_amount(self, x):
        if x.strip() == '!':
            return '!'
        p = pow(10, self.amount_edit.decimal_point())
        return int(p * Decimal(x.strip()))

    def parse_address(self, line):
        r = line.strip()
        m = re.match('^'+RE_ALIAS+'$', r)
        address = str(m.group(2) if m else r)
        assert bitcoin.is_address(address)
        return address

    def check_text(self):
        self.errors = []
        if self.is_pr:
            return
        # filter out empty lines
        lines = [i for i in self.lines() if i]
        outputs = []
        total = 0
        self.payto_address = None
        if len(lines) == 1:
            data = lines[0]
            if data.startswith("bitcoin:"):
                self.scan_f(data)
                return
            try:
                self.payto_address = self.parse_output(data)
            except:
                pass
            if self.payto_address:
                self.win.lock_amount(False)
                return

        is_max = False
        for i, line in enumerate(lines):
            try:
                _type, to_address, amount = self.parse_address_and_amount(line)
            except:
                self.errors.append((i, line.strip()))
                continue

            outputs.append((_type, to_address, amount))
            if amount == '!':
                is_max = True
            else:
                total += amount

        self.win.is_max = is_max
        self.outputs = outputs
        self.payto_address = None

        if self.win.is_max:
            self.win.do_update_fee()
        else:
            self.amount_edit.setAmount(total if outputs else None)
            self.win.lock_amount(total or len(lines)>1)

    def get_errors(self):
        return self.errors

    def get_recipient(self):
        return self.payto_address

    def get_outputs(self, is_max):
        if self.payto_address:
            if is_max:
                amount = '!'
            else:
                amount = self.amount_edit.get_amount()

            _type, addr = self.payto_address
            self.outputs = [(_type, addr, amount)]

        return self.outputs[:]

    def lines(self):
        return [self.text]

    def is_multiline(self):
        return len(self.lines()) > 1


    def qr_input(self):
        data = super(PayToEdit,self).qr_input()
        if data.startswith("bitcoin:"):
            self.scan_f(data)
            # TODO: update fee

    def resolve(self):
        self.is_alias = False
        if self.hasFocus():
            return
        if self.is_multiline():  # only supports single line entries atm
            return
        if self.is_pr:
            return
        key = str(self.toPlainText())
        if key == self.previous_payto:
            return
        self.previous_payto = key
        if not (('.' in key) and (not '<' in key) and (not ' ' in key)):
            return
        parts = key.split(sep=',')  # assuming single line
        if parts and len(parts) > 0 and bitcoin.is_address(parts[0]):
            return
        try:
            data = self.win.contacts.resolve(key)
        except:
            return
        if not data:
            return
        self.is_alias = True

        address = data.get('address')
        name = data.get('name')
        new_url = key + ' <' + address + '>'
        self.setText(new_url)
        self.previous_payto = new_url

        #if self.win.config.get('openalias_autoadd') == 'checked':
        self.win.contacts[key] = ('openalias', name)
        self.win.contact_list.on_update()

        if data.get('type') == 'openalias':
            self.validated = data.get('validated')
            '''
            if self.validated:
                self.setGreen()
            else:
                self.setExpired()
                '''
        else:
            self.validated = None

