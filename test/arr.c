int getint();
int putint(int x);
int putchar(int x);
int main()
{
    int i;
    int s[10];
    int a;
    a = getint();
    a = a % 10;
    i = 0;
    while (i < 10) {
        s[i] = 1;
        i = i + 1;
    }
    s[3] = a;
    s[a] = 3;
    s[(s[(a + s[3]) % 10]*s[a]) % 10] = s[(s[a] + s[a * 2 % 10]) % 10] + a;
    i = 0;
    while (i < 10) {
        putint(s[i]);
        putchar(10);
        i = i + 1;
    }
    return 0;
}
