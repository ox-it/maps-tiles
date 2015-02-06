# Maps-Tiles

This repository contains:
 * the source files for maps
 * puppet files to provision a VM exposing TileMill
 * Vagrantfile to start a local VM

## Vagrant VM

Run `vagrant up` from the root of the repository. You can access TileMill at http://localhost:8088 (port forwarded).

You should run `fab vm init` the first time to setup some permissions on filestystem and database for the user vagrant.

## Remote server

TileMill UI is served on port 80, tiles are served on port 8080.

To run Fabric commands you need to set up two environment variables: `MAPS_HOST` (hostname of the server to SSH) and `MAPS_USER` (your user name on the server).

## Authentication for TileMill web interface

user // pass

## Update commands

You need `fabric` to run commands on the server (using a virtualenv, it is recommended to `pip install -r requirements.txt`).

You should run:
 * `fab server download_osm_oxf` to download the latest dump from OpenStreetMap for Oxfordshire
 * `fab server populate_osm` to feed PostGIS with the latest dump from OpenStreetMap

## Initial setup for an user

Once logged-in to the server, you should add your .gitconfig to the root of your user directory.

## Workflow for working with

After having done some changes, you should run `fab server tilemill_to_git` to copy the project files from the workspace (TileMill) to the git repository.

Using SSH, do `cd /srv/tilemill/maps-tiles` to navigate to the git repository; you can now use all the git commands (i.e. `commit`, `branch` etc)

## Note on git / github using HTTPS

You will notice fairly quickly that you will need to enter your username/password quite often when doing `git push` and `git pull`, that is because
we are using HTTPS, various techniques exist to reduce this issue: https://stackoverflow.com/questions/5343068/is-there-a-way-to-skip-password-typing-when-using-https-github

## Deploying tiles

Deploying the tiles to a server is done by running: `fab tiles deploy_tiles:/local/path/to.mbtiles`

It expects en environment variable `TILES_HOST` containing `host:port`, your public SSH key should have been deployed to `/srv/tiles/.ssh/authorized_keys` first.

## Similar projects

Here's a list of similar projects to run TileMill on a server:
 * https://github.com/perrygeo/vagrant-webmaps
 * https://github.com/miccolis/aws-tilemill
