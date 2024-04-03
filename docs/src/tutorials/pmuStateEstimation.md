# [PMU State Estimation](@id PMUStateEstimationTutorials)
To initiate the process, let us construct the `PowerSystem` composite type and formulate the AC model:
```@example PMUSETutorial
using JuliaGrid # hide
@default(unit) # hide
@default(template) # hide

system = powerSystem()

addBus!(system; label = 1, type = 3, active = 0.5)
addBus!(system; label = 2, type = 1, reactive = 0.05)
addBus!(system; label = 3, type = 1, active = 0.5)

@branch(resistance = 0.02, susceptance = 0.04)
addBranch!(system; label = 1, from = 1, to = 2, reactance = 0.05)
addBranch!(system; label = 2, from = 1, to = 2, reactance = 0.01)
addBranch!(system; label = 3, from = 2, to = 3, reactance = 0.04)

addGenerator!(system; label = 1, bus = 1, active = 3.2, reactive = 0.1)
addGenerator!(system; label = 2, bus = 2, active = 2.1, reactive = 0.1)

acModel!(system)
nothing # hide
```

To review, we can conceptualize the bus/branch model as the graph denoted by ``\mathcal{G} = (\mathcal{N}, \mathcal{E})``, where we have the set of buses ``\mathcal{N} = \{1, \dots, n\}``, and the set of branches ``\mathcal{E} \subseteq \mathcal{N} \times \mathcal{N}`` within the power system:
```@repl PMUSETutorial
𝒩 = collect(keys(system.bus.label))
ℰ = [𝒩[system.branch.layout.from] 𝒩[system.branch.layout.to]]
```

---

Next, we will define the `Measurement` type and integrate phasor measurements into the graph ``\mathcal{G}``. These measurements, facilitated by a set of PMUs, capture both bus voltage and branch current phasors:
```@example PMUSETutorial
device = measurement()

@pmu(label = "PMU ?")
addPmu!(system, device; bus = 1, magnitude = 1.0, angle = 0.0, noise = false)
addPmu!(system, device; from = 2, magnitude = 1.2, angle = -3.0, noise = false)
addPmu!(system, device; to = 3, magnitude = 0.5, angle = 3.1, noise = false)

nothing # hide
```

In PMU state estimation, phasor measurements are observed in rectangular coordinates, where both the real and imaginary parts of bus voltage and branch current phasors are considered as measurements. Thus, we observe sets of measurements that capture the real part of phasors ``\bar{\mathcal{P}}_R`` and the imaginary part of phasors ``\bar{\mathcal{P}}_I``. These two sets collectively form the set of measurements ``\mathcal{M}``.


---

!!! ukw "Notation"
    In this section, when referring to a vector ``\mathbf{a}``, we use the notation ``\mathbf{a} = [a_{i}]`` or ``\mathbf{a} = [a_{ij}]``, where ``a_i`` represents the element associated with bus ``i \in \mathcal{N}`` or measurement ``i \in \mathcal{M}``, and ``a_{ij}`` represents the element associated with branch ``(i,j) \in \mathcal{E}``.

---

## [State Estimation Model](@id PMUSEModelTutorials)
Phasor measurements obtained from PMUs are represented in the polar coordinate system, where PMUs measure the magnitude and phase angle of bus voltages or branch currents:
```@repl PMUSETutorial
print(device.pmu.label, device.pmu.magnitude.mean, device.pmu.angle.mean)
```

Measurement variances are also linked with the magnitude and angle of the phasors:
```@repl PMUSETutorial
print(device.pmu.label, device.pmu.magnitude.variance, device.pmu.angle.variance)
```

Thus, PMUs initially output phasor measurements in polar coordinates. However, these can be interpreted in rectangular coordinates, where the real and imaginary parts of bus voltage and branch current phasors serve as measurements. This yields a vector of state variables in rectangular coordinates ``\mathbf x \equiv[\mathbf{V}_\text{re},\mathbf{V}_\text{im}]``:
```math
  \begin{aligned}
    \mathbf{V}_\mathrm{re}&=\big[\Re(\bar{V}_1),\dots,\Re(\bar{V}_n)\big]^T\\
	  \mathbf{V}_\mathrm{im}&=\big[\Im(\bar{V}_1),\dots,\Im(\bar{V}_n)\big]^T.
  \end{aligned}
```
This approach yields linear measurement functions, facilitating a linear state estimation model.

The primary drawback of this method stems from measurement errors, which are associated with polar coordinates. Consequently, the covariance matrix must be transformed from polar to rectangular coordinates. As a result, errors from a single PMU are correlated, leading to a non-diagonal covariance matrix. Despite this, the covariance matrix is commonly treated as diagonal, impacting the accuracy of the state estimation in such scenarios.

Hence, the model includes real and imaginary parts of bus voltage and current phasor measurements from the set ``\mathcal{M}``, contributing to the formulation of a linear system of equations:
```math
  \mathbf{z}=\mathbf{h}(\mathbf x) + \mathbf{u} + \mathbf{w}.
```
Here, ``\mathbf{h}(\mathbf x)= [h_1(\mathbf x), \dots, h_k(\mathbf x)]^{{T}}`` represents the vector of linear measurement functions, while ``\mathbf{z} = [z_1,\dots,z_k]^{\mathrm{T}}`` denotes the vector of measurement values. The vector of uncorrelated measurement errors is denoted as ``\mathbf{u} = [u_1,\dots,u_k]^{\mathrm{T}}``, defining the vector of measurement variances as ``\mathbf{v} = [v_1,\dots,v_k]^{\mathrm{T}}``. The vector ``\mathbf{w} = [w_1,\dots,w_k]^{\mathrm{T}}`` encapsulates the correlation between measurement errors. Finally, it is important to note that the number of equations is equal to ``k = 2|\bar{\mathcal{P}}|``.

In summary, upon defining the PMU, each ``i``-th PMU is associated with two measurement functions ``h_{2i-1}(\mathbf x)``, ``h_{2i}(\mathbf x)``, along with their corresponding measurement values ``z_{2i-1}``, ``z_{2i}``, and the respective variances ``v_{2i-1}``, ``v_{2i}``.

---

