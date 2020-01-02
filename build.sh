#!/usr/bin/env bash
set -eE

MODULE_NAME=$(basename $(pwd))
COMMIT=$(git rev-parse HEAD)
TMP_DIR="/tmp/stack-${COMMIT}"
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"
trap "rm -rf ${TMP_DIR}" EXIT

cp -a . "${TMP_DIR}"
cd ${TMP_DIR}
chmod +x kubebuilder
GO111MODULE=on

go mod init "${MODULE_NAME}"
./kubebuilder init --domain resourcepacks.crossplane.io
./kubebuilder create api \
  --controller=true \
  --example=true \
  --group gcp \
  --version v1alpha1 \
  --kind MinimalGCP \
  --make=true \
  --namespaced=false \
  --resource=true

make manifests

kubectl crossplane stack init --cluster "muvaf/${MODULE_NAME}"
echo "COPY resources/ resources/" >> stack.Dockerfile
kubectl crossplane stack build
