#!/bin/bash  

#
# Copyright (C) YuqiaoZhang(HanetakaYuminaga)
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

# 18.04 LTS
# 16.04 LTS
# cat /etc/os-release 

if test \( $# -ne 1 \);
then
    echo "Usage: build.sh arch"
    echo ""
    echo "Archs:"
    echo "  x86     -   build with the x86 arch"
    echo "  x64     -   build with the x64 arch"
    echo ""
    exit 1
fi

if test \( \( -n "$1" \) -a \( "$1" = "x86" \) \);then
    dpkg --add-architecture i386
    add-apt-repository universe
    apt-get update

    apt remove libc++abi1-10 # bug ?
    apt remove libc++abi-10-dev # bug ?
    apt remove libc++1-10 # bug ?
    apt remove libc++-10-dev # bug ?
    #apt remove gcc-9
    #apt remove gcc
    #apt remove g++-9
    #apt remove g++
    #apt remove clang-10
    #apt remove clang
    apt autoremove

    apt install libc6-dev:i386
    apt install libgcc-9-dev:i386 # libc++ links libgcc_s # -nostdlib -nodefaultlibs 
    apt install libstdc++-9-dev:i386
    apt install liblzma-dev:i386
    apt install libunwind8:i386
    apt install libunwind-dev:i386
    apt install libc++abi1-10:i386
    apt install libc++abi1:i386
    apt install libc++abi-10-dev:i386
    apt install libc++abi-dev:i386
    apt install libc++1-10:i386
    apt install libc++1:i386
    apt install libc++-10-dev:i386
    apt install libc++-dev:i386
    apt install libxcb1-dev:i386
    apt install libx11-dev:i386
    apt install libx11-xcb-dev:i386
    apt install libglvnd-dev:i386
    # apt install libfreeimage-dev:i386
    curl -L -o libfreeimage3_3.17.0+ds1-5build2_i386.deb http://archive.ubuntu.com/ubuntu/pool/universe/f/freeimage/libfreeimage3_3.17.0+ds1-5build2_i386.deb
    apt install libfreeimage3_3.17.0+ds1-5build2_i386.deb
    curl -L -o libfreeimage-dev_3.17.0+ds1-5build2_i386.deb http://archive.ubuntu.com/ubuntu/pool/universe/f/freeimage/libfreeimage-dev_3.17.0+ds1-5build2_i386.deb
    apt install libfreeimage-dev_3.17.0+ds1-5build2_i386.deb

    # apt install gcc-9:i386
    # apt install gcc:i386
    # apt install g++-9:i386
    # apt install g++:i386
    apt install clang-10:i386
    apt install clang:i386
    apt install chrpath
    apt install glslang-tools
elif test \( \( -n "$1" \) -a \( "$1" = "x64" \) \);then
    add-apt-repository universe
    apt-get update

    apt install libc6-dev
    apt install libgcc-9-dev # libc++ links libgcc_s # -nostdlib -nodefaultlibs 
    apt install libstdc++-9-dev
    apt install liblzma-dev
    apt install libunwind8
    apt install libunwind-dev
    apt install libc++abi1-10
    apt install libc++abi1
    apt install libc++abi-10-dev 
    apt install libc++abi-dev
    apt install libc++1-10
    apt install libc++1
    apt install libc++-10-dev
    apt install libc++-dev
    apt install libxcb1-dev
    apt install libx11-dev
    apt install libx11-xcb-dev
    apt install libglvnd-dev
    apt install libfreeimage-dev

    apt install gcc-9
    apt install gcc
    apt install g++-9
    apt install g++
    apt install clang-10
    apt install clang
    apt install chrpath
    apt install glslang-tools
else
    echo "The arch \"$1\" is not supported!"
    echo ""
    echo "Archs:"
    echo "  x86     -   build with the x86 arch"
    echo "  x64     -   build with the x64 arch"
    echo ""
    exit 1
fi



