#include <stdio.h>
#include "mymalloc.h"

int main() {
    int *p = (int*) mymalloc(sizeof (int));
    printf("Get p: %p\n", (void*) p);
    int *k = NULL;
    for (int i = 0; i < 10; i += 1) {
        if (k) {
            myfree(k);
        }
        k = mymalloc(sizeof (int));
    }
    myfree(p);
    collect(fileno(stdout));
    return 0;
}