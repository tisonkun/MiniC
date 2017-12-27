int putint(int x);
int getint();
int putchar(int xx);
int main()
{
    int a;
    a = getint();
    a = a - 10 * (a / 10);
    int s[10];
    int i;
    i = 0;
    while (i < 10) {
        s[i] = a;
        i = i + 1;
    }
    s[a] = 10;
    i = 0;
    while (i < 10) {
        putint(s[i] - a);
        i = i + 1;
        putchar(10);
    }
    return 0;
}
