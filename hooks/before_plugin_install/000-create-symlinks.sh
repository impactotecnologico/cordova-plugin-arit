#!/bin/sh
pushd plugins/net.it.arit.plugin/src/ios/CatchroomSDK/CraftARAugmentedRealitySDK.framework
ln -s -f Versions/A/Headers/ Headers
ln -s -f Versions/A/CraftARAugmentedRealitySDK CraftARAugmentedRealitySDK
cd Versions
ln -s -f A Current
cd -
popd

pushd plugins/net.it.arit.plugin/src/ios/CatchroomSDK/Pods.framework
ln -s -f Versions/A/Headers/ Headers
ln -s -f Versions/A/Pods Pods
cd Versions
ln -s -f A Current
cd -
popd
