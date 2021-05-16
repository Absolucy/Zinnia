#pragma once
#include "config.h"
#include <stdbool.h>
#include <sys/signal.h>
#include <sys/sysctl.h>
#include <sys/types.h>

#define DEBUGGER_CHECK
#define GARBAGE_CODEGEN

#define SC_GETPID 20
#define SC_SYSCTL 202

static inline pid_t __attribute__((always_inline)) get_pid() {
	register pid_t pid asm("x0") = -1;
	register long syscall asm("x16") = SC_GETPID;
	asm volatile("svc #0x80" : "=r"(pid) : "r"(syscall) : "memory", "cc");
	return pid;
}

// Based off the example provided at https://developer.apple.com/library/archive/qa/qa1361/_index.html
static inline bool __attribute__((always_inline)) is_being_traced() {
#if defined(ANTI_DEBUG) && !DEBUG
	int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, get_pid()};
	struct kinfo_proc info;
	size_t size;
	info.kp_proc.p_flag = 0;

	register int* sysctl_name asm("x0") = mib;
	register uint sysctl_len asm("x1") = sizeof(mib) / sizeof(*mib);
	register void* sysctl_old asm("x2") = &info;
	register void* sysctl_old_len asm("x3") = &size;
	register void* sysctl_new asm("x4") = NULL;
	register void* sysctl_new_len asm("x5") = 0;
	register long syscall asm("x16") = SC_SYSCTL;
	register int retval asm("x0");
	asm volatile("svc #0x80"
				 : "=r"(retval)
				 : "r"(sysctl_name), "r"(sysctl_len), "r"(sysctl_old), "r"(sysctl_old_len), "r"(sysctl_new),
				   "r"(sysctl_new_len), "r"(syscall)
				 : "memory", "cc");

	return retval == 0 && ((info.kp_proc.p_flag & P_TRACED) != 0);
#else
	return false;
#endif
}
