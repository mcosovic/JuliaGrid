"""
    addVoltmeter!(system::PowerSystem, device::Measurement; label, bus, magnitude,
        variance, status, noise)

The function adds a new voltmeter to the `Measurement` composite type within a given
`PowerSystem` type. The voltmeter can be added to an already defined bus.

# Keywords
The voltmeter is defined with the following keywords:
* `label`: a unique label for the voltmeter;
* `bus`: the label of the bus to which the voltmeter is connected;
* `magnitude` (pu or V): the bus voltage magnitude value;
* `variance` (pu or V): the variance of the bus voltage magnitude measurement;
* `status`: the operating status of the voltmeter:
  * `status = 1`: in-service;
  * `status = 0`: out-of-service;
* `noise`:
  * `noise = true`: AWGN with `variance` influences `magnitude` to define the measurement mean;
  * `noise = false`: the value of `magnitude` is used as the measurement mean.

# Updates
The function updates the `voltmeter` field of the `Measurement` composite type.

# Default Settings
Default settings for certain keywords are as follows: `variance = 1e-2`, `status = 1`,
`noise = true`, and users can modify these default settings using the
[`@voltmeter`](@ref @voltmeter) macro.

# Units
The default units for the `magnitude` and `variance` keywords are per-units (pu). However,
users can choose to use volts (V) as the units by applying the [`@voltage`](@ref @voltage)
macro.

# Examples
Adding a voltmeter using the default unit system:
```jldoctest
system = powerSystem()
device = measurement()

addBus!(system; label = "Bus 1", base = 132e3)

addVoltmeter!(system, device; label = "Voltmeter 1", bus = "Bus 1", magnitude = 1.1)
```

Adding a voltmeter using a custom unit system:
```jldoctest
@voltage(kV, rad, kV)
system = powerSystem()
device = measurement()

addBus!(system; label = "Bus 1", base = 132.0)

addVoltmeter!(system, device; label = "Voltmeter 1", bus = "Bus 1", magnitude = 145.2)
```
"""
function addVoltmeter!(system::PowerSystem, device::Measurement;
    label::L = missing, bus::L, magnitude::T, variance::T = missing, status::T = missing,
    noise::Bool = template.voltmeter.noise)

    voltmeter = device.voltmeter
    default = template.voltmeter

    voltmeter.number += 1
    setLabel(voltmeter, label, default.label, "voltmeter")

    index = system.bus.label[getLabel(system.bus, bus, "bus")]
    push!(voltmeter.layout.index, index)

    baseVoltageInv = 1 / (system.base.voltage.value[index] * system.base.voltage.prefix)
    setMeter(voltmeter.magnitude, magnitude, variance, status, noise, default.variance,
        default.status, prefix.voltageMagnitude, baseVoltageInv)
end

"""
    addVoltmeter!(system::PowerSystem, device::Measurement, analysis::AC; variance, status)

The function incorporates voltmeters into the `Measurement` composite type for every bus
within the `PowerSystem` type. These measurements are derived from the exact bus voltage
magnitudes defined in the `AC` abstract type. These exact values are perturbed by AWGN
with the specified `variance` to obtain measurement data.

# Keywords
Users have the option to configure the following keywords:
* `variance` (pu or V): the variance of bus voltage magnitude measurements; 
* `status`: the operating status of the voltmeters:
  * `status = 1`: in-service;
  * `status = 0`: out-of-service.

# Updates
The function updates the `voltmeter` field of the `Measurement` composite type.

# Default Settings
Default settings for keywords are as follows: `variance = 1e-2`, `status = 1`, and users
can modify these default settings using the [`@voltmeter`](@ref @voltmeter) macro.

# Units
By default, the unit for `variance` is per-unit (pu). However, users can choose to use
volts (V) as the units by applying the [`@voltage`](@ref @voltage) macro.

# Abstract type
The abstract type `AC` can have the following subtypes:
- `ACPowerFlow`: generates measurements uses AC power flow results;
- `ACOptimalPowerFlow`: generates measurements uses AC optimal power flow results.

# Examples
Adding voltmeters using exact values from the AC power flow:
```jldoctest
system = powerSystem("case14.h5")
acModel!(system)

analysis = newtonRaphson(system)
for i = 1:10
    stopping = mismatch!(system, analysis)
    if all(stopping .< 1e-8)
        break
    end
    solve!(system, analysis)
end

device = measurement()

@voltmeter(label = "Voltmeter ?")
addVoltmeter!(system, device, analysis; variance = 1e-3)
```

Adding voltmeters using exact values from the AC optimal power flow:
```jldoctest
system = powerSystem("case14.h5")
acModel!(system)

analysis = acOptimalPowerFlow(system, Ipopt.Optimizer)
solve!(system, analysis)

device = measurement()

@voltmeter(label = "Voltmeter ?")
addVoltmeter!(system, device, analysis; variance = 1e-3)
```
"""
function addVoltmeter!(system::PowerSystem, device::Measurement, analysis::AC;
    variance::T = missing, status::T = missing)

    voltmeter = device.voltmeter
    default = template.voltmeter

    status = unitless(status, default.status)
    checkStatus(status)

    voltmeter.number = copy(system.bus.number)
    voltmeter.layout.index = collect(1:system.bus.number)
    voltmeter.label = Dict{String,Int64}(); sizehint!(voltmeter.label, voltmeter.number)

    voltmeter.magnitude.mean = similar(analysis.voltage.magnitude)
    voltmeter.magnitude.variance = similar(analysis.voltage.magnitude)
    voltmeter.magnitude.status = fill(Int8(status), system.bus.number)

    prefixInv = 1 / system.base.voltage.prefix
    @inbounds for i = 1:system.bus.number
        voltmeter.label[replace(default.label, r"\?" => string(i))] = i

        voltmeter.magnitude.variance[i] = topu(variance, default.variance, prefix.voltageMagnitude, prefixInv / system.base.voltage.value[i])
        voltmeter.magnitude.mean[i] = analysis.voltage.magnitude[i] + voltmeter.magnitude.variance[i]^(1/2) * randn(1)[1]
    end

    voltmeter.layout.label = system.bus.number
