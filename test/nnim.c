int getint();
int putint(int x);
int putchar(int x);
int n;
int m;
int a[100003];
int _2(int x, int a[33])
{
    int l;
    l = 0;
    while (x != 0) {
        a[l] = x % 2;
        l = l + 1;
        x = x / 2;
    }
    int i;
    i = l;
    while (i < 33) {
        a[i] = 0;
        i = i + 1;
    }
    return l;
}
int f[33];
int main()
{
    int T;
    T = getint();
    while (T != 0) {
        T = T - 1;
        m = getint();
        n = getint();
        int i;
        i = 0;
        while (i < m) {
            a[i] = getint();
            i = i + 1;
        }
        i = 0;
        while (i < 33) {
            f[i] = 0;
            i = i + 1;
        }
        int j;
        j = 0;
        while (j < m) {
            i = 0;
            int s[33];
            _2(a[j], s);
            while (i < 33) {
                f[i] = (f[i] + s[i]) % (n + 1);
                i = i + 1;
            }
            j = j + 1;
        }
        int ans;
        ans = 0;
        i = 0;
        while (i < 33) {
            if (f[i])
                ans = 1;
            i = i + 1;
        }
        if (ans) {
            putchar(89);
            putchar(101);
            putchar(115);
        }
        else {
            putchar(78);
            putchar(111);
        }
        putchar(10);
    }
    return 0;
}
