
# TianGong LCA Data

## Env Preparing

### Using VSCode Dev Contariners

Install requirements:

```bash
sudo apt update
sudo apt upgrade

sudo apt install git-lfs
```

In the project root:

```bash
git lfs install
git lfs pull

```

Optional

```bash
git lfs track "*.jpg"
git lfs track "*.JPG"
git lfs track "*.png"
git lfs track "*.PNG"


```

### Auto Build

The auto build will be triggered by pushing any tag named like v$version. For instance, push a tag named as v0.0.1 will build a release of 0.0.1 version.

```bash
#list existing tags
git tag
#creat a new tag
git tag v0.0.1
#push this tag to origin
git push origin v0.0.1
```

## To Do

DDG empty results bug
