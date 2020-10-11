#/usr/bin/env python3

from functions import informUser, ObjectActions, envConfig
from os.path import dirname, abspath
from sys import argv, stdout

class GotoState(Exception, informUser, ObjectActions, envConfig):
    def __init__(self):
        self.rootDir = dirname(abspath(__file__))
        self.stateEnvFile = self.rootDir + '/.aliases.yml'

        if self.CheckIfFileExists(self.stateEnvFile):
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

    def check_paths(self, *args, **kwargs):
        path='' 
        for i in args:
            if not i.endswith('/'): 
                path = path + i + '/'
                continue

            path = path + i

        if kwargs["opts"].get("show", False):            
            print(path)
        else:
            return path

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


    def get(self, alias):
        print(self.stateEnv["aliases"].get(alias, None))

    def check(self, alias):
        get_alias = self.stateEnv["aliases"].get(alias, None)
        if get_alias:
            print("%s::::%s" % (True, get_alias))
        else:
            print("%s::::%s" % (False, get_alias))

    def list_aliases(self):
        aliases = ["%s::::%s" % (x, self.stateEnv["aliases"][x]) for x in self.stateEnv["aliases"]]
        print(",".join(aliases))

    def add(self, alias, path):
        cpath = self.check_paths(path, opts={})
        self.stateEnv["aliases"][alias] = cpath
        self.update_conf(
            docFile=self.stateEnvFile, 
            docCont=self.stateEnv
        )

    def rm(self, alias):
        if self.stateEnv["aliases"].get(alias):
            self.stateEnv["aliases"].pop(alias)
            self.update_conf(
                docFile=self.stateEnvFile, 
                docCont=self.stateEnv
            )
        else:
            print("Alias: %s does not exist" % alias)


if __name__ == "__main__":
    gotoState = GotoState()
    if argv[1] == "list":
        gotoState.list_aliases()
    elif argv[1] == "add":
        gotoState.add(argv[2], argv[3])
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
    elif argv[1] == "check_paths":
        gotoState.check_paths(*argv[2:], opts={"show": True})
