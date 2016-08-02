#!/bin/bash -xe

# Some cmd need run as root
if [ "$EUID" -ne 0 ]; then
    echo "ple change to root user"
    exit 1
fi

# Path for this script and config file
WORKDIR=`pwd`

# Prepared for installing system dependencies
# These dependencies are packages which need to be installed in
# my machine. In other machines, it maybe need to install some
# other packages except these dependencies.
# In general, these denpendencies are enough.
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y python-pip python-dev build-essential
sudo apt-get install -y \
wget \
curl \
openssh-server \
uuid-runtime \
vim \
python \
git \
ansible \
software-properties-common
sudo apt-get clean \
sudo rm -rf /var/lib/apt/lists/*

# Install puppet by running script
cd $WORKDIR
git clone https://git.openstack.org/openstack-infra/system-config
/$WORKDIR/system-config/install_puppet.sh

# Check whether the pip.rb file is exist in $WORKDIR dir
if [ ! -f pip.rb ]; then
    echo "pls make sure the pip.rb is exist..."
    exit 1
fi

cp pip.rb /usr/lib/ruby/vendor_ruby/puppet/provider/package/pip.rb

# Prepared for ci dependencies
sudo pip install --upgrade pip
sudo pip install -U testrepository
sudo pip install -U python-jenkins
sudo apt-get install -y puppetmaster-passenger hiera hiera-puppet

# Install modules by puppet
/$HOME/system-config/install_modules.sh

# Prepared for configuration
# Check whether the common.yaml file is exist in $WORKDIR dir.
# Note: before copy common.yaml file to /etc/puppet/environments/,
#       ple give the right config options in common.yaml.
if [ ! -f common.yaml ]; then
    echo "pls make sure the common.yaml is exist..."
    exit 1
fi

sudo cp common.yaml /etc/puppet/environments/common.yaml
sudo cp /etc/puppet/modules/openstackci/contrib/hiera.yaml /etc/puppet/
sudo cp /etc/puppet/modules/openstackci/contrib/single_node_ci_site.pp /etc/puppet/manifests/site.pp

sudo sed -i -r "s/upstart/init/g" /etc/puppet/modules/mysql/spec/classes/mysql_server_spec.rb
sudo sed -i -r "s/upstart/init/g" /etc/puppet/modules/mysql/manifests/params.pp

# install the package for ci
sudo puppet apply --verbose /etc/puppet/manifests/site.pp



sudo service mysql start
sudo service apache2 start
sudo service zuul start
sudo service zuul-merger start

sudo chown -R nodepool:nodepool /opt/dib_cache

# register the image-build dpc worker
sudo service nodepool-builder start
sudo service nodepool start

echo "WARNING: pls give the image name, if None, default as 'dpc'."
IMAGE_NAME=${IMAGE_NAME:-dpc}

# build dpc image
bash -c "sudo su - nodepool; cd; source /etc/default/nodepool; nodepool image-build $IMAGE_NAME; exit"

# upload the iamge to openstack env
sudo nodepool image-upload all $IMAGE_NAME

sudo service nodepool start
sudo service jenkins restart

