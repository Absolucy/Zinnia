#include "string_table.h"
#include <Foundation/Foundation.h>
#include <inttypes.h>
#include <mach-o/dyld.h>
#ifdef __arm64e__
#include <ptrauth.h>
#endif

// Table of contents, containing each string's encryption key, nonce, and length.
__attribute__((section("__DATA,__godzillatoc")))
__attribute__((used)) static struct string_entry string_table_of_contents[100] = {};
// The actual encrypted strings.
__attribute__((section("__DATA,__godzillastrtb"))) __attribute__((used)) static uint8_t encrypted_string[32768] = {};
// Two keypairs, which the ToC and strings are initially encrypted with.
__attribute__((section("__TEXT,__godzilladk")))
__attribute__((used)) static struct decryption_key decryption_keys[2] = {};

static inline __attribute__((always_inline)) void initialize_keys(struct chacha20_context* ctx,
																  struct decryption_key* keys) {
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

char* st_get(uint32_t idx) {
	struct string_entry* entry = &string_table_of_contents[idx];
	struct chacha20_context ctx;

	initialize_keys(&ctx, &entry->keys);

	uint32_t length = perfect_unshuffle(entry->length);

	char* string_base = (char*)encrypted_string;
	if (idx > 0) {
		for (int i = 0; i < idx; i++) {
			string_base += perfect_unshuffle(string_table_of_contents[i].length);
		}
	}

	char* string = (char*)malloc(length);
	memcpy(string, string_base, length);
	chacha20_xor(&ctx, (uint8_t*)string, length);

	return string;
}

void initialize_string_table() {
	struct chacha20_context ctx;
	// Decrypt the table of contents
	initialize_keys(&ctx, &decryption_keys[0]);
	chacha20_xor(&ctx, (uint8_t*)string_table_of_contents, sizeof(struct string_entry) * 100);
	// Decrypt the string table
	initialize_keys(&ctx, &decryption_keys[1]);
	chacha20_xor(&ctx, (uint8_t*)encrypted_string, 32768);
}
