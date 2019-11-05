#!/bin/bash
virtualenv -p python2.7 --no-site-packages $INFRASTRUCTURE_ROOT_DIR/p-env
source $INFRASTRUCTURE_ROOT_DIR/p-env/bin/activate
pip install -r $INFRASTRUCTURE_ROOT_DIR/molecule/requirements.txt

