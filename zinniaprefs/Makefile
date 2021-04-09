TARGET := iphone:clang:latest:12.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ZinniaPrefs

ZinniaPrefs_FILES = $(shell find Sources/ZinniaPrefs -name '*.swift') $(shell find Sources/ZinniaPrefsC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
ZinniaPrefs_INSTALL_PATH = /Library/PreferenceBundles
ZinniaPrefs_SWIFTFLAGS = -ISources/ZinniaPrefsC/include
ZinniaPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
