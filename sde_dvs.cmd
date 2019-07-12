
(define Tox      @<1e-3*tox>@)
(define W        @<1e-3*W>@)
(define H        @<1e-3*H>@)
(define Tmg      0.002)
(define L        @<1e-3*L>@)
(define Ld       @<1e-3*Ld>@)




(define xs0      (* -0.5 W))
(define xs1      (*  0.5 W))
(define ys0      (* -0.5 H))
(define ys1      (*  0.5 H))
(define Lso      (* -0.5 L))
(define Ls1      (*  0.5 L))


(define xox0     (- xs0 Tox))
(define xox1     (+ xs1 Tox))
(define yox0     (- ys0 Tox))
(define yox1     (+ ys1 Tox))
(define Ldrain   (+ Ls1 Ld))
(define Lsource  (- Lso Ld))


(define xmg0     (- xox0 Tmg))
(define xmg1     (+ xox1 Tmg))
(define ymg0     (- yox0 Tmg))
(define ymg1     (+ yox1 Tmg))

#if "@Material@" == "SiGe"
(define Mat      "SiliconGermanium")
#else
(define Mat      "@Material@")
#endif

; Overlap behavior (New replaces old)
(sdegeo:set-default-boolean "ABA")

; ===================  Boundary Creation =========================
(sdegeo:set-default-boolean "BAB"); old replaces new


(sdegeo:create-cuboid (position xs0  ys0  Lso) (position xs1  ys1  Ls1) Mat "semi1")
(sdegeo:create-cuboid (position xs0  ys0  Ls1) (position xs1  ys1  Ldrain) Mat "drain")
(sdegeo:create-cuboid (position xs0  ys0  Lso) (position xs1  ys1  Lsource) Mat "source")
(sdegeo:create-cuboid (position xox0  yox0  Lso) (position xox1  yox1  Ls1) "HfO2" "ox")



;(sdegeo:create-cuboid (position xmg0  ymg0  Lso) (position xmg1  ymg1  Ls1) 
; "TiNitride" "MetalGate")
 
; =================== Profile Definitions  =========================
#if "@Type@" == "pMOS"
(sdedr:define-constant-profile "body_profile1" "PhosphorusActiveConcentration" @Nch@ )
#else
(sdedr:define-constant-profile "body_profile1" "BoronActiveConcentration" @Nch@ )
#endif
(sdedr:define-constant-profile "body_profile2" "ArsenicActiveConcentration" @Ndrain@)


; =================== Constant and Analytical Profiles =========================
(sdedr:define-constant-profile-region "b_Place1"   "body_profile1" "semi1" 0.0)
(sdedr:define-constant-profile-region "b_Place2"   "body_profile2" "drain" 0.0)
(sdedr:define-constant-profile-region "b_Place3"   "body_profile2" "source" 0.0)

;------------------- Window Definition ----------------------
(sdegeo:define-contact-set "gate"   4.0 (color:rgb 0.0 1.0 0.0) "**")
(sdegeo:set-current-contact-set "gate")
(sdegeo:define-3d-contact (list (car (find-face-id (position xox1 yox1 Ls1)))) "gate")
(render:rebuild)
(sdegeo:define-3d-contact (list (car (find-face-id (position xox0 yox0 Lso)))) "gate")
(render:rebuild)
(sdegeo:define-3d-contact (list (car (find-face-id (position 0 yox0 Lso)))) "gate")
(render:rebuild)
(sdegeo:define-3d-contact (list (car (find-face-id (position 0 yox1 Ls1)))) "gate")
(render:rebuild)

(sdegeo:define-contact-set "drain1")
(sdegeo:set-current-contact-set "drain1")
(sdegeo:define-3d-contact (list (car (find-face-id (position 0 0 Ldrain)))) "drain1")
(render:rebuild)
(sdegeo:define-contact-set "source1" 4.0 (color:rgb 0.0 1.0 0.0) "||")
(sdegeo:set-current-contact-set "source1")
(sdegeo:define-3d-contact (list (car (find-face-id (position 0 0 Lsource)))) "source1")
(render:rebuild)



;-----------create other regions of oxide--------------------------------------
(sdegeo:create-cuboid (position xox0  yox0  Ls1) (position xox1  yox1  Ldrain) "HfO2" "drainox")
(sdegeo:create-cuboid (position xox0  yox0  Lso) (position xox1  yox1  Lsource) "HfO2" "sourceox")

(sde:showattribs "all")
(sde:save-model "3dnanowire")


;--- Meshing --------------------------------------------------------------------------
(sdedr:define-refinement-window "RefWin.Active" "Cuboid"
 (position xox0  yox0  Ldrain)
 (position xox1  yox1  Lsource))

(sdedr:define-refinement-size "RefDef.Active"
  0.001     0.001     0.0100
  0.001     0.001     0.0100
)
(sdedr:define-refinement-placement "Place.Active"
 "RefDef.Active" "RefWin.Active")



(sdedr:define-refinement-window "RefWin.Active1" "Cuboid"
 (position xs0  ys0  Lso)
 (position xs1  ys1  Ls1))
(sdedr:define-refinement-size "RefDef.Active1"
  0.0010     0.0010    0.0009
  0.0010     0.0010    0.0009
)
(sdedr:define-refinement-placement "Place.Active1"
 "RefDef.Active1" "RefWin.Active1")


 (sdedr:define-refinement-window "RefWin.Active11" "Cuboid"
 (position xox0  yox0  Lso)
 (position xox1  yox1  Lsource))
(sdedr:define-refinement-size "RefDef.Active11"
  0.001     0.001     0.0100
  0.001     0.001     0.0100
  )
(sdedr:define-refinement-placement "Place.Active11"
 "RefDef.Active11" "RefWin.Active11")

 
 (sdedr:define-refinement-window "RefWin.Active22" "Cuboid"
 (position xox0  yox0  Ls1)
 (position xox1  yox1  Ldrain))

(sdedr:define-refinement-size "RefDef.Active22"
  0.001    0.001    0.0100
  0.001    0.001    0.0100
)
(sdedr:define-refinement-placement "Place.Active22"
 "RefDef.Active22" "RefWin.Active22")




(sdeio:save-tdr-bnd (get-body-list) "n@node@_bnd.tdr")

;----------------------------------------------------------------------
; Build Mesh

(sdedr:write-cmd-file "n@node@_msh.cmd")
; (sdedr:write-scaled-cmd-file "n1_msh.cmd" .001)
;----------------------------------------------------------------------
; Build Mesh
(system:command "snmesh n@node@_msh")

