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

type Locations struct {
	Aliases map[string]string
	Workdir string
}

type State struct {
	DB        *db.Storage
	Locations Locations
	logger    *logrus.Logger
}

func (s *State) loadInterfaceToStruct() {
	s.DB.Read()

	data, err := yaml.Marshal(&s.DB.Data)
	if err != nil {
		s.logger.Fatalf(err.Error())
	}

	err = yaml.Unmarshal(data, &s.Locations)
	if err != nil {
		s.logger.Fatalf(err.Error())
	}
}

func (s *State) checkPaths(p string, kwargs ...map[string]string) string {
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

func (s *State) add(p, pwd string) {
	err := s.DB.Upsert(
		fmt.Sprintf("aliases.%s", p),
		pwd,
	)
	if err != nil {
		s.logger.Fatalf(err.Error())
	}
	s.loadInterfaceToStruct()
}

func (s *State) list_aliases() {
	var aliases []string

	for i, j := range s.Locations.Aliases {
		aliases = append(aliases, fmt.Sprintf("%s::::%s", i, j))
	}
	fmt.Print(strings.Join(aliases, ","))
}

func (s *State) rm(p string) {
	s.DB.Delete(fmt.Sprintf("aliases.%s", p))
}

func (s *State) get(p string) {
	path, err := s.DB.GetPath(fmt.Sprintf("aliases.%s", p))
	if err != nil {
		return
	}
	fmt.Print(path.(string))
}

func (s *State) check(a string) {
	s.loadInterfaceToStruct()
	path, err := s.DB.GetPath(fmt.Sprintf("aliases.%s", a))
	if err != nil {
		fmt.Printf("%s::::%s\n", "False", "empty")
		return
	}
	fmt.Printf("%s::::%s\n", "True", path)
}

func (s *State) setWorkdir(p string) {
	err := s.DB.Upsert(
		"workdir",
		p,
	)
	if err != nil {
		s.logger.Fatalf(err.Error())
	}
	s.loadInterfaceToStruct()
}

func (s *State) getWorkdir() {
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

	state := State{
		DB:     db,
		logger: logger,
		Locations: Locations{
			Aliases: make(map[string]string),
		},
	}
	state.loadInterfaceToStruct()

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
			state.add(*addPath, flag.Arg(0))
		}
	}

	if *checkPaths != "" {
		state.checkPaths(*checkPaths, map[string]string{"show": "true"})
	}

	if *listPaths {
		state.list_aliases()
	}

	if *rmPaths != "" {
		state.rm(*rmPaths)
	}

	if *getPaths != "" {
		state.get(*getPaths)
	}

	if *check != "" {
		state.check(*check)
	}

	if *setWorkdir != "" {
		state.setWorkdir(*setWorkdir)
	}

	if *getWorkdir {
		state.getWorkdir()
	}
}
