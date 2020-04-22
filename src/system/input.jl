######################
#  Struct Variables  #
######################
struct PowerSystem
    bus::Array{Float64,2}
    generator::Array{Float64,2}
    isgenerator::Bool
    branch::Array{Float64,2}
    baseMVA::Float64
    info::Union{Array{String,1}, Array{String,2}}
    package::String
    path::String
    data::String
    extension::String
end

struct FlowSettings
    algorithm::String
    solve::String
    main::Bool
    flow::Bool
    generator::Bool
    save::String
    maxIter::Int64
    stopping::Float64
    reactive::Array{Bool,1}
end

struct GeneratorSettings
    algorithm::String
    solve::String
    main::Bool
    flow::Bool
    generator::Bool
    save::String
    path::String
    runflow::Int64
    maxIter::Int64
    stopping::Float64
    reactive::Array{Bool,1}
    set::Dict{String, Union{Array{Any,1}, Any}}
    variance::Dict{String, Union{Array{Any,1}, Any}}
end

struct StateEstimation
    pmuCurrent::Array{Float64,2}
    pmuVoltage::Array{Float64,2}
    legacyFlow::Array{Float64,2}
    legacyCurrent::Array{Float64,2}
    legacyInjection::Array{Float64,2}
    legacyVoltage::Array{Float64,2}
    type::Array{String,1}
end

struct EstimationSettings
    algorithm::String
end


############################
#  Load power system data  #
############################
function loadsystem(args)
    package_dir = abspath(joinpath(dirname(Base.find_package("JuliaGrid")), ".."))
    isgenerator = true
    extension = ""
    path = ""
    data = ""
    fullpath = ""
    for i = 1:length(args)
        try
            extension = match(r"\.[A-Za-z0-9]+$", args[i]).match
            if extension == ".h5" || extension == ".xlsx"
                fullpath = args[i]
                path = dirname(args[i])
                data = basename(args[i])
                break
            end
        catch
        end
    end
    if isempty(extension)
       error("The input data format is not supported.")
    end

    if path == ""
        path = joinpath(package_dir, "src/data/")
        fullpath = joinpath(package_dir, "src/data/", data)
    end

    input_data = cd(readdir, path)
    if any(input_data .== data)
        println(string("  Input Power System: ", data))
    else
        error("The input power system data is not found.")
    end

    read_data = readdata(fullpath, extension; type = "pf")

    if !any(keys(read_data) .== "bus")
        error("Invalid power flow data structure, variable 'bus' not found.")
    end
    if !any(keys(read_data) .== "branch")
        error("Invalid power flow data structure, variable 'branch' not found.")
    end

    bus = Array{Float64}(undef, 0, 0)
    generator = Array{Float64}(undef, 0, 0)
    branch = Array{Float64}(undef, 0, 0)
    baseMVA = 0.0
    info = Array{String}(undef, 0)

    for i in keys(read_data)
        if i == "bus"
           bus = read_data[i]
        end
        if i == "generator"
            generator = read_data[i]
        end
        if i == "branch"
            branch = read_data[i]
        end
        if i == "basePower"
            baseMVA = read_data[i][1]
        end
        if i == "info"
            info = read_data[i]
        end
    end

    if length(generator) == 0
        generator = zeros(1, 21)
        isgenerator = false
    end

    if baseMVA == 0
        baseMVA = 100.0
        @info("The variable 'basePower' not found. The algorithm proceeds with default value: 100 MVA")
    end

    return PowerSystem(bus, generator, isgenerator, branch, baseMVA, info, package_dir, fullpath, data, extension)
end


###############################
#  Set power system settings  #
###############################
function pfsettings(args, max, stop, react, solve, save, system)
    algorithm = "false"
    algorithm_type = ["nr", "gs", "fnrxb", "fnrbx", "dc"]
    main = false
    flow = false
    generator = false
    reactive = [false; true; false]

    for i = 1:length(args)
        if any(algorithm_type .== args[i])
            algorithm = args[i]
        end
        if args[i] == "main"
            main = true
        end
        if args[i] == "flow"
            flow = true
        end
        if args[i] == "generator" && system.isgenerator
            generator = true
        end
    end

    if react == 1 && system.isgenerator
        reactive = [true; true; false]
    end

    if algorithm == "false"
        algorithm = "nr"
        @info("Invalid power flow METHOD key. The algorithm proceeds with the AC power flow.")
    end

    if !isempty(save)
        path = dirname(save)
        data = basename(save)
        if isempty(data)
            data = string("new_juliagrid", system.extension)
        end
        save = joinpath(path, data)
    end

    return FlowSettings(algorithm, solve, main, flow, generator, save, max, stop, reactive)
