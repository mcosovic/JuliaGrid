"""
    @base(system::PowerSystem, power, voltage)

By default, the units for base power and base voltages are set to volt-ampere (VA) and volt
(V), but you can modify the prefixes using the macro.

Prefixes must be specified according to the [SI prefixes](https://www.nist.gov/pml/owm/metric-si-prefixes)
and should be included with the unit of `power` (VA) or unit of `voltage` (V). Keep in mind
that the macro must be used after creating the composite type `PowerSystem`.

# Example
```jldoctest
system = powerSystem("case14.h5")
@base(system, MVA, kV)
```
"""
macro base(system::Symbol, power::Symbol, voltage::Symbol)
    powerString = string(power)
    suffixPower = parseSuffix(powerString, suffixList.basePower)
    prefixPower = parsePrefix(powerString, suffixPower)

    voltageString = string(voltage)
    suffixVoltage = parseSuffix(voltageString, suffixList.baseVoltage)
    prefixVoltage = parsePrefix(voltageString, suffixVoltage)

    return quote
        system = $(esc(system))

        prefixOld = system.base.power.prefix
        system.base.power.value = system.base.power.value * prefixOld / $prefixPower
        system.base.power.prefix = $prefixPower
        system.base.power.unit = $powerString

        prefixOld = system.base.voltage.prefix
        system.base.voltage.value = system.base.voltage.value * prefixOld / $prefixVoltage
        system.base.voltage.prefix = $prefixVoltage
        system.base.voltage.unit = $voltageString
    end
end

"""
    @power(active, reactive, apparent)

JuliaGrid stores all data related with powers in per-units, and these cannot be altered.
However, the power units of the built-in functions used to add or modified power system
elements can be modified using the macro.

Prefixes must be specified according to the
[SI prefixes](https://www.nist.gov/pml/owm/metric-si-prefixes) and should be included with
the unit of `active` power (W), `reactive` power (VAr), or `apparent` power (VA). Also it
is a possible to combine SI units with/without prefixes with per-units (pu).

Changing the unit of active power is reflected in the following quantities:
* [`addBus!`](@ref addBus!): `active`, `conductance`,
* [`shuntBus!`](@ref shuntBus!): `conductance`,
* [`addGenerator!`](@ref addGenerator!): `active`, `minActive`, `maxActive`, `lowActive`, `upActive`, `loadFollowing`, `reserve10min`, `reserve30min`,
* [`addActiveCost!`](@ref addActiveCost!): `piecewise`, `polynomial`,
* [`outputGenerator!`](@ref outputGenerator!): `active`,
* [`addBranch!`](@ref addBranch!): `longTerm`, `shortTerm`, `emergency` if rating `type = 2`.

Changing the unit of reactive power unit is reflected in the following quantities:
* [`addBus!`](@ref addBus!): `reactive`, `susceptance`,
* [`shuntBus!`](@ref shuntBus!): `susceptance`,
* [`addGenerator!`](@ref addGenerator!): `reactive`, `minReactive`, `maxReactive`, `minLowReactive`, `maxLowReactive`, `minUpReactive`, `maxUpReactive`, `reactiveTimescale`,
* [`addReactiveCost!`](@ref addReactiveCost!): `piecewise`, `polynomial`,
* [`outputGenerator!`](@ref outputGenerator!): `reactive`.

Changing the unit of apparent power unit is reflected in the following quantities:
* [`addBranch!`](@ref addBranch!): `longTerm`, `shortTerm`, `emergency` if rating `type = 1` or `type = 3`.

# Example
```jldoctest
@power(MW, kVAr, VA)
```
"""
macro power(active::Symbol, reactive::Symbol, apparent::Symbol)
    activeString = string(active)
    suffixUser = parseSuffix(activeString, suffixList.activePower)
    prefix.activePower = parsePrefix(activeString, suffixUser)

    reactiveString = string(reactive)
    suffixUser = parseSuffix(reactiveString, suffixList.reactivePower)
    prefix.reactivePower = parsePrefix(reactiveString, suffixUser)

    apparentString = string(apparent)
    suffixUser = parseSuffix(apparentString, suffixList.apparentPower)
    prefix.apparentPower = parsePrefix(apparentString, suffixUser)
end

