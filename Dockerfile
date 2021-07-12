ARG ROS_DISTRO=kinetic

FROM ros:${ROS_DISTRO}-ros-core AS build-env
ENV DEBIAN_FRONTEND=noninteractive \
    BUILD_HOME=/var/lib/build \
    GST_SDK_PATH=/opt/gstreamer_camera_driver

RUN set -xue \
# Kinetic and melodic have python3 packages but they seem to conflict
&& [ $ROS_DISTRO = "noetic" ] && PY=python3 || PY=python \
# Turn off installing extra packages globally to slim down rosdep install
&& echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/01norecommend \
&& apt-get update \
&& apt-get install -y \
 build-essential cmake \
 fakeroot dpkg-dev debhelper \
 $PY-rosdep $PY-rospkg $PY-bloom \
&& apt-get install -y gstreamer0.10-x \
&& apt-get install -y gstreamer0.10-plugins-base \
 gstreamer0.10-plugins-base-apps gstreamer0.10-plugins-good

# Set up non-root build user
ARG BUILD_UID=1000
ARG BUILD_GID=${BUILD_UID}

RUN set -xe \
&& groupadd -o -g ${BUILD_GID} build \
&& useradd -o -u ${BUILD_UID} -d ${BUILD_HOME} -rm -s /bin/bash -g build build

# Install build dependencies using rosdep
COPY --chown=build:build gstreamer_camera_driver/package.xml ${GST_SDK_PATH}/gstreamer_camera_driver/package.xml

RUN set -xe \
&& apt-get update \
&& rosdep init \
&& rosdep update --rosdistro=${ROS_DISTRO} \
&& rosdep install -y --from-paths ${GST_SDK_PATH}

RUN sudo git clone --depth 1 https://github.com/vishnubob/wait-for-it.git ~/.base-image/wait-for-it &&\
    sudo mv ~/.base-image/wait-for-it/wait-for-it.sh /usr/bin

# Set up build environment
COPY --chown=build:build gstreamer_camera_driver ${GST_SDK_PATH}/gstreamer_camera_driver

USER build:build
WORKDIR ${BUILD_HOME}

RUN set -xe \
&& mkdir src \
&& ln -s ${GST_SDK_PATH} ./src

FROM build-env

RUN /opt/ros/${ROS_DISTRO}/env.sh catkin_make -DCMAKE_BUILD_TYPE=Release 

# Entrypoint for running GStreamer driver:
#
# Usage: docker run --rm -it gscam_driver [launch parameters ..]
#
CMD ["bash", "-c", "set -e \
&& . ./devel/setup.bash \
&& roslaunch gscam_driver left_imx390.launch \
", "ros-entrypoint"]