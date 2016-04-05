define unicorn::generate(
  $app_name=$name,
  $app_root,
  $worker_processes,
  $app_socket,
  $backlog,
  $timeout,
  $pid_file,
  $bundle=false,
  $rails_env=false,
  $user=false,
) {
  require unicorn


  if $bundle == true {

    package{"bundler":
    } ->
    exec{'echo \'gem "unicorn"\' >> Gemfile':
      cwd => $app_root,
      unless => 'grep \'gem "unicorn"\' Gemfile'
    } ->
    exec{'bundle install && cp -f Gemfile Gemfile.compare':
      cwd    => $app_root,
      unless => 'diff Gemfile Gemfile.compare'
    }

    file{ "/etc/init.d/${app_name}":
      content => template('unicorn/etc/init.d/unicorn_bundler.init.erb'),
      mode    => 744,
      notify => Service[$app_name],
    }

  } else {

    file{ "/etc/init.d/${app_name}":
      content => template('unicorn/etc/init.d/unicorn.init.erb'),
      mode    => 744,
      notify => Service[$app_name],
    }

  }

  file{"${app_root}/config":
    ensure => directory,
  } ->
  file{"${app_root}/config/unicorn.conf.rb":
    content => template('unicorn/config/unicorn.conf.rb.erb'),
    mode    => 644,
  }

}