##### Bus Voltage Phasor Measurement Functions
The vector ``\mathbf{h}(\mathbf x)`` comprises functions representing bus voltage phasor measurements. When the state vector is presented in the rectangular coordinate system, the real and imaginary components of the phasor directly define these measurement functions. Therefore, the functions defining the bus voltage phasor measurement at bus ``i \in \mathcal{N}`` can be expressed as follows:
```math
  \begin{aligned}
    h_{\Re(\bar{V}_i)}(\cdot) &= \Re(\bar{V}_i)\\
    h_{\Im(\bar{V}_i)}(\cdot) &= \Im(\bar{V}_i).
  \end{aligned}
```

---

##### Branch Current Phasor Measurement Functions
Furthermore, the vector ``\mathbf{h}(\mathbf x)`` encompasses functions representing branch current phasor measurements. In accordance with the guidelines provided in the [AC Model](@ref ACModelTutorials), the functions delineating the real and imaginary components of the phasor at the branch ``(i,j) \in \mathcal{E}`` at the "from" and "to" bus ends are as follows:
```math
  h_{\Re(\bar{I}_{ij})}(\cdot) = g \Re(\bar{V}_i) - b \Im(\bar{V}_i) -
  \left(g_\tau \cos\phi_{ij} - b_\tau \sin \phi_{ij}\right) \Re(\bar{V}_j) +
  \left(g_\tau\sin \phi_{ij} + b_\tau\cos \phi_{ij} \right) \Im(\bar{V}_j)
```

```math
  h_{\Im(\bar{I}_{ij})}(\cdot) = b \Re(\bar{V}_i) + g \Im(\bar{V}_i) -
  \left(g_\tau \sin \phi_{ij} + b_\tau \cos\phi_{ij}\right) \Re(\bar{V}_j) -
  \left(g_\tau\cos \phi_{ij} - b_\tau\sin \phi_{ij} \right)\Im(\bar{V}_j)
```

```math
  h_{\Re(\bar{I}_{ji})}(\cdot) = \tau_{ij}^2 g \Re(\bar{V}_j) - \tau_{ij}^2 b \Im(\bar{V}_j) -
  \left(g_\tau \cos\phi_{ij} + b_\tau \sin \phi_{ij}\right) \Re(\bar{V}_i) -
  \left( g_\tau\sin \phi_{ij} - b_\tau\cos \phi_{ij} \right) \Im(\bar{V}_i)
```

```math
  h_{\Im(\bar{I}_{ji})}(\cdot) = \tau_{ij}^2 b \Re(\bar{V}_j) + \tau_{ij}^2 g \Im(\bar{V}_j) +
  \left(g_\tau \sin \phi_{ij} - b_\tau \cos\phi_{ij} \right) \Re(\bar{V}_i) -
  \left(g_\tau\cos \phi_{ij} + b_\tau\sin \phi_{ij}\right) \Im(\bar{V}_i),
```
where:
```math
  \begin{aligned}
    g = \cfrac{g_{ij} + g_{\text{s}ij}}{\tau_{ij}^2},\;\;\;
    b = \cfrac{b_{ij}+b_{\text{s}ij}} {\tau_{ij}^2},\;\;\;
    g_\tau = \cfrac{g_{ij}}{\tau_{ij}},\;\;\;
    b_\tau = \cfrac{b_{ij}}{\tau_{ij}}.
  \end{aligned}
```

---

##### Measurement Values
Recall that the PMU provides measurements as magnitude and phase angle. This implies that when we measure the bus voltage phasor at bus ``i \in \mathcal{N}``, we obtain the magnitude ``z_{V_i}`` and the angle ``z_{\theta_i}``, while measuring the current at branch ``(i,j) \in \mathcal{E}``, we get the magnitude ``z_{I_{ij}}`` and the angle ``z_{\psi_{ij}}`` at the "from" bus end or ``z_{I_{ji}}`` and ``z_{\psi_{ji}}`` at the "to" bus end of the branch. These measurements must be transformed from polar to rectangular coordinates. Consequently, the vector ``\mathbf{z}`` comprises the following measurement values:
```math
  \begin{aligned}
    z_{\Re(\bar{V}_i)} = z_{V_i} \cos z_{\theta_i}; \;\;\; z_{\Im(\bar{V}_i)} = z_{V_i} \sin z_{\theta_i} \\
    z_{\Re(\bar{I}_{ij})} = z_{I_{ij}} \cos z_{\psi_{ij}}; \;\;\; z_{\Im(\bar{I}_{ij})} = z_{I_{ij}} \sin z_{\psi_{ij}} \\
    z_{\Re(\bar{I}_{ji})} = z_{I_{ji}} \cos z_{\psi_{ji}}; \;\;\; z_{\Im(\bar{I}_{ji})} = z_{I_{ji}} \sin z_{\psi_{ji}}.
  \end{aligned}
```

---

##### Measurement Varinces
Similarly, we need to calculate variances in the rectangular coordinate system. For instance, when we measure the bus voltage phasor at bus ``i \in \mathcal{N}``, we obtain variances related to measurements of the magnitude ``v_{V_i}`` and the angle ``v_{\theta_i}``. Utilizing the classical theory of propagation of uncertainty [[1]](@ref PMUSEReferenceTutorials), the variance related to the measurement value ``z_{\Re(\bar{V}_i)}`` can be calculated as follows:
```math
    v_{\Re(\bar{V}_i)} =
    v_{V_i} \left[ \cfrac{\mathrm \partial} {\mathrm \partial z_{V_i}} (z_{V_i} \cos z_{\theta_i}) \right] +
    v_{\theta_i} \left[ \cfrac{\mathrm \partial} {\mathrm \partial z_{\theta_i}} (z_{V_i} \cos z_{\theta_i})\right] =
    v_{V_i} (\cos z_{\theta_i}) + v_{\theta_i} (z_{V_i} \sin z_{\theta_i}).
```
Using analogy, we can write:
```math
  \begin{aligned}
    v_{\Im(\bar{V}_i)} &=
    v_{V_i} (\sin z_{\theta_i}) + v_{\theta_i} (z_{V_i} \cos z_{\theta_i}) \\
    v_{\Re(\bar{I}_{ij})} & =
    v_{I_{ij}} (\cos z_{\psi_{ij}}) + v_{\psi_{ij}} (z_{I_{ij}} \sin z_{\psi_{ij}}) \\
    v_{\Im(\bar{I}_{ij})} &=
    v_{I_{ij}} (\sin z_{\psi_{ij}}) + v_{\psi_{ij}} (z_{I_{ij}} \cos z_{\psi_{ij}}) \\
    v_{\Re(\bar{I}_{ji})} &=
    v_{I_{ji}} (\cos z_{\psi_{ji}}) + v_{\psi_{ji}} (z_{I_{ji}} \sin z_{\psi_{ji}}) \\
    v_{\Im(\bar{I}_{ji})} &=
    v_{I_{ji}} (\sin z_{\psi_{ji}}) + v_{\psi_{ji}} (z_{I_{ji}} \cos z_{\psi_{ji}}).
  \end{aligned}
```

