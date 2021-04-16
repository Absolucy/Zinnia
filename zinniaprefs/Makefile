TARGET := iphone:clang:14.4:14.0
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ZinniaPrefs

ifdef FINALPACKAGE
TARGET_CC =  /opt/apple-llvm-hikari/bin/clang
TARGET_CXX = /opt/apple-llvm-hikari/bin/clang++
endif

ZinniaPrefs_FILES              = ../Sources/Zinnia/DRM.swift \
								$(shell find ../Sources/Zinnia/Prefs -name '*.swift') \
							 $(shell find ../Sources/Zinnia/UI -name '*.swift') \
							 $(shell find ../Sources/ZinniaC/drm -name '*.m' -o -name '*.c') \
                             $(shell find ../Sources/Zinnia/NomaePreferences -name '*.swift')
ZinniaPrefs_INSTALL_PATH = /Library/PreferenceBundles
ZinniaPrefs_SWIFTFLAGS = -I../Sources/ZinniaC/include
ifdef FINALPACKAGE
ZinniaPrefs_CFLAGS             = -Xlinker -x -fobjc-arc -DTHEOS_SWIFT -DDRM -fvisibility=hidden -mllvm --enable-bcfobf -mllvm --enable-splitobf -mllvm --enable-strcry -mllvm --enable-funcwra -mllvm --enable-subobf
ZinniaPrefs_LDFLAGS            = -Xlinker -x
else
ifdef DRM
ZinniaPrefs_CFLAGS             = -fobjc-arc -Wno-error -DTHEOS_SWIFT -DDEBUG -DDRM
else
ZinniaPrefs_CFLAGS             = -fobjc-arc -Wno-error -DTHEOS_SWIFT -DDEBUG
endif
endif
ZinniaPrefs_FRAMEWORKS = AVFoundation
ZinniaPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
