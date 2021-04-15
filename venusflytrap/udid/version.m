#include <Foundation/Foundation.h>
#include <dlfcn.h>

NSOperatingSystemVersion get_version_info() {
	void* preSystemHandle = dlopen("/usr/lib/libSystem.B.dylib", RTLD_LAZY);

	void* predlOpen = dlsym(preSystemHandle, "dlopen");
	typedef void* (*dlopenPtr)(const char*, int);
	dlopenPtr predlopenFn = (dlopenPtr)((long)(predlOpen));

	void* predlSym = dlsym(preSystemHandle, "dlsym");
	typedef void* (*dlsymPtr)(void*, const char*);
	dlsymPtr predlsymFn = (dlsymPtr)((long)(predlSym));

	void* systemHandle = predlopenFn("/usr/lib/libSystem.B.dylib", RTLD_LAZY);
	dlsymPtr dlsymFn = (dlsymPtr)((long)predlsymFn(systemHandle, "dlsym"));

	void* dlClose = dlsymFn(systemHandle, "dlclose");
	typedef void* (*dlclosePtr)(void*);
	dlclosePtr dlcloseFn = (dlclosePtr)((long)(dlClose));

	void* dlOpen = dlsymFn(systemHandle, "dlopen");
	dlopenPtr dlopenFn = (dlopenPtr)((long)(dlOpen));

	dlcloseFn(preSystemHandle);

	void* objcHandle = dlopenFn("/usr/lib/libobjc.A.dylib", RTLD_LAZY);

	void* ms = dlsymFn(objcHandle, "objc_msgSend");
	typedef id(*msPtr)(id, SEL);
	msPtr sendMsg = (msPtr)((long)(ms));

	void* srn = dlsymFn(objcHandle, "sel_registerName");
	typedef SEL(*snPtr)(const char*);
	snPtr sel = (snPtr)((long)(srn));

	void* ogc = dlsymFn(objcHandle, "objc_getClass");
	typedef id(*ogcPtr)(const char*);
	ogcPtr class = (ogcPtr)((long)(ogc));


	NSProcessInfo* process_info = ((NSProcessInfo*(*)(id, SEL, NSString*))sendMsg)(class("NSProcessInfo"), sel("valueForKey:"), @"processInfo");

	NSOperatingSystemVersion v = ((NSOperatingSystemVersion(*)(NSProcessInfo*, SEL))sendMsg)(process_info, sel("operatingSystemVersion"));

	dlcloseFn(objcHandle);
	dlcloseFn(systemHandle);
	return v;
}
