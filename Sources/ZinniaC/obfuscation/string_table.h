#pragma once
#include "chacha20.h"
#include "shuffle.h"
#include <stdint.h>
#include <stdlib.h>

struct decryption_key {
	uint32_t key[8];
	uint32_t nonce[3];
	uint32_t xor_key[8];
	uint32_t xor_nonce[3];
};

struct string_entry {
	uint32_t length;
	struct decryption_key keys;
};

/// You must free this string later!
char* st_get(uint32_t idx);
void st_get_bytes(uint32_t idx, void (^callback)(uint8_t*, size_t));
void initialize_string_table();
