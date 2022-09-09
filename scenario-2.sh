#!/usr/bin/env bash

shopt -s expand_aliases
alias k='kubectl'

#
# End to end scenario 2
#
./kcp.sh stop
rm -rf _tmp/
./kcp.sh install -v 0.8.2
./kcp.sh start

# Cluster 1 => color: green label
kind delete cluster --name cluster1
kind create cluster --name cluster1

# Cluster 2 => color: blue label
kind delete cluster --name cluster2
kind create cluster --name cluster2

tail -f _tmp/kcp-output.log | while read LOGLINE
do
   [[ "${LOGLINE}" == *"finished bootstrapping root workspace phase 1"* ]] && pkill -P $$ tail
done
echo "KCP is started :-)"

#echo ">> KUBECONFIG=_tmp/.kcp/admin.kubeconfig k kcp ws ."
#KUBECONFIG=_tmp/.kcp/admin.kubeconfig k kcp ws .
#echo ">> KUBECONFIG=_tmp/.kcp/admin.kubeconfig k kcp ws create my-org --enter"
#KUBECONFIG=_tmp/.kcp/admin.kubeconfig k kcp ws create my-org --enter

kubectl ctx kind-cluster1
./kcp.sh syncer -w my-org -c cluster1

kubectl ctx kind-cluster2
./kcp.sh syncer -w my-org -c cluster2

KUBECONFIG=_tmp/.kcp/admin.kubeconfig k kcp ws root:my-org
KUBECONFIG=_tmp/.kcp/admin.kubeconfig k label synctarget cluster1 color=green
KUBECONFIG=_tmp/.kcp/admin.kubeconfig k label synctarget cluster2 color=blue

KUBECONFIG=_tmp/.kcp/admin.kubeconfig k delete placement,location --all
KUBECONFIG=_tmp/.kcp/admin.kubeconfig k apply -f ./k8s

#KUBECONFIG=_tmp/.kcp/admin.kubeconfig k get placement,location,synctarget -A
#KUBECONFIG=_tmp/.kcp/admin.kubeconfig k kcp ws ..

./demo.sh s1



