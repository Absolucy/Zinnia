#import <Orion/Orion.h>

__attribute__((constructor)) static void init() {
	// Initialize Orion - do not remove this line.
#ifndef TARGET_IPHONE_SIMULATOR
	orion_init();
#endif
	// Custom initialization code goes here.
}
