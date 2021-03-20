#import <Orion/Orion.h>
__attribute__((constructor)) static void init() {
	// Initialize Orion - do not remove this line.
#if !TARGET_IPHONE_SIMULATOR
	NSLog(@"Zinnia: loaded");
	orion_init();
#endif
	// Custom initialization code goes here.
}
