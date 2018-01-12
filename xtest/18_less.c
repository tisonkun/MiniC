int getint();
int a;
int b;
int putint(int i);
int main(){
	a = getint();
	b = getint();
	int n;
	int one;
	one = 1;
	int zero;
	zero = 0;
	if ( a < b ){
		n = putint(one);
		return 1;
	}
	else{
		n = putint(zero);
		return 0;
	}
}
