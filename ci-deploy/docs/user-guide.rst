User Guide
**********

Deploy CI master node 
========================

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
GitHub and `make configuration changes <http://docs.openstack.org/infra/openstackci/third_party_ci.html#create-an-initial-project-config-repository>`_ for your own CI environment. 

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

This config can be found in Openstack CI `Jenkins <http://docs.openstack.org/infra/openstackci/third_party_ci.html#securing-jenkins-optional>`_ .

* zuul_revision/nodepool_revision

When set zuul_revision/nodepool_revision as master, during running the puppet command, it will get
lastest version of zuul and nodepool codes from the master branch of project, respectively. 

If you want to have a stable env, please select a stable branch for the zuul and nodepool.


project-config repo (nodepool.yaml)
-----------------------------------

``project-config`` repo contains the configuration of CI modules, including Gerrit, Zuul, Jenkins,
Nodepool and so on. The role of each module is introduced in `official project-config <https://github.com/openstack-infra/project-config>`_.

To config an available project-config repo, the above modules need to be modified. While, the major work is in `nodepool.yaml <https://github.com/openstack-infra/project-config/blob/master/nodepool/nodepool.yaml>`_ file in Nodepool module(dir).

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


Note

* ``username``, ``password``, ``auth-url`` and ``project-name`` is the info of an available OpenStack environment.
``net-id`` is the internal network of Openstack environment.

* the name in diskimage, ubuntu-trusty, is the value of $IMAGE_NAME.

* ``ready-script`` define which script will be run once slave node is started. 

If you want to add some configuration to slave node before running the jenkins job, you can modify ``configure_mirrors.sh``. It is located in ``./nodepool/script/``.

* the name option in ``targets`` section is the Jenkins master which nodepool should attach nodes to.

Nodepool provides a secure file, named ``/etc/nodepool/secure.conf``. It is a standard ini config file.
Take a skip from ``/etc/nodepool/secure.conf``
::
  
  [jenkins "{target_name}"]
  user={user}
  apikey={apikey}
  credentials={credentials}
  url={url}
  
the variable ``{target_name}`` is the name of the jenkins target. It needs to match with a ``targets`` name specified in nodepool.yaml

* More introductions for nodepool.yaml configuration can be found in `this <http://docs.openstack.org/infra/nodepool/configuration.html>`_ .

Jenkins
=======

Jenkins configuration has been introduced in detail in `this <http://docs.openstack.org/infra/openstackci/third_party_ci.html#securing-jenkins-optional>`_. Please follow it.

prune jenkins jobs
--------------------

If use the jenkins configuration in official, there will be more than six thousand jenkins jobs registered in Jenkins.
Most of them are useless for our CI test. An operation of pruning will be needed.

Firstly, delete all of useless projects in ``./jenkins/jobs/projects.yaml``, only reserve your own project.
Secondly, run the ``jenkins-jobs update`` command.

::

  jenkins-jobs --conf /etc/jenkins-jobs/jenkins-jobs.ini update --delete-old /etc/jenkins-jobs/config/
  
**TIP**
It will take a very, and very, long time to prune jenkins jobs, if there is too many jobs in original.
To save time, you can first ``delete-all`` jobs, and then ``update`` jobs.
::

  jenkins-jobs delete-all
  jenkins-jobs --conf /etc/jenkins_jobs/jenkins_jobs.ini update /etc/jenkins_jobs/config


Gerrit
========

Firstly, you need a healthy gerrit server, and an available account with administrator role.

Assuming: gerrit server is 10.63.243.3, account is green.

Test gerrit
::

  opnfv@cimaster:~$ ssh -p 29418 green@10.63.243.3
  
    ****    Welcome to Gerrit Code Review    ****
  
    Hi green, you have successfully connected over SSH.
  
    Unfortunately, interactive shells are disabled.
    To clone a hosted Git repository, use:
  
    git clone ssh://green@10.63.243.3:29418/REPOSITORY_NAME.git
  
  Connection to 10.63.243.3 closed.
  
As shown above, the gerrit server and account is OK.

create ci account
-----------------

As the common.yaml shown, ``git_user``, git_email`` and ``gerrit_user`` options need to fill an account.
This account is created in gerrit, and used for CI jobs.

::
  
  cat ~/.ssh/id_rsa.pub|ssh -p 29418 green@10.63.243.3 gerrit create-account openzeroci --email openzeroci@zte.com.cn --full-name openzeroci --group "'VerifiedCI'" --http-password Aa888888 --ssh-key -

**NOTE** 

