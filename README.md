<a href="https://www.ultralytics.com/"><img src="https://raw.githubusercontent.com/ultralytics/assets/main/logo/Ultralytics_Logotype_Original.svg" width="320" alt="Ultralytics logo"></a>

# 🌟 NUDAR (NeUtrino Detection and Ranging)

Welcome to the NUDAR (NeUtrino Detection and Ranging) repository by [Ultralytics](https://www.ultralytics.com/)! This project offers sophisticated simulation tools crafted for modeling the Earth's structure and simulating [neutrino](https://en.wikipedia.org/wiki/Neutrino) detector systems. Grounded in scientific research, our tools cater to both the academic community and applied sciences within [geophysics](https://en.wikipedia.org/wiki/Geophysics) and [particle physics](https://home.cern/science/physics/). Explore the fascinating intersection of earth modeling and neutrino detection with NUDAR! 🌍✨

[![Ultralytics Actions](https://github.com/ultralytics/nudar/actions/workflows/format.yml/badge.svg)](https://github.com/ultralytics/nudar/actions/workflows/format.yml)
[![Ultralytics Discord](https://img.shields.io/discord/1089800235347353640?logo=discord&logoColor=white&label=Discord&color=blue)](https://discord.com/invite/ultralytics)
[![Ultralytics Forums](https://img.shields.io/discourse/users?server=https%3A%2F%2Fcommunity.ultralytics.com&logo=discourse&label=Forums&color=blue)](https://community.ultralytics.com/)
[![Ultralytics Reddit](https://img.shields.io/reddit/subreddit-subscribers/ultralytics?style=flat&logo=reddit&logoColor=white&label=Reddit&color=blue)](https://reddit.com/r/ultralytics)

## 📜 Description

NUDAR provides a comprehensive suite of [MATLAB](https://www.mathworks.com/products/matlab.html) simulations designed to advance the theoretical study of [antineutrino](https://en.wikipedia.org/wiki/Antineutrino) interactions and detection. This software is instrumental in deepening our understanding of antineutrino properties and their potential applications, such as probing the [Earth's interior](https://pubs.usgs.gov/gip/interior/) and enhancing nuclear detection capabilities.

Our development is inspired by the foundational paper by G. Jocher et al., "Theoretical Antineutrino Detection, Direction and Ranging at Long Distances," published in Physics Reports (Volume 527, Issue 3, 2013). For an in-depth look at the scientific principles underpinning these simulations, please consult the publication via its DOI: [https://doi.org/10.1016/j.physrep.2013.01.005](https://doi.org/10.1016/j.physrep.2013.01.005). You can find more insights into related fields on the [Ultralytics Blog](https://www.ultralytics.com/blog).

![Earth Modeling and Neutrino Detection Simulation](https://raw.githubusercontent.com/ultralytics/agm2015/main/AGM2015small.jpg)

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

- [Statistics and Machine Learning Toolbox](https://www.mathworks.com/products/statistics.html)
- [Signal Processing Toolbox](https://www.mathworks.com/products/signal.html)
- [Mapping Toolbox](https://www.mathworks.com/products/mapping.html)

Ensure you have the necessary licenses for these toolboxes, obtainable through official [MathWorks](https://www.mathworks.com/) channels.

## 🚀 Running the Simulation

To start the Interactive Detector Neutrino Direction and Ranging (iDND) tool, execute the following command in the MATLAB command window:

```matlab
iDND
```

This command launches the simulation interface, enabling exploration of various neutrino detection scenarios and earth model configurations. For more on simulation techniques, check resources on [computational modeling](https://en.wikipedia.org/wiki/Computational_model).

## 💡 Contribute

Ultralytics thrives on community collaboration, and we deeply value your contributions! Whether it's reporting bugs, suggesting features, or submitting code changes, your involvement is crucial.

- **Reporting Issues**: Encounter a bug? Please report it on [GitHub Issues](https://github.com/ultralytics/nudar/issues).
- **Feature Requests**: Have an idea for improvement? Share it via [GitHub Issues](https://github.com/ultralytics/nudar/issues).
- **Pull Requests**: Want to contribute code? Please read our [Contributing Guide](https://docs.ultralytics.com/help/contributing) first, then submit a Pull Request.
- **Feedback**: Share your thoughts and experiences by participating in our official [Survey](https://www.ultralytics.com/survey?utm_source=github&utm_medium=social&utm_campaign=Survey).

A heartfelt thank you 🙏 goes out to all our contributors! Your efforts help make Ultralytics tools better for everyone.

[![Ultralytics open-source contributors](https://raw.githubusercontent.com/ultralytics/assets/main/im/image-contributors.png)](https://github.com/ultralytics/ultralytics/graphs/contributors)

## 📄 License

Ultralytics offers two licensing options to accommodate diverse needs:

- **AGPL-3.0 License**: Ideal for students, researchers, and enthusiasts passionate about open collaboration and knowledge sharing. This [OSI-approved](https://opensource.org/license/agpl-3.0) open-source license promotes transparency and community involvement. See the [LICENSE](LICENSE) file for details.
- **Enterprise License**: Designed for commercial applications, this license permits the seamless integration of Ultralytics software and AI models into commercial products and services, bypassing the copyleft requirements of AGPL-3.0. For commercial use cases, please inquire about an [Ultralytics Enterprise License](https://www.ultralytics.com/license).

## 📮 Contact

For bug reports or feature suggestions, please use [GitHub Issues](https://github.com/ultralytics/nudar/issues). For general questions, discussions, and community support, join our [Discord](https://discord.com/invite/ultralytics) server!

<br>
<div align="center">
  <a href="https://github.com/ultralytics"><img src="https://github.com/ultralytics/assets/raw/main/social/logo-social-github.png" width="3%" alt="Ultralytics GitHub"></a>
  <img src="https://github.com/ultralytics/assets/raw/main/social/logo-transparent.png" width="3%" alt="space">
  <a href="https://www.linkedin.com/company/ultralytics/"><img src="https://github.com/ultralytics/assets/raw/main/social/logo-social-linkedin.png" width="3%" alt="Ultralytics LinkedIn"></a>
  <img src="https://github.com/ultralytics/assets/raw/main/social/logo-transparent.png" width="3%" alt="space">
  <a href="https://twitter.com/ultralytics"><img src="https://github.com/ultralytics/assets/raw/main/social/logo-social-twitter.png" width="3%" alt="Ultralytics Twitter"></a>
  <img src="https://github.com/ultralytics/assets/raw/main/social/logo-transparent.png" width="3%" alt="space">
  <a href="https://www.youtube.com/ultralytics?sub_confirmation=1"><img src="https://github.com/ultralytics/assets/raw/main/social/logo-social-youtube.png" width="3%" alt="Ultralytics YouTube"></a>
  <img src="https://github.com/ultralytics/assets/raw/main/social/logo-transparent.png" width="3%" alt="space">
  <a href="https://www.tiktok.com/@ultralytics"><img src="https://github.com/ultralytics/assets/raw/main/social/logo-social-tiktok.png" width="3%" alt="Ultralytics TikTok"></a>
  <img src="https://github.com/ultralytics/assets/raw/main/social/logo-transparent.png" width="3%" alt="space">
  <a href="https://ultralytics.com/bilibili"><img src="https://github.com/ultralytics/assets/raw/main/social/logo-social-bilibili.png" width="3%" alt="Ultralytics BiliBili"></a>
  <img src="https://github.com/ultralytics/assets/raw/main/social/logo-transparent.png" width="3%" alt="space">
  <a href="https://discord.com/invite/ultralytics"><img src="https://github.com/ultralytics/assets/raw/main/social/logo-social-discord.png" width="3%" alt="Ultralytics Discord"></a>
</div>
