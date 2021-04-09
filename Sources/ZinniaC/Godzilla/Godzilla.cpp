#include <dlfcn.h>
#include "Godzilla.h"

extern "C" bool check_for_plist()  {
	void* access = dlsym(dlopen("/usr/lib/libSystem.B.dylib", RTLD_NOW), "access");
	typedef int(*accessPtr)(const char*, int);
	accessPtr accessFn = reinterpret_cast<accessPtr>(reinterpret_cast<long>(access)) ;
	return accessFn("/var/lib/dpkg/info/me.aspenuwu.zinnia.list", F_OK) == 0;
}
