#!/bin/bash -e

export INTERFACE=$1
echo ${X7WORKDIR:?"need set X7WORKDIR first"}

cd $X7WORKDIR/x7_fai
./setup.sh $1
cd $X7WORKDIR/x7
./mk cache
cd $X7WORKDIR/x7/devstack
./init.sh srv
./stack.sh
exit 1
