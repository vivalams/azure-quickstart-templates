#!/bin/bash
# Copyright (c) Microsoft Corporation. All Rights Reserved.
# Licensed under the MIT license. See LICENSE file on the project webpage for details.

set -x

EDX_VERSION="named-release/dogwood.rc"

# Run edX bootstrap
ANSIBLE_ROOT=/edx/app/edx_ansible
CONFIGURATION_REPO=https://github.com/edx/configuration.git
CONFIGURATION_VERSION=$EDX_VERSION
wget https://raw.githubusercontent.com/edx/configuration/master/util/install/ansible-bootstrap.sh -O- | bash

# Stage configuration files
PLATFORM_REPO=https://github.com/edx/edx-platform.git
PLATFORM_VERSION=$EDX_VERSION

bash -c "cat <<EOF >extra-vars.yml
---
edx_platform_repo: \"$PLATFORM_REPO\"
edx_platform_version: \"$PLATFORM_VERSION\"
edx_ansible_source_repo: \"$CONFIGURATION_REPO\"
configuration_version: \"$CONFIGURATION_VERSION\"
certs_version: \"$EDX_VERSION\"
forum_version: \"$EDX_VERSION\"
xqueue_version: \"$EDX_VERSION\"
COMMON_SSH_PASSWORD_AUTH: \"yes\"
EOF"
sudo -u edx-ansible cp *.yml $ANSIBLE_ROOT

# Install edX platform
cd /tmp && git clone $CONFIGURATION_REPO configuration
cd configuration && git checkout $CONFIGURATION_VERSION
pip install -r requirements.txt
cd playbooks && ansible-playbook -i localhost, -c local vagrant-devstack.yml -e@$ANSIBLE_ROOT/extra-vars.yml

#cd $ANSIBLE_ROOT/edx_ansible && git checkout $CONFIGURATION_VERSION
#pip install -r requirements.txt
#cd playbooks && ansible-playbook -i localhost, -c local vagrant-devstack.yml -e@$ANSIBLE_ROOT/extra-vars.yml