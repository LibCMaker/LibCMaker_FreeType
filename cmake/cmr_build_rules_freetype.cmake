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

# Part of "LibCMaker/cmake/cmr_build_rules.cmake".

  # Overwrite FindHarfBuzz.cmake and set vars to it.
  if(WITH_HARFBUZZ)
    if(NOT LIBCMAKER_HARFBUZZ_SRC_DIR)
      cmr_print_error(
        "Please set LIBCMAKER_HARFBUZZ_SRC_DIR with path to LibCMaker_HarfBuzz root.")
    endif()
    cmr_print_value(LIBCMAKER_HARFBUZZ_SRC_DIR)
    # To use our FindHarfBuzz.cmake in FreeType's CMakeLists.txt
    list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_HARFBUZZ_SRC_DIR}/cmake/modules")

    cmr_print_status(
      "Overwrite FindHarfBuzz.cmake from LibCMaker_HarfBuzz in unpacked sources.")
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${LIBCMAKER_HARFBUZZ_SRC_DIR}/cmake/modules/FindHarfBuzz.cmake
        ${lib_SRC_DIR}/builds/cmake/
    )
  endif()

  # Copy CMake build scripts.
  if(COPY_FREETYPE_CMAKE_BUILD_SCRIPTS)
    cmr_print_status("Copy CMake build scripts to unpacked sources.")
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${lib_BASE_DIR}/patch/freetype-${lib_VERSION}
        ${lib_SRC_DIR}/
    )
  endif()

  # Configure library.
  add_subdirectory(${lib_SRC_DIR} ${lib_VERSION_BUILD_DIR})

  if(WITH_HARFBUZZ)
    set_property(TARGET freetype PROPERTY LINKER_LANGUAGE CXX)
  endif()