"""
    @voltage(magnitude, angle, base)

JuliaGrid stores all data related with voltages in per-units and radians, and these cannot
be altered. However, the voltage magnitude and angle units of the built-in functions used
to add or modified power system elements can be modified using the macro.

The prefixes must adhere to the [SI prefixes](https://www.nist.gov/pml/owm/metric-si-prefixes)
and should be specified along with the unit of voltage, either `magnitude` (V) or `base` (V).
Alternatively, the unit of voltage `magnitude` can be expressed in per-unit (pu). The unit of
voltage angle should be in radians (rad) or degrees (deg).

Changing the unit of voltage magnitude is reflected in the following quantities:
* [`addBus!`](@ref addBus!): `magnitude`, `minMagnitude`, `maxMagnitude`,
* [`addGenerator!`](@ref addGenerator!): `magnitude`.

Changing the unit of voltage angle is reflected in the following quantities:
* [`addBus!`](@ref addBus!): `angle`,
* [`addBranch!`](@ref addBranch!): `shiftAngle`, `minDiffAngle`, `maxDiffAngle`,
* [`parameterBranch!`](@ref parameterBranch!): `shiftAngle`.

Changing the unit prefix of voltage base is reflected in the following quantity:
* [`addBus!`](@ref addBus!): `base`.

# Example
```jldoctest
@voltage(pu, deg, kV)
```
"""
macro voltage(magnitude::Symbol, angle::Symbol, base::Symbol)
    magnitudeString = string(magnitude)
    suffixUser = parseSuffix(magnitudeString, suffixList.voltageMagnitude)
    prefix.voltageMagnitude = parsePrefix(magnitudeString, suffixUser)

    angleString = string(angle)
    suffixUser = parseSuffix(angleString, suffixList.voltageAngle)
    prefix.voltageAngle = parsePrefix(angleString, suffixUser)

    baseString = string(base)
    suffixUser = parseSuffix(baseString, suffixList.baseVoltage)
    prefix.baseVoltage = parsePrefix(baseString, suffixUser)
end

"""
    @current(magnitude, angle)

JuliaGrid stores all data related with currents in per-units and radians, and these cannot
be altered. However, the current magnitude and angle units of the built-in functions used
to add or modified measurement devices can be modified using the macro.

The prefixes must adhere to the [SI prefixes](https://www.nist.gov/pml/owm/metric-si-prefixes)
and should be specified along with the unit of current `magnitude` (V).
Alternatively, the unit of current `magnitude` can be expressed in per-unit (pu). The unit
of current angle should be in radians (rad) or degrees (deg).

Changing the unit of current magnitude is reflected in the following quantities:
* [`addAmmeter!`](@ref addAmmeter!): `mean`, `exact`, `variance`.

# Example
```jldoctest
@current(pu, deg)
```
"""
macro current(magnitude::Symbol, angle::Symbol)
    magnitudeString = string(magnitude)
    suffixUser = parseSuffix(magnitudeString, suffixList.currentMagnitude)
    prefix.currentMagnitude = parsePrefix(magnitudeString, suffixUser)

    angleString = string(angle)
    suffixUser = parseSuffix(angleString, suffixList.currentAngle)
    prefix.currentAngle = parsePrefix(angleString, suffixUser)
end

"""
    @parameter(impedance, admittance)

JuliaGrid stores all data related with impedances and admittancies in per-units, and these
cannot be altered. However, units of impedance and admittance of the built-in functions
used to add or modified power system elements can be modified using the macro.

Prefixes must be specified according to the
[SI prefixes](https://www.nist.gov/pml/owm/metric-si-prefixes) and should be
included with the unit of `impedance` (Ω) or unit of `admittance` (S). The second option
is to define the units in per-unit (pu).

In the case where impedance and admittance are being used in SI units (Ω and S) and these
units are related to the transformer, the assignment must be based on the primary side of
the transformer.

Changing the units of impedance is reflected in the following quantities in specific
functions:
* [`addBranch!`](@ref addBranch!): `resistance`, `reactance`,
* [`parameterBranch!`](@ref parameterBranch!): `resistance`, `reactance`.

Changing the units of admittance is reflected in the following quantities:
* [`addBranch!`](@ref addBranch!): `susceptance`,
* [`parameterBranch!`](@ref parameterBranch!): `susceptance`.

# Example
```jldoctest
@parameter(Ω, pu)
```
"""
macro parameter(impedance::Symbol, admittance::Symbol)
    impedanceString = string(impedance)
    suffixUser = parseSuffix(impedanceString, suffixList.impedance)
    prefix.impedance = parsePrefix(impedanceString, suffixUser)

    admittanceString = string(admittance)
    suffixUser = parseSuffix(admittanceString, suffixList.admittance)
    prefix.admittance = parsePrefix(admittanceString, suffixUser)
end

######### Parse Suffix (Unit) ##########
function parseSuffix(input::String, suffixList)
    sufixUser = ""
    @inbounds for i in suffixList
        if endswith(input, i)
            sufixUser = i
        end
    end
    if isempty(sufixUser) || (sufixUser in ["pu"; "rad"; "deg"] && sufixUser != input)
        error("The unit $input of $type is illegal.")
    end

    return sufixUser
end

