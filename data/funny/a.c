int putchar(int x);
int putint(int x);
int n;
int f()
{
    putint(n);
    putchar(10);
    return 0;
}
int main()
{
    n = 10;
    putint(n);
    putchar(10);
    f();
    return 0;
}
