/*=================================================================
 *  MI.c 
 * Calculation of modulation index, given two input arrays of 
 * low and high frequency components
 *
 * Ryan McGinn, 2012
 *============================================================*/

#include <math.h>
#include <stdlib.h>
#include "mex.h"
#include "MI.h"
#ifndef pi 
#define pi 3.14159265358979323846
#endif
#ifndef isnan
#define isnan(x) ((x) != (x))
#endif

/* FUNCTION for determining PHASE for a complex array */
double *phase(double *Sim, double *Sre, int sizeS) {
    int i;
    double *phi = (double *)malloc(sizeS*sizeof(double));

    for(i=0;i<sizeS;i++) {
        phi[i] = atan2(Sim[i],Sre[i]);
        /*wrap phases between -pi and pi */
        phi[i] = fmod(phi[i]+pi,2*pi) - pi;
    }
    
    return phi;
}

/* FUNCTION for determining envelope for a complex array */
double *env(double *Sim, double *Sre, int sizeS) {
    int i;
    double *envelope = (double *)malloc(sizeS*sizeof(double));

    for(i=0;i<sizeS;i++) {
        envelope[i] = sqrt(pow(Sim[i],2) + pow(Sre[i],2));
    }
    return envelope;
}

/* FUNCTION for BINNING angular data */
struct ABo *angular_bins(double *phi, int nbins, int n){
    double jump = 2*pi/((double)nbins);
    int i,j,k;
    int *bufflim;
    int *nbuff;
    int buffres;
    double *binedges;
    struct ABo *ab_out;
    
    ab_out = malloc(sizeof(struct ABo));
    
    /* allocate memory */
    binedges = (double *)malloc((nbins+1)*sizeof(double));
    ab_out->phin = (int *) malloc(nbins*sizeof(int));
    ab_out->pii = (int **) malloc(nbins*sizeof(int *));
    ab_out->phis = (double **) malloc(nbins*sizeof(double *));
    ab_out->phim = (double *) malloc(nbins*sizeof(double));
    bufflim = (int *)malloc((nbins + 1)*sizeof(int));
    nbuff = (int *) malloc(nbins*sizeof(int));
    
    /* Define bin edges */
    binedges[0] = -pi;
    for(i=1;i<nbins;i++) {
        binedges[i] = -pi+i*jump;
    }
    binedges[nbins] = pi;
    

    buffres = floor(0.5*((1/(double)nbins))*n);
    /* Allocate space for pii and phis pointers */
    for(i=0;i<nbins;i++) {
        ab_out->pii[i] = (int *)malloc(buffres*sizeof(int));
        ab_out->phis[i] = (double *)malloc(buffres*sizeof(double));
        ab_out->phin[i] = 0;
        bufflim[i] = buffres;
    }
    
    /* Bin phase values
     * Except for edge cases, is dealt with by the formula
     * k = (phi+pi*nbins)/2pi
     * where k is the index of the bin
     */
    for (j=0;j<n;j++) {
        if(phi[j] == -pi) {
            k = 1;
            ab_out->pii[1][(ab_out->phin[1])] = j;
            ab_out->phis[1][(ab_out->phin[1])] = phi[j];
            ab_out->phin[1] += 1;
        }
        else if(phi[j] == pi) {
            k = nbins;
            ab_out->pii[nbins][(ab_out->phin[nbins])] = j;
            ab_out->phis[nbins][(ab_out->phin[nbins])] = phi[j];
            ab_out->phin[nbins] += 1;
        }   
        else if(phi[j] > pi || phi[j]<-pi) {
            printf("Error, Please wrap phase between -pi and pi, phi = %0.2f\n",phi[j]);
        }
        else {  
            k = floor(((phi[j] + pi)*(nbins))/(2*pi));
            if(k<0 || k >= nbins) {
                printf("Phases do not fit within set bins, please check");
            }
            else {
            ab_out->pii[k][(ab_out->phin[k])] = j;
            ab_out->phis[k][(ab_out->phin[k])] = phi[j];
            ab_out->phin[k] += 1;
            }
        }
        if(ab_out->phin[k] == bufflim[k]) {
            bufflim[k] = bufflim[k] + buffres;
            ab_out->pii[k] = realloc(ab_out->pii[k],(bufflim[k])*sizeof(int));
            ab_out->phis[k] = realloc(ab_out->phis[k],(bufflim[k])*sizeof(double));
        }
    }
    
    /* Determine the mean of each bin */
    for(i=1;i<=nbins;i++){
        ab_out->phim[i-1] = (double)((binedges[i-1]) + (binedges[i]))/2;
    }
    
    /* Free unreturned variables */
    free(binedges);
    free(bufflim);
    free(nbuff);
    
    /* Return structure */
    return ab_out;
}


/* FUNCTION for NORMALIZING a probability distribution */

