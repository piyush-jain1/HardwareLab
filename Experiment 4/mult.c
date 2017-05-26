#include <stdio.h>
#include <stdlib.h>

int main()
{
	int a[16][16],b[16][16];
	int c[16][16];
	int i,j;
	for(i = 0; i < 16; i++)
	{
		for(j = 0 ; j < 16 ; j++)
		{
			a[i][j] = 1;
			b[i][j] = 1;
		}
	}
	for(i = 0; i < 16; i++)
	{
		for(j = 0 ; j < 16 ; j++)
		{
			printf("%c", a[i][j]);
		}
	}
	for(i = 0; i < 16; i++)
	{
		for(j = 0 ; j < 16 ; j++)
		{
			printf("%c", b[j][i]);
		}
	}
	return 0;


}