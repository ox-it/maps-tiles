import os
from datetime import datetime

from fabric.api import *
from fabric.contrib import *
from fabric.contrib.files import exists, sed
from fabric import utils
from fabric.operations import put

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

@task
def tiles():
    """Configuration for tiles server
    """
    host = os.getenv('TILES_HOST')      # should be hostname:port
    env.hosts = [host]
    env.user = 'tiles'
    env.home = '/srv/tiles'
    env.deploy_path = '/srv/tiles/www'


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
    # first remove the old dump -- causes permission issues if the file has been created
    # by another user
    run('rm -f {tilemill_home}/{osm_file}'.format(tilemill_home=env.tilemill_home, osm_file=env.osm_file))
    run('curl "{osm_download}" > {tilemill_home}/{osm_file}'.format(osm_download=OSM_DOWNLOAD,
                                                                      tilemill_home=env.tilemill_home,
                                                                      osm_file=env.osm_file))

@task
def populate_osm():
    """Run importer from OSM file
    """
    # we need to temporarily change the owner of tables to the user running the
    # importer (mapbox is the user running TileMill)
    # TODO this is an ugly tradeoff and should probably be improved...
    sudo('psql {db} -c "REASSIGN OWNED BY mapbox TO {user};"'.format(db=env.osm_db, user=env.user), user='postgres')
    run('imposm -m {tilemill_home}/imposm-mapping.py --connection postgis:///{db} --read --write --optimize --deploy-production-tables --overwrite-cache {tilemill_home}/{osm_file}'.format(db=env.osm_db,
                                                                                                                        tilemill_home=env.tilemill_home,
                                                                                                                        osm_file=env.osm_file))
    sudo('psql {db} -c "REASSIGN OWNED BY {user} TO mapbox;"'.format(db=env.osm_db, user=env.user), user='postgres')


@task
def upgrade_osm():
    """Download latest dump and push it to PostGis
    """
    download_osm_oxf()
    populate_osm()


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


# tiles

@task
def deploy_tiles(local_file):
    """Deploy tiles from a file to the web server
    :param local_file: local mbtiles file to push to the server
    """
    remote_file = '/srv/tiles/tiles.mbtiles'
    put(local_path=local_file, remote_path=remote_file)
    versioned_path = '/srv/%s/tiles-%s' % (env.user, datetime.now().strftime('%Y%m%d%H%M'))
    run('mb-util {file} {path}'.format(file=remote_file, path=versioned_path))
    run('rm -f {path}'.format(path=env.deploy_path))
    run('ln -s %s %s' % (versioned_path, env.deploy_path))
