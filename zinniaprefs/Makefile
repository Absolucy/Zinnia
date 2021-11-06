TARGET := iphone:clang:14.4:14.0
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ZinniaPrefs

ZinniaPrefs_FILES				= $(shell find ../Sources/Zinnia/NomaePreferences -name '*.swift') \
									$(shell find ../Sources/Zinnia/Prefs -name '*.swift') \
									$(shell find ../Sources/Zinnia/UI -name '*.swift') \
									$(shell find ../Sources/ZinniaC/interface -name 'wallpaper.m')
ZinniaPrefs_INSTALL_PATH		= /Library/PreferenceBundles
ZinniaPrefs_SWIFTFLAGS			= -I../Sources/ZinniaC/include
ZinniaPrefs_CFLAGS				= -fobjc-arc -DTHEOS_SWIFT -DZINNIAPREFS
ADDITIONAL_SWIFTFLAGS			= -DTHEOS_SWIFT -DZINNIAPREFS
ZinniaPrefs_FRAMEWORKS			= AVFoundation
ZinniaPrefs_PRIVATE_FRAMEWORKS	= AppSupport

include $(THEOS_MAKE_PATH)/bundle.mk
