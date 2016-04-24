require 'spec_helper'

describe 'unicorn::generate' do
  let(:title) { 'rspec_app' }
  let(:params) {
    {
        :app_name => 'rspec_app',
        :app_root => '/opt/rspec_app',
    }
  }

  it { is_expected.to compile }

  it { is_expected.to contain_class('unicorn') }

  it { is_expected.to contain_package('ruby-dev').with_ensure('present') }

  it { is_expected.to contain_file('/etc/init.d/rspec_app').with_content(/--chuid\s\w+\s/) }

  it { is_expected.to contain_file('/opt/rspec_app/config/unicorn.conf.rb').with_content(/stdout_path\s'\/var\/log\/unicorn\/\w+\.log'/) }

end
