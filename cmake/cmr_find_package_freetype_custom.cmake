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

    # Try to find already installed lib.
    find_package(${module_NAME} ${module_version} QUIET ${find_args})
    if(FT_WITH_HARFBUZZ)
      find_package(HarfBuzz QUIET ${find_args})
    endif()

    if(NOT ${find_NAME}_FOUND AND NOT ${lib_NAME_UPPER}_FOUND
          OR FT_WITH_HARFBUZZ AND NOT HarfBuzz_FOUND AND NOT HARFBUZZ_FOUND)

      cmr_print_status("${find_NAME} is not built, build it.")

      include(cmr_find_package_${lib_NAME_LOWER})

      if(find_REQUIRED)
        list(APPEND find_args REQUIRED)
      endif()
      find_package(${module_NAME} ${module_version} ${find_args})
      if(FT_WITH_HARFBUZZ)
        find_package(HarfBuzz ${find_args})
      endif()

    else()
      cmr_print_status("${find_NAME} is built, skip its building.")
    endif()
