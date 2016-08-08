#!/bin/bash

PROXY_IP=127.0.0.1
PROXY_PORT=8081

http_proxy=http://$PROXY_IP:$PROXY_PORT
https_proxy=$http_proxy

local_ip=$(ifconfig | grep "inet addr" | grep -v 127.0.0.1 | awk '{print $2}' | awk -F ':' '{print $2}')

local_path=`pwd`
if [ ! -d $local_path/tmp ]; then
    mkdir $local_path/tmp
fi
work_dir=$local_path/tmp

# set git proxy
function set_user_git_proxy {
    myname=`whoami`
    mypath=`cat /etc/passwd | grep $myname | awk -F ":" '{print $6}'`
    cat <<EOF > $mypath/.gitconfig
[http]
        proxy = $PROXY_IP:$PROXY_PORT
[https]
        proxy = $PROXY_IP:$PROXY_PORT
[url "https://"]
        insteadOf = git://
EOF
}

#set pip proxy
function set_user_pip_proxy {
    myname=`whoami`
    mypath=`cat /etc/passwd | grep $myname | awk -F ":" '{print $6}'`

    if [ ! -d $mypath/.pip ]; then
        mkdir $mypath/.pip
    fi

    cat <<EOF > $mypath/.pip/pip.conf
[global]
proxy=$http_proxy
EOF
}

#set profile proxy
function set_user_proxy {
    myname=`whoami`
    mypath=`cat /etc/passwd | grep $myname | awk -F ":" '{print $6}'`

    echo "export http_proxy=$PROXY_IP:$PROXY_PORT" >> $mypath/.profile
    echo "export https_proxy=$PROXY_IP:$PROXY_PORT" >> $mypath/.profile
    echo "export no_proxy=localhost,127.0.0.1,$local_ip" >> $mypath/.profile
    source $mypath/.profile
}

#set apt proxy
function set_apt_proxy {
    cat <<EOF > /etc/apt/apt.conf
Acquire::http::Proxy "$http_proxy";
Acquire::https::Proxy "$https_proxy";
EOF
}

set_apt_proxy
set_user_git_proxy
set_user_pip_proxy
set_user_proxy



# git clone devstack
cd $work_dir
git clone https://github.com/openstack-dev/devstack

# create stack user
cd $work_dir/devstack/tools
./create-stack-user.sh

chown -R stack:stack $work_dir/devstack

su - stack

# set the stack user global env
set_user_git_proxy
set_user_pip_proxy
set_user_proxy

function config_ds_local {
    cat <<EOF > $work_dir/devstack/local.conf
[[local|localrc]]
ADMIN_PASSWORD=stack
DATABASE_PASSWORD=stack
RABBIT_PASSWORD=stack
SERVICE_PASSWORD=stack

enable_service heat h-api h-api-cfn h-api-cw h-eng
disable_service tempest
enable_plugin vitrage https://github.com/openstack/vitrage
enable_plugin vitrage-dashboard https://github.com/openstack/vitrage-dashboard
enable_plugin ceilometer https://github.com/openstack/ceilometer
enable_plugin aodh https://github.com/openstack/aodh

GIT_DEPTH=1

[[post-config|\$NOVA_CONF]]
[DEFAULT]
notification_topics = notifications,vitrage_notifications
notification_driver=messagingv2

EOF
}

config_ds_local

sed -i -r "s/curl -f/curl -x $PROXY_IP:$PROXY_PORT -f/g"  $work_dir/devstack/tools/install_pip.sh
sed -i -r "s/function upload_image \{/function upload_image \{\\n    export http_proxy=$PROXY_IP:$PROXY_PORT\\n    export https_proxy=$PROXY_IP:$PROXY_PORT\\n    export no_proxy=localhost,127.0.0.1,$local_ip/g" functions
sed -i '/if ! timeout 300 sh -c/, +2d' $work_dir/devstack/functions-common

$work_dir/devstack/stack.sh
