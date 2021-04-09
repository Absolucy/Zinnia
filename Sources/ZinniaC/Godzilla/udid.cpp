#include "iokit.h"
#include "Godzilla.h"
#include <dlfcn.h>

typedef kern_return_t (*_IOObjectRelease)(io_object_t object);
typedef CFMutableDictionaryRef (*_IOServiceMatching)(const char* name);
typedef io_service_t (*_IOServiceGetMatchingService)(mach_port_t masterPort, CFDictionaryRef matching);
typedef CFTypeRef (*_IORegistryEntrySearchCFProperty)(io_registry_entry_t entry, const io_name_t plane, CFStringRef key,
													  CFAllocatorRef allocator, uint32_t options);
typedef CFTypeRef (*_IORegistryEntryCreateCFProperty)(io_registry_entry_t entry, CFStringRef key,
													  CFAllocatorRef allocator, uint32_t options);

#define kIODeviceTreePlane "IODeviceTree"

extern "C" CFStringRef get_ecid() {
	void* io_kit_framework =
		dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_LAZY);
	mach_port_t* kIOMasterPortDefault =
		(mach_port_t*)dlsym(io_kit_framework, "kIOMasterPortDefault");
	_IOObjectRelease IOObjectRelease =
		(_IOObjectRelease)dlsym(io_kit_framework, "IOObjectRelease");
	_IOServiceMatching IOServiceMatching =
		(_IOServiceMatching)dlsym(io_kit_framework, "IOServiceMatching");
	_IOServiceGetMatchingService IOServiceGetMatchingService =
		(_IOServiceGetMatchingService)dlsym(io_kit_framework, "IOServiceGetMatchingService");
	_IORegistryEntrySearchCFProperty IORegistryEntrySearchCFProperty = (_IORegistryEntrySearchCFProperty)dlsym(
		io_kit_framework, "IORegistryEntrySearchCFProperty");

	CFStringRef ecid_string = NULL;
	CFDataRef ecid_data = NULL;
	io_service_t platform_expert;
	if ((platform_expert = IOServiceGetMatchingService(
			 *kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))))
	{
		#ifdef __arm64e__
			if ((ecid_data = (CFDataRef)IORegistryEntrySearchCFProperty(
					 platform_expert, kIODeviceTreePlane, CFSTR("unique-chip-id"),
					 kCFAllocatorDefault, kIORegistryIterateRecursively)))
			{
				UInt64* ecid_bytes_ptr = (UInt64*)CFDataGetBytePtr(ecid_data);
				ecid_string = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%016llX"),
													   *ecid_bytes_ptr);
				CFRelease(ecid_data);
			}
		#else
			if ((ecid_data = (CFDataRef)IORegistryEntrySearchCFProperty(
					 platform_expert, kIODeviceTreePlane, CFSTR("unique-chip-id"),
					 kCFAllocatorDefault, kIORegistryIterateRecursively)))
			{
				UInt64* ecid_bytes_ptr = (UInt64*)CFDataGetBytePtr(ecid_data);
				ecid_string = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%llu"),
													   *ecid_bytes_ptr);
				CFRelease(ecid_data);
			}
		#endif
	}
	IOObjectRelease(platform_expert);
	return ecid_string;
}

extern "C" CFStringRef get_chip_id() {
	void* io_kit_framework =
		dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_LAZY);
	mach_port_t* kIOMasterPortDefault =
		(mach_port_t*)dlsym(io_kit_framework, "kIOMasterPortDefault");
	_IOObjectRelease IOObjectRelease =
		(_IOObjectRelease)dlsym(io_kit_framework, "IOObjectRelease");
	_IOServiceMatching IOServiceMatching =
		(_IOServiceMatching)dlsym(io_kit_framework, "IOServiceMatching");
	_IOServiceGetMatchingService IOServiceGetMatchingService =
		(_IOServiceGetMatchingService)dlsym(io_kit_framework, "IOServiceGetMatchingService");
	_IORegistryEntrySearchCFProperty IORegistryEntrySearchCFProperty = (_IORegistryEntrySearchCFProperty)dlsym(
		io_kit_framework, "IORegistryEntrySearchCFProperty");

	CFStringRef chip_string = NULL;
	io_service_t platform_expert;
	if ((platform_expert = IOServiceGetMatchingService(
			 *kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))))
	{
		CFDataRef chip_data = NULL;
		if ((chip_data = (CFDataRef)IORegistryEntrySearchCFProperty(
				 platform_expert, kIODeviceTreePlane, CFSTR("chip-id"), kCFAllocatorDefault,
				 kIORegistryIterateRecursively)))
		{
			UInt64* chip_bytes_ptr = (UInt64*)CFDataGetBytePtr(chip_data);
			chip_string =
				CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%08llX"), *chip_bytes_ptr);
			CFRelease(chip_data);
		}
	}
	IOObjectRelease(platform_expert);
	return chip_string;
}
//
extern "C" CFStringRef get_serial() {
	void* io_kit_framework =
		dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_LAZY);
	mach_port_t* kIOMasterPortDefault =
		(mach_port_t*)dlsym(io_kit_framework, "kIOMasterPortDefault");
	_IOObjectRelease IOObjectRelease =
		(_IOObjectRelease)dlsym(io_kit_framework, "IOObjectRelease");
	_IOServiceMatching IOServiceMatching =
		(_IOServiceMatching)dlsym(io_kit_framework, "IOServiceMatching");
	_IOServiceGetMatchingService IOServiceGetMatchingService =
		(_IOServiceGetMatchingService)dlsym(io_kit_framework, "IOServiceGetMatchingService");
	_IORegistryEntryCreateCFProperty IORegistryEntryCreateCFProperty = (_IORegistryEntryCreateCFProperty)dlsym(
		io_kit_framework, "IORegistryEntryCreateCFProperty");

	CFDataRef sn_data = NULL;
	io_service_t platform_expert;
	if ((platform_expert = IOServiceGetMatchingService(
			 *kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))))
	{
		sn_data = (CFDataRef)IORegistryEntryCreateCFProperty(platform_expert,
															 CFSTR("IOPlatformSerialNumber"),
															 kCFAllocatorDefault, kIORegistryIterateRecursively);
	}
	IOObjectRelease(platform_expert);
	return (CFStringRef)sn_data;
}
