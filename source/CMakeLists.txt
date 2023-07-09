cmake_minimum_required(VERSION 3.1)
project(main)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake-modules/")

add_subdirectory(mosquitto)
