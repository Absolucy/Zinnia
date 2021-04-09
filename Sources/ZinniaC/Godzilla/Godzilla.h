#include <CoreFoundation/CoreFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif

__attribute__((always_inline)) bool check_for_plist();
__attribute__((always_inline)) CFStringRef get_ecid();
__attribute__((always_inline)) CFStringRef get_chip_id();
__attribute__((always_inline)) CFStringRef get_serial();

#ifdef __cplusplus
}
#endif
