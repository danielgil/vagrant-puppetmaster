

    file {"/etc/puppet/puppet.conf":
        ensure      => file,
        owner       => 'root',
        group       => 'root',
        mode        => '644',
        content     => template('/vagrant/puppet/templates/puppet.conf.erb'),
        
    }

    file {"/etc/httpd/conf.d/dashboard-vhost.conf":
        ensure      => file,
        owner       => 'root',
        group       => 'root',
        mode        => '644',
        content     => template('/vagrant/puppet/templates/dashboard-vhost.conf.erb'),
    }

    file {"/etc/httpd/conf.d":
        ensure      =>  directory,
        owner       => 'root',
        group       => 'root',
        mode        => '644',
        recurse     => true,
        purge       => true,
        require     => Package['httpd'],
    }

    file {"/usr/share/puppet-dashboard/config/database.yml":
        ensure      => file,
        owner       => 'puppet-dashboard',
        group       => 'puppet-dashboard',
        mode        => '640',
        content     => template('/vagrant/puppet/templates/database.yml.erb'),
        require     => Package['puppet-dashboard'],
    }

    service { 'puppet':
        ensure      => running,
        enable      => true,
        subscribe   => File['/etc/puppet/puppet.conf'],
    }

    service { 'puppetmaster':
        ensure      => running,
        enable      => true,
        subscribe   => File['/etc/puppet/puppet.conf'],
    }

    service { 'httpd':
        ensure      => running,
        enable      => true,
        subscribe   => File['/etc/httpd/conf.d/dashboard-vhost.conf'],
        require     => [Package['puppet-dashboard', 'mod_passenger'], Exec['generate-dashboard-ssl-cert']],
    }

    service { 'mysqld':
        ensure      => running,
        enable      => true,
        require     => Package['mysql-server'],
    }

    service { 'puppet-dashboard-workers':
        ensure      => running,
        enable      => true,
        require     => Service['httpd', 'mysqld', 'puppetmaster'],
    }

    package {['httpd','mod_passenger', 'mod_ssl', 'puppet-dashboard', 'mysql-server']:
        ensure      => installed,
    }


    exec {'generate-dashboard-ssl-key':
        command     => "openssl req -nodes -newkey rsa:2048 -keyout /usr/share/puppet-dashboard/certs/dashboard.key -out /usr/share/puppet-dashboard/certs/dashboard.csr -subj \"/CN=$fqdn\"",
        path        => '/bin:/usr/bin', 
        creates     => "/usr/share/puppet-dashboard/certs/dashboard.key",
        require     => Package['puppet-dashboard'],
    }

    exec {'generate-dashboard-ssl-cert':
        command     => "openssl x509 -req -days 3650 -in /usr/share/puppet-dashboard/certs/dashboard.csr -signkey /usr/share/puppet-dashboard/certs/dashboard.key -out /usr/share/puppet-dashboard/certs/dashboard.crt",
        path        => '/bin:/usr/bin',
        creates     => "/usr/share/puppet-dashboard/certs/dashboard.crt",
        require     => Exec['generate-dashboard-ssl-key'],
    }

    exec {'generate-dashboard-passwd':
        command     => "htpasswd -cb /etc/httpd/passwd $dashboarduser $dashboardpassword",
        path        => '/bin:/usr/bin',
        require     => Package['httpd'],
    }

    exec {'rake-tasks':
        command     => "rake gems:refresh_specs; rake RAILS_ENV=production db:migrate",
        path        => '/bin:/usr/bin',
        cwd         => '/usr/share/puppet-dashboard',
        require     => Package['puppet-dashboard','mod_passenger'],
    }

    exec {'set-mysql-root':
        command     => "mysqladmin -u root password $mysqlrootpassword ; mysqladmin -u root -h $fqdn -p$mysqlrootpassword password $mysqlrootpassword",
        path        => '/bin:/usr/bin',
        require     => Service['mysqld'],
    }

    exec {'create-dashboard-db':
        command     => "mysql -u root -p$mysqlrootpassword -e \"create database dashboard character set utf8;CREATE USER 'dashboard'@'localhost' IDENTIFIED BY '$dashboarddbpassword';GRANT ALL PRIVILEGES ON dashboard.* TO 'dashboard'@'localhost';\"",
        path        => '/bin:/usr/bin',
        require     => [Service['mysqld'], Exec['set-mysql-root']],
    }

    exec {'passenger-version':
        command     => "sed -i \"s/@PASSENGERVERSION@/$(passenger-config --version)/\" /etc/httpd/conf.d/dashboard-vhost.conf",
        path        => '/bin:/usr/bin',
        require     => File['/etc/httpd/conf.d/dashboard-vhost.conf'],
    }

