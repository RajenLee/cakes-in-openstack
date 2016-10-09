User Guide
**********

Deploy CI master node
========================

This instruction will guide user to deploy a (Openstack) CI environment.
The workflow of deploying CI has been introduced in
`Openstack Third-part CI <http://docs.openstack.org/infra/openstackci/third_party_ci.html>`_ .
Please read it.

Now, according to the `Openstack Third-part CI <http://docs.openstack.org/infra/openstackci/third_party_ci.html>`_ ,
a script is drafted to deploy ci master node automatically. User can find
this script in ``../code/deploy-cimaster-with-proxy.sh``.

Before running the above script, several files need to be prepared in advance.

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
  jenkins_ssh_public_key: AAAAB3NzaC1y...C/w3GJ5K5SspUhbRpzfCYvvhRzbTRbDL
  gerrit_server: 10.63.243.3
  #gerrit_ssh_host_key:
  gerrit_user: openzeroci
  gerrit_user_ssh_private_key: |
                               -----BEGIN RSA PRIVATE KEY-----
                               ...OMIT...
                               -----END RSA PRIVATE KEY-----
  gerrit_user_ssh_public_key: AAAAB3NzaC1y...C/w3GJ5hbRpzfCYvvhRzbTRbDL
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

This repo contains a set of configuration files that are consumed by the
"openstack-infra/system-config" puppet modules in order to deploy and configure
the OpenStack Infrastructure. You need to create an account inGitHub and
`make configuration changes <http://docs.openstack.org/infra/openstackci/third_party_ci.html#create-an-initial-project-config-repository>`_ for your own CI environment.

In the repo, the major modification is in nodepool.yaml. It will be introduced
in the following section.

* jenkins_username/jenkins_password

The username and password for Jenkins. They will be written into the Jenkins
config: ``/etc/jenkins_jobs/jenkins_jobs.ini``.

* jenkins_ssh_private_key

For all of the private_key in common.yaml, the content of private key must be
vertical alignment with the vertical bar.

* jenkins_ssh_public_key

In general, a public key consists of three parts: key_type, main body of key,
and annotation.

But, for ``jenkins_ssh_public_key``, please **ONLY** fill with main body of
public key, without key_type and annotation.

* git_name/git_email/gerrit_server


``git_name`` and ``git_email`` will be used to Zuul merger. ``gerrit_server``
will define which gerrit server that Zuul will monitor.

These options will be written into Zuul config: ``/etc/zuul/zuul.conf``.

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

So, if you want to modify the Zuul config, please first modify the common.yaml
file, and then run the puppet command.

::

  sudo puppet apply --verbose /etc/puppet/manifests/site.pp

* jenkins_api_key/jenkins_credentials_id

This config can be found in Openstack CI `Jenkins <http://docs.openstack.org/infra/openstackci/third_party_ci.html#securing-jenkins-optional>`_ .

* zuul_revision/nodepool_revision

When set zuul_revision/nodepool_revision as master, during running the puppet
command, it will get lastest version of Zuul and Nodepool codes from the
master branch of project, respectively.

If you want to have a stable env, please select a stable branch for the Zuul
and Nodepool.


project-config repo (nodepool.yaml)
-----------------------------------

``project-config`` repo contains the configuration of CI modules, including
Gerrit, Zuul, Jenkins, Nodepool and so on. The role of each module is
introduced in `official project-config <https://github.com/openstack-infra/project-config>`_.

To configure an available project-config repo, the above modules need to be
modified. While, the major work is in `nodepool.yaml <https://github.com/openstack-infra/project-config/blob/master/nodepool/nodepool.yaml>`_ file in Nodepool module(dir).

The following is nodepool.yaml file used for my CI environment.

::

  script-dir: /etc/nodepool/scripts
  elements-dir: /etc/nodepool/elements
  images-dir: /opt/nodepool_dib

  cron:
    cleanup: '*/1 * * * *'
    check: '*/15 * * * *'
    image-update: '14 14 * * *'

  zmq-publishers:
    - tcp://localhost:8888

  gearman-servers:
    - host: 127.0.0.1

  labels:
    - name: ubuntu-trusty
      image: ubuntu-trusty
      ready-script: configure_mirror.sh
      min-ready: 5
      providers:
        - name: zte-RegionOne

  providers:
    - name: zte-RegionOne
      region-name: 'RegionOne'
      username: 'ciuser'
      password: 'ciuser'
      auth-url: 'http://172.20.0.12:5000/v2.0'
      project-name: 'ciuser'
      api-timeout: 60
      boot-timeout: 1500
      max-servers: 40
      rate: 0.001
      image-type: qcow2
      networks:
        - net-id: add16b70-14fc-402f-bd52-459cab1fd2e6
      images:
        - name: ubuntu-trusty
          min-ram: 8192
          diskimage: ubuntu-trusty
          username: jenkins
          private-key: /home/nodepool/.ssh/id_rsa
          # name-filter: 'Performance'
          # config-drive: true

  targets:
    - name: jenkins1

  diskimages:
    - name: ubuntu-trusty
      elements:
        - ubuntu-minimal
        - vm
        - simple-init
        - openstack-repos
        - nodepool-base
        - node-devstack
        - cache-bindep
        - growroot
        - infra-package-needs
      release: trusty
      env-vars:
        DIB_DISTRIBUTION_MIRROR: http://mirrors.tuna.tsinghua.edu.cn/ubuntu/
        TMPDIR: /opt/dib_tmp
        DIB_IMAGE_CACHE: /opt/dib_cache
        DIB_APT_LOCAL_CACHE: '0'
        DIB_DISABLE_APT_CLEANUP: '1'


