# BallisticMobility

This repository has all the Physical Model Interfaces used for simulating ballistic mobility in S-Device.

The fist parth of the code is written in Tcl. Tcl  (pronounced "tickle" or as an initialism) is a high-level, general-purpose, interpreted, dynamic programming language. It was designed with the goal of being very simple but powerful. Tcl casts everything into the mold of a command, even programming constructs like variable assignment and procedure definition. Tcl supports multiple programming paradigms, including object-oriented, imperative and functional programming or procedural styles.

It is commonly used embedded into C applications, for rapid prototyping, scripted applications, GUIs, and testing. Tcl interpreters are available for many operating systems, allowing Tcl code to run on a wide variety of systems. Because Tcl is a very compact language, it is used on embedded systems platforms, both in its full form and in several other small-footprint versions.

The popular combination of Tcl with the Tk extension is referred to as Tcl/Tk, and enables building a graphical user interface.
(GUI) natively in Tcl. Tcl/Tk is included in the standard Python installation in the form of Tkinter. 

THE ORGANIZATION OF THE CODE:

1. sde_dvs.cmd -> Tcl code for building a Double Gate Ultra Thin Fet
2. sdevice.par -> Tcl code for defining physical files for the simuation of the models.
3. sdevice_des.cmd -> Tcl code for defining the physics of the each region and material of the device.
4. pmi_HighFieldMoblity2densityQF.C -> Object Oriented C++ code for using predifined classes from the simulator to prototype          new models inside the framework. The model is based on the electron concentration at each point of the channel.
5. pmi_HighFieldMobility2mattQF.C-> Object Oriented C++ code for using predifined classes from the simulator to prototype          new models inside the framework. The model is based in the Fermi Energies of each vertex.

Please read the Wiki for a better explanation.


