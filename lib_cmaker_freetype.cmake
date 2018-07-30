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

## +++ Common part of the lib_cmaker_<lib_name> function +++
set(cmr_lib_NAME "FreeType")

# To find library's LibCMaker source dir.
set(lcm_${cmr_lib_NAME}_SRC_DIR ${CMAKE_CURRENT_LIST_DIR})

if(NOT LIBCMAKER_SRC_DIR)
  message(FATAL_ERROR
    "Please set LIBCMAKER_SRC_DIR with path to LibCMaker root.")
endif()

include(${LIBCMAKER_SRC_DIR}/cmake/modules/lib_cmaker_init.cmake)

function(lib_cmaker_freetype)

  # Make the required checks.
  # Add library's and common LibCMaker module paths to CMAKE_MODULE_PATH.
  # Unset lcm_CMAKE_ARGS.
  # Set vars:
  #   cmr_CMAKE_MIN_VER
  #   cmr_lib_cmaker_main_PATH
  #   cmr_printers_PATH
  #   lower_lib_NAME
  # Parce args and set vars:
  #   arg_VERSION
  #   arg_DOWNLOAD_DIR
  #   arg_UNPACKED_DIR
  #   arg_BUILD_DIR
  lib_cmaker_init(${ARGN})

  include(${cmr_lib_cmaker_main_PATH})
  include(${cmr_printers_PATH})

  cmake_minimum_required(VERSION ${cmr_CMAKE_MIN_VER})
## --- Common part of the lib_cmaker_<lib_name> function ---

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
      
  set(FT_lib_NAME ${cmr_lib_NAME})

  if(DEFINED WITH_HarfBuzz AND DEFINED WITH_HARFBUZZ)
    unset(WITH_HARFBUZZ)
  endif()
  if(NOT DEFINED WITH_HarfBuzz AND DEFINED WITH_HARFBUZZ)
    set(WITH_HarfBuzz ${WITH_HARFBUZZ})
    unset(WITH_HARFBUZZ)
  endif()
  
  if(WITH_HarfBuzz)
    if(NOT LIBCMAKER_HARFBUZZ_SRC_DIR)
      cmr_print_fatal_error(
        "Please set LIBCMAKER_HARFBUZZ_SRC_DIR with path to LibCMaker_HarfBuzz root.")
    endif()
    cmr_print_var_value(LIBCMAKER_HARFBUZZ_SRC_DIR)

    set(WITH_HarfBuzz_NEED ON CACHE BOOL "Mark about the need for HarfBuzz")
    mark_as_advanced(WITH_HarfBuzz_NEED)
    if(WITH_HarfBuzz_NEED)
      set(WITH_HarfBuzz OFF)
    endif()
  endif()


  #-----------------------------------------------------------------------
  # Library specific build arguments
  #-----------------------------------------------------------------------

  if(ANDROID AND BUILD_SHARED_LIBS AND WITH_HarfBuzz_NEED)
    set(BUILD_SHARED_LIBS OFF)
    set(BUILD_SHARED_LIBS_NEED ON)
  endif()

  foreach(d ZLIB BZip2 PNG HarfBuzz)
    string(TOUPPER "${d}" D)
    if(DEFINED WITH_${d} OR DEFINED WITH_${D})
      list(APPEND lcm_CMAKE_ARGS
        -DWITH_${d}=${WITH_${d}}
      )
    endif()
  endforeach()

## +++ Common part of the lib_cmaker_<lib_name> function +++
  set(cmr_LIB_VARS
    FREETYPE_NO_DIST
    LIBCMAKER_HARFBUZZ_SRC_DIR
    LIBCMAKER_FREETYPE_SRC_DIR
    BUILD_FRAMEWORK
    IOS_PLATFORM
  )

  foreach(d ${cmr_LIB_VARS})
    if(DEFINED ${d})
      list(APPEND lcm_CMAKE_ARGS
        -D${d}=${${d}}
      )
    endif()
  endforeach()
