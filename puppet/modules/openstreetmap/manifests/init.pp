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
    
    $db_user = 'tilemill'
    
    postgresql::server::role { $db_user :
          password_hash => false,
          require => Exec['utf8 postgres']
    }
    
    postgis::database { 'osm' :
        owner => $db_user,
        charset => 'UTF8',
        require => Postgresql::Server::Role[$db_user]
    }
    
    package { "osm2pgsql" : ensure => "installed"}
}
