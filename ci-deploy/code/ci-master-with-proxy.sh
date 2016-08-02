#!/bin/bash -x

if [ "$HOME" != "/root" ]; then
    echo "ple change to root user"
    exit 1
fi

PROXY_IP=127.0.0.1
PROXY_PORT=8081
JENKINS_MASTER_PORT=8080

http_proxy=http://$PROXY_IP:$PROXY_PORT
https_proxy=$http_proxy
work_dir='/home/opnfv/install'

source /root/.profile
#
## install the dependency
#apt-get update
#apt-get upgrade -y 
#apt-get install -y python-pip python-dev build-essential
#apt-get install -y \
#wget \
#curl \
#openssh-server \
#uuid-runtime \
#vim \
#python \
#git \
#ansible \
#software-properties-common \
#&& apt-get clean \
#&& rm -rf /var/lib/apt/lists/*
#
## add configure & proxy for git 
#cat <<EOF >/root/.gitconfig
#[http]
#	proxy=$http_proxy
#[https]
#	proxy=$http_proxy
#[user]
#	name=admin
#	email=julienjut@gmail.com
#[url "https://"]
#        insteadOf = git://
#EOF
#
## add proxy for pip 
#mkdir -p /root/.pip
#cat <<EOF >/root/.pip/pip.conf
#[global]
#proxy=$http_proxy
#EOF
#
## install puppet and modules
#cd /home/opnfv
#git clone https://git.openstack.org/openstack-infra/system-config  
#/home/opnfv/system-config/install_puppet.sh
#
#cd $work_dir
#cp pip.rb /usr/lib/ruby/vendor_ruby/puppet/provider/package/pip.rb
#
#pip install --upgrade pip 
#pip install -U testrepository
#pip install -U python-jenkins
#apt-get install -y puppetmaster-passenger hiera hiera-puppet

#/home/opnfv/system-config/install_modules.sh

#cp common.yaml /etc/puppet/environments/common.yaml 
#cp /etc/puppet/modules/openstackci/contrib/hiera.yaml /etc/puppet/
#cp /etc/puppet/modules/openstackci/contrib/single_node_ci_site.pp /etc/puppet/manifests/site.pp

#sed -i -r "s/upstart/init/g" /etc/puppet/modules/mysql/spec/classes/mysql_server_spec.rb
#sed -i -r "s/upstart/init/g" /etc/puppet/modules/mysql/manifests/params.pp

## install the package for ci
#puppet apply --verbose /etc/puppet/manifests/site.pp

# set the proxy in file(pip proxy set in global is not available)
# rm /etc/nodepool/elements/cache-devstack/install.d/99-cache-testrepository-db
#
#sed -i -r "s/8.8.8.8/114.114.114.114/g" /etc/nodepool/elements/nodepool-base/finalise.d/99-unbound
#
#sed -i -r "s/8.8.8.8/114.114.114.114/g" /etc/nodepool/elements/nodepool-base/environment.d/75-nodepool-base-env
#
#sed -i -r "s/8.8.8.8/114.114.114.114/g" /etc/nodepool/scripts/prepare_node.sh
#
#sed -i -r "s/pip install/pip install --proxy http:\/\/$PROXY_IP:$PROXY_PORT/g" /etc/nodepool/elements/cache-bindep/install.d/40-install-bindep
#
#sed -i -r "s/pip install/pip install --proxy http:\/\/$PROXY_IP:$PROXY_PORT/g" /etc/nodepool/elements/nodepool-base/install.d/90-venv-swift-logs
#
#sed -i -r "s/pip install/pip install --proxy http:\/\/$PROXY_IP:$PROXY_PORT/g" /etc/nodepool/elements/nodepool-base/install.d/91-venv-os-testr
#
#sed -i -r "s/zuul-swift-logs-env\/bin\/pip install/zuul-swift-logs-env\/bin\/pip install --proxy http:\/\/$PROXY_IP:$PROXY_PORT/g" /etc/nodepool/scripts/prepare_node.sh
#
#sed -i -r "s/os-testr-env\/bin\/pip install/os-testr-env\/bin\/pip install --proxy http:\/\/$PROXY_IP:$PROXY_PORT/g" /etc/nodepool/scripts/prepare_node.sh
#
#sed -i -r "s/pip install/pip install --proxy http:\/\/$PROXY_IP:$PROXY_PORT/g" /etc/nodepool/scripts/prepare_tripleo.sh
#
#sed -i -r "s/pip install/pip install --proxy http:\/\/$PROXY_IP:$PROXY_PORT/g" /etc/nodepool/scripts/prepare_node_devstack.sh
#

#service mysql start
#service apache2 start
#service zuul start                       
#service zuul-merger start  

## set the nodepool user global env
#cp /root/.gitconfig /home/nodepool/.gitconfig
#cp  /root/.pip/pip.conf  /home/nodepool/.pip/pip.conf
#echo "export http_proxy=$PROXY_IP:$PROXY_PORT" >> /home/nodepool/.profile
#echo "export https_proxy=$PROXY_IP:$PROXY_PORT" >> /home/nodepool/.profile
#chown nodepool:nodepool /home/nodepool/.gitconfig
#chown -R nodepool:nodepool /opt/dib_cache
#
## register the image-build dpc worker
#/usr/local/bin/nodepoold -c /etc/nodepool/nodepool.yaml -l /etc/nodepool/logging.conf

## build dpc image
#bash -c "su nodepool; cd; source /etc/default/nodepool; nodepool build-image dpc; exit"

## upload the iamge to openstack env
#nodepool image-upload all dpc

#unset http_proxy; unset https_proxy; nodepool image-upload all dpc; exit"
service nodepool start
service jenkins restart

exec jenkins-jobs update --delete-old /etc/jenkins_jobs/config
