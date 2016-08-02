
CI Deploy User Guide
====================

This instruction will guide user to deploy a (Openstack) CI environment. The workflow of
deploying CI has been introduced in `Openstack Third-part CI <http://docs.openstack.org/infra/openstackci/third_party_ci.html>`_ . Please read it.

Now, according to the `Openstack Third-part CI <http://docs.openstack.org/infra/openstackci/third_party_ci.html>`_ , a script is drafted to deploy ci master node automatically. User can find this script in ``../code/deploy-cimaster-with-proxy.sh``.

Before run the above script, serveral files need to be prepared in advance.

Assuming: the CI master is deployed in a VM.

common.yaml
-----------------------------


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


* nodepool image-build failed
* nodepool \** cmd no valid
* ci slave node created failed
* slave node can not be registered in jenkins
* slave node is outline in jenkins
* jjb 
