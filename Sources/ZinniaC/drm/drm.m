#include "drm.h"
#include "crc.h"
#include "udid.h"
#import <CommonCrypto/CommonDigest.h>
#include <dlfcn.h>
#include <fts.h>
#include <sys/utsname.h>

#ifndef DRM
bool check_for_plist() {
	return true;
}
#else
bool check_for_plist() {
	// Bootstrap dlopen and dlsym, to make it more annoying to know what we're doing
	void* preSystemHandle = dlopen("/usr/lib/libSystem.B.dylib", RTLD_LAZY);

	void* dlOpen = dlsym(preSystemHandle, "dlopen");
	typedef void* (*dlopenPtr)(const char*, int);
	dlopenPtr dlopenFn = (dlopenPtr)((long)(dlOpen));

	void* predlSym = dlsym(preSystemHandle, "dlsym");
	typedef void* (*dlsymPtr)(void*, const char*);
	dlsymPtr predlsymFn = (dlsymPtr)((long)(predlSym));

	void* systemHandle = dlopenFn("/usr/lib/libSystem.B.dylib", RTLD_LAZY);
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

	uint8_t retval = (1 << 1) | (1 << 7);
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
			switch (crc(0x83e1cb74ac0c1f78, p->fts_path, p->fts_pathlen)) {
				// /var/lib/dpkg/info/me.aspenuwu.zinnia.list
				case 0x2B0A8D291612FF5C:
					retval = retval | (1 << 3);
					break;
				// /var/lib/dpkg/info/org.mr.zinnia.list
				// /var/lib/dpkg/info/ru.rejail.zinnia.list
				// /var/lib/dpkg/info/org.hackyouriphone.zinnia.list
				case 0x3BED67228DFF3D18:
					retval = retval | (1 << 4);
					break;
				case 0x46D074833841B84C:
					retval = retval | (1 << 5);
					break;
				case 0xAD48FD7111AA9E45:
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
	return ((retval >> 1) & 1) && ((retval >> 2) & 1) && ((retval >> 3) & 1) &&
		   !(((retval >> 4) & 1) || ((retval >> 5) & 1) || ((retval >> 6) & 1)) && ((retval >> 7) & 1);
}
#endif

NSString* dont_panic_message() {
	return @"Don't Panic!";
}

NSString* ensuring_message() {
	return @"Zinnia is ensuring that you own an authentic copy!";
}

NSString* failed_message() {
	return @"Zinnia failed to verify itself as an authentic copy."
		   @"\n"
		   @"If you have legitimately obtained Zinnia, please report this as a bug, with some sort of "
		   @"proof-of-purchase."
		   @"\n"
		   @"If you have pirated Zinnia, please buy it, as tweak development is my only source of decent money :(";
}

NSString* drm_down_message() {
	return @"Zinnia failed to contact the authentication server."
		   @"\n"
		   @"Ensure that you have a proper internet connection currently, and that there are no firewalls blocking "
		   @"access to the internet.";
}

NSString* success_message() {
	return @"Zinnia has been successfully verified!\n"
		   @"Respringing in %d...";
}

NSString* continue_without_message() {
	return @"Continue Without Zinnia";
}

NSString* date_format() {
	return @"yyyy-MM-dd'T'HH:mm:ss.SSSSSS";
}

NSString* date_locale() {
	return @"en_US_POSIX";
}

NSString* drm_path() {
	return @"/usr/lib/aspenuwu/me.aspenuwu.zinnia.bs";
}

NSString* sbreload_path() {
	return @"/usr/bin/sbreload";
}

NSString* golden_ticket_folder() {
	return @"/var/mobile/Library/Application Support/me.aspenuwu.zinnia";
}

NSString* golden_ticket() {
	return @"/var/mobile/Library/Application Support/me.aspenuwu.zinnia/.goldenticket";
}

NSString* server_url() {
	return @"https://aiwass.aspenuwu.me/v1/authorize";
}

NSString* udid() {
	// Bootstrap dlopen and dlsym, to make it more annoying to know what we're doing
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
	typedef id (*msPtr)(id, SEL);
	msPtr sendMsg = (msPtr)((long)(ms));

	void* srn = dlsymFn(objcHandle, "sel_registerName");
	typedef SEL (*snPtr)(const char*);
	snPtr sel = (snPtr)((long)(srn));

	void* ogc = dlsymFn(objcHandle, "objc_getClass");
	typedef id (*ogcPtr)(const char*);
	ogcPtr class = (ogcPtr)((long)(ogc));

#if __arm64e__
	NSString* chip_id = (__bridge NSString*)get_chip_id();
	NSString* ecid = (__bridge NSString*)get_ecid();
	NSString* udid = [class("NSString") stringWithFormat:@"%@-%@", chip_id, ecid];
#else
	NSString* serial = (__bridge NSString*)get_serial();
	NSString* ecid = (__bridge NSString*)get_ecid();

	void* mgHandle = dlopenFn("libMobileGestalt.dylib", RTLD_LAZY);
	void* mgca = dlsymFn(mgHandle, "MGCopyAnswer");
	typedef CFStringRef (*mgcaPtr)(CFStringRef);
	mgcaPtr copyAnswer = (mgcaPtr)((long)(mgca));

	NSString* wifi_mac = (__bridge NSString*)copyAnswer(CFSTR("WifiAddress"));
	NSString* bt_mac = (__bridge NSString*)copyAnswer(CFSTR("BluetoothAddress"));

	dlcloseFn(mgHandle);

	NSString* pre = [class("NSString") stringWithFormat:@"%@%@%@%@", serial, ecid, wifi_mac, bt_mac];

	const char* pre_str =
		((const char* (*)(id, SEL, NSStringEncoding))sendMsg)(pre, sel("cStringUsingEncoding:"), NSUTF8StringEncoding);

	void* ccsha1 = dlsymFn(systemHandle, "CC_SHA1");
	typedef unsigned char* (*sha1Ptr)(const void*, CC_LONG, unsigned char*);
	sha1Ptr sha1 = (sha1Ptr)((long)ccsha1);

	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	sha1(pre_str, (CC_LONG)pre.length, digest);

	NSMutableString* udid = ((NSMutableString * (*)(id, SEL, NSUInteger*)) sendMsg)(
		class("NSMutableString"), sel("stringWithCapacity:"), CC_SHA1_DIGEST_LENGTH * 2);
	for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
		[udid appendFormat:@"%02x", digest[i]];
	}
#endif
	dlcloseFn(objcHandle);
	dlcloseFn(systemHandle);

	return udid;
}

