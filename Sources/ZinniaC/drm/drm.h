#include <Foundation/Foundation.h>

bool check_for_plist();
NSString* dont_panic_message();
NSString* failed_message();
NSString* continue_without_message();
NSString* drm_down_message();
NSString* success_message();
NSString* date_format();
NSString* date_locale();
NSString* drm_path();
NSString* sbreload_path();
NSString* golden_ticket_folder();
NSString* golden_ticket();
NSString* server_url();
NSString* udid();
NSString* model();
NSString* tweakName();
NSData* pubkey();
NSData* getDeviceKey();
NSData* getDeviceAD();
NSData* randomBytes(size_t amt);

void runDrm();
