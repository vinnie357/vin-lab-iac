f5-cis
=========

## Use this script to automatically: 
## 1- Deploy F5 CC 
## 2- Deploy our frontend-app using BIG-IP 
## 3- Deploy our ASPs
## 4- Replace kube-proxy
## 5- Deploy our backend application using ASP

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: f5-cis,
                vars:
                        bigips:
                            - mgmt: 192.168.20.34
                            self: 192.168.3.34
                            - mgmt: 192.168.20.35
                            self: 192.168.3.35
                        network:
                            calico: true
                            flannel: false
                        provider?
                        creds:
                            bigip:
                                user:
                                pass:
                            sshKey:
         }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
