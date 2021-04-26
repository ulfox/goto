# goto


Project for navigating between directories

[Docs:Kafka-Video-Streaming](https://blog.primef.org/blog/kafka/2021-04-10/kafka-video-stream/)

![goto](https://github.com/ulfox/goto/blob/main/media/goto.gif)


### Installing goto

First get the code

    git clone https://github.com/ulfox/goto.git

##### Get dependenceis

    bash setup.sh

The installation after you download the pyyaml dependency is very trivial, since all we have to do is add in our ..bashrc. the following line

If we assume you installed moved the goto app under /opt/goto, then

    source /opt/goto/goto/goto.sh

Once you add the above line in your .bashrc do a hot env reload


    source ~/.bashrc


## Runtime dependencies
- python3
- pyyaml

##  Installation

- Clone the project to your desired location
- Add in your .bashrc `source /path/to/goto/goto.sh`
- Finally reload your current env `source ~/.bashrc`

## Usage

---
## **Set a project directory**

    goto set-pdir /some/path

Example:

    goto set-pdir /datafs/workdir

The above command will make goto to show directories that are under that path

| Note: You should set some project directory. The default one is the goto's workdir! |
| --- |
---

### Set aliases for your directories

Let us assume we have 3 projects (directories) under the set-pdir path we set.

    > ls /datafs/workdir/
    someProject  my-go-project  my-python-project
    

First navigate to the desired project's directory.

    > goto project <Tab>
    someProject  my-go-project  my-python-project

    > goto project my-go-project
    Changing directory to --- /datafs/workdir/my-go-project

Set an alias for that project

    > goto set gp

#### View aliases

    > goto list

    Aliases
      gp @ /datafs/workdir/my-go-project

### Navigate using Aliases names

Now that we have set an alias, if we want to visit that location again instead of trying to 
remember the path or doing a reverse-search, you can just call **goto alias_name**

    ## We are under $HOME
    > pwd
    /home/ulfox

    > goto gp
    > pwd
    /datafs/workdir/my-go-project

### Set aliases outside of goto's project dir

If you want to save a location that is outside of goto's prjects dir, then navigate to that location manually
and then set an alias at that location

    > cd ~
    > pwd
    /home/ulfox

    > goto set home
    > goto set h

    > goto list
    Aliases
      gp @ /datafs/workdir/my-go-project
      h @ /home/ulfox
      home @ /home/ulfx

### Remove an alias from goto's list

    > goto rm <Tab><Tab>
    > gp h home

    > goto rm home
    > goto rm <Tab><Tab>
    gp h

### Get Help

    goto help

    Goto -- help menu
    
     alias          Change directory to the given alias name
     set <alias>    Set an alias to this location
     rm  <alias>    Remove alias from list
     list           List saved aliases
     show-projects  Get projects
     project        Navigate to an available project
     set-pdir       Set a new project path
     help           Show this message and exit

