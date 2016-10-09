Reference
##########

Common Command
==============

* puppet command

::

  sudo puppet apply --verbose /etc/puppet/manifests/site.pp

* Nodepool command

::

  # build image
  sudo su - nodepool
  source /etc/default/nodepool
  nodepool image-build $IMAGE_NAME

  # upload image to OpenStack env
  sudo su - nodepool
  source /etc/default/nodepool
  nodepool image-upload all #IMAGE_NAME

  # update and upload image
  sudo su - nodepool
  source /etc/default/nodepool
  nodepool image-update all $IMAGE_NAME

* Jenkins command

::

  $ sudo jenkins-jobs [--conf /etc/jenkins_jobs/jenkins_jobs.ini] update \
  [--delete-old] /etc/jenkins_jobs/config

* Gearman jobs

::

  echo status | nc 127.0.0.1 4730 -w 1
  # a skippet for result
  # build:gate-horizon-selenium-headless    0    0    5
  # build:gate-neutron-lbaas-dashboard-dsvm-integration    0    0    5


The output of the status command contains tab separated columns with the
following information.

  * Name: The name of the job.
  * Number in queue: The total number of jobs in the queue including the
    currently running ones (next column).

  * Number of jobs running: The total number of jobs currently running.
  * Number of capable workers: A maximum possible count of workers that can
    run this job. This number being zero is one reason zuul reports
    "NOT Registered".

FAQ
====

During deploying CI master, series of bugs will be occurred. In this guide,
it will summary the common problems.

**Note**

In this instruction, it has the prerequisite that:

* don't need to add proxy to host
* no limited for host to connect to foreigin websites.

Otherwise, there will be so many bugs caused by an unreachable network, and
these bugs are not listed in the following.

* database update failed

  * Description
    The table structure in Nodepool database is not match with model class
    in Nodepool code.

  * Troubleshooting
    Nodepool code has been updated and database structure is changed.

  * Solution
    Delete the Nodepool database in mysql, and create a new one. These tables
    in Nodepool database will be create automatically.

  ::

    mysql> create database nodepool;
    mysql> GRANT ALL ON nodepool.* TO 'nodepool'@'localhost';
    mysql> flush privileges;

* Nodepool image-build failed

  * NOTE: Most errors for image build failed, is caused by network.
    PLEASE MAKE SURE NETWORK IS NOT LIMITED.


* Nodepool \** cmd no valid

  * Description
    All Nodepool cmd is unavailable, and no logs

  * Troubleshooting
    Before Nodepool runs its cmd, the job corresponding to the cmd must be
    registered. It can be checked used by Gearman.
    If there are no registered jobs in Gearman, maybe, the reason is Zuul
    service failed.

  * Solution

  ::

    check registered jobs : ``echo status| nc 127.0.0.1 4730 -w 1``
    restart Zuul service: ``service zuul-merger restart``; ``service zuul restart``

