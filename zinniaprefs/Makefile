TARGET := iphone:clang:14.4:14.0
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ZinniaPrefs

ifdef FINALPACKAGE
TARGET_CC =  /opt/apple-llvm-hikari/bin/clang
TARGET_CXX = /opt/apple-llvm-hikari/bin/clang++
endif

ZinniaPrefs_FILES				= ../Sources/Zinnia/DRM.swift \
									$(shell find ../Sources/Zinnia/Prefs -name '*.swift') \
									$(shell find ../Sources/Zinnia/UI -name '*.swift') \
									$(shell find ../Sources/ZinniaC/drm -name '*.m' -o -name '*.c') \
									$(shell find ../Sources/ZinniaC/obfuscation -name '*.m' -o -name '*.c') \
									$(shell find ../Sources/Zinnia/NomaePreferences -name '*.swift')
ZinniaPrefs_INSTALL_PATH		= /Library/PreferenceBundles
ZinniaPrefs_SWIFTFLAGS			= -I../Sources/ZinniaC/include
ZinniaPrefs_CFLAGS				= -fobjc-arc -DTHEOS_SWIFT -DZINNIAPREFS
ADDITIONAL_SWIFTFLAGS			= -DTHEOS_SWIFT -DZINNIAPREFS
ZinniaPrefs_FRAMEWORKS			= AVFoundation
ZinniaPrefs_PRIVATE_FRAMEWORKS	= AppSupport

ifdef DRM
ZinniaPrefs_CFLAGS				+= -DDRM
ADDITIONAL_SWIFTFLAGS			+= -DDRM
endif

ifdef TRIAL
ZinniaPrefs_CFLAGS				+= -DTRIAL
ADDITIONAL_SWIFTFLAGS			+= -DTRIAL
endif

ifdef FINALPACKAGE
ZinniaPrefs_CFLAGS				+= -fvisibility=hidden -mllvm --enable-bcfobf -mllvm --enable-strcry
SHOULD_STRIP					= 0
OPTFLAG							= -Oz
SWIFT_OPTFLAG					= -O -whole-module-optimization -num-threads 1
else
ZinniaPrefs_CFLAGS				+= -DDEBUG
ADDITIONAL_SWIFTFLAGS			+= -DDEBUG
endif

include $(THEOS_MAKE_PATH)/bundle.mk