**Note**

* ``username``, ``password``, ``auth-url``, ``project-name`` and ``net-id``

The info of an available OpenStack environment and ``net-id`` is the internal
network of OpenStack environment.

* the ``name`` in diskimage, ubuntu-trusty, is the value of $IMAGE_NAME.

* ``ready-script`` defines which script will be run once slave node is started.

If you want to add some configuration to slave node before running the Jenkins
job, ple modify ``configure_mirrors.sh``, located in ``./nodepool/script/``.

* ``name`` option in ``targets`` section

It is the Jenkins master where Nodepool should attach nodes.

Nodepool provides a secure file, named ``/etc/nodepool/secure.conf``. It is a
standard ini config file.

Take a snippet from ``/etc/nodepool/secure.conf``

::

  [jenkins "{target_name}"]
  user={user}
  apikey={apikey}
  credentials={credentials}
  url={url}

The variable ``{target_name}`` is the name of the Jenkins target. It needs to
match with a ``targets:name`` specified in nodepool.yaml

* More introductions for nodepool.yaml configuration can be found in `this <http://docs.openstack.org/infra/nodepool/configuration.html>`_ .

Jenkins
=======

Jenkins configuration has been introduced in detail in `this <http://docs.openstack.org/infra/openstackci/third_party_ci.html#securing-jenkins-optional>`_.
Please follow it.

prune Jenkins jobs
--------------------

If use the Jenkins jobs configuration in official, there will be more than six
thousand Jenkins jobs registered in Jenkins. Most of them are unused for our
CI test. An operation of pruning will be needed.

Firstly, delete all of useless projects in ``./jenkins/jobs/projects.yaml``,
only reserve your own project.

Secondly, run the ``jenkins-jobs update`` command.

::

  jenkins-jobs --conf /etc/jenkins-jobs/jenkins-jobs.ini update --delete-old \
      /etc/jenkins-jobs/config/

**TIP**
It will take a very, and very, long time to prune Jenkins jobs, if there is
too many jobs in original.

To save time, you can first use ``delete-all`` command to delete all of
Jenkins jobs, and then use ``update`` command to update new jobs.

::

  jenkins-jobs delete-all
  jenkins-jobs --conf /etc/jenkins_jobs/jenkins_jobs.ini update /etc/jenkins_jobs/config


Gerrit
========

Firstly, you need a healthy Gerrit server, and an available account with
administrator role.

Assuming: Gerrit server is 10.63.243.3, account is green.

Test gerrit

::

  opnfv@cimaster:~$ ssh -p 29418 green@10.63.243.3

    ****    Welcome to Gerrit Code Review    ****

    Hi green, you have successfully connected over SSH.

    Unfortunately, interactive shells are disabled.
    To clone a hosted Git repository, use:

    git clone ssh://green@10.63.243.3:29418/REPOSITORY_NAME.git

  Connection to 10.63.243.3 closed.

As shown above, the Gerrit server and account is OK.

Create CI account
-----------------

As the common.yaml shown, ``git_user``, ``git_email`` and ``gerrit_user``
options need to fill an account. This account is created in Gerrit, and
used for CI Jenkins jobs.

::

  cat ~/.ssh/id_rsa.pub|ssh -p 29418 green@10.63.243.3 gerrit create-account \
      openzeroci --email openzeroci@zte.com.cn --full-name openzeroci --group \
      "'VerifiedCI'" --http-password Aa888888 --ssh-key -

**NOTE**

* The ``id_rsa.pub`` must be consistent with the ``gerrit_user_ssh_public_key``
  in common.yaml, which is paired with ``gerrit_user_ssh_private_key``.

* ``--group "'VerifiedCI'"``, "VerifiedCI" group must be exist before run the above
  command to create "openzeroci" account. If no, pls create group firstly.

::

  ssh -p 29418 green@10.63.243.3 gerrit create-group VerifiedCI


Create CI group(optional)
-------------------------

If you don't like creating group by shell command, you can use the web browser.

.. image:: ./images/create_verifiedci_group.JPG
  :name: create_verifiedci_group
  :width: 80%