* launch CI slave node failed

  * ``NotFound: Floating ip pool not found. (HTTP 404) (Request-ID:
    req-dc5db0c4-7bfc-48a0-8fc6-85743d356c49)``

    * Solution: add ``pool`` option in nodepool.yaml
    * NOTE: This error only occurrs in early Nodepool version, the lastest
      version has abandoned ``pool`` option.

  * ``SSHException: not a valid RSA private key file``

    * Solution
      The style of private key is wrong in common.yaml.
      Detailed info is introduced in Common.yaml Section.

  * ``Exception: Timeout waiting for ssh access``

    * Solution
    The style of public key is wrong in common.yaml.
    Detailed info is introduced in Common.yaml Section.

  * After slave VM started, Nodepool fails to ssh to slave because of timout

    * Log Info

    ::

      2016-07-03 21:03:46,284 ERROR nodepool.utils: Exception while testing ssh access:
      Traceback (most recent call last):
      File "/usr/local/lib/python2.7/dist-packages/nodepool/nodeutils.py", line 55,
      in ssh_connect client = SSHClient(ip, username, **connect_kwargs)
      File "/usr/local/lib/python2.7/dist-packages/nodepool/sshclient.py", line 30,
      in _init_ key_filename=key_filename)
      File "/usr/local/lib/python2.7/dist-packages/paramiko/client.py", line 305,
      in connect retry_on_signal(lambda: sock.connect(addr))
      File "/usr/local/lib/python2.7/dist-packages/paramiko/util.py", line 270,
      in retry_on_signal return function()
      File "/usr/local/lib/python2.7/dist-packages/paramiko/client.py", line 305,
      in <lambda> retry_on_signal(lambda: sock.connect(addr))
      File "/usr/lib/python2.7/socket.py", line 224, in meth
      return getattr(self._sock,name)(*args)
      error: [Errno 110] Connection timed out

    * Troubleshooting
      After starting a vm node, it needs to download the Flow Table, but the
      speed of download is very very slow, whose time is much larger than the
      "timeout" value. (the default value of "timeout" is **60 seconds**)

    * Solution
      expand the ``timeout`` option in nodepool.yaml

  * Fail to start slave node because of binding failed to port

    * Error Info

    ::

      OpenStackCloudException: ('Error in creating the server: Exceeded maximum
      number of retries. Exceeded max scheduling attempts 3 for instance
      71140bf1-fa48-44f1-b73c-8511dce1da0c. Last exception: Binding failed for port
      59b81292-e5d5-4b06-a8e0-55c2d8bd473a, please check neutron logs for more
      information.', {'server': Munch({'OS-EXT-STS:task_state': None, 'addresses': {},
      'image': {u'id': u'e8d04018-e586-478a-9437-4b97a5b05434'}, 'networks': {},
      'OS-EXT-STS:vm_state': u'error', 'OS-EXT-SRV-ATTR:instance_name':
      u'instance-000003e5', 'OS-SRV-USG:launched_at': None, 'NAME_ATTR': 'name',
      'flavor': {u'id': u'4'}, 'id': u'71140bf1-fa48-44f1-b73c-8511dce1da0c',
      'cloud': 'defaults', 'user_id': u'28e38e4ec3064402b0c48249ef8587ba',
      'OS-DCF:diskConfig': u'MANUAL', 'HUMAN_ID': True, 'accessIPv4': '', 'accessIPv6':
      '', 'public_v4': '', 'OS-EXT-STS:power_state': 0, 'OS-EXT-AZ:availability_zone':
      u'', 'config_drive': u'', 'status': u'ERROR', 'updated': u'2016-06-30T12:28:08Z',
      'hostId': u'', 'OS-EXT-SRV-ATTR:host': None, 'OS-SRV-USG:terminated_at': None,
      'key_name': None, 'public_v6': '', 'request_ids': [], 'private_v4': '',
      'interface_ip': '', 'OS-EXT-SRV-ATTR:hypervisor_hostname': None, 'name':
      u'ubuntu-trusty-zte-RegionOne-1780', 'created': u'2016-06-30T12:25:02Z', 'fault':
      {u'message': u'Exceeded maximum number of retries. Exceeded max scheduling attempts
      3 for instance 71140bf1-fa48-44f1-b73c-8511dce1da0c. Last exception: Binding
      failed for port 59b81292-e5d5-4b06-a8e0-55c2d8bd473a, please check neutron logs
      for more information.', u'code': 500, u'details': u' File "/usr/lib/python2.7/
      dist-packages/nova/conductor/manager.py", line 393, in build_instances\n
      filter_properties, instances[0].uuid)\n File "/usr/lib/python2.7/dist-packages/
      nova/scheduler/utils.py", line 186, in populate_retry\n raise
      exception.MaxRetriesExceeded(reason=msg)\n', u'created': u'2016-06-30T12:28:08Z'}
      , 'region': 'RegionOne', 'x_openstack_request_ids': [], 'os-extended-volumes:
      volumes_attached': [], 'volumes': [], 'tenant_id': '056a9a90a90845dba5eb4fa807',
      'metadata': Unknown macro: {u'groups'}, 'human_id':
      u'ubuntu-trusty-zte-regionone-1780'})})

    * Troubleshooting
      When starting slave node, only need to config internal network config,
      no floating network.

    * Solution
      Delete Floating Network config in nodepool.yaml

