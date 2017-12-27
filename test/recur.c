int getint();
int putint(int x);
int putchar(int x);
int fac(int x)
{
    if (x < 2)
        return 1;
    int a;
    a = x - 1;
    int t;
    t = fac(a);
    a = a - 1;
    return t + fac(a);
}
int main()
{
    int a;
    a = getint();
    putint(fac(a));
    putchar(10);
    return 0;
}
