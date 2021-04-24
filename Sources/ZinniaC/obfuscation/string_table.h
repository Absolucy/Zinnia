#pragma once
#include "chacha20.h"
#include "shuffle.h"
#include <stdint.h>
#include <stdlib.h>

struct string_entry {
	uint32_t length;
	uint32_t key[8];
	uint32_t nonce[3];
	uint32_t xor_key[8];
	uint32_t xor_nonce[3];
};

/// You must free this string later!
char* st_get(uint32_t idx);
