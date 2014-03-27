import os
from datetime import datetime

from fabric.api import *
from fabric.contrib import *
from fabric.contrib.files import exists, sed
from fabric import utils

# environments

@task
def vm():
    """Configuration for Vagrant VMs (provisioned w/ Puppet)
    """
    env.user = 'vagrant'
    env.hosts = ['127.0.0.1:2222']
    result = local('vagrant ssh-config | grep IdentityFile', capture=True)
    env.key_filename = result.split()[1]

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
    remote('curl http://download.geofabrik.de/europe/great-britain/england/oxfordshire-latest.osm.pbf > oxfordshire-latest.osm.pbf')
    
@task
def populate_osm():
    """Run importer from OSM file
    """
    pass
    
