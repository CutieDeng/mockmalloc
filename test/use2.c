#include <stdio.h>
#include <stdlib.h>
#include "mymalloc.h"

int main() {
    int *k[45];
    for (int i = 0; i < 45; i += 1) {
        k[i] = (int*) mymalloc(sizeof (int));
    }
    for (int i = 0; i < 260; i += 1) {
        int s = random() % 43;
        int *t = (int*) mymalloc(sizeof(int));
        myfree(k[s]);
        k[s] = t;
    }
    for (int i = 0; i < 45; i += 1) {
        myfree(k[i]);
    }
    collect(fileno(stdout));
    return 0;
}