######### Parse Prefix ##########
function parsePrefix(input::String, suffixUser::String)
    if suffixUser == "pu"
        scale = 0.0
    elseif suffixUser == "deg"
        scale = pi / 180
    else
        scale = 1.0
        if suffixUser != input
            prefixUser = split(input, suffixUser)[1]
            if !(prefixUser in keys(prefixList))
                error("The unit prefix $prefixUser is illegal.")
            else
                scale = prefixList[prefixUser]
            end
        end
    end

    return scale
end

"""
The macro is designed to reset various settings to their default values.

    @default(mode)

The `mode` argument can take on the following values:
* `unit`: resets all units to their default settings
* `power`: sets active, reactive, and apparent power to per-units
* `voltage`: sets voltage magnitude to per-unit and voltage angle to radian
* `parameter`: sets impedance and admittance to per-units
* `template`: resets bus, branch and generator templates to their default settings
* `bus`: resets the bus template to its default settings
* `branch`: resets the branch template to its default settings
* `generator`: resets the generator template to its default settings.

# Example
```jldoctest
@default(unit)
```
"""
macro default(mode::Symbol)
    if mode == :unit || mode == :power
        prefix.activePower = 0.0
        prefix.reactivePower = 0.0
        prefix.apparentPower = 0.0
    end

    if mode == :unit || mode == :voltage
        prefix.voltageMagnitude = 0.0
        prefix.voltageAngle = 1.0
        prefix.baseVoltage = 1.0
    end

    if mode == :unit || mode == :current
        prefix.currentMagnitude = 0.0
        prefix.currentAngle = 1.0
    end

    if mode == :unit || mode == :parameter
        prefix.impedance = 0.0
        prefix.admittance = 0.0
    end

    if mode == :template || mode == :bus
        template.bus.active.value = 0.0
        template.bus.active.pu = true
        template.bus.reactive.value = 0.0
        template.bus.reactive.pu = true

        template.bus.conductance.value = 0.0
        template.bus.conductance.pu = true
        template.bus.susceptance.value = 0.0
        template.bus.susceptance.pu = true

        template.bus.magnitude.value = 1.0
        template.bus.magnitude.pu = true
        template.bus.minMagnitude.value = 0.0
        template.bus.minMagnitude.pu = true
        template.bus.maxMagnitude.value = 0.0
        template.bus.maxMagnitude.pu = true

        template.bus.base = 138e3
        template.bus.angle = 0.0
        template.bus.type = Int8(1)
        template.bus.area = 1
        template.bus.lossZone = 1
    end

    if mode == :template || mode == :branch
        template.branch.resistance.value = 0.0
        template.branch.resistance.pu = true
        template.branch.reactance.value = 0.0
        template.branch.reactance.pu = true
        template.branch.conductance.value = 0.0
        template.branch.conductance.pu = true
        template.branch.susceptance.value = 0.0
        template.branch.susceptance.pu = true

        template.branch.longTerm.value = 0.0
        template.branch.longTerm.pu = true
        template.branch.shortTerm.value = 0.0
        template.branch.shortTerm.pu = true
        template.branch.emergency.value = 0.0
        template.branch.emergency.pu = true

        template.branch.turnsRatio = 1.0
        template.branch.shiftAngle = 0.0
        template.branch.minDiffAngle = 0.0
        template.branch.maxDiffAngle = 0.0
        template.branch.status = Int8(1)
        template.branch.type = Int8(1)
    end

    if mode == :template || mode == :generator
        template.generator.active.value = 0.0
        template.generator.active.pu = true
        template.generator.reactive.value = 0.0
        template.generator.reactive.pu = true
        
        template.generator.magnitude.value = 1.0
        template.generator.magnitude.pu = true

        template.generator.minActive.value = 0.0
        template.generator.minActive.pu = true
        template.generator.maxActive.value = 0.0
        template.generator.maxActive.pu = true
        template.generator.minReactive.value = 0.0
        template.generator.minReactive.pu = true
        template.generator.maxReactive.value = 0.0
        template.generator.maxReactive.pu = true

        template.generator.lowActive.value = 0.0
        template.generator.lowActive.pu = true
        template.generator.minLowReactive.value = 0.0
        template.generator.minLowReactive.pu = true
        template.generator.maxLowReactive.value = 0.0
        template.generator.maxLowReactive.pu = true

        template.generator.upActive.value = 0.0
        template.generator.upActive.pu = true
        template.generator.minUpReactive.value = 0.0
        template.generator.minUpReactive.pu = true
        template.generator.maxUpReactive.value = 0.0
        template.generator.maxUpReactive.pu = true

        template.generator.loadFollowing.value = 0.0
        template.generator.loadFollowing.pu = true
        template.generator.reactiveTimescale.value = 0.0
        template.generator.reactiveTimescale.pu = true
        template.generator.reserve10min.value = 0.0
        template.generator.reserve10min.pu = true
        template.generator.reserve30min.value = 0.0
        template.generator.reserve30min.pu = true

        template.generator.status = Int8(1)
        template.generator.area = 0
    end
end