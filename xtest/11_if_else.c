int putint(int i);
int a;
int main(){
	a = 10;
	int n;
	int one;
	one = 1;
	int zero;
	zero = 0;
	if( a>0 ){
		n = putint(one);
		return 1;
	}
	else{
		n = putint(zero);
		return 0;
	}
}
