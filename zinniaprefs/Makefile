TARGET := iphone:clang:14.4:14.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ZinniaPrefs

ZinniaPrefs_FILES              = $(shell find ../Sources/ZinniaPrefs -name '*.swift') \
							 $(shell find ../Sources/ZinniaUI -name '*.swift') \
                             $(shell find ../Sources/NomaePreferences -name '*.swift') \
							 ../Sources/ZinniaC/libpddokdo.m
ZinniaPrefs_INSTALL_PATH = /Library/PreferenceBundles
ZinniaPrefs_SWIFTFLAGS = -I../Sources/ZinniaC/include
ZinniaPrefs_FRAMEWORKS = AVFoundation
ZinniaPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
