int putint(int x);
int getint();
int putchar(int x);
int t(){putint(1);putchar(10);return 1;}
int f(){putint(0);putchar(10);return 0;}
int main()
{
    int a;
    a = getint();
    int b;
    b = getint();
    int c;
    c = a > b || t() || f();
    putint(c);
    putchar(10);
    c = !(a < b) && t() || f();
    putint(c);
    putchar(10);
    c = a == b || f() && t();
    putint(c);
    putchar(10);
    return 0;
}
