#include <unistd.h>
#include "Godzilla.h"

extern "C" bool check_for_plist() {
	return access("/var/lib/dpkg/info/me.aspenuwu.zinnia.list", F_OK) == 0;
}
