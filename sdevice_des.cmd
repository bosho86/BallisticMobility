

        #if @<"@MobilityModel@" == "BallisticmattQF">@
     #define _MOVMODEL_  HighFieldSaturation(
    #define _PMI_      PMIModel(
     #define _NAME_   Name="pmi_HighFieldMobility2mattQF"
     #define _INDEX_  Index="1"
     #define _STRING_ String= "n"))
 
     
     

   #endif


        #if @<"@MobilityModel@" == "ConstantMobility">@
     #define _MOVMODEL_  ConstantMobility
     

   #endif



      #if @<"@Tunneling@" == "NLTMV">@

     #define _P2_  eBarrierTunneling "NLM2" (MultiValley)

   
     #define _M2_  Nonlocal "NLM2" (
     #define _M22_ RegionInterface="semi1/drain"
     #define _M222_ Length=25e-7
     #define _M2222_ Permeation=5e-7	)
     
   #else


     #define _P22_  

     #define _M2_ 
     #define _M22_ 
     #define _M222_
     #define _M2222_ 

   #endif



   
   
   
      #if @<"@FloatingBody@" == "BTB">@
      #define _L1_ Recombination  ( SRH(DopingDep) Band2Band ( Model=NonlocalPath ) ) 
        
   #else

      #define _L1_
      
   #endif
   




File {
  * Input Files
  Grid      = "n@node|sde@_msh.tdr" 
  plot = "n@Vds@_@L@_@FloatingBody@_@Workfu@_@MobilityModel@_@alpha@_@ucontact@_@uchannel@_@Tunneling@_@V0@_DOS_des.tdr"
  current = "n@Vds@_@L@_@FloatingBody@_@Workfu@_@MobilityModel@_@alpha@_@ucontact@_@uchannel@_@Tunneling@_@V0@_DOS_des.plt"     
  Output  = "n@node@"
  param = "@parameter@"
    PMIPath="pmi"
}

plot {SRH eSRHRecombination hSRHRecombination tSRHRecombination eTrappedCharge  Auger
  eVelocity/Vector eCurrent/Vector hCurrent/Vector ElectricField/Vector
  eDensity hdensity potential
  DopingConcentration eQuasiFermi hQuasiFermi
  eMobility hMobility
  ConductionBandEdge ValenceBandEdge
  eBand2BandGeneration hBand2BandGeneration Band2Band
  eQuantumPotential
  eBarrierTunneling hBarrierTunneling NonLocal
}


Electrode {
  { Name="source1"     Voltage=0.0 }
  { Name="drain1"      Voltage=0.0 }
  { Name="gate"        Voltage=@V0@ workfunction=@Workfu@}

}

Physics{

Fermi

EffectiveIntrinsicDensity( NoBandGapNarrowing )  

   #if @<"@FloatingBody@" == "BTB">@
   _L1_ 
        
   #else
      
   #endif


#if @<"@Tunneling@" == "NLTMV">@
_P2_   
#else
_P22_ 
#endif 
#if "@Quantization@"=="DG"

     eQuantumPotential(Density)



     
#elif "@Quantization@"=="DGA"


  eQuantumPotential(AutoOrientation) 
Aniso(eQuantumPotential(
AnisoAxes(SimulationSystem)={
(1,0,0)
(0,1,0)
}
))

 
#elif "@Quantization@"=="NONE"

#endif
        
}

Physics (Material="InGaAs"){
	MoleFraction(
	       xFraction=0.47
		)
Fermi
eQuasiFermi=0



}


Physics (region="drain"){
Mobility(ConstantMobility)

eMultiValley(Nonparabolicity )

}

Physics (region="source"){

Mobility(ConstantMobility)
eMultiValley(Nonparabolicity)


 
}

Physics(Region=semi1){

eMultiValley(Nonparabolicity)
  


#if @<"@MobilityModel@" == "BallisticmattQF">@
    eMobility( 
     _MOVMODEL_  
     _PMI_   
      _NAME_  
      _INDEX_ 
      _STRING_ 

   )
   
#endif


 #if @<"@MobilityModel@" == "ConstantMobility">@
     eMobility(
    _MOVMODEL_ )
     #endif
}



Math {
   
    LineSearchDamping=0.001
    Number_of_Threads=4
    
    
    *Tunneling
  #if @<"@Tunneling@" == "NLTMV">@ 
     _M2_ 
    _M22_ 
    _M222_
     _M2222_
 
  #else
  #endif   

}    



 #if @<"@Quantization@" == "DGA" >@

solve { 
  coupled { Poisson}
 coupled {Poisson eQuantumPotential electron hole}
  Quasistationary(
      InitialStep=0.001 MinStep=1e-5 Maxstep=0.01
	            Increment=1.3 
      #Plot { Range=(0,1) Intervals=1}
      Goal { Name="drain1" Voltage=@Vds@} #!!!
  ){ 
      coupled{poisson eQuantumPotential electron hole}
       
  } 

  Quasistationary(
      InitialStep=0.005 MinStep=1e-5 MaxStep=0.01
	            Increment=1.3 

      Plot { Range=(0,1) Intervals=14}
 #     AcceptNewtonParameter (ReferenceStep = 5.0e-4)
      Goal { Name="gate" Voltage=@VG_END@}
      
  ){ 
      coupled{poisson eQuantumPotential electron hole}
 
  }  
 
}


#else


solve { 
  coupled { Poisson}
 coupled {Poisson electron hole}
  Quasistationary(
      InitialStep=0.001 MinStep=1e-5 Maxstep=0.01
	            Increment=1.3 
      #Plot { Range=(0,1) Intervals=1}
      Goal { Name="drain1" Voltage=@Vds@} #!!!
  ){ 
      coupled{poisson electron hole}
       
  } 

  Quasistationary(
      InitialStep=0.005 MinStep=1e-5 MaxStep=0.01
	            Increment=1.3 

      Plot { Range=(0,1) Intervals=14}
 #     AcceptNewtonParameter (ReferenceStep = 5.0e-4)
      Goal { Name="gate" Voltage=@VG_END@}
      
  ){ 
      coupled{poisson electron hole}
 
  }  
 
}
#endif
