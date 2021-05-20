#import "blake3.h"
#import <Foundation/Foundation.h>
#import <stdint.h>

/// Get the current device's UDID in a hard-to-spoof manner.
extern NSString* udid();
/// Get the current device's model identifier in a hard-to-spoof manner.
extern NSString* model();
/// Ensure that the "good" package identifiers are installed, and not the "bad" identifiers.
extern BOOL dpkg_check();
/// Initialize the string table. This should only be run once, during initialization!
extern void initialize_string_table();

/// Get a string from the string table, automatically decrypting it.
/// You must free() this string later!
#ifdef DRM
extern char* st_get(uint32_t idx);
#else
extern char* st_get(const char* name);
#endif

/// Get some arbritrary data from the string table, automatically decrypting it.
/// You must free() this data later!
#ifdef DRM
extern void st_get_bytes(uint32_t idx, void (^callback)(uint8_t*, size_t));
#else
extern void st_get_bytes(const char* name, void (^callback)(uint8_t*, size_t));
#endif
