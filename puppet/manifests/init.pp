class wallboards {

        file {"/etc/wallboardurl.conf":
                ensure => file,
                source => "puppet:///modules/wallboards/wallboardurl.conf.$hostname",
                mode => 0775
        }
          file {"/etc/rc.local":
                ensure => file,
                source => "puppet:///modules/wallboards/rc.local",
                owner  => root,
                mode   => 0755
        }


        file {"/usr/local/sbin/restart-browser.sh":
                ensure => file,
                source => "puppet:///modules/wallboards/restart-browser.sh",
                owner  => root,
                mode   => 0755
        }

        $inotify_packages = [
        "inotify-tools",
        ]

        package { $inotify_packages:
             ensure => latest,
        }



}

