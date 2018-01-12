int a;
int b;
int getint();
int putint(int i);
int main(){
	a = getint();
	b = getint();
	int c;
	c = -(a + b);
	int n;
	n = putint(c);
	return c;
}
