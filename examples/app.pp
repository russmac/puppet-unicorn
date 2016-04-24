# Wrapper class see app.yaml
class wrapper_class(
  $ruby_apps=hiera('ruby_apps')
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
    app_root          => $self['app_root'],
    user              => $self['user'],                   # optional
    rails_env         => $self['rails_env'],              # optional
    bundle            => $self['bundle'],                 # optional
    app_socket        => $self['app_socket'],             # optional
    pid_file          => $self['pid_file'],               # optional
    worker_processes  => $self['worker_processes'],       # optional
    backlog           => $self['backlog'],                # optional
    timeout           => $self['timeout'],                # optional
  }

}
