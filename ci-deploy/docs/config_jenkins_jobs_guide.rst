Jenkins Jobs Configuration Guide
********************************

Git Clone Repo
==============

Use the link with commit-msg hook to git clone "openzero/releng" repo
from Gerrit.


Jobs Configuration Files
========================

Take "add citest project jobs" for instance.

Generally, to add project jobs, three files will be affacted.

Add jobs list of "citest" project in layout.yaml
--------------------------------------------------------

./zuul/layout.yaml

::

  # projects:
  - name: citest
    template:
      - name: merge-check
    ## which jobs will be run, if check pipeline is triggered.
    check:
      - citest-verified-flow
    ## which jobs will be run, if gate pipeline is triggered.
    gate:
      - citest-verified-flow

Add job template of "citest" project in projects.yaml
-----------------------------------------------------

./jenkins/jobs/projects.yaml

::

  - project:
    name: citest
    jobs:
      - {name}-verified-flow

Add detailed description of job template
----------------------------------------

./jenkins/jobs/citest.yaml

::

  job-template:
    name: {name}-verified-flow
    builders:
      - shell: |
          cat /etc/resolv.conf
    publishers:
      - console-log


Push a new change
------------------

After the above three files modified and merged, these new Jenkins jobs
should be registered in Gearman and Jenkins.

Then, git clone "citest" project and push a new change to trigger jobs.

::

  git add .
  git commit
  git review
