# MRI $RF$ pulse simulation in MALTAB

This repository is a MATLAB application that simulate the response of MRI **R**adio**F**requency (**RF**) pulses.
The app is a GUI, and the code also made to be used purely programmatically.

1. Open the GUI app
2. Click on a pulse in the library list.
3. The selected $RF$ pulse is loaded with default parameters, plotted in the GUI, and it's simulation triggered. The simulation is plotted automatically : magnetization vector across time $M_{xzy}(t)$, slice profile $\Delta Z$, chemical shift profile $\Delta B_0$.

The application is completely object oriented, to take advandtage of heritage and composition of several abstract classes.

Also, you can use your own pulses in the app by :
- a super fast method : fill the $RF$ pulse shape ($B1$ curve $GZ$ curve) in the the `USER_DEFINED` pulse. This is "empty" pulse, used as placeholder in the app.
- !! TODO !! : an ergonomic method made for interativity : add your own $RF$ pulse objects so it will appear in the library.


## Features
### GUI
The GUI have 3 independent panels :
- **Pulse definition** : It shows the library of pulses, and the selected pulse, including its shape and the UI parameters.
![Pulse definition](docs/gui_pulse_definition.jpeg)
- **Simulation parameters** : You define the range and granularity (number of points) for the slice profile evaluation $\Delta Z$ and the chemical shift $\Delta B_0$ evaluation.
![Simulation parmeters](docs/gui_simulation_parameters.jpeg)
- **Simulation results** : Displays $M_{xzy}(t)$, the slice profile $\Delta Z$, and the chemical shift $\Delta B_0$ profile.
![Simulation results](docs/gui_simulation_results.jpeg)

### Scripting
Here is some examples of non-GUI analysis :  
- [Why SINC is used for slice selection instead of to RECT ?](+mri_rf_pulse_sim/+analysis/rect_vs_sinc.m)
- [Too much B1max ? RF clip ? maybe increase pulse duration](+mri_rf_pulse_sim/+analysis/rf_clip.m)
- [FOCI is derivezd from HS pulse. But is it better ?](+mri_rf_pulse_sim/+analysis/compare_hs_foci.m)
- [Why do we need a slice selection gradient **rewinder** ?](+mri_rf_pulse_sim/+analysis/slice_selection_rewinder_lob.m)

### Object oriented programming
All pulses are objects.  
Pulses can inherit from others : `FOCI` is derived from `HyperbolicSecant`.  
Pulses can be composed of several abstract classes.
For example, `slr_mb_verse` is a **SLR** base waveform, then the **M**ulti**B**and algorithm is applied to excite several slices, and finnally the **VERSE** algorithm reduces it's duration and $B1_{max}$ using constrains.


### Re-usability
One of the objectives here is to centralize the equations/algorithms of $RF$ pulse so they can be almost copy-pasted in other programming environments, like a complete sequence simulator, or a sequence development environment from your manufacturer.  
One difficulty when looking in the literature is that different sources can have different vocabulary or different parameters. A typical example is the **H**yperbolic**S**ecant, which is the extremely well described, but with a large variety of implementation using different input parameters.


## Examples
TODO


## TODO list
https://github.com/users/benoitberanger/projects/2


## Download and install
1. Clone the repository with 
    - `git clone --recurse-submodules https://github.com/benoitberanger/mri_rf_pulse_simulation_matlab.git`
2. In Matlab, `cd /path/to/mri_rf_pulse_simulation_matlab`
3. Start the app with `mri_rf_pulse_sim.app()`


## Limitations
- MATLAB R2023a+ ? maybe few release earlier, but I did not test them.


## External dependency

**None**, except for : 
- For SLR pulses : 
    - DSP System Toolbox
    - Signal Processing Toolbox


## Tested on
MATLAB R2023a+


## Alternatives
In all alternatives that I found, in Python, Malab, Julia, none has the same interactivty and ergonomy.

- Python : https://github.com/mikgroup/sigpy
- Matlab : https://github.com/leoliuf/MRiLab
- Julia : https://github.com/cncastillo/KomaMRI.jl
