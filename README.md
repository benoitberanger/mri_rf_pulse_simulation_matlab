# MRI $RF$ pulse simulation in MALTAB

This repository is a Matlab application that simulate the response of MRI **R**adio**F**requency (**RF**) pulses.
The app is a GUI, and the code also made to be used purely programatically.

1. Open the GUI app
2. Click on a pulse in the library list.
3. The selected $RF$ pulse is loaded with default paramters, plotted in the GUI, and it's simulation triggered.
4. The simulation is plotted : magnetization vector across time $M_{xzy}(t)$, slice profile $\Delta Z$, chemical shift profile $\Delta B_0$.

The application is completly object oriented programming, to take advandtage of heritage. See the API section.

Also, you can use your own pulses in the app by :
- a super fast method : filling the $RF$ pulse shape ($B1$ curve $GZ$ curve). !! TODO !!
- an ergonomic method made for interativity : add your own $RF$ pulse objects so it will appear in the library. !! TODO !!

## Download and install
1. Clone the repository with 
    - `git clone --recurse-submodules https://github.com/benoitberanger/mri_rf_pulse_simulation_matlab.git`
2. In Matlab, `cd /path/to/mri_rf_pulse_simulation_matlab`
3. Start the app with `mri_rf_pulse_sim.app()`

## Features
### GUI
The GUI have 3 independant panels :
- **Pulse definition** : It shows the library of pulses, and the selected pulse, including its shape and the UI parameters.
- **Simulation parameters** : You define the range and granularity (number of points) for the slice profile evaluation $\Delta Z$ and the chemical shift $\Delta B_0$ evaluation.
- **Simulation results** : Displays $M_{xzy}(t)$, the slice profile $\Delta Z$, and the chemical shift $\Delta B_0$ profile.

### Scripting
Here is some exemples of non-GUI analysis :  
- [evaluate_adiabaticity_hs](+mri_rf_pulse_sim/+analysis/evaluate_adiabaticity_hs.m)
- [compare_hs_foci](+mri_rf_pulse_sim/+analysis/compare_hs_foci.m)


### API for user defined pulses
TODO


# Limitations
- MATLAB R2023a+ ? maybe few realease earlier, but I did not test them.


## TODO list
https://github.com/users/benoitberanger/projects/2


# Examples
TODO


# External dependency ?

**None**, except for : 
- For SLR pulses : 
    - DSP System Toolbox
    - Signal Processing Toolbox


# Tested on
MATLAB R2023a+


# Alternatives
In all alternatives that I found, in Python, Malab, Julia, none has the same interactivty and ergonomy.

## Python
https://github.com/mikgroup/sigpy

## Matlab
https://github.com/leoliuf/MRiLab

## Julia
https://github.com/cncastillo/KomaMRI.jl
