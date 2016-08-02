
CI Deploy User Guide
====================

This instruction will guide user to deploy a (Openstack) CI environment. The workflow of
deploying CI has been introduced in `Openstack Third-part CI <http://docs.openstack.org/infra/openstackci/third_party_ci.html>`_ . Please read it.

Now, according to the `Openstack Third-part CI <http://docs.openstack.org/infra/openstackci/third_party_ci.html>`_ , a script is drafted to deploy ci master node automatically. User can find this script in ``../code/deploy-cimaster-with-proxy.sh``.

Before run the above script, serveral files need to be prepared in advance.

Assuming: the CI master is deployed in a VM.

common.yaml
-----------------------------

::

  # See parameter documetation inside ../manifests/single_node_ci.pp
  # Fields commented out have reasonable default values
  
  #vhost_name:
  project_config_repo: https://github.com/USERNAME/project-config 
  #serveradmin:
  jenkins_username: jenkins
  jenkins_password: jenkins
  jenkins_ssh_private_key: | 
                           -----BEGIN RSA PRIVATE KEY-----
                           ...OMIT...
                           -----END RSA PRIVATE KEY-----
  jenkins_ssh_public_key: AAAAB3NzaC1yc2EAAAADAQABAAABAQDHa...C/w3GJ5KvtCKeEAiAvoWqH5SspUhbRpzfCYvvhRzbTRbDL
  gerrit_server: 10.63.243.3
  #gerrit_ssh_host_key:
  gerrit_user: openzeroci
  gerrit_user_ssh_private_key: |
                               -----BEGIN RSA PRIVATE KEY-----
                               ...OMIT...
                               -----END RSA PRIVATE KEY-----
  gerrit_user_ssh_public_key: AAAAB3NzaC1yc2EAAAADAQABAAABAQDHa...C/w3GJ5KvtCKeEAiAvoWqH5SspUhbRpzfCYvvhRzbTRbDL
  git_email: openzeroci@zte.com.cn 
  git_name: openzeroci
  log_server: 192.168.122.252
  #smtp_host:
  #smtp_default_from:
  #smtp_default_to:
  zuul_revision: master
  zuul_git_source_repo: https://git.openstack.org/openstack-infra/zuul
  oscc_file_contents: |
                      # Do Not Edit - Generated & Managed by Puppet
                      #
  mysql_root_password: root123 
  mysql_nodepool_password: root123 
  #nodepool_jenkins_target: jenkins1
  jenkins_api_key: fd11cfaebab8659d7f8a3e7cb0649a6d
  jenkins_credentials_id: 0e779e44-eb45-4266-864c-d729ab16c15a
  nodepool_revision: master
  nodepool_git_source_repo: https://git.openstack.org/openstack-infra/nodepool


* project_config_repo

This repo contains a set of config files that are consumed by the openstack-infra/system-config puppet
modules in order to deploy and configure the OpenStack Infrastructure. You need to create an account in
GitHub and `make configuration changes <http://docs.openstack.org/infra/openstackci/third_party_ci.html#create-an-initial-project-config-repository`_ for your own CI environment. 

In the repo, the major modification is in nodepool.yaml. It will be introduced in the following section.

* jenkins_username/jenkins_password

The username and password for Jenkins. They will be written into the jenkins config: ``/etc/jenkins_jobs/jenkins_jobs.ini``.

* jenkins_ssh_private_key

For all of the private_key in common.yaml, the content of private key must be vertical alignment with the vertical bar.

* jenkins_ssh_public_key

In general, a public key is consist of three part: key_type, main body of key, and annotation.

But, for ``jenkins_ssh_public_key``, please **ONLY** fill with main body of public key, without key_type and annotation.

* git_name/git_email/gerrit_server


``git_name`` and ``git_email`` will be used to zuul merger. ``gerrit_server`` will define which gerrit server zuul will
monitor.

These options will be written into zuul config: ``/etc/zuul/zuul.conf``.

::

  # /etc/zuul/zuul.conf
  [gearman]
  server=localhost
  
  [gearman_server]
  start=true
  log_config=/etc/zuul/gearman-logging.conf
  
  [gerrit]
  server=10.63.243.3
  user=openzeroci
  sshkey=/var/lib/zuul/ssh/id_rsa
  
  [zuul]
  layout_config=/etc/zuul/layout/layout.yaml
  log_config=/etc/zuul/logging.conf
  state_dir=/var/lib/zuul
  url_pattern=http://192.168.122.252/{build.parameters[LOG_PATH]}
  status_url=http://cimaster
  job_name_in_report=true
  
  [merger]
  git_dir=/var/lib/zuul/git
  zuul_url=http://cimaster/p/
  log_config=/etc/zuul/merger-logging.conf
  git_user_email=openzeroci@zte.com.cn
  git_user_name=openzeroci
  
  
  [smtp]
  server=localhost
  port=25
  default_from=zuul@cimaster
  default_to=zuul.reports@cimaster

So, if you want to modify the zuul config, please first modify the common.yaml file, and then run the
puppet command.
::

  sudo puppet apply --verbose /etc/puppet/manifests/site.pp

* jenkins_api_key/jenkins_credentials_id
* zuul_revision/nodepool_revision




project-config repo (nodepool.yaml)
-----------------------------------


Jenkins
=======


Gerrit
========


Test Repo
=========


Common Command
==============


FAQ
====

During deploying CI master, series of bugs will be occurred. In this guide, it will summary the common problems.

Note: In this instruction, it is dafault that, a) don't need to add proxy to host, b) no limited for host to
connect to foreigin websites. Otherwise, there will be so many bugs caused by an unreachable network, and these
bugs are not listed in the following.

* database update failed
* nodepool image-build failed
* nodepool \** cmd no valid
* ci slave node created failed
* slave node can not be registered in jenkins
* slave node is outline in jenkins
* job (such as dsvm-tempest-full) failed
* zuul merge failed
* /etc/resolv.conf is repeatly overridden
* update ready-script failed
* gerrit can not receive the result of 'verified -1'
* git review failed
* jenkins-jobs update failed
