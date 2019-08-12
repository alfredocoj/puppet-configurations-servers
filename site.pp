node "10.0.0.95" { # puppetserver

  cron { 'update-manifest':
    command => '/opt/puppetlabs/puppet/bin/r10k deploy environment -pv',
    user    => 'root',
    hour    => '*',
    minute  => '*/1'
  }

  cron { 'run-puppet':
    command =>
      '/opt/puppetlabs/puppet/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes -v >> /tmp/mylogs.txt'
    ,
    user    => 'root',
    hour    => '*',
    minute  => '*/5'
  }

  include logrotate
  logrotate::rule { 'messages':
    path         => '/var/log/messages',
    rotate       => 5,
    rotate_every => 'week',
    postrotate   => '/usr/bin/killall -HUP syslogd',
  }

  logrotate::rule { 'docker-logs':
    path          => '/var/lib/docker/containers/*/*.log',
    rotate        => 7,
    #rotate_every  => 'week',
    #size          => '1M',
    missingok     => true,
    delaycompress => true
    #postrotate    => 'truncate -s 0 /var/lib/docker/containers/*/*-json.lo*',
  }
}

node "10.0.0.96" { # puppetnode

  cron { 'run-puppet':
    command =>
      '/opt/puppetlabs/puppet/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes -v >> /tmp/mylogs.txt'
    ,
    user    => 'root',
    hour    => '*',
    minute  => '*/5'
  }

  include logrotate
  logrotate::rule { 'messages':
    path         => '/var/log/messages',
    rotate       => 5,
    rotate_every => 'week',
    postrotate   => '/usr/bin/killall -HUP syslogd',
  }

  logrotate::rule { 'docker-logs':
    path          => '/var/lib/docker/containers/*/*.log',
    rotate        => 7,
    #rotate_every  => 'week',
    #size          => '1M',
    missingok     => true,
    delaycompress => true
    #postrotate    => 'truncate -s 0 /var/lib/docker/containers/*/*-json.lo*',
  }
}

node "10.0.0.97" { # puppetnode

  cron { 'update-manifest':
    command => '/opt/puppetlabs/puppet/bin/r10k deploy environment -pv',
    user => 'root',
    hour => '*',
    minute => '*/120'
  }

  cron { 'run-puppet':
    command => '/opt/puppetlabs/puppet/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes -v >> /tmp/mylogs.txt',
    user => 'root',
    hour => '*',
    minute => '*/60'
  }

  include logrotate
  logrotate::rule { 'messages':
    path         => '/var/log/messages',
    rotate       => 5,
    rotate_every => 'week',
    postrotate   => '/usr/bin/killall -HUP syslogd',
  }

  logrotate::rule { 'docker-logs':
    path          => '/var/lib/docker/containers/*/*.log',
    rotate        => 7,
    #rotate_every  => 'week',
    #size          => '1M',
    missingok     => true,
    delaycompress => true
    #postrotate    => 'truncate -s 0 /var/lib/docker/containers/*/*-json.lo*',
  }
}

node "10.0.0.17" { # puppetnode
  include apt

  package { 'lsb-release':
    ensure => installed,
  }

  cron { 'update-manifest':
    command => '/opt/puppetlabs/puppet/bin/r10k deploy environment -pv',
    user => 'root',
    hour => '*',
    minute => '*/120'
  }

  cron { 'run-puppet':
    command => '/opt/puppetlabs/puppet/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes -v >> /tmp/mylogs.txt',
    user => 'root',
    hour => '*',
    minute => '*/60'
  }

  include logrotate
  logrotate::rule { 'messages':
    path         => '/var/log/messages',
    rotate       => 5,
    rotate_every => 'week',
    postrotate   => '/usr/bin/killall -HUP syslogd',
  }

  class { 'docker':
    version => '18.06.0~ce~3-0~debian',
  }

  class {'docker::compose':
    ensure => present,
    version => '1.23.2',
  }

  user { 'docker':
    ensure => present,
    password => '!coalizao',
    home => '/home/docker',
    shell => '/bin/bash',
    groups => ['docker'],
    comment => 'Usuario p/ Aplicações Docker',
    managehome => true,
    purge_ssh_keys => true,
    require => Package['docker']
  }

  user { 'k8s-admin':
    ensure => present,
    password => '$6$1si56Qe5IiOS$MnF0HcvNDcktSbY5XSCHo3Lu9jrHVbgOE77F4reoGFzjBIkNbMrJaJc22v8xOD03YnyrmFulLDDsDPwhuOJwM/', ## !coalizao
    home => '/home/k8s-admin',
    shell => '/bin/bash',
    groups => ['docker','root'],
    comment => 'Usuario p/ k8s',
    managehome => true,
    purge_ssh_keys => true
  }

  ssh_authorized_key { 'user1@pc1':
    ensure => present,
    user => 'k8s-admin',
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQChoDwPqY5QojG11NV3gtyJsvqvCQubT2CpsRoWToI8E80TV/OES2xaFvqNTONvym6G0VMmcgXTiZ/O5G4c4LKVgYaF+cEYgsyTm0yjo71gVEjZZHLm32xiE3lV9Q/+I9CC5yJhJVkn/WmmcQF+KRCsjljBH8RRUGSzirvhcNy8drVQCHFtz0/tLWuUvmoiB4MDNUO3nBeJGR3mDxzztRPxFe6P4FgXb+OQT8QS1KL3v3K4jOwYXlbo0Ca9aczdpEriG16Iyh2gx0OQ7dhCQGkJSg7M2IKo1PaXhnouuAx5UMWEnS25BtrP9a0mlnyvLfA5/nOvU6gRu58vzS97iKKK',
    require => User['k8s-admin']
  }

  logrotate::rule { 'docker-logs':
    path          => '/var/lib/docker/containers/*/*.log',
    rotate        => 7,
    #rotate_every  => 'week',
    #size          => '1M',
    missingok     => true,
    delaycompress => true
    #postrotate    => 'truncate -s 0 /var/lib/docker/containers/*/*-json.lo*',
  }
}

