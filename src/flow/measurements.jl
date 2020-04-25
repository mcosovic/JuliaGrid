###########################
#  Generate measurements  #
###########################
function rungenerator(system, settings, measurement; flow = 0)
    if settings.runflow == 1
        branch = flow["branch"]
        bus = flow["bus"]
        busi, Vi, Ti, Pinj, Qinj, branchi, fromi, toi, Pij, Qij, Pji, Qji, Iij, Dij, Iji, Dji = view_generator(bus, branch)

        for i = 1:system.Nbra
            measurement["legacyFlow"][i, 1] = branchi[i]
            measurement["legacyFlow"][i + system.Nbra, 1] = branchi[i]
            measurement["legacyFlow"][i, 2] = fromi[i]
            measurement["legacyFlow"][i + system.Nbra, 2] = toi[i]
            measurement["legacyFlow"][i, 3] = toi[i]
            measurement["legacyFlow"][i + system.Nbra, 3] = fromi[i]
            measurement["legacyFlow"][i, 10] = Pij[i] / system.baseMVA
            measurement["legacyFlow"][i + system.Nbra, 10] = Pji[i] / system.baseMVA
            measurement["legacyFlow"][i, 11] = Qij[i] / system.baseMVA
            measurement["legacyFlow"][i + system.Nbra, 11] = Qji[i] / system.baseMVA

            measurement["legacyCurrent"][i, 1] = branchi[i]
            measurement["legacyCurrent"][i + system.Nbra, 1] = branchi[i]
            measurement["legacyCurrent"][i, 2] = fromi[i]
            measurement["legacyCurrent"][i + system.Nbra, 2] = toi[i]
            measurement["legacyCurrent"][i, 3] = toi[i]
            measurement["legacyCurrent"][i + system.Nbra, 3] = fromi[i]
            measurement["legacyCurrent"][i, 7] = Iij[i]
            measurement["legacyCurrent"][i + system.Nbra, 7] = Iji[i]

            measurement["pmuCurrent"][i, 1] = branchi[i]
            measurement["pmuCurrent"][i + system.Nbra, 1] = branchi[i]
            measurement["pmuCurrent"][i, 2] = fromi[i]
            measurement["pmuCurrent"][i + system.Nbra, 2] = toi[i]
            measurement["pmuCurrent"][i, 3] = toi[i]
            measurement["pmuCurrent"][i + system.Nbra, 3] = fromi[i]
            measurement["pmuCurrent"][i, 10] = Iij[i]
            measurement["pmuCurrent"][i + system.Nbra, 10] = Iji[i]
            measurement["pmuCurrent"][i, 11] = Dij[i]
            measurement["pmuCurrent"][i + system.Nbra, 11] = Dji[i]
        end

        for i = 1:system.Nbus
            measurement["legacyInjection"][i, 1] = busi[i]
            measurement["legacyInjection"][i, 8] = Pinj[i] / system.baseMVA
            measurement["legacyInjection"][i, 9] = Qinj[i] / system.baseMVA

            measurement["legacyVoltage"][i, 1] = busi[i]
            measurement["legacyVoltage"][i, 5] = Vi[i]

            measurement["pmuVoltage"][i, 1] = busi[i]
            measurement["pmuVoltage"][i, 8] = Vi[i]
            measurement["pmuVoltage"][i, 9] = (pi / 180) * Ti[i]
        end
    end

    names = Dict("pmu" => [], "legacy" => [])
    for type in keys(measurement)
        if occursin("pmu", type)
            push!(names["pmu"], type)
        end
        if occursin("legacy", type)
            push!(names["legacy"], type)
        end
    end
    measurement = runset(system, settings, measurement, names)
    measurement = runvariance(system, settings, measurement, names)

    write = Dict("pmuVoltage" => [2 8 3; 5 9 6], "pmuCurrent" => [4 10 5; 7 11 8],
                "legacyFlow" => [4 10 5; 7 11 8], "legacyCurrent" => [4 7 5],
                "legacyInjection" => [2 8 3; 5 9 6], "legacyVoltage" => [2 5 3])
    for i in keys(measurement)
        for row in eachrow(write[i])
            dim = size(measurement[i], 1)
            measurement[i][:, row[1]] .= measurement[i][:, row[2]] .+ measurement[i][:, row[3]].^(1/2) .* randn!(zeros(dim))
        end
    end

    info = infogenerator(system, settings, measurement, names)
    push!(measurement, "info" => info)

    grid = readdata(system.path, system.extension, "power system")

    group = ["pmuVoltage"; "pmuCurrent"; "legacyFlow"; "legacyCurrent"; "legacyInjection"; "legacyVoltage"]
    for (k, i) in enumerate(group)
        if !any(i .== keys(measurement))
            deleteat!(group, k)
        end
    end

    if system.Ngen != 0
        group = [group; "bus"; "generator"; "branch"; "basePower"]
        push!(measurement, "generator" => grid["generator"])
    else
        group = [group; "bus"; "branch"; "basePower"]
    end

    push!(measurement, "bus" => grid["bus"])
    push!(measurement, "branch" => grid["branch"])
    push!(measurement, "basePower" => grid["basePower"])

    if !isempty(settings.path)
        header = h5read(joinpath(system.packagepath, "src/system/header.h5"), "/measurement")
        savedata(measurement; group = group, header = header, path = settings.path, info = info)
    end

    return measurement
