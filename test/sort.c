int getint();
int putint(int x);
int putchar(int x);
int a[100];
int n;
int swap(int x, int y)
{
    int t;
    t = a[x];
    a[x] = a[y];
    a[y] = t;
    return 0;
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
    int j;
    i = 0;
    while (i < n) {
        j = i + 1;
        while (j < n) {
            if (a[i] > a[j])
                swap(i, j);
            j = j + 1;
        }
        i = i + 1;
    }
    i = 0;
    while (i < n) {
        putint(a[i]);
        putchar(10);
        i = i + 1;
    }
    return 0;
}
