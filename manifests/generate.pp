# Creates daemonized Unicorn service
define unicorn::generate(
  $app_root,
  $app_name=$name,
  $bundle=false,
  $rails_env=false,
  $app_socket="${app_root}/tmp/${app_name}.socket",
  $pid_file="${app_root}/tmp/${app_name}.pid",
  $user=$unicorn::params::user,
  $group='unicorn',
  $worker_processes=$unicorn::params::worker_processes,
  $backlog=$unicorn::params::backlog,
  $timeout=$unicorn::params::timeout,
) {
  require unicorn

  # Create the user, Make part of the wider unicorn group
  if ! defined(User[$user]){
    user{ $user:
      ensure     => present,
      groups     => $group,
      managehome => false,
      shell      => '/bin/false'
    }
  }

  # bundler app
  if $bundle == true {
    package{'bundler':
    } ->
    exec{'echo \'gem "unicorn"\' >> Gemfile':
      cwd    => $app_root,
      unless => 'grep \'gem "unicorn"\' Gemfile'
    } ->
    exec{'bundle install && cp -f Gemfile Gemfile.compare':
      cwd    => $app_root,
      unless => 'diff Gemfile Gemfile.compare'
    }
    file{ "/etc/init.d/${app_name}":
      ensure  => present,
      content => template('unicorn/etc/init.d/unicorn_bundler.init.erb'),
      mode    => '0744',
      notify  => Service[$app_name],
    } ~>
    exec{"PUP-5972 workaround ${app_name}":
      command     => "/bin/systemctl enable ${app_name}",
      refreshonly => true
    } ~>
    service{$app_name:
      ensure => running,
      enable => true,
    }

  # Non bundler app
  } else {
    file{ "/etc/init.d/${app_name}":
      content => template('unicorn/etc/init.d/unicorn.init.erb'),
      mode    => '0744',
      notify  => Service[$app_name],
    }
  }

  file{"${app_root}/tmp":
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  } ->
  file{"${app_root}/config":
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  } ->
  file{"${app_root}/config/unicorn.conf.rb":
    ensure  => present,
    content => template('unicorn/config/unicorn.conf.rb.erb'),
    mode    => '0644',
  } ~>
  exec{"PUP-5972 workaround ${app_name}":
    command     => "/bin/systemctl enable ${app_name}",
    refreshonly => true
  } ~>
  service{$app_name:
    ensure => running,
    enable => true,
  }

}
