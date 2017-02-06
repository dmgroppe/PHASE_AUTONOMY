/* define variables */
struct ABo{
    int **pii;
    double **phis;
    double *phim;
    int *phin;
    int nf;
};

struct mio{
    double *cm;
    double *phimi;
};

/* define functions*/
double *phase(double *Sim, double *Sre, int sizeS);
double *env(double *Sim, double *Sre, int sizeS);
struct ABo *angular_bins(double *phi, int nbins, int n);
double *normalize_distn(double *D, int lengthD);
double d_kl(double *P, double *Q, int lengthP);
double mi_tort(double *P, int lengthP);
double mean4ind(double *arr, int *ind, int sizeind);
double *modind_tort(double *A_fa, double *phi_fp, int nbins, int n);
struct mio *mi_comodulogram_TF(double **A_fa, int nA, double **phi_fp, 
                                     int nP, int nt);