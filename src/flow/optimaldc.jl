### DC optimal power flow
function rundcopf(system, num, settings, info)
    printstyled("Algorithm: DC optimal power flow\n"; bold = true)

    ########## Pre-processing ##########
    busi, Pload, Gshunt, Pmax, Pmin, reactance, transTap, transShift, branchOn, longTermRating, angleMin, angleMax,
    costModel, numOfCoeffs, coeffs = read_opfdcsystem(system, num)

    ########## Convert in integers ##########
    geni = convert(Array{Int64,1}, system.generator[:, 1])
    fromi = convert(Array{Int64,1}, system.branch[:, 2])
    toi = convert(Array{Int64,1}, system.branch[:, 3])

    ########## Numbering ##########
    numbering = false
    bus = collect(1:num.Nbus)
    for i = 1:num.Nbus
        if bus[i] != busi[i]
            numbering = true
            break
        end
    end
    if numbering
        println("The new bus numbering is running.")
    end
    from = renumber(fromi, busi, bus, numbering)
    to = renumber(toi, busi, bus, numbering)

    ########## Optimization model ##########
    model = Model(Ipopt.Optimizer)
    @variable(model, thetas[bus])
    @constraint(model, thetas[1] == 0.0)
    @variable(model, Pmin[i] / system.basePower <= pGen[i = 1:num.Ngen] <= Pmax[i] / system.basePower)
    @inbounds for i = 1:num.Ngen
        set_start_value(pGen[i], (Pmax[i] + Pmin[i]) / (2 * system.basePower))
    end

    ########## Ybus matrix ##########
    Ybus, admitance, Pshift = ybusdc(system, num, bus, from, to, branchOn, transTap, reactance, transShift)

    ########## Branch flow constraints ##########
    @inbounds for i = 1:num.Nbranch
        if longTermRating[i] ≉  0 && longTermRating[i] < 10^10
            upf = longTermRating[i] / system.basePower + admitance[i] * transShift[i] * pi / 180
            upt = longTermRating[i] / system.basePower - admitance[i] * transShift[i] * pi / 180
            @constraint(model, -upt <= admitance[i] * thetas[from[i]] - admitance[i] * thetas[to[i]] <= upf)
        end
    end

    ########## Branch angle constraints ##########
    @inbounds for i = 1:num.Nbranch
        if angleMin[i] > -360 && angleMax[i] < 360
            angMinRad = angleMin[i] * π / 180
            angMaxRad = angleMax[i] * π / 180
            @constraint(model, angMinRad <= thetas[from[i]] - thetas[to[i]] <= angMaxRad)
        end
    end

    ########## Power mismatch constraints ##########
    Amis = [Ybus sparse(geni, collect(1:num.Ngen), -1, num.Nbus, num.Ngen)]
    bmis = - (Pload + Gshunt) / system.basePower - Pshift;
    @constraint(model, Amis * [thetas; pGen] .== bmis)

    Qpg, cpg, kpg, nPWL, pwlIds = process_cost_table(system, num, costModel, coeffs, numOfCoeffs)
    if nPWL == 0
        @objective(model, Min, sum(0.5 * Qpg[i] * pGen[i]^2 + cpg[i] * pGen[i] + kpg[i] for i = 1:num.Ngen))
    elseif nPWL > 0
        @variable(model, pwlVars[i = 1:nPWL])
        pgbas = 1
        qgbas = zeros(Int64, 0)
        nq = 0
        ybas = 1 + num.Ngen + nq
        Apwl, bpwl = makeApwl(system, num, nPWL, pwlIds, pgbas, qgbas, ybas, numOfCoeffs)
        for i = 1:(length(bpwl))
            @constraint(model, dot(Apwl[i,:], [pGen; pwlVars]) <= bpwl[i])
        end
        @objective(model, Min, sum(0.5 * Qpg[i] * pGen[i]^2 + cpg[i] * pGen[i] + kpg[i] for i = 1:num.Ngen) + sum(pwlVars[i] for i = 1:nPWL))
    end

    optimize!(model)


    @show objective_value(model)
    println(value.(thetas) * 180/π)
    println(value.(pGen))
    if nPWL > 0
        println(value.(pwlVars))
    end

    # return
end