end

"""
    updateVoltmeter!(system::PowerSystem, device::Measurement, analysis::Analysis; kwargs...)

The function allows for the alteration of parameters for a voltmeter.

# Arguments
If the `Analysis` type is omitted, the function applies changes to the `Measurement` 
composite type only. However, when including the `Analysis` type, it updates both the
`Measurement` and `Analysis` types. This streamlined process avoids the need to completely
rebuild vectors and matrices when adjusting these parameters.

# Keywords
To update a specific voltmeter, provide the necessary `kwargs` input arguments in 
accordance with the keywords specified in the [`addVoltmeter!`](@ref addVoltmeter!)
function, along with their respective values. Ensure that the `label` keyword matches the
`label` of the existing voltmeter you want to modify. If any keywords are omitted, their
corresponding values will remain unchanged.

# Updates
The function updates the `voltmeter` field within the `Measurement` composite type.
Furthermore, it guarantees that any modifications to the parameters are transmitted to the
`Analysis` type.

# Units
Units for input parameters can be changed using the same method as described for the
[`addVoltmeter!`](@ref addVoltmeter!) function.

# Example
```jldoctest
system = powerSystem()
device = measurement()

addBus!(system; label = "Bus 1", base = 132e3)

addVoltmeter!(system, device; label = "Voltmeter 1", bus = "Bus 1", magnitude = 1.1)
updateVoltmeter!(system, device; label = "Voltmeter 1", magnitude = 0.9, noise = false)
```
"""
function updateVoltmeter!(system::PowerSystem, device::Measurement; label::L,
    magnitude::T = missing, variance::T = missing, status::T = missing,
    noise::Bool = template.voltmeter.noise)

    voltmeter = device.voltmeter

    index = voltmeter.label[getLabel(voltmeter, label, "voltmeter")]
    indexBus = voltmeter.layout.index[index]

    baseVoltageInv = 1 / (system.base.voltage.value[indexBus] * system.base.voltage.prefix)

    updateMeter(voltmeter.magnitude, index, magnitude, variance, status, noise,
        prefix.voltageMagnitude, baseVoltageInv)
end

"""
    @voltmeter(label, variance, status, noise)

The macro generates a template for a voltmeter, which can be utilized to define a voltmeter
using the [`addVoltmeter!`](@ref addVoltmeter!) function.

# Keywords
To establish the voltmeter template, users can specify default values for the `variance`,
`status`, and `noise` keywords, along with pattern for labels using the `label` keyword.

# Units
By default, the unit for `variance` is per-unit (pu). However, users can choose to use
volts (V) as the units by applying the [`@voltage`](@ref @voltage) macro.

# Examples
Adding a voltmeter using the default unit system:
```jldoctest
system = powerSystem()
device = measurement()

addBus!(system; label = "Bus 1", base = 132e3)

@voltmeter(label = "Voltmeter ?", variance = 1e-5, noise = false)
addVoltmeter!(system, device; bus = "Bus 1", magnitude = 1.1)
```

Adding a voltmeter using a custom unit system:
```jldoctest
@voltage(kV, rad, kV)
system = powerSystem()
device = measurement()

addBus!(system; label = "Bus 1", base = 132.0)

@voltmeter(label = "Voltmeter ?", variance = 0.00132, noise = false)
addVoltmeter!(system, device; bus = "Bus 1", magnitude = 145.2)
```
"""
macro voltmeter(kwargs...)
    for kwarg in kwargs
        parameter::Symbol = kwarg.args[1]

        if hasfield(VoltmeterTemplate, parameter)
            if parameter == :variance
                container::ContainerTemplate = getfield(template.voltmeter, parameter)
                if prefix.voltageMagnitude != 0.0
                    setfield!(container, :value, prefix.voltageMagnitude * Float64(eval(kwarg.args[2])))
                    setfield!(container, :pu, false)
                else
                    setfield!(container, :value, Float64(eval(kwarg.args[2])))
                    setfield!(container, :pu, true)
                end
            elseif parameter == :status
                setfield!(template.voltmeter, parameter, Int8(eval(kwarg.args[2])))
            elseif parameter == :noise
                setfield!(template.voltmeter, parameter, Bool(eval(kwarg.args[2])))
            elseif parameter == :label
                label = string(kwarg.args[2])
                if contains(label, "?")
                    setfield!(template.voltmeter, parameter, label)
                else
                    throw(ErrorException("The label template lacks the '?' symbol to indicate integer placement."))
                end
            end
        else
            throw(ErrorException("The keyword $(parameter) is illegal."))
        end
    end
end