# Metamath command line tools in Docker

A docker image containing the [set.mm](https://github.com/metamath/set.mm) repository and the following command line tools for Metamath:

* [metamath.exe](https://us.metamath.org/index.html#mmprog)
* [checkmm](https://us.metamath.org/other.html#checkmm)
* [metamath-knife](https://github.com/david-a-wheeler/metamath-knife)
* [mmj2](https://github.com/digama0/mmj2)
* [mmverify.py](https://github.com/david-a-wheeler/mmverify.py)
* [metamath-test](https://github.com/david-a-wheeler/metamath-test)
* [hmm - Haskell Metamath verifier](http://home.solcon.nl/mklooster/repos/hmm/)

And a few of my own:

* [checkmm-ts](https://github.com/Antony74/checkmm-ts)
* [prettier-plugin-mm (beta)](https://github.com/Antony74/prettier-plugin-mm)
* [alt-mm (beta)](https://github.com/Antony74/alt-mm)

## Getting started

    git clone https://github.com/Antony74/metamath-docker.git
    cd metamath-docker
    docker build -t akb74/metamath-cmds .
    docker run -it akb74/metamath-cmds

## Getting started with dockerhub

The [dockerhub image](https://hub.docker.com/repository/docker/akb74/metamath-cmds/general) will usually be out of date, but the run command

    docker run -it akb74/metamath-cmds

will pull from dockerhub if you don't have a local build.
