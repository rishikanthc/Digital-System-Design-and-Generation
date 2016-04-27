#include <stdio.h>
#include <time.h>
#define number 10
int main()
{
	int inputs = 20;
	int count=number;
	srand(time(NULL));
	
	FILE *inputData, *expectedOutput;
	inputData = fopen("inputData","w");
	expectedOutput = fopen("expectedOutput", "w");
	int i,j,k;
	signed int  o[12];
	char a[4][4],x[4][1],testdata[count][20];
	short int f,t,mul[4][1];
	f=0; k=4;
	
	int m,n,p,q;
	
	for ( m = 0; m < count; ++m)
	{
		k=4;
		for ( i = 0; i < 4; ++i)
		for (j = 0; j < 4; ++j)
		{
			a[i][j]=(rand() % 256)- 128;
			testdata[m][k]=a[i][j];
			k++;
		}

		for (i = 0; i < 4; ++i)
		for (j = 0; j < 1; ++j)
		{
			x[i][j]=(rand() % 256)- 128;
			testdata[m][i]=x[i][j];
		}


		for (i = 0; i < 20; ++i)
		{
			fprintf(inputData,"%x\n",(testdata[m][i]&0xff));
		}


	for (i = 0; i < 4; ++i)
	{
		mul[i][0]=0;
		for (j = 0; j < 4; ++j)
		{
			mul[i][0] += a[i][j] * x[j][0];
		}
	}

	for (i = 0; i < 4; ++i)
	{
		for (j = 0; j < 4; ++j)
			printf("%d ",a[i][j] );
		printf("\n");
	}

	for (i = 0; i < 4; ++i)
	{
		for (j = 0; j < 1; ++j)
			printf("%d ",x[i][j] );
		printf("\n");
	}

	for ( i = 0; i < 4; ++i)
	{
		for ( j = 0; j < 1; ++j)
		{
			printf("%hd\n",mul[i][j] );
			fprintf(expectedOutput,"%x\n",(mul[i][j]&0xffff) );
		}
	}
	}


	fclose(inputData);
	fclose(expectedOutput);
	return 0;
}

//*************OLDER VERSION******************
//fprintf(expectedOutput,"x\nx\n0\n0\n0\n");
	/*for ( i = 0; i < 3; ++i)
		for (j = 0; j < 3; ++j)
		{
			a[i][j]=(rand() % 256)- 208;
			testdata[k]=a[i][j];
			k++;
		}

	for (i = 0; i < 3; ++i)
		for (j = 0; j < 1; ++j)
		{
			x[i][j]=(rand() % 256)- 128;
			testdata[i]=x[i][j];
		}

	for (i = 0; i < 12; ++i)
	{
		fprintf(inputData,"%x\n",(testdata[i]&0xff));
	}

	for (i = 0; i < 3; ++i)
	{
		mul[i][0]=0;
		for (j = 0; j < 3; ++j)
		{
			mul[i][0] += a[i][j] * x[j][0];
		}
	}

	for (i = 0; i < 3; ++i)
	{
		for (j = 0; j < 3; ++j)
			printf("%d ",a[i][j] );
		printf("\n");
	}

	for (i = 0; i < 3; ++i)
	{
		for (j = 0; j < 1; ++j)
			printf("%d ",x[i][j] );
		printf("\n");
	}

	for ( i = 0; i < 3; ++i)
	{
		for ( j = 0; j < 1; ++j)
		{
			printf("%hd\n",mul[i][j] );
			fprintf(expectedOutput,"%x\n",(mul[i][j]&0xffff) );
		}
	} */
