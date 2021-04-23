#include "string_table.h"

static char* st_get(uint32_t idx) {
	struct string_entry* entry = &lookup_table[idx];
	struct chacha20_context ctx;
	st_key(&ctx, idx);

	char* string_base = (char*)encrypted_string;
	for (int i = 0; i < idx - 1; i++) {
		string_base += lookup_table[i].length;
	}

	char* string = (char*)malloc(entry->length);
	memcpy(string, string_base, entry->length);
	chacha20_xor(&ctx, (uint8_t*)string, entry->length);

	return string;
}
