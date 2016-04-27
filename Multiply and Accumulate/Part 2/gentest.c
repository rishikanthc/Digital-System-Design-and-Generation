#include <stdio.h>
#include <time.h>

int main()
{
	int inputs = 1000;
	srand(time(NULL));
	
	FILE *inputData, *expectedOutput;
	inputData = fopen("inputData","w");
	expectedOutput = fopen("expectedOutput", "w");
	int i;
	signed int  a, b;
	short int f;
	f=0;
	fprintf(expectedOutput,"x\nx\n0\n0\n0\n");
	for(i=0;i<1000;i++)
	{
		a = (rand() % 256) - 128;
		b = (rand() % 256) - 128;
		f= f+(a*b);
		printf("%d %d %d\n",a,b,f);
		fprintf(inputData,"%x\n%x\n",((a>>0)&0xff),((b>>0)&0xff));
		fprintf(expectedOutput, "%hd\n",f);//((f>>0)&0xffff));
	}
	printf("%d",sizeof(f));
	fclose(inputData);
	fclose(expectedOutput);
	return 0;
}
