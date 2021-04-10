#include <dlfcn.h>
#include <Foundation/Foundation.h>
#include <CommonCrypto/CommonCrypto.h>
#include "drm.h"

#ifdef __cplusplus
extern "C" {
#endif

bool check_for_plist()  {
	void* access = dlsym(dlopen("/usr/lib/libSystem.B.dylib", RTLD_NOW), "access");
	typedef int(*accessPtr)(const char*, int);
	accessPtr accessFn = (accessPtr)((long)(access));
	return accessFn("/var/lib/dpkg/info/me.aspenuwu.zinnia.list", F_OK) == 0
		&& accessFn("/var/lib/dpkg/info/org.mr.zinnia.list", F_OK) != 0
		&& accessFn("/var/lib/dpkg/info/ru.rejail.zinnia.list", F_OK) != 0
		&& accessFn("/var/lib/dpkg/info/org.hackyouriphone.zinnia.list", F_OK) != 0;
}

#ifdef __cplusplus
}
#endif
