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


# References
* **Intel plugin k8s** - https://github.com/intel/intel-device-plugins-for-kubernetes
  
