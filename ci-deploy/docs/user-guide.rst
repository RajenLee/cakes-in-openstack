
CI Deploy User Guide
====================

This instruction will guide user to deploy a (Openstack) CI environment. The workflow of
deploying CI has been introduced in `Openstack Third-part CI <http://docs.openstack.org/infra/openstackci/third_party_ci.html>`_ . Please read it.

Now, according to the `Openstack Third-part CI <http://docs.openstack.org/infra/openstackci/third_party_ci.html>`_ , a script is drafted to deploy ci master node automatically. User can find this script in ``../code/deploy-cimaster-with-proxy.sh``.

Before run the above script, serveral files need to be prepared in advance.

common.yaml
-----------------------------


project-config repo (nodepool.yaml)
-----------------------------------



FAQ
====

During deploying CI master, series of bugs will be occurred. In this guide, it will summary the common problems.

* nodepool image-build failed
* 
