#!/bin/bash

/usr/bin/tini -s /opt/conda/bin/python3.11 -- /usr/local/bin/jupyterhub-singleuser "$@" --debug
