//
//  libhooker.h
//  libhooker
//
//  Created by CoolStar on 8/17/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#ifndef libhooker_h
#define libhooker_h

#ifdef __cplusplus
extern "C" {
#endif

/*!
* @enum libhooker errors
*
* @abstract
* Get a human readable string for debugging purposes.
*
* @discussion
* Passing zero for the value is useful for when two threads need to reconcile
* the completion of a particular event. Passing a value greater than zero is
* useful for managing a finite pool of resources, where the pool size is equal
* to the value.
*
* @constant LIBHOOKER_OK  No errors took place
* @constant LIBHOOKER_ERR_SELECTOR_NOT_FOUND An Objective-C selector was not found. (This error is from libblackjack)
* @constant LIBHOOKER_ERR_SHORT_FUNC A function was too short to hook
* @constant LIBHOOKER_ERR_BAD_INSN_AT_START A problematic instruction was found at the start. We can't preserve the original function due to this instruction getting clobbered.
* @constant LIBHOOKER_ERR_VM An error took place while handling memory pages
* @constant LIBHOOKER_ERR_NO_SYMBOL No symbol was specified for hooking
*/
enum LIBHOOKER_ERR {
	LIBHOOKER_OK = 0,
	LIBHOOKER_ERR_SELECTOR_NOT_FOUND = 1,
	LIBHOOKER_ERR_SHORT_FUNC = 2,
	LIBHOOKER_ERR_BAD_INSN_AT_START = 3,
	LIBHOOKER_ERR_VM = 4,
	LIBHOOKER_ERR_NO_SYMBOL = 5
};

/*!
* @function LHStrError
*
* @abstract
* Get a human readable string for debugging purposes.
*
* @discussion
* Passing zero for the value is useful for when two threads need to reconcile
* the completion of a particular event. Passing a value greater than zero is
* useful for managing a finite pool of resources, where the pool size is equal
* to the value.
*
* @param err
* The raw error value.
*
* @result
* A human-readable error string, or "Unknown Error" on invalid error.
*/
extern const char *LHStrError(enum LIBHOOKER_ERR err) __attribute__((weak_import));

#ifdef __cplusplus
}
#endif

#endif /* libhooker_h */