end


##############################
#  Produce  measurement set  #
##############################
function runset(system, settings, measurement, names)
    write = Dict("pmuVoltage" => [4, 7], "pmuCurrent" => [6, 9],
                 "legacyFlow" => [6, 9], "legacyCurrent" => 6,
                 "legacyInjection" => [4, 7], "legacyVoltage" => 4)
    type = Dict("pmuall" => "pmu",  "legacyall" => "legacy", "pmuredundancy" => "pmu",  "legacyredundancy" => "legacy")

    for set in keys(settings.set)
        if set in ["pmuall" "legacyall"]
            for i in names[type[set]]
                measurement[i][:, write[i]] .= 1
            end
        end
        if set in ["pmuVoltage", "pmuCurrent", "legacyFlow", "legacyCurrent", "legacyInjection", "legacyVoltage"]
            for (pos, howMany) in enumerate(settings.set[set])
                success = false
                if isa(howMany, Number) && howMany <= size(measurement[set], 1)
                    success = true
                    measurement[set][:, write[set][pos]] .= 0
                    idxn = randperm(size(measurement[set], 1))
                    idx = idxn[1:trunc(Int, howMany)]
                    measurement[set][idx, write[set][pos]] .= 1
                elseif isa(howMany, Number) && howMany > size(measurement[set], 1) || howMany == "all"
                    success = true
                    measurement[set][:, write[set][pos]] .= 0
                    measurement[set][:, write[set][pos]] .= 1
                elseif !success && howMany != "no"
                    error("The name-value pair setting is incorect, deployment measurements according to types failed.")
                end
            end
        end
        if set in ["pmuredundancy" "legacyredundancy"]
            Nmax = 0
            for i in names[type[set]]
                Nmax += length(write[i]) * size(measurement[i], 1)
            end
            success = false
            howMany = settings.set[set]
            if isa(howMany, Number) && howMany <= Nmax / (2 * system.Nbus - 1)
                success = true
                idxn = randperm(Nmax)
                idx = idxn[1:trunc(Int, round((2 * system.Nbus - 1) * howMany))]
                total_set = fill(0, Nmax)
                total_set[idx] .= 1
            elseif isa(howMany, Number) && howMany > Nmax / (2 * system.Nbus - 1)
                success = true
                total_set = fill(1, Nmax)
            end
            if success
                start = 0
                last = 0
                for i in names[type[set]]
                    for k in write[i]
                        last += size(measurement[i], 1)
                        measurement[i][:, k] .= total_set[(start + 1):last]
                        start += size(measurement[i], 1)
                    end
                end
            else
                error("The name-value pair setting is incorect, deployment measurements according to redundancy failed.")
            end
        end
        if set == "pmudevice"
            if any(names["pmu"] .== "pmuVoltage") && any(names["pmu"]  .== "pmuCurrent")
                success = false
                howMany = settings.set[set]
                if isa(howMany, Number) && howMany <= size(measurement["pmuVoltage"], 1)
                    success = true
                    idxn = randperm(size(measurement["pmuVoltage"], 1))
                    idx = idxn[1:trunc(Int, howMany)]
                elseif isa(howMany, Number) && howMany > size(measurement["pmuVoltage"], 1) || howMany == "all"
                    success = true
                    idx = collect(1:size(measurement["pmuVoltage"], 1))
                end
                if success
                    measurement["pmuVoltage"][:, [4, 7]] .= 0
                    measurement["pmuCurrent"][:, [6, 9]] .= 0
                    labelVol = measurement["pmuVoltage"][:, 1]
                    labelCurr = measurement["pmuCurrent"][:, 2]
                    try
                        labelVol = measurement["pmuVoltage"][:, 10]
                        labelCurr = measurement["pmuCurrent"][:, 12]
                    catch
                    end
                    for i in idx
                        measurement["pmuVoltage"][i, 4] = 1
                        measurement["pmuVoltage"][i, 7] = 1
                        for j = 1:size(measurement["pmuCurrent"], 1)
                            if labelVol[i] == labelCurr[j]
                                measurement["pmuCurrent"][j, 6] = 1
                                measurement["pmuCurrent"][j, 9] = 1
                            end
                        end
                    end
                else
                    error("The name-value pair setting is incorect, deployment measurements according to device number failed.")
                end
            else
               error("The complete PMU measurement DATA is not found.")
           end
        end
        if set == "pmuoptimal"
            if any(names["pmu"] .== "pmuVoltage") && any(names["pmu"]  .== "pmuCurrent")
                Nvol = size(measurement["pmuVoltage"], 1)
                Ncurr = size(measurement["pmuCurrent"], 1)
                if Nvol == system.Nbus && Ncurr == 2 * system.Nbra
                    bus = collect(1:system.Nbus)
                    numbering = false
                    fromi = @view(system.branch[:, 2])
                    toi = @view(system.branch[:, 3])
                    busi = @view(system.bus[:, 4])
                    @inbounds for i = 1:system.Nbus
                        if bus[i] != busi[i]
                            numbering = true
                        end
                    end
                    from, to = numbering_branch(fromi, toi, busi, system.Nbra, system.Nbus, system.bus, numbering)

                    A = sparse([bus; from; to], [bus; to; from], fill(1, system.Nbus + 2 * system.Nbra), system.Nbus, system.Nbus)
                    f  = fill(1, system.Nbus);
                    lb = fill(0, system.Nbus);
                    ub = fill(1, system.Nbus);
                    model = Model(GLPK.Optimizer)

                    @variable(model, x[i = 1:system.Nbus], Int)
                    @constraint(model, lb .<= x .<= ub)
                    @constraint(model, -A * x .<= -f)
                    @objective(model, Min, sum(x))
                    optimize!(model)
                    x = JuMP.value.(x)
                    idx = findall(x->x == 1, x)

                    measurement["pmuVoltage"][:, [4, 7]] .= 0
                    measurement["pmuCurrent"][:, [6, 9]] .= 0
                    for i in idx
                        measurement["pmuVoltage"][i, 4] = 1
                        measurement["pmuVoltage"][i, 7] = 1
                        for j = 1:system.Nbra
                            if busi[i] == fromi[j]
                                measurement["pmuCurrent"][j, 6] = 1
                                measurement["pmuCurrent"][j, 9] = 1
                            end
                            if busi[i] == toi[j]
                                measurement["pmuCurrent"][j + system.Nbra, 6] = 1
                                measurement["pmuCurrent"][j + system.Nbra, 9] = 1
                            end
                        end
                    end
                else
                    error("The optimal algorithm requires the concordant number of buses and branches, and corresponding measurements.")
                end
            else
                error("The complete PMU measurement DATA is not found.")
            end
        end
    end

    return measurement
