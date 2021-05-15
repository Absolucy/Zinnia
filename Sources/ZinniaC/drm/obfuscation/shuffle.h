#pragma once
#include <stdint.h>
#include <stdlib.h>
#include "../config.h"

/// This is an implementation of a Faro Shuffle on an unsigned 32-bit integer: https://en.wikipedia.org/wiki/Faro_shuffle
/// It's sole purpose is to make it more difficult to statically analyze data.
/// If you wish to disable this, comment out the "USE_PERFECT_SHUFFLING" define in config.h
static inline __attribute__((always_inline)) uint32_t perfect_shuffle(uint32_t x) {
#ifdef USE_PERFECT_SHUFFLING
	x = (x & UINT32_C(0xff0000ff)) | ((x & UINT32_C(0x00ff0000)) >> 8) | ((x & UINT32_C(0x0000ff00)) << 8);
	x = (x & UINT32_C(0xf00ff00f)) | ((x & UINT32_C(0x0f000f00)) >> 4) | ((x & UINT32_C(0x00f000f0)) << 4);
	x = (x & UINT32_C(0xc3c3c3c3)) | ((x & UINT32_C(0x30303030)) >> 2) | ((x & UINT32_C(0x0c0c0c0c)) << 2);
	x = (x & UINT32_C(0x99999999)) | ((x & UINT32_C(0x44444444)) >> 1) | ((x & UINT32_C(0x22222222)) << 1);
#endif
	return x;
}

/// This is an implementation of a Faro Shuffle on an unsigned 64-bit integer: https://en.wikipedia.org/wiki/Faro_shuffle
/// It's sole purpose is to make it more difficult to statically analyze data.
/// If you wish to disable this, comment out the "USE_PERFECT_SHUFFLING" define in config.h
static inline __attribute__((always_inline)) uint64_t perfect_shuffle_u64(uint64_t x) {
#ifdef USE_PERFECT_SHUFFLING
	uint32_t* y = (uint32_t*)&x;
	y[0] = perfect_shuffle(y[0]);
	y[1] = perfect_shuffle(y[1]);
	return *(uint64_t*)y;
#else
	return x;
#endif
}

/// This is an implementation of (undoing) a Faro Shuffle on an unsigned 32-bit integer: https://en.wikipedia.org/wiki/Faro_shuffle
/// It's sole purpose is to make it more difficult to statically analyze data.
/// If you wish to disable this, comment out the "USE_PERFECT_SHUFFLING" define in config.h
static inline __attribute__((always_inline)) uint32_t perfect_unshuffle(uint32_t x) {
#ifdef USE_PERFECT_SHUFFLING
	x = (x & UINT32_C(0x99999999)) | ((x & UINT32_C(0x44444444)) >> 1) | ((x & UINT32_C(0x22222222)) << 1);
	x = (x & UINT32_C(0xc3c3c3c3)) | ((x & UINT32_C(0x30303030)) >> 2) | ((x & UINT32_C(0x0c0c0c0c)) << 2);
	x = (x & UINT32_C(0xf00ff00f)) | ((x & UINT32_C(0x0f000f00)) >> 4) | ((x & UINT32_C(0x00f000f0)) << 4);
	x = (x & UINT32_C(0xff0000ff)) | ((x & UINT32_C(0x00ff0000)) >> 8) | ((x & UINT32_C(0x0000ff00)) << 8);
#endif
	return x;
}

/// This is an implementation of (undoing) a Faro Shuffle on an unsigned 64-bit integer: https://en.wikipedia.org/wiki/Faro_shuffle
/// It's sole purpose is to make it more difficult to statically analyze data.
/// If you wish to disable this, comment out the "USE_PERFECT_SHUFFLING" define in config.h
static inline __attribute__((always_inline)) uint64_t perfect_unshuffle_u64(uint64_t x) {
#ifdef USE_PERFECT_SHUFFLING
	uint32_t* y = (uint32_t*)&x;
	y[0] = perfect_unshuffle(y[0]);
	y[1] = perfect_unshuffle(y[1]);
	return *(uint64_t*)y;
#else
	return x;
#endif
}

static inline __attribute__((always_inline)) uint8_t* decode_shuffled_key(uint32_t* key, size_t len) {
	uint32_t* decoded_key = (uint32_t*)malloc(len * sizeof(uint32_t));
	for (int i = 0; i < len; i++)
		decoded_key[i] = perfect_unshuffle(key[i]);
	return (uint8_t*)decoded_key;
}

static inline __attribute__((always_inline)) uint8_t decode_expanded_offset(uint64_t* offset) {
	uint64_t x = perfect_unshuffle_u64(*offset);
	uint8_t base = 0;
	for (size_t bit = 0; bit < 64; bit += 8) {
		if ((x & (1 << bit)) != 0) {
			base |= 1 << (bit / 8);
		}
	}
	return base;
}