---

##### Measurement Covarinces
Once again, let us consider the bus voltage phasor measurement at bus ``i \in \mathcal{N}``. The covariances corresponding to that measurement in the rectangular coordinate system can be obtained using the equation:
```math
    v_{\Re(\bar{V}_i), \Im(\bar{V}_i)} = v_{\Im(\bar{V}_i), \Re(\bar{V}_i)} =
    v_{V_i} \cfrac{\mathrm \partial} {\mathrm \partial z_{V_i}} (z_{V_i} \cos z_{\theta_i})
    \cfrac{\mathrm \partial} {\mathrm \partial z_{V_i}} (z_{V_i} \sin z_{\theta_i})  +
    v_{\theta_i} \cfrac{\mathrm \partial} {\mathrm \partial z_{\theta_i}} (z_{V_i} \cos z_{\theta_i})
    \cfrac{\mathrm \partial} {\mathrm \partial z_{\theta_i}} (z_{V_i} \sin z_{\theta_i}),
```
which results in the solution:
```math
    v_{\Re(\bar{V}_i), \Im(\bar{V}_i)} = v_{\Im(\bar{V}_i), \Re(\bar{V}_i)} =
    \cos z_{\theta_i} \sin z_{\theta_i}(v_{V_i} - v_{\theta_i} z_{V_i}).
```
Similarly, for the branch current phasor measurements, we can write:
```math
  \begin{aligned}
    v_{\Re(\bar{I}_{ij}), \Im(\bar{I}_{ij})} &= v_{\Im(\bar{I}_{ij}), \Re(\bar{I}_{ij})}  =
    \sin z_{\psi_{ij}} \cos z_{\psi_{ij}}(v_{I_{ij}}  - v_{\psi_{ij}} z_{I_{ij}}) \\
   v_{\Re(\bar{I}_{ji}), \Im(\bar{I}_{ji})} &= v_{\Im(\bar{I}_{ji}), \Re(\bar{I}_{ji})}  =
    \sin z_{\psi_{ji}} \cos z_{\psi_{ji}}(v_{I_{ji}}  - v_{\psi_{ij}} z_{I_{ji}}).
  \end{aligned}
```

---

## [Weighted Least-squares Estimation](@id PMUSEWLSStateEstimationTutorials)
The solution to the PMU state estimation problem is determined by solving the linear weighted least-squares (WLS) problem, represented by the following formula:
```math
	\mathbf H^{T} \bm \Sigma^{-1} \mathbf H \mathbf x = \mathbf H^{T} \bm \Sigma^{-1} \mathbf z.
```
Here, ``\mathbf z \in \mathbb {R}^{k}`` denotes the vector of measurement values, ``\mathbf {H} \in \mathbb {R}^{k \times 2n}`` represents the coefficient matrix, and ``\bm \Sigma \in \mathbb {R}^{k \times k}`` is the measurement error covariance matrix.

---

##### Implementation
JuliaGrid initiates the PMU state estimation framework by setting up the WLS model, as illustrated in the following:
```@example PMUSETutorial
analysis = pmuWlsStateEstimation(system, device)
nothing # hide
```

---

##### Coefficient Matrix
In JuliaGrid, the coefficient matrix is constructed using measurement functions. For bus voltage phasor measurements, the coefficient expressions for the measurement function`` h_{\Re(\bar{V}_i)}(\cdot)`` are as follows:
```math
  \begin{aligned}
   	\cfrac{\mathrm \partial{h_{\Re(\bar{V}_i)}(\cdot)}}{\mathrm \partial \Re(\bar{V}_i)}=1; \;\;\;
    \cfrac{\mathrm \partial{h_{\Re(\bar{V}_i)}(\cdot)}}{\mathrm \partial \Re(\bar{V}_j)}=0 \\
   	\cfrac{\mathrm \partial{h_{\Re(\bar{V}_i)}(\cdot)}}{\mathrm \partial \Im(\bar{V}_i)}=0;\;\;\;
    \cfrac{\mathrm \partial{h_{\Re(\bar{V}_i)}(\cdot)}}{\mathrm \partial \Im(\bar{V}_j)}=0.
  \end{aligned}
```

Similarly, for the measurement function ``h_{\Im(\bar{V}_i)}(\cdot)``, the coefficients are:
```math
  \begin{aligned}
   	\cfrac{\mathrm \partial{h_{\Im(\bar{V}_i)}(\cdot)}}{\mathrm \partial \Re(\bar{V}_i)}=0;\;\;\;
    \cfrac{\mathrm \partial{h_{\Im(\bar{V}_i)}(\cdot)}}{\mathrm \partial \Re(\bar{V}_j)}=0 \\
   	\cfrac{\mathrm \partial{h_{\Im(\bar{V}_i)}(\cdot)}}{\mathrm \partial \Im(\bar{V}_i)}=1;\;\;\;
    \cfrac{\mathrm \partial{h_{\Im(\bar{V}_i)}(\cdot)}}{\mathrm \partial \Im(\bar{V}_j)}=0.
  \end{aligned}
```