end


###########################
#  Load measurement data  #
###########################
function loadmeasurement(system, runflow)
    Nbus = size(system.bus, 1)
    Nbranch = size(system.branch, 1)
    Ngen = size(system.generator, 1)

    if runflow == 1
        measurement = Dict()
        push!(measurement, "pmuVoltage" => fill(0.0, Nbus, 9))
        push!(measurement, "pmuCurrent" => fill(0.0, 2 * Nbranch, 11))
        push!(measurement, "legacyFlow" => fill(0.0, 2 * Nbranch, 11))
        push!(measurement, "legacyCurrent" => fill(0.0, 2 * Nbranch, 7))
        push!(measurement, "legacyInjection" => fill(0.0, Nbus, 9))
        push!(measurement, "legacyVoltage" => fill(0.0, Nbus, 5))
    else
        measurement = readdata(system.path, system.extension; type = "se")
    end

    return measurement
end


########################################
#  Set measurement generator settings  #
########################################
function gesettings(runflow, max, stop, react, solve, save, pmuset, pmuvariance, legacyset, legacyvariance, measurement)
    savepf = ""
    algorithm = "nr"
    main = false
    flow = false
    generator = false

    reactive = [false; true; false]
    if react == 1
        reactive = [true; true; false]
    end

    names = keys(measurement)
    set = Dict{String, Union{Array{Any,1}, Any}}()
    variance = Dict{String, Union{Array{Any,1}, Any}}()

    ################## PMU Set ##################
    if !isa(pmuset, Array)
        pmuset = [pmuset]
    end

    onebyone = false
    for i in pmuset
        if any(i .== ["Vi", "Ti", "Iij", "Dij"])
            onebyone = true
            break
        end
    end
    if onebyone
        for i in pmuset
            if any(i .== ["Vi", "Ti"]) && any(names .== "pmuVoltage")
                push!(set, "pmuVoltage" => convert(Array{Any}, ["no"; "no"]))
            end
            if any(i .== ["Iij", "Dij"]) && any(names .== "pmuCurrent")
                push!(set, "pmuCurrent" => convert(Array{Any}, ["no"; "no"]))
            end
        end
        for (k, i) in enumerate(pmuset)
            if i == "Vi" && any(names .== "pmuVoltage")
                set["pmuVoltage"][1] = nextelement(pmuset, k)
            end
            if i == "Ti" && any(names .== "pmuVoltage")
                set["pmuVoltage"][2] = nextelement(pmuset, k)
            end
            if i == "Iij" && any(names .== "pmuCurrent")
                set["pmuCurrent"][1] = nextelement(pmuset, k)
            end
            if i == "Dij" && any(names .== "pmuCurrent")
                set["pmuCurrent"][2] = nextelement(pmuset, k)
            end
        end
    end
    if !onebyone && any(names .== ["pmuVoltage" "pmuCurrent"])
        for (k, i) in enumerate(pmuset)
            if any(i .== ["redundancy" "device"])
                push!(set, string("pmu", i) => nextelement(pmuset, k))
                break
            end
            if any(i .== ["all" "optimal"])
                push!(set, string("pmu", i) => i)
                break
            end
        end
    end

    ################## Legacy Set ##################
    if !isa(legacyset, Array)
        legacyset = [legacyset]
    end

    onebyone = false
    for i in legacyset
        if any(i .== ["Pij", "Qij", "Iij", "Pi", "Qi", "Vi"])
            onebyone = true
            break
        end
    end
    if onebyone
        for i in legacyset
            if any(i .== ["Pij", "Qij"]) && any(names .== "legacyFlow")
                push!(set, "legacyFlow" => convert(Array{Any}, ["no"; "no"]))
            end
            if i .== "Iij" && any(names .== "legacyCurrent")
                push!(set, "legacyCurrent" => convert(Any, "no"))
            end
            if any(i .== ["Pi", "Qi"]) && any(names .== "legacyInjection")
                push!(set, "legacyInjection" => convert(Array{Any}, ["no"; "no"]))
            end
            if i .== "Vi" && any(names .== "legacyVoltage")
                push!(set, "legacyVoltage" => convert(Any, "no"))
            end
        end
        for (k, i) in enumerate(legacyset)
            if i == "Pij" && any(names .== "legacyFlow")
                set["legacyFlow"][1] = nextelement(legacyset, k)
            end
            if i == "Qij" && any(names .== "legacyFlow")
                set["legacyFlow"][2] = nextelement(legacyset, k)
            end
            if i == "Iij" && any(names .== "legacyCurrent")
                set["legacyCurrent"][1] = nextelement(legacyset, k)
            end
            if i == "Pi" && any(names .== "legacyInjection")
                set["legacyInjection"][1] = nextelement(legacyset, k)
            end
            if i == "Qi" && any(names .== "legacyInjection")
                set["legacyInjection"][2] = nextelement(legacyset, k)
            end
            if i == "Vi" && any(names .== "legacyVoltage")
                set["legacyVoltage"][1] = nextelement(legacyset, k)
            end
        end
    end
    if !onebyone && any(names .== ["legacyFlow" "legacyCurrent" "legacyInjection" "legacyVoltage"])
        for (k, i) in enumerate(legacyset)
            if i == "redundancy"
                push!(set, string("legacy", i) => nextelement(legacyset, k))
                break
            end
            if i == "all"
                push!(set, string("legacy", i) => i)
                break
            end
        end
    end

    ################## PMU Variance ##################
    onebyone = false
    all = false
    for i in pmuvariance
        if any(i .== ["Vi", "Ti", "Iij", "Dij"])
            onebyone = true
        end
        if i == "all"
            all = true
        end
    end
    if all && onebyone
        valall = 0.0
        for (k, i) in enumerate(pmuvariance)
            if i == "all"
                valall = nextelement(pmuvariance, k)
            end
        end
        miss = setdiff(["Vi", "Ti", "Iij", "Dij"], pmuvariance)
        for i in miss
            pmuvariance = [pmuvariance i valall]
        end
    end
    if onebyone
        for i in pmuvariance
            if any(i .== ["Vi", "Ti"]) && any(names .== "pmuVoltage")
                push!(variance, "pmuVoltage" => convert(Array{Any}, ["no"; "no"]))
            end
            if any(i .== ["Iij", "Dij"]) && any(names .== "pmuCurrent")
                push!(variance, "pmuCurrent" => convert(Array{Any}, ["no"; "no"]))
            end
        end
        for (k, i) in enumerate(pmuvariance)
            if i == "Vi" && any(names .== "pmuVoltage")
                variance["pmuVoltage"][1] = nextelement(pmuvariance, k)
            end
            if i == "Ti" && any(names .== "pmuVoltage")
                variance["pmuVoltage"][2] = nextelement(pmuvariance, k)
            end
            if i == "Iij" && any(names .== "pmuCurrent")
                variance["pmuCurrent"][1] = nextelement(pmuvariance, k)
            end
            if i == "Dij" && any(names .== "pmuCurrent")
                variance["pmuCurrent"][2] = nextelement(pmuvariance, k)
            end
        end
    end
    if !onebyone && any(names .== ["pmuVoltage" "pmuCurrent"])
        for (k, i) in enumerate(pmuvariance)
            if i == "random"
                push!(variance, string("pmu", i) => [nextelement(pmuvariance, k); nextelement(pmuvariance, k + 1)])
                break
            end
            if i == "all"
                push!(variance, string("pmu", i) => nextelement(pmuvariance, k))
                break
            end
        end
    end

    ################## Legacy Variance ##################
    onebyone = false
    all = false
    for i in legacyvariance
        if any(i .== ["Pij", "Qij", "Iij", "Pi", "Qi", "Vi"])
            onebyone = true
        end
        if i == "all"
            all = true
        end
    end
    if all && onebyone
        valall = 0.0
        for (k, i) in enumerate(legacyvariance)
            if i == "all"
                valall = nextelement(legacyvariance, k)
            end
        end
        miss = setdiff(["Pij", "Qij", "Iij", "Pi", "Qi", "Vi"], legacyvariance)
        for i in miss
            pmuvariance = [legacyvariance i valall]
        end
    end
    if onebyone
        for i in legacyvariance
            if any(i .== ["Pij", "Qij"]) && any(names .== "legacyFlow")
                push!(variance, "legacyFlow" => convert(Array{Any}, ["no"; "no"]))
            end
            if i .== "Iij" && any(names .== "legacyCurrent")
                push!(variance, "legacyCurrent" => convert(Any, "no"))
            end
            if any(i .== ["Pi", "Qi"]) && any(names .== "legacyInjection")
                push!(variance, "legacyInjection" => convert(Array{Any}, ["no"; "no"]))
            end
            if i .== "Vi" && any(names .== "legacyVoltage")
                push!(variance, "legacyVoltage" => convert(Any, "no"))
            end
        end
        for (k, i) in enumerate(legacyvariance)
            if i == "Pij" && any(names .== "legacyFlow")
                variance["legacyFlow"][1] = nextelement(legacyvariance, k)
            end
            if i == "Qij" && any(names .== "legacyFlow")
                variance["legacyFlow"][2] = nextelement(legacyvariance, k)
            end
            if i == "Iij" && any(names .== "legacyCurrent")
                variance["legacyCurrent"][1] = nextelement(legacyvariance, k)
            end
            if i == "Pi" && any(names .== "legacyInjection")
                variance["legacyInjection"][1] = nextelement(legacyvariance, k)
            end
            if i == "Qi" && any(names .== "legacyInjection")
                variance["legacyInjection"][2] = nextelement(legacyvariance, k)
            end
            if i == "Vi" && any(names .== "legacyVoltage")
                variance["legacyVoltage"][1] = nextelement(legacyvariance, k)
            end
        end
    end
    if !onebyone  && any(names .== ["legacyFlow" "legacyCurrent" "legacyInjection" "legacyVoltage"])
        for (k, i) in enumerate(legacyvariance)
            if i == "random"
                push!(variance, string("legacy", i) =>  [nextelement(legacyvariance, k); nextelement(legacyvariance, k + 1)])
                break
            end
            if i == "all"
                push!(variance, string("legacy", i) => nextelement(legacyvariance, k))
                break
            end
        end
    end

    return GeneratorSettings(algorithm, solve, main, flow, generator, savepf, save, runflow, max, stop, reactive, set, variance)
