 

#include "PMIModels.h"
#include <cmath>
#include <iostream>
 

class pmi_hfmobility2 : public PMI_HighFieldMobility2 {

public:

    pmi_hfmobility2(const PMI_Environment& env,

               int idx,

               const std::string& ms,

               const PMI_AnisotropyType aniso)

     : PMI_HighFieldMobility2(env, idx, ms, aniso),

    fac(0.5)

    {

    }

 

    void compute(const idata* in, odata* out)

    {
     const double K = 8.6173324e-5;
     const double m0 =  5.6778e-16; //eV/cm^2/s^2
     const double meff = 0.0571;
     const double q = 1.602e-19;
     const double T = 300;
     const double delta =1000;//10;//1500
     
     const double gradscalar = ReadScalar("eGradQuasiFermi");
     
     double eGQF[3];
     ReadVector("eGradQuasiFermi",eGQF);
     const double Enorm =ReadScalar("eEnormal");
     const double eQF = ReadScalar ("eQuasiFermiPotential");
     const double n_now= in->n();
     const double number=(n_now)*1e-12;

     //const double vtob=ReadScalar("eCurrentDensity-X");
     const double phi=ReadScalar("ElectrostaticPotential");     
     const double eQFdensity=phi-(K*T)*log(number);

     const double md=ReadScalar("eMobility");

     const double term =(K*T)*log(number);
     const double negterm = -term;
     const double cb=ReadScalar("ConductionBandEnergy");
     const double qpot= ReadScalar("eQuantumPotential");
     const double effbarrier=cb-qpot;
     const double densityenergy= effbarrier+term;

     const double qf = in->gradQF();

     const double ef = in->Epar();
  
     const double prod =in->EprodQF();

     const double mulow = in->mulow();     
     const double pi=M_PI;
     const double v02 =sqrt((2*K*T)*(1/(pi*m0*meff)));
     
  
     const float vk = v02*(sqrt(pow(tanh(1/(2*K*T)), 2) + 2*eQF*(1/(K*T))));//v02*sqrt(pow(tanh(eQF/2*K*T), 2) + 2*eQF/K*T); 
     const double force = qf+delta;    
     const float mumodel=vk/force;
     const float mu2=(mulow*mumodel)/(mumodel+mulow);
     //const float mu =vk/qf;
 


    if (mu2<=1)
    {out-> val()=1;}
    else{
    out-> val()= mu2;}




   
    out->dval_dgradQF()=-((pow(mulow,2))*vk)/(pow((vk+mulow*force),2));// -vk/force)*(1/n_now);
    out->dval_dmulow()=-(pow(mumodel,2)/(pow((mumodel+mulow),2)));

    WriteUserField (PMI_UserField0, qf);
    WriteUserField (PMI_UserField1, force);
    WriteUserField (PMI_UserField2, vk);
    WriteUserField (PMI_UserField3, mu2);
    WriteUserField (PMI_UserField4, vk);
    WriteUserField (PMI_UserField5, eQFdensity);
    WriteUserField (PMI_UserField6, eGQF[0]);
    WriteUserField (PMI_UserField7, eGQF[1]);
    WriteUserField (PMI_UserField8, eGQF[2]);
    WriteUserField (PMI_UserField9, ef);
    WriteUserField (PMI_UserField10, prod);
    WriteUserField (PMI_UserField11, mulow);
   }

private:

    const double fac;

};

 

extern "C"

PMI_HighFieldMobility2* new_PMI_HighFieldMobility2(

     const PMI_Environment& env,

     int model_index,

     const std::string& model_string,

     const PMI_AnisotropyType aniso)

{

    return new pmi_hfmobility2(env, model_index, model_string, aniso);

}

 
