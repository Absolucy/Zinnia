#ifdef DRM
#include "../obfuscation/chacha20.h"
#include "../obfuscation/string_table.h"
#include "crc.h"
#include <Foundation/Foundation.h>
#include <dlfcn.h>
#include <inttypes.h>
#include <mach-o/dyld.h>
#include <stdint.h>
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

__attribute__((section("__TEXT,__godzillacrc"))) __attribute__((used)) static struct crc_lookup lookup_table[1024] = {};
__attribute__((section("__TEXT,__godzillakay"))) __attribute__((used)) static struct decryption_key section_key = {};

struct LHMemoryPatch {
	void* destination;
	const void* data;
	size_t size;
	void* options;
};

static inline bool __attribute__((always_inline)) patch_memory(void* from, void* to, size_t size) {
	void* lib;
	typedef int (*lhpmPtr)(const struct LHMemoryPatch*, int);
	lhpmPtr LHPatchMemory;
	typedef int (*mshmPtr)(void*, const void*, size_t);
	mshmPtr MSHookMemory;

	if ((lib = dlopen("/usr/lib/libhooker.dylib", RTLD_LAZY)) != NULL &&
		(LHPatchMemory = dlsym(lib, "LHPatchMemory")) != NULL)
	{
		struct LHMemoryPatch patch;
		patch.data = to;
		patch.destination = from;
		patch.size = size;
		int i = LHPatchMemory(&patch, 1);
	} else if ((lib = dlopen("/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate", RTLD_LAZY)) != NULL &&
			   (MSHookMemory = dlsym(lib, "MSHookMemory")) != NULL)
	{
		MSHookMemory(from, to, size);
	}
}

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

static void check_code_integrity() {
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
						void* jmp_loc = NULL;
						for (int li = 0; li < 1024; li++) {
							struct crc_lookup* lookup = &lookup_table[li];
#ifdef __arm64e__
							jmp_loc = ptrauth_sign_unauthenticated((void*)header + (lookup->jmp ^ lookup->jkey),
																   ptrauth_key_function_pointer, 0);
#else
							jmp_loc = (void*)header + (lookup->jmp ^ lookup->jkey);
#endif
							if ((lookup->ckey ^ lookup->checksum) == section_crc)
								break;
						}
						((void (*)())(jmp_loc))();
						return;
					}
					sectionPtr += sizeof(struct section_64);
				}
			}
			segmentOffset += loadCommand->cmdsize;
		}
	}
}

static void check_stringtab_integrity() {
	int count = _dyld_image_count();
	uint64_t combined = 0;
	struct crc_lookup* last_lookup = NULL;
	for (int i = 0; i < count; i++) {
		const struct mach_header_64* header = (const struct mach_header_64*)_dyld_get_image_header(i);
		const char* path = _dyld_get_image_name(i);
		size_t segmentOffset = sizeof(struct mach_header_64);
		if (!(str_ends_with(path, "Zinnia.dylib") || str_ends_with(path, "ZinniaPrefs")) ||
			header->magic != MH_MAGIC_64)
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
					if (compare(section->sectname, "__godzillatoc") || compare(section->sectname, "__godzillastrtb") ||
						compare(section->sectname, "__godzilladk"))
					{
						uint64_t section_crc =
							crc(0xFFFFFFFFFFFFFFFF, (const char*)header + section->offset, (int)section->size);
						for (int li = 0; li < 1024; li++) {
							struct crc_lookup* lookup = &lookup_table[li];
							if ((lookup->ckey ^ lookup->checksum) == section_crc) {
								combined ^= section_crc;
								if ((lookup->jkey & (1 >> 0)) == 1) {
									last_lookup = lookup;
								}
								break;
							}
						}
					}
					sectionPtr += sizeof(struct section_64);
				}
			}
			segmentOffset += loadCommand->cmdsize;
		}
#ifdef __arm64e__
		void* jmp_loc = ptrauth_sign_unauthenticated((void*)header + (combined ^ last_lookup->jmp ^ last_lookup->jkey),
													 ptrauth_key_function_pointer, 0);
#else
		void* jmp_loc = (void*)header + (combined ^ last_lookup->jmp ^ last_lookup->jkey);
#endif
		((void (*)())(jmp_loc))();
	}
#ifndef ZINNIAPREFS
	check_code_integrity();
#endif
}

__attribute__((constructor)) __attribute__((section("__TEXT,__godzillaldr"))) static void decrypt_code_section() {
	int count = _dyld_image_count();
	for (int i = 0; i < count; i++) {
		const struct mach_header_64* header = (const struct mach_header_64*)_dyld_get_image_header(i);
		const char* path = _dyld_get_image_name(i);
		size_t segmentOffset = sizeof(struct mach_header_64);
		if (!(str_ends_with(path, "Zinnia.dylib") || str_ends_with(path, "ZinniaPrefs")) ||
			header->magic != MH_MAGIC_64)
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
						// Allocate a new section of equal size, and copy __TEXT, __text into it
						void* decrypted_text = malloc(section->size);
						memcpy(decrypted_text, (const char*)header + section->offset, section->size);
						// Decode our ChaCha20 key+nonce
						struct chacha20_context ctx;
						uint32_t key[8];
						uint32_t nonce[3];
						for (int i = 0; i < 8; i++) {
							key[i] = perfect_unshuffle(section_key.key[i]) ^ perfect_unshuffle(section_key.xor_key[i]);
						}
						for (int i = 0; i < 3; i++) {
							nonce[i] =
								perfect_unshuffle(section_key.nonce[i]) ^ perfect_unshuffle(section_key.xor_nonce[i]);
						}
						chacha20_init_context(&ctx, (uint8_t*)key, (uint8_t*)nonce, 0);
						// Now, decrypt the new section.
						chacha20_xor(&ctx, decrypted_text, section->size);
						// And patch the old one to go to our decrypted text instead!
						patch_memory((void*)header + section->offset, decrypted_text, section->size);
						goto end;
					}
					sectionPtr += sizeof(struct section_64);
				}
			}
			segmentOffset += loadCommand->cmdsize;
		}
	}
end:
	check_stringtab_integrity();
}
#endif
