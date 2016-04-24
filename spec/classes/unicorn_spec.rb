require 'spec_helper'

describe 'unicorn' do
    it { is_expected.to compile }
    it { is_expected.to contain_class('unicorn') }
end