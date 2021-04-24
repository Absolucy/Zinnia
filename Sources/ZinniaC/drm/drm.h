#include <Foundation/Foundation.h>

bool check_for_plist();
NSString* udid();
NSString* model();
NSString* tweakName();
NSData* pubkey();
NSData* getDeviceKey();
NSData* getDeviceAD();
NSData* randomBytes(size_t amt);

void runDrm();
