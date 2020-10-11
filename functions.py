#/usr/bin/env python3

from sys import exit
from os import path, makedirs
import tarfile
import shutil
import yaml


class envConfig():
    def read_conf(self, docFile):
        environmentFile = docFile
        with open(environmentFile, 'r') as _STREAM:
            try:
                _CFG = yaml.safe_load(_STREAM)
            except yaml.YAMLError as _EXC:
                logging.error(_EXC)

        return _CFG

    def update_conf(self, docFile, docCont):
        environmentFile = docFile
        with open(environmentFile, 'w') as file:
            doc = yaml.dump(docCont, file)

class informUser():
    def die(self, *args, exitCode=0):
        for err in args:
            print(err)

        exit(exitCode)

class ObjectActions():
    def CheckIfDirExists(self, DIR):
        if not path.exists(DIR):
            makedirs(DIR)
        else:
            if not path.isdir(DIR):
                return False
        
        return True
    
    def CheckIfFileExists(self, FILE):
        if not path.exists(FILE):
            return False
        else:
            if not path.isfile(FILE):
                return False
        
        return True

    def CheckIfPathExists(self, DIR):
        if not path.exists(DIR):
            return False
        else:
            if not path.isdir(DIR):
                return False
        
        return True

    def GetDirName(self, FILE):
        connectorTarFile, connectorCompExt = path.splitext(FILE)
        return connectorTarFile
