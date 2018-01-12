#include <stdio.h>
int getint()
{
    int x;
    scanf("%d", &x);
    return x;
}
int putint(int x)
{
    printf("%d",x);
}
int putchar(int x);
int f(int a[100], int x)
{
    a[x] = x * x;
    return x;
}
int cp(int a[100], int b[100])
{
    int i;
    i = 0;
    while (i < 100) {
        b[i] = a[i];
        i = i + 1;
    }
}
int s[100];
int main()
{
    int a;
    a = getint();
    a = a % 100;
    int i;
    i = 0;
    while (i < 100)
        if (i < a)
            i = f(s, i) + 1;
        else {
            s[i] = i;
            i = i + 1;
        }
    int s2[100];
    cp(s, s2);
    i = 0;
    while (i < 100) {
        putint(s2[i]);
        putchar(10);
        i = i + 1;
    }
    return 0;
}
