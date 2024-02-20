{
  lib,
  buildRosPackage,
  #cmake,
  #boost,
  catkin,
  std-msgs,
  geometry-msgs,
  nav-msgs,
  roscpp,
  rospy,
  sensor-msgs,
  tf,
  livox-driver,
  rosbag,
  rostest,
  pcl-ros,
  opencv,
  fetchgit,
}: let
  name = "livox_mapping";
  version = "2.6.0";
in
  buildRosPackage {
    pname = name;
    inherit version;

    src = fetchgit {
      url = "https://github.com/purepani/livox_mapping.git";
      rev = "abd0b51f83bc7ade0ef5db3a24b5cbb3d35f0c3f";
      hash = "sha256-xHZNYHdxyixLNXKOxPkq6IpLb6KGqtvM7Vp1vlXA3U0=";
    };

    buildType = "catkin";
    buildInputs = [
      catkin
      roscpp
      rospy
      opencv
      std-msgs
      rosbag
      pcl-ros
      geometry-msgs
      nav-msgs
      sensor-msgs
      tf
      livox-driver
      rostest
      rosbag
    ];

    meta = {
      description = "Livox ROS Driver";
      license = with lib.licenses; [bsdOriginal];
    };
  }
