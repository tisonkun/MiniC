int getint(){int x;scanf("%d",&x);return x;}
int putint(int x){printf("%d",x);}
int putchar(int x);
int main()
{
    int a;
    a = getint();
    int b;
    b = getint();
    int c;
    c = getint();
    putint(a + b * c);
    putchar(10);
    putint(a - b * c);
    putchar(10);
    putint(a + b - c);
    putchar(10);
    putint(a - b - c);
    putchar(10);
    putint(a - (b - c));
    putchar(10);
    putint(a * (b - c));
    putchar(10);
    putint(a * (b - c * 2));
    putchar(10);
    putint(a / (b + 1) * c);
    putchar(10);
    putint(-(a + b));
    putchar(10);
    putint(a - (a * (b / 3 - c)));
    putchar(10);
    return 0;
}
