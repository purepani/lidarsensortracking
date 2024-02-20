{
  lib,
  buildRosPackage,
  cmake,
  gz-cmake_3,
  roscpp,
  #boost,
  std-msgs,
  protobuf,
  catkin,
  tf,
  gazebo,
  fetchgit,
}: let
  name = "livox_laser_simulation";
  version = "1.0";
in
  buildRosPackage {
    pname = name;
    inherit version;

    #src = "${livox_laser_simulation}";
    src = fetchgit {
      url = "https://github.com/sangshuduo/livox_laser_simulation.git";
      rev = "4ab77b51f5c55e342c4a64bfb9de55117c90413f";
      sha256 = "sha256-0z1vv0Xxb2oZL4E+2WUyKgONSnlfenJo/n5zecilJ44=";
    };

    #buildType = "catkin";
    buildType = "cmake";
    buildInputs = [
      gz-cmake_3
      protobuf
      roscpp
      gazebo
      catkin
      tf
    ];
    propegatedBuildInputs = [roscpp tf std-msgs];
    nativeBuildInputs = [cmake catkin gz-cmake_3];

    meta = {
      description = "Livox ROS Laser Simulation";
      license = with lib.licenses; [bsdOriginal];
    };
  }
