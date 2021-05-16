#include "anti_debug.h"
#include "blake3/blake3.h"
#include "checksum.h"
#include "config.h"
#include "drm.h"
#include "obfuscation/chacha20.h"
#include "obfuscation/shuffle.h"
#include "obfuscation/string_table.h"
#include "util.h"
#include <Foundation/Foundation.h>
#include <dlfcn.h>
#include <inttypes.h>
#include <mach-o/dyld.h>
#include <stdint.h>

__attribute__((section(SECTION_CODE_DECRYPTION_KEY)))
__attribute__((used)) static uint8_t obfuscated_section_key[345] = {};

struct LHMemoryPatch {
	void* destination;
	const void* data;
	size_t size;
	void* options;
};

static inline void __attribute__((always_inline)) patch_memory(void* from, void* to, size_t size) {
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
		LHPatchMemory(&patch, 1);
	} else if ((lib = dlopen("/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate", RTLD_LAZY)) != NULL &&
			   (MSHookMemory = dlsym(lib, "MSHookMemory")) != NULL)
	{
		MSHookMemory(from, to, size);
	}
}

/// This is the fancy code that decrypts __TEXT,__text.
__attribute__((constructor)) __attribute__((used)) __attribute__((section(SECTION_CODE_DECRYPTION_ROUTINE))) void
decrypt_code_section() {
	// First, we iterate through all the dyld images.
	int count = _dyld_image_count();
	DEBUGGER_CHECK
	for (int i = 0; i < count; i++) {
		const struct mach_header_64* header = (const struct mach_header_64*)_dyld_get_image_header(i);
		const char* path = _dyld_get_image_name(i);
		size_t segmentOffset = sizeof(struct mach_header_64);
		// If this dyld image either:
		//  1. doesn't point to our tweak
		//  2. doesn't point to our tweak's preferences bundle
		//  3. isn't 64-bit,
		// then we skip it and continue onto the next one.
		if (!(str_ends_with(path, TWEAK_DYLIB) || str_ends_with(path, PREFS_BUNDLE)) || header->magic != MH_MAGIC_64)
			continue;
		DEBUGGER_CHECK
		// Now, we're going to iterate through this image's load commands, to find all the segments.
		for (uint32_t i = 0; i < header->ncmds; i++) {
			struct load_command* loadCommand = (struct load_command*)((uint8_t*)header + segmentOffset);
			DEBUGGER_CHECK
			// We found a 64-bit segment. Good.
			if (loadCommand->cmd == LC_SEGMENT_64) {
				struct segment_command_64* segCommand = (struct segment_command_64*)loadCommand;
				void* sectionPtr = (void*)(segCommand + 1);
				DEBUGGER_CHECK
				// Now, we're going to loop through every section in this segment.
				for (uint32_t nsect = 0; nsect < segCommand->nsects; ++nsect) {
					struct section_64* section = (struct section_64*)sectionPtr;
					DEBUGGER_CHECK
					// Check if this is the __TEXT,__text section.
					if (compare(section->segname, SEG_TEXT) && compare(section->sectname, SECT_TEXT)) {
						// Allocate a new section of equal size, and copy __TEXT, __text into it
						void* decrypted_text = malloc(section->size);
						memcpy(decrypted_text, (const char*)header + section->offset, section->size);
						DEBUGGER_CHECK
						// Get the offset of our decryption key
						uint8_t offset = (obfuscated_section_key[0] ^ 42) ^ obfuscated_section_key[1];
						decryption_key* section_key = (decryption_key*)(obfuscated_section_key + 2 + offset);
						// Decode our ChaCha20 key+nonce
						struct chacha20_context ctx;
						uint32_t key[8];
						uint32_t nonce[3];
						for (int i = 0; i < 8; i++) {
							key[i] =
								perfect_unshuffle(section_key->key[i]) ^ perfect_unshuffle(section_key->xor_key[i]);
						}
						for (int i = 0; i < 3; i++) {
							nonce[i] =
								perfect_unshuffle(section_key->nonce[i]) ^ perfect_unshuffle(section_key->xor_nonce[i]);
						}
						chacha20_init_context(&ctx, (uint8_t*)key, (uint8_t*)nonce, 0);
						// Now, decrypt the new section.
						chacha20_xor(&ctx, decrypted_text, section->size);
						// And patch the old one to go to our decrypted text instead!
						patch_memory((void*)header + section->offset, decrypted_text, section->size);
						// We're donezo!
						goto done;
					}
					sectionPtr += sizeof(struct section_64);
				}
			}
			segmentOffset += loadCommand->cmdsize;
		}
	}
done:
	check_stringtab_integrity();
end:
	/* GARBAGE_TEMPLATE */
	count ^= count;
}
