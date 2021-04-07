TARGET := iphone:clang:14.4:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Zinnia

Zinnia_FILES              = $(shell find Sources/Zinnia -name '*.swift') \
                             $(shell find Sources/ZinniaC -name '*.m' -o -name "*.x" -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
Zinnia_SWIFTFLAGS         = -ISources/ZinniaC/include
Zinnia_CFLAGS             = -fobjc-arc
Zinnia_LDFLAGS            = -weak_framework CydiaSubstrate -weak_library $(THEOS)/sdks/iPhoneOS14.4.sdk/usr/lib/libblackjack.dylib -weak_library $(THEOS)/sdks/iPhoneOS14.4.sdk/usr/lib/libhooker.dylib
Zinnia_FRAMEWORKS         = AVFoundation
Zinnia_PRIVATE_FRAMEWORKS = CoreTelephony

include $(THEOS_MAKE_PATH)/tweak.mk
