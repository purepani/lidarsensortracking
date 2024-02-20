{
  livox_ros_driver,
  livox_sdk,
}: {
  lib,
  buildRosPackage,
  cmake,
  boost,
  catkin,
  roscpp,
  rospy,
  std-msgs,
  rosbag,
  pcl-ros,
}: let
  name = "livox_ros_driver";
  version = "2.6.0";
in
  buildRosPackage {
    pname = name;
    inherit version;

    src = livox_ros_driver;

    buildType = "cmake";
    buildInputs = [
      cmake
      livox_sdk
      catkin
      roscpp
      rospy
      std-msgs
      rosbag
      pcl-ros
    ];
    nativeBuildInputs = [cmake boost];

    meta = {
      description = "Livox ROS Driver";
      license = with lib.licenses; [bsdOriginal];
    };
  }