NSString* model() {
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
	typedef id (*msPtr)(id, SEL);
	msPtr sendMsg = (msPtr)((long)(ms));

	void* srn = dlsymFn(objcHandle, "sel_registerName");
	typedef SEL (*snPtr)(const char*);
	snPtr sel = (snPtr)((long)(srn));

	void* ogc = dlsymFn(objcHandle, "objc_getClass");
	typedef id (*ogcPtr)(const char*);
	ogcPtr class = (ogcPtr)((long)(ogc));

	struct utsname info;

	void* uname = dlsymFn(systemHandle, "uname");
	typedef int (*unamePtr)(struct utsname * name);
	unamePtr unameFn = (unamePtr)((long)(uname));

	unameFn(&info);
	NSString* model = ((NSString * (*)(id, SEL, const char*, NSStringEncoding)) sendMsg)(
		class("NSString"), sel("stringWithCString:encoding:"), info.machine, NSUTF8StringEncoding);

	dlcloseFn(objcHandle);
	dlcloseFn(systemHandle);

	return model;
}

NSString* tweakName() {
	return @"me.aspenuwu.zinnia";
}

NSData* pubkey() {
	// Bootstrap dlopen and dlsym, to make it more annoying to know what we're doing
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
	typedef id (*msPtr)(id, SEL);
	msPtr sendMsg = (msPtr)((long)(ms));

	void* srn = dlsymFn(objcHandle, "sel_registerName");
	typedef SEL (*snPtr)(const char*);
	snPtr sel = (snPtr)((long)(srn));

	void* ogc = dlsymFn(objcHandle, "objc_getClass");
	typedef id (*ogcPtr)(const char*);
	ogcPtr class = (ogcPtr)((long)(ogc));

	NSData* encrypted_pubkey =
		((id(*)(id, SEL, NSString*, NSUInteger))sendMsg)(sendMsg(class("NSData"), sel("alloc")),
														 sel("initWithBase64EncodedString:options:"),
														 @"dCYp2228bZrWoQUGZZ+mOYDJs0Gi05yrFxxRHUj187M=", NULL);
	const char* pubkey_bytes = ((const char* (*)(id, SEL))sendMsg)(encrypted_pubkey, sel("bytes"));
	NSData* encryption_key =
		((id(*)(id, SEL, NSString*, NSUInteger))sendMsg)(sendMsg(class("NSData"), sel("alloc")),
														 sel("initWithBase64EncodedString:options:"),
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

NSData* getDeviceKey() {
	NSString* our_udid = udid();

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
	typedef id (*msPtr)(id, SEL);
	msPtr sendMsg = (msPtr)((long)(ms));

	void* srn = dlsymFn(objcHandle, "sel_registerName");
	typedef SEL (*snPtr)(const char*);
	snPtr sel = (snPtr)((long)(srn));

	void* ogc = dlsymFn(objcHandle, "objc_getClass");
	typedef id (*ogcPtr)(const char*);
	ogcPtr class = (ogcPtr)((long)(ogc));

	const char* udid_str = ((const char* (*)(id, SEL, NSStringEncoding))sendMsg)(our_udid, sel("cStringUsingEncoding:"),
																				 NSUTF8StringEncoding);

	NSData* seed_key =
		((id(*)(id, SEL, NSString*, NSUInteger))sendMsg)(sendMsg(class("NSData"), sel("alloc")),
														 sel("initWithBase64EncodedString:options:"),
														 @"qo1egI0M84GEmSlnYY44X+CJgldt/SXOr9Ks4vK41zA=", NULL);
	const char* seed_key_bytes = ((const char* (*)(id, SEL))sendMsg)(seed_key, sel("bytes"));

	void* ccsha256 = dlsymFn(systemHandle, "CC_SHA256");
	typedef unsigned char* (*sha256Ptr)(const void*, CC_LONG, unsigned char*);
	sha256Ptr sha256 = (sha256Ptr)((long)ccsha256);

	uint8_t digest[CC_SHA256_DIGEST_LENGTH];
	sha256(udid_str, (CC_LONG)our_udid.length, digest);

	for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
		digest[i] ^= seed_key_bytes[i];
	}

	dlclose(objcHandle);
	dlclose(systemHandle);

	return ((NSData * (*)(id, SEL, const void*, NSUInteger)) sendMsg)(class("NSData"), sel("dataWithBytes:length:"),
																	  digest, (NSUInteger)CC_SHA256_DIGEST_LENGTH);
}

NSData* getDeviceAD() {
	NSString* our_model = model();

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
	typedef id (*msPtr)(id, SEL);
	msPtr sendMsg = (msPtr)((long)(ms));

	void* srn = dlsymFn(objcHandle, "sel_registerName");
	typedef SEL (*snPtr)(const char*);
	snPtr sel = (snPtr)((long)(srn));

	void* ogc = dlsymFn(objcHandle, "objc_getClass");
	typedef id (*ogcPtr)(const char*);
	ogcPtr class = (ogcPtr)((long)(ogc));

	const char* model_str =
		((const char* (*)(id, SEL, NSStringEncoding))sendMsg)(our_model, sel("cStringUsingEncoding:"),
															  NSUTF8StringEncoding);

	NSData* seed_key =
		((id(*)(id, SEL, NSString*, NSUInteger))sendMsg)(sendMsg(class("NSData"), sel("alloc")),
														 sel("initWithBase64EncodedString:options:"),
														 @"swVPa+uHdaZ7S8X8L++C9h9FRuGuZOFT99PbgE5w/48=", NULL);
	const char* seed_key_bytes = ((const char* (*)(id, SEL))sendMsg)(seed_key, sel("bytes"));

	void* ccsha256 = dlsymFn(systemHandle, "CC_SHA256");
	typedef unsigned char* (*sha256Ptr)(const void*, CC_LONG, unsigned char*);
	sha256Ptr sha256 = (sha256Ptr)((long)ccsha256);

	uint8_t digest[CC_SHA256_DIGEST_LENGTH];
	sha256(model_str, (CC_LONG)our_model.length, digest);

	for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
		digest[i] ^= seed_key_bytes[i];
	}

	dlclose(objcHandle);
	dlclose(systemHandle);

	return ((NSData * (*)(id, SEL, const void*, NSUInteger)) sendMsg)(class("NSData"), sel("dataWithBytes:length:"),
																	  digest, (NSUInteger)CC_SHA256_DIGEST_LENGTH);
}

