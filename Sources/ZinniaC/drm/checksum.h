#pragma once
#include "blake3/blake3.h"
#include "obfuscation/shuffle.h"
#include <stdbool.h>
#include <stdint.h>

/// Calculates the blake3 hash of the specified data, using a shuffled key to initialize the hasher.
static inline __attribute__((always_inline)) uint64_t hash(uint32_t* shuffled_key, const void* data, size_t len) {
	uint8_t* key = decode_shuffled_key(shuffled_key, 8);
	uint64_t hash;
	blake3_hasher hasher;
	blake3_hasher_init_keyed(&hasher, key);
	blake3_hasher_update(&hasher, data, len);
	blake3_hasher_finalize(&hasher, (uint8_t*)&hash, sizeof(uint64_t));
	free(key);
	return hash;
}
