 

#include "PMIModels.h"
#include <cmath>

 

class pmi_hfmobility2 : public PMI_HighFieldMobility2 {

private:

    const double fac;
    static double cb_edge_tob0;
    static double eDensity_tob0;
    static double mu_tob0;
    static double psi_tob0;
    static double efield_tob0;
    double timeLast;


public:

    pmi_hfmobility2(const PMI_Environment& env,

               int idx,

               const std::string& ms,

               const PMI_AnisotropyType aniso)

     : PMI_HighFieldMobility2(env, idx, ms, aniso),

    fac(0.5)


    {
    timeLast = 0;
    }



    void compute(const idata* in, odata* out)

    {
     const double K = 8.6173324e-5;
     const double m0 =  5.6778e-16; //eV/cm^2/s^2
     const double meff = 0.0516;
     const double q = 1.602e-19;
     const double T = 300;
     const double delta =2000;//1500
     
     
     const double ef = in->gradQF();
     const double n_now= in->n();
          
     const double efield=ReadScalar("ElectricField");
     const double md=ReadScalar("eMobility");
     const double psi =ReadScalar("eQuasiFermiPotential");
     const double mulow = in->mulow();     
     const double v02 =sqrt((K*T)*(1/(m0*meff)));
     const double cb_edge_now=ReadScalar("ConductionBandEnergy");
     const double timeNow = ReadTime();
     
   

     if (abs(timeNow - timeLast) > 1e-10) {
	cb_edge_tob0 = -1e10;
	timeLast = timeNow;
    }
     if (cb_edge_tob0 < cb_edge_now){
    	cb_edge_tob0 = cb_edge_now;
	eDensity_tob0 = n_now;
        psi_tob0= psi;
        mu_tob0= md;
        efield_tob0=efield;
     }
   

     const double term1=eDensity_tob0/n_now;
     const double vo = v02*(tanh(0.05/(2*K*T)))*eDensity_tob0;
     const float vk = v02*(tanh(0.05/(2*K*T)))*term1;//*(fabs(nsource/n_now)); 
     
     const double force = ef+delta;     
     const double vtob= ((mu_tob0)/force)*100;
     const float vk2=vtob*term1;
     const float mumodel=vk2/force;
     const float mu2 =(mulow*mumodel)/(mumodel+mulow);
 
            
 
    if (mu2<=0)
    {out-> val()=1;}
    else{
    
    out-> val()= mu2;}



    out->dval_dn()=-(vo*force*(pow(mulow,2)))/(pow((vo+mulow*force*n_now),2));
    out->dval_dgradQF()=-((pow(mulow,2))*vk)/(pow((vk+mulow*force),2));
    out->dval_dmulow()=-(pow(mumodel,2)/(pow((mumodel+mulow),2)));
    
    WriteUserField (PMI_UserField0, cb_edge_tob0);
    WriteUserField (PMI_UserField1, eDensity_tob0);
    WriteUserField (PMI_UserField2, timeNow);
    WriteUserField (PMI_UserField3, mu_tob0);
    WriteUserField (PMI_UserField4, vk);
    WriteUserField (PMI_UserField5, vtob);
   // WriteUserField (PMI_UserField6, vk1);
   }



};

//initializing the doubles variables
double pmi_hfmobility2::cb_edge_tob0=-1e10;
double pmi_hfmobility2::eDensity_tob0=1e10;
double pmi_hfmobility2::psi_tob0=0.001;
double pmi_hfmobility2::mu_tob0=1e10;
double pmi_hfmobility2::efield_tob0=0.001;
extern "C"

PMI_HighFieldMobility2* new_PMI_HighFieldMobility2(

     const PMI_Environment& env,

     int model_index,

     const std::string& model_string,

     const PMI_AnisotropyType aniso)

{

    return new pmi_hfmobility2(env, model_index, model_string, aniso);

}

 
