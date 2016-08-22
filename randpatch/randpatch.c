#define _GNU_SOURCE
#include <dlfcn.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
FILE *fopen(const char *path, const char *mode) {
    void *(*original_fopen)(const char *, const char *) = dlsym(RTLD_NEXT, "fopen");
    if (!strcmp(path, "/dev/random")) {
        path = "/dev/urandom";
    }
    return original_fopen(path, mode);
}
int open(const char *path, int oflag, ...) {
    int (*original_open)(const char *, int, ...) = dlsym(RTLD_NEXT, "open");
    int ret;
    va_list args;
    if (!strcmp(path, "/dev/random")) {
        path = "/dev/urandom";
    }
    va_start(args, oflag);
    if (oflag & O_CREAT) {
        ret = original_open(path, oflag, (mode_t)va_arg(args, mode_t));
    } else {
        ret = original_open(path, oflag);
    }
    va_end(args);
    return ret;
}