node "10.0.0.131" { # puppetnode
  include apt

  package { 'lsb-release':
    ensure => installed,
  }

  cron { 'update-manifest':
    command => '/opt/puppetlabs/puppet/bin/r10k deploy environment -pv',
    user => 'root',
    hour => '*',
    minute => '*/120'
  }

  cron { 'run-puppet':
    command => '/opt/puppetlabs/puppet/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes -v >> /tmp/mylogs.txt',
    user => 'root',
    hour => '*',
    minute => '*/60'
  }

  include logrotate
  logrotate::rule { 'messages':
    path         => '/var/log/messages',
    rotate       => 5,
    rotate_every => 'week',
    postrotate   => '/usr/bin/killall -HUP syslogd',
  }

  class { 'docker':
    version => '18.06.0~ce~3-0~debian',
  }

  class {'docker::compose':
    ensure => present,
    version => '1.23.2',
  }

  user { 'docker':
    ensure => present,
    password => '!coalizao',
    home => '/home/docker',
    shell => '/bin/bash',
    groups => ['docker'],
    comment => 'Usuario p/ Aplicações Docker',
    managehome => true,
    purge_ssh_keys => true,
    require => Package['docker']
  }

  user { 'k8s-admin':
    ensure => present,
    password => '$6$1si56Qe5IiOS$MnF0HcvNDcktSbY5XSCHo3Lu9jrHVbgOE77F4reoGFzjBIkNbMrJaJc22v8xOD03YnyrmFulLDDsDPwhuOJwM/', ## !coalizao
    home => '/home/k8s-admin',
    shell => '/bin/bash',
    groups => ['docker','root'],
    comment => 'Usuario p/ k8s',
    managehome => true,
    purge_ssh_keys => true
  }

  ssh_authorized_key { 'user1@pc1':
    ensure => present,
    user => 'k8s-admin',
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQChoDwPqY5QojG11NV3gtyJsvqvCQubT2CpsRoWToI8E80TV/OES2xaFvqNTONvym6G0VMmcgXTiZ/O5G4c4LKVgYaF+cEYgsyTm0yjo71gVEjZZHLm32xiE3lV9Q/+I9CC5yJhJVkn/WmmcQF+KRCsjljBH8RRUGSzirvhcNy8drVQCHFtz0/tLWuUvmoiB4MDNUO3nBeJGR3mDxzztRPxFe6P4FgXb+OQT8QS1KL3v3K4jOwYXlbo0Ca9aczdpEriG16Iyh2gx0OQ7dhCQGkJSg7M2IKo1PaXhnouuAx5UMWEnS25BtrP9a0mlnyvLfA5/nOvU6gRu58vzS97iKKK',
    require => User['k8s-admin']
  }

  ssh_authorized_key { 'user2@pc2':
    ensure => present,
    user => 'k8s-admin',
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDHGnNLBAugD8nuIzvWildmXHruq0ldwqQo7PpdPUeVnI6VKzOT4jgMhT4FJp+7OHF8g9zB1i3WRHPLYrxyVN5S63m7W5ROL9tEHdWAGNfeHowi+Z+ySLR0J57t5Gu7uQG3X7fIgWPXAM4xju0I5CnwcRum64yi9YCMM0qp4c81++G9SJz7c/3rXLUg01TOR5GNVhHPKc5BXa08P4VvkV4JLFckH8zsDr+pq1EhVa49Ms7qK0pnJzzz4dd31kt+wzcLyd1nbfm0yrcaoXY9bXATuGKgimo/Q8pbLo//5Xm2UBRvzQJocRQ5pfKnxeroqTdfG95OmomGv+HgshsKKK',
    require => User['k8s-admin']
  }

  ssh_authorized_key { 'user3@pc3':
    ensure => present,
    user => 'k8s-admin',
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDKRK5HF0urnOvCTATE6czpWaqS7HmL6ux6bKvyXTy0YCB09Yhsz5b7L8Qf+DO3Rkn70WT4Ddlltc3omrGa9sf+StIF67QFNz7fHp8ngWFyIRcPZDAMq7ZhlvCqG6cUX3bayKgdT7H7+0sOhmZSDoOr6EBf3ouugcXLVkWhCmIeq2CSqq6Iv+pncAk5xTJU5sRnxw3urzyYaF8nAE1425cnDTYZTKWmq0s9q5taZ9SEEkfeGS/jJdWMKoLzhsoBC6cMEfcxUz8CObgivCm7xMyeEHeovoJQlTvyDtpLfh1sj0Xw05FSQm6JhE/nNqKYQivFYflyyS2vaU93ffcATBBB',
    require => User['k8s-admin']
  }

  logrotate::rule { 'docker-logs':
    path          => '/var/lib/docker/containers/*/*.log',
    rotate        => 7,
    #rotate_every  => 'week',
    #size          => '1M',
    missingok     => true,
    delaycompress => true
    #postrotate    => 'truncate -s 0 /var/lib/docker/containers/*/*-json.lo*',
  }
}

