#pragma once
#include <stdint.h>
#include <string.h>

/// Compares two strings. This is simply to avoid linking to strcmp.
static inline bool __attribute__((always_inline)) compare(const char* a, const char* b) {
	int i = 0;
	while (a[i] != 0 && b[i] != 0) {
		if (a[i] != b[i])
			return false;
		i++;
	}
	return true;
}


/// Comapres two arbritrary pieces of data. This is simply to avoid linking to memcmp.
static inline bool __attribute__((always_inline)) compare_len(uint8_t* a, uint8_t* b, size_t len) {
	for (int i = 0; i < len; i++) {
		if (a[i] != b[i])
			return false;
	}
	return true;
}

/// Checks to see if a string ends with a particular suffix.
static inline int __attribute__((always_inline)) str_ends_with(const char* s, const char* suffix) {
	size_t slen = strlen(s);
	size_t suffix_len = strlen(suffix);

	return suffix_len <= slen && !strcmp(s + slen - suffix_len, suffix);
}
