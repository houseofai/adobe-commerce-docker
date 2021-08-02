#!/bin/bash

MAGENTO_VERSION=2.4.1-p1

echo "Building Magento Enterprise version"
docker build -t odyssee/magento:$MAGENTO_VERSION-ee --build-arg mode=enterprise .
echo "Pushing Magento Enterprise version"
docker push odyssee/magento:$MAGENTO_VERSION-ee

# Community version
echo "Building Magento Community version"
docker build -t odyssee/magento:$MAGENTO_VERSION-ce .
echo "Pushing Magento Community version"
docker push odyssee/magento:$MAGENTO_VERSION-ce

# Enterprise - Luma Sample version
echo "Building Magento Enterprise Luma version"
docker build -t odyssee/magento-luma:$MAGENTO_VERSION-ee -f Dockerfile-luma --build-arg mode=ee --build-arg MAGENTO_VERSION=$MAGENTO_VERSION .
echo "Pushing Magento Enterprise Luma version"
docker push odyssee/magento-luma:$MAGENTO_VERSION-ee

# Community - Luma Sample version
echo "Building Magento Community Luma version"
docker build -t odyssee/magento-luma:$MAGENTO_VERSION-ce -f Dockerfile-luma --build-arg MAGENTO_VERSION=$MAGENTO_VERSION .
echo "Pushing Magento Community Luma version"
docker push odyssee/magento-luma:$MAGENTO_VERSION-ce

# Enterprise - Venia Sample version
echo "Building Magento Enterprise Luma version"
docker build -t odyssee/magento-pwa-venia:$MAGENTO_VERSION-ee -f Dockerfile-pwa-venia --build-arg mode=ee --build-arg MAGENTO_VERSION=$MAGENTO_VERSION .
echo "Pushing Magento Enterprise Luma version"
docker push odyssee/magento-pwa-venia:$MAGENTO_VERSION-ee

# Community - Venia Sample version
echo "Building Magento Community Luma version"
docker build -t odyssee/magento-pwa-venia:$MAGENTO_VERSION-ce -f Dockerfile-pwa-venia --build-arg MAGENTO_VERSION=$MAGENTO_VERSION .
echo "Pushing Magento Community Luma version"
docker push odyssee/magento-pwa-venia:$MAGENTO_VERSION-ce
