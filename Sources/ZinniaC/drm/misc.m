#import "../include/Tweak.h"
#import <Foundation/Foundation.h>

UIImage* lockScreenWallpaper() {
	NSData* lockWallpaperData =
		[NSData dataWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackground.cpbitmap"];
	CFDataRef lockWallpaperDataRef = (__bridge CFDataRef)lockWallpaperData;
	NSArray* imageArray = (__bridge NSArray*)CPBitmapCreateImagesFromData(lockWallpaperDataRef, NULL, 1, NULL);
	return [UIImage imageWithCGImage:(CGImageRef)imageArray[0]];
}
