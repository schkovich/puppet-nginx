require 'spec_helper_system'

describe "nginx::resource::vhost define:" do
  context 'should run successfully' do

    pp = "
    class { 'nginx': }
    nginx::resource::vhost { 'www.puppetlabs.com':
      ensure   => present,
      www_root => '/var/www/www.puppetlabs.com',
    }
    "

    context puppet_apply(pp) do
      its(:exit_code) { should_not == 1 }
      its(:refresh) { should be_nil }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end

  describe file('/etc/nginx/conf.d/www.puppetlabs.com.conf') do
   it { should be_file }
   it { should contain "www.puppetlabs.com" }
  end

  context 'with ssl' do

    pp = "
    class { 'nginx': }
    nginx::resource::vhost { 'www.puppetlabs.com':
      ensure   => present,
      ssl      => true,
      ssl_cert => '/tmp/blah.cert',
      ssl_key  => '/tmp/blah.key',
      www_root => '/var/www/www.puppetlabs.com',
    }
    "
    context puppet_apply(pp) do
      its(:exit_code) { should_not == 1 }
      its(:refresh) { should be_nil }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end

    describe file('/etc/nginx/conf.d/www.puppetlabs.com.conf') do
    it { should be_file }
    it { should contain "ssl on;" }
    end
  end

end
