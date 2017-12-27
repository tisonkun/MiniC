int getint();
int putchar(int x);
int putint(int x);
int fa[4400066];
int a[200003];
int dep[200003];
int n;
int pos[200003];
int m;
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
int calcfa(int x)
{
    int i;
    i = 1;
    while (i < 22) {
        fa[x * 22 + i] = fa[fa[x * 22 + i - 1] * 22 + i - 1];
        i = i + 1;
    }
    return 0;
}
int query(int x, int p)
{
    int i;
    i = 21;
    int pi;
    pi = 2097152;
    while (p) {
        while (pi > p) {
            i = i - 1;
            pi = pi / 2;
        }
        p = p - pi;
        x = fa[x * 22 + i];
    }
    return a[x];
}
int main()
{
    int T;
    T = getint();
    while (T != 0) {
        T = T - 1;
        n = getint();
        int lastans;
        lastans = 0;
        m = 1;
        int j;
        j = 1;
        int i;
        i = 1;
        while (i < n + 1) {
            int op;
            int x;
            op = getint();
            x = getint();
            op = _xor(op, lastans);
            x = _xor(x, lastans);
            if (op == 1) {
                pos[j] = m;
                a[m] = x;
                fa[m * 22] = pos[j - 1];
                dep[m] = dep[pos[j - 1]] + 1;
                calcfa(m);
                m = m + 1;
                j = j + 1;
            }
            else if (op == 2) {
                pos[j] = pos[j - 1 - x];
                j = j + 1;
            }
            else { // op == 3
                lastans = query(pos[j - 1], dep[pos[j - 1]] - x);
                putint(lastans);
                putchar(10);
            }
            i = i + 1;
        }
    }
    return 0;
}
