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

LOCAL_PATH:= $(call my-dir)

# SVO

include $(CLEAR_VARS)

LOCAL_MODULE := SVO

LOCAL_SRC_FILES:= \
	$(abspath $(LOCAL_PATH)/../../3party)/glm.cpp \
	$(abspath $(LOCAL_PATH)/../../src)/camera.cpp \
	$(abspath $(LOCAL_PATH)/../../src)/glRoutine.cpp \
	$(abspath $(LOCAL_PATH)/../../src)/glslUtility.cpp \
	$(abspath $(LOCAL_PATH)/../../src)/main.cpp \
	$(abspath $(LOCAL_PATH)/../../src)/objLoader.cpp \
	$(abspath $(LOCAL_PATH)/../../src)/shader.cpp \
	$(abspath $(LOCAL_PATH)/../../src)/util.cpp 

#LOCAL_CFLAGS += -fdiagnostics-format=msvc
LOCAL_CFLAGS += -finput-charset=UTF-8 -fexec-charset=UTF-8
LOCAL_CFLAGS += -fvisibility=hidden

LOCAL_CPP_FEATURES += exceptions


LOCAL_LDFLAGS += -finput-charset=UTF-8 -fexec-charset=UTF-8
LOCAL_LDFLAGS += -Wl,--enable-new-dtags # the linker can't recognize the old dtags
LOCAL_LDFLAGS += -Wl,-rpath,XORIGIN # chrpath can only make path shorter
LOCAL_LDFLAGS += -Wl,--version-script,$(abspath $(LOCAL_PATH))/SVO.def

LOCAL_LDFLAGS += -lfreeimage -lOpenGL -lGLX -lX11-xcb -lxcb -lX11

include $(BUILD_EXECUTABLE)
