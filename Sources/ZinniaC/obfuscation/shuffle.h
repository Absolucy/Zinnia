#pragma once
#include <stdint.h>
#include <stdlib.h>

static inline __attribute__((always_inline)) uint32_t perfect_shuffle(uint32_t x) {
	x = (x & UINT32_C(0xff0000ff)) | ((x & UINT32_C(0x00ff0000)) >> 8) | ((x & UINT32_C(0x0000ff00)) << 8);
	x = (x & UINT32_C(0xf00ff00f)) | ((x & UINT32_C(0x0f000f00)) >> 4) | ((x & UINT32_C(0x00f000f0)) << 4);
	x = (x & UINT32_C(0xc3c3c3c3)) | ((x & UINT32_C(0x30303030)) >> 2) | ((x & UINT32_C(0x0c0c0c0c)) << 2);
	x = (x & UINT32_C(0x99999999)) | ((x & UINT32_C(0x44444444)) >> 1) | ((x & UINT32_C(0x22222222)) << 1);

	return x;
}

static inline __attribute__((always_inline)) uint32_t perfect_unshuffle(uint32_t x) {
	x = (x & UINT32_C(0x99999999)) | ((x & UINT32_C(0x44444444)) >> 1) | ((x & UINT32_C(0x22222222)) << 1);
	x = (x & UINT32_C(0xc3c3c3c3)) | ((x & UINT32_C(0x30303030)) >> 2) | ((x & UINT32_C(0x0c0c0c0c)) << 2);
	x = (x & UINT32_C(0xf00ff00f)) | ((x & UINT32_C(0x0f000f00)) >> 4) | ((x & UINT32_C(0x00f000f0)) << 4);
	x = (x & UINT32_C(0xff0000ff)) | ((x & UINT32_C(0x00ff0000)) >> 8) | ((x & UINT32_C(0x0000ff00)) << 8);

	return x;
}

static inline __attribute__((always_inline)) uint8_t* decode_shuffled_key(uint32_t* key, size_t len) {
	uint32_t* decoded_key = (uint32_t*)malloc(len * sizeof(uint32_t));
	for (int i = 0; i < len; i++)
		decoded_key[i] = perfect_unshuffle(key[i]);
	return (uint8_t*)decoded_key;
}
