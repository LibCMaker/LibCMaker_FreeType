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

if(NOT LIBCMAKER_SRC_DIR)
  message(FATAL_ERROR
    "Please set LIBCMAKER_SRC_DIR with path to LibCMaker root.")
endif()
# TODO: prevent multiply includes for CMAKE_MODULE_PATH
list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_SRC_DIR}/cmake/modules")


include(CMakeParseArguments) # cmake_parse_arguments

include(cmr_lib_cmaker)
include(cmr_print_debug_message)
include(cmr_print_fatal_error)
include(cmr_print_message)
include(cmr_print_var_value)


if((WITH_HarfBuzz OR WITH_HARFBUZZ) AND NOT LIBCMAKER_HARFBUZZ_SRC_DIR)
  cmr_print_fatal_error(
    "Please set LIBCMAKER_HARFBUZZ_SRC_DIR with path to LibCMaker_HarfBuzz root.")
endif()

if((WITH_HarfBuzz OR WITH_HARFBUZZ) AND NOT LIBCMAKER_FREETYPE_SRC_DIR)
  cmr_print_fatal_error(
    "Please set LIBCMAKER_FREETYPE_SRC_DIR with path to LibCMaker_FreeType root.")
endif()

# To find library CMaker source dir.
set(lcm_LibCMaker_FreeType_SRC_DIR ${CMAKE_CURRENT_LIST_DIR})
# TODO: prevent multiply includes for CMAKE_MODULE_PATH
list(APPEND CMAKE_MODULE_PATH "${lcm_LibCMaker_FreeType_SRC_DIR}/cmake/modules")


function(lib_cmaker_freetype)
  cmake_minimum_required(VERSION 3.2)

  cmr_print_message("======== Build library: FreeType ========")

