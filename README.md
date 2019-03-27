# evansjp-dev-box
Dockerfile for development

### Startup
```
docker run -it --detach-keys="ctrl-@" -v /mnt/isilon/:/mnt/isilon/ --user $(id -u) quay.research.chop.edu/evansj/evansj-dev-box zsh
```

### Conda envs
I store conda envs in host directory `/mnt/isilon/dbhi_bfx/perry/dev-conda-envs/`. Create envs here using
```
conda create -p /mnt/isilon/dbhi_bfx/perry/dev-conda-envs/cookie python=3.7
```

### singularity cache

### Modifications
* UID
