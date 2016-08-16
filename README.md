# Maps-Tiles

This repository contains:

 * `maps-ox/`: source files for map tiles (i.e. stylesheets)
 * `data/`: GeoJSON files containing transformed OxPoints data
 * `puppet/`: puppet files to provision a VM exposing TileMill
 * `Vagrantfile` to start a local VM using Vagrant

## Export with standalone maps app
As of August 2016, the tilemill server wasn't operational and attempts to restore it haven't been successful.
Instead, the following method can be used to generate the map tiles

1. Install tilemill
Default install doesn't work. Instead see the note here https://github.com/mapbox/tilemill/issues/2550
2. Copy the maps-ox folder to ~/Documents/MapBox/project
3. Copy the data folder to /srv/tilemill/maps-tiles
4. Download the following .zip files and copy to /srv/tilemill/mapbox:
    - http://mapbox-geodata.s3.amazonaws.com/natural-earth-1.3.0/physical/10m-land.zip
    - http://tilemill-data.s3.amazonaws.com/osm/coastline-good.zip
    - http://tilemill-data.s3.amazonaws.com/osm/shoreline_300.zip
5. Run Docker container for postgis database
```
docker-compose up
```
6. Trigger osm import to postgis database
```
docker exec -it mapstiles_pg_1 /bin/bash /srv/fetch_osm.sh
```
Enter password 'docker' when prompted
7. Modify project.mml to amend connection details for each Datasource as follows:
```
    "dbname": "gis",
    "host": "docker-default",
    "port": "5432",
    "user": "docker",
    "password": "docker",
```
8. Open project in tilemill
9. Add all .mss stylesheets from maps-ox. This only seems to be possible by manually creating them and then pasting the contents of the files.
10. If necessary amend pg_hba.conf to allow incoming connections from tilemill. The docker container output will show an error if this is needed.
11. At this point the map should show up with appropriate appearance and labels etc. The tiles can be exported according to the instructions below.

## Vagrant VM

Run `vagrant up` from the root of the repository. You can access TileMill at http://localhost:8088 (port forwarded).

You should run `fab vm init` the first time to setup some permissions on filestystem and database for the user vagrant.

## Remote server

TileMill UI is served on port 80, tiles are served on port 8080.

To run **Fabric** commands you need to set up two environment variables:

* `MAPS_HOST` (hostname of the server to SSH)
* `MAPS_USER` (your user name on the server).

Use the following syntax to set an environment variable:

    export NAME=VALUE

## Authentication for TileMill web interface

It is using HTTP Basic Auth, default username/password are: `user` / `pass`.

## Initial setup for a new user

Once logged-in to the server, you should add your `.gitconfig` to the root of your user directory.

Also run the following **Fabric** command to "attach" your user to PostGIS:

    fab server init

## Update OpenStreetMap data

You need **Fabric** to run commands on the server (using a virtualenv, it is recommended to `pip install -r requirements.txt`).

Run the following command to download the latest dump from OpenStreetMap and populate PostGIS with it:

    fab server update_osm

**Important note**: the script will ask for your password, and it is expected that you have `sudo` access to the machine. See `fabfile.py` for more information.

## Update OxPoints data

Follow the process in the directory `data/` and make sure that you commit and push
the updated GeoJSON files.

SSH into the Tilemill server and go to the git repository at `/srv/tilemill/maps-tiles`,
make sure you are on the correct branch and fetch the latest changes (`git pull`).

## Workflow for working with Tilemill and git

After having done some changes, you should run the following command to copy the project files from the workspace (TileMill) to the git repository:

    fab server tilemill_to_git

Using SSH, navigate to `/srv/tilemill/maps-tiles` to navigate to the git repository; you can now use all the git commands (i.e. `commit`, `branch` etc)

### Using git / GitHub with HTTPS

You will notice fairly quickly that you will need to enter your username/password quite often when doing `git push` and `git pull`, that is because
we are using HTTPS, various techniques exist to reduce this issue: https://stackoverflow.com/questions/5343068/is-there-a-way-to-skip-password-typing-when-using-https-github

## Exporting tiles from TileMill

Use the web interface to export in `MBTiles` format. Default parameters are fine.

Once the export is done ("process exited"...), go to `/usr/share/mapbox/export` and
`scp` the most recent `maps-ox.mbtiles` file (which can be suffixed with a random string
if there are multiple exports) to your machine. For example:

    scp myusername@tilemill.mydomain:/usr/share/mapbox/export/maps-ox.mbtiles .

## Deploying tiles

Deploying the tiles to a server is done by running the **Fabric** command:

    fab tiles deploy_tiles:/local/path/to.mbtiles

It expects en environment variable `TILES_HOST` containing `host:port`, your public SSH key should have been deployed to `/srv/tiles/.ssh/authorized_keys` first.

## Similar projects

Here's a list of similar projects to run TileMill on a server:
 * https://github.com/perrygeo/vagrant-webmaps
 * https://github.com/miccolis/aws-tilemill
