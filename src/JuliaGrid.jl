module JuliaGrid

export runpf
export runmg
export runse

using SparseArrays, LinearAlgebra, SuiteSparse
using PrettyTables, Printf
using HDF5, CSV, XLSX
using Random
using JuMP, GLPK, Ipopt
using LightGraphs


### Includes
include("system/input.jl")
include("system/routine.jl")
include("system/results.jl")
include("system/headers.jl")

include("flow/flowdc.jl")
include("flow/flowac.jl")
include("flow/flowalgorithms.jl")
include("flow/measurements.jl")

include("estimation/estimationdc.jl")


### Power Flow
function runpf(
    args...;
    max::Int64 = 100,
    stop::Float64 = 1.0e-8,
    reactive::Int64 = 0,
    solve::String = "",
    save::String = "",
)
    path = loadpath(args)
    system, num, info = loadsystem(path)
    settings = pfsettings(args, max, stop, reactive, solve, save, system, num)

    if settings.algorithm == "dc"
        results = rundcpf(system, num, settings, info)
    else
        results = runacpf(system, num, settings, info)
    end

    return results, system, info
end


### Measurement Generator
function runmg(
    args...;
    runflow::Int64 = 1,
    max::Int64 = 100,
    stop::Float64 = 1.0e-8,
    reactive::Int64 = 0,
    solve::String = "",
    save::String = "",
    pmuset = [],
    pmuvariance = [],
    legacyset = [],
    legacyvariance = [],
)

    path = loadpath(args)
    system, numsys, info = loadsystem(path)
    measurements, num = loadmeasurement(path, system, numsys, pmuvariance, legacyvariance; runflow = runflow)
    settings = gesettings(num, pmuset, pmuvariance, legacyset, legacyvariance; runflow = runflow, save = save)

    if settings.runflow == 1
        pfsettings = gepfsettings(max, stop, reactive, solve)
        acflow = runacpf(system, numsys, pfsettings, info)
        info = rungenerator(system, measurements, num, numsys, settings, info; flow = acflow)
    else
        info = rungenerator(system, measurements, num, numsys, settings, info)
    end

    return measurements, system, info
end

### State Estimation
function runse(
    args...;
    max::Int64 = 100,
    stop::Float64 = 1.0e-8,
    start::String = "flat",
    bad = [],
    lav = [],
    observe = [],
    solve::String = "",
    save::String = "",
    pmuset = [],
    pmuvariance = [],
    legacyset = [],
    legacyvariance = [],
)

    path = loadpath(args)
    system, numsys, info = loadsystem(path)
    measurements, num = loadmeasurement(path, system, numsys, pmuvariance, legacyvariance)
    settings = sesettings(args, system, max, stop, start, bad, lav, observe, solve, save)

    gensettings = gesettings(num, pmuset, pmuvariance, legacyset, legacyvariance)
    info = rungenerator(system, measurements, num, numsys, gensettings, info)

    results = rundcse(system, measurements, num, numsys, settings, info)

    return results, measurements, system, info
end

end # JuliaGrid
