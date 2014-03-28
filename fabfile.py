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
def init():
    """Initialise permissions for user
    """
    run('sudo adduser {user} tilemill'.format(user=env.user), warn_only=True)
    sudo('createuser {user} -S -R -D -l'.format(user=env.user), user='postgres', warn_only=True)
    sudo('psql -c "GRANT ALL ON DATABASE {db} TO {user};"'.format(user=env.user, db=env.osm_db), user='postgres', warn_only=True)

@task
def server():
     """Configuration for remote server
     """
     pass
     
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


