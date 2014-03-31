Maps-Tiles
==========

This repository contains:
 * the source files for maps
 * puppet files to provision a VM exposing TileMill
 * Vagrantfile to start a local VM

Vagrant VM
----------

Run `vagrant up` from the root of the repository. You can access TileMill at http://localhost:8088 (port forwarded).

You should run `fab vm init` the first time to setup some permissions on filestystem and database for the user vagrant.


Remote server
-------------

TileMill UI is served on port 80, tiles are served on port 8080.

To run Fabric commands you need to set up two environment variables: `MAPS_HOST` (hostname of the server to SSH) and `MAPS_USER` (your user name on the server). 


Authentication for TileMill web interface
-----------------------------------------

user // pass



Update commands
---------------

You need `fabric` to run commands on the server (using a virtualenv, it is recommended to `pip install -r requirements.txt`).

You should run:
 * `fab server download_osm_oxf` to download the latest dump from OpenStreetMap for Oxfordshire
 * `fab server populate_osm` to feed PostGIS with the latest dump from OpenStreetMap
