#include "anti_debug.h"
#include "checksum.h"
#include "config.h"
#include <Foundation/Foundation.h>
#include <fts.h>

__attribute__((section(SECTION_FILENAME_HASH_KEY))) __attribute__((used)) static uint8_t checksum_key[289] = {};

bool dpkg_check() {
	FTS* ftsp;
	FTSENT *p, *chp;

	GARBAGE_CODEGEN

	uint8_t retval = (1 << 1) | (1 << 7);
	char* paths[] = {"/var/lib/dpkg/info", NULL};

	if ((ftsp = fts_open(paths, FTS_COMFOLLOW | FTS_NOCHDIR | FTS_NOSTAT | FTS_XDEV, NULL)) == NULL) {
		return false;
	}
	DEBUGGER_CHECK
	/* Initialize ftsp with as many argv[] parts as possible. */
	chp = fts_children(ftsp, 0);
	if (chp == NULL) {
		return false;
	}
	DEBUGGER_CHECK
	while ((p = fts_read(ftsp)) != NULL) {
		DEBUGGER_CHECK
		uint64_t filename = hash(checksum_key, p->fts_path, p->fts_pathlen);
		switch (filename) {
			case GOOD_FILENAME_HASH:
				retval = retval | (1 << 3);
				break;
			case BAD_FILENAME_HASH_1:
				retval = retval | (1 << 4);
				break;
			case BAD_FILENAME_HASH_2:
				retval = retval | (1 << 5);
				break;
			case BAD_FILENAME_HASH_3:
				retval = retval | (1 << 6);
				break;
			default:
				break;
		}
	}
	fts_close(ftsp);

	DEBUGGER_CHECK
	if (access(GOOD_FILENAME, F_OK) == 0) {
		GARBAGE_CODEGEN
		retval = retval | (1 << 2);
	}

end:
	GARBAGE_CODEGEN
	return ((retval >> 1) & 1) && ((retval >> 2) & 1) && ((retval >> 3) & 1) &&
		   !(((retval >> 4) & 1) || ((retval >> 5) & 1) || ((retval >> 6) & 1)) && ((retval >> 7) & 1);
}
