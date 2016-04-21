
Bash script to create docker container to be used for development

## Usage

1. run `./setup.sh` to create `ddbash` symlink
2. cd into development project and run `ddbash <imageName>` where imageName is defined base image to be used for development environment. For example: `ddbash node5`

To add more base images, define them in `ddbash-osx.sh`. Example:

```bash
imagemap[node5]="node:5"
imagemap[ruby230]="ruby:2.3.0"
```

## Example
```bash

$ cd my-project/
$ ddbash

#?!> ERR: Which dev image to use?
#?!> Available images: [ruby230 node5]

$ ddbash node5

Image node5_dev does not exist. Creating...

******* BUILD DEV IMAGE: node5_dev *******

Sending build context to Docker daemon 13.82 kB
Step 1 : FROM node:5
 ---> 1de2e178998e
...
Successfully built c7d718fc7d5f

******* START DEV CONTAINER: *******

#> Bash version: 4.3.42(1)-release
#> Using image [node5_dev]
Container [my-project.node5_dev] is not running. Starting...

my-project.node5_dev /data >
```
