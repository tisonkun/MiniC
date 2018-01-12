int getint(){int x;scanf("%d",&x);return x;}
int putchar(int x);
int putint(int x){printf("%d",x);}
int a[100000];
int n;
int qsort(int L, int R)
{
    int swap(int a, int b);
    int m;
    m = (L + R) / 2;
    int am;
    am = a[m];
    int l;
    int r;
    l = L;
    r = R - 1;
    while (l < r + 1) {
        while (a[l] < am)
            l = l + 1;
        while (a[r] > am)
            r = r - 1;
        if (l < r + 1) {
            swap(l, r);
            l = l + 1;
            r = r - 1;
        }
    }
    if (r > L)
        qsort(L, r + 1);
    if (l < R-1)
        qsort(l, R);
}
int swap(int x, int y)
{
    int t;
    t = a[x];
    a[x] = a[y];
    a[y] = t;
}
int main()
{
    n = getint();
    int i;
    i = 0;
    while (i < n) {
        a[i] = getint();
        i = i + 1;
    }
    qsort(0, n);
    i = 0;
    while (i < n) {
        putint(a[i]);
        putchar(10);
        i = i + 1;
    }
    return 0;
}
