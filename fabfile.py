import os
from datetime import datetime

from fabric.api import *
from fabric.contrib import *
from fabric.contrib.files import exists, sed
from fabric import utils

OSM_DOWNLOAD = 'http://download.geofabrik.de/europe/great-britain/england/oxfordshire-latest.osm.pbf'

# environments

@task
def vm():
    """Configuration for Vagrant VMs (provisioned w/ Puppet)
    """
    env.user = local('vagrant ssh-config | grep User', capture=True).split()[1]
    ssh_port = local('vagrant ssh-config | grep Port', capture=True).split()[1]
    env.hosts = ['127.0.0.1:{port}'.format(port=ssh_port)]
    result = local('vagrant ssh-config | grep IdentityFile', capture=True)
    env.key_filename = result.split()[1]
    env.tilemill_home = '/srv/tilemill'
    env.osm_file = 'oxfordshire-latest.osm.pbf'
    env.osm_db = 'osm'

@task
def server():
     """Configuration for remote server
     """
     host = os.getenv('MAPS_HOST')
     env.hosts = ['{name}:22'.format(name=host)]
     env.user = os.getenv('MAPS_USER')
     env.tilemill_home = '/srv/tilemill'
     env.osm_file = 'oxfordshire-latest.osm.pbf'
     env.osm_db = 'osm'

# commands to prepare server

@task
def init():
    """Initialise permissions for user
    """
    run('sudo adduser {user} tilemill'.format(user=env.user), warn_only=True)
    sudo('createuser {user} -S -R -D -l'.format(user=env.user), user='postgres', warn_only=True)
    sudo('psql {db} -c "GRANT ALL ON spatial_ref_sys TO {user};"'.format(user=env.user, db=env.osm_db), user='postgres', warn_only=True)
    sudo('psql {db} -c "GRANT ALL ON geography_columns TO {user};"'.format(user=env.user, db=env.osm_db), user='postgres', warn_only=True)
    sudo('psql {db} -c "GRANT ALL ON geometry_columns TO {user};"'.format(user=env.user, db=env.osm_db), user='postgres', warn_only=True)
    sudo('psql -c "GRANT ALL ON DATABASE {db} TO {user};"'.format(user=env.user, db=env.osm_db), user='postgres', warn_only=True)
     
     
# commands

@task
def download_osm_oxf():
    """Download latest OpenStreetMap dump for Oxfordshire
    """
    run('curl "{osm_download}" > {tilemill_home}/{osm_file}'.format(osm_download=OSM_DOWNLOAD,
                                                                      tilemill_home=env.tilemill_home,
                                                                      osm_file=env.osm_file))

@task
def populate_osm():
    """Run importer from OSM file
    """
    run('imposm -m {tilemill_home}/imposm-mapping.py --connection postgis:///{db} --read --write --optimize --deploy-production-tables --overwrite-cache {tilemill_home}/{osm_file}'.format(db=env.osm_db,
                                                                                                                        tilemill_home=env.tilemill_home,
                                                                                                                        osm_file=env.osm_file))

@task
def tilemill_to_git():
    """Copy project files to the git repository
    """
    run('cp -R /usr/share/mapbox/project/maps-ox /srv/tilemill/maps-tiles/')


@task
def git_to_tilemill():
    """Copy files from the git repo to tilemill
    """
    run('cp -R /srv/tilemill/maps-tiles/maps-ox/ /usr/share/mapbox/project/')