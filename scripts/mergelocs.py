import os
from pathlib import Path

def mergeFiles(src, dest):
    srcfile = open(src, 'r')
    srclines = srcfile.readlines()
    forappend = ''.join(srclines)
    dstfile = open(dest, 'a')
    dstfile.write(forappend)
    dstfile.close()

def processContentFromFile(path):
    if '.lproj' not in path:
        return
    array = path.split('/')
    code = array[2].split('.')[0]
    print('code ' + path)
    destpath = '../Electrum/texts/' + code + '.lproj/Localizable.strings'
    if Path(destpath).is_file():
        mergeFiles(path, destpath)
    else:
        print(': ' + code)
        exit(1)
for root, dirs, files in os.walk("../temp"):
    for file in files:
        path = root + '/' + file
        processContentFromFile(path)
