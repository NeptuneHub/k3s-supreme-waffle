# Introduction
Jellyfin enable you to streaming video from your server. This guide was based on the intel GPU integrated on I5-8400T

# Install driver and coded

Before deploy jellyfin on K3S you first need to install the video driver.
```
sudo apt update
sudo apt install -y intel-media-va-driver-non-free vainfo
```

Then check with this command:
```
sudo vainfo
```

you should have an output like this:

```
error: XDG_RUNTIME_DIR is invalid or not set in the environment.
error: can't connect to X server!
libva info: VA-API version 1.20.0
libva info: Trying to open /usr/lib/x86_64-linux-gnu/dri/iHD_drv_video.so
libva info: Found init function __vaDriverInit_1_20
libva info: va_openDriver() returns 0
vainfo: VA-API version: 1.20 (libva 2.12.0)
vainfo: Driver version: Intel iHD driver for Intel(R) Gen Graphics - 24.1.0 ()
vainfo: Supported profile and entrypoints
      VAProfileNone                   : VAEntrypointVideoProc
      VAProfileNone                   : VAEntrypointStats
      VAProfileMPEG2Simple            : VAEntrypointVLD
      VAProfileMPEG2Simple            : VAEntrypointEncSlice
      VAProfileMPEG2Main              : VAEntrypointVLD
      VAProfileMPEG2Main              : VAEntrypointEncSlice
      VAProfileH264Main               : VAEntrypointVLD
      VAProfileH264Main               : VAEntrypointEncSlice
      VAProfileH264Main               : VAEntrypointFEI
      VAProfileH264Main               : VAEntrypointEncSliceLP
      VAProfileH264High               : VAEntrypointVLD
      VAProfileH264High               : VAEntrypointEncSlice
      VAProfileH264High               : VAEntrypointFEI
      VAProfileH264High               : VAEntrypointEncSliceLP
      VAProfileVC1Simple              : VAEntrypointVLD
      VAProfileVC1Main                : VAEntrypointVLD
      VAProfileVC1Advanced            : VAEntrypointVLD
      VAProfileJPEGBaseline           : VAEntrypointVLD
      VAProfileJPEGBaseline           : VAEntrypointEncPicture
      VAProfileH264ConstrainedBaseline: VAEntrypointVLD
      VAProfileH264ConstrainedBaseline: VAEntrypointEncSlice
      VAProfileH264ConstrainedBaseline: VAEntrypointFEI
      VAProfileH264ConstrainedBaseline: VAEntrypointEncSliceLP
      VAProfileVP8Version0_3          : VAEntrypointVLD
      VAProfileVP8Version0_3          : VAEntrypointEncSlice
      VAProfileHEVCMain               : VAEntrypointVLD
      VAProfileHEVCMain               : VAEntrypointEncSlice
      VAProfileHEVCMain               : VAEntrypointFEI
      VAProfileHEVCMain10             : VAEntrypointVLD
      VAProfileHEVCMain10             : VAEntrypointEncSlice
      VAProfileVP9Profile0            : VAEntrypointVLD
      VAProfileVP9Profile2            : VAEntrypointVLD
```

Now install ffmpeg driver, get the correct one from here:
```
https://repo.jellyfin.org/?path=/ffmpeg/ubuntu/latest-6.x/amd64 (wget the noble package for ubuntu)
```

ant then install it including all the dependencies
```
sudo dpkg -i jellyfin-ffmpeg6_6.0.1-8-noble_amd64.deb 
sudo apt-get install -f
```

then check with:
```
dpkg -l | grep jellyfin-ffmpeg6
```

you should have a responses like this:
```
ii  jellyfin-ffmpeg6                     6.0.1-8-noble                           amd64        Tools for transcoding, streaming and playing of multimedia files
```
# Install intel gpu support for K3S
This is needed to enable k3S to assign the intel GPU as a resource in the deployment. If you have different GPU you should skip this point / replace with the driver of your CPU 

```
helm repo add nfd https://kubernetes-sigs.github.io/node-feature-discovery/charts # for NFD
helm repo add intel https://intel.github.io/helm-charts/ # for device-plugin-operator and plugins
helm repo update
helm install nfd nfd/node-feature-discovery --namespace node-feature-discovery --create-namespace
helm install gpu intel/intel-device-plugins-gpu --namespace inteldeviceplugins-system --create-namespace --set nodeFeatureRule=true
```

Now supposing that the node with intel CPU is ubuntu 2, typing down this command:
```
kubectl describe node ubuntu2
```

you will have something like this:
```
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource                       Requests      Limits
  --------                       --------      ------
  cpu                            3550m (59%)   6300m (105%)
  memory                         7044Mi (22%)  18500Mi (58%)
  ephemeral-storage              0 (0%)        0 (0%)
  hugepages-1Gi                  0 (0%)        0 (0%)
  hugepages-2Mi                  0 (0%)        0 (0%)
  gpu.intel.com/i915             0             0
  gpu.intel.com/i915_monitoring  0             0
```

so now you can assign the **gpu.intel.com/i915** to the resources of your deployment.

If during the deployment of intel-device-plugins-gpu you have a problem related to "too many file open" you need to raise on the node os the inotify.max_usr value.

This change the value at runtime:
```
sysctl -w fs.inotify.max_user_watches=100000 
sysctl -w fs.inotify.max_user_instances=100000
```

to keep also after reboot

```
sudo vim /etc/sysctl.conf
```

and add this:
```
fs.inotify.max_user_watches=100000 
fs.inotify.max_user_instances=100000
```

and apply the change with this command:
```
sudo sysctl -p
```

# Deploy on k3S

You can use the deployment.yaml in this repo to deploy PVC, Deployment, SVC and service route.

In the PVC remember to correctly set the local path with the video to reproduce (in the example /mnt/servarr).

In  the service route remember to put the correct url of your service.

Then just use
```
kubectl apply -f deployment.yaml
```

# Jellyfin configuration
After installing it you need to login and activate HW acceleration, so click on profile > admin dashboard > reproduction (My interface is in a different langue, so the name can be a bit different) and then:

```
Hardware Acceleration: QSV
Enable hardware decoding for: all selected
Hardware encoding options: enable hardware encoding.
```

In this way a was able to reproduce a 4k video in HEVC with the UHD Graphics 630 intel integrated graphics card.

# Jellyfin backup
Because we installed Jellyfin in a K3S node where only it is installed we just backup the entire **/var/lib/rancher/k3s/storage** directory. Otherwise you need tospecify the exact pvc name.

Say that you can use the script **backup.sh** in this space, remembering to check:
* **source_base**: in case you want to specify a specific PVC directory;
* **dest_base**: you need put where you want you backup.

Finally you can schedule it daily with crontab by:
```
sudo crontab -e
```

and adding this at the bottom something like this:
```
0 5 * * * /bin/bash <path-of-the-script>/backup.sh >> <path-of-the-log/cron.log 2>&1
```

# References
* **Intel plugin k8s** - https://github.com/intel/intel-device-plugins-for-kubernetes
* **Jellyfin image from linux server** - https://docs.linuxserver.io/images/docker-jellyfin/
  
