#!/usr/bin/env bash

set -ex

eval $(minikube docker-env)
echo "Building new kube-apiserver image ..."
docker build -t kube-apiserver -f dockerfiles/kube-apiserver bazel-bin/cmd/kube-apiserver/linux_amd64_pure_stripped/
echo "Replacing current kube-apiserver image with new image ..."
minikube ssh -- sudo sed -i 's/image:.*/image:\ kube-apiserver:latest/' /etc/kubernetes/manifests/kube-apiserver.yaml
echo "Removing old docker container ..."
sleep 3
DOCKER_CONTAINER_NAME=$(minikube ssh -- docker ps --format {{.Names}} | grep k8s_kube-apiserver)
minikube ssh -- docker stop $DOCKER_CONTAINER_NAME
minikube ssh -- docker rm $DOCKER_CONTAINER_NAME
