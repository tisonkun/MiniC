int getint();
int putint(int x);
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
    if (a < b) {
        putint(a - b);
        putchar(10);
    }
    if (a == b) {
        putint(a * b);
        putchar(10);
    }
    if (a != b) {
        putint(a / b);
        putchar(10);
    }
    return 0;
}
