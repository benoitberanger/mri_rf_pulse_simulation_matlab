---
title: 'MRI RF pulse simulation in MALTAB'
tags:
    - MRI
    - RF pulse
    - simulation
    - MATLAB
    - GUI
authors:
    - name: Benoît Béranger
      orcid: 0000-0003-0704-9854
      corresponding: true
      affiliation: 1
    - name: Julien Lamy
      affiliation: 2
    - name: Laura Mouton
      affiliation: 1
    - name: Marc Lapert
      affiliation: 3
affiliations:
 - name: Centre de NeuroImagerie de Recherche - CENIR, Institut du Cerveau - ICM, Paris, France
   index: 1
 - name: Laboratoire ICube, Université de Strasbourg-CNRS, Strasbourg, France
   index: 2
 - name: Siemens Healthcare SAS, Courbevoie, France
   index: 3
date: 11 August 2024
---

# Summary
**M**agnetic **R**esonance **I**maging (MRI) is a non-invasive non-ionisong technique mainly used to acquire images of the human body. To do so, $MRI$ uses **R**adio**F**requency (RF) pulses to excite matter, and magnetic gradients to encode the image. This toolbox focuses on the simulation and evaluation of such RF pulses.

Why ? Because here is a **lot** of them ! Some pulses are designed to selectivly excite a specific volume, like a thin slice of matter, while other are called "non-selective" and will excite the whole volume in the scanner.  
Why are they so different from each other ? How to compare them ? Which one to choose ? The [main objective]{.ul} of this toolbox is to answer these questions, using a GUI or pragramaticaly, or both.

# Statement of need
An RF pulse is _complex_ curve. It can be associated with a magnetic gradient curve which is _real_. Modern MRI scanners do use this complex RF curve : you provide the _magnitude_ and the _phase_ of the pulse. To simulate the pulse response, we can solve the Bloch equations [REF] that describe the evolution of a magnitisation vector under a magnetic field. Depending on different starting conditions, we can evaluate, for exampple, the slice profile of a slice-selective RF pulse.

## Interactivity
Open the GUI and click on a pulse in the library list. The pulse is loaded with default parameters, which are displayed and editable, and it's curves are plotted. By default, the simulation is triggered, and the results plotted :
![FOCI](../docs/gui_FOCI.png)
Changing a parameter such as the pulse duration, in the GUI or programaticaly, will update the pulse curves, and simulation updated with the ne resultats plotted.

# Citations
A list of key references, including to other software addressing related needs. Note that the references should include full names of venues, e.g., journals and conferences, not abbreviations only understood in the context of a specific discipline.

# Acknowledgements
We acknowledge contributions from [...] during the genesis of this project.

# References