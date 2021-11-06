TARGET := iphone:clang:14.4:14.0
INSTALL_TARGET_PROCESSES = SpringBoard
GO_EASY_ON_ME = 1
THEOS_LEAN_AND_MEAN = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Zinnia

Zinnia_FILES				= Sources/Zinnia/Tweak.swift \
								$(shell find Sources/Zinnia/UI -name '*.swift') \
								$(shell find Sources/Zinnia/NomaePreferences -name '*.swift') \
								$(shell find Sources/ZinniaC -name '*.m' -o -name '*.c')
Zinnia_SWIFTFLAGS			= -ISources/ZinniaC/include
Zinnia_CFLAGS				= -fobjc-arc -DTHEOS_SWIFT
ADDITIONAL_SWIFTFLAGS		= -DTHEOS_SWIFT
Zinnia_FRAMEWORKS			= AVFoundation
Zinnia_PRIVATE_FRAMEWORKS	= AppSupport CoreTelephony CoverSheet
Zinnia_LOGOS_DEFAULT_GENERATOR     = internal

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += zinniaprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
