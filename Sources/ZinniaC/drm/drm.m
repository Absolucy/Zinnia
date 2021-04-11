#include "drm.h"
#include "byond32.h"
#include <dlfcn.h>
#include <fts.h>
#include <mach-o/dyld.h>
#include <mach-o/dyld_images.h>
#include <mach-o/nlist.h>
#include <mach/mach_vm.h>

#ifdef __cplusplus
extern "C" {
#endif

bool check_for_plist() {
	// Bootstrap dlopen and dlsym, to make it more annoying to know what we're doing
	void* preSystemHandle = dlopen("/usr/lib/libSystem.B.dylib", RTLD_NOW);

	void* dlOpen = dlsym(preSystemHandle, "dlopen");
	typedef void* (*dlopenPtr)(const char*, int);
	dlopenPtr dlopenFn = (dlopenPtr)((long)(dlOpen));

	void* predlSym = dlsym(preSystemHandle, "dlsym");
	typedef void* (*dlsymPtr)(void*, const char*);
	dlsymPtr predlsymFn = (dlsymPtr)((long)(predlSym));

	void* systemHandle = dlopenFn("/usr/lib/libSystem.B.dylib", RTLD_NOW);
	dlsymPtr dlsymFn = (dlsymPtr)((long)predlsymFn(systemHandle, "dlsym"));

	void* dlClose = dlsymFn(systemHandle, "dlclose");
	typedef void* (*dlclosePtr)(void*);
	dlclosePtr dlcloseFn = (dlclosePtr)((long)(dlClose));

	dlcloseFn(preSystemHandle);

	void* access = dlsymFn(systemHandle, "access");
	typedef int (*accessPtr)(const char*, int);
	accessPtr accessFn = (accessPtr)((long)(access));

	void* ftsOpen = dlsymFn(systemHandle, "fts_open");
	typedef FTS* (*ftsOpenPtr)(char* const*, int, int (*)(const FTSENT**, const FTSENT**));
	ftsOpenPtr ftsOpenFn = (ftsOpenPtr)((long)(ftsOpen));

	void* ftsChildren = dlsymFn(systemHandle, "fts_children");
	typedef FTSENT* (*ftsChildrenPtr)(FTS*, int);
	ftsChildrenPtr ftsChildrenFn = (ftsChildrenPtr)((long)(ftsChildren));

	void* ftsRead = dlsymFn(systemHandle, "fts_read");
	typedef FTSENT* (*ftsReadPtr)(FTS*);
	ftsReadPtr ftsReadFn = (ftsReadPtr)((long)(ftsRead));

	void* ftsClose = dlsymFn(systemHandle, "fts_close");
	typedef int (*ftsClosePtr)(FTS*);
	ftsClosePtr ftsCloseFn = (ftsClosePtr)((long)(ftsClose));

	FTS* ftsp;
	FTSENT *p, *chp;
	int rval = 0;

	uint8_t retval = 0;
	char* paths[] = {"/var/lib/dpkg/info", NULL};

	if ((ftsp = ftsOpenFn(paths, 45 ^ 42, NULL)) == NULL) {
		return false;
	}
	/* Initialize ftsp with as many argv[] parts as possible. */
	chp = ftsChildrenFn(ftsp, 0);
	if (chp == NULL) {
		return false;
	}
	while ((p = ftsReadFn(ftsp)) != NULL) {
		if ((p->fts_info ^ 34) == 42) {
			switch (byond32(0xFFFFFFFF, p->fts_path, p->fts_pathlen)) {
				// /var/lib/dpkg/info/me.aspenuwu.zinnia.list
				case 0xd7e2f228:
					retval = retval | (1 << 3);
					break;
				// /var/lib/dpkg/info/org.mr.zinnia.list
				// /var/lib/dpkg/info/ru.rejail.zinnia.list
				// /var/lib/dpkg/info/org.hackyouriphone.zinnia.list
				case 0x955489a2:
					retval = retval | (1 << 4);
					break;
				case 0x78607499:
					retval = retval | (1 << 5);
					break;
				case 0x6433c423:
					retval = retval | (1 << 6);
					break;
				default:
					break;
			}
		}
	}
	ftsCloseFn(ftsp);

	if (accessFn("/var/lib/dpkg/info/me.aspenuwu.zinnia.list", F_OK) == 0) {
		retval = retval | (1 << 2);
	}
	dlcloseFn(systemHandle);
	return ((retval >> 2) & 1) && ((retval >> 3) & 1) &&
		   !(((retval >> 4) & 1) || ((retval >> 5) & 1) || ((retval >> 6) & 1));
}

NSString* golden_ticket_folder() {
	return @"/var/mobile/Library/Application Support/me.aspenuwu.zinnia";
}

NSString* golden_ticket() {
	return @"/var/mobile/Library/Application Support/me.aspenuwu.zinnia/.goldenticket";
}

NSData* pubkey() {
	// Bootstrap dlopen and dlsym, to make it more annoying to know what we're doing
	void* preSystemHandle = dlopen("/usr/lib/libSystem.B.dylib", RTLD_NOW);

	void* predlOpen = dlsym(preSystemHandle, "dlopen");
	typedef void* (*dlopenPtr)(const char*, int);
	dlopenPtr predlopenFn = (dlopenPtr)((long)(predlOpen));

	void* predlSym = dlsym(preSystemHandle, "dlsym");
	typedef void* (*dlsymPtr)(void*, const char*);
	dlsymPtr predlsymFn = (dlsymPtr)((long)(predlSym));

	void* systemHandle = predlopenFn("/usr/lib/libSystem.B.dylib", RTLD_NOW);
	dlsymPtr dlsymFn = (dlsymPtr)((long)predlsymFn(systemHandle, "dlsym"));

	void* dlClose = dlsymFn(systemHandle, "dlclose");
	typedef void* (*dlclosePtr)(void*);
	dlclosePtr dlcloseFn = (dlclosePtr)((long)(dlClose));

	void* dlOpen = dlsymFn(systemHandle, "dlopen");
	dlopenPtr dlopenFn = (dlopenPtr)((long)(dlOpen));

	dlcloseFn(preSystemHandle);

	void* objcHandle = dlopenFn("/usr/lib/libobjc.A.dylib", RTLD_NOW);

	void* ms = dlsymFn(objcHandle, "objc_msgSend");
	typedef id (*msPtr)(id, SEL);
	msPtr sendMsg = (msPtr)((long)(ms));

	void* srn = dlsymFn(objcHandle, "sel_registerName");
	typedef SEL (*snPtr)(const char*);
	snPtr sel = (snPtr)((long)(srn));

	void* ogc = dlsymFn(objcHandle, "objc_getClass");
	typedef id (*ogcPtr)(const char*);
	ogcPtr class = (ogcPtr)((long)(ogc));

	NSData* encrypted_pubkey = ((id(*)(id, SEL, NSString*, NSUInteger))sendMsg)(
		sendMsg(class("NSData"), sel("alloc")), sel("initWithBase64EncodedString:options:"),
		@"N6eL73O9CCRDs7Qop1pMvS33SFw1+VfcDDLpTqYMxiQ=", NULL);
	const char* pubkey_bytes = ((const char* (*)(id, SEL))sendMsg)(encrypted_pubkey, sel("bytes"));
	NSData* encryption_key = ((id(*)(id, SEL, NSString*, NSUInteger))sendMsg)(
		sendMsg(class("NSData"), sel("alloc")), sel("initWithBase64EncodedString:options:"),
		@"TOLzf/wZPUmecFPA/r9FGOAp72Z4F6/O1MgPoA/0o4s=", NULL);
	const char* encryption_key_bytes = ((const char* (*)(id, SEL))sendMsg)(encryption_key, sel("bytes"));
	NSMutableData* decrypted_pubkey = sendMsg(sendMsg(class("NSMutableData"), sel("alloc")), sel("init"));

	for (int i = 0; i < encrypted_pubkey.length; i++) {
		const char decrypted = pubkey_bytes[i] ^ encryption_key_bytes[i];
		((void (*)(id, SEL, const char*, NSUInteger))sendMsg)(decrypted_pubkey, sel("appendBytes:length:"), &decrypted,
															  1);
	}
	dlcloseFn(objcHandle);
	dlcloseFn(systemHandle);
	return decrypted_pubkey;
}

#ifdef __cplusplus
}
#endif