Furthermore, for the measurement functions ``h_{\Re(\bar{I}_{ij})}(\cdot)`` and ``h_{\Im(\bar{I}_{ij})}(\cdot)``, the coefficients are:
```math
  \begin{aligned}
  \cfrac{\mathrm \partial{h_{\Re(\bar{I}_{ij})}(\cdot)}}{\mathrm \partial \Re(\bar{V}_i)} &=
  \cfrac{\mathrm \partial{h_{\Im(\bar{I}_{ij})}(\cdot)}}{\mathrm \partial \Im(\bar{V}_i)} = g \\
  \cfrac{\mathrm \partial{h_{\Re(\bar{I}_{ij})}(\cdot)}} {\mathrm \partial \Re(\bar{V}_j)} &=
  \cfrac{\mathrm \partial{h_{\Im(\bar{I}_{ij})}(\cdot)}} {\mathrm \partial \Im(\bar{V}_j)} =
  - \left(g_\tau \cos\phi_{ij} - b_\tau \sin \phi_{ij}\right)\\
  \cfrac{\mathrm \partial{h_{\Re(\bar{I}_{ij})}(\cdot)}}{\mathrm \partial \Im(\bar{V}_i)} &=-
  \cfrac{\mathrm \partial{h_{\Im(\bar{I}_{ij})}(\cdot)}}{\mathrm \partial \Re(\bar{V}_i)} =
  -b \\
  \cfrac{\mathrm \partial{h_{\Re(\bar{I}_{ij})}(\cdot)}}{\mathrm \partial \Im(\bar{V}_j)} &= -
  \cfrac{\mathrm \partial{h_{\Im(\bar{I}_{ij})}(\cdot)}}{\mathrm \partial\Re(\bar{V}_j)} =
  \left(g_\tau\sin \phi_{ij} + b_\tau \cos \phi_{ij} \right),
  \end{aligned}
```
and for the measurement functions ``h_{\Re(\bar{I}_{ji})}(\cdot)`` and ``h_{\Im(\bar{I}_{ji})}(\cdot)``, the coefficients are:
```math
  \begin{aligned}
  \cfrac{\mathrm \partial{h_{\Re(\bar{I}_{ji})}(\cdot)}}{\mathrm \partial \Re(\bar{V}_i)} &=
  \cfrac{\mathrm \partial{h_{\Im(\bar{I}_{ji})}(\cdot)}}{\mathrm \partial \Im(\bar{V}_i)} =
  - \left(g_\tau \cos\phi_{ij} + b_\tau \sin \phi_{ij}\right)\\
  \cfrac{\mathrm \partial{h_{\Re(\bar{I}_{ji})}(\cdot)}} {\mathrm \partial \Re(\bar{V}_j)} &=
  \cfrac{\mathrm \partial{h_{\Im(\bar{I}_{ji})}(\cdot)}} {\mathrm \partial \Im(\bar{V}_j)} = \tau_{ij}^2g\\
  \cfrac{\mathrm \partial{h_{\Re(\bar{I}_{ji})}(\cdot)}}{\mathrm \partial \Im(\bar{V}_i)} &= -
  \cfrac{\mathrm \partial{h_{\Im(\bar{I}_{ji})}(\cdot)}}{\mathrm \partial \Re(\bar{V}_i)} =
  -\left(g_\tau\sin \phi_{ij} - b_\tau\cos \phi_{ij} \right) \\
  \cfrac{\mathrm \partial{h_{\Re(\bar{I}_{ji})}(\cdot)}}{\mathrm \partial \Im(\bar{V}_j)} &= -
  \cfrac{\mathrm \partial{h_{\Im(\bar{I}_{ji})}(\cdot)}}{\mathrm \partial \Re(\bar{V}_j)} =
  -\tau_{ij}^2b.
  \end{aligned}
```

Using the above-described equations, JuliaGrid forms the coefficient matrix ``\mathbf{H} \in \mathbb{R}^{k \times 2n}``:
```@repl PMUSETutorial
𝐇 = analysis.method.coefficient
```
In this matrix, each row corresponds to a specific measurement in the rectangular coordinate system. Therefore, the ``i``-th PMU is associated with the ``2i - 1`` index of the row, representing the real part of the phasor measurement, while the ``2i`` row corresponds to the imaginary part of the phasor measurement. Columns are ordered based on how the state variables are defined ``\mathbf x \equiv[\mathbf{V}_\text{re},\mathbf{V}_\text{im}]``.

---

##### Precision Matrix
JuliaGrid opts not to retain the covariance matrix ``\bm \Sigma`` but rather stores its inverse, the precision or weighting matrix denoted as ``\mathbf W = \bm \Sigma^{-1}``. The order of these values corresponds to the description provided for the coefficient matrix. Users can access these values using the following command:
```@repl PMUSETutorial
𝐖 = analysis.method.precision
```
The precision matrix maintains a diagonal form, implying that correlations between the real and imaginary parts of the phasor measurements are disregarded.

To accommodate correlations, users have the option to consider correlation when adding each PMU to the `Measurement` type. For instance, let us add a new PMU while considering correlation:
```@example PMUSETutorial
addPmu!(system, device; bus = 2, magnitude = 1.02, angle = 0.015, correlated = true)

nothing # hide
```

Following this, we recreate the WLS state estimation model:
```@example PMUSETutorial
analysis = pmuWlsStateEstimation(system, device)
nothing # hide
```

Upon inspection, it becomes evident that the precision matrix no longer maintains a diagonal structure:
```@repl PMUSETutorial
𝐖 = analysis.method.precision
```

---

##### Mean Vector
To retrieve the vector ``\mathbf z``, containing the means of Gaussian distributions for each measurement, users can utilize:
```@repl PMUSETutorial
𝐳 = analysis.method.mean
```
These values represent measurement values in the rectangular coordinate system as described earlier.

---

##### Estimate of State Variables
Next, the WLS equation is solved to obtain the estimate of bus voltage magnitudes and angles:
```math
	\hat{\mathbf x} = [\mathbf H^{T} \bm \Sigma^{-1} \mathbf H]^{-1} \mathbf H^{T} \bm \Sigma^{-1} \mathbf z.
```

This process is executed using the [`solve!`](@ref solve!(::PowerSystem, ::PMUStateEstimation{LinearWLS{Normal}})) function:
```@example PMUSETutorial
solve!(system, analysis)
```

The initial step involves the LU factorization of the gain matrix:
```math
	\mathbf G = \mathbf H^{T} \bm \Sigma^{-1} \mathbf H = \mathbf L \mathbf U.
```

!!! tip "Tip"
    By default, JuliaGrid utilizes LU factorization as the primary method to factorize the gain matrix. However, users maintain the flexibility to opt for alternative factorization methods such as LDLt or QR.

Access to the factorized gain matrix is available through:
```@repl PMUSETutorial
𝐋 = analysis.method.factorization.L
𝐔 = analysis.method.factorization.U
```

Finally, JuliaGrid obtains the solution in the rectangular coordinate system and then transforms these solutions into the standard form given in the polar coordinate system.

The estimated bus voltage magnitudes ``\hat{\mathbf V} = [V_i]`` and angles ``\hat{\bm {\Theta}} = [\hat{\theta}_i]``, ``i \in \mathcal{N}``, can be retrieved using the variables:
```@repl PMUSETutorial
𝐕 = analysis.voltage.magnitude
𝚯 = analysis.voltage.angle
```