* The ``id_rsa.pub`` must be consistent with the ``gerrit_user_ssh_public_key`` in common.yaml, which is paired with
``gerrit_user_ssh_private_key``.

* ``--group "'VerifiedCI'"``, VerifiedCI group must be exist before run the above command to create openzeroci. If no, pls create group firstly.
::
  
  ssh -p 29418 green@10.63.243.3 gerrit create-group VerifiedCI


create gerrit group(optional)
-------------------------
If you don't like creating group by shell command, you can use the web browser.

.. image:: /ci-deploy/docs/create_verifiedci_group.JPG
  :name: create_verifiedci_group
  :width: 80%


set gerrit account(optional)
----------------

Join the openstackci people into VerifiedCI group.

.. image:: /ci-deploy/docs/add_account_in_verifiedci_group.JPG
  :name: add_account_in_verifiedci_group.JPG
  :width: 80%


create gerrit project
-----------------

::

  ssh -p 29418 green@10.63.243.3 gerrit create-project ci_test.git


set gerrit project access
---------------------

* create master branch for "ci_test" project

.. image:: /ci-deploy/docs/set_project_branch.JPG
  :name: set_project_branch
  :width: 80%

* config "ci_test" access

In general, the following access should be configed for project.
::

  Core-Review -2,+2
  Core-Review -1,+1
  Verified -1,+1
  
.. image:: /ci-deploy/docs/set_project_access.JPG
  :name: set_project_access
  :width: 80%

* config "ci_test" jenkins jobs

Will be introduced in detailed in Test Repo Section.

* trigger jobs (push a new change/patchset)

A new change, as well as patchset, can trigger jenkins job. If there is no open change for "ci_test" project,
you should git clone the "ci_test" project with commit-msg hook and then git push a new change. Otherwise, you
can add a new patchset of change to trigger jobs.

git push a new change::

  git clone ssh://green@10.63.243.3:29418/ci_test && scp -p -P 29418 green@10.63.243.3:hooks/commit-msg ci_test/.git/hooks/
  cd ci_test
  git remote add gerrit ssh://green@10.63.243.3:29418/ci_test
  touch test.file
  git add test.file
  git commit ## add comment in commit
  git review
  
The link for git clone with commit-msg hook can be got from here.

.. image:: /ci-deploy/docs/set_project_git_clone.JPG
  :name: set_project_git_clone
  :width: 80%

Test Repo
=========
Take "citest" project for instance.

./zuul/layout.yaml
::

  # add citest job config in projects section
  # projects:
  - name: citest
    check:
      - citest-verified-flow
    gate:
      - citest-verified-flow
  
./jenkins/jobs/projects.yaml
::

  - project:
    name: citest
    jobs:
      - {name}-verified-flow
      
./jenkins/jobs/citest.yaml
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

``./zuul/layout.yaml`` file will be copy into ``/etc/zuul/layout/layout.yaml``.

``./jenkins/jobs/projects.yaml`` and ``./jenkins/jobs/citest.yaml`` will be copyed to 
``/etc/jenkins-jobs/config/projects.yaml`` and ``/etc/jenkins-job/config/citest.yaml``.

``layout.yaml`` contains the rules of pipelines and which jobs will be triggered for a project.
Besides, according to the open project, such as citest, in ``projects.yaml`` and jobs of this 
project configured in ``layout.yaml`` , zuul service will registers these jobs' name into gearman.


``projects.yaml`` file defines all of the Jenkins jobs for all projects. It is the entry for
Jenkins Jobs Builder creating Jenkins jobs.
While, the content of ``projects.yaml`` is just job templates, not the specific jobs.
So which jobs are included in each template? and what does a specific job do?

``citest.yaml`` introduces the defination of job template: {name}-verified-flow.
One template, one ``job-template`` section. It includes a list of jobs or shell commands.

In a word, JJB read the ``projects.yaml`` file to construct the set of all Jenkins jobs.
For each project, it sees the “name” attribute of the project, and substitutes that name
attribute value wherever it sees {name} in any of the jobs that are defined for that project.
JJB reads other YAML file to parse job template and then creates jobs.

**NOTE** Zuul does not construct Jenkins jobs. JJB does that. Zuul simply configures which Jenkins
jobs should run for a project and a pipeline. Jenkins Job Builder translates YAML type of job
templating rules to XML configuration, and then create Jenkins jobs.

After "citest" project configuration file prepared, use ``jenkins-jobs update`` command to
update new jobs to Jenkins.

If all jobs can be found in Jenkins brower and Gearman, "citest" jobs is configured successfully.

