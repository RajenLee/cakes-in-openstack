
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
  project_config_repo: https://github.com/dongwenjuan/project-config 
  #serveradmin:
  jenkins_username: jenkins
  jenkins_password: jenkins
  jenkins_ssh_private_key: | 
                           -----BEGIN RSA PRIVATE KEY-----
                           ...OMIT...
                           -----END RSA PRIVATE KEY-----
  jenkins_ssh_public_key: AAAAB3NzaC1yc2EAAAADAQABAAABAQDHaEP31qpXO1DZVoVDvirS8gYNkiDxWyJLSx5nNB58WKs11/aLX4HzP0Y+WcIzHholnynGcBbpG/9eyUpbd2wsBS8tJtJcCcjHBrJ/bvfMjlUyR7uhpU7Pk1FgqyCvY7uaGJThhMVijQ59BY8E5YQIoZu+DnejVqAMyEobE0tcSwIKurRbEajyvrx1/f/o+feIy5AbPjIVqKCoIjfgrkFbicYo0LB+Hd/zEI3SukyU4KqHHHlyZ6+iGklF8chZJPnJM9QhQpGVTw93C13jW2DsWzz5CtOUgRbB1GQxzEC/w3GJ5KvtCKeEAiAvoWqH5SspUhbRpzfCYvvhRzbTRbDL
  gerrit_server: 10.63.243.3
  #gerrit_ssh_host_key:
  gerrit_user: openzeroci
  gerrit_user_ssh_private_key: |
                               -----BEGIN RSA PRIVATE KEY-----
                               ...OMIT...
                               -----END RSA PRIVATE KEY-----
  gerrit_user_ssh_public_key: AAAAB3NzaC1yc2EAAAADAQABAAABAQDHaEP31qpXO1DZVoVDvirS8gYNkiDxWyJLSx5nNB58WKs11/aLX4HzP0Y+WcIzHholnynGcBbpG/9eyUpbd2wsBS8tJtJcCcjHBrJ/bvfMjlUyR7uhpU7Pk1FgqyCvY7uaGJThhMVijQ59BY8E5YQIoZu+DnejVqAMyEobE0tcSwIKurRbEajyvrx1/f/o+feIy5AbPjIVqKCoIjfgrkFbicYo0LB+Hd/zEI3SukyU4KqHHHlyZ6+iGklF8chZJPnJM9QhQpGVTw93C13jW2DsWzz5CtOUgRbB1GQxzEC/w3GJ5KvtCKeEAiAvoWqH5SspUhbRpzfCYvvhRzbTRbDL
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


* 


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
