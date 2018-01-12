#include <stdio.h>
int getint(){
    int x;
    scanf("%d", &x);
    return x;
}
int putint(int x){printf("%d",x);}
int putchar(int x);
int main()
{
    int a;
    a = getint();
    int b;
    b = getint();
    if (a > b) {
        putint(a + b);
        putchar(10);
    }
    if (a < b) {
        putint(a - b);
        putchar(10);
    }
    if (a == b) {
        putint(a * b);
        putchar(10);
    }
    if (a != b) {
        putint(a / b);
        putchar(10);
    }
    return 0;
}
