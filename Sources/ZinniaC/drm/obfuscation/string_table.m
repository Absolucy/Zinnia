#include "string_table.h"
#include "../config.h"
#include <Foundation/Foundation.h>
#include <inttypes.h>
#include <mach-o/dyld.h>
#ifdef __arm64e__
#include <ptrauth.h>
#endif

// Table of contents, containing each string's encryption key, nonce, and length.
__attribute__((section(SECTION_STRING_TABLE_OF_CONTENTS)))
__attribute__((used)) static string_entry string_table_of_contents[100] = {};
// The actual encrypted strings.
__attribute__((section(SECTION_STRING_TABLE))) __attribute__((used)) static uint8_t encrypted_string[32768] = {};
// Two keypairs, which the ToC and strings are initially encrypted with.
__attribute__((section(SECTION_STRING_TABLE_KEYS))) __attribute__((used)) static uint8_t decryption_keys[433] = {};

static inline __attribute__((always_inline)) void initialize_keys(struct chacha20_context* ctx, decryption_key* keys) {
	uint32_t key[8];
	uint32_t nonce[3];
	for (int i = 0; i < 8; i++) {
		key[i] = perfect_unshuffle(keys->key[i]) ^ perfect_unshuffle(keys->xor_key[i]);
	}
	for (int i = 0; i < 3; i++) {
		nonce[i] = perfect_unshuffle(keys->nonce[i]) ^ perfect_unshuffle(keys->xor_nonce[i]);
	}
	chacha20_init_context(ctx, (uint8_t*)key, (uint8_t*)nonce, 0);
}

#ifdef DRM
char* st_get(uint32_t idx) {
	__block char* ret;
	st_get_bytes(idx, ^(uint8_t* data, size_t _) {
	  ret = (char*)data;
	});
	return ret;
}
#else
char* st_get(const char* name) {
	@throw @"do not use st_get without running through post-processor!";
	return (char*)NULL;
}
#endif

#ifdef DRM
void st_get_bytes(uint32_t idx, void (^callback)(uint8_t*, size_t)) {
	string_entry* entry = &string_table_of_contents[idx];
	struct chacha20_context ctx;

	initialize_keys(&ctx, &entry->keys);

	uint32_t length = perfect_unshuffle(entry->length);

	char* string_base = (char*)encrypted_string;
	if (idx > 0) {
		for (int i = 0; i < idx; i++) {
			string_base += perfect_unshuffle(string_table_of_contents[i].length);
		}
	}

	// if _platform_memmove crashes here, THAT MEANS THE STRING TABLE DID NOT DECRYPT!
	uint8_t* bytes = (uint8_t*)malloc(length);
	memcpy(bytes, string_base, length);
	chacha20_xor(&ctx, bytes, length);

	callback(bytes, length);
}
#else
void st_get_bytes(const char* name, void (^callback)(uint8_t*, size_t)) {
	@throw @"do not use st_get_bytes without running through post-processor!";
}
#endif

void initialize_string_table() {
	struct chacha20_context ctx;
	// Find the offset (0-255) of our encryption keys from the first 8 bytes of the section
	uint8_t offset = (decryption_keys[0] ^ 42) ^ decryption_keys[1];
	decryption_key* keys = (decryption_key*)(decryption_keys + 2 + offset);
	// Decrypt the table of contents
	initialize_keys(&ctx, &keys[0]);
	chacha20_xor(&ctx, (uint8_t*)string_table_of_contents, sizeof(string_entry) * 100);
	// Decrypt the string table
	initialize_keys(&ctx, &keys[1]);
	chacha20_xor(&ctx, (uint8_t*)encrypted_string, 32768);
}
