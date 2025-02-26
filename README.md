## JuliaGrid

[![Documentation][documentation-badge]][documentation] [![Build][build-badge]][build] [![Codecov][codecov-badge]][codecov]

<a href="https://mcosovic.github.io/JuliaGrid.jl/stable/"><img align="left" width="290" src="/docs/src/assets/logo2.svg" /></a>

JuliaGrid is an open-source and easy-to-use simulation tool and solver designed for researchers and educators. It is available as a Julia package, with its source code released under the MIT License. JuliaGrid primarily focuses on steady-state power system analyses, offering a versatile set of algorithms and easy manipulation of power system configuration and analyses.

We've rigorously tested and validated our simulation tool across various scenarios to the best of our abilities. Your feedback on errors, or bugs as a user would be highly appreciated and can help improve future versions. For more details, visit our [documentation][documentation] site.

---

### Installation
JuliaGrid is compatible with Julia version 1.9 and newer. To get the JuliaGrid package installed, execute the following Julia command:
```
import Pkg
Pkg.add("JuliaGrid")
```

---

### Citing JuliaGrid
Please consider citing the following [preprint](https://arxiv.org/abs/2502.18229) if JuliaGrid contributes to your research or projects:
```bibtex
@misc{juliagrid,
      title={JuliaGrid: An Open-Source Julia-Based Framework for Power System State Estimation},
      author={Mirsad Cosovic and Ognjen Kundacina and Muhamed Delalic and Armin Teskeredzic and Darijo Raca and Amer Mesanovic and Dragisa Miskovic and Dejan Vukobratovic and Antonello Monti},
      year={2025},
      eprint={2502.18229},
      archivePrefix={arXiv},
      primaryClass={cs.SE}
}
```

[documentation-badge]: https://github.com/mcosovic/JuliaGrid.jl/workflows/Documentation/badge.svg
[documentation]: https://mcosovic.github.io/JuliaGrid.jl/stable/
[build-badge]: https://github.com/mcosovic/JuliaGrid.jl/workflows/Build/badge.svg
[build]: https://github.com/mcosovic/JuliaGrid.jl/actions
[codecov-badge]: https://codecov.io/github/mcosovic/JuliaGrid.jl/branch/master/graph/badge.svg
[codecov]: https://app.codecov.io/github/mcosovic/JuliaGrid.jl