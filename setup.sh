#!/usr/bin/env bash

mkdir -vp modules
pip install -r requirements.txt --target=modules/ pyyaml
