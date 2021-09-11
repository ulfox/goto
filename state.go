package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/sirupsen/logrus"
	"github.com/ulfox/dby/db"
	"gopkg.in/yaml.v2"
)

type locations struct {
	Aliases map[string]string
	Workdir string
}

type state struct {
	DB        *db.Storage
	Locations locations
	logger    *logrus.Logger
}

func (s *state) loadInterfaceToStruct() {
	err := s.DB.Read()
	if err != nil {
		s.logger.Fatalf(err.Error())
	}

	data, err := yaml.Marshal(&s.DB.Data[0])
	if err != nil {
		s.logger.Fatalf(err.Error())
	}

	err = yaml.Unmarshal(data, &s.Locations)
	if err != nil {
		s.logger.Fatalf(err.Error())
	}
}

func (s *state) checkPaths(p string, kwargs ...map[string]string) string {
	var showStdout bool
	if strings.HasSuffix(p, "/") && len(p) > 1 {
		p = p[:len(p)-1]
	}

	for _, j := range kwargs {
		if j["show"] != "" {
			showStdout = true
			break
		}

	}
	if showStdout {
		fmt.Print(kwargs[0]["show"])
	}
	return p
}

func (s *state) add(p, pwd string) {
	err := s.DB.Upsert(
		fmt.Sprintf("aliases.%s", p),
		pwd,
	)
	if err != nil {
		s.logger.Fatalf(err.Error())
	}
	s.loadInterfaceToStruct()
}

func (s *state) listAliases() {
	var aliases []string

	for i, j := range s.Locations.Aliases {
		aliases = append(aliases, fmt.Sprintf("%s::::%s", i, j))
	}
	fmt.Print(strings.Join(aliases, ","))
}

func (s *state) rm(p string) {
	s.DB.Delete(fmt.Sprintf("aliases.%s", p))
}

func (s *state) get(p string) {
	path, err := s.DB.GetPath(fmt.Sprintf("aliases.%s", p))
	if err != nil {
		return
	}
	fmt.Print(path.(string))
}

func (s *state) check(a string) {
	s.loadInterfaceToStruct()
	path, err := s.DB.GetPath(fmt.Sprintf("aliases.%s", a))
	if err != nil {
		fmt.Printf("%s::::%s\n", "False", "empty")
		return
	}
	fmt.Printf("%s::::%s\n", "True", path)
}

func (s *state) setWorkdir(p string) {
	err := s.DB.Upsert(
		"workdir",
		p,
	)
	if err != nil {
		s.logger.Fatalf(err.Error())
	}
	s.loadInterfaceToStruct()
}

func (s *state) getWorkdir() {
	path, err := s.DB.GetPath("workdir")
	if err != nil {
		return
	}
	fmt.Print(path.(string))
}

func main() {
	flag.Usage = func() {
		fmt.Printf("Usage: %s [options] \nOptions:\n", os.Args[0])
		flag.PrintDefaults()
	}

	logger := logrus.New()

	dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		logger.Fatalf(err.Error())
	}

	db, err := db.NewStorageFactory(dir + "/local/aliases.yaml")
	if err != nil {
		logger.Fatalf(err.Error())
	}

	gotoState := state{
		DB:     db,
		logger: logger,
		Locations: locations{
			Aliases: make(map[string]string),
		},
	}
	gotoState.loadInterfaceToStruct()

	addPath := flag.String("add", "", "add path as alias")
	checkPaths := flag.String("check_paths", "", "")
	listPaths := flag.Bool("list", false, "list paths")
	rmPaths := flag.String("rm", "", "remove path from alias")
	getPaths := flag.String("get", "", "get path from alias")
	check := flag.String("check", "", "")
	setWorkdir := flag.String("set_workdir", "", "set workdir")
	getWorkdir := flag.Bool("get_workdir", false, "get workdir")

	flag.Parse()
	if *addPath != "" {
		if len(flag.Args()) >= 1 {
			gotoState.add(*addPath, flag.Arg(0))
		}
	}

	if *checkPaths != "" {
		gotoState.checkPaths(*checkPaths, map[string]string{"show": "true"})
	}

	if *listPaths {
		gotoState.listAliases()
	}

	if *rmPaths != "" {
		gotoState.rm(*rmPaths)
	}

	if *getPaths != "" {
		gotoState.get(*getPaths)
	}

	if *check != "" {
		gotoState.check(*check)
	}

	if *setWorkdir != "" {
		gotoState.setWorkdir(*setWorkdir)
	}

	if *getWorkdir {
		gotoState.getWorkdir()
	}
}