end


###########################
#  Load measurement data  #
###########################
function loadmeasurement(system)
    read_data = readdata(system.path, system.extension; type = "se")

    pmuCurrent = Array{Float64}(undef, 0, 0)
    pmuVoltage = Array{Float64}(undef, 0, 0)
    legacyFlow = Array{Float64}(undef, 0, 0)
    legacyCurrent = Array{Float64}(undef, 0, 0)
    legacyInjection = Array{Float64}(undef, 0, 0)
    legacyVoltage = Array{Float64}(undef, 0, 0)
    type = convert(Array{String,1}, keys(read_data))
    display(type)
    for i in keys(read_data)
        if i == "pmuVoltage"
            pmuVoltage = read_data[i]
        end
        if i == "pmuCurrent"
            pmuCurrent = read_data[i]
        end
        if i == "legacyFlow"
            legacyFlow = read_data[i]
        end
        if i == "legacyCurrent"
            legacyCurrent = read_data[i]
        end
        if i == "legacyInjection"
            legacyInjection = read_data[i]
        end
        if i == "legacyVoltage"
            legacyVoltage = read_data[i]
        end
    end

    return StateEstimation(pmuCurrent, pmuVoltage, legacyFlow, legacyCurrent, legacyInjection, legacyVoltage, type)
end


###################################
#  Set state estimation settings  #
###################################
function sesettings(ARGS, MAX, STOP, SOLVE)
    algorithm = "false"
    algorithm_type = ["dc", "nonlinear"]

    for i = 1:length(ARGS)
        if any(algorithm_type .== ARGS[i])
            algorithm = ARGS[i]
        end
    end

    if algorithm == "false"
        algorithm = "nonlinear"
        @info("Invalid power flow algorithm key. The algorithm proceeds with the nonlinear state estimation.")
    end

    return EstimationSettings(algorithm)
end
