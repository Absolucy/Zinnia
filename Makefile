TARGET := iphone:clang:14.4:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Zinnia

Zinnia_FILES              = $(shell find Sources/Zinnia -name '*.swift') \
                             $(shell find Sources/ZinniaC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
Zinnia_SWIFTFLAGS         = -ISources/ZinniaC/include
Zinnia_CFLAGS             = -fobjc-arc
Zinnia_PRIVATE_FRAMEWORKS = CoreTelephony

include $(THEOS_MAKE_PATH)/tweak.mk
