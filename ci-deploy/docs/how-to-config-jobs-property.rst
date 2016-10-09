

Customized personalized jobs
============================


"no-voting" property
--------------------

  add `voting: false` option for the job in "jobs" section.

::

  # openzero/releng/zuul/layout.yaml
  jobs:
    - name: $YOUR_JOB_NAME
      voting: false

"periodic" job
--------------

This kind of jobs can be triggered by timer.

* add a periodic pipeline

Note: this pipeline can be customized.

::

  # openzero/releng/zuul/layout.yaml
  - name: periodic-rd
    description: Jobs in this queue are triggered on a timer.
    manager: IndependentPipelineManager
    source: gerrit
    precedence: low
    trigger:
      timer:
        - time: '0 */4 * * *'

* put the job into the above pipeline under $YOUR_PROJECT

::

  # openzero/releng/zuul/layout.yaml
  projects:
    - name: "YOUR_PROJECT"
      periodic:
        - "$YOUR_JOB_NAME"



"post" job
----------

This kind of jobs can be triggered after each change is mergered.


* put the job into "post" pipeline

::

  # openzero/releng/zuul/layout.yaml
  projects:
    - name: "YOUR_PROJECT"
      post:
        - "$YOUR_JOB_NAME"


assign a job into a static slave node
---------------------------------------

To run a job on a static slave, it just need to appoint a "node" label
under the defination of job template.

But the value of "node" label must be consistented with the Label value
of slave node.

::

  # openzero/releng/jenkins/jobs/$YOUR_JOB_TEMPLATE_FILE.yaml
  - job-template:
      name: '{name}-verified-flow'
      node: $SLAVE_NODE_LABEL


