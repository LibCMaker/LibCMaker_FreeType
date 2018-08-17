# ****************************************************************************
#  Project:  LibCMaker_FreeType
#  Purpose:  A CMake build script for FreeType Library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2018 NikitaFeodonit
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

cmake_minimum_required(VERSION 3.3)

project(LibCMaker_FreeType_Compile_Test C CXX)

set(CMAKE_VERBOSE_MAKEFILE ON)
set(cmr_PRINT_DEBUG ON)


#-----------------------------------------------------------------------
# Configure to find_package()
#-----------------------------------------------------------------------

# Set CMake's search path for find_*() commands.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")

if(ANDROID)
  list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
endif()


#-----------------------------------------------------------------------
# Set path to LibCMaker root
#-----------------------------------------------------------------------

set(LibCMaker_DIR "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker")
# Uncomment it if need functions from LibCMaker
#list(APPEND CMAKE_MODULE_PATH "${LibCMaker_DIR}/cmake")


#-----------------------------------------------------------------------
# Set vars to LibCMaker_FreeType
#-----------------------------------------------------------------------

set(FT_lib_NAME     "FreeType")
set(FT_lib_VERSION  "2.9.1")
set(FT_lib_DIR      "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker_FreeType")

# To use below for sample sources.
set(cmr_UNPACKED_DIR ${CMAKE_CURRENT_BINARY_DIR}/download/unpacked)

# To use our FindFreetype.cmake.
list(APPEND CMAKE_MODULE_PATH "${FT_lib_DIR}/cmake/modules")

set(COPY_FREETYPE_CMAKE_BUILD_SCRIPTS ON)


#-----------------------------------------------------------------------
# Library specific vars and options
#-----------------------------------------------------------------------

set(FREETYPE_NO_DIST ON)

set(FT_WITH_ZLIB OFF)
set(FT_WITH_BZip2 OFF)
set(FT_WITH_PNG OFF)
set(FT_WITH_HarfBuzz OFF)

if(FT_WITH_HarfBuzz)
  set(HB_lib_NAME     "HarfBuzz")
  set(HB_lib_VERSION  "1.8.6")
  set(HB_lib_DIR      "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker_HarfBuzz")

  # To find FindHarfBuzz.cmake.
  list(APPEND CMAKE_MODULE_PATH "${HB_lib_DIR}/cmake/modules")

  # Need for lib_cmaker_freetype() to build HarfBuzz.
  set(LIBCMAKER_HARFBUZZ_SRC_DIR ${HB_lib_DIR})

  # LIBCMAKER_FREETYPE_SRC_DIR needed for lib_cmaker_harfbuzz() to build
  # HarfBuzz with FreeType.
  # LIBCMAKER_FREETYPE_SRC_DIR is set in lib_cmaker_freetype().

  set(COPY_HARFBUZZ_CMAKE_BUILD_SCRIPTS ON)
endif()


#-----------------------------------------------------------------------
# Build, install and find the FreeType
#-----------------------------------------------------------------------

# Make build and install the library at a config CMake phase.
include(${LibCMaker_DIR}/cmake/cmr_find_package.cmake)
cmr_find_package(
  LibCMaker_DIR   ${LibCMaker_DIR}
  NAME            ${FT_lib_NAME}
  VERSION         ${FT_lib_VERSION}
  LIB_DIR         ${FT_lib_DIR}
  REQUIRED
#  CONFIG
  NOT_USE_VERSION_IN_FIND_PACKAGE
  CUSTOM_LOGIC_FILE ${FT_lib_DIR}/cmake/cmr_find_package_freetype_custom.cmake
)


#-----------------------------------------------------------------------
# Link to the library
#-----------------------------------------------------------------------

# Build test executables.

add_executable(${PROJECT_NAME} test_with_freetype.c)

# FreeType
target_link_libraries(${PROJECT_NAME} freetype)

# HarfBuzz
if(FT_WITH_HarfBuzz)
  target_include_directories(${PROJECT_NAME} PUBLIC ${HARFBUZZ_INCLUDE_DIR})
  # From <freetype sources>/docs/CHANGES:
  #  Note that HarfBuzz depends on FreeType.
  target_link_libraries(${PROJECT_NAME} ${HARFBUZZ_LIBRARY} freetype)
  # HarfBuzz is C++ library.
  set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
endif()
