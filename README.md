## libcksum

A tiny library implementing POSIX cksum algorithm for Linux.

### Build

Make targets:

* `make shared`: Build `libcksum.so` shared library
* `make static`: Build `libcksum.a` static library
* `make all` or just `make`: Build both versions of library
* `make test`: Build test binaries and check the implementation
* `make install`: install both libraries, header, and manfile
* `make uninstall`: uninstall libraries, header, and manfile
* `make clean`: clean build area

Make variables:

* `V`: enable verbose mode (1 to enable, 0 (default) to disable)
* `PREFIX`: set another prefix instead of default `/usr/local`
* `DESTDIR`: install to `$(DESTDIR)/$(PREFIX)` instead of `$(PREFIX)`

### API

* `uint32_t cksum (unsigned char *pbuf, uintmax_t length)`:
Calculate cksum of `length` bytes of `pbuf`.

### Example

A very simple (e.g., no error handling, small files only, no "-" support)
implementation of `cksum(1)` from coreutils:

```
#include <stdlib.h>
#include <stdio.h>
#include <cksum.h>

int main(int argc, char *argv[])
{
    FILE *f = fopen(argv[1],"r");
    fseek(f, 0L, SEEK_END);
    size_t size = ftell(f);
    rewind(f);
    unsigned char *buf = malloc(size);
    fread(buf, size, 1, f);
    uint32_t sum = cksum(buf, size);
    fclose(f);
    free(buf);
    printf("%u %u %s\n", sum, size, argv[1]);
    return 0;
}
```
Build it with the command like this:
```
cc libcksum_test.c -lcksum -o libcksum_test
```
Run the same way you run `cksum`:
```
./libcksum_test testfile.bin
```
