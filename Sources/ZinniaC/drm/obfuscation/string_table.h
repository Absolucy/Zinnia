#pragma once
#include "chacha20.h"
#include "shuffle.h"
#include <stdint.h>
#include <stdlib.h>

/// An obfuscated decryption key.
typedef struct {
	uint32_t key[8];
	uint32_t nonce[3];
	uint32_t xor_key[8];
	uint32_t xor_nonce[3];
} decryption_key;

/// A string table entry, describing the length of the string,
/// and the keys needed to decrypt the string.
typedef struct {
	uint32_t length;
	decryption_key keys;
} string_entry;

/// Get a string from the string table, automatically decrypting it.
/// You must free() this string later!
#ifdef DRM
char* st_get(uint32_t idx);
#else
char* st_get(const char* name);
#endif

/// Get some arbritrary data from the string table, automatically decrypting it.
/// You must free() this data later!
#ifdef DRM
void st_get_bytes(uint32_t idx, void (^callback)(uint8_t*, size_t));
#else
void st_get_bytes(const char* name, void (^callback)(uint8_t*, size_t));
#endif

/// Initialize the string table. This should only be run once, after __TEXT,__text has been decrypted.
/// If this segfaults in "platform_memmove", then that means decryption FAILED!
void initialize_string_table();
