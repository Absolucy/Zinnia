#include "anti_debug.h"
#include "checksum.h"
#include "config.h"
#include "drm.h"
#include "obfuscation/shuffle.h"
#include "obfuscation/string_table.h"
#include "util.h"
#include <mach-o/dyld.h>
#include <stdint.h>
#ifdef __arm64e__
#include <ptrauth.h>
#endif

typedef struct {
	uint64_t hash;
	uint64_t size;
	uint64_t jkey;
	uint64_t jmp;
} crc_lookup;

__attribute__((section(SECTION_CHECKSUM_HASH_KEY))) __attribute__((used)) static uint8_t checksum_key[289] = {};

__attribute__((section(SECTION_CHECKSUM_LOOKUP_TABLE))) __attribute__((used)) static crc_lookup lookup_table[1024] = {};

/// This ensures that the string table hasn't been tampered with, and jumps to
/// the next part of initialization (check_code_integrity) if it hasn't been.
__attribute__((used)) void check_stringtab_integrity() {
	// First, we iterate through all the dyld images.
	int count = _dyld_image_count();
	uint64_t combined = 0;
	crc_lookup* last_lookup = NULL;
	DEBUGGER_CHECK
	for (int i = 0; i < count; i++) {
		const struct mach_header_64* header = (const struct mach_header_64*)_dyld_get_image_header(i);
		const char* path = _dyld_get_image_name(i);
		size_t segmentOffset = sizeof(struct mach_header_64);
		DEBUGGER_CHECK
		// If this dyld image either:
		//  1. doesn't point to our tweak
		//  2. doesn't point to our tweak's preferences bundle
		//  3. isn't 64-bit,
		// then we skip it and continue onto the next one.
		if (!(str_ends_with(path, TWEAK_DYLIB) || str_ends_with(path, PREFS_BUNDLE)) || header->magic != MH_MAGIC_64)
			continue;
		// Now, we're going to iterate through this image's load commands, to find all the segments.
		for (uint32_t i = 0; i < header->ncmds; i++) {
			struct load_command* loadCommand = (struct load_command*)((uint8_t*)header + segmentOffset);
			DEBUGGER_CHECK
			// We found a 64-bit segment. Good.
			if (loadCommand->cmd == LC_SEGMENT_64) {
				struct segment_command_64* segCommand = (struct segment_command_64*)loadCommand;
				void* sectionPtr = (void*)(segCommand + 1);
				// Now, we're going to loop through every section in this segment.
				for (uint32_t nsect = 0; nsect < segCommand->nsects; ++nsect) {
					struct section_64* section = (struct section_64*)sectionPtr;
					// Check to see if this is one of the string table sections.
					if (compare(section->sectname, (char*)SECTION_STRING_TABLE_OF_CONTENTS + 7) ||
						compare(section->sectname, (char*)SECTION_STRING_TABLE + 7) ||
						compare(section->sectname, (char*)SECTION_STRING_TABLE_KEYS + 7))
					{
						// Calculate the blake3 hash of this section, using the checksum_key to initialize the
						// hasher.
						uint64_t section_hash =
							hash(checksum_key, (const char*)header + section->offset, (int)section->size);
						DEBUGGER_CHECK
						// Now, we're going to see if any of the entries in the lookup table match
						// our calculated hash. If so, we will XOR an uint64_t-compressed version
						// of our hash against `combined`.
						// If all the sections have the correct checksums, then after we're done,
						// `combined` will be the offset of the next function (check_code_integrity).
						for (int li = 0; li < 1024; li++) {
							crc_lookup* lookup = &lookup_table[li];
							if (lookup->hash == section_hash) {
								combined ^= section_hash;
								// One of the hashes will have the first bit of the jkey set.
								// This is the one that needs to be XOR'd against combined.
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
		// Now, we turn the combined and the "correct" hash's jmp and jkey into a function pointer!
		// If the string table is tampered with without perfectly fixing the hash lookup table,
		/// then this will very likely segfault :)
#ifdef __arm64e__
		void* jmp_loc = ptrauth_sign_unauthenticated((void*)header + (combined ^ last_lookup->jmp ^ last_lookup->jkey),
													 ptrauth_key_function_pointer, 0);
#else
		void* jmp_loc = (void*)header + (combined ^ last_lookup->jmp ^ last_lookup->jkey);
#endif
		((void (*)())(jmp_loc))();
	}
end:
	count = 0;
	combined = 0;
	last_lookup = NULL;
}

/// This ensures that the __TEXT,__text section hasn't been tampered with, and jumps to
/// the next part of initialization (whatever the normal tweak init function is) if it hasn't been.
__attribute__((used)) void check_code_integrity() {
	// First, we iterate through all the dyld images.
	int count = _dyld_image_count();
	DEBUGGER_CHECK
	for (int i = 0; i < count; i++) {
		const struct mach_header_64* header = (const struct mach_header_64*)_dyld_get_image_header(i);
		const char* path = _dyld_get_image_name(i);
		size_t segmentOffset = sizeof(struct mach_header_64);
		// If this dyld image either:
		//  1. doesn't point to our tweak
		//  2. isn't 64-bit,
		// then we skip it and continue onto the next one.
		if (!str_ends_with(path, TWEAK_DYLIB) || header->magic != MH_MAGIC_64)
			continue;
		DEBUGGER_CHECK
		// Now, we're going to iterate through this image's load commands, to find all the segments.
		for (uint32_t i = 0; i < header->ncmds; i++) {
			struct load_command* loadCommand = (struct load_command*)((uint8_t*)header + segmentOffset);
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
						// Calculate the blake3 hash of this section, using the checksum_key to initialize the hasher.
						uint64_t section_hash =
							hash(checksum_key, (const char*)header + section->offset, (int)section->size);
						DEBUGGER_CHECK
						void* jmp_loc = NULL;
						// Now, we're going to see if any of the entries in the lookup table match
						// our calculated hash. If so, we're going to use it's `jmp` value as the
						// offset of the next function to call.
						for (int li = 0; li < 1024; li++) {
							crc_lookup* lookup = &lookup_table[li];
#ifdef __arm64e__
							jmp_loc = ptrauth_sign_unauthenticated((void*)header + (lookup->jmp ^ lookup->jkey),
																   ptrauth_key_function_pointer, 0);
#else
							jmp_loc = (void*)header + (lookup->jmp ^ lookup->jkey);
#endif
							// Good news! This is the one, jmp_loc should be right so let's break
							// out of this loop.
							if (lookup->hash == section_hash)
								break;
						}
						// Using the jmp_loc as a pointer, we call the next function.
						// This will very likely segfault if someone tampers with the tweak
						// without managing to perfectly fix up the hash lookup table.
						((void (*)())(jmp_loc))();
						return;
					}
					sectionPtr += sizeof(struct section_64);
				}
			}
			segmentOffset += loadCommand->cmdsize;
		}
	}
end:
	count = 0;
}
