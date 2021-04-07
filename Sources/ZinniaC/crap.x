//
//  File.m
//  
//
//  Created by Aspen on 4/7/21.
//

#import <Foundation/Foundation.h>
#import "include/Tweak.h"


void zinnia_open_the_damn_camera() {
	NSLog(@"Zinnia: 1");
	if (%c(SBLockScreenManager)) {
		SBLockScreenManager *manager = (SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance];
		NSLog(@"Zinnia: 2");
		if (manager != nil) {
			NSLog(@"Zinnia: 3");
			CSCoverSheetViewController *lock = [manager coverSheetViewController];
			if (lock != nil) {
				NSLog(@"Zinnia: got the damn lock");
				[lock activatePage:1 animated:NO withCompletion:nil];
			}
		}
	}
}