!!! note "Info"
    It is essential to note that the slack bus does not exist in the case of the PMU state estimation model.

---

##### [Alternative Formulation](@id PMUSEOrthogonalWLSStateEstimationTutorials)
The resolution of the WLS state estimation problem using the conventional method typically progresses smoothly. However, it is widely acknowledged that in certain situations common to real-world systems, this method can be vulnerable to numerical instabilities. Such conditions might impede the algorithm from converging to a satisfactory solution. In such cases, users may opt for an alternative formulation of the WLS state estimation, namely, employing an approach called orthogonal factorization [[2, Sec. 3.2]](@ref DCStateEstimationReferenceManual).

This approach is suitable when measurement errors are uncorrelated, and the precision matrix remains diagonal. Therefore, as a preliminary step, we need to eliminate the correlation, as we did previously:
```@example PMUSETutorial
updatePmu!(system, device; label = "PMU 4", correlated = false)

nothing # hide
```

To address ill-conditioned situations arising from significant differences in measurement variances, users can employ an alternative approach:
```@example PMUSETutorial
analysis = pmuWlsStateEstimation(system, device, Orthogonal)
nothing # hide
```

To explain the method, we begin with the WLS equation:
```math
	\mathbf H^{T} \mathbf W \mathbf H \hat{\mathbf x} = \mathbf H^{T} \mathbf W \mathbf z,
```
where ``\mathbf W = \bm \Sigma^{-1}``. Subsequently, we can write:
```math
  \left({\mathbf W^{1/2}} \mathbf H\right)^{T}  {\mathbf W^{1/2}} \mathbf H  \hat{\mathbf x} = \left({\mathbf W^{1/2}} \mathbf H\right)^{T} {\mathbf W^{1/2}} \mathbf z.
```

Consequently, we have:
```math
  \bar{\mathbf{H}}^{T}  \bar{\mathbf{H}} \hat{\mathbf x} = \bar{\mathbf{H}}^{T}  \bar{\mathbf{z}},
```
where:
```math
  \bar{\mathbf{H}} = {\mathbf W^{1/2}} \mathbf H; \;\;\; \bar{\mathbf{z}} = {\mathbf W^{1/2}} \mathbf z.
```

At this point, QR factorization is performed on the rectangular matrix:
```math
  \bar{\mathbf{H}} = {\mathbf W^{1/2}} \mathbf H = \mathbf{Q}\mathbf{R}.
```

Executing this procedure involves the [`solve!`](@ref solve!(::PowerSystem, ::PMUStateEstimation{LinearWLS{Normal}})) function:
```@example PMUSETutorial
solve!(system, analysis)
nothing # hide
```

Access to the factorized matrix is possible through:
```@repl PMUSETutorial
𝐐 = analysis.method.factorization.Q
𝐑 = analysis.method.factorization.R
```

To obtain the solution, JuliaGrid avoids materializing the orthogonal matrix ``\mathbf{Q}`` and proceeds to solve the system, resulting in the estimate of bus voltage magnitudes ``\hat{\mathbf V} = [V_i]`` and angles ``\hat{\bm {\Theta}} = [\hat{\theta}_i]``, where ``i \in \mathcal{N}``:
```@repl PMUSETutorial
𝐕 = analysis.voltage.magnitude
𝚯 = analysis.voltage.angle
```

---

## [Bad Data Processing](@id PMUSEBadDataTutorials)
Besides the state estimation algorithm, one of the essential state estimation routines is the bad data processing, whose main task is to detect and identify measurement errors, and eliminate them if possible. This is usually done by processing the measurement residuals [[2, Ch. 5]](@ref PMUSEReferenceTutorials), and typically, the largest normalized residual test is used to identify bad data. The largest normalized residual test is performed after we obtained the solution of the state estimation in the repetitive process of identifying and eliminating bad data measurements one after another [[3]](@ref PMUSEReferenceTutorials).

To illustrate this process, let us introduce a new measurement that contains an obvious outlier:
```@example PMUSETutorial
addPmu!(system, device; bus = 3, magnitude = 2.5, angle = 0.0, noise = false)

nothing # hide
```

Subsequently, we will construct the WLS state estimation model and solve it:
```@example PMUSETutorial
analysis = pmuWlsStateEstimation(system, device)
solve!(system, analysis)
nothing # hide
```

Now, the bad data processing can be executed:
```@example PMUSETutorial
residualTest!(system, device, analysis; threshold = 4.0)
nothing # hide
```

In this step, we employ the largest normalized residual test, guided by the analysis outlined in [[2, Sec. 5.7]](@ref PMUSEReferenceTutorials). To be more precise, we compute all measurement residuals in the rectangular coordinate system based on the obtained estimate of state variables:
```math
    r_{i} = z_i - h_i(\hat {\mathbf x}), \;\;\; i \in \mathcal{M}.
```

The normalized residuals for all measurements are computed as follows:
```math
    \bar{r}_{i} = \cfrac{|r_i|}{\sqrt{C_{ii}}} = \cfrac{|r_i|}{\sqrt{S_{ii}\Sigma_{ii}}}, \;\;\; i \in \mathcal{M},
```

In this equation, we denote the diagonal entries of the residual covariance matrix ``\mathbf C \in \mathbb{R}^{k \times k}`` as ``C_{ii} = S_{ii}\Sigma_{ii}``, where ``S_{ii}`` is the diagonal entry of the residual sensitivity matrix ``\mathbf S`` representing the sensitivity of the measurement residuals to the measurement errors. For this specific configuration, the relationship is expressed as:
```math
    \mathbf C = \mathbf S \bm \Sigma = \bm \Sigma - \mathbf H [\mathbf H^T \bm \Sigma^{-1} \mathbf H]^{-1} \mathbf H^T.
```
It is important to note that only the diagonal entries of ``\mathbf C`` are required. To obtain the inverse, the JuliaGrid package utilizes a computationally efficient sparse inverse method, retrieving only the necessary elements of the inverse.

The subsequent step involves selecting the largest normalized residual, and the ``j``-th measurement is then suspected as bad data and potentially removed from the measurement set ``\mathcal{M}``:
```math
    \bar{r}_{j} = \text{max} \{\bar{r}_{i}, i \in \mathcal{M} \},
```

Users can access this information using the variable:
```@repl PMUSETutorial
analysis.outlier.maxNormalizedResidual
```

