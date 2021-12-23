GStreamer Camera Driver for CARMA
=================================

This is a fork of the [ROS GSCam](https://github.com/ros-drivers/gscam) package that is used for broadcasting any [GStreamer](http://gstreamer.freedesktop.org/)-based video stream via the standard [ROS Camera API](http://ros.org/wiki/camera_drivers). This fork has been modified to allow for building a Docker image that can serve as a camera driver for the [CARMA Platform](https://github.com/usdot-fhwa-stol/carma-platform).

GStreamer Library Support
-------------------------

This driver supports the following versions of GStreamer:

#### 0.10.x: Deprecated

#### 1.x: Default

Ubuntu 20.04 Installation
------------------------
Assuming the CARMA Platform is installed at `~/carma_ws/src`,
```
cd ~/carma_ws/src
git clone https://github.com/VT-ASIM-LAB/gstreamer_camera_driver.git
cd gstreamer_camera_driver/docker
sudo ./build-image.sh -d
```
After the Docker image is successfully built, add the following lines to the appropriate `docker-compose.yml` file in the `carma-config` directory.
```
gstreamer-camera-driver:
  image: usdotfhwastoldev/carma-gstreamer-camera-driver:develop
  container_name: gstreamer-camera-driver
  network_mode: host
  volumes_from:
    - container:carma-config:ro
  environment:
    - ROS_IP=127.0.0.1
  volumes:
    - /opt/carma/logs:/opt/carma/logs
    - /opt/carma/.ros:/home/carma/.ros
    - /opt/carma/vehicle/calibration:/opt/carma/vehicle/calibration
  command: bash -c '. ./devel/setup.bash && export ROS_NAMESPACE=$${CARMA_INTR_NS} && wait-for-it.sh localhost:11311 -- roslaunch /opt/carma/vehicle/config/drivers.launch drivers:=gstreamer_camera'
```
Finally, add the following lines to the `drivers.launch` file in the same directory as `docker-compose.yml`.
```
<include if="$(arg gstreamer_camera)" file="$(find gscam_driver)/launch/left_imx390.launch">
</include>
```
`left_imx390.launch` is used as an example here and can be replaced with any other launch file in the `gstreamer_camera_driver/launch` directory.

ROS API (stable)
----------------

### gscam_driver

This can be run as both a node and a nodelet.

#### Nodes
* `gscam`

#### Published Topics
* `camera/image_raw [sensor_msgs/Image]`: publishes the video stream obtained from the camera.
* `camera/camera_info [sensor_msgs/CameraInfo]`: publishes the [camera calibration file](http://www.ros.org/wiki/camera_calibration_parsers#File_formats).
* `camera/driver_discovery [cav_msgs/DriverStatus]`: publishes the CARMA [DriverStatus](https://github.com/usdot-fhwa-stol/carma-msgs/blob/develop/cav_msgs/msg/DriverStatus.msg) message (1.25 Hz).

#### Subscribed Topics
N/A

#### Services
* `set_camera_info [sensor_msgs/SetCameraInfo]`: stores the given CameraInfo as the camera's calibration information.

#### Parameters
* `camera_name`: the name of the camera (corrsponding to the camera info).
* `camera_info_url`: a url (`file://path/to/file`, `package://pkg_name/path/to/file`) to the [camera calibration file](http://www.ros.org/wiki/camera_calibration_parsers#File_formats).
* `gscam_config`: the GStreamer [pipeline description](https://gstreamer.freedesktop.org/documentation/tutorials/basic/gstreamer-tools.html?gi-language=c).
* `frame_id`: the [TF2](http://www.ros.org/wiki/tf2) frame ID.
* `reopen_on_eof`: re-open the stream if it ends (EoF).
* `sync_sink`: synchronize the `appsink` (sometimes setting this to `false` can resolve problems with sub-par framerates).
* `preroll`: [preroll](https://gstreamer.freedesktop.org/documentation/additional/design/preroll.html?gi-language=c) the stream if needed.
* `use_gst_timestamp`: use [GstClock](https://gstreamer.freedesktop.org/documentation/gstreamer/gstclock.html?gi-language=c) instead of [ROS Time](http://wiki.ros.org/roscpp/Overview/Time).
* `publish_timestamp`: publish the timestamp of received image frames.

Examples
--------

See the example launch files in the `gstreamer_camera_driver/launch` directory. Each launch file launches a Leopard Imaging LI-IMX390 camera connected via a TCP/IP connection.

Original GSCam Documentation [![Build Status](https://travis-ci.org/ros-drivers/gscam.svg?branch=master)](https://travis-ci.org/ros-drivers/gscam)
===========================================================================================================================

This is a ROS package originally developed by the [Brown Robotics
Lab](http://robotics.cs.brown.edu/) for broadcasting any
[GStreamer](http://gstreamer.freedesktop.org/)-based video stream via the
standard [ROS Camera API](http://ros.org/wiki/camera_drivers). This fork has
several fixes incorporated into it to make it broadcast correct
`sensor_msgs/Image` messages with proper frames and timestamps. It also allows
for more ROS-like configuration and more control over the GStreamer interface.

Note that this pacakge can be built both in a rosbuild and catkin workspaces.

GStreamer Library Support
-------------------------

gscam supports the following versions of GStreamer

### 0.1.x: _Default_

Install dependencies via `rosdep`.

### 1.0.x: Experimental

#### Dependencies:
 
* gstreamer1.0-tools 
* libgstreamer1.0-dev 
* libgstreamer-plugins-base1.0-dev 
* libgstreamer-plugins-good1.0-dev

Ubuntu Install:

##### 12.04

```sh
sudo add-apt-repository ppa:gstreamer-developers/ppa
sudo apt-get install gstreamer1.0-tools libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev
```

##### 14.04

```sh
sudo apt-get install gstreamer1.0-tools libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev
```

#### Usage:
* Use the CMake flag `-DGSTREAMER_VERSION_1_x=On` when building
* See the [Video4Linux2 launchfile example](examples/v4l.launch) for
  an example of the differences in the GStreamer config lines

#### Notes:
* This has been tested with `v4l2src`

ROS API (stable)
----------------

### gscam

This can be run as both a node and a nodelet.

#### Nodes
* `gscam`

#### Topics
* `camera/image_raw`
* `camera/camera_info`

#### Services
* `camera/set_camera_info`

#### Parameters
* `~camera_name`: The name of the camera (corrsponding to the camera info)
* `~camera_info_url`: A url (`file://path/to/file`, `package://pkg_name/path/to/file`) to the [camera calibration file](http://www.ros.org/wiki/camera_calibration_parsers#File_formats).
* `~gscam_config`: The GStreamer [configuration string](http://wiki.oz9aec.net/index.php?title=Gstreamer_cheat_sheet&oldid=1829).
* `~frame_id`: The [TF](http://www.ros.org/wiki/tf) frame ID.
* `~reopen_on_eof`: Re-open the stream if it ends (EOF).
* `~sync_sink`: Synchronize the app sink (sometimes setting this to `false` can resolve problems with sub-par framerates).

C++ API (unstable)
------------------

The gscam c++ library can be used, but it is not guaranteed to be stable. 

Examples
--------

See example launchfiles and configs in the examples directory. Currently there
are examples for:

* [Video4Linux2](examples/v4l.launch): Standard
  [video4linux](http://en.wikipedia.org/wiki/Video4Linux)-based cameras like
  USB webcams.
    * ***GST-1.0:*** Use the roslaunch argument `GST10:=True` for GStreamer 1.0 variant
* [Nodelet](examples/gscam_nodelet.launch): Run a V4L-based camera in a nodelet
* [Video File](examples/videofile.launch): Any videofile readable by GStreamer
* [DeckLink](examples/decklink.launch):
  [BlackMagic](http://www.blackmagicdesign.com/products/decklink/models)
  DeckLink SDI capture cards (note: this requires the `gst-plugins-bad` plugins)
