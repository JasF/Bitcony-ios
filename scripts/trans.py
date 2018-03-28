# Imports the Google Cloud client library
import os
import json
import pathlib

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = '/Users/jasf/horo-ios-37af8506fd1b.json'

import google.auth
from google.cloud import translate

# Instantiates a client
translate_client = translate.Client()

text_file = open("../unlocalized.h", "r")
lines = text_file.readlines()
targets = ['ar','bg','cs','da','de','el','eo','es','fa','fr','hu','hy','id','it','ja','ko','ky','lv','nb','nl','nn','pl','pt','ro','ru','sk','sl','sv','ta','th','tr','uk','vi','zh']

print(str(lines))
for line in lines:
    line = line.replace("'",'')
    line = line.replace('\n','')
    uniline = str(line)
    for target in targets:
        translation = translate_client.translate(uniline, target_language=target)
        path = '../temp/' + target + '.lproj/'
        if not os.path.exists(path):
            pathlib.Path(path).mkdir(parents=True, exist_ok=True)
        translated = translation['translatedText']
        content = u'"' + line + '"="' + translated + '";\n'
        contentFile = open(path + 'Localizable.strings', 'a')
        contentFile.write(content)
        contentFile.close()
        print(content)
