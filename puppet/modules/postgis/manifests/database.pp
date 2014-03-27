# ==Definition: postgis::database
#
# Create a new PostgreSQL PostGIS database
#
define postgis::database(
  $owner   = false,
  $charset = false,
) {

  postgresql::server::database{$name:
    owner    => $owner,
    encoding => $charset,
    template => 'template_postgis',
    # TODO fixed external dependency temporarily
    # as "create postgis_template" is not a valid target??
    #require  => Exec['create postgis_template'],
    require => Postgresql::Server::Database['template_postgis'],
  }

}
