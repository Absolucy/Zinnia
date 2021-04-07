//
//  File.m
//  
//
//  Created by Aspen on 4/7/21.
//

#import <Foundation/Foundation.h>
#import "include/Tweak.h"


void zinnia_open_the_damn_camera() {
	if (%c(SBLockScreenManager)) {
		SBLockScreenManager *manager = (SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance];
		if (manager != nil) {
			CSCoverSheetViewController *lock = [manager coverSheetViewController];
			if (lock != nil) {
				[lock activatePage:2 animated:NO withCompletion:nil];
			}
		}
	}
}
