#include <stdint.h>

#define to64l(arr)                                                                                                     \
	(((uint64_t)(((uint8_t*)(arr))[0]) << 0) + ((uint64_t)(((uint8_t*)(arr))[1]) << 8) +                               \
	 ((uint64_t)(((uint8_t*)(arr))[2]) << 16) + ((uint64_t)(((uint8_t*)(arr))[3]) << 24) +                             \
	 ((uint64_t)(((uint8_t*)(arr))[4]) << 32) + ((uint64_t)(((uint8_t*)(arr))[5]) << 40) +                             \
	 ((uint64_t)(((uint8_t*)(arr))[6]) << 48) + ((uint64_t)(((uint8_t*)(arr))[7]) << 56))

static uint8_t obfuscated_polynomial[8] = {0xb8, 0x8a, 0x45, 0xe0, 0x05, 0x01, 0x0e, 0xcf};
static uint8_t polynomial_key1[8] = {0xf3, 0x6b, 0x20, 0x47, 0xc5, 0x02, 0x50, 0x4f};
static uint8_t polynomial_key2[8] = {0x02, 0xfa, 0x90, 0x73, 0x35, 0x73, 0x26, 0x21};

static uint8_t obfuscated_mask[8] = {0xb7, 0xf2, 0x8b, 0xfd, 0xa1, 0x1d, 0xbf, 0x1c};
static uint8_t mask_key1[8] = {0x19, 0x2d, 0xd6, 0x74, 0xd5, 0xa0, 0x84, 0xc7};
static uint8_t mask_key2[8] = {0xae, 0xdf, 0x5d, 0x89, 0x74, 0xbd, 0x3b, 0x5b};

static uint8_t obfuscated_initial[8] = {0xf9, 0x4e, 0xde, 0xf6, 0xb6, 0xa8, 0xf6, 0xd5};
static uint8_t initial_key1[8] = {0xe2, 0xfc, 0xd5, 0xa2, 0x75, 0x8a, 0xa3, 0xa9};
static uint8_t initial_key2[8] = {0x63, 0xad, 0x07, 0xf8, 0xb7, 0xe9, 0xb4, 0xff};

static inline __attribute__((always_inline)) uint64_t crc_initial() {
	return to64l(obfuscated_initial) ^ to64l(initial_key1) ^ to64l(initial_key2);
}

static inline __attribute__((always_inline)) uint64_t crc(uint64_t initial, const char* data, int size) {
	uint64_t polynomial = to64l(obfuscated_polynomial) ^ to64l(polynomial_key1) ^ to64l(polynomial_key2);
	uint64_t mask = to64l(obfuscated_mask) ^ to64l(mask_key1) ^ to64l(mask_key2);
	uint64_t crc = initial;
	for (int i = 0; i < size; i++) {
		crc ^= (uint64_t)data[i] << 56;
		for (int i = 0; i < 8; i++) {
			if ((crc & mask) != 0) {
				crc = (uint64_t)((crc << 1) ^ polynomial);
			} else {
				crc <<= 1;
			}
		}
	}
	return crc;
}