If the largest normalized residual, denoted as ``\bar{r}_{j}``, satisfies the inequality:
```math
    \bar{r}_{j} \ge \epsilon,
```
the corresponding measurement is identified as bad data and subsequently removed. In this example, the bad data identification `threshold` is set to ``\epsilon = 4``. Users can verify the satisfaction of this inequality by inspecting:
```@repl PMUSETutorial
analysis.outlier.detect
```

This indicates that the measurement labeled as:
```@repl PMUSETutorial
analysis.outlier.label
```
is removed from the PMU model and marked as out-of-service. Specifically, either the real or imaginary part of the corresponding measurement is identified as the outlier. Consequently, both parts of the measurement are removed from the PMU state estimation model.


Subsequently, we can immediately solve the system again, but this time without the removed measurement:
```@example PMUSETutorial
solve!(system, analysis)
nothing # hide
```

Following that, we check for outliers once more:
```@example PMUSETutorial
residualTest!(system, device, analysis; threshold = 4.0)
nothing # hide
```

To examine the value:
```@repl PMUSETutorial
analysis.outlier.maxNormalizedResidual
```

As this value is now less than the `threshold` ``\epsilon = 4``, the measurement is not removed, or there are no outliers. This can also be verified by observing the bad data flag:
```@repl PMUSETutorial
analysis.outlier.detect
```

---

## [Least Absolute Value Estimation](@id PMUSELAVTutorials)
The least absolute value (LAV) method provides an alternative estimation approach that is considered more robust in comparison to the WLS method. The WLS state estimation problem relies on specific assumptions about measurement errors, whereas robust estimators aim to remain unbiased even in the presence of various types of measurement errors and outliers. This characteristic eliminates the need for bad data processing, as discussed in [[2, Ch. 6]](@ref DCSEReferenceTutorials). It is important to note that robustness often comes at the cost of increased computational complexity.

It can be demonstrated that the problem can be expressed as a linear programming problem. This section outlines the method as described in [[1, Sec. 6.5]](@ref DCSEReferenceTutorials). To revisit, we consider the system of linear equations:
```math
  \mathbf{z}=\mathbf{h}(\mathbf x)+\mathbf{u}+\mathbf{w}.
```

Subsequently, the LAV state estimator is derived as the solution to the optimization problem:
```math
  \begin{aligned}
    \text{minimize}& \;\;\; \mathbf a^T |\mathbf r|\\
    \text{subject\;to}& \;\;\; \mathbf{z} - \mathbf{H} \mathbf x =\mathbf r.
  \end{aligned}
```
Here, ``\mathbf a \in \mathbb {R}^{k}`` is the vector with all entries equal to one, and ``\mathbf r`` represents the vector of measurement residuals. Let ``\bm \eta`` be defined in a manner that ensures:
```math
  |\mathbf r| \preceq \bm \eta,
```
and replace the above inequality with two equalities using the introduction of two non-negative slack variables ``\mathbf q \in \mathbb {R}_{\ge 0}^{k}`` and ``\mathbf w \in \mathbb {R}_{\ge 0}^{k}``:
```math
  \begin{aligned}
    \mathbf r - \mathbf q &= -\bm \eta \\
    \mathbf r + \mathbf w &= \bm \eta.
  \end{aligned}
```

Let us now define four additional non-negative variables:
```math
    \mathbf x_x \in \mathbb {R}_{\ge 0}^{n}; \;\;\; \mathbf x_y  \in \mathbb {R}_{\ge 0}^{n}; \;\;\;
    \mathbf {r}_x \in \mathbb {R}_{\ge 0}^{k}; \;\;\; \mathbf {r}_y \in \mathbb {R}_{\ge 0}^{k},
```
where:
```math
    \mathbf x = \mathbf x_x - \mathbf x_y; \;\;\; \mathbf r = \mathbf {r}_x - \mathbf {r}_y\\
    \mathbf {r}_x = \cfrac{1}{2} \mathbf q; \;\;\;  \mathbf {r}_y = \cfrac{1}{2} \mathbf w.
```
Then, the above two equalities become:
```math
  \begin{aligned}
    \mathbf r - 2\mathbf {r}_x &= -2\bm \eta \\
    \mathbf r + 2 \mathbf {r}_y &= 2\bm \eta,
  \end{aligned}
```
that is:
```math
  \begin{aligned}
    \mathbf {r}_x + \mathbf {r}_y = \bm \eta; \;\;\; \mathbf r = \mathbf {r}_x - \mathbf {r}_y.
  \end{aligned}
```

Hence, the optimization problem can be written:
```math
  \begin{aligned}
    \text{minimize}& \;\;\; \mathbf a^T (\mathbf {r}_x + \mathbf {r}_y)\\
    \text{subject\;to}& \;\;\; \mathbf{H}(\mathbf x_x - \mathbf x_y) + \mathbf {r}_x - \mathbf {r}_y = \mathbf{z} \\
                       & \;\;\; \mathbf x_x \succeq \mathbf 0, \; \mathbf x_y \succeq \mathbf 0 \\
                       & \;\;\; \mathbf {r}_x \succeq \mathbf 0, \; \mathbf {r}_y \succeq \mathbf 0.
  \end{aligned}
```

To form the above optimization problem, the user can call the following function:
```@example PMUSETutorial
using Ipopt
using JuMP # hide

analysis = pmuLavStateEstimation(system, device, Ipopt.Optimizer)
nothing # hide
```

Then the user can solve the optimization problem by:
```@example PMUSETutorial
JuMP.set_silent(analysis.method.jump) # hide
solve!(system, analysis)
nothing # hide
```
As a result, we obtain optimal values for the four additional non-negative variables, while the state estimator is obtained by:
```math
    \hat{\mathbf x} = \mathbf x_x - \mathbf x_y.
```

Users can retrieve the estimated bus voltage magnitudes ``\hat{\mathbf V} = [V_i]`` and angles ``\hat{\bm {\Theta}} = [\hat{\theta}_i]``, ``i \in \mathcal{N}``, using:
```@repl PMUSETutorial
𝐕 = analysis.voltage.magnitude
𝚯 = analysis.voltage.angle
```

---

