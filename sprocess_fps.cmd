# Create 1D or 2D Fin structure

# Set sprocess material name
set material Undefined
#if [string compare @Material@ SiGe]==0
  set material SiliconGermanium
#elseif [string compare @Material@ InGaAs]==0
  set material InGaAs
#elseif [string compare @Material@ InGaSb]==0
  set material InGaSb
  mater add name=InGaSb new.like=InGaAs
#endif

set gateType Double
set deviceType ThinFilm

# Write out some variables
#set gateType x
#set deviceType x

# Insulator thicknesses in [um]
set Tox      0.0000   
##set Thfo2    0.0014 
##set Thfo2   0.00335

### Insulator thicknesses in [um]
##set Tox      0.002  

#if @Dimension@==1

set basename [lindex [split $argv0 .] 0] ;# filename without extension
pdbSetBoolean Grid MGoals UseLines 1
pdbSet Grid No1DMerge 1

#if [string compare @Type@ nMOS]==0
  set carrierSign 1
#else
  set carrierSign -1
#endif

line x loc=[expr -@Thfo2@]            spac=@Spacing@                    tag=top
line x loc=0.0                                  spac=@InterfaceSpacing@    tag=ox_semi_top
line x loc=[expr  @Wtop@/2]            spac=@Spacing@             tag=semi_semi
line x loc=[expr  @Wtop@]               spac=@InterfaceSpacing@    tag=semi_ox_bot
line x loc=[expr  @Wtop@ + @Thfo2@]   spac=@Spacing@                   tag=bottom

region HfO2            name=hfo2_1                xlo=top         xhi=ox_semi_top
region $material        name=semi1                 xlo=ox_semi_top xhi=semi_ox_bot
region HfO2            name=hfo2_2                xlo=semi_ox_bot xhi=bottom



init

set species DopingConcentration

# Loop over 1D and 2D
foreach dim [list "1D" "2D"] {

  if { [string compare $dim "2D"]==0} {
     set species NetActive
     # Extrude to 2D
     line y loc=0      spacing=1.0
     line y loc=1.0e-4 spacing=1.0
     grid 2D
  }
      
# Doping
select name=$species $material z=-$carrierSign*@Nch@ store     
               
# Contacts. No bottom contact for SG-SOI case
contact name=gate   HfO2  xlo=[expr -(@Thfo2@+$Tox)-5.0e-5] xhi=[expr -(@Thfo2@+$Tox)+5.0e-5]
contact name=gate   bottom add

  if { [string compare $dim "1D"]==0} {
    struct tdr=@tdr@ gas !interfaces !bnd alt.maternames
  } else {
    struct smesh=n@node@_2D.tdr alt.maternames
  }

}; # End of foreach loop over dimension
 
#else

AdvancedCalibration 

mater add name=Al2O3  new.like=oxide 


# Set math section - ParDiso for mechanics and multi-thread simulation
#-math  flow  dim=3 pardiso numThreads=4
math  numThreads=4
# Start with mgoal mode
sde off
#-----------------------------------------------------
# Structure parameters, [um]
set Wt       @Wtop@                 ;# Fin top width
set Wb       @Wbottom@              ;# Fin bottom width
set W        @<0.5*(Wtop+Wbottom)>@ ;# Fin average width
set H        @H@                    ;# Fin height
set Fpitch   0.000                  ;# Fin pitch
set Tsti     0.250

# Doping parameters, [/cm3]
set Nch      @Nch@                  ;# channel doping
#if "@Type@" == "nMOS"
set Dch      "Boron"
set sign 1
#else
set Dch      "Phosphorus"
set sign -1
#endif

#if @<Wbottom == Wtop>@
set Afin    90.0
#else
set Afin    [expr (180.0/3.14159265*atan($H/(0.5*($Wb-$Wt))))]
#endif

#-----------------------------------------------------
# Derived dimensions
set Xmin    0.0
set Xmax    1.0

#-set Ymin    [expr (-0.5*$Fpitch)]
set Ymin    0.0
set Ymax    [expr ( 0.5*$Fpitch)]

set FY0     [expr (-0.5*$Wt)]
set FY1     [expr ( 0.5*$Wt)]

set FbY0     [expr (-0.5*$Wb)]
set FbY1     [expr ( 0.5*$Wb)]