* slave node can not be registered in Jenkins

  * Description
    The started slave node can not be registered in Jenkins.
    In general, once a slave node is started, it will be signed up to the node
    pool in the Jenkins. But in this case, there is only cimaster node detected
    in the node pool.

  * Troubleshooting
    During starting slave node, Nodepool will call "createJenkinsNode" API to
    add slave nodes to Jenkins according to ``targets:name`` config in
    nodepool.yaml. While the address of "Jenkins URL" is configured in
    secure.conf. The reason for this error is the ``targets:name`` is not
    consistent with the ``{target_name}`` in secure.conf.

  * Solution:
    make the ``targets:name`` in nodepool.yaml and ``{target_name}`` in
    secure.conf consistent.


* slave node is in 'outline' state in Jenkins

  * Troubleshooting
    Start jenkins.jar failed in slave node, or lack jenkins.jar package

  * Solution
    download jenkins.jar package manually and start it.

* update ready-script failed

  * Troubleshooting
    mirror source is not stable, which lead to update image failed.

* Gerrit can not receive the result of 'verified -1'

  * Troubleshooting
    Lack 'verified' permission for project access

* git review failed

  * Description
    Create a repo in Gerrit and then git review a new change to Gerrit,
    it's failed.

  * Error info

  ::

    opnfv@cimaster:/tmp/ci$ git review
    Errors running git rebase -i remotes/gerrit/master
    fatal: Needed a single revision
    invalid upstream remotes/gerrit/master

  * Solution
    Lack master branch for project in Gerrit.
    According to 'set gerrit project access' subsection to create master branch.

* jenkins-jobs update failed

  * Failed to find suitable template named '###'

    * Description: jenkins-job update failed
      modify Jenkins jobs in the ./releng/jenkins/jobs/projects.yaml,
      such as add/delete some project, and then execute `puppet apply`. The
      execution of `puppet apply` is failed and when running the `jenkins-jobs
      update --delete-old /etc/jenkins_jobs/config` cmd, it fails too.

    * Error Info

    ::

      root@cimaster:~# jenkins-jobs update --delete-old /etc/jenkins_jobs/config
      INFO:root:Updating jobs in ['/etc/jenkins_jobs/config'] ([])
      /usr/local/lib/python2.7/dist-packages/jenkins/_init_.py:644:
      DeprecationWarning: get_plugins_info() is deprecated, use get_plugins()
      DeprecationWarning)
      Traceback (most recent call last):
      File "/usr/local/bin/jenkins-jobs", line 10, in <module>
      sys.exit(main())
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/cli/entry.py",
      line 139, in main jjb.execute()
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/cli/entry.py", line 133,
      in execute jenkins_jobs.cmd.execute(self._options, self._config_file_values)
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/cmd.py", line 269, in
      execute n_workers=options.n_workers)
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/builder.py", line 349,
      in update_jobs self.parser.expandYaml(jobs_glob)
      File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/parser.py", line 266,
      in expandYaml.format(jobname))
      jenkins_jobs.errors.JenkinsJobsException: Failed to find suitable template
      named 'experimental-openstackci-beaker- {node}'

    * Troubleshooting
      The template named 'experimental-openstackci-beaker-{node}' is just declared
      in ``projects.yaml``, but not be defined in YAML template file to explain
      what this template should do.

    * Solution
      create this template under ``/etc/jenkins-jobs/config/`` dir

  * Error in request. Possibly authentication failed [403]: Forbidden

    * Description: Modify projects.yaml and update jobs, failed
    * Error Info

    ::

      root@cimaster:# jenkins-jobs update --delete-old /etc/jenkins_jobs/config
      No handlers could be found for logger "jenkins_jobs.config"
      /usr/local/lib/python2.7/dist-packages/jenkins/__init__.py:644:
        DeprecationWarning: get_plugins_info() is deprecated, use get_plugins()
        DeprecationWarning)
      Traceback (most recent call last):
        File "/usr/local/bin/jenkins-jobs", line 10, in <module>
          sys.exit(main())
        File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/cli/entry.py",
          line 168, in main jjb.execute()
        File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/cli/entry.py",
          line 154, in execute n_workers=options.n_workers)
        File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/builder.py",
          line 303, in update_jobs self.parser = YamlParser(self.jjb_config,
          self.plugins_list)
        File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/builder.py", line
          242, in plugins_list self._plugins_list = self.jenkins.get_plugins_info()
        File "/usr/local/lib/python2.7/dist-packages/jenkins_jobs/builder.py", line
          205, in get_plugins_info raise e jenkins.JenkinsException: Error in
          request. Possibly authentication failed [403]: Forbidden

    * Troubleshooting
    The Request object, used to get plugins info, is lack of cookies, which
    lead to be rejected.

    * Solution
    when update jobs, assign config file: jenkins-jobs.ini

