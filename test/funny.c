int getint();
int putint(int x);
int putchar(int x);
int _2(int x, int a[40])
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
    while (i < 40) {
        a[i] = 0;
        i = i + 1;
    }
    return l;
}
int _xor(int x, int y)
{
    int ax[40];
    int ay[40];
    _2(x, ax);
    _2(y, ay);
    int i;
    i = 40 - 1;
    int ans;
    ans = 0;
    while (i != -1) {
        if (ax[i] + ay[i] == 1)
            ans = ans * 2 + 1;
        else
            ans = ans * 2;
        i = i - 1;
    }
    return ans;
}
int putGame(int T)
{
    putchar(71);
    putchar(97);
    putchar(109);
    putchar(101);
    putchar(32);
    putint(T);
    putchar(58);
    putchar(32);
    return 0;
}
int sg[25];
int n;
int a[25];
int test()
{
    int ans;
    ans = 0;
    int i;
    i = 0;
    while (i < n) {
        if (a[i] % 2 == 1)
            ans = _xor(ans, sg[n - i - 1]);
        i = i + 1;
    }
    return ans;
}
int main()
{
    sg[0] = 0;
    int i;
    i = 1;
    while (i < 25) {
        int v[100];
        int j;
        int k;
        j = 0;
        while (j < 100) {
            v[j] = 0;
            j = j + 1;
        }
        j = 0;
        while (j < i) {
            k = 0;
            while (k < j + 1) {
                v[_xor(sg[j], sg[k])] = 1;
                k = k + 1;
            }
            j = j + 1;
        }
        j = 0;
        int fin;
        fin = 0;
        while (j < 100 && !fin) {
            if (!v[j]) {
                sg[i] = j;
                fin = 1;
            }
            j = j + 1;
        }
        i = i + 1;
    }
    // int kk;
    // kk = 0;
    // while(kk < 25){putint(sg[kk]);putchar(10);kk = kk +1;}
    n = getint();
    int Ti;
    Ti = 1;
    while (n != 0) {
        int i;
        i = 0;
        while (i < n) {
            a[i] = getint();
            i = i + 1;
        }
        putGame(Ti);
        Ti = Ti + 1;
        if (test()) {
            i = 0;
            int fin;
            fin = 0;
            while (i < n && !fin) {
                if (a[i]) {
                    int j;
                    int k;
                    j = i + 1;
                    while (j < n && !fin) {
                        k = j;
                        while (k < n && !fin) {
                            a[i] = a[i] - 1;
                            a[j] = a[j] + 1;
                            a[k] = a[k] + 1;
                            if (!test()) {
                                putint(i);
                                putchar(32);
                                putint(j);
                                putchar(32);
                                putint(k);
                                putchar(10);
                                fin = 1;
                            }
                            a[i] = a[i] + 1;
                            a[j] = a[j] - 1;
                            a[k] = a[k] - 1;
                            k = k + 1;
                        }
                        j = j + 1;
                    }
                }
                i = i + 1;
            }
        }
        else {
            putint(-1);
            putchar(32);
            putint(-1);
            putchar(32);
            putint(-1);
            putchar(10);
        }
        n = getint();
    }
    return 0;
}