#-----------------------------------------------------

#---------------------------------------------------------------------#
#   SIMULATION CONTROLL
set debug         0
set DoDiff        1
set Type          @Type@


#---------------------------------------------------------------------#
#   USER-DEFINED PROCEDURES

proc WriteBND {} {
        global count

        if { $count < 10} {
           struct bndfile=n@node@_0${count}
        } else {
           struct bndfile=n@node@_${count}
        }
        set count [expr $count+1]
}
set count 1

# 
#---------------------------------------------------------------------#

SetTDRList   {Dopants} !Solutions

line x loc=$Xmin     tag=SiTop          spacing=0.01
line x loc=$Xmax     tag=SiBottom       spacing=0.01

line y loc=$Ymin   tag=Left     spacing=0.01
line y loc=$Ymax   tag=Right    spacing=0.01

region $material  xlo=SiTop  xhi=SiBottom  ylo=Left  yhi=Right

init concentration=1.0e15 field=Boron wafer.orient=100 !DelayFullD

etch $material anisotropic thickness=$Tsti 
##-deposit Oxide   coord=$H  type=fill region.name=BOX
deposit $material coord=0.0 type=fill region.name=SiFin

mask name=fin_mask left=$FY0 right=$FY1 negative
photo mask=fin_mask thickness=0.010
etch    $material type=trapezoidal  angle=$Afin  thickness=1*$Tsti
strip Photoresist
etch    $material type=isotropic  thickness=0.001
deposit $material type=isotropic  thickness=0.001
if { $debug } { WriteBND }

##-- Define the channel stop region and the channel region for the convenience  -##
polygon name=sti xy rectangle min= { $H+0.001 $Ymin } max= { $Tsti $Ymax }
polygon list
insert polygon=sti replace.materials= " $material Gas " new.material=Oxide
polygon    clear
if { $debug } { WriteBND }

#sel $material  z=NetActive   name=-1*$Dch   store
#diffuse temp=600 time=1.0e-6<s> !stress.relax


deposit material=HfO2 thickness=@Thfo2@ type=isotropic
deposit Tungsten coord=-0.050 type=fill region.name=MetalGate


# Explicit Doping
select region=${material}_1.1 name=NetActive z=-1.0e15      store
select region=${material}_1.2 name=NetActive z=-$sign*@Nch@ store

# Change name of  regions
region point= { $H/2           0.0} new.name=semi1; # Fin region
region point= { $Xmax-1.0e-3   0.0} new.name=semi2; # Substrate region
region point= { -@Thfo2@/2 0.0}      new.name=hfo2;  # HfO2 region
## region point= { -$Tox/2        0.0} new.name=ox;    # Oxide region


#----- Contact for sdevice simulation -----
contact bottom name=substrate $material
contact point replace region=MetalGate  name=gate
if { $debug } { WriteBND }

# refinement at interfaces
mgoals min.normal.size=0.1 max.box.angle=165 normal.growth.ratio=2 accuracy=1e-6 minedge=1.0e-5
refinebox interface.materials= " $material Polysilicon Oxide Nitride Oxynitride"
refinebox min= { -1*@Thfo2@ $FbY0-2*@Thfo2@ } max= { $H+2*@Thfo2@ $FbY1+2*@Thfo2@ } \
          xrefine= @Spacing@ yrefine=  @Spacing@
          
# orig: min.normal.size=1.1e-4
refinebox name= Channel\
   min= { -1*@Thfo2@ $FbY0-2*@Thfo2@ } \
   max= { $H+2*@Thfo2@ $FbY1+2*@Thfo2@ } \
   min.normal.size= @InterfaceSpacing@ normal.growth.ratio= 1.1 \
   interface.mat.pairs= " $material Oxide" all add
   
refinebox name= Substrate\
   min= { $H+2*@Thfo2@ -1 } \
   max= { $Xmax      1 } \
   min.normal.size= 1e-3 normal.growth.ratio= 1.5 \
   interface.mat.pairs= " $material Oxide" all add
          
grid remesh

transform reflect left


#----- Save TDR file -----
struct tdr=n@node@ !gas !interfaces !bnd alt.maternames
struct tdr=n@node1@ !gas !interfaces !bnd alt.maternames

exit


#endif