* Jenkins jobs failed in slave node

  * Could not resolve host: git.openstack.org

    * Network is unavailable

  * /etc/resolv.conf is repeatly overridden

    * Description
      Although DNS has been added through calling ``ready-script``, the network
      is still unreachable.

    * Error info

    ::

      INFO:zuul.Cloner:Creating repo openstack/requirements from upstream
         git://git.openstack.org/openstack/requirements
      07:25:04 ERROR:zuul.Repo:Unable to initialize repo for
         git://git.openstack.org/openstack/requirements
      07:25:04 Traceback (most recent call last):
      07:25:04   File "/usr/zuul-env/src/zuul/zuul/merger/merger.py", line 53, in __init__
      07:25:04     self._ensure_cloned()
      07:25:04   File "/usr/zuul-env/src/zuul/zuul/merger/merger.py", line 65, in _ensure_cloned
      07:25:04     git.Repo.clone_from(self.remote_url, self.local_path)
      07:25:04   File "/usr/zuul-env/local/lib/python2.7/site-packages/git/repo/base.py",
         line 965, in clone_from
      07:25:04     return cls._clone(git, url, to_path, GitCmdObjectDB, progress, **kwargs)
      07:25:04   File "/usr/zuul-env/local/lib/python2.7/site-packages/git/repo/base.py",
         line 911, in _clone
      07:25:04     finalize_process(proc, stderr=stderr)
      07:25:04   File "/usr/zuul-env/local/lib/python2.7/site-packages/git/util.py", line 155,
         in finalize_process
      07:25:04     proc.wait(**kwargs)
      07:25:04   File "/usr/zuul-env/local/lib/python2.7/site-packages/git/cmd.py", line 332,
         in wait
      07:25:04     raise GitCommandError(self.args, status, errstr)
      07:25:04 GitCommandError: 'git clone -v git://git.openstack.org/openstack/requirements
         /tmp/tmp.7cHqiTG4U9' returned with exit code 128
      07:25:04 stderr: 'Cloning into '/tmp/tmp.7cHqiTG4U9'...
      07:25:04 fatal: unable to connect to git.openstack.org:
      07:25:04 git.openstack.org: Name or service not known

    * Troubleshooting
    DhClient will delete all DNS when release expire. So if only modify the
    /etc/resolv.conf, it will out of operation after a release cycle. To
    resolve the issue, need to modify /sbin/dhclient-script which dhclient
    will call when dhclient sets each interface's initial configuration. It
    will override the default behaviour of the client in creating a
    /etc/resolv.conf file.

    * Solution
    add the following code in the head of ``ready-script``

    ::

      sudo sed -i -e '/mv -f $new_resolv_conf $resolv_conf/a\
          echo "nameserver 172.10.0.1" >> $resolv_conf' /sbin/dhclient-script

    **NOTE**
    This is not the best solution. The DNS server should be dynamically pushed
    into /etc/resolv.conf file.

  * can not trigger Jenkins jobs because of Zuul merge failed

    * Description
    When add a new change for project to trigger jobs, this error is occurred

    * Error info

    ::

      2016-08-01 04:11:08,745 INFO zuul.MergeClient: Merge <gear.Job 0x7f0800119ed0
         handle: H:127.0.0.1:35 name: merger:merge unique: a3891d60a231458f9b4a591053bd086d>
         complete, merged: False, updated: False, commit: None
      2016-08-01 04:11:08,748 INFO zuul.IndependentPipelineManager: Unable to merge change
         <Change 0x7f08001b7090 76,12>
      2016-08-01 04:11:08,749 INFO zuul.IndependentPipelineManager: Reporting item
         <QueueItem 0x7f0800113a90 for <Change 0x7f08001b7090 76,12> in check>, actions:
         [<zuul.reporter.gerrit.GerritReporter object at 0x7f0800163f90>]
      2016-08-01 04:11:08,752 ERROR zuul.source.Gerrit: Exception looking for ref
         refs/heads/master
      Traceback (most recent call last):
        File "/usr/local/lib/python2.7/dist-packages/zuul/source/gerrit.py", line 49,
          in getRefSha refs = self.connection.getInfoRefs(project)
        File "/usr/local/lib/python2.7/dist-packages/zuul/connection/gerrit.py", line
          391, in getInfoRefs data = urllib.request.urlopen(url).read()
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
    add "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" options
    into the code of zuul/merger/merger.py, and then restart zuul-merger service.

    ::

      #/usr/local/lib/python2.7/dist-packages/zuul/merger/merger.py
      #fd.write('ssh -i %s $@\n' % key)
      fd.write('ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i %s $@\n' % key)


  * can not trigger Jenkins jobs because of job not registered

    * Error Info

    ::

      2016-08-01 10:18:55,007 ERROR zuul.Gearman: Job <gear.Job 0x7fad4ce77150 handle:
         None name: citest-verified-flow unique: 80879edb4ee64546a87efc63bdb2486a>
         is not registered with Gearman
      2016-08-01 10:18:55,008 INFO zuul.Gearman: Build <gear.Job 0x7fad4ce77150 handle:
         None name: citest-verified-flow unique: 80879edb4ee64546a87efc63bdb2486a>
         complete, result NOT_REGISTERED

    * Troubleshooting
    The job, citest-verified-flow, is not registered with Gearman.
    Gearman only registers jobs which are defined in ``/etc/zuul/layout/layout.yaml`` file.
    Check whether the defination and style of jobs are right.

    * Solution
    Modify the style of jobs in ``layout.yaml``.
    Call ``jenkins-jobs update`` and  restart zuul service.

  * cimaster node is offline in Jenkins after a job runs on a slave node

    * Error Info

    ::

      Building on master in workspace /var/lib/jenkins/workspace/bifrost-provision-daily-master
      [bifrost-provision-daily-master] $ /bin/bash /tmp/hudson7357862238037084303.sh
      sudo: no tty present and no askpass program specified
      Build step 'Execute shell' marked build as failure
      Finished: FAILURE

    * Solution
    Add the "node" label for the job.


  * can not get ZUUL_* env variables in slave node

    * Troubleshooting
    This is a Jenkins version bug
      > You might be affected by the fix to SECURITY-170 in new Jenkins
      > you installed. It prevents Zuul from passing paramters that are not
      > white listed. Which version of Jenkins are you using? Last version
      > without the security fix is 1.651.1.

      > If you have later version, you would need to either white list all
      > zuul variables (
      > -Dhudson.model.ParametersAction.safeParameters=ZUUL_URL,ZUUL_COMMIT ),
      > or disable that security feature (
      > -Dhudson.model.ParametersAction.keepUndefinedParameters=true ).

    * Solution

    ::

       # /etc/default/jenkins
       JAVA_ARGS="-Xloggc:/var/log/jenkins/gc.log -XX:+PrintGCDetails
       -Xmx12g -Dorg.kohsuke.stapler.compression.CompressionFilter.disabled=true
       -Djava.util.logging.config.file=/var/lib/jenkins/logger.conf"
       # disable the security feature
       JAVA_ARGS="$JAVA_ARGS -Dhudson.model.ParametersAction.keepUndefinedParameters=true"


