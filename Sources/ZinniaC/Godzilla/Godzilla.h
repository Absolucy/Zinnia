#include <CoreFoundation/CoreFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif

bool check_for_plist();
CFStringRef get_ecid();
CFStringRef get_chip_id();
CFStringRef get_serial();

#ifdef __cplusplus
}
#endif
