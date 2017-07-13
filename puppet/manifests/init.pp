class wallboards {

        file {"/etc/wallboardurl.conf":
                ensure => file,
                source => "puppet:///modules/wallboards/wallboardurl.conf.$hostname",
                mode => 0775
        }

        file {"/usr/local/sbin/restart-browser.sh":
                ensure => file,
                source => "puppet:///modules/wallboards/restart-browser.sh",
                owner  => root,
                mode   => 0755
        }
service { 'ssh':
        ensure => 'running',
}
service { 'lightdm':
        ensure => 'running',
}


$wallboard_packages = [
  "inotify-tools","chromium-browser","x11-xserver-utils","xwit","sqlite3","libnss3","unclutter", "puppet","openjdk-7-jdk","icedtea-7-plugin",
  ]

  package { $wallboard_packages:
    ensure => latest,
  }

file {"/etc/systemd/system/restart-browser.service":
        ensure => file,
        source => "puppet:///modules/wallboards/restart-browser.service",
        owner  => root,
        mode   => "0755"
}
file {"/usr/local/sbin/restart-browser.sh":
        ensure => file,
        source => "puppet:///modules/wallboards/$restartfile",
        owner  => root,
        mode   => "0755"
}
service { 'restart-browser':
        ensure => 'running',
}
file {"/etc/xdg/lxsession/LXDE-pi/autostart":
        ensure => file,
        source => "puppet:///modules/wallboards/autostart",
        owner  => root,
        mode   => "0644"
}
  file {"/usr/local/sbin/launchbrowser.sh":
    ensure => file,
    source => "puppet:///modules/wallboards/launchbrowser.sh",
    owner  => root,
    mode   => "0755"
  }
  file {"/usr/local/sbin/tvon.sh":
    ensure => file,
    source => "puppet:///modules/wallboards/tvon.sh",
    owner  => root,
    mode   => "0755"
  }
  file {"/usr/local/sbin/tvoff.sh":
    ensure => file,
    source => "puppet:///modules/wallboards/tvoff.sh",
    owner  => root,
    mode   => "0755"
  }
cron {'tvoff':
        command => '/usr/local/sbin/tvoff.sh',
        user => root,
        hour => [17],
        minute => '30'
}
cron {'tvon':
        command => '/usr/local/sbin/tvon.sh',
        user => root,
        hour => [8],
        minute => '00'
}





}

