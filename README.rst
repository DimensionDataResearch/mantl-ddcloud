Mantl integration for CloudControl
==================================

This repository contains Mantl customisations required to run it on Dimension Data CloudControl. We're actually `working on merging this work back into the original Mantl repository <https://github.com/DimensionDataResearch/mantl/tree/ddcloud/initial>`_ but that's still a work-in-progress.

I'll document this process when I get a chance; it works, but it's still a tiny bit manual for now.

Requirements
------------

* Linux or OSX only (sorry, but I haven't had time to build cross-platform scripts yet).
* Python 2.7
* Ansible 1.8 or higher (run ``pip install -r mantl/requirements.txt``).
* Terraform 0.7-rc2 or higher.
* The `ddcloud provider <https://github.com/DimensionDataResearch/dd-cloud-compute-terraform>`_ for Terraform.
* An AWS hosted DNS zone.
* AWS credentials that can manage entries in that zone.
* CloudControl credentials.
* SSH keypair stored in ``~/.ssh/id_rsa``.

Getting started
---------------

You'll want to customise `<terraform/mantl.tf>`_ and `<mantl.yml>`_ with the correct values for your configuration.
Run ``build-cluster-step1.sh`` and follow the instructions.