## [Optimal PMU Placement](@id optimalpmu)
JuliaGrid utilizes the optimal PMU placement algorithm proposed in [[4]](@ref PMUSEReferenceTutorials). The optimal positioning of PMUs is framed as an integer linear programming problem, expressed as:
```math
  \begin{aligned}
    \text{minimize}& \;\;\; \sum_{i=1}^n d_i\\
    \text{subject\;to}& \;\;\; \mathbf A \mathbf d \ge \mathbf a.
  \end{aligned}
```
Here, the vector \mathbf ``d = [d_1,\dots,d_n]^T`` serves as the optimization variable, where ``d_i \in \mathbb{F} = \{0,1\}`` is the PMU placement or a binary decision variable associated with the bus ``i \in \mathcal{N}``. The all-one vector ``\mathbf a`` is of dimension ``n``. The binary connectivity matrix ``\mathbf A \in \mathbb{F}^{n \times n}`` can be directly derived from the bus nodal matrix ``\mathbf Y`` by converting its entries into binary form [[5]](@ref PMUSEReferenceTutorials).

Consequently, we obtain the binary vector ``\mathbf d = [d_1,\dots,d_n]^T``, where ``d_i = 1``, ``i \in \mathcal{N}``, suggests that a PMU should be placed at bus ``i``. The primary aim of PMU placement in the power system is to determine a minimal set of PMUs such that the entire system is observable without relying on traditional measurements [[4]](@ref PMUSEReferenceTutorials). Specifically, when we observe ``d_i = 1``, it indicates that the PMU is installed at bus ``i \in \mathcal{N}`` to measure bus voltage phasor and also to measure all current phasors across branches incident to bus ``i``.

To execute optimal PMU placement, users can utilize the following function:
```@example PMUSETutorial
using GLPK

placement = pmuPlacement(system, GLPK.Optimizer)

nothing # hide
```

The `placement` variable contains data regarding the optimal placement of measurements. It lists all buses ``i \in \mathcal{N}`` that satisfy ``d_i = 1``:
```@repl PMUSETutorial
placement.bus
```

This PMU installed at bus `2` will measure the bus voltage phasor at the corresponding bus and all current phasors at the branches incident to bus `2` located at the "from" or "to" bus ends. These data are stored in the variables:
```@repl PMUSETutorial
placement.from
placement.to
```

---


## [Power Analysis](@id PMUPowerAnalysisTutorials)
Once the computation of voltage magnitudes and angles at each bus is completed, various electrical quantities can be determined. JuliaGrid offers the [`power!`](@ref power!(::PowerSystem, ::ACPowerFlow)) function, which enables the calculation of powers associated with buses and branches. Here is an example code snippet demonstrating its usage:
```@example PMUSETutorial
power!(system, analysis)
nothing # hide
```

The function stores the computed powers in the rectangular coordinate system. It calculates the following powers related to buses and branches:

| Bus                                                            | Active                                          | Reactive                                        |
|:---------------------------------------------------------------|:------------------------------------------------|:------------------------------------------------|
| [Injections](@ref BusInjectionsTutorials)                      | ``\mathbf{P} = [P_i]``                          | ``\mathbf{Q} = [Q_i]``                          |
| [Generator injections](@ref PMUGeneratorPowerInjectionsManual) | ``\mathbf{P}_{\text{p}} = [P_{\text{p}i}]``     | ``\mathbf{Q}_{\text{p}} = [Q_{\text{p}i}]``     |
| [Shunt elements](@ref BusShuntElementTutorials)                | ``\mathbf{P}_{\text{sh}} = [{P}_{\text{sh}i}]`` | ``\mathbf{Q}_{\text{sh}} = [{Q}_{\text{sh}i}]`` |


| Branch                                                       | Active                                       | Reactive                                     |
|:-------------------------------------------------------------|:---------------------------------------------|:---------------------------------------------|
| ["From" bus end flows](@ref BranchNetworkEquationsTutorials) | ``\mathbf{P}_{\text{i}} = [P_{ij}]``         | ``\mathbf{Q}_{\text{i}} = [Q_{ij}]``         |
| ["To" bus end flows](@ref BranchNetworkEquationsTutorials)   | ``\mathbf{P}_{\text{j}} = [P_{ji}]``         | ``\mathbf{Q}_{\text{j}} = [Q_{ji}]``         |
| [Shunt elements](@ref BranchShuntElementsTutorials)          | ``\mathbf{P}_{\text{s}} = [P_{\text{s}ij}]`` | ``\mathbf{P}_{\text{s}} = [P_{\text{s}ij}]`` |
| [Series elements](@ref BranchSeriesElementTutorials)         | ``\mathbf{P}_{\text{l}} = [P_{\text{l}ij}]`` | ``\mathbf{Q}_{\text{l}} = [Q_{\text{l}ij}]`` |

!!! note "Info"
    For a clear comprehension of the equations, symbols presented in this section, as well as for a better grasp of power directions, please refer to the [Unified Branch Model](@ref UnifiedBranchModelTutorials).

---

##### Power Injections
[Active and reactive power injections](@ref BusInjectionsTutorials) are stored as the vectors ``\mathbf{P} = [P_i]`` and ``\mathbf{Q} = [Q_i]``, respectively, and can be retrieved using the following commands:
```@repl PMUSETutorial
𝐏 = analysis.power.injection.active
𝐐 = analysis.power.injection.reactive
```

----

##### [Generator Power Injections](@id PMUGeneratorPowerInjectionsManual)
We can calculate the active and reactive power injections supplied by generators at each bus ``i \in \mathcal{N}`` by summing the active and reactive power injections and the active and reactive power demanded by consumers at each bus:
```math
  \begin{aligned}
    P_{\text{p}i} &= P_i + P_{\text{d}i}\\
    Q_{\text{p}i} &= Q_i + Q_{\text{d}i}.
  \end{aligned}
```

The active and reactive power injections from the generators at each bus are stored as vectors, denoted by ``\mathbf{P}_{\text{p}} = [P_{\text{p}i}]`` and ``\mathbf{Q}_{\text{p}} = [Q_{\text{p}i}]``, which can be obtained using:
```@repl PMUSETutorial
𝐏ₚ = analysis.power.supply.active
𝐐ₚ = analysis.power.supply.reactive
```

---

##### Power at Bus Shunt Elements
[Active and reactive powers](@ref BusShuntElementTutorials) associated with the shunt elements at each bus are represented by the vectors ``\mathbf{P}_{\text{sh}} = [{P}_{\text{sh}i}]`` and ``\mathbf{Q}_{\text{sh}} = [{Q}_{\text{sh}i}]``. To retrieve these powers in JuliaGrid, use the following commands:
```@repl PMUSETutorial
𝐏ₛₕ = analysis.power.shunt.active
𝐐ₛₕ = analysis.power.shunt.reactive
```

---

