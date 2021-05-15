#include <CommonCrypto/CommonDigest.h>
#include <CoreFoundation/CoreFoundation.h>
#include <Foundation/Foundation.h>
#include <dlfcn.h>
#include <mach/mach.h>
#include <sys/sysctl.h>

typedef char io_name_t[128];
typedef mach_port_t io_object_t;
typedef io_object_t io_registry_entry_t;
typedef io_object_t io_service_t;

typedef kern_return_t (*_IOObjectRelease)(io_object_t object);
typedef CFMutableDictionaryRef (*_IOServiceMatching)(const char* name);
typedef io_service_t (*_IOServiceGetMatchingService)(mach_port_t masterPort, CFDictionaryRef matching);
typedef CFTypeRef (*_IORegistryEntrySearchCFProperty)(io_registry_entry_t entry, const io_name_t plane, CFStringRef key,
													  CFAllocatorRef allocator, uint32_t options);
typedef CFTypeRef (*_IORegistryEntryCreateCFProperty)(io_registry_entry_t entry, CFStringRef key,
													  CFAllocatorRef allocator, uint32_t options);

#define kIODeviceTreePlane "IODeviceTree"

static CFStringRef get_ecid() {
	void* io_kit_framework = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_LAZY);
	mach_port_t* kIOMasterPortDefault = (mach_port_t*)dlsym(io_kit_framework, "kIOMasterPortDefault");
	_IOObjectRelease IOObjectRelease = (_IOObjectRelease)dlsym(io_kit_framework, "IOObjectRelease");
	_IOServiceMatching IOServiceMatching = (_IOServiceMatching)dlsym(io_kit_framework, "IOServiceMatching");
	_IOServiceGetMatchingService IOServiceGetMatchingService =
		(_IOServiceGetMatchingService)dlsym(io_kit_framework, "IOServiceGetMatchingService");
	_IORegistryEntrySearchCFProperty IORegistryEntrySearchCFProperty =
		(_IORegistryEntrySearchCFProperty)dlsym(io_kit_framework, "IORegistryEntrySearchCFProperty");

	CFStringRef ecid_string = NULL;
	CFDataRef ecid_data = NULL;
	io_service_t platform_expert;
	if ((platform_expert =
			 IOServiceGetMatchingService(*kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice")))) {
#ifdef __arm64e__
		if ((ecid_data = (CFDataRef)IORegistryEntrySearchCFProperty(platform_expert, kIODeviceTreePlane,
																	CFSTR("unique-chip-id"), kCFAllocatorDefault,
																	kIORegistryIterateRecursively)))
		{
			UInt64* ecid_bytes_ptr = (UInt64*)CFDataGetBytePtr(ecid_data);
			ecid_string = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%016llX"), *ecid_bytes_ptr);
			CFRelease(ecid_data);
		}
#else
		if ((ecid_data = (CFDataRef)IORegistryEntrySearchCFProperty(platform_expert, kIODeviceTreePlane,
																	CFSTR("unique-chip-id"), kCFAllocatorDefault,
																	kIORegistryIterateRecursively)))
		{
			UInt64* ecid_bytes_ptr = (UInt64*)CFDataGetBytePtr(ecid_data);
			ecid_string = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%llu"), *ecid_bytes_ptr);
			CFRelease(ecid_data);
		}
#endif
	}
	IOObjectRelease(platform_expert);
	dlclose(io_kit_framework);
	return ecid_string;
}

static CFStringRef get_chip_id() {
	void* io_kit_framework = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_LAZY);
	mach_port_t* kIOMasterPortDefault = (mach_port_t*)dlsym(io_kit_framework, "kIOMasterPortDefault");
	_IOObjectRelease IOObjectRelease = (_IOObjectRelease)dlsym(io_kit_framework, "IOObjectRelease");
	_IOServiceMatching IOServiceMatching = (_IOServiceMatching)dlsym(io_kit_framework, "IOServiceMatching");
	_IOServiceGetMatchingService IOServiceGetMatchingService =
		(_IOServiceGetMatchingService)dlsym(io_kit_framework, "IOServiceGetMatchingService");
	_IORegistryEntrySearchCFProperty IORegistryEntrySearchCFProperty =
		(_IORegistryEntrySearchCFProperty)dlsym(io_kit_framework, "IORegistryEntrySearchCFProperty");

	CFStringRef chip_string = NULL;
	io_service_t platform_expert;
	if ((platform_expert =
			 IOServiceGetMatchingService(*kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice")))) {
		CFDataRef chip_data = NULL;
		if ((chip_data =
				 (CFDataRef)IORegistryEntrySearchCFProperty(platform_expert, kIODeviceTreePlane, CFSTR("chip-id"),
															kCFAllocatorDefault, kIORegistryIterateRecursively)))
		{
			UInt64* chip_bytes_ptr = (UInt64*)CFDataGetBytePtr(chip_data);
			chip_string = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%08llX"), *chip_bytes_ptr);
			CFRelease(chip_data);
		}
	}
	IOObjectRelease(platform_expert);
	dlclose(io_kit_framework);
	return chip_string;
}

static CFStringRef get_serial() {
	void* io_kit_framework = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_LAZY);
	mach_port_t* kIOMasterPortDefault = (mach_port_t*)dlsym(io_kit_framework, "kIOMasterPortDefault");
	_IOObjectRelease IOObjectRelease = (_IOObjectRelease)dlsym(io_kit_framework, "IOObjectRelease");
	_IOServiceMatching IOServiceMatching = (_IOServiceMatching)dlsym(io_kit_framework, "IOServiceMatching");
	_IOServiceGetMatchingService IOServiceGetMatchingService =
		(_IOServiceGetMatchingService)dlsym(io_kit_framework, "IOServiceGetMatchingService");
	_IORegistryEntryCreateCFProperty IORegistryEntryCreateCFProperty =
		(_IORegistryEntryCreateCFProperty)dlsym(io_kit_framework, "IORegistryEntryCreateCFProperty");

	CFDataRef sn_data = NULL;
	io_service_t platform_expert;
	if ((platform_expert =
			 IOServiceGetMatchingService(*kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice")))) {
		sn_data = (CFDataRef)IORegistryEntryCreateCFProperty(platform_expert, CFSTR("IOPlatformSerialNumber"),
															 kCFAllocatorDefault, kIORegistryIterateRecursively);
	}
	IOObjectRelease(platform_expert);
	dlclose(io_kit_framework);
	return (CFStringRef)sn_data;
}

NSString* udid() {

#if __arm64e__
	NSString* chip_id = (__bridge NSString*)get_chip_id();
	NSString* ecid = (__bridge NSString*)get_ecid();
	NSString* udid = [NSString stringWithFormat:@"%@-%@", chip_id, ecid];
#else
	NSString* serial = (__bridge NSString*)get_serial();
	NSString* ecid = (__bridge NSString*)get_ecid();

	void* mgHandle = dlopen("libMobileGestalt.dylib", RTLD_LAZY);
	void* mgca = dlsym(mgHandle, "MGCopyAnswer");
	typedef CFStringRef (*mgcaPtr)(CFStringRef);
	mgcaPtr copyAnswer = (mgcaPtr)((long)(mgca));

	NSString* wifi_mac = (__bridge NSString*)copyAnswer(CFSTR("WifiAddress"));
	NSString* bt_mac = (__bridge NSString*)copyAnswer(CFSTR("BluetoothAddress"));

	dlclose(mgHandle);

	NSString* pre = [NSString stringWithFormat:@"%@%@%@%@", serial, ecid, wifi_mac, bt_mac];

	const char* pre_str = [pre cStringUsingEncoding:NSUTF8StringEncoding];

	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(pre_str, (CC_LONG)pre.length, digest);

	NSMutableString* udid = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
		[udid appendFormat:@"%02x", digest[i]];
	}
#endif

	return udid;
}

NSString* model() {

	size_t len = 32;
	int mib[2] = {CTL_HW, HW_MACHINE};
	char* name = (char*)malloc(32);

	register int* sysctl_name asm("x0") = mib;
	register uint sysctl_len asm("x1") = 2;
	register void* sysctl_old asm("x2") = name;
	register size_t* sysctl_old_len asm("x3") = &len;
	register const void* sysctl_new asm("x4") = NULL;
	register size_t sysctl_new_len asm("x5") = 0;
	register long syscall asm("x16") = 202;

	// This is equivalent to sysctlbyname("hw.machine")
	asm volatile("svc #0x80" // syscall instruction
				 : "=r"(sysctl_name), "=r"(sysctl_len)
				 : "r"(sysctl_name), "r"(sysctl_len), "r"(sysctl_old), "r"(sysctl_old_len), "r"(sysctl_new),
				   "r"(sysctl_new_len), "r"(syscall)
				 : "memory", "cc");

	NSString* model = [[NSString alloc] initWithBytesNoCopy:sysctl_old
													 length:32
												   encoding:NSUTF8StringEncoding
											   freeWhenDone:YES];

	return model;
}
