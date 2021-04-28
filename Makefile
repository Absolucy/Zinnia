TARGET := iphone:clang:14.4:14.0
INSTALL_TARGET_PROCESSES = SpringBoard
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Zinnia

ifdef FINALPACKAGE
TARGET_CC =  /opt/apple-llvm-hikari/bin/clang
TARGET_CXX = /opt/apple-llvm-hikari/bin/clang++
endif

Zinnia_FILES				= Sources/Zinnia/Tweak.swift \
								$(shell find Sources/Zinnia/DRM -name '*.swift') \
								$(shell find Sources/Zinnia/UI -name '*.swift') \
								$(shell find Sources/Zinnia/NomaePreferences -name '*.swift') \
								$(shell find Sources/ZinniaC -name '*.m' -o -name '*.c')
Zinnia_SWIFTFLAGS			= -ISources/ZinniaC/include
Zinnia_CFLAGS				= -fobjc-arc -DTHEOS_SWIFT 
ADDITIONAL_SWIFTFLAGS		= -DTHEOS_SWIFT
Zinnia_LDFLAGS				= -weak_framework CydiaSubstrate -weak_library $(THEOS)/sdks/iPhoneOS14.4.sdk/usr/lib/libblackjack.dylib -weak_library $(THEOS)/sdks/iPhoneOS14.4.sdk/usr/lib/libhooker.dylib
Zinnia_FRAMEWORKS			= AVFoundation
Zinnia_PRIVATE_FRAMEWORKS	= AppSupport CoreTelephony CoverSheet

ifdef DRM
Zinnia_CFLAGS				+= -DDRM
ADDITIONAL_SWIFTFLAGS		+= -DDRM
endif

ifdef TRIAL
Zinnia_CFLAGS				+= -DTRIAL
ADDITIONAL_SWIFTFLAGS		+= -DTRIAL
endif

ifdef FINALPACKAGE
Zinnia_CFLAGS				+= -fvisibility=hidden -mllvm --enable-bcfobf -mllvm --enable-strcry
SHOULD_STRIP				= 0
OPTFLAG						= -Oz
SWIFT_OPTFLAG				= -O -whole-module-optimization -num-threads 1
else
Zinnia_CFLAGS				+= -DDEBUG
ADDITIONAL_SWIFTFLAGS		+= -DDEBUG
endif

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += zinniaprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