node "10.0.0.152" { # puppetnode


  cron { 'update-manifest':
    command => '/opt/puppetlabs/puppet/bin/r10k deploy environment -pv',
    user => 'root',
    hour => '*',
    minute => '*/120'
  }

  cron { 'run-puppet':
    command => '/opt/puppetlabs/puppet/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes -v >> /tmp/mylogs.txt',
    user => 'root',
    hour => '*',
    minute => '*/240'
  }

  class { 'docker':
    version => '17.09.0~ce-0~debian',
  }

  class {'docker::compose':
    ensure => present,
    version => '1.9.0',
  }


  user { 'docker':
    ensure => present,
    password => '!coalizao',
    home => '/home/docker',
    shell => '/bin/bash',
    groups => ['docker','lp'],
    comment => 'Usuario p/ Aplicações Docker',
    managehome => true,
    purge_ssh_keys => true,
    require => Package['docker'],
    #weak_ssl         => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88'
  }

  docker::image { 'portainer/agent':
    image_tag => 'latest'
  }

  docker::run { 'portainer_agent':
    image            => 'portainer/agent:latest',
    ensure           => present,
    privileged       => true,
    pull_on_start    => false,
    ports            => ['9001'],
    expose           => ['9001:9001'],
    volumes          => ['/var/run/docker.sock:/var/run/docker.sock', '/var/lib/docker/volumes:/var/lib/docker.volumes'],
    restart_service  => true,
    restart          => 'always'
  }

}

node "10.0.0.128" { # puppetserver - services


  cron { 'update-manifest':
    command => '/opt/puppetlabs/puppet/bin/r10k deploy environment -pv',
    user => 'root',
    hour => '*',
    minute => '*/120'
  }

  cron { 'run-puppet':
    command => '/opt/puppetlabs/puppet/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes -v >> /tmp/mylogs.txt',
    user => 'root',
    hour => '*',
    minute => '*/240'
  }

  class { 'docker':
    version => '18.06.0~ce~3-0~debian',
  }

  class {'docker::compose':
    ensure => present,
    version => '1.23.2',
  }

  user { 'docker':
    ensure => present,
    password => 'ODFmZTk4',
    home => '/home/docker',
    shell => '/bin/bash',
    groups => ['docker'],
    comment => 'Usuario p/ Aplicações Docker',
    managehome => true,
    purge_ssh_keys => true,
    require => Package['docker'],
  }

  user { 'k8s-admin':
    ensure => present,
    password => '!coalizao',
    home => '/home/k8s-admin',
    shell => '/bin/bash',
    groups => ['docker'],
    comment => 'Usuario p/ Aplicações Docker',
    managehome => true,
    purge_ssh_keys => true,
    require => Package['docker'],
  }

  include logrotate
  logrotate::rule { 'messages':
    path         => '/var/log/messages',
    rotate       => 5,
    rotate_every => 'week',
    postrotate   => '/usr/bin/killall -HUP syslogd',
  }

  logrotate::rule { 'docker-logs':
    path          => '/var/lib/docker/containers/*/*.log',
    rotate        => 7,
    rotate_every  => 'week',
    #size          => '1M',
    missingok     => true,
    delaycompress => true
    #,
    #postrotate    => 'truncate -s 0 /var/lib/docker/containers/*/*-json.lo*',
  }


  /*tomcat::install { '/opt/tomcat':
    source_url => 'https://www.apache.org/dist/tomcat/tomcat-9/v9.0.20/bin/apache-tomcat-9.0.20.tar.gz',
  }

  tomcat::instance { 'default':
    catalina_home    => '/opt/tomcat',
  }*/

  class { 'zabbix::agent':
    zabbix_version       => '3.4',
    manage_repo          => true,
    zabbix_package_state => 'latest',
    server => '10.0.0.211',
  }

}

