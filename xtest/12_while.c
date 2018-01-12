int putint(int i);
int a;
int b;
int main(){
	b=0;
	a=3;
	while(a>0){	
		b = b+a;
		a = a-1;
	}
	int n;
	n= putint(b);
	return b;
}	