end


###################################
#  Produce measurement variances  #
###################################
function runvariance(system, settings, measurement, names)
    write = Dict("pmuVoltage" => [3, 6], "pmuCurrent" => [5, 8],
                 "legacyFlow" => [5, 8], "legacyCurrent" => 5,
                 "legacyInjection" => [3, 6], "legacyVoltage" => 3)
    type = Dict("pmuall" => "pmu",  "legacyall" => "legacy", "pmurandom" => "pmu",  "legacyrandom" => "legacy")

    for var in keys(settings.variance)
        if var in ["pmuall" "legacyall"]
            howMany = settings.variance[var]
            if isa(howMany, Number) && howMany > 0
                for i in names[type[var]]
                    measurement[i][:, write[i]] .= howMany
                end
            else
                error("The variance must be positive number.")
            end
        end
        if var in ["pmurandom" "legacyrandom"]
            howMany = settings.variance[var]
            if isa(howMany[1], Number) && isa(howMany[2], Number) && howMany[1] > 0 && howMany[2] > 0
                min = minimum(howMany)
                max = maximum(howMany)
                for i in names[type[var]]
                    for k in write[i]
                        measurement[i][:, k] .= min .+ (max - min) .* rand(size(measurement[i], 1))
                    end
                end
            else
                error("The variance must be positive number.")
            end
        end
        if var in ["pmuVoltage", "pmuCurrent", "legacyFlow", "legacyCurrent", "legacyInjection", "legacyVoltage"]
            for (pos, howMany) in enumerate(settings.variance[var])
                if howMany != "no"
                    if isa(howMany, Number) && howMany > 0
                        measurement[var][:, write[var][pos]] .= howMany
                    else
                        error("The variance must be positive number.")
                    end
                end
            end
        end
    end

    return measurement
end


###############
#  View data  #
###############
function view_generator(bus, branch)
    busi = @view(bus[:, 1])
    Vi = @view(bus[:, 2])
    Ti = @view(bus[:, 3])
    Pinj = @view(bus[:, 4])
    Qinj = @view(bus[:, 5])

    branchi = @view(branch[:, 1])
    fromi = @view(branch[:, 2])
    toi = @view(branch[:, 3])
    Pij = @view(branch[:, 4])
    Qij = @view(branch[:, 5])
    Pji = @view(branch[:, 6])
    Qji = @view(branch[:, 7])
    Iij = @view(branch[:, 10])
    Dij = @view(branch[:, 11])
    Iji = @view(branch[:, 12])
    Dji = @view(branch[:, 13])

    return busi, Vi, Ti, Pinj, Qinj, branchi, fromi, toi, Pij, Qij, Pji, Qji, Iij, Dij, Iji, Dji
end
