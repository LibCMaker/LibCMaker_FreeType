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

include(cmr_get_version_parts)
include(cmr_print_fatal_error)

function(cmr_freetype_get_download_params
    version
    out_url out_sha1 out_src_dir_name out_tar_file_name)

  set(lib_base_url "http://download.savannah.gnu.org/releases/freetype")
  
  # TODO: get url and sha1 for all FreeType version
  # TODO: check with freetype-${version}.tar.bz2.sig
  if(version VERSION_EQUAL "2.7.1")
    set(lib_sha1 "4d08a9a6567c6332d58e9a5f9a7e9e3fbce66789")
  endif()
  if(version VERSION_EQUAL "2.8.1")
    set(lib_sha1 "417bb3747c4ac95b6f2652024a53fad45581fa1c")
  endif()

  if(NOT DEFINED lib_sha1)
    cmr_print_fatal_error("Library version ${version} is not supported.")
  endif()

  set(lib_src_name "freetype-${version}")
  set(lib_tar_file_name "${lib_src_name}.tar.bz2")
  set(lib_url "${lib_base_url}/${lib_tar_file_name}")

  set(${out_url} "${lib_url}" PARENT_SCOPE)
  set(${out_sha1} "${lib_sha1}" PARENT_SCOPE)
  set(${out_src_dir_name} "${lib_src_name}" PARENT_SCOPE)
  set(${out_tar_file_name} "${lib_tar_file_name}" PARENT_SCOPE)
endfunction()
