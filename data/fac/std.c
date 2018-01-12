int getint();
int putint(int x);
int putchar(int x);
int i;
int a;
int fac(int n)
{
    i = 0;
    a = 1;
    while (i != n + 1) {
        putint(i);
        putchar(58); // colon
        putint(a);
        putchar(10); // new line
        i = i + 1;
        a = a * i;
    }
    return 0;
}
int main()
{
    fac(getint());
    putint(i);
    putchar(10);
    putint(a);
    putchar(10);
    return 0;
}
