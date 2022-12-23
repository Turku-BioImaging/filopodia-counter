# Filopodia-counter

Filopodia counter is a script for automated filopodia counting from single cell images. It expects a multichannel image (2-4 channels). The cell needs to be stainded at least with two markers, one that indicates filopodia tips and another that defines the cell area. 

<img src="images/Figure1-example_cell.png" alt="drawing" width="300"/>

**Figure 1:** Example image for filopodia counter. In the image the cell body had been detected using an actin dye (white) and the every filopodia tip has been detected by staining myosin 10 (magenta).

## Dependences

Filopodia counter in dependent on Fiji-plugins MorpholibJ and BioFormats. Please subscribe to these using through the Fiji updater. 

## Usage

<img src="images/Figure2-UI.png" alt="drawing" width="500"/>

**Figure 2:** User interface of the Filopodia counter

1. Download the Filopodia counter from this repository (see log for the current version) and drag of drop it to Fiji.
2. Add files to be corrected. You can cound filopodia in just one image or add multiple images. All these images will be processed with teh same parameters.
3. Select the channel with the filopodia stain (options C1, C2, C3, C4).
4. Select the channel with the cell body stain (options C1, C2, C3, C4).
5. Select the path to results folder.
6. Select promiance (= signal relative to the local background). Higher prominance detects less filopodia tips.
7. Click *OK*

The script will output
- .cvs table containing the name of each processed file
- Quality control image of each processed image

<img src="images/Figure3-QC-cell.png" alt="drawing" width="600"/>

**Figure 3:**  Filopodia counter saves a QC image of each quatified cell. This image has each counted filopodia circled in yellow.

## Log

Current version: *Filopodia-counter-v4*
