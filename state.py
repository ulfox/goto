#!/usr/bin/env python3

from sys import path as syspath
syspath.insert(0, 'modules')

from sys import argv, stdout
from os import path
import yaml


class LoadConfig():
    def read_conf(self, docFile):
        stateFile = docFile
        with open(stateFile, 'r') as _STREAM:
            try:
                _CFG = yaml.safe_load(_STREAM)
            except yaml.YAMLError as _EXC:
                raise

        return _CFG

    def update_conf(self, docFile, docCont):
        stateFile = docFile
        with open(stateFile, 'w') as file:
            yaml.dump(docCont, file)


class GotoState(LoadConfig):
    def __init__(self):
        self.rootDir = path.dirname(path.abspath(__file__))
        self.stateEnvFile = self.rootDir + '/.aliases.yml'

        if path.isfile(self.stateEnvFile):
            self.stateEnv = self.read_conf(docFile=self.stateEnvFile)
        else:
            self.stateEnv = {
                'aliases': {},
                'workdir': self.rootDir,
            }
            self.update_conf(
                docFile=self.stateEnvFile,
                docCont=self.stateEnv
            )

    def check_paths(self, p, **kwargs):
        if p.endswith("/") and len(p) > 1:
            p = p[:len(p)-1] 
        if kwargs["opts"].get("show", False):
            print(p)
        else:
            return p

    def add(self, alias, p):
        cpath = self.check_paths(p, opts={})
        self.stateEnv["aliases"][alias] = cpath
        self.update_conf(
            docFile=self.stateEnvFile, 
            docCont=self.stateEnv
        )

    def list_aliases(self):
        aliases = ["%s::::%s" % (x, self.stateEnv["aliases"][x]) for x in self.stateEnv["aliases"]]
        print(",".join(aliases))


    def rm(self, alias):
        if self.stateEnv["aliases"].get(alias):
            self.stateEnv["aliases"].pop(alias)
            self.update_conf(
                docFile=self.stateEnvFile, 
                docCont=self.stateEnv
            )
        else:
            print("Alias: %s does not exist" % alias)

    def get(self, alias):
        print(self.stateEnv["aliases"].get(alias, None))

    def check(self, alias):
        get_alias = self.stateEnv["aliases"].get(alias, None)
        if get_alias:
            print("%s::::%s" % (True, get_alias))
        else:
            print("%s::::%s" % (False, get_alias))

    def set_workdir(self, path):
        cpath = self.check_paths(path, opts={})
        self.stateEnv["workdir"] = cpath
        self.update_conf(
            docFile=self.stateEnvFile,
            docCont=self.stateEnv
        )

    def get_workdir(self):
        workdir = self.stateEnv.get("workdir", None)
        if workdir == None:
            self.set_workdir(self.rootDir)
            print(self.rootDir)
        else:
            print(workdir)

if __name__ == "__main__":
    gotoState = GotoState()
    if argv[1] == "add":
        gotoState.add(argv[2], argv[3])
    elif argv[1] == "check_paths":
        gotoState.check_paths(argv[2], opts={"show": True})
    elif argv[1] == "list":
        gotoState.list_aliases()
    elif argv[1] == "rm":
        gotoState.rm(argv[2])
    elif argv[1] == "get":
        gotoState.get(argv[2])
    elif argv[1] == "check":
        gotoState.check(argv[2])
    elif argv[1] == "set_workdir":
        gotoState.set_workdir(argv[2])
    elif argv[1] == "get_workdir":
        gotoState.get_workdir()
