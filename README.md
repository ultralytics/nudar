<a href="https://www.ultralytics.com/"><img src="https://raw.githubusercontent.com/ultralytics/assets/main/logo/Ultralytics_Logotype_Original.svg" width="320" alt="Ultralytics logo"></a>

[![Ultralytics Actions](https://github.com/ultralytics/nudar/actions/workflows/format.yml/badge.svg)](https://github.com/ultralytics/nudar/actions/workflows/format.yml)
[![Ultralytics Discord](https://img.shields.io/discord/1089800235347353640?logo=discord&logoColor=white&label=Discord&color=blue)](https://discord.com/invite/ultralytics)
[![Ultralytics Forums](https://img.shields.io/discourse/users?server=https%3A%2F%2Fcommunity.ultralytics.com&logo=discourse&label=Forums&color=blue)](https://community.ultralytics.com/)
[![Ultralytics Reddit](https://img.shields.io/reddit/subreddit-subscribers/ultralytics?style=flat&logo=reddit&logoColor=white&label=Reddit&color=blue)](https://reddit.com/r/ultralytics)

## 🌟 Introduction

Welcome to the NUDAR (Nuclear Detection, Ranging, and Mapping) repository by [Ultralytics](https://www.ultralytics.com/)! This project offers sophisticated simulation tools crafted for modeling the Earth's structure and simulating [neutrino](https://en.wikipedia.org/wiki/Neutrino) detector systems. Grounded in scientific research, our tools cater to both the academic community and applied sciences within [geophysics](https://en.wikipedia.org/wiki/Geophysics) and [particle physics](https://home.cern/science/physics/particle-physics). Explore the fascinating intersection of earth modeling and neutrino detection with NUDAR! 🌍✨

## 📜 Description

NUDAR provides a comprehensive suite of [MATLAB](https://www.mathworks.com/products/matlab.html) simulations designed to advance the theoretical study of [antineutrino](https://en.wikipedia.org/wiki/Antineutrino) interactions and detection. This software is instrumental in deepening our understanding of antineutrino properties and their potential applications, such as probing the [Earth's interior](https://education.nationalgeographic.org/resource/encyclopedia/earths-interior/) and enhancing nuclear detection capabilities.

Our development is inspired by the foundational paper by G. Jocher et al., "Theoretical Antineutrino Detection, Direction and Ranging at Long Distances," published in [Physics Reports](https://www.sciencedirect.com/journal/physics-reports) (Volume 527, Issue 3, 2013). For an in-depth look at the scientific principles underpinning these simulations, please consult the publication via its DOI: [http://dx.doi.org/10.1016/j.physrep.2013.01.005](http://dx.doi.org/10.1016/j.physrep.2013.01.005). You can find more insights into related fields on the [Ultralytics Blog](https://www.ultralytics.com/blog).

![Earth Modeling and Neutrino Detection Simulation](https://github.com/ultralytics/agm2015/blob/main/AGM2015small.jpg)

## 🧰 Requirements

To utilize the NUDAR simulations, ensure you have MATLAB (version 2018a or later) installed. The simulations also rely on a common functions repository, which must be accessible within your MATLAB environment.

Follow these steps to set up your environment:

1.  Clone the Common Functions repository for MATLAB:
    ```shell
    git clone https://github.com/ultralytics/functions-matlab
    ```
2.  Add the cloned repository to your MATLAB path using the following command:
    ```matlab
    addpath(genpath('/path/to/functions-matlab')) % Replace /path/to/ with the actual path
    ```

**Note:** The following MATLAB toolboxes are also required:

-   [Statistics and Machine Learning Toolbox](https://www.mathworks.com/products/statistics.html)
-   [Signal Processing Toolbox](https://www.mathworks.com/products/signal.html)
-   [Mapping Toolbox](https://www.mathworks.com/products/mapping.html)

Ensure you have the necessary licenses for these toolboxes, obtainable through official [MathWorks](https://www.mathworks.com/) channels.

## 🚀 Running the Simulation

To start the Interactive Detector Neutrino Direction and Ranging (iDND) tool, execute the following command in the MATLAB command window:

```matlab
iDND
```

This command launches the simulation interface, enabling exploration of various neutrino detection scenarios and earth model configurations. For more on simulation techniques, check resources on [computational modeling](https://en.wikipedia.org/wiki/Computational_model).

## 🤝 Contribute

Contributions from the community are highly encouraged! Whether it's fixing bugs, proposing new features, or enhancing documentation, your input is valuable. Please see our [Contributing Guide](https://docs.ultralytics.com/help/contributing/) for details on how to get started. We also invite you to share your experiences with Ultralytics technologies by completing our [Survey](https://www.ultralytics.com/survey?utm_source=github&utm_medium=social&utm_campaign=Survey). A big thank you 🙏 to all our contributors!

[![Ultralytics open-source contributors](https://raw.githubusercontent.com/ultralytics/assets/main/im/image-contributors.png)](https://github.com/ultralytics/nudar/graphs/contributors)

## ©️ License

Ultralytics offers two licensing options for NUDAR:

-   **AGPL-3.0 License**: An [OSI-approved](https://opensource.org/license/agpl-3.0/) open-source license ideal for students, researchers, and enthusiasts keen on collaboration and knowledge sharing. See the [LICENSE](https://github.com/ultralytics/nudar/blob/main/LICENSE) file for full details.
-   **Enterprise License**: Designed for commercial applications, this license permits the integration of NUDAR into commercial products and services without the open-source obligations of AGPL-3.0. For commercial use, please contact us through [Ultralytics Licensing](https://www.ultralytics.com/license).

## 📬 Contact Us

If you encounter bugs, have feature requests, or wish to contribute, please use [GitHub Issues](https://github.com/ultralytics/nudar/issues). For broader questions and discussions about NUDAR or other Ultralytics projects, join our vibrant community on [Discord](https://discord.com/invite/ultralytics)!

<br>
<div align="center">
  <a href="https://github.com/ultralytics"><img src="https://github.com/ultralytics/assets/raw/main/social/logo-social-github.png" width="3%" alt="Ultralytics GitHub"></a>
  <img src="https://github.com/ultralytics/assets/raw/main/social/logo-transparent.png" width="3%" alt="space">
  <a href="https://www.linkedin.com/company/ultralytics/"><img src="https://github.com/ultralytics/assets/raw/main/social/logo-social-linkedin.png" width="3%" alt="Ultralytics LinkedIn"></a>
  <img src="https://github.com/ultralytics/assets/raw/main/social/logo-transparent.png" width="3%" alt="space">
  <a href="https://twitter.com/ultralytics"><img src="https://github.com/ultralytics/assets/raw/main/social/logo-social-twitter.png" width="3%" alt="Ultralytics Twitter"></a>
  <img src="https://github.com/ultralytics/assets/raw/main/social/logo-transparent.png" width="3%" alt="space">
  <a href="https://youtube.com/ultralytics"><img src="https://github.com/ultralytics/assets/raw/main/social/logo-social-youtube.png" width="3%" alt="Ultralytics YouTube"></a>
  <img src="https://github.com/ultralytics/assets/raw/main/social/logo-transparent.png" width="3%" alt="space">
  <a href="https://www.tiktok.com/@ultralytics"><img src="https://github.com/ultralytics/assets/raw/main/social/logo-social-tiktok.png" width="3%" alt="Ultralytics TikTok"></a>
  <img src="https://github.com/ultralytics/assets/raw/main/social/logo-transparent.png" width="3%" alt="space">
  <a href="https://ultralytics.com/bilibili"><img src="https://github.com/ultralytics/assets/raw/main/social/logo-social-bilibili.png" width="3%" alt="Ultralytics BiliBili"></a>
  <img src="https://github.com/ultralytics/assets/raw/main/social/logo-transparent.png" width="3%" alt="space">
  <a href="https://discord.com/invite/ultralytics"><img src="https://github.com/ultralytics/assets/raw/main/social/logo-social-discord.png" width="3%" alt="Ultralytics Discord"></a>
</div>
