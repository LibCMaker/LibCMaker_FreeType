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

# Part of "LibCMaker/cmake/cmr_find_package.cmake".

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

  set(FT_lib_NAME ${find_NAME})

  if(FT_WITH_HARFBUZZ)
    if(NOT LIBCMAKER_HARFBUZZ_SRC_DIR)
      cmr_print_error(
        "Please set LIBCMAKER_HARFBUZZ_SRC_DIR with path to LibCMaker_HarfBuzz root.")
    endif()
    cmr_print_value(LIBCMAKER_HARFBUZZ_SRC_DIR)

    set(FT_WITH_HARFBUZZ_NEED ON CACHE BOOL "Mark about the need for HarfBuzz")
    mark_as_advanced(FT_WITH_HARFBUZZ_NEED)
    if(FT_WITH_HARFBUZZ_NEED)
      set(FT_WITH_HARFBUZZ OFF)
    endif()
  endif()


  #-----------------------------------------------------------------------
  # Library specific build arguments
  #-----------------------------------------------------------------------

  if(ANDROID AND BUILD_SHARED_LIBS AND FT_WITH_HARFBUZZ_NEED)
    set(BUILD_SHARED_LIBS OFF)
    set(BUILD_SHARED_LIBS_NEED ON)
  endif()

  foreach(d ZLIB BZip2 PNG HarfBuzz)
    string(TOUPPER "${d}" D)
    if(DEFINED FT_WITH_${d} OR DEFINED FT_WITH_${D})
      list(APPEND find_CMAKE_ARGS
        -DFT_WITH_${D}=${FT_WITH_${D}}
      )
    endif()
  endforeach()

## +++ Common part of the lib_cmaker_<lib_name> function +++
  set(find_LIB_VARS
    COPY_FREETYPE_CMAKE_BUILD_SCRIPTS
    FREETYPE_NO_DIST
    LIBCMAKER_HARFBUZZ_SRC_DIR
    LIBCMAKER_FREETYPE_SRC_DIR
    BUILD_FRAMEWORK
    IOS_PLATFORM
    DISABLE_FORCE_DEBUG_POSTFIX
  )

  foreach(d ${find_LIB_VARS})
    if(DEFINED ${d})
      list(APPEND find_CMAKE_ARGS
        -D${d}=${${d}}
      )
    endif()
  endforeach()
## --- Common part of the lib_cmaker_<lib_name> function ---


  #-----------------------------------------------------------------------
  # Building
  #-----------------------------------------------------------------------

  set(FT_lib_LANGUAGES CXX C)

  if(NOT FT_WITH_HARFBUZZ)
## +++ Common part of the lib_cmaker_<lib_name> function +++
    cmr_lib_cmaker_main(
      LibCMaker_DIR ${find_LibCMaker_DIR}
      NAME          ${find_NAME}
      VERSION       ${find_VERSION}
      LANGUAGES     ${FT_lib_LANGUAGES}
      BASE_DIR      ${find_LIB_DIR}
      DOWNLOAD_DIR  ${cmr_DOWNLOAD_DIR}
      UNPACKED_DIR  ${cmr_UNPACKED_DIR}
      BUILD_DIR     ${lib_BUILD_DIR}
      CMAKE_ARGS    ${find_CMAKE_ARGS}
      INSTALL
    )
## --- Common part of the lib_cmaker_<lib_name> function ---
  endif()

  if(FT_WITH_HARFBUZZ OR FT_WITH_HARFBUZZ_NEED)
    cmr_print_status("Build HarfBuzz with compiled FreeType")
    cmr_print_value(LIBCMAKER_HARFBUZZ_SRC_DIR)

    set(cmr_BUILD_FROM_FREETYPE ON)
    set(LIBCMAKER_FREETYPE_SRC_DIR ${find_LIB_DIR})
    option(HB_HAVE_FREETYPE "Enable freetype interop helpers" ON)

    include(${LIBCMAKER_HARFBUZZ_SRC_DIR}/cmr_build_harfbuzz.cmake)

    if(NOT FT_WITH_HARFBUZZ)
      set(FT_WITH_HARFBUZZ ON)
      set(FT_WITH_HARFBUZZ_NEED OFF
        CACHE BOOL "Mark about the need for HarfBuzz" FORCE
      )

      list(APPEND find_CMAKE_ARGS
        -DFT_WITH_HARFBUZZ=${FT_WITH_HARFBUZZ}
      )

      cmr_print_status("Rebuild FreeType with compiled HarfBuzz")
      find_path(Freetype_INCLUDE_DIR_TO_REMOVE
        NAMES "ft2build.h"
        PATH_SUFFIXES "include/freetype2"
        HINTS ${cmr_INSTALL_DIR}
      )
      if(Freetype_INCLUDE_DIR_TO_REMOVE)
        cmr_print_status("Clear directory ${Freetype_INCLUDE_DIR_TO_REMOVE}")
        execute_process(
          COMMAND ${CMAKE_COMMAND} -E
            remove_directory ${Freetype_INCLUDE_DIR_TO_REMOVE}
        )
      endif()
      cmr_print_status("Clear directory ${lib_BUILD_DIR}")
      execute_process(
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${lib_BUILD_DIR}
      )
    else()
      cmr_print_status("Build FreeType with compiled HarfBuzz")
    endif()

    if(BUILD_SHARED_LIBS_NEED)
      cmr_print_status("Rebuild FreeType as shared library")
      set(BUILD_SHARED_LIBS ON)
      set(BUILD_SHARED_LIBS_HARFBUZZ ON)
    endif()

## +++ Common part of the lib_cmaker_<lib_name> function +++
    cmr_lib_cmaker_main(
      LibCMaker_DIR ${find_LibCMaker_DIR}
      NAME          ${find_NAME}
      VERSION       ${find_VERSION}
      LANGUAGES     ${FT_lib_LANGUAGES}
      BASE_DIR      ${find_LIB_DIR}
      DOWNLOAD_DIR  ${cmr_DOWNLOAD_DIR}
      UNPACKED_DIR  ${cmr_UNPACKED_DIR}
      BUILD_DIR     ${lib_BUILD_DIR}
      CMAKE_ARGS    ${find_CMAKE_ARGS}
      INSTALL
    )
## --- Common part of the lib_cmaker_<lib_name> function ---

    if(BUILD_SHARED_LIBS_HARFBUZZ)
      cmr_print_status("Rebuild HarfBuzz as shared library")
      find_path(HarfBuzz_INCLUDE_DIR_TO_REMOVE
        NAMES "hb.h"
        PATH_SUFFIXES "include/harfbuzz"
        HINTS ${cmr_INSTALL_DIR}
      )
      if(HarfBuzz_INCLUDE_DIR_TO_REMOVE)
        cmr_print_status("Clear directory ${HarfBuzz_INCLUDE_DIR_TO_REMOVE}")
        execute_process(
          COMMAND ${CMAKE_COMMAND} -E
            remove_directory ${HarfBuzz_INCLUDE_DIR_TO_REMOVE}
        )
      endif()
      set(HB_BUILD_DIR ${cmr_BUILD_DIR}/build_${HB_lib_NAME})
      cmr_print_status("Clear directory ${HB_BUILD_DIR}")
      execute_process(
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${HB_BUILD_DIR}
      )
      unset(HARFBUZZ_INCLUDE_DIR CACHE)

      include(${LIBCMAKER_HARFBUZZ_SRC_DIR}/cmr_build_harfbuzz.cmake)
    endif()
  endif()