### Read data
function read_opfdcsystem(system, num)
    busi = @view(system.bus[:, 1])
    Pload = @view(system.bus[:, 3])
    Gshunt = @view(system.bus[:, 5])

    Pmax = @view(system.generator[:, 9])
    Pmin = @view(system.generator[:, 10])

    reactance = @view(system.branch[:, 5])
    transTap = @view(system.branch[:, 10])
    transShift = @view(system.branch[:, 11])
    branchOn = @view(system.branch[:, 12])
    longTermRating = @view(system.branch[:, 7])
    angleMin = @view(system.branch[:, 13])
    angleMax = @view(system.branch[:, 14])

    costModel = @view(system.gencost[:, 1])
    numOfCoeffs = convert(Array{Int64,1}, system.gencost[:, 4])
    maxNumOfCoeffs, ~ = findmax(numOfCoeffs)
    coeffs = @view(system.gencost[1:num.Ngen, 5:4+maxNumOfCoeffs])

    return busi, Pload, Gshunt,
            Pmax, Pmin,
            reactance, transTap, transShift, branchOn, longTermRating, angleMin, angleMax,
            costModel, numOfCoeffs, coeffs
end


### Process data needed for the objective function
function process_cost_table(system, num, costModel, coeffs, numOfCoeffs)
    linTerm = fill(0.0, num.Ngen); quadTerm = fill(0.0, num.Ngen); constTerm = fill(0.0, num.Ngen)
    nPWL = 0; pwlIds = zeros(Int64, 0)

    @inbounds for i = 1:num.Ngen
        if costModel[i] == 1
            ########## PWL cost model ##########
            if numOfCoeffs[i] == 2
                ########## Single block pwl cost, convert to polynomial ##########
                x0 = system.gencost[i, 5]
                y0 = system.gencost[i, 6]
                x1 = system.gencost[i, 7]
                y1 = system.gencost[i, 8]
                m = (y1 - y0) / (x1 - x0)
                b = y0 - m * x0
                linTerm[i] = m
                constTerm[i] = b
            else
                nPWL = nPWL + 1
                append!(pwlIds, i)
            end
        elseif costModel[i] == 2
            ########## Polynomial ##########
            if numOfCoeffs[i] == 2
                linTerm[i] = coeffs[i, 1]
                constTerm[i] = coeffs[i, 2]
            elseif numOfCoeffs[i] == 3
                ########## Quadratic generator costs ##########
                quadTerm[i] = coeffs[i, 1]
                linTerm[i] = coeffs[i, 2]
                constTerm[i] = coeffs[i, 3]
            end
        end
    end
    Qpg = 2 * quadTerm * system.basePower^2
    cpg = linTerm * system.basePower
    kpg = constTerm

    return Qpg, cpg, kpg, nPWL, pwlIds
end


### Construct parameters for linear basin constraints
function makeApwl(system, num, nPWL, pwlIds, pgbas, qgbas, ybas, numOfCoeffs)
    if nPWL == 0
        Apwl = sparse([], [], [], 0, ybas + nPWL - 1, 0)
        bpwl = zeros(Int64, 0)

        return Apwl, bpwl
    end

    numCostPoints = sum(numOfCoeffs[i] for i in pwlIds)
    Apwl = zeros(Float64, numCostPoints - nPWL, ybas + nPWL - 1)
    bpwl = zeros(Int64, 0)

    k = 1
    @inbounds for i in pwlIds
        ns = numOfCoeffs[i]
        p = @view(system.gencost[i, 5:2:(5 + 2 * ns - 1)]) / system.basePower
        c = @view(system.gencost[i, 6:2:(5 + 2 * ns)])
        m = diff(c) ./ diff(p)
        if any(diff(p) == 0)
            println("makeApwl: Bad x axis data in the generator cost matrix, row: ", i)
        end
        b = m .* p[1:(ns - 1)] - c[1:(ns - 1)]
        bpwl = [bpwl; b]
        ########## Q and P costs ##########
        if i > num.Ngen
            sidx = qgbas + (i-ng) - 1
        else
            sidx = pgbas + i - 1
        end
        @inbounds for j = 1:(ns - 1)
            Apwl[j + k - 1, sidx] = m[j]
        end
        k = k + ns - 1
    end

    k = 1; j = 1
    @inbounds for i in pwlIds
        ns = numOfCoeffs[i]
        @inbounds for it = k:(k + ns - 2)
            Apwl[it, ybas + j - 1] = -1.0
        end
        k = k + ns - 1
        j = j + 1
    end

    return Apwl, bpwl
end
