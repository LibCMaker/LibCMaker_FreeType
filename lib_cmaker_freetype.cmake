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

if(NOT LIBCMAKER_SRC_DIR)
  message(FATAL_ERROR
    "Please set LIBCMAKER_SRC_DIR with path to LibCMaker modules root")
endif()
# TODO: prevent multiply includes for CMAKE_MODULE_PATH
list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_SRC_DIR}/cmake/modules")

# To find library CMaker source dir.
set(lcm_LibCMaker_LIB_SRC_DIR ${CMAKE_CURRENT_LIST_DIR})
# TODO: prevent multiply includes for CMAKE_MODULE_PATH
list(APPEND CMAKE_MODULE_PATH "${lcm_LibCMaker_LIB_SRC_DIR}/cmake/modules")

include(CMakeParseArguments) # cmake_parse_arguments

include(cmr_lib_cmaker)
include(cmr_print_debug_message)
include(cmr_print_var_value)

function(lib_cmaker_freetype)
  cmake_minimum_required(VERSION 3.2)

  set(options
    # optional args
  )
  
  set(oneValueArgs
    # required args
    BUILD_DIR
    # optional args
    VERSION DOWNLOAD_DIR UNPACKED_SRC_DIR
  )

  set(multiValueArgs
    # optional args
  )

  cmake_parse_arguments(arg
      "${options}" "${oneValueArgs}" "${multiValueArgs}" "${ARGN}")
  # -> lib_VERSION
  # -> lib_BUILD_DIR
  # -> lib_* ...

  cmr_print_var_value(LIBCMAKER_SRC_DIR)

  cmr_print_var_value(arg_BUILD_DIR)

  cmr_print_var_value(arg_VERSION)
  cmr_print_var_value(arg_DOWNLOAD_DIR)
  cmr_print_var_value(arg_UNPACKED_SRC_DIR)

  # Required args
  if(NOT arg_BUILD_DIR)
    cmr_print_fatal_error("Argument BUILD_DIR is not defined.")
  endif()
  if(arg_UNPARSED_ARGUMENTS)
    cmr_print_fatal_error(
      "There are unparsed arguments: ${arg_UNPARSED_ARGUMENTS}")
  endif()


  #-----------------------------------------------------------------------
  # Library specific build arguments.
  #-----------------------------------------------------------------------

  set(lcm_CMAKE_ARGS)

  if(FREETYPE_NO_DIST)
    list(APPEND lcm_CMAKE_ARGS
      -DFREETYPE_NO_DIST=${FREETYPE_NO_DIST}
    )
  endif()

  foreach(d ZLIB BZip2 PNG HarfBuzz)
    string(TOUPPER "${d}" D)
    if(DEFINED WITH_${d} OR DEFINED WITH_${D})
      list(APPEND lcm_CMAKE_ARGS
        -DWITH_${d}=${WITH_${d}}
      )
    endif()
  endforeach()

  if(SKIP_INSTALL_HEADERS)
    list(APPEND lcm_CMAKE_ARGS
      -DSKIP_INSTALL_HEADERS=${SKIP_INSTALL_HEADERS}
    )
  endif()
  if(SKIP_INSTALL_LIBRARIES)
    list(APPEND lcm_CMAKE_ARGS
      -DSKIP_INSTALL_LIBRARIES=${SKIP_INSTALL_LIBRARIES}
    )
  endif()
  if(SKIP_INSTALL_ALL)
    list(APPEND lcm_CMAKE_ARGS
      -DSKIP_INSTALL_ALL=${SKIP_INSTALL_ALL}
    )
  endif()
  if(BUILD_FRAMEWORK)
    list(APPEND lcm_CMAKE_ARGS
      -DBUILD_FRAMEWORK=${BUILD_FRAMEWORK}
    )
  endif()
  if(IOS_PLATFORM)
    list(APPEND lcm_CMAKE_ARGS
      -DIOS_PLATFORM=${IOS_PLATFORM}
    )
  endif()
  
  
  #-----------------------------------------------------------------------
  # BUILDING
  #-----------------------------------------------------------------------

  cmr_lib_cmaker(
    VERSION ${arg_VERSION}
    PROJECT_DIR ${lcm_LibCMaker_LIB_SRC_DIR}
    DOWNLOAD_DIR ${arg_DOWNLOAD_DIR}
    UNPACKED_SRC_DIR ${arg_UNPACKED_SRC_DIR}
    BUILD_DIR ${arg_BUILD_DIR}
    CMAKE_ARGS ${lcm_CMAKE_ARGS}
    INSTALL
  )

endfunction()
