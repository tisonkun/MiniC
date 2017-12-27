int n;
int getint();
int putint(int x);
int putchar(int x);
int f(int n)
{
    putint(n);
    n = 10;
    putchar(n);
    return 0;
}
int main()
{
    n = getint();
    if (n > 5) {
        int n;
        n = getint();
        f(n);
    }
    else
        f(getint());
    f(n);
    return 0;
}
