TARGET := iphone:clang:14.4:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Zinnia

TARGET_CC =  /opt/apple-llvm-hikari/bin/clang
TARGET_CXX = /opt/apple-llvm-hikari/bin/clang++

Zinnia_FILES              = $(shell find Sources/Zinnia/Tweak -name '*.swift') \
							 $(shell find Sources/Zinnia/UI -name '*.swift') \
                             $(shell find Sources/ZinniaC -name '*.m' -o -name "*.x" -o -name '*.c' -o -name '*.mm' -o -name '*.cpp') \
                             $(shell find Sources/NomaePreferences -name '*.swift')
Zinnia_SWIFTFLAGS         = -ISources/ZinniaC/include
Zinnia_CFLAGS             = -fobjc-arc -Wno-error -fvisibility=hidden -mllvm --enable-bcfobf -mllvm --enable-splitobf -mllvm --enable-strcry -mllvm --enable-funcwra -mllvm --aesSeed=0x2A
Zinnia_LDFLAGS            = -weak_framework CydiaSubstrate -weak_library $(THEOS)/sdks/iPhoneOS14.4.sdk/usr/lib/libblackjack.dylib -weak_library $(THEOS)/sdks/iPhoneOS14.4.sdk/usr/lib/libhooker.dylib
Zinnia_FRAMEWORKS         = AVFoundation
Zinnia_PRIVATE_FRAMEWORKS = CoreTelephony CoverSheet

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += zinniaprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
