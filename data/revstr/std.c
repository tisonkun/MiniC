int getint(){int x;scanf("%d",&x);return x;}
int getchar();
int putchar(int x);
int n;
int a[100];
int main()
{
    n = getint();
    getchar();
    int i;
    i = 0;
    while (i < n) {
        a[i] = getchar();
        i = i + 1;
    }
    i = 0;
    while (i < n / 2) {
        int t;
        t = a[i];
        a[i] = a[n - 1 - i];
        a[n - 1 - i] = t;
        i = i + 1;
    }
    i = 0;
    while (i < n) {
        putchar(a[i]);
        i = i + 1;
    }
    putchar(10);
    return 0;
}
