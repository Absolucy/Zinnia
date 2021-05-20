#import "popups.h"
#import "../include/Tweak.h"
#import "../include/bridge.h"
#import <Foundation/Foundation.h>

extern BOOL dpkg_check();

void zinnia_unlock() {
	[[NSClassFromString(@"SpringBoard") performSelector:@selector(sharedApplication)]
		performSelector:@selector(_simulateHomeButtonPress)];
	// we do a little trolling
	if (!dpkg_check())
		((void (*)())NULL)();
}

void zinnia_camera() {
	[csvc activatePage:1 animated:YES withCompletion:nil];
	if (!dpkg_check() || !isValidated())
		((void (*)())NULL)();
}
