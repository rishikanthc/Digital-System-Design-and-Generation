#include <stdio.h>
#include <time.h>
#include "math.h"

#define kvalue 32
#define bits 8
#define count 4

struct d{
  long a:bits;
}a[kvalue*kvalue],x[kvalue];


struct e{
  long a:(2*bits);
}o[kvalue];
long long int mul,sum;

int main(int argc, char const *argv[])
{
  FILE *aData, *expectedOutput, *xData;
  aData = fopen("aData","w");
  xData = fopen("xData","w");
  expectedOutput = fopen("expectedOutput", "w");

  srand(time(NULL));
  long i,j,t,p,mask,mask2,iter;
  p=(pow(2,bits)-1);
  mask=1;
  for (iter = 0; iter < count; ++iter)
  {
    mask=1;
    for (i = 0; i < bits-1; ++i)
    {
      mask =(mask<<1)|1;
    }
    mask2=1;
    for (i = 0; i < 2*bits-1; ++i)
    {
      mask2 =(mask2<<1)|1;
    }
    printf("mask%d\n",mask );
    for (i = 0; i < kvalue*kvalue; ++i)
    {
      t=rand()%p;
      a[i].a=t;
      fprintf(aData,"%x\n",(a[i].a)&mask);
    }
    for (i = 0; i < kvalue; ++i)
    {
      t=rand()%p;
      x[i].a=t;
      fprintf(xData,"%x\n",(x[i].a)&mask);
    }
    sum=0; int k=0;
    for (i = 0,j=0; i < kvalue*kvalue; ++i,++j)
    {
      mul=(long long)a[i].a * x[j].a;
      sum=sum+mul;
      if(j==(kvalue-1))
      {
        j=-1;
        o[k].a=sum;
        sum=0;
        k++;
      }
  
    }
    printf("Expected Output\n");
    for (i = 0; i < kvalue; ++i)
    {
      printf("%d\n",o[i].a );
      fprintf(expectedOutput,"%llx\n",(o[i].a)&mask2);
    }}
  
  
  return 0;
}

