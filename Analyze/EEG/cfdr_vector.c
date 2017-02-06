#include "mex.h"

// [sig] = fdr_vector(p, psorted, alpha, stringent)

/* the gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  double *p,*psorted, *sig;
  double  alpha, stringent;
  double pcut = 0;
  double c =1;
  mwSize nvals, N, mrows, ncols;
  int i,j;
  

  // Create the output
  mrows = mxGetM(prhs[0]);
  ncols = mxGetN(prhs[0]);
  
  if (mrows > ncols)
  {
      N = mrows;
  }
  else
  {
      N = ncols;
  }
          
  
  plhs[0] = mxCreateDoubleMatrix(mrows,ncols, mxREAL);
  sig = mxGetPr(plhs[0]);
  
  /*  get the scalar input x */
  p = mxGetPr(prhs[0]);
  psorted = mxGetPr(prhs[1]);
  alpha = mxGetScalar(prhs[2]);
  stringent = mxGetScalar(prhs[3]);
  
  
  for (i=0; i<N; i++)
  {
      if (stringent == 1.0)
      {
          c = 0;
          for(j=1; j<=i+1; j++)
          {
            c = c+1.0/j; 
          }
      }
          
      if (*(psorted+i) < alpha*(i+1)/(N*c))
      {
        pcut = *(psorted+i);
        break;
      }     
  }
  
  for(i=0; i<N; i++)
  {
      if (*(p+i) < pcut){
          *(sig+i) = 1;
      }
      else{
          *(sig+i) = 0;
      }
  }
}
