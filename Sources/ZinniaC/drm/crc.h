#include <stdint.h>

#define to64l(arr)                                                                                                     \
	(((uint64_t)(((uint8_t*)(arr))[0]) << 0) + ((uint64_t)(((uint8_t*)(arr))[1]) << 8) +                               \
	 ((uint64_t)(((uint8_t*)(arr))[2]) << 16) + ((uint64_t)(((uint8_t*)(arr))[3]) << 24) +                             \
	 ((uint64_t)(((uint8_t*)(arr))[4]) << 32) + ((uint64_t)(((uint8_t*)(arr))[5]) << 40) +                             \
	 ((uint64_t)(((uint8_t*)(arr))[6]) << 48) + ((uint64_t)(((uint8_t*)(arr))[7]) << 56))

const uint8_t obfuscated_polynomial[8] = {0xab, 0xc9, 0xdd, 0x84, 0x34, 0x0e, 0x3a, 0xf0};
const uint8_t polynomial_key[8] = {0xe2, 0xd2, 0x28, 0x50, 0xc1, 0x7e, 0x42, 0x51};

static inline uint64_t crc(uint64_t initial, const char* data, int size) {
	uint64_t polynomial = to64l(obfuscated_polynomial) ^ to64l(polynomial_key);
	uint64_t crc = initial;
	for (int i = 0; i < size; i++) {
		crc ^= (uint64_t)data[i] << 56;
		for (int i = 0; i < 8; i++) {
			if ((crc & 0x8000000000000000) != 0) {
				crc = (uint64_t)((crc << 1) ^ polynomial);
			} else {
				crc <<= 1;
			}
		}
	}
	return crc;
}
