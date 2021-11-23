CARMA GStreamer Camera Driver
===========================================================================================================================

This is a fork of the [ROS GSCam](https://github.com/ros-drivers/gscam) package that is used for broadcasting any [GStreamer](http://gstreamer.freedesktop.org/)-based video stream via the standard [ROS Camera API](http://ros.org/wiki/camera_drivers). This fork has been modified to allow construction of a Docker image that can serve as a camera driver for the [CARMA Platform](https://github.com/usdot-fhwa-stol/carma-platform).

GStreamer Library Support
-------------------------

This driver supports the following versions of GStreamer:

#### 0.1.x: Default

#### 1.0.x: Experimental

Ubuntu Installation
------------------------
Assuming the CARMA Platform is installed at `~/carma_ws/carma/src`,
```
cd ~/carma_ws/carma/src
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

### gscam

This can be run as both a node and a nodelet.

#### Nodes
* `gscam`

#### Topics
* `camera/image_raw`: publishes the video stream obtained from the camera.
* `camera/camera_info`: publishes the [camera calibration file](http://www.ros.org/wiki/camera_calibration_parsers#File_formats).
* `camera/driver_discovery`: publishes the CARMA [DriverStatus](https://github.com/usdot-fhwa-stol/carma-msgs/blob/develop/cav_msgs/msg/DriverStatus.msg) message.

#### Services
* `camera/set_camera_info`: sets the [camera calibration file](http://www.ros.org/wiki/camera_calibration_parsers#File_formats).

#### Parameters
* `~camera_name`: The name of the camera (corrsponding to the camera info)
* `~camera_info_url`: A url (`file://path/to/file`, `package://pkg_name/path/to/file`) to the [camera calibration file](http://www.ros.org/wiki/camera_calibration_parsers#File_formats).
* `~gscam_config`: The GStreamer [configuration string](http://wiki.oz9aec.net/index.php?title=Gstreamer_cheat_sheet&oldid=1829).
* `~frame_id`: The [TF](http://www.ros.org/wiki/tf) frame ID.
* `~reopen_on_eof`: Re-open the stream if it ends (EOF).
* `~sync_sink`: Synchronize the app sink (sometimes setting this to `false` can resolve problems with sub-par framerates).
* `~publish_timestamp`: Publish the timestamp of received image frames.

Examples
--------

See the example launch files in the `gstreamer_camera_driver/launch` directory. Each launch file launches a Leopard Imaging LI-IMX390 camera connected via a TCP/IP connection.
