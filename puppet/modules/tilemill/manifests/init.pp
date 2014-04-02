class tilemill {
    include apt

    $user = 'tilemill'
    $user_directory = "/srv/${user}"
    $maps_project_dir = "${user_directory}/maps-tiles"
    $git_repo = 'https://github.com/ox-it/maps-tiles.git'
    $mapbox_project = '/usr/share/mapbox/project/maps-ox'

    exec { "add-apt" :
      command => "/usr/bin/add-apt-repository -y ppa:developmentseed/mapbox && /usr/bin/apt-get update",
      subscribe => Package["python-software-properties"]
    }

    package { "libmapnik" : ensure => "installed", subscribe => Exec['add-apt'] }
    package { "tilemill" : ensure => "latest", subscribe => Exec['add-apt'] }
    package { "nodejs" : ensure => "latest", subscribe => Exec['add-apt'] }

    # installing a few fonts
    package { ["fonts-cantarell", "lmodern", "ttf-aenigma", "ttf-georgewilliams", "ttf-bitstream-vera", "ttf-sjfonts", "ttf-tuffy", "tv-fonts", "ubuntustudio-font-meta"] :
        ensure => installed
    }

	user { $user :
		home => $user_directory,
		ensure => present,
		shell => "/bin/bash",
	}

	file { $user_directory :
		ensure 	=> directory,
		owner 	=> $user,
		group 	=> $user,
		mode => 775,
		require => User[$user]
	}

    file { "tilemill.init" :
        path => "/etc/init/tilemill.conf",
        content => template("tilemill/tilemill-init.erb"),
        require => Package['tilemill'],
    }

    file { "tilemill.config" :
        path => "/etc/tilemill/tilemill.config",
        content => template("tilemill/tilemill-config.erb"),
        require => Package['tilemill'],
    }

    service { "tilemill" :
        provider => "upstart",
        ensure => "running",
        enable => true,
        require => File["tilemill.config"],
    }
    
    exec { "git-clone-project" :
        command => "git clone ${git_repo} ${maps_project_dir}",
        user => 'tilemill',
        unless => "test -d ${maps_project_dir}",
        require => [File[$user_directory], Package['git']]
    }
    
    # make sure the git repo can be shared between different users
    exec { "git-share-repo" :
        command => "git config core.sharedRepository true",
        user => 'tilemill',
        cwd => $maps_project_dir,
        require => Exec["git-clone-project"]
    }
    
    file {$maps_project_dir :
        group => 'tilemill',
        mode => 'g+swX',
        recurse => true,
        require => Exec['git-clone-project'],
    }
    
    file { '/usr/share/mapbox/project/maps-ox' :
        ensure => directory,
        mode => 0764,
        recurse => true,
        require => Service['tilemill']
    }
    
    exec { "copy-to-mapbox" :
        command => "cp -R ${maps_project_dir}/maps-ox/ /usr/share/mapbox/project/maps-ox",
        user => 'mapbox',
        unless => "test -d /usr/share/mapbox/project/maps-ox",
        require => [Service['tilemill'], Exec['git-clone-project']]
    }

    file { "${user_directory}/mapbox" :
        ensure => directory,
        owner => tilemill,
        group => mapbox,
        mode => 0774,
        recurse => true,
        require => [File[$user_directory], Service['tilemill']]
    }

    # download a file (HTTP download)
    define download($url = $title, $file, $user = 'tilemill', $group = 'mapbox', $mode = 0774) {
          exec { "copy-${title}" :
              command => "curl ${url} > ${file}",
              user => $user,
              unless => "test -f ${file}",
          }
          file { $file :
              owner => $user,
              group => $group,
              mode => $mode,
              require => Exec["copy-${title}"]
          }
    }

    download { "http://mapbox-geodata.s3.amazonaws.com/natural-earth-1.3.0/physical/10m-land.zip" :
        file => "${user_directory}/mapbox/10m-land.zip",
        require => File["${user_directory}/mapbox"]
    }

    download { "http://tilemill-data.s3.amazonaws.com/osm/coastline-good.zip" :
        file => "${user_directory}/mapbox/coastline-good.zip",
        require => File["${user_directory}/mapbox"]
    }
    
    download { "http://tilemill-data.s3.amazonaws.com/osm/shoreline_300.zip" :
        file => "${user_directory}/mapbox/shoreline_300.zip",
        require => File["${user_directory}/mapbox"]
    }

}