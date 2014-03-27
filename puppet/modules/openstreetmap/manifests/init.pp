class openstreetmap {

    class { 'postgresql::server': }

    include ::postgis
    
    postgis::database { 'osm' :
        owner => 'tilemill',
        require => User['tilemill']
    }
}
