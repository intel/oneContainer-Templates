M4 Docker Templates
===================

.. contents::

Overview
--------

This project contains collection of component build & install
`m4 <https://www.gnu.org/software/m4/>`_ templates which can
be used as ingredients of docker images. You will find template
definitions for key Intel software and popular frameworks. For
example:

* `Intel(R) Media Driver for VAAPI <https://github.com/intel/media-driver>`_
* `Intel(R) Media SDK <https://github.com/Intel-Media-SDK/MediaSDK>`_
* `OpenVINO Toolkit <https://github.com/openvinotoolkit/openvino>`_
* `FFmpeg <https://ffmpeg.org/>`_
* `GStreamer <https://gstreamer.freedesktop.org/>`_

Supported base images
---------------------

Project supports the following base images:

+--------------+---------------+
| OS image     | Support level |
+==============+===============+
| ubuntu:20.04 | Full          |
+--------------+---------------+
| ubuntu:18.04 | Experimental  |
+--------------+---------------+
| centos:8     | Experimental  |
+--------------+---------------+
| centos:7     | Experimental  |
+--------------+---------------+

Mind that not all of the component templates might be supported
for particular OS image. Currently all templates are supported for
``ubuntu:20.04`` image. List of supported templates for base images
with *experimental* support level might not be defined.

Build and install
-----------------

Project uses `cmake <https://cmake.org/>`_ (version 2.8 or higher)
to build and install. Configure and install as follows::

  PREFIX=/usr/local
  cmake -DCMAKE_INSTALL_PREFIX=$PREFIX .
  make -j$(nproc)
  make install

You will get template files installed relative to::

  $PREFIX/share/m4docker-<major.minor>

Make sure to add include paths to template locations to be able to
use them in a top-level Dockerfile.m4 template::

  m4docker=$(find $PREFIX -type d -name m4docker-*.*)
  m4 -I $m4docker/system -I $m4docker/components ...

Example
-------

Below is a simplest example of a top-level Dockerfile.m4 which you can
compose. It will define a docker image containing self-built Intel media
stack (libva, media driver, media sdk)::

  # cat Dockerfile.m4

  include(begin.m4)
  include(media-driver.m4)
  include(msdk.m4)
  include(end.m4)

  FROM OS_NAME:OS_VERSION as build
  BUILD_ALL()
  CLEANUP()

  FROM OS_NAME:OS_VERSION
  INSTALL_ALL()

m4 ``include()`` directory effectively include project component template
files. Media driver and Media SDK templates are included explicitly, other
ingredients (such as libva) from which they depend will be fetched implicitly.
Mind that order in which you include templates is important (in this order
components will be built).

``FROM`` directive is usual docker directive to define a layer.
``BUILD_ALL`` and ``INSTALL_ALL`` are project defined m4 macro helpers
which actually add component build (or install) code from the template
to docker layer definition. ``CLEANUP`` is another macro helper which
allows to remove some build target depending on the desired docker image
type. By default image is considered to be required for runtime, so
``CLEANUP`` removes header files, static library files and manuals.

``begin.m4`` and ``end.m4`` are special project templates which should
surround inclusion of all other component templates.

To produce a Dockerfile from this Dockerfile.m4 template, execute::

  m4 -I $m4docker/system -I $m4docker/components \
    -D OS_NAME=ubuntu -D OS_VERSION=20.04 \
    Dockerfile.m4 > Dockerfile

Contributing
------------

Contributions are welcomed. If you would like to provide a new template,
please, review `how to write new template <doc/new_template_howto.rst>`_.
Make sure to extend `tests <tests/readme.rst>`_ to cover new template or
changes to project core.

If you made any modifications to the project, run tests before submitting
your change for review::

  cmake .
  ctest -V

Links
-----

* `m4 <https://www.gnu.org/software/m4/>`_
* `Docker <https://docker.com/>`_
