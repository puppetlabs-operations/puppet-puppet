require 'spec_helper_acceptance'

describe 'agent', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'with default parameters' do
    it 'should run with no errors' do
      pp = <<-EOS
      class { 'puppet::agent': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end

#  context 'running as service' do
#    it 'should run with no errors' do
#      pp = <<-EOS
#      class { 'puppet::agent':
#       method        => 'service',
#      }
#      EOS

#      # Run it twice and test for idempotency
#      apply_manifest(pp, :catch_failures => true)
#      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
#    end
#
#    describe service('puppet') do
#      it {
#        should be_enabled
#      }
#      it {
#        should be_running
#      }
#    end
#  end
end