node "10.0.0.126" { # puppetnode - banco de dados maxipos


  cron { 'update-manifest':
    command => '/opt/puppetlabs/puppet/bin/r10k deploy environment -pv',
    user => 'root',
    hour => '*',
    minute => '*/120'
  }

  cron { 'run-puppet':
    command => '/opt/puppetlabs/puppet/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes -v >> /tmp/mylogs.txt',
    user => 'root',
    hour => '*',
    minute => '*/240'
  }

  /*class { 'postgresql::globals':
    encoding            => 'UTF-8',
    locale              => 'en_US.UTF-8',
    manage_package_repo => true,
    version             => '11.4',
  }

  class { 'postgresql::server':
    postgres_password          => 'YWNiZjM1',
  }

  postgresql::server::db { 'maxipos':
    user     => 'maxipos',
    password => postgresql_password('maxipos', 'MjYxMzJk'),
  }

  postgresql::server::role { 'admin':
    password_hash     => postgresql_password('admin', 'YWNiZjM1'),
    superuser         => true,
  }

  postgresql::server::database_grant { 'maxipos':
    privilege => 'ALL',
    db        => 'maxipos',
    role      => 'admin',
  }*/

  class { 'zabbix::agent':
    zabbix_version       => '3.4',
    manage_repo          => true,
    zabbix_package_state => 'latest',
    server => '10.0.0.211', ## registry images docker
  }
}

node "10.0.0.127" { # puppetnode - banco de dados


  cron { 'update-manifest':
    command => '/opt/puppetlabs/puppet/bin/r10k deploy environment -pv',
    user => 'root',
    hour => '*',
    minute => '*/120'
  }

  cron { 'run-puppet':
    command => '/opt/puppetlabs/puppet/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes -v >> /tmp/mylogs.txt',
    user => 'root',
    hour => '*',
    minute => '*/240'
  }

  /*class { 'postgresql::globals':
    encoding            => 'UTF-8',
    locale              => 'en_US.UTF-8',
    manage_package_repo => true,
    version             => '11.4',
  }

  class { 'postgresql::server':
    postgres_password          => 'YWNiZjM2',
  }

  postgresql::server::role { 'admin':
    password_hash     => postgresql_password('admin', 'teste123'),
    superuser         => true,
  }*/

  class { 'zabbix::agent':
    zabbix_version       => '3.4',
    manage_repo          => true,
    zabbix_package_state => 'latest',
    server => '10.0.0.211',
  }
}

node "10.0.0.9" { # puppetserver


  cron { 'update-manifest':
    command => '/opt/puppetlabs/puppet/bin/r10k deploy environment -pv',
    user => 'root',
    hour => '*',
    minute => '*/120'
  }

  cron { 'run-puppet':
    command => '/opt/puppetlabs/puppet/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes -v >> /tmp/mylogs.txt',
    user => 'root',
    hour => '*',
    minute => '*/240'
  }

  class { 'docker':
    version => '17.09.0~ce-0~debian',
  }

  class {'docker::compose':
    ensure => present,
    version => '1.9.0',
  }


  user { 'docker':
    ensure => present,
    password => 'gm123',
    home => '/home/docker',
    shell => '/bin/bash',
    groups => ['docker','lp'],
    comment => 'Usuario p/ Aplicações Docker',
    managehome => true,
    purge_ssh_keys => true,
    require => Package['docker'],
    #weak_ssl         => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88'
  }

  file { '/home/docker/postgres/docker-compose.yml':
    ensure =>  file,
    content => "
version: '3'

services:
  postgres:
    #image: postgres:9.6
    build:
      context: .
    environment:
      POSTGRES_PASSWORD: 'ithappens'
    ports:
      - '15432:5432'
    volumes:
      - /home/alfredo/postgres/data:/var/lib/postgresql/data

  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: 'admin@admin'
      PGADMIN_DEFAULT_PASSWORD: 'ithappens'
    ports:
      - '16543:80'
    depends_on:
      - postgres"
  }

  docker_compose { 'postgres':
    compose_files => ['/home/docker/postgres/docker-compose.yml'],
    ensure  => present,
  }


  tomcat::install { '/opt/tomcat':
    source_url => 'https://www.apache.org/dist/tomcat/tomcat-9/v9.0.20/bin/apache-tomcat-9.0.20.tar.gz',
  }

  tomcat::instance { 'default':
    catalina_home    => '/opt/tomcat',
  }

}