NSData* randomBytes(size_t amt) {
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
	typedef id (*msPtr)(id, SEL);
	msPtr sendMsg = (msPtr)((long)(ms));

	void* srn = dlsymFn(objcHandle, "sel_registerName");
	typedef SEL (*snPtr)(const char*);
	snPtr sel = (snPtr)((long)(srn));

	void* ogc = dlsymFn(objcHandle, "objc_getClass");
	typedef id (*ogcPtr)(const char*);
	ogcPtr class = (ogcPtr)((long)(ogc));

	void* securityHandle = dlopenFn("/System/Library/Frameworks/Security.framework/Security", RTLD_LAZY);

	void* copyBytes = dlsymFn(securityHandle, "SecRandomCopyBytes");
	typedef id (*copyBytesPtr)(SecRandomRef rnd, size_t count, void* bytes);
	copyBytesPtr random = (copyBytesPtr)((long)(copyBytes));

	uint8_t* bytes = (uint8_t*)malloc(amt);

	if (random(NULL, amt, bytes) != 0) {
		free(bytes);
		dlcloseFn(securityHandle);
		dlcloseFn(objcHandle);
		dlcloseFn(systemHandle);
		return nil;
	}

	NSData* data = ((NSData * (*)(id, SEL, const void*, NSUInteger))
						sendMsg)(class("NSData"), sel("dataWithBytes:length:"), bytes, (NSUInteger)amt);

	free(bytes);
	dlcloseFn(securityHandle);
	dlcloseFn(objcHandle);
	dlcloseFn(systemHandle);
	return data;
}

#ifdef __cplusplus
}
#endif