## --- Common part of the lib_cmaker_<lib_name> function ---


  #-----------------------------------------------------------------------
  # Building
  #-----------------------------------------------------------------------

  if(NOT WITH_HarfBuzz)
## +++ Common part of the lib_cmaker_<lib_name> function +++
    cmr_lib_cmaker_main(
      NAME          ${cmr_lib_NAME}
      VERSION       ${arg_VERSION}
      BASE_DIR      ${lcm_${cmr_lib_NAME}_SRC_DIR}
      DOWNLOAD_DIR  ${arg_DOWNLOAD_DIR}
      UNPACKED_DIR  ${arg_UNPACKED_DIR}
      BUILD_DIR     ${arg_BUILD_DIR}
      CMAKE_ARGS    ${lcm_CMAKE_ARGS}
      INSTALL
    )
## --- Common part of the lib_cmaker_<lib_name> function ---
  endif()
  
  if(WITH_HarfBuzz OR WITH_HarfBuzz_NEED)
    cmr_print_var_value(LIBCMAKER_HARFBUZZ_SRC_DIR)
    cmr_print_var_value(HB_lib_VERSION)
    cmr_print_var_value(HB_DOWNLOAD_DIR)
    cmr_print_var_value(HB_UNPACKED_DIR)
    cmr_print_var_value(HB_BUILD_DIR)
  
    set(HB_HAVE_FREETYPE ON)
    set(LIBCMAKER_FREETYPE_SRC_DIR ${lcm_${cmr_lib_NAME}_SRC_DIR})
    
    cmr_print_message("Build HarfBuzz with compiled FreeType")

    include(${LIBCMAKER_HARFBUZZ_SRC_DIR}/lib_cmaker_harfbuzz.cmake)
    lib_cmaker_harfbuzz(
      VERSION       ${HB_lib_VERSION}
      DOWNLOAD_DIR  ${HB_DOWNLOAD_DIR}
      UNPACKED_DIR  ${HB_UNPACKED_DIR}
      BUILD_DIR     ${HB_BUILD_DIR}
    )

    # Need to restore 'cmr_lib_NAME' after 'lib_cmaker_harfbuzz.cmake'.
    set(HB_lib_NAME ${cmr_lib_NAME})
    set(cmr_lib_NAME ${FT_lib_NAME})

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
  
    if(BUILD_SHARED_LIBS_NEED)
      cmr_print_message("Rebuild FreeType as shared library")
      set(BUILD_SHARED_LIBS ON)
      set(BUILD_SHARED_LIBS_HARFBUZZ ON)
    endif()

## +++ Common part of the lib_cmaker_<lib_name> function +++
    cmr_lib_cmaker_main(
      NAME          ${cmr_lib_NAME}
      VERSION       ${arg_VERSION}
      BASE_DIR      ${lcm_${cmr_lib_NAME}_SRC_DIR}
      DOWNLOAD_DIR  ${arg_DOWNLOAD_DIR}
      UNPACKED_DIR  ${arg_UNPACKED_DIR}
      BUILD_DIR     ${arg_BUILD_DIR}
      CMAKE_ARGS    ${lcm_CMAKE_ARGS}
      INSTALL
    )
## --- Common part of the lib_cmaker_<lib_name> function ---
    
    if(BUILD_SHARED_LIBS_HARFBUZZ)
      # Need to restore 'cmr_lib_NAME' for 'lib_cmaker_harfbuzz'.
      set(cmr_lib_NAME ${HB_lib_NAME})

      cmr_print_message("Rebuild HarfBuzz as shared library")
      
      cmr_print_message("Clear directory ${HB_BUILD_DIR}")
      execute_process(
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${HB_BUILD_DIR}
      )
  
      lib_cmaker_harfbuzz(
        VERSION ${HB_lib_VERSION}
        DOWNLOAD_DIR ${HB_DOWNLOAD_DIR}
        UNPACKED_DIR ${HB_UNPACKED_DIR}
        BUILD_DIR ${HB_BUILD_DIR}
      )
    endif()
    
  endif()

endfunction()
