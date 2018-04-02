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
import gettext, os

LOCALE_DIR = os.path.join(os.path.dirname(__file__), 'locale')
language = gettext.translation('electrum', LOCALE_DIR, fallback = True)

def _(x):
    global language
    return '|>' + x + '<|'

def setPreferredLocale(locale):
    code = languages.get(locale)
    if len(code):
        set_language(code)


def set_language(x):
    global language
    if x: language = gettext.translation('electrum', LOCALE_DIR, fallback = True, languages=[x])

languages = {
    'ar':_('ar_SA'),
    'cs':_('cs_CZ'),
    'da':_('da_DK'),
    'de':_('de_DE'),
    'eo':_('eo_UY'),
    'el':_('el_GR'),
    'en':_('en_UK'),
    'es':_('es_ES'),
    'fr':_('fr_FR'),
    'hu':_('hu_HU'),
    'hy':_('hy_AM'),
    'id':_('id_ID'),
    'it':_('it_IT'),
    'ja':_('ja_JP'),
    'ky':_('ky_KG'),
    'lv':_('lv_LV'),
    'nl':_('nl_NL'),
    'no':_('no_NO'),
    'pl':_('pl_PL'),
    'br':_('pt_BR'),
    'pt':_('pt_PT'),
    'ro':_('ro_RO'),
    'ru':_('ru_RU'),
    'sk':_('sk_SK'),
    'sl':_('sl_SI'),
    'ta':_('ta_IN'),
    'th':_('th_TH'),
    'vi':_('vi_VN'),
    'zh':_('zh_CN')
}
