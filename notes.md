## Useful commands

`docker build` with `--no-cache` to build from scratch in order to pick up the latests downloads

`docker run` with `--privileged` if you want to use `perf` (not actually currently installed)

`docker image ls` list containers with sizes

## perf

This is for studying the performance of a metamatch command in the context of this Docker container

    sudo perf record -g -- checkmmc set.mm
    perf report
