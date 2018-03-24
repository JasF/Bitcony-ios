import os
from fnmatch import fnmatch
import shutil
import os, errno


root = "./decoded-locale's"
pattern = "*.py"

def postprocess(str):
    str = str.replace('&', '')
    return str

def getFullMsgStr(content, i):
    result = ''
    y=0
    while i<len(content):
        line = content[i]
        if len(line) <= 1:
            break
        f = line.find('"') + 1
        l = line.find('"', f)
        lineContent = line[f:l]
        result = result + lineContent
        i = i + 1
    return postprocess(result)

def getFullMsgId(content, i):
    result = ''
    y=0
    while i<len(content):
        line = content[i]
        if line.split(' ')[0] == 'msgstr':
            break
        f = line.find('"') + 1
        l = line.find('"', f)
        lineContent = line[f:l]
        result = result + lineContent
        i = i + 1
    return postprocess(result), i

def processLocalization(content, path):
    print(path)
    code = path.split('/')[2].split('_')[0]
    newPath = './locs/' + code + '.lproj'
    try:
        os.makedirs(newPath)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise
    newPath = newPath + '/Localizable.strings'
    text_file = open(newPath, 'w')
    text_file.write(content)
    text_file.close()

def processPoFileContent(content, path):
    i=0
    localization = ""
    while i<len(content):
        line = content[i]
        if line.split(' ')[0] == 'msgid':
            fullMsgId, y = getFullMsgId(content, i)
            fullMsgStr = getFullMsgStr(content, y)
            if len(fullMsgId) > 1:
                localization = localization + '"' + fullMsgId + '"' + '=' + '"' + fullMsgStr + '"' + ';\n'
            i=i+2
        else:
            i=i+1
    processLocalization(localization, path)
    pass

def processPoFile(path):
    with open (path, 'r') as myfile:
        data=myfile.readlines()
        processPoFileContent(data, path)

def main():
    for path, subdirs, files in os.walk(root):
        for name in files:
            if name.endswith('.po'):
                processPoFile(path + '/' + name)

try:
    shutil.rmtree('./locs')
except:
    pass
#processPoFile("./decoded-locale's/cs_CZ/LC_MESSAGES/electrum.mo.po")
main()