double *normalize_distn(double *D, int lengthD) {
    double S;
    double *P;
    int i;
    /*printf("entered Probability normalization\n"); */
    P = (double *)malloc(lengthD*sizeof(double));
    
    S = 0;
    for(i=0;i<lengthD;i++){
        S = S + D[i];
    }
    if(S<1e-100){
        printf("Error: Normalization factor approaches zero in 'normalize_distn'\n");
        return P;
    }
    for(i=0;i<lengthD;i++){
        P[i] = D[i]/S;
    }
    return P;
}
        
        
/* FUNCTION for determining Kullback-Liebler Distance */
double d_kl(double *P, double *Q, int lengthP) {
    double dkl;
    int i;
    
    dkl = 0;
    for(i=0;i<lengthP;i++) {
        if(P[i]<1E-300 || isnan(P[i]) == 1) {
            dkl = dkl + 0;
        }
        else if(isnan(P[i]==1)) {
            printf("NaN value for P in 'd_kl', setting summation term to 0");
        }
        else {
            dkl = dkl + P[i]*log(((double)P[i])/((double)Q[i]));
        }
    }
    return dkl;
}
                   
                   
/*FUNCTION for determining MODULATION INDEX */
double mi_tort(double *P, int lengthP) {
    double *U;
    double D,MI;
    int i;
    
    U = (double *)malloc(lengthP*sizeof(double));
    
    /*Compute Kullback-Liebler distance */
    for(i=0;i<lengthP;i++){
        U[i] = (double)1/(double)lengthP;
    }
    D = d_kl(P,U,lengthP);
    MI = D/log((double)lengthP);
    
    /* free allocated distribution */
    free(U);
    
    /* Return Modulation Index */
    return MI;
}

/* FUNCTION for determining mean of a subset of an array determined by indices */
double mean4ind(double *arr, int *ind, int sizeind) {
    int i;
    double S;
    
    S = 0;
    for(i=0;i<sizeind;i++) {
        S += arr[ind[i]];
    }
    S = S/sizeind;
    return S;
}
           

/* FUNCTION for determining the modulation index */       
double *modind_tort(double *A_fa, double *phi_fp, int nbins, int n) {
    /* define variables */
    double *A_fa_avg;
    double *P, Ptest;
    double *miphi;
    double phimax,mi;
    struct ABo *ab_out;
    int i,j;
    
    
    A_fa_avg = (double *)malloc(nbins*sizeof(double));
    miphi = (double *)malloc(2*sizeof(double));
    /* Bin Phase Data */
    ab_out = angular_bins(phi_fp,nbins,n);
    
    /*Average Amplitude over each phase bin */
    for(i=0;i<nbins;i++) {
       if((ab_out->phin[i])==0) { 
           A_fa_avg[i] = 0;
       }
       else{
           A_fa_avg[i] = mean4ind(A_fa,(ab_out->pii[i]),(ab_out->phin[i]));
       }
    }
   
    /* Normalize Amplitude distribution */
    P = normalize_distn(A_fa_avg,nbins);
    
    /* Find Maximal Phase of Distribution */
    phimax = ab_out->phim[0];
    Ptest = P[0];
    for(i =1;i<nbins;i++) {
        if(P[i] > Ptest) {
            phimax = ab_out->phim[i];
            Ptest = P[i];
        }
    }
    mi = mi_tort(P,nbins);
    /* Free unreturned variables */
    free(A_fa_avg);
    free(P);
    for(i=0;i<nbins;i++){
        free(ab_out->phis[i]);
        free(ab_out->pii[i]);
    }
    free(ab_out->phin);
    free(ab_out->pii);
    free(ab_out->phis);
    free(ab_out->phim);
    free(ab_out);
    
    miphi[0] = mi;
    miphi[1] = phimax;
    
    /* Return modulation index */
    return miphi;
}

 
/* EXTERNAL CALL LIKELY SENDS HERE FIRST: */
/* FUNCTION for creating modulation index COMODULOGRAM */
struct mio *mi_comodulogram_TF(double **A_fa, int nA, double **phi_fp, 
                                     int nP, int nt){
    /*Define Parameters*/
    int i,j,k;
    int nbins = 12;
    double *tmpA;
    double *tmpP;
    double *miphi_tmp;
    struct mio *miout;
    
    miout = malloc(sizeof(struct mio));
    
    miout->cm = (double *)malloc(nA*nP*sizeof(double));
    miout->phimi = (double *)malloc(nA*nP*sizeof(double));
    tmpA = (double *)malloc(nt*sizeof(double));
    tmpP = (double *)malloc(nt*sizeof(double));

      
    /* Pre-allocate comodulogram matrix */
    
    for(i=0; i<nA; i++) {
        for(j=0; j<nP;j++) {
            /* Find Relevant section of Phase frequency */
            for(k=0;k<nt;k++){
                tmpA[k] = A_fa[i][k];
                tmpP[k] = phi_fp[j][k];
            }
            /* Find Relevant section of Amplitude frequency */
            miphi_tmp = modind_tort(tmpA, tmpP, nbins, nt);
            miout->cm[i*nP + j]=miphi_tmp[0];
            miout->phimi[i*nP +j]=miphi_tmp[1];
            free(miphi_tmp);
        }
    } 

    /* Free unreturned variables */
    free(tmpA);
    free(tmpP);
    
    /* Return structure array */
    return miout;
}



     