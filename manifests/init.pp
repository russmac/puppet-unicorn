class unicorn(
) inherits unicorn::params {

  package{$unicorn_dependencies:
    ensure => present,
  }

  package{$unicorn_gem_dependencies:
    ensure   => present,
    provider => gem,
  }

  package{'unicorn':
    ensure   => present,
    provider => gem,
    require  => [Package[$unicorn_dependencies],Package[$unicorn_gem_dependencies]]
  }

  file{'/var/log/unicorn':
    ensure => directory,
    mode   => 777,
  }

}