# From <freetype sources>/docs/CHANGES:
#
#  FreeType can now use the HarfBuzz library to greatly improve the
#  auto-hinting of  fonts that  use OpenType features:  Many glyphs
#  that are part  of such features but don't have  cmap entries are
#  now handled  properly, for  example small caps  or superscripts.
#  Define the configuration  macro FT_CONFIG_OPTION_USE_HARFBUZZ to
#  activate HarfBuzz support.
#  
#  You need HarfBuzz version 0.9.19 or newer.
#  
#  Note that HarfBuzz depends on  FreeType; this currently causes a
#  chicken-and-egg problem  that can be  solved as follows  in case
#  HarfBuzz is not yet installed on your system.
#  
#    1. Compile  and  install  FreeType without  the  configuration
#       macro FT_CONFIG_OPTION_USE_HARFBUZZ.
#  
#    2. Compile and install HarfBuzz.
#  
#    3. Define  macro  FT_CONFIG_OPTION_USE_HARFBUZZ, then  compile
#       and install FreeType again.
#  
#  With FreeType's  `configure' script the procedure  boils down to
#  configure, build, and install FreeType, then configure, compile,
#  and  install  HarfBuzz,  then configure,  compile,  and  install
#  FreeType again (after executing `make distclean').
      
  if(DEFINED WITH_HarfBuzz AND DEFINED WITH_HARFBUZZ)
    unset(WITH_HARFBUZZ)
  endif()
  if(NOT DEFINED WITH_HarfBuzz AND DEFINED WITH_HARFBUZZ)
    set(WITH_HarfBuzz ${WITH_HARFBUZZ})
    unset(WITH_HARFBUZZ)
  endif()
  
  if(WITH_HarfBuzz)
    set(WITH_HarfBuzz_NEED ON CACHE BOOL "Mark about the need for HarfBuzz")
    mark_as_advanced(WITH_HarfBuzz_NEED)
    if(WITH_HarfBuzz_NEED)
      set(WITH_HarfBuzz OFF)
    endif()
  endif()

  set(options
    # optional args
  )
  
  set(oneValueArgs
    # required args
    VERSION BUILD_DIR
    # optional args
    DOWNLOAD_DIR UNPACKED_SRC_DIR
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

  cmr_print_var_value(arg_VERSION)
  cmr_print_var_value(arg_BUILD_DIR)

  cmr_print_var_value(arg_DOWNLOAD_DIR)
  cmr_print_var_value(arg_UNPACKED_SRC_DIR)

  # Required args
  if(NOT arg_VERSION)
    cmr_print_fatal_error("Argument VERSION is not defined.")
  endif()
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

  if(DEFINED FREETYPE_NO_DIST)
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

  if(DEFINED LIBCMAKER_HARFBUZZ_SRC_DIR)
    list(APPEND lcm_CMAKE_ARGS
      -DLIBCMAKER_HARFBUZZ_SRC_DIR=${LIBCMAKER_HARFBUZZ_SRC_DIR}
    )
  endif()
  if(DEFINED ENV{HARFBUZZ_DIR})
    list(APPEND lcm_CMAKE_ARGS
      -DHARFBUZZ_DIR=$ENV{HARFBUZZ_DIR}
    )
  endif()

  if(DEFINED LIBCMAKER_FREETYPE_SRC_DIR)
    list(APPEND lcm_CMAKE_ARGS
      -DLIBCMAKER_FREETYPE_SRC_DIR=${LIBCMAKER_FREETYPE_SRC_DIR}
    )
  endif()

  if(DEFINED BUILD_FRAMEWORK)
    list(APPEND lcm_CMAKE_ARGS
      -DBUILD_FRAMEWORK=${BUILD_FRAMEWORK}
    )
  endif()
  if(DEFINED IOS_PLATFORM)
    list(APPEND lcm_CMAKE_ARGS
      -DIOS_PLATFORM=${IOS_PLATFORM}
    )
  endif()
  
  
  #-----------------------------------------------------------------------
  # BUILDING
  #-----------------------------------------------------------------------

  if(NOT WITH_HarfBuzz)
    cmr_lib_cmaker(
      VERSION ${arg_VERSION}
      PROJECT_DIR ${lcm_LibCMaker_FreeType_SRC_DIR}
      DOWNLOAD_DIR ${arg_DOWNLOAD_DIR}
      UNPACKED_SRC_DIR ${arg_UNPACKED_SRC_DIR}
      BUILD_DIR ${arg_BUILD_DIR}
      CMAKE_ARGS ${lcm_CMAKE_ARGS}
      INSTALL
    )
  endif()
  
  if(WITH_HarfBuzz OR WITH_HarfBuzz_NEED)
    cmr_print_var_value(LIBCMAKER_HARFBUZZ_SRC_DIR)
    cmr_print_var_value(HB_lib_VERSION)
    cmr_print_var_value(HB_DOWNLOAD_DIR)
    cmr_print_var_value(HB_UNPACKED_SRC_DIR)
    cmr_print_var_value(HB_BUILD_DIR)
  
    set(HB_HAVE_FREETYPE ON)
    
    include(${LIBCMAKER_HARFBUZZ_SRC_DIR}/lib_cmaker_harfbuzz.cmake)
    
    cmr_print_message("Build HarfBuzz with compiled FreeType")

    lib_cmaker_harfbuzz(
      VERSION ${HB_lib_VERSION}
      DOWNLOAD_DIR ${HB_DOWNLOAD_DIR}
      UNPACKED_SRC_DIR ${HB_UNPACKED_SRC_DIR}
      BUILD_DIR ${HB_BUILD_DIR}
    )

    if(NOT WITH_HarfBuzz)
      set(WITH_HarfBuzz ON)
      set(WITH_HarfBuzz_NEED OFF
        CACHE BOOL "Mark about the need for HarfBuzz" FORCE
      )

      list(APPEND lcm_CMAKE_ARGS
        -DWITH_HarfBuzz=${WITH_HarfBuzz}
      )

      cmr_print_message("Rebuild FreeType with compiled HarfBuzz")
      find_path(Freetype_INCLUDE_DIR_TO_REMOVE
        NAMES "ft2build.h"
        PATH_SUFFIXES "include/freetype2"
        HINTS ${CMAKE_INSTALL_PREFIX}
      )
      if(Freetype_INCLUDE_DIR_TO_REMOVE)
        cmr_print_message("Clear directory ${Freetype_INCLUDE_DIR_TO_REMOVE}")
        execute_process(
          COMMAND ${CMAKE_COMMAND} -E
            remove_directory ${Freetype_INCLUDE_DIR_TO_REMOVE}
        )
      endif()
      cmr_print_message("Clear directory ${arg_BUILD_DIR}")
      execute_process(
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${arg_BUILD_DIR}
      )
    else()
      cmr_print_message("Build FreeType with compiled HarfBuzz")
    endif()
  
    cmr_lib_cmaker(
      VERSION ${arg_VERSION}
      PROJECT_DIR ${lcm_LibCMaker_FreeType_SRC_DIR}
      DOWNLOAD_DIR ${arg_DOWNLOAD_DIR}
      UNPACKED_SRC_DIR ${arg_UNPACKED_SRC_DIR}
      BUILD_DIR ${arg_BUILD_DIR}
      CMAKE_ARGS ${lcm_CMAKE_ARGS}
      INSTALL
    )
  endif()

endfunction()
