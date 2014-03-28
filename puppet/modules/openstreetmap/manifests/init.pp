class openstreetmap {

    class { 'postgresql::globals' :
      encoding => 'UTF8',
      locale   => 'en_GB.UTF-8',
    }->
    class { 'postgresql::server' :
        encoding => 'UTF8'
    }->
    # workaround for http://projects.puppetlabs.com/issues/4695
    # when PostgreSQL is installed with SQL_ASCII encoding instead of UTF8
    exec { 'utf8 postgres' :
      command => 'pg_dropcluster --stop 9.1 main ; pg_createcluster --start --locale en_GB.UTF-8 9.1 main',
      unless  => 'sudo -u postgres psql -t -c "\l" | grep template1 | grep -q UTF',
      require => Class['postgresql::server'],
      path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    }
    
    include ::postgis
    
    $db_user = 'mapbox'
    $db_name = 'osm'
    
    postgresql::server::role { $db_user :
          password_hash => false,
          require => Exec['utf8 postgres']
    }
    
    postgis::database { $db_name :
        owner => $db_user,
        charset => 'UTF8',
        require => Postgresql::Server::Role[$db_user]
    }
    
    postgresql::server::database_grant { 'mapbox_osm':
        privilege => 'ALL',
        db        => $db_name,
        role      => $db_user,
        require => Postgis::Database[$db_name]
    }
    
    postgresql::server::table_grant { 'osm_spatial_ref_sys':
        privilege => 'ALL',
        db        => $db_name,
        table     => 'spatial_ref_sys',
        role      => $db_user,
        require => Postgresql::Server::Database_grant['mapbox_osm']
    }
    
    postgresql::server::table_grant { 'osm_geography_columns':
        privilege => 'ALL',
        db        => $db_name,
        table     => 'geography_columns',
        role      => $db_user,
        require => Postgresql::Server::Database_grant['mapbox_osm']
    }
    
    postgresql::server::table_grant { 'osm_geometry_columns':
        privilege => 'ALL',
        db        => $db_name,
        table     => 'geometry_columns',
        role      => $db_user,
        require => Postgresql::Server::Database_grant['mapbox_osm']
    }
    
    package { "imposm" : ensure => "installed"}

    file { "imposm-mapping" :
        path => "/srv/tilemill/imposm-mapping.py",
        content => template("openstreetmap/imposm-mapping.py"),
        require => User['tilemill'],
    }
}
