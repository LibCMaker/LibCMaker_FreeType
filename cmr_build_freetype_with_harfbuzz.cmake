# ****************************************************************************
#  Project:  LibCMaker_FreeType
#  Purpose:  A CMake build script for FreeType Library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2019 NikitaFeodonit
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

#-----------------------------------------------------------------------
# The file is an example of the convenient script for the library build.
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Lib's name, version, paths
#-----------------------------------------------------------------------

set(FT_lib_NAME "FreeType")
set(FT_lib_VERSION "2.11.0" CACHE STRING "FT_lib_VERSION")
set(FT_lib_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE PATH "FT_lib_DIR")

# To use our Find<LibName>.cmake.
list(APPEND CMAKE_MODULE_PATH "${FT_lib_DIR}/cmake/modules")


#-----------------------------------------------------------------------
# LibCMaker_<LibName> specific vars and options
#-----------------------------------------------------------------------

# Used in 'cmr_build_rules_harfbuzz.cmake'
set(
  LIBCMAKER_FREETYPE_SRC_DIR ${FT_lib_DIR}
  CACHE PATH "LIBCMAKER_FREETYPE_SRC_DIR"
)

option(COPY_FREETYPE_CMAKE_BUILD_SCRIPTS "COPY_FREETYPE_CMAKE_BUILD_SCRIPTS" ON)


#-----------------------------------------------------------------------
# Library specific vars and options
#-----------------------------------------------------------------------

option(FREETYPE_NO_DIST "FREETYPE_NO_DIST" ON)

option(FT_WITH_ZLIB "Use system zlib instead of internal library." OFF)
option(FT_WITH_BZip2 "Support bzip2 compressed fonts." OFF)
option(FT_WITH_PNG "Support PNG compressed OpenType embedded bitmaps." OFF)
option(FT_WITH_HarfBuzz "Improve auto-hinting of OpenType fonts." OFF)
option(FT_WITH_BrotliDec "Support compressed WOFF2 fonts." OFF)

option(
  DISABLE_FORCE_DEBUG_POSTFIX "Do not add 'd' postfix for Debug build." OFF
)

if(FT_WITH_HarfBuzz)
  set(
    LIBCMAKER_HARFBUZZ_SRC_DIR "${LibCMaker_LIB_DIR}/LibCMaker_HarfBuzz"
    CACHE PATH "LIBCMAKER_HARFBUZZ_SRC_DIR"
  )
  # To use our FindHarfBuzz.cmake.
  list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_HARFBUZZ_SRC_DIR}/cmake/modules")
endif()


#-----------------------------------------------------------------------
# Build, install and find the library
#-----------------------------------------------------------------------

cmr_find_package(
  LibCMaker_DIR   ${LibCMaker_DIR}
  NAME            ${FT_lib_NAME}
  VERSION         ${FT_lib_VERSION}
  LIB_DIR         ${FT_lib_DIR}
  REQUIRED
  FIND_MODULE_NAME Freetype
  NOT_USE_VERSION_IN_FIND_PACKAGE
  CUSTOM_LOGIC_FILE ${FT_lib_DIR}/cmake/cmr_find_package_freetype_custom.cmake
)
