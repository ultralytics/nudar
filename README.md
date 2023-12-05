<img src="https://storage.googleapis.com/ultralytics/UltralyticsLogoName1000×676.png" width="200">

# 🌟 Introduction

Welcome to the official repository for the `nudar` project by Ultralytics! This repository is your gateway to exploring earth modeling and neutrino detector simulations. Here you'll find all the code and information needed to jump-start your journey into the fascinating world of antineutrino detection research.

# 📜 Description

The `nudar` repository is dedicated to providing a state-of-the-art software suite for earth modeling and simulations pertaining to neutrino detection. Our software is grounded in the rigorous research presented by G. Jocher et al. in their significant work, "Theoretical Antineutrino Detection, Direction, and Ranging at Long Distances," which has been a cornerstone contribution to the field. For further reading and to understand the underpinnings of our models, please refer to their study in Physics Reports (Volume 527, Issue 3, 2013). The full paper can be accessed at [this link](http://dx.doi.org/10.1016/j.physrep.2013.01.005).

The visualization below provides a glimpse into the kind of mapping and simulation work that we do at Ultralytics:

![Earth Modeling Visualization](https://github.com/ultralytics/agm2015/blob/master/AGM2015small.jpg "AGM2015")

# 📦 Requirements

To use the tools provided in this repository, you will need to have [MATLAB](https://www.mathworks.com/products/matlab.html) version 2018a or newer. We also utilize a common functions repository to streamline our processes. To set up your environment correctly, you will need to perform the following steps:

1. Clone our `functions-matlab` repository:
   ```shell
   git clone https://github.com/ultralytics/functions-matlab
   ```
2. Add the repository to your MATLAB path:
   ```matlab
   addpath(genpath('/functions-matlab'))
   ```
   ⚠️ Ensure that you replace `/functions-matlab` with the actual path to the cloned repository on your system.

In addition, you will require the following MATLAB toolboxes pre-installed:
- `Statistics and Machine Learning Toolbox`: This toolbox is essential for performing the advanced statistical calculations and machine learning algorithms used in our simulations.
- `Signal Processing Toolbox`: Signal analysis is a crucial aspect of neutrino detection, and this toolbox provides necessary functionalities.
- `Mapping Toolbox`: Creating accurate earth models involves complex mapping procedures, and the Mapping Toolbox is used extensively for these tasks.

# 🚀 Running the Simulation

Getting the simulation up and running is as straightforward as launching MATLAB and executing the following command:
```matlab
iDND
```
Make sure the working directory is set to the root of the cloned `nudar` repository before you run the command.

# ℹ️ License

All code and software provided in this repository are available under the AGPL-3.0 license. For more details, please visit the [LICENSE](https://github.com/ultralytics/nudar/blob/master/LICENSE) file contained within this repository.

# 🤝 Contact

For additional information, support, or inquiries, kindly visit our contact page at [Ultralytics Contact Info](http://www.ultralytics.com/contact). Please note that we welcome any constructive feedback or contributions to improve the project, but we do not provide direct email contact through the README to maintain privacy and security. 

Enjoy modeling and discovering the unseen world of antineutrinos with `nudar`! 🌎⚛️
