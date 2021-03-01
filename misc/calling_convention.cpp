#include<iostream>
using namespace std;


int conv (int n, int arg[10])
{
	int Rn=26;
	int temp=0, tempRn;
	for(int i=0;i<n;++i)
	{
		temp=arg[i];
		if(arg[i]%2!=0)
			++arg[i];
		Rn -= arg[i];
		tempRn = Rn;
		
		if(Rn < 8)
		{
			cout << "Remaining arguments passed in memory ";
			return 1;
		}
		
		if(i==0) cout << "Parameter N : LSB -> MSB" << endl;
		cout << "Parameter " << i+1 << " : R" << Rn  ;
		while(temp!=1)
		{
			cout << " , R" << ++tempRn;
			--temp;
		}
		cout << endl;
	}
	return 1;
}

int ret_conv(int ret)
{
	int temp=ret;
  	if(ret%2!=0)
        	++ret;
	int Rn = 26- ret;
    	int tempRn = Rn;

    	if(Rn < 8)
    	{
      		cout << "Return value stored in memory ";
        	return 1;
    	}

    	cout << "Return      : R" << Rn  ;
    	while(temp!=1)
    	{
        	cout << " , R" << ++tempRn;
        	--temp;
    	}
    	cout << endl;
    	return 1;
}

int main()
{
	int n;
	int ret;
	int arg[10];
	cout << "Enter the number of arguments : ";
	cin >> n;
	cout << endl ;
	for(int i=0 ; i<n ; ++i)
	{
		cout << "Enter the number of bytes in argument " << i+1 << " : ";
		cin >> arg[i];
	}
	cout << "Enter the number of bytes to be returned (0 if void) : ";
	cin >> ret;
	cout << endl;
	conv(n, arg);
	cout << endl;
	if(ret!=0)
		ret_conv(ret);
	return 1;

}
