#include<stdio.h>

struct sample {
    int x1;
    int x2;
    struct sample *next;
};

void test(int *p, struct sample* s) {
    s->x2 = *p;
}

int main () {
    int a, *p;
    a = 10;
    p = &a;
    struct sample s1;
    s1.x1 = 20;
    test(p, &s1);
    printf("%d",s1.x2 + s1.x1);
}