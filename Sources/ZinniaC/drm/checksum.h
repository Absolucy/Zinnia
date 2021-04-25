#pragma once
#include "../blake3/blake3.h"
#include "../obfuscation/shuffle.h"
#include <stdbool.h>
#include <stdint.h>

#define hash_to_u64(x, n)                                                                                              \
	((uint64_t)x[0 + n] | (uint64_t)x[1 + n] << 8 | (uint64_t)x[2 + n] << 16 | (uint64_t)x[3 + n] << 24 |              \
	 (uint64_t)x[4 + n] << 32 | (uint64_t)x[5 + n] << 40 | (uint64_t)x[6 + n] << 48 | (uint64_t)x[7 + n] << 56)

#define hash_to_u32(x, n)                                                                                              \
	((uint32_t)x[0 + n] | (uint32_t)x[1 + n] << 8 | (uint32_t)x[2 + n] << 16 | (uint32_t)x[3 + n] << 24)

static inline __attribute__((always_inline)) uint8_t* hash(uint32_t* shuffled_key, const void* data, size_t len) {
	uint8_t* key = decode_shuffled_key(shuffled_key, 8);
	uint8_t* output = (uint8_t*)malloc(sizeof(uint8_t) * 12);
	blake3_hasher hasher;
	blake3_hasher_init_keyed(&hasher, key);
	blake3_hasher_update(&hasher, data, len);
	blake3_hasher_finalize(&hasher, output, 12);
	free(key);
	return output;
}

static inline __attribute__((always_inline)) bool compare_hash(uint32_t shuffled_ckey, uint8_t* stored_hash,
															   uint8_t* calculated_hash) {
	uint32_t* stored = (uint32_t*)stored_hash;
	uint32_t* calculated = (uint32_t*)calculated_hash;
	for (int i = 0; i < 3; i++) {
		if (calculated[i] != (perfect_unshuffle(stored[i]) ^ (perfect_unshuffle(shuffled_ckey) * (i + 1))))
			return false;
	}
	return true;
}
