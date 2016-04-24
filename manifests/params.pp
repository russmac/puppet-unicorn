class unicorn::params {

  $unicorn_dependencies=['ruby-dev']
  $unicorn_gem_dependencies=['rack']
  $user=unicorn
  $worker_processes=3
  $backlog=100
  $timeout=32

}