describe 'apache::mod::worker', :type => :class do
  let :pre_condition do
    'class { "apache": mpm_module => false, }'
  end
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
      }
    end
    it { should contain_class("apache::params") }
    it { should_not contain_apache__mod('worker') }
    it { should contain_file("/etc/apache2/mods-available/worker.conf").with_ensure('file') }
    it { should contain_file("/etc/apache2/mods-enabled/worker.conf").with_ensure('link') }

    context "with Apache version < 2.4" do
      let :params do
        {
          :apache_version => '2.2',
        }
      end

      it { should_not contain_file("/etc/apache2/mods-available/worker.load") }
      it { should_not contain_file("/etc/apache2/mods-enabled/worker.load") }

      it { should contain_package("apache2-mpm-worker") }
    end

    context "with Apache version >= 2.4" do
      let :params do
        {
          :apache_version => '2.4',
        }
      end

      it { should contain_file("/etc/apache2/mods-available/worker.load").with({
        'ensure'  => 'file',
        'content' => "LoadModule mpm_worker_module /usr/lib/apache2/modules/mod_mpm_worker.so\n"
        })
      }
      it { should contain_file("/etc/apache2/mods-enabled/worker.load").with_ensure('link') }
    end
  end
  context "on a RedHat OS" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
      }
    end
    it { should contain_class("apache::params") }
    it { should_not contain_apache__mod('worker') }
    it { should contain_file("/etc/httpd/conf.d/worker.conf").with_ensure('file') }

    context "with Apache version < 2.4" do
      let :params do
        {
          :apache_version => '2.2',
        }
      end

      it { should contain_file_line("/etc/sysconfig/httpd worker enable").with({
        'require' => 'Package[httpd]',
        })
      }
    end

    context "with Apache version >= 2.4" do
      let :params do
        {
          :apache_version => '2.4',
        }
      end

      it { should_not contain_apache__mod('event') }

      it { should contain_file("/etc/httpd/conf.d/worker.load").with({
        'ensure'  => 'file',
        'content' => "LoadModule mpm_worker_module modules/mod_mpm_worker.so\n",
        })
      }
    end
  end
  context "on a FreeBSD OS" do
    let :facts do
      {
        :osfamily               => 'FreeBSD',
        :operatingsystemrelease => '9',
        :concat_basedir         => '/dne',
      }
    end
    it { should contain_class("apache::params") }
    it { should_not contain_apache__mod('worker') }
    it { should contain_file("/usr/local/etc/apache22/Modules/worker.conf").with_ensure('file') }
  end
end