Set CI account(optional)
----------------

Join the "openstackci" account into "VerifiedCI" group.

.. image:: ./images/add_account_in_verifiedci_group.JPG
  :name: add_account_in_verifiedci_group.JPG
  :width: 80%


Create CI project
-----------------

::

  ssh -p 29418 green@10.63.243.3 gerrit create-project ci_test.git


Set project access
---------------------

* create master branch for "ci_test" project

.. image:: ./images/set_project_branch.JPG
  :name: set_project_branch
  :width: 80%

* config "ci_test" access

In general, the following access should be configured for project.

::

  Core-Review -2,+2
  Core-Review -1,+1
  Verified -1,+1

.. image:: ./images/set_project_access.JPG
  :name: set_project_access
  :width: 80%


Example: "citest" project
=========================

Create "citest" repo in Gerrit
------------------------------

Description in detail in "Gerrit/Create Ci Project" section.

Set "citest" repo access
------------------------

Description in detail in "Gerrit/Set Project Access" section.

Add Jenkins Jobs Configuration
------------------------------

Git clone "project-config" repo and modify the following files.

/project-config/zuul/layout.yaml

::

  # add citest job config in projects section
  # projects:
  - name: citest
    check:
      - citest-verified-flow
    gate:
      - citest-verified-flow

/project-config/jenkins/jobs/projects.yaml

::

  - project:
    name: citest
    jobs:
      - {name}-verified-flow

/project-config/jenkins/jobs/citest.yaml

::

  job-template:
    name: {name}-verified-flow
    builders:
      - link-logs
      - net-info
      - shell: |
          cat /etc/resolv.conf
    publishers:
      - test-results
      - console-log

``./zuul/layout.yaml`` file will be copied into ``/etc/zuul/layout/layout.yaml``.

``./jenkins/jobs/projects.yaml`` and ``./jenkins/jobs/citest.yaml`` will be
copied to ``/etc/jenkins-jobs/config/projects.yaml`` and
 ``/etc/jenkins-job/config/citest.yaml``.

``layout.yaml`` contains the rules of pipelines and which jobs will be
triggered for a project. Besides, according to the open project, such as
citest, in ``projects.yaml`` and jobs of this project configured in
``layout.yaml`` , Zuul service will register these jobs' name into Gearman.


``projects.yaml`` file defines all of the Jenkins jobs for all projects.
It is the entry for Jenkins Jobs Builder(JJB) creating Jenkins jobs.
While, the content of ``projects.yaml`` is just job templates, not the specific
jobs. So which jobs are included in each template? and what does a specific job
do?

``citest.yaml`` introduces the defination of job template: {name}-verified-flow.
One template, one ``job-template`` section. It includes a list of jobs or shell
commands.

In a word, JJB reads ``projects.yaml`` file to construct the set of all Jenkins
jobs. For each project, it sees the "name" attribute of the project, and
substitutes that "name" attribute value wherever it sees "{name}" in any of the
jobs that are defined for that project. JJB reads other YAML file to parse job
template and then creates jobs.

**NOTE**
Zuul does not construct Jenkins jobs. JJB does that. Zuul simply configures
which Jenkins jobs should run for a project and a pipeline. JJB translates
YAML type of job templating rules to XML configuration, and then create
Jenkins jobs.

After "citest" project configuration file prepared, use ``jenkins-jobs update``
command to update new jobs to Jenkins.

If all jobs can be found in Jenkins browser and Gearman, "citest" jobs is
configured successfully.

**TIP**
Check whether new jobs are registered in Gearman

::

  echo status | nc 127.0.0.1 4730 -w 1|grep citest
  #result
  opnfv@cimaster:~$ echo status | nc 127.0.0.1 4730 -w 1 |grep citest
  build:citest-verified-flow:ubuntu-trusty	0	0	5
  build:citest-verified-flow	0	0	5


Trigger jobs (push a new change/patchset)
------------


After the above three files modified and merged, these new Jenkins jobs
should be registered in Gearman and Jenkins.

Then, git clone "citest" project and trigger jobs.

A new change, as well as patchset, can trigger Jenkins job. If there is no
open change for "ci_test" project, you should git clone the "ci_test" project
with commit-msg hook and then git push a new change. Otherwise, you can add
a new patchset of change to trigger Jenkins jobs.

git push a new change

::

  git clone ssh://green@10.63.243.3:29418/ci_test && scp -p -P 29418 \
      green@10.63.243.3:hooks/commit-msg ci_test/.git/hooks/
  cd ci_test
  git remote add gerrit ssh://green@10.63.243.3:29418/ci_test
  touch test.file
  git add test.file
  git commit ## add comment in commit
  git review

The link for git clone with commit-msg hook can be got from here.

.. image:: ./images/set_project_git_clone.JPG
  :name: set_project_git_clone
  :width: 80%

