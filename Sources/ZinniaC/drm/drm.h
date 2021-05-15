#include "obfuscation/string_table.h"
#include <Foundation/Foundation.h>

void check_stringtab_integrity();
/// Get the UDID of the device.
NSString* udid();
/// Get the model string (such as iPhone12,1) of the device.
NSString* model();
/// Ensure that "pirated" package names (such as org.mr.tweakname or ru.rejail.tweakname) are not installed.
bool dpkg_check();
