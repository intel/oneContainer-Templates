#### v0.2.0 (2021-05-11)

* changed(dldt-ie): added numa lib
* changed(dldt-ie): add env vars
* changed(gst-libva): enable patching
* changed(gst-svt): added libexecdir flag
* components/gmmlib.m4: fix centos build
* system/centos-repo.m4: fix repo enable script
* components/yasm.m4: sync w/ ovc template
* components/nginx-upload.m4: sync w/ ovc template
* components/nasm.m4: sync w/ ovc template
* components/libx265.m4: cmake conditional install
* components/libx264.m4: cmake conditional install
* components/libvpx.m4: cmake conditional install
* components/libvorbis.m4: sync w/ ovc template
* components/libopus.m4: sync w/ ovc template
* components/libogg.m4: sync w/ ovc template
* components/libfdk-aac.m4: sync w/ ovc template
* components/libaom.m4: conditional cmake install
* components/gst-orc.m4: meson conditional install
* components/gst-core.m4: meson conditional install
* components/gst-libav.m4: meson conditional install
* components/dav1d.m4: conditional meson install
* components/gmmlib.m4: update w/ ovc changes
* components: add cmake and meson templates
* system/begin.m4: fine tune cleanup
* opencv.m4: make OPENCV_GSTREAMER option functional
* refactor(opencv): remove non consumed flag
* changed(ocl): include a flag for dg1 support
* changed: implementation to allow custom patches
* fix(dldt-ie): remove build_ocl macro condition
* refactor(dldt-ie): selective cldnn
* changed(gst-gva): enhance gva options
* changed(opencv): more optional dependencies included
* changed(gst-svt): include libdir
* fix(ffmpeg): remove duplicate definitions
* changed(ffmpeg): include more selectable flags
* feat(components): introduce intel compute runtime ocl
* gst-gva: add dl-streamer v1.3 template
* dldt: bump version to 2021.2 and some fixes

#### v0.1.0 (2021-01-28)

* Initial commit introducing oneContainer Templates