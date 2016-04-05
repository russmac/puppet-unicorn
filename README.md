# puppet-unicorn

Creates a deamonized init script which is just original unicorn script modified and templated.

Works on debian jessie 8.3 with systemd

Could be useful to quickly spin up ruby apps for CI by wrappering with a define
```
# The hiera data
ruby_apps:
  my_application:
    user: steve
    rails_env: proddev
    bundle: true
    app_root: /opt/my_application
    app_socket: /opt/my_application/tmp/my_application.socket
    pid_file: /opt/my_application/tmp/my_application.pid
    worker_processes: 10
    backlog: 24
    timeout: 30
  my_other_application:
    user: steve
    rails_env: proddev
    bundle: true
    app_root: /opt/my_other_application
    app_socket: /opt/my_other_application/tmp/my_other_application.socket
    pid_file: /opt/my_other_application/tmp/my_other_application.pid
    worker_processes: 10
    backlog: 24
    timeout: 30



# Wrapper class
class wrapper_class(
  $ruby_apps=hiera(ruby_apps)
){

  $ruby_apps_keys=keys($ruby_apps)

  wrapper_define::generate{$ruby_apps_keys:
    app_data => $ruby_apps
  }

}

# wrapper define
define wrapper_define(
  $app_data,
  $self=$app_data[$name]
){

  unicorn::generate{ $name:
    user              => $self['user'],
    log_group         => $self['log_group'],
    rails_env         => $self['rails_env'],              # optional
    bundle            => $self['bundle'],                 # optional
    app_root          => $self['app_root'],
    app_socket        => $self['app_socket'],
    pid_file          => $self['pid_file'],
    worker_processes  => $self['worker_processes'],
    backlog           => $self['backlog'],
    timeout           => $self['timeout'],
  }

}

```


##Simple Usage
```
unicorn::generate{  $app_name:
    user              => $user,
    log_group         => 'puppet',
    rails_env         => $rails_env,              # optional
    bundle            => true,                    # optional
    app_root          => $app_root,
    app_socket        => $app_socket,
    pid_file          => $pid_file,
    worker_processes  => $worker_processes,
    backlog           => $backlog,
    timeout           => $timeout,
  }
```
  
Replace paramteres to suit.

Set your nginx resource to requires on this to make sure it picks up the socket

Due to puppet bug https://tickets.puppetlabs.com/browse/PUP-5972 you will need to help puppet along by enabling service first if you want services running after one run.

  ```
  // Notify from some template changed during installation
  exec{"PUP-5972 workaround $app_name":
    command     => "systemctl enable $app_name",
    refreshonly => true
    require     => Unicorn::Generate[$app_name]
  } ->
  service{$app_name:
    ensure   => running,
    enable   => true,
    require  => Unicorn::Generate[$app_name]
  }
```
