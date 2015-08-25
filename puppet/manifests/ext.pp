class wallboards::ext {

file {"/etc/chromium/default":
                ensure => file,
                source => "puppet:///modules/wallboards/chromium-ext",
                owner  => root,
                mode   => 0755
        }
}

