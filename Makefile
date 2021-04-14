TARGET := iphone:clang:14.4:14.0
INSTALL_TARGET_PROCESSES = SpringBoard
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Zinnia

TARGET_CC =  /opt/apple-llvm-hikari/bin/clang
TARGET_CXX = /opt/apple-llvm-hikari/bin/clang++

Zinnia_FILES              =	$(shell find Sources/Zinnia/Tweak -name '*.swift') \
							 $(shell find Sources/Zinnia/UI -name '*.swift') \
							 $(shell find Sources/Zinnia/NomaePreferences -name '*.swift') \
                             $(shell find Sources/ZinniaC -name '*.m' -o -name "*.x" -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
Zinnia_SWIFTFLAGS         = -ISources/ZinniaC/include
ifdef FINALPACKAGE
Zinnia_CFLAGS             = -Xlinker -x -fobjc-arc -DTHEOS_SWIFT -fvisibility=hidden -mllvm --enable-bcfobf -mllvm --enable-splitobf -mllvm --enable-strcry -mllvm --enable-funcwra -mllvm --enable-subobf
ADDITIONAL_SWIFTFLAGS     = -Xlinker -x
Zinnia_LDFLAGS            = -Xlinker -x -weak_framework CydiaSubstrate -weak_library $(THEOS)/sdks/iPhoneOS14.4.sdk/usr/lib/libblackjack.dylib -weak_library $(THEOS)/sdks/iPhoneOS14.4.sdk/usr/lib/libhooker.dylib
else
Zinnia_CFLAGS             = -fobjc-arc -Wno-error -DTHEOS_SWIFT
Zinnia_LDFLAGS            = -weak_framework CydiaSubstrate -weak_library $(THEOS)/sdks/iPhoneOS14.4.sdk/usr/lib/libblackjack.dylib -weak_library $(THEOS)/sdks/iPhoneOS14.4.sdk/usr/lib/libhooker.dylib
endif
Zinnia_FRAMEWORKS         = AVFoundation
Zinnia_PRIVATE_FRAMEWORKS = CoreTelephony CoverSheet

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += zinniaprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
