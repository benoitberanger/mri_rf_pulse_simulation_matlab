# MRI RF pulse simulation in MALTAB

This repository is a Matlab application that simulate the response of MRI **R**adio**F**requency (**RF**) pulses.
The app is a GUI, and the code also made to be used purely programatically.

1. Open the GUI app
2. Click on a pulse in the library list.
3. The selected RF pulse is loaded with default paramters, plotted in a GUI, and it's simulation triggered.
4. The simulation is plotted : magnetization vector across time, slice profile, delta B0 profile.

The application is completly object oriented programming, to take advandtage of heritage. See the API section.

Also, you can use your own pulses in the app by :
- a super fast method : filling the RF pulse shape (B1 curve GZ curve).
- an ergonomic method made for interativity : add your own RF pulse objects so it will appear in the library.

## Download and install
1. Clone the repository with 
    - `git clone --recurse-submodules https://github.com/benoitberanger/mri_rf_pulse_simulation_matlab.git`
2. In Matlab, `cd /path/to/mri_rf_pulse_simulation_matlab`
3. Start the app with `mri_rf_pulse_sim.app()`

## Features
### GUI
The GUI have 3 independant panels :
- **Pulse definition** : It shows the library of pulses, and the selected pulse, including its shape and the UI parameters.
- **Simulation parameters** : You define the range and granularity (number of points) for the slice profile and the $\Delta$ B0.
- **Simulation results** : Displays $M_{xzy}(t)$, the slice profile, and the $\Delta$ B0 profile.

### Scripting
Works, but need a few useful exemple.

### API for user defined pulses
TODO


# Limitations
- MATLAB R2023a+


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
In all alternatives that I found, in Python or Malab, none posses the same interactivty and ergonomy.

## Python
https://github.com/mikgroup/sigpy

## Matlab
https://github.com/leoliuf/MRiLab
