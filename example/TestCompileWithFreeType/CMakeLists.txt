# ****************************************************************************
#  Project:  LibCMaker_FreeType
#  Purpose:  A CMake build script for FreeType Library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017 NikitaFeodonit
#
#    This file is part of the LibCMaker_FreeType project.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published
#    by the Free Software Foundation, either version 3 of the License,
#    or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#    See the GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/>.
# ****************************************************************************

cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

project(LibCMaker_FreeType_Compile_Test C)


#-----------------------------------------------------------------------
# Set path to LibCMaker root
#-----------------------------------------------------------------------

set(LIBCMAKER_SRC_DIR "${PROJECT_SOURCE_DIR}/cmake/LibCMaker")
# Uncomment it if need functions from LibCMaker
#list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_SRC_DIR}/cmake/modules")


#-----------------------------------------------------------------------
# Set vars for LibCMaker_FreeType.
#-----------------------------------------------------------------------

set(lib_VERSION "2.7.1")
#set(BUILD_SHARED_LIBS ON)

# Set useful vars for lib_cmaker_freetype().
set(cmr_PRINT_DEBUG ON)

set(DOWNLOAD_DIR "${PROJECT_BINARY_DIR}")
set(UNPACKED_SRC_DIR "${PROJECT_BINARY_DIR}")
set(BUILD_DIR "${PROJECT_BINARY_DIR}/build")

# Library specific vars
set(FREETYPE_NO_DIST ON)

set(WITH_ZLIB OFF)
set(WITH_BZip2 OFF)
set(WITH_PNG OFF)
set(WITH_HarfBuzz OFF)

#set(SKIP_INSTALL_HEADERS ON)
#set(SKIP_INSTALL_LIBRARIES ON)
#set(SKIP_INSTALL_ALL ON)


#-----------------------------------------------------------------------
# Build and install the FreeType.
#-----------------------------------------------------------------------

include(
  ${PROJECT_SOURCE_DIR}/cmake/LibCMaker_FreeType/lib_cmaker_freetype.cmake)

# Make compile, build and install the library at a config CMake phase,
# generate the CMake config files.

# Install specified library version.
lib_cmaker_freetype(
  VERSION ${lib_VERSION}
  DOWNLOAD_DIR ${DOWNLOAD_DIR}
  UNPACKED_SRC_DIR ${UNPACKED_SRC_DIR}
  BUILD_DIR ${BUILD_DIR}
)

# Install default library version.
#lib_cmaker_freetype(
#  DOWNLOAD_DIR ${DOWNLOAD_DIR}
#  UNPACKED_SRC_DIR ${UNPACKED_SRC_DIR}
#  BUILD_DIR ${BUILD_DIR}
#)


#-----------------------------------------------------------------------
# Configure for find_package.
#-----------------------------------------------------------------------

if(ANDROID)
  set(CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
endif()


#-----------------------------------------------------------------------
# find_package
#-----------------------------------------------------------------------

# Use newly got library.
find_package(Freetype REQUIRED CONFIG)

# QUIET suppresses the big warning issued, and allows fallback
#find_package(Freetype QUIET CONFIG)
#if(NOT Freetype_FOUND)
    # Do warn about falling back to system, but can make message more
    # explicit/informative
#    message(STATUS
#      "No Freetype.cmake config file found, falling back to FindFreetype...")
    # Use REQUIRED flag to fail if not found
#    find_package(Freetype REQUIRED)
#endif()


#-----------------------------------------------------------------------
# Link to the library
#-----------------------------------------------------------------------

# Build test executables
add_executable (${PROJECT_NAME} test_with_freetype.c)
target_link_libraries(${PROJECT_NAME} freetype)
