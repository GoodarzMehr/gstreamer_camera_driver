#ifndef __GSCAM_GSCAM_H
#define __GSCAM_GSCAM_H

extern "C"{
  #include <gst/gst.h>
  #include <gst/app/gstappsink.h>
}

#include <ros/ros.h>

#include <image_transport/image_transport.h>
#include <camera_info_manager/camera_info_manager.h>

#include <sensor_msgs/Image.h>
#include <sensor_msgs/CameraInfo.h>
#include <sensor_msgs/SetCameraInfo.h>
#include <sensor_msgs/image_encodings.h>

#include <cv_bridge/cv_bridge.h>

#include <cav_msgs/DriverStatus.h>

#include <stdexcept>

namespace gscam {
  
  class GSCam {
  
    public:
      
      GSCam(ros::NodeHandle nh_camera, ros::NodeHandle nh_private);
      ~GSCam();

      bool configure();
      bool init_stream();
      void publish_stream();
      void cleanup_stream();
      void run();

    private:
      
      // General GStreamer configuration
      std::string gsconfig_;

      // GStreamer structures
      GstElement *pipeline_;
      GstElement *sink_;

      // Appsink configuration
      bool sync_sink_;
      bool preroll_;
      bool use_gst_timestamps_;
      bool reopen_on_eof_;
      bool publish_timestamp_;

      // Camera publisher configuration
      int width_, height_;
      std::string frame_id_;
      std::string image_encoding_;
      std::string camera_name_;
      std::string camera_info_url_;

      // ROS Interface
      // Calibration between ros::Time and gst timestamps
      double time_offset_;
      ros::NodeHandle nh_, nh_private_;
      image_transport::ImageTransport image_transport_;
      camera_info_manager::CameraInfoManager camera_info_manager_;
      image_transport::CameraPublisher camera_pub_;
      
      // Case of a jpeg only publisher
      ros::Publisher jpeg_pub_;
      ros::Publisher cinfo_pub_;

      // Driver discovery publisher
      ros::Publisher discovery_pub_;
      ros::Time last_discovery_pub_;
      
  };

}

#endif // ifndef __GSCAM_GSCAM_H