**TIP** Check whether new jobs are registered in Gearman
::
  
  echo status | nc 127.0.0.1 4730 -w 1|grep citest
  #result
  opnfv@cimaster:~$ echo status | nc 127.0.0.1 4730 -w 1 |grep citest
  build:citest-verified-flow:ubuntu-trusty	0	0	5
  build:citest-verified-flow	0	0	5


Common Command
==============

* puppet command
::

  sudo puppet apply --verbose /etc/puppet/manifests/site.pp

* nodepool command

::

  # build image
  nodepool image-build $IMAGE_NAME
  # update image
  nodepool image-update all $IMAGE_NAME
  # upload image to OpenStack env
  nodepool image-upload all #IMAGE_NAME

* jenkins command

::
  
  jenkins-jobs --conf /etc/jenkins_jobs/jenkins_jobs.ini update [--delete-old] /etc/jenkins_jobs/config
  jenkins-jobs delete-all

* Gearman jobs
::
  
  echo status | nc 127.0.0.1 4730 -w 1
  # a skippet for result
  # build:gate-horizon-selenium-headless	0	0	5
  # build:gate-neutron-lbaas-dashboard-dsvm-integration	0	0	5
  

The output of the status command contains tab separated columns with the following information.

  * Name: The name of the job.
  * Number in queue: The total number of jobs in the queue including the currently running ones (next column). 
  * Number of jobs running: The total number of jobs currently running. 
  * Number of capable workers: A maximum possible count of workers that can run this job. This number being zero is one reason zuul reports “NOT Registered”.

FAQ
====

During deploying CI master, series of bugs will be occurred. In this guide, it will summary the common problems.

Note: In this instruction, it is dafault that, a) don't need to add proxy to host, b) no limited for host to
connect to foreigin websites. Otherwise, there will be so many bugs caused by an unreachable network, and these
bugs are not listed in the following.

* database update failed

  * Description : the table structure in nodepool database is not match with model class in nodepool code.
  * Troubleshooting
  Nodepool code has been updated and database structure is changed.
  
  * Solution
  Delete the nodepool database in mysql, and create a new one. These tables in nodepool database will be create
  automatically.
  ::
  
    mysql> create database nodepool;
    mysql> GRANT ALL ON nodepool.* TO 'nodepool'@'localhost';
    mysql> flush privileges;
  
* nodepool image-build failed
  
  * NOTE: Most errors for image build failed, is caused by network. PLEASE MAKE SURE NETWORK IS NOT LIMITED.
  

* nodepool \** cmd no valid

  * Description : all nodepool cmd is unavailable, and no logs
  
  * Troubleshooting
  Before nodepool run its cmd, the job corresponding to the cmd must be registered. It can be checked used by gearman.
  If there are no registered jobs in Gearman, maybe, the reason is zuul service failed.
  
  * Solution
  check registered jobs : ``echo status| nc 127.0.0.1 4730 -w 1 ``
  restart zuul service: ``service zuul-merger restart``; ``service zuul restart``

* ci slave node created failed

  * ``NotFound: Floating ip pool not found. (HTTP 404) (Request-ID: req-dc5db0c4-7bfc-48a0-8fc6-85743d356c49)``
  
    * Solution: add ``pool`` option in nodepool.yaml
    * NOTE: This error only occurrs in early nodepool version, the lastest version has abandoned ``pool`` option.
  
  * ``SSHException: not a valid RSA private key file``
  
    * Solution
    The style of private key is wrong in common.yaml. 
    Detailed info is introduced in Common.yaml Section.

  * ``Exception: Timeout waiting for ssh access``
    
    * Solution
    The style of public key is wrong in common.yaml. 
    Detailed info is introduced in Common.yaml Section.

* slave node can not be registered in jenkins
  
  * Description: the started slave node can not be registered in Jenkins
    In general, once a slave node is started, it will be signed up to the node pool in the jenkins.
    But in this case, there is only cimaster node detected in the node pool.

  * TroubleShooting
  During starting slave node, nodepool will call "createJenkinsNode" API to add slave nodes to Jenkins according to
  ``targets:name`` config in nodepool.yaml. While the address of "Jenkins URL" is configured in secure.conf.
  The reason for this error is the ``targets:name`` is not consistent with the ``{target_name}`` in secure.conf.

  * Solution:
  make the ``targets:name`` in nodepool.yaml and ``{target_name}`` in secure.conf consistent.


* slave node is in 'outline' state in Jenkins
  
  * Troubleshooting
  Stare jenkins.jar failed in slave node, or lack jenkins.jar package
  
  * Solution
  download jenkins.jar package manually and start it.


* zuul merge failed

  * Description
  When add a new change for project to trigger jobs, this error is occurred
  
  * Error info
  ::
    
    2016-08-01 04:11:08,745 INFO zuul.MergeClient: Merge <gear.Job 0x7f0800119ed0 handle: H:127.0.0.1:35 name: merger:merge unique: a3891d60a231458f9b4a591053bd086d> complete, merged: False, updated: False, commit: None
    2016-08-01 04:11:08,748 INFO zuul.IndependentPipelineManager: Unable to merge change <Change 0x7f08001b7090 76,12>
    2016-08-01 04:11:08,749 INFO zuul.IndependentPipelineManager: Reporting item <QueueItem 0x7f0800113a90 for <Change 0x7f08001b7090 76,12> in check>, actions: [<zuul.reporter.gerrit.GerritReporter object at 0x7f0800163f90>]
    2016-08-01 04:11:08,752 ERROR zuul.source.Gerrit: Exception looking for ref refs/heads/master
    Traceback (most recent call last):
      File "/usr/local/lib/python2.7/dist-packages/zuul/source/gerrit.py", line 49, in getRefSha
        refs = self.connection.getInfoRefs(project)
      File "/usr/local/lib/python2.7/dist-packages/zuul/connection/gerrit.py", line 391, in getInfoRefs
        data = urllib.request.urlopen(url).read()
      File "/usr/lib/python2.7/urllib2.py", line 127, in urlopen
        return _opener.open(url, data, timeout)
      File "/usr/lib/python2.7/urllib2.py", line 404, in open
        response = self._open(req, data)
      File "/usr/lib/python2.7/urllib2.py", line 422, in _open
        '_open', req)
      File "/usr/lib/python2.7/urllib2.py", line 382, in _call_chain
        result = func(*args)
      File "/usr/lib/python2.7/urllib2.py", line 1222, in https_open
        return self.do_open(httplib.HTTPSConnection, req)
      File "/usr/lib/python2.7/urllib2.py", line 1184, in do_open
        raise URLError(err)
    URLError: <urlopen error [Errno 111] Connection refused>

  * Solution
  use the link of clone with commit-msg hook to git clone repo.
  ::
  
    #take "citest" repo for instance
    cd /var/lib/zuul/git/
    git clone ssh://green@10.63.243.3:29418/citest && scp -p -P 29418 green@10.63.243.3:hooks/commit-msg citest/.git/hooks/
    
  
* /etc/resolv.conf is repeatly overridden

  * Description: Although DNS has been added through calling ``ready-script``, the network is still unreachable.
  * Error info
  ::
    
    INFO:zuul.Cloner:Creating repo openstack/requirements from upstream git://git.openstack.org/openstack/requirements
    07:25:04 ERROR:zuul.Repo:Unable to initialize repo for git://git.openstack.org/openstack/requirements
    07:25:04 Traceback (most recent call last):
    07:25:04   File "/usr/zuul-env/src/zuul/zuul/merger/merger.py", line 53, in __init__
    07:25:04     self._ensure_cloned()
    07:25:04   File "/usr/zuul-env/src/zuul/zuul/merger/merger.py", line 65, in _ensure_cloned
    07:25:04     git.Repo.clone_from(self.remote_url, self.local_path)
    07:25:04   File "/usr/zuul-env/local/lib/python2.7/site-packages/git/repo/base.py", line 965, in clone_from
    07:25:04     return cls._clone(git, url, to_path, GitCmdObjectDB, progress, **kwargs)
    07:25:04   File "/usr/zuul-env/local/lib/python2.7/site-packages/git/repo/base.py", line 911, in _clone
    07:25:04     finalize_process(proc, stderr=stderr)
    07:25:04   File "/usr/zuul-env/local/lib/python2.7/site-packages/git/util.py", line 155, in finalize_process
    07:25:04     proc.wait(**kwargs)
    07:25:04   File "/usr/zuul-env/local/lib/python2.7/site-packages/git/cmd.py", line 332, in wait
    07:25:04     raise GitCommandError(self.args, status, errstr)
    07:25:04 GitCommandError: 'git clone -v git://git.openstack.org/openstack/requirements /tmp/tmp.7cHqiTG4U9' returned with exit code 128
    07:25:04 stderr: 'Cloning into '/tmp/tmp.7cHqiTG4U9'...
    07:25:04 fatal: unable to connect to git.openstack.org:
    07:25:04 git.openstack.org: Name or service not known
  
  * Troubleshooting
  DhClient will delete all DNS when release expire. So if only modify the /etc/resolv.conf, it will out of 
  operation after a release cycle. To resolve the issue, need to modify /sbin/dhclient-script which dhclient
  will call when dhclient sets each interface's initial configuration. It will override the default behaviour
  of the client in creating a /etc/resolv.conf file.
  
  * Solution
  add the following code in the head of ``ready-script``
  ::
  
    sudo sed -i -e '/mv -f $new_resolv_conf $resolv_conf/a\
        echo "nameserver 172.10.0.1" >> $resolv_conf' /sbin/dhclient-script
        
  **NOTE** This is not the best solution. The DNS server should be dynamically pushed into /etc/resolv.conf file.