##### Power Flows
The resulting [active and reactive power flows](@ref BranchNetworkEquationsTutorials) at each "from" bus end are stored as the vectors ``\mathbf{P}_{\text{i}} = [P_{ij}]`` and ``\mathbf{Q}_{\text{i}} = [Q_{ij}],`` respectively, and can be retrieved using the following commands:
```@repl PMUSETutorial
𝐏ᵢ = analysis.power.from.active
𝐐ᵢ = analysis.power.from.reactive
```

Similarly, the vectors of [active and reactive power flows](@ref BranchNetworkEquationsTutorials) at the "to" bus end are stored as ``\mathbf{P}_{\text{j}} = [P_{ji}]`` and ``\mathbf{Q}_{\text{j}} = [Q_{ji}]``, respectively, and can be retrieved using the following code:
```@repl PMUSETutorial
𝐏ⱼ = analysis.power.to.active
𝐐ⱼ = analysis.power.to.reactive
```

---

##### Power at Branch Shunt Elements
[Active and reactive powers](@ref BranchShuntElementsTutorials) associated with the branch shunt elements at each branch are represented by the vectors ``\mathbf{P}_{\text{s}} = [P_{\text{s}ij}]`` and ``\mathbf{Q}_{\text{s}} = [Q_{\text{s}ij}]``. We can retrieve these values using the following code:
```@repl PMUSETutorial
𝐏ₛ = analysis.power.charging.active
𝐐ₛ = analysis.power.charging.reactive
```

---

##### Power at Branch Series Elements
[Active and reactive powers](@ref BranchSeriesElementTutorials) associated with the branch series element at each branch are represented by the vectors ``\mathbf{P}_{\text{l}} = [P_{\text{l}ij}]`` and ``\mathbf{Q}_{\text{l}} = [Q_{\text{l}ij}]``. We can retrieve these values using the following code:
```@repl PMUSETutorial
𝐏ₗ = analysis.power.series.active
𝐐ₗ = analysis.power.series.reactive
```

---

## [Current Analysis](@id PMUCurrentAnalysisTutorials)
JuliaGrid offers the [`current!`](@ref current!(::PowerSystem, ::ACPowerFlow)) function, which enables the calculation of currents associated with buses and branches. Here is an example code snippet demonstrating its usage:
```@example PMUSETutorial
current!(system, analysis)
nothing # hide
```

The function stores the computed currents in the polar coordinate system. It calculates the following currents related to buses and branches:

| Bus                                       | Magnitude              | Angle                    |
|:------------------------------------------|:-----------------------|:-------------------------|
| [Injections](@ref BusInjectionsTutorials) | ``\mathbf{I} = [I_i]`` | ``\bm{\psi} = [\psi_i]`` |

| Branch                                                       | Magnitude                                    | Angle                                          |
|:-------------------------------------------------------------|:---------------------------------------------|:-----------------------------------------------|
| ["From" bus end flows](@ref BranchNetworkEquationsTutorials) | ``\mathbf{I}_{\text{i}} = [I_{ij}]``         | ``\bm{\psi}_{\text{i}} = [\psi_{ij}]``         |
| ["To" bus end flows](@ref BranchNetworkEquationsTutorials)   | ``\mathbf{I}_{\text{j}} = [I_{ji}]``         | ``\bm{\psi}_{\text{j}} = [\psi_{ji}]``         |
| [Series elements](@ref BranchSeriesElementTutorials)         | ``\mathbf{I}_{\text{l}} = [I_{\text{l}ij}]`` | ``\bm{\psi}_{\text{l}} = [\psi_{\text{l}ij}]`` |

!!! note "Info"
    For a clear comprehension of the equations, symbols presented in this section, as well as for a better grasp of power directions, please refer to the [Unified Branch Model](@ref UnifiedBranchModelTutorials).

---

##### Current Injections
In JuliaGrid, [complex current injections](@ref BusInjectionsTutorials) are stored in the vector of magnitudes denoted as ``\mathbf{I} = [I_i]`` and the vector of angles represented as ``\bm{\psi} = [\psi_i]``. You can retrieve them using the following commands:
```@repl PMUSETutorial
𝐈 = analysis.current.injection.magnitude
𝛙 = analysis.current.injection.angle
```

---

##### Current Flows
To obtain the vectors of magnitudes ``\mathbf{I}_{\text{i}} = [I_{ij}]`` and angles ``\bm{\psi}_{\text{i}} = [\psi_{ij}]`` for the resulting [complex current flows](@ref BranchNetworkEquationsTutorials), you can use the following commands:
```@repl PMUSETutorial
𝐈ᵢ = analysis.current.from.magnitude
𝛙ᵢ = analysis.current.from.angle
```

Similarly, we can obtain the vectors of magnitudes ``\mathbf{I}_{\text{j}} = [I_{ji}]`` and angles ``\bm{\psi}_{\text{j}} = [\psi_{ji}]`` of the resulting c[omplex current flows](@ref BranchNetworkEquationsTutorials) using the following code:
```@repl PMUSETutorial
𝐈ⱼ = analysis.current.to.magnitude
𝛙ⱼ = analysis.current.to.angle
```

---

##### Current at Branch Series Elements
To obtain the vectors of magnitudes ``\mathbf{I}_{\text{l}} = [I_{\text{l}ij}]`` and angles ``\bm{\psi}_{\text{l}} = [\psi_{\text{l}ij}]`` of the resulting [complex current flows](@ref BranchSeriesElementTutorials), one can use the following code:
```@repl PMUSETutorial
𝐈ₗ = analysis.current.series.magnitude
𝛙ₗ = analysis.current.series.angle
```

---

## [References](@id PMUSEReferenceTutorials)

[1] ISO-IEC-OIML-BIPM: "Guide to the expression of uncertainty in measurement," 1992.

[2] A. Abur and A. Exposito, *Power System State Estimation: Theory and Implementation*, Taylor & Francis, 2004.

[3] G. Korres, "A distributed multiarea state estimation," *IEEE Trans. Power Syst.*, vol. 26, no. 1, pp. 73–84, Feb. 2011.

[4] B. Gou, "Optimal placement of PMUs by integer linear programming," *IEEE Trans. Power Syst.*, vol. 23, no. 3, pp. 1525–1526, Aug. 2008.

[5] B. Xu and A. Abur, "Observability analysis and measurement placement for systems with PMUs," *in Proc. IEEE PES PSCE*, New York, NY, 2004, pp. 943-946 vol.2.


