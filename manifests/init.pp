class unicorn(
) inherits unicorn::params {

  package{$unicorn::unicorn_dependencies:
    ensure => present,
  }

  user{'unicorn':
    ensure     => present,
    managehome => false,
    shell      => '/bin/false'
  }

  package{$unicorn::unicorn_gem_dependencies:
    ensure   => present,
    provider => gem,
  }

  package{'unicorn':
    ensure   => present,
    provider => gem,
    require  => [Package[$unicorn::unicorn_dependencies],
                Package[$unicorn::unicorn_gem_dependencies]
                ]
  }

  file{'/var/log/unicorn':
    ensure => directory,
    mode   => '0777',
  }

}