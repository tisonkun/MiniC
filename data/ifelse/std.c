int getint(){int x;
scanf("%d",&x);return x;}
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
    else {
        putint(a - b);
        putchar(10);
    }
    if (a < b) {
        putint(a - b);
        putchar(10);
    }
    else if (a == b) {
        putint(a * b);
        putchar(10);
    }
    else if (a != b) {
        putint(a / b);
        putchar(10);
    }

    int c;
    c = 0;
    if (a < b)
        c = 1;
    else if (a < b * 2)
        c = 2;
    else
        c = 3;
    putint(c);
    putchar(10);

    int d;
    d = 0;
    if (a < b)
        if (a < b / 2)
            d = 2;
        else
            d = 3;
    putint(d);
    putchar(10);

    int e;
    e = 0;
    if (a > b)
        if (a > b * 2)
            if (a > b * 3)
                e = 4;
            else
                e = 3;
    putint(e);
    putchar(10);

    int f;
    f = 0;
    if (a > b)
        if (a > b * 2)
            if (a > b * 3)
                f = 4;
            else if (a * 2 > b * 5) {
                f = 3;
                if (a > b + 10)
                    f = 2;
            }
            else
                f = 5;
        else
            f = 6;
    putint(f);
    putchar(10);
    return 0;
}