* update ready-script failed

  * Troubleshooting
  mirror source is not stable, which lead to update image failed.

* gerrit can not receive the result of 'verified -1'

  * Troubleshooting
  Lack 'verified' permission for project access
  
* git review failed
  
  * Description: Create a repo in gerrit and then git review a new change to gerrit, it's failed
  * Error info
  ::
    
    opnfv@cimaster:/tmp/ci$ git review
    Errors running git rebase -i remotes/gerrit/master
    fatal: Needed a single revision
    invalid upstream remotes/gerrit/master
  
  * Solution
  Lack master branch for project in gerrit.
  According to 'set gerrit project access' subsection to create master branch.
  
* jenkins-jobs update failed
  
  * Failed to find suitable template named '###'
  
    * Description: jenkins-job update failed
    modify the jenkins jobs in the ./project-config/jenkins/jobs/projects.yaml, such as add/delete some project, and then execute `puppet apply`. The execution of `puppet apply` is failed and when running the 'jenkins-jobs update --delete-old /etc/jenkins_jobs/config` cmd, it fails too. 
    
    * Error Info
    ::
    
      root@cimaster:~# jenkins-jobs update --delete-old /etc/jenkins_jobs/config
      INFO:root:Updating jobs in ['/etc/jenkins_jobs/config'] ([])
      /usr/local/lib/python2.7/dist-packages/jenkins/_init_.py:644: DeprecationWarning: get_plugins_info() is deprecated, use get_plugins()
      DeprecationWarning)
      Traceback (most recent call last):
      File "/usr/local/bin/jenkins-jobs", line 10, in <module>
      sys.exit(main())
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/cli/entry.py", line 139, in main
      jjb.execute()
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/cli/entry.py", line 133, in execute
      jenkins_jobs.cmd.execute(self._options, self._config_file_values)
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/cmd.py", line 269, in execute
      n_workers=options.n_workers)
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/builder.py", line 349, in update_jobs
      self.parser.expandYaml(jobs_glob)
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/parser.py", line 266, in expandYaml
      .format(jobname))
      jenkins_jobs.errors.JenkinsJobsException: Failed to find suitable template named 'experimental-openstackci-beaker- {node}'
      
    * Troubleshooting
      the template named 'experimental-openstackci-beaker- {node}' is defined in ``projects.yaml``, but not be defined in
      YAML template file to explain what this template should do.
      
    * Solution
      create this template under ``/etc/jenkins-jobs/config/`` dir
  
  * Error in request. Possibly authentication failed [403]: Forbidden
    
    * Description: Modify projects.yaml and update jobs, failed
    * Error Info
    ::
    
      root@cimaster:/etc/jenkins_jobs/config# jenkins-jobs update --delete-old /etc/jenkins_jobs/config
    No handlers could be found for logger "jenkins_jobs.config"
    /usr/local/lib/python2.7/dist-packages/jenkins/__init__.py:644: DeprecationWarning: get_plugins_info() is deprecated, use get_plugins()
      DeprecationWarning)
    Traceback (most recent call last):
      File "/usr/local/bin/jenkins-jobs", line 10, in <module>
        sys.exit(main())
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/cli/entry.py", line 168, in main
        jjb.execute()
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/cli/entry.py", line 154, in execute
        n_workers=options.n_workers)
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/builder.py", line 303, in update_jobs
        self.parser = YamlParser(self.jjb_config, self.plugins_list)
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/builder.py", line 242, in plugins_list
        self._plugins_list = self.jenkins.get_plugins_info()
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/builder.py", line 205, in get_plugins_info
        raise e
    jenkins.JenkinsException: Error in request. Possibly authentication failed [403]: Forbidden

    * Troubleshooting
    * Solution
    when update jobs, assign config file: jenkins-jobs.ini
  
* jenkins jobs failed in slave node

  * Could not resolve host: git.openstack.org
    
    * Network is unavailable
