#!/usr/bin/env bash

curl  -v  -s -L "http://localhost:7777/rdirienzo/watchjob/processes/DeployProcess/jobs/$1" -H "accept: application/json"