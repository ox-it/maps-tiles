class openstreetmap {

    class { 'postgresql::server': }

    include ::postgis
    
    $db_user = 'tilemill'
    
    postgresql::server::role { $db_user :
          password_hash => false,
    }
    
    postgis::database { 'osm' :
        owner => $db_user,
        charset => 'SQL_ASCII',
        require => Postgresql::Server::Role[$db_user]
    }
    
    package { "osm2pgsql" : ensure => "installed"}
}
