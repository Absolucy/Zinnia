#ifdef DRM
#include "crc.h"
#include <Foundation/Foundation.h>
#include <inttypes.h>
#include <mach-o/dyld.h>
#ifdef __arm64e__
#include <ptrauth.h>
#endif

struct crc_lookup {
	uint64_t ckey;
	uint64_t checksum;
	uint64_t size;
	uint64_t jkey;
	uint64_t jmp;
};

__attribute__((section("__TEXT,__fuckmainrepo")))
__attribute__((used)) static struct crc_lookup lookup_table[1024] = {};

static inline bool __attribute__((always_inline)) compare(const char* a, const char* b) {
	int i = 0;
	while (a[i] != 0 && b[i] != 0) {
		if (a[i] != b[i])
			return false;
		i++;
	}
	return true;
}

static inline int __attribute__((always_inline)) str_ends_with(const char* s, const char* suffix) {
	size_t slen = strlen(s);
	size_t suffix_len = strlen(suffix);

	return suffix_len <= slen && !strcmp(s + slen - suffix_len, suffix);
}

__attribute__((constructor)) static void check_text_integrity() {
	int count = _dyld_image_count();
	for (int i = 0; i < count; i++) {
		const struct mach_header_64* header = (const struct mach_header_64*)_dyld_get_image_header(i);
		const char* path = _dyld_get_image_name(i);
		size_t segmentOffset = sizeof(struct mach_header_64);
		if (!str_ends_with(path, "Zinnia.dylib") || header->magic != MH_MAGIC_64)
			continue;
		for (uint32_t i = 0; i < header->ncmds; i++) {
			struct load_command* loadCommand = (struct load_command*)((uint8_t*)header + segmentOffset);
			if (loadCommand->cmd == LC_SEGMENT_64) {
				// We found a 64-bit segment
				struct segment_command_64* segCommand = (struct segment_command_64*)loadCommand;
				// For each section in the 64-bit segment
				void* sectionPtr = (void*)(segCommand + 1);
				for (uint32_t nsect = 0; nsect < segCommand->nsects; ++nsect) {
					struct section_64* section = (struct section_64*)sectionPtr;
					// Check if this is the __TEXT segment
					if (compare(section->segname, SEG_TEXT) && compare(section->sectname, SECT_TEXT)) {
						uint64_t section_crc =
							crc(0xFFFFFFFFFFFFFFFF, (const char*)header + section->offset, (int)section->size);
						for (int li = 0; li < 1024; li++) {
							struct crc_lookup* lookup = &lookup_table[li];
							if ((lookup->ckey ^ lookup->checksum) == section_crc) {
#ifdef __arm64e__
								void* jmp_loc = ptrauth_sign_unauthenticated(
									(void*)header + (lookup->jmp ^ lookup->jkey), ptrauth_key_function_pointer, 0);
#else
								void* jmp_loc = (void*)header + (lookup->jmp ^ lookup->jkey);
#endif
								((void (*)())(jmp_loc))();
								return;
							}
						}
						return;
					}
					sectionPtr += sizeof(struct section_64);
				}
			}
			segmentOffset += loadCommand->cmdsize;
		}
	}
}
#endif
