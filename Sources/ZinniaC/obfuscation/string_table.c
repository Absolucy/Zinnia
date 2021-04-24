#include "string_table.h"

__attribute__((section("__TEXT,__GODZILLATOC")))
__attribute__((used)) static struct string_entry lookup_table[100] = {};
__attribute__((section("__TEXT,__GODZILLASTRTB"))) __attribute__((used)) static uint8_t encrypted_string[32768] = {};

static inline __attribute__((always_inline)) void st_key(struct chacha20_context* ctx, uint32_t idx) {
	struct string_entry* entry = &lookup_table[idx];
	uint32_t key[8];
	uint32_t nonce[3];
	for (int i = 0; i < 8; i++) {
		key[i] = perfect_unshuffle(entry->key[i]) ^ perfect_unshuffle(entry->xor_key[i]);
	}
	for (int i = 0; i < 3; i++) {
		nonce[i] = perfect_unshuffle(entry->nonce[i]) ^ perfect_unshuffle(entry->xor_nonce[i]);
	}
	chacha20_init_context(ctx, (uint8_t*)key, (uint8_t*)nonce, 0);
}

char* st_get(uint32_t idx) {
	struct string_entry* entry = &lookup_table[idx];
	struct chacha20_context ctx;
	st_key(&ctx, idx);

	uint32_t length = perfect_unshuffle(entry->length);

	char* string_base = (char*)encrypted_string;
	if (idx > 0) {
		for (int i = 0; i < idx; i++) {
			string_base += perfect_unshuffle(lookup_table[i].length);
		}
	}

	char* string = (char*)malloc(length);
	memcpy(string, string_base, length);
	chacha20_xor(&ctx, (uint8_t*)string, length);

	return string;
}
