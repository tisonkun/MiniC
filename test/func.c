int getint();
int putint(int x);
int putchar(int x);
int f(int x)
{
    int s;
    s = 0;
    int i;
    i = 0;
    while (i < x) {
        i = i + 1;
        s = s + x * i;
        putint(s);
        putchar(10);
    }
    return s;
}
int g(int x)
{
    if (x % 2 == 0)
        return f(x);
    else
        return f(x + 1);
}
int main()
{
    int a;
    a = getint();
    int b;
    b = f(a) + g(a);
    putint(b);
    putchar(10);
    return 0;
}
