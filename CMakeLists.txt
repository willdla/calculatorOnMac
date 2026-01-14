cmake_minimum_required(VERSION 3.16)
project(Calculator)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(PROJECT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

# Use absolute paths for include directories
include_directories(${PROJECT_SOURCE_DIR}/src)
include_directories(${PROJECT_SOURCE_DIR}/src/CalcManager)
include_directories(${PROJECT_SOURCE_DIR}/src/CalcManager/Header\ Files)

add_subdirectory(src/CalcManager)
add_subdirectory(src/CalcConsole)
