#pragma once
#include "chacha20.h"
#include "shuffle.h"
#include <stdlib.h>

struct string_entry {
	uint32_t length;
	uint32_t key[8];
	uint32_t nonce[3];
	uint32_t xor_key[8];
	uint32_t xor_nonce[3];
};

__attribute__((section("__TEXT,__GZTOC"))) __attribute__((used)) static struct string_entry lookup_table[100] = {};
__attribute__((section("__TEXT,__GZSTB"))) __attribute__((used)) static uint8_t encrypted_string[32768] = {};

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

/// You must free this string later!
static char* st_get(uint32_t idx);
