"""
    printBusData(system::PowerSystem, analysis::Analysis, io::IO)

The function prints voltages, powers, and currents related to buses. Optionally, an `IO`
may be passed as the last argument to redirect output.

!!! compat "Julia 1.10"
    The function [`printBusData`](@ref printBusData) requires Julia 1.10 or later.

# Example
```jldoctest
system = powerSystem("case14.h5")

analysis = newtonRaphson(system)
for i = 1:10
    stopping = mismatch!(system, analysis)
    if all(stopping .< 1e-8)
        break
    end
    solve!(system, analysis)
end
power!(system, analysis)

printBusData(system, analysis)
```
"""
function printBusData(system::PowerSystem, analysis::AC, io::IO = stdout)
    format = printFormatBus(system, analysis)

    maxLine = sum(format["length"][1:3]) + 8
    if format["power"]
        maxLine += (sum(format["length"][4:11]) + 24)
    end
    if format["current"]
        maxLine += (sum(format["length"][12:13]) + 6)
    end

    printTitle(maxLine, "Bus Data", io)

    Printf.@printf(io, "| %*s%s%*s | %*s%s%*s |",
        floor(Int, (format["length"][1] - 5) / 2), "", "Label", ceil(Int, (format["length"][1] - 5) / 2) , "",
        floor(Int, (format["length"][2] + format["length"][3] - 4) / 2), "", "Voltage", ceil(Int, (format["length"][2] + format["length"][3] - 4) / 2) , "",
    )
    if format["power"]
        Printf.@printf(io, " %*s%s%*s | %*s%s%*s | %*s%s%*s | %*s%s%*s |",
            floor(Int, (format["length"][4] + format["length"][5] - 13) / 2), "", "Power Generation", ceil(Int, (format["length"][4] + format["length"][5] - 13) / 2) , "",
            floor(Int, (format["length"][6] + format["length"][7] - 9) / 2), "", "Power Demand", ceil(Int, (format["length"][6] + format["length"][7] - 9) / 2) , "",
            floor(Int, (format["length"][8] + format["length"][9] - 12) / 2), "", "Power Injection", ceil(Int, (format["length"][8] + format["length"][9] - 12) / 2) , "",
            floor(Int, (format["length"][10] + format["length"][11] - 8) / 2), "", "Shunt Power", ceil(Int, (format["length"][10] + format["length"][11] - 8) / 2) , "",
        )
    end
    if format["current"]
        Printf.@printf(io, " %*s%s%*s |",
            floor(Int, (format["length"][12] + format["length"][13] - 14) / 2), "", "Current Injection", ceil(Int, (format["length"][12] + format["length"][13] - 14) / 2) , ""
        )
    end
    Printf.@printf io "\n"

    Printf.@printf(io, "| %*s | %*s |",
        format["length"][1], "",
        format["length"][2] + format["length"][3] + 3, "",
    )
    if format["power"]
        Printf.@printf(io, " %*s | %*s | %*s | %*s |",
            format["length"][4] + format["length"][5] + 3, "",
            format["length"][6] + format["length"][7] + 3, "",
            format["length"][8] + format["length"][9] + 3, "",
            format["length"][10] + format["length"][11] + 3, "",
        )
    end
    if format["current"]
        Printf.@printf(io, " %*s |",
            format["length"][12] + format["length"][13] + 3, "",
        )
    end
    Printf.@printf io "\n"

    Printf.@printf(io, "| %*s | %*s | %*s ",
        format["length"][1], "",
        format["length"][2], "Magnitude",
        format["length"][3], "Angle",
    )
    if format["power"]
        Printf.@printf(io, "| %*s | %*s | %*s | %*s | %*s | %*s | %*s | %*s ",
            format["length"][4], "Active",
            format["length"][5], "Reactive",
            format["length"][6], "Active",
            format["length"][7], "Reactive",
            format["length"][8], "Active",
            format["length"][9], "Reactive",
            format["length"][10], "Active",
            format["length"][11], "Reactive",
        )
    end
    if format["current"]
        Printf.@printf(io, "| %*s | %*s ",
            format["length"][12], "Magnitude",
            format["length"][13], "Angle",
        )
    end
    Printf.@printf io "|\n"

    Printf.@printf(io, "| %*s | %*s | %*s ",
        format["length"][1], "",
        format["length"][2], "$(format["unit"][2])",
        format["length"][3], "$(format["unit"][3])",
    )
    if format["power"]
        Printf.@printf(io, "| %*s | %*s | %*s | %*s | %*s | %*s | %*s | %*s ",
            format["length"][4], "$(format["unit"][4])",
            format["length"][5], "$(format["unit"][5])",
            format["length"][6], "$(format["unit"][4])",
            format["length"][7], "$(format["unit"][5])",
            format["length"][8], "$(format["unit"][4])",
            format["length"][9], "$(format["unit"][5])",
            format["length"][10], "$(format["unit"][4])",
            format["length"][11], "$(format["unit"][5])",
        )
    end
    if format["current"]
        Printf.@printf(io, "| %*s | %*s ",
            format["length"][12], "$(format["unit"][6])",
            format["length"][13], "$(format["unit"][7])",
        )
    end
    Printf.@printf io "|\n"

    Printf.@printf(io, "|-%*s-|-%*s-|-%*s-",
        format["length"][1], "-"^format["length"][1],
        format["length"][2], "-"^format["length"][2],
        format["length"][3], "-"^format["length"][3],
    )
    if format["power"]
        Printf.@printf(io, "|-%*s-|-%*s-|-%*s-|-%*s-|-%*s-|-%*s-|-%*s-|-%*s-",
            format["length"][4], "-"^format["length"][4],
            format["length"][5], "-"^format["length"][5],
            format["length"][6], "-"^format["length"][6],
            format["length"][7], "-"^format["length"][7],
            format["length"][8], "-"^format["length"][8],
            format["length"][9], "-"^format["length"][9],
            format["length"][10], "-"^format["length"][10],
            format["length"][11], "-"^format["length"][11],
        )
    end
    if format["current"]
        Printf.@printf(io, "|-%*s-|-%*s-",
        format["length"][12], "-"^format["length"][12],
        format["length"][13], "-"^format["length"][13]
        )
    end
    Printf.@printf io "|\n"

    for (label, i) in system.bus.label
        if prefix.voltageMagnitude != 0.0
            voltageMagnitude = (analysis.voltage.magnitude[i] ) * (system.base.voltage.value[i] * system.base.voltage.prefix) / prefix.voltageMagnitude
        else
            voltageMagnitude = analysis.voltage.magnitude[i]
        end

        if format["current"]
            if  prefix.currentMagnitude != 0.0
                currentMagnitude = analysis.current.injection.magnitude[i] * system.base.power.value * system.base.power.prefix / (sqrt(3) * system.base.voltage.value[i] * system.base.voltage.prefix * prefix.currentMagnitude)
            else
                currentMagnitude = analysis.current.injection.magnitude[i]
            end
        end

        Printf.@printf(io, "| %*s | %*.4f | %*.4f ",
            format["length"][1], label,
            format["length"][2], voltageMagnitude,
            format["length"][3], analysis.voltage.angle[i] * format["scale"][3],
        )
        if format["power"]
            Printf.@printf(io, "| %*.4f | %*.4f | %*.4f | %*.4f | %*.4f | %*.4f | %*.4f | %*.4f ",
                format["length"][4], analysis.power.supply.active[i] * format["scale"][4],
                format["length"][5], analysis.power.supply.reactive[i] * format["scale"][5],
                format["length"][6], system.bus.demand.active[i] * format["scale"][4],
                format["length"][7], system.bus.demand.reactive[i] * format["scale"][5],
                format["length"][8], analysis.power.injection.active[i] * format["scale"][4],
                format["length"][9], analysis.power.injection.reactive[i] * format["scale"][5],
                format["length"][10], analysis.power.shunt.active[i] * format["scale"][4],
                format["length"][11], analysis.power.shunt.reactive[i] * format["scale"][5],
            )
        end
        if format["current"]
            Printf.@printf(io, "| %*.4f | %*.4f ",
            format["length"][12], currentMagnitude,
            format["length"][13], analysis.current.injection.angle[i] * format["scale"][7]
            )
        end
        Printf.@printf io "|\n"
    end

    Printf.@printf(io, "|%s|\n", "-"^maxLine)
end

function printBusData(system::PowerSystem, analysis::DC, io::IO = stdout)
    format = printFormatBus(system, analysis)

    maxLine = sum(format["length"][1:2]) + 5
    if format["power"]
        maxLine += (sum(format["length"][3:5]) + 9)
    end

    printTitle(maxLine, "Bus Data", io)

    Printf.@printf(io, "| %*s%s%*s | %*s |",
        floor(Int, (format["length"][1] - 5) / 2), "", "Label", ceil(Int, (format["length"][1] - 5) / 2) , "",
        format["length"][2], "Voltage",
    )

    if format["power"]
        Printf.@printf(io, " %*s | %*s | %*s |",
            format["length"][3], "Power Generation",
            format["length"][4], "Power Demand",
            format["length"][5], "Power Injection",
        )
    end
    Printf.@printf io "\n"

    Printf.@printf(io, "| %*s | %*s ",
        format["length"][1], "",
        format["length"][2], "Angle $(format["unit"][1])",
    )
    if format["power"]
        Printf.@printf(io, "| %*s | %*s | %*s ",
            format["length"][3], "Active $(format["unit"][2])",
            format["length"][4], "Active $(format["unit"][2])",
            format["length"][5], "Active $(format["unit"][2])",
        )
    end
    Printf.@printf io "|\n"

    Printf.@printf(io, "|-%*s-|-%*s-",
        format["length"][1], "-"^format["length"][1],
        format["length"][2], "-"^format["length"][2],
    )
    if format["power"]
        Printf.@printf(io, "|-%*s-|-%*s-|-%*s-",
            format["length"][3], "-"^format["length"][3],
            format["length"][4], "-"^format["length"][4],
            format["length"][5], "-"^format["length"][5],
        )
    end
    Printf.@printf io "|\n"

    for (label, i) in system.bus.label
        Printf.@printf(io, "| %*s | %*.4f ",
            format["length"][1], label,
            format["length"][2], analysis.voltage.angle[i] * format["scale"][1],
        )
        if format["power"]
            Printf.@printf(io, "| %*.4f | %*.4f | %*.4f ",
                format["length"][3], analysis.power.supply.active[i] * format["scale"][2],
                format["length"][4], system.bus.demand.active[i] * format["scale"][2],
                format["length"][5], analysis.power.injection.active[i] * format["scale"][2],
            )
        end
        Printf.@printf io "|\n"
    end

    Printf.@printf(io, "|%s|\n", "-"^maxLine)
end

"""
    printBranchData(system::PowerSystem, analysis::Analysis, io::IO)

The function prints powers and currents related to branches. Optionally, an `IO` may be
passed as the last argument to redirect output.

!!! compat "Julia 1.10"
    The function [`printBranchData`](@ref printBranchData) requires Julia 1.10 or later.

# Example
```jldoctest
system = powerSystem("case14.h5")

analysis = newtonRaphson(system)
for i = 1:10
    stopping = mismatch!(system, analysis)
    if all(stopping .< 1e-8)
        break
    end
    solve!(system, analysis)
end
power!(system, analysis)

printBranchData(system, analysis)
```
"""
function printBranchData(system::PowerSystem, analysis::AC, io::IO = stdout)
    format = printFormatBranch(system, analysis)

    if format["power"] || format["current"]
        maxLine = format["length"][1] + format["length"][16] + 5
        if format["power"]
            maxLine += (sum(format["length"][2:9]) + 24)
        end
        if format["current"]
            maxLine += (sum(format["length"][10:15]) + 18)
        end

        printTitle(maxLine, "Branch Data", io)

        Printf.@printf(io, "| %*s%s%*s ", floor(Int, (format["length"][1] - 5) / 2), "", "Label", ceil(Int, (format["length"][1] - 5) / 2) , "",)

        if format["power"]
            Printf.@printf(io, "| %*s%s%*s | %*s%s%*s | %*s%s%*s | %*s%s%*s ",
                floor(Int, (format["length"][2] + format["length"][3] - 11) / 2), "", "From-Bus Power", ceil(Int, (format["length"][2] + format["length"][3] - 11) / 2) , "",
                floor(Int, (format["length"][4] + format["length"][5] - 9) / 2), "", "To-Bus Power", ceil(Int, (format["length"][4] + format["length"][5] - 9) / 2) , "",
                floor(Int, (format["length"][6] + format["length"][7] - 8) / 2), "", "Shunt Power", ceil(Int, (format["length"][6] + format["length"][7] - 8) / 2) , "",
                floor(Int, (format["length"][8] + format["length"][9] - 9) / 2), "", "Series Power", ceil(Int, (format["length"][8] + format["length"][9] - 9) / 2) , "",
            )
        end
        if format["current"]
            Printf.@printf(io, "| %*s%s%*s | %*s%s%*s | %*s%s%*s ",
                floor(Int, (format["length"][10] + format["length"][11] - 13) / 2), "", "From-Bus Current", ceil(Int, (format["length"][10] + format["length"][11] - 13) / 2) , "",
                floor(Int, (format["length"][12] + format["length"][13] - 11) / 2), "", "To-Bus Current", ceil(Int, (format["length"][12] + format["length"][13] - 11) / 2) , "",
                floor(Int, (format["length"][14] + format["length"][15] - 11) / 2), "", "Series Current", ceil(Int, (format["length"][14] + format["length"][15] - 11) / 2) , "",
            )
        end
        Printf.@printf io "| %s |\n" "Status"

        Printf.@printf(io, "| %*s |",
            format["length"][1], "",
        )
        if format["power"]
            Printf.@printf(io, " %*s | %*s | %*s | %*s |",
                format["length"][2] + format["length"][3] + 3, "",
                format["length"][4] + format["length"][5] + 3, "",
                format["length"][6] + format["length"][7] + 3, "",
                format["length"][8] + format["length"][9] + 3, "",
            )
        end
        if format["current"]
            Printf.@printf(io, " %*s | %*s | %*s |",
                format["length"][10] + format["length"][11] + 3, "",
                format["length"][12] + format["length"][13] + 3, "",
                format["length"][14] + format["length"][15] + 3, "",
            )
        end
        Printf.@printf io " %*s |\n" format["length"][16] ""

        Printf.@printf(io, "| %*s ", format["length"][1], "")

        if format["power"]
            Printf.@printf(io, "| %*s | %*s | %*s | %*s | %*s | %*s | %*s | %*s ",
                format["length"][2], "Active",
                format["length"][3], "Reactive",
                format["length"][4], "Active",
                format["length"][5], "Reactive",
                format["length"][6], "Active",
                format["length"][7], "Reactive",
                format["length"][8], "Active",
                format["length"][9], "Reactive",
            )
        end
        if format["current"]
            Printf.@printf(io, "| %*s | %*s | %*s | %*s | %*s | %*s ",
                format["length"][10], "Magnitude",
                format["length"][11], "Angle",
                format["length"][12], "Magnitude",
                format["length"][13], "Angle",
                format["length"][14], "Magnitude",
                format["length"][15], "Angle",
            )
        end
        Printf.@printf io "| %*s |\n" format["length"][16] ""

        Printf.@printf(io, "| %*s ", format["length"][1], "")

        if format["power"]
            Printf.@printf(io, "| %*s | %*s | %*s | %*s | %*s | %*s | %*s | %*s ",
                format["length"][2], "$(format["unit"][2])",
                format["length"][3], "$(format["unit"][3])",
                format["length"][4], "$(format["unit"][2])",
                format["length"][5], "$(format["unit"][3])",
                format["length"][6], "$(format["unit"][2])",
                format["length"][7], "$(format["unit"][3])",
                format["length"][8], "$(format["unit"][2])",
                format["length"][9], "$(format["unit"][3])",
            )
        end
        if format["current"]
            Printf.@printf(io, "| %*s | %*s | %*s | %*s | %*s | %*s ",
                format["length"][10], "$(format["unit"][4])",
                format["length"][11], "$(format["unit"][5])",
                format["length"][12], "$(format["unit"][4])",
                format["length"][13], "$(format["unit"][5])",
                format["length"][14], "$(format["unit"][4])",
                format["length"][15], "$(format["unit"][5])",
            )
        end
        Printf.@printf io "| %*s |\n" format["length"][16] ""

        Printf.@printf(io, "|-%*s-", format["length"][1], "-"^format["length"][1]
        )
        if format["power"]
            Printf.@printf(io, "|-%*s-|-%*s-|-%*s-|-%*s-|-%*s-|-%*s-|-%*s-|-%*s-",
                format["length"][2], "-"^format["length"][2],
                format["length"][3], "-"^format["length"][3],
                format["length"][4], "-"^format["length"][4],
                format["length"][5], "-"^format["length"][5],
                format["length"][6], "-"^format["length"][6],
                format["length"][7], "-"^format["length"][7],
                format["length"][8], "-"^format["length"][8],
                format["length"][9], "-"^format["length"][9],
            )
        end
        if format["current"]
            Printf.@printf(io, "|-%*s-|-%*s-|-%*s-|-%*s-|-%*s-|-%*s-",
                format["length"][10], "-"^format["length"][10],
                format["length"][11], "-"^format["length"][11],
                format["length"][12], "-"^format["length"][12],
                format["length"][13], "-"^format["length"][13],
                format["length"][14], "-"^format["length"][14],
                format["length"][15], "-"^format["length"][15],
            )
        end
        Printf.@printf io "|-%*s-|\n" format["length"][16] "-"^format["length"][16]

        for (label, i) in system.branch.label
            Printf.@printf(io, "| %*s ", format["length"][1], label)

            if format["power"]
                Printf.@printf(io, "| %*.4f | %*.4f | %*.4f | %*.4f | %*.4f | %*.4f | %*.4f | %*.4f ",
                    format["length"][2], analysis.power.from.active[i] * format["scale"][2],
                    format["length"][3], analysis.power.from.reactive[i] * format["scale"][3],
                    format["length"][4], analysis.power.to.active[i] * format["scale"][2],
                    format["length"][5], analysis.power.to.reactive[i] * format["scale"][3],
                    format["length"][6], analysis.power.charging.active[i] * format["scale"][2],
                    format["length"][7], analysis.power.charging.reactive[i] * format["scale"][3],
                    format["length"][8], analysis.power.series.active[i] * format["scale"][2],
                    format["length"][9], analysis.power.series.reactive[i] * format["scale"][3],
                )
            end
            if format["current"]
                if prefix.currentMagnitude != 0.0
                    j = system.branch.layout.from[i]
                    currentMagnitudeFrom = analysis.current.from.magnitude[i] * system.base.power.value * system.base.power.prefix / (sqrt(3) * system.base.voltage.value[j] * system.base.voltage.prefix * prefix.currentMagnitude)
                    currentMagnitudeS = analysis.current.series.magnitude[i] * system.base.power.value * system.base.power.prefix / (sqrt(3) * system.base.voltage.value[j] * system.base.voltage.prefix * prefix.currentMagnitude)

                    j = system.branch.layout.to[i]
                    currentMagnitudeTo = analysis.current.to.magnitude[i] * system.base.power.value * system.base.power.prefix / (sqrt(3) * system.base.voltage.value[j] * system.base.voltage.prefix * prefix.currentMagnitude)
                else
                    currentMagnitudeFrom = analysis.current.from.magnitude[i]
                    currentMagnitudeTo = analysis.current.to.magnitude[i]
                    currentMagnitudeS = analysis.current.series.magnitude[i]
                end

                Printf.@printf(io, "| %*.4f | %*.4f | %*.4f | %*.4f | %*.4f | %*.4f ",
                    format["length"][10], currentMagnitudeFrom,
                    format["length"][11], analysis.current.from.angle[i] * format["scale"][5],
                    format["length"][12], currentMagnitudeTo,
                    format["length"][13], analysis.current.to.angle[i] * format["scale"][5],
                    format["length"][14], currentMagnitudeS,
                    format["length"][15], analysis.current.series.angle[i] * format["scale"][5]
                )
            end

            Printf.@printf(io, "| %*i |\n", format["length"][16], system.branch.layout.status[i])
        end
        Printf.@printf(io, "|%s|\n", "-"^maxLine)
    end
end

function printBranchData(system::PowerSystem, analysis::DC, io::IO = stdout)
    format = printFormatBranch(system, analysis)

    if format["power"]
        maxLine = sum(format["length"]) + 11

        printTitle(maxLine, "Branch Data", io)

        Printf.@printf(io, "| %*s%s%*s | %*s | %*s | %*s |\n",
            floor(Int, (format["length"][1] - 5) / 2), "", "Label", ceil(Int, (format["length"][1] - 5) / 2) , "",
            format["length"][2], "From-Bus Power",
            format["length"][3], "To-Bus Power",
            format["length"][4], "Status",
        )

        Printf.@printf(io, "| %*s | %*s | %*s | %*s |\n",
            format["length"][1], "",
            format["length"][2], "Active $(format["unit"])",
            format["length"][3], "Active $(format["unit"])",
            format["length"][4], "",
        )

        Printf.@printf(io, "|-%*s-|-%*s-|-%*s-|-%*s-|\n",
            format["length"][1], "-"^format["length"][1],
            format["length"][2], "-"^format["length"][2],
            format["length"][3], "-"^format["length"][3],
            format["length"][4], "-"^format["length"][4],
        )

        for (label, i) in system.branch.label
            Printf.@printf(io, "| %*s | %*.4f | %*.4f | %*i |\n",
                format["length"][1], label,
                format["length"][2], analysis.power.from.active[i] * format["scale"],
                format["length"][3], analysis.power.to.active[i] * format["scale"],
                format["length"][4], system.branch.layout.status[i],
            )
        end

        Printf.@printf(io, "|%s|\n", "-"^maxLine)
    end
end

"""
    printGeneratorData(system::PowerSystem, analysis::Analysis, io::IO)

The function prints powers related to generators. Optionally, an `IO` may be passed as the
last argument to redirect output.

!!! compat "Julia 1.10"
    The function [`printGeneratorData`](@ref printGeneratorData) requires Julia 1.10 or later.

# Example
```jldoctest
system = powerSystem("case14.h5")

analysis = newtonRaphson(system)
for i = 1:10
    stopping = mismatch!(system, analysis)
    if all(stopping .< 1e-8)
        break
    end
    solve!(system, analysis)
end
power!(system, analysis)

printGeneratorData(system, analysis)
```
"""
function printGeneratorData(system::PowerSystem, analysis::AC, io::IO = stdout)
    format = printFormatGenerator(system, analysis)

    if format["power"]
        maxLine = sum(format["length"]) + 11

        printTitle(maxLine, "Generator Data", io)

        Printf.@printf(io, "| %*s%s%*s | %*s%s%*s | %s |\n",
            floor(Int, (format["length"][1] - 5) / 2), "", "Label", ceil(Int, (format["length"][1] - 5) / 2) , "",
            floor(Int, (format["length"][2] + format["length"][3] - 9) / 2), "", "Output Power", ceil(Int, (format["length"][2] + format["length"][3] - 9) / 2) , "",
            "Status"
        )

        Printf.@printf(io, "| %*s | %*s | %*s |\n",
            format["length"][1], "",
            format["length"][2] + format["length"][3] + 3, "",
            format["length"][4], ""
        )

        Printf.@printf(io, "| %*s | %*s | %*s | %*s |\n",
            format["length"][1], "",
            format["length"][2], "Active",
            format["length"][3], "Reactive",
            format["length"][4], ""
        )

        Printf.@printf(io, "| %*s | %*s | %*s | %*s |\n",
            format["length"][1], "",
            format["length"][2], "$(format["unit"][1])",
            format["length"][3], "$(format["unit"][2])",
            format["length"][4], ""
        )

        Printf.@printf(io, "|-%*s-|-%*s-|-%*s-|-%*s-|\n",
            format["length"][1], "-"^format["length"][1],
            format["length"][2], "-"^format["length"][2],
            format["length"][3], "-"^format["length"][3],
            format["length"][4], "-"^format["length"][4],
        )

        for (label, i) in system.generator.label
            Printf.@printf(io, "| %*s | %*.4f | %*.4f | %*i |\n",
                format["length"][1], label,
                format["length"][2], analysis.power.generator.active[i] * format["scale"][1],
                format["length"][3], analysis.power.generator.reactive[i] * format["scale"][2],
                format["length"][4], system.generator.layout.status[i]
            )
        end

        Printf.@printf(io, "|%s|\n", "-"^maxLine)
    end
end

function printGeneratorData(system::PowerSystem, analysis::DC, io::IO = stdout)
    format = printFormatGenerator(system, analysis)

    if format["power"]
        maxLine = sum(format["length"]) + 8

        printTitle(maxLine, "Generator Data", io)

        Printf.@printf(io, "| %*s%s%*s | %*s | %s |\n",
            floor(Int, (format["length"][1] - 5) / 2), "", "Label", ceil(Int, (format["length"][1] - 5) / 2) , "",
            format["length"][2], "Output Power",
            "Status"
        )

        Printf.@printf(io, "| %*s | %*s | %*s |\n",
            format["length"][1], "",
            format["length"][2], "Active $(format["unit"])",
            format["length"][3], "",
        )

        Printf.@printf(io, "|-%*s-|-%*s-|-%*s-|\n",
            format["length"][1], "-"^format["length"][1],
            format["length"][2], "-"^format["length"][2],
            format["length"][3], "-"^format["length"][3],
        )

        for (label, i) in system.generator.label
            Printf.@printf(io, "| %*s | %*.4f | %*i |\n",
                format["length"][1], label,
                format["length"][2], analysis.power.generator.active[i] * format["scale"],
                format["length"][3], system.generator.layout.status[i]
            )
        end

        Printf.@printf(io, "|%s|\n", "-"^maxLine)
    end
end

function printFormatBus(system::PowerSystem, analysis::AC)
    errorVoltage(analysis.voltage.magnitude)

    format = Dict(
        "length" => [5; 9; 5; 6; 8; 6; 8; 6; 8; 6; 8; 9; 5],
        "unit" => [""; "[pu]"; "[rad]"; "[pu]"; "[pu]"; "[pu]"; "[rad]"],
        "scale" => [0.0; 0.0; 1.0; 1.0; 1.0; 1.0; 1.0],
        "power" => !isempty(analysis.power.injection.active),
        "current" => !isempty(analysis.current.injection.magnitude)
    )

    if prefix.voltageMagnitude != 0.0
        format["unit"][2] = "[$(findKey(prefixList, prefix.voltageMagnitude))V]"
    else
        maxV = maximum(analysis.voltage.magnitude)
        format["length"][2] = max(length(Printf.@sprintf("%.4f", maxV)), format["length"][2])
    end

    if prefix.voltageAngle != 0.0
        format["unit"][3] = "[deg]"
        format["scale"][3] = 1 / prefix.voltageAngle
    end
    minmaxT = extrema(analysis.voltage.angle)
    format["length"][3] = max(length(Printf.@sprintf("%.4f", minmaxT[1] * format["scale"][3])), length(Printf.@sprintf("%.4f", minmaxT[2] * format["scale"][3])), format["length"][3])

    if format["power"]
        if prefix.activePower != 0.0
            format["unit"][4] = "[$(findKey(prefixList, prefix.activePower))W]"
            format["scale"][4] = system.base.power.value * system.base.power.prefix / prefix.activePower
        end

        minmaxPg = extrema(analysis.power.supply.active)
        format["length"][4] = max(length(Printf.@sprintf("%.4f", minmaxPg[1] * format["scale"][4])), length(Printf.@sprintf("%.4f", minmaxPg[2] * format["scale"][4])), format["length"][4])

        minmaxPl = extrema(system.bus.demand.active)
        format["length"][6] = max(length(Printf.@sprintf("%.4f", minmaxPl[1] * format["scale"][4])), length(Printf.@sprintf("%.4f", minmaxPl[2] * format["scale"][4])), format["length"][6])

        minmaxPi = extrema(analysis.power.injection.active)
        format["length"][8] = max(length(Printf.@sprintf("%.4f", minmaxPi[1] * format["scale"][4])), length(Printf.@sprintf("%.4f", minmaxPi[2] * format["scale"][4])), format["length"][8])

        minmaxPsi = extrema(analysis.power.shunt.active)
        format["length"][10] = max(length(Printf.@sprintf("%.4f", minmaxPsi[1] * format["scale"][4])), length(Printf.@sprintf("%.4f", minmaxPsi[2] * format["scale"][4])), format["length"][10])

        if prefix.reactivePower != 0.0
            format["unit"][5] = "[$(findKey(prefixList, prefix.reactivePower))VAr]"
            format["scale"][5] = system.base.power.value * system.base.power.prefix / prefix.reactivePower
        end

        minmaxQg = extrema(analysis.power.supply.reactive)
        format["length"][5] = max(length(Printf.@sprintf("%.4f", minmaxQg[1] * format["scale"][5])), length(Printf.@sprintf("%.4f", minmaxQg[2] * format["scale"][5])), format["length"][5])

        minmaxQl = extrema(system.bus.demand.reactive)
        format["length"][7] = max(length(Printf.@sprintf("%.4f", minmaxQl[1] * format["scale"][5])), length(Printf.@sprintf("%.4f", minmaxQl[2] * format["scale"][5])), format["length"][7])

        minmaxQi = extrema(analysis.power.injection.reactive)
        format["length"][9] = max(length(Printf.@sprintf("%.4f", minmaxQi[1] * format["scale"][5])), length(Printf.@sprintf("%.4f", minmaxQi[2] * format["scale"][5])), format["length"][9])

        minmaxQsi = extrema(analysis.power.shunt.reactive)
        format["length"][11] = max(length(Printf.@sprintf("%.4f", minmaxQsi[1] * format["scale"][5])), length(Printf.@sprintf("%.4f", minmaxQsi[2] * format["scale"][5])), format["length"][11])
    end

    if format["current"]
        if prefix.currentMagnitude != 0.0
            format["unit"][6] = "[$(findKey(prefixList, prefix.currentMagnitude))A]"
        else
            maxI = maximum(analysis.current.injection.magnitude)
            format["length"][12] = max(length(Printf.@sprintf("%.4f", maxI)), format["length"][12])
        end

        if prefix.currentAngle != 0.0
            format["unit"][7] = "[deg]"
            format["scale"][7] = 1 / prefix.currentAngle
        end
        minmaxW = extrema(analysis.current.injection.angle)
        format["length"][13] = max(length(Printf.@sprintf("%.4f", minmaxW[1] * format["scale"][7])), length(Printf.@sprintf("%.4f", minmaxW[2] * format["scale"][7])), format["length"][13])
    end

    @inbounds for (label, i) in system.bus.label
        format["length"][1] = max(length(label), format["length"][1])

        if prefix.voltageMagnitude != 0.0
            scaleV = (system.base.voltage.value[i] * system.base.voltage.prefix) / prefix.voltageMagnitude
            format["length"][2] = max(length(Printf.@sprintf("%.4f", analysis.voltage.magnitude[i] * scaleV)), format["length"][2])
        end

        if format["current"] && prefix.currentMagnitude != 0.0
            scaleI = system.base.power.value * system.base.power.prefix / (sqrt(3) * system.base.voltage.value[i] * system.base.voltage.prefix * prefix.currentMagnitude)
            format["length"][12] = max(length(Printf.@sprintf("%.4f", analysis.current.injection.magnitude[i] * scaleI)), format["length"][12])
        end
    end

    return format
end

function printFormatBus(system::PowerSystem, analysis::DC)
    errorVoltage(analysis.voltage.angle)

    format = Dict(
        "length" => [5; 11; 16; 12; 15],
        "unit" => ["[rad]"; "[pu]"],
        "scale" => [1.0; 1.0],
        "power" => !isempty(analysis.power.injection.active),
    )

    if prefix.voltageAngle != 0.0
        format["unit"][1] = "[deg]"
        format["scale"][1] = 1 / prefix.voltageAngle
    end
    minmaxT = extrema(analysis.voltage.angle)
    format["length"][2] = max(length(Printf.@sprintf("%.4f", minmaxT[1] * format["scale"][1])), length(Printf.@sprintf("%.4f", minmaxT[2] * format["scale"][1])), format["length"][2])

    if format["power"]
        if prefix.activePower != 0.0
            format["unit"][2] = "[$(findKey(prefixList, prefix.activePower))W]"
            format["scale"][2] = system.base.power.value * system.base.power.prefix / prefix.activePower
        end

        minmaxPg = extrema(analysis.power.supply.active)
        format["length"][3] = max(length(Printf.@sprintf("%.4f", minmaxPg[1] * format["scale"][2])), length(Printf.@sprintf("%.4f", minmaxPg[2] * format["scale"][2])), format["length"][3])

        minmaxPl = extrema(system.bus.demand.active)
        format["length"][4] = max(length(Printf.@sprintf("%.4f", minmaxPl[1] * format["scale"][2])), length(Printf.@sprintf("%.4f", minmaxPl[2] * format["scale"][2])), format["length"][4])

        minmaxPi = extrema(analysis.power.injection.active)
        format["length"][5] = max(length(Printf.@sprintf("%.4f", minmaxPi[1] * format["scale"][2])), length(Printf.@sprintf("%.4f", minmaxPi[2] * format["scale"][2])), format["length"][5])
    end

    @inbounds for (label, i) in system.bus.label
        format["length"][1] = max(length(label), format["length"][1])
    end

    return format
end

function printFormatBranch(system::PowerSystem, analysis::AC)
    format = Dict(
        "length" => [5; 6; 8; 6; 8; 6; 8; 6; 8; 9; 5; 9; 5; 9; 5; 6],
        "unit" => [""; "[pu]"; "[pu]"; "[pu]"; "[rad]"],
        "scale" => [0.0; 1.0; 1.0; 1.0; 1.0],
        "power" => !isempty(analysis.power.injection.active),
        "current" => !isempty(analysis.current.injection.magnitude)
    )

    if format["power"]
        if prefix.activePower != 0.0
            format["unit"][2] = "[$(findKey(prefixList, prefix.activePower))W]"
            format["scale"][2] = system.base.power.value * system.base.power.prefix / prefix.activePower
        end

        minmaxPij = extrema(analysis.power.from.active)
        format["length"][2] = max(length(Printf.@sprintf("%.4f", minmaxPij[1] * format["scale"][2])), length(Printf.@sprintf("%.4f", minmaxPij[2] * format["scale"][2])), format["length"][2])

        minmaxPji = extrema(analysis.power.to.active)
        format["length"][4] = max(length(Printf.@sprintf("%.4f", minmaxPji[1] * format["scale"][2])), length(Printf.@sprintf("%.4f", minmaxPji[2] * format["scale"][2])), format["length"][4])

        minmaxPsi = extrema(analysis.power.charging.active)
        format["length"][6] = max(length(Printf.@sprintf("%.4f", minmaxPsi[1] * format["scale"][2])), length(Printf.@sprintf("%.4f", minmaxPsi[2] * format["scale"][2])), format["length"][6])

        minmaxPli = extrema(analysis.power.series.active)
        format["length"][8] = max(length(Printf.@sprintf("%.4f", minmaxPli[1] * format["scale"][2])), length(Printf.@sprintf("%.4f", minmaxPli[2] * format["scale"][2])), format["length"][8])

        if prefix.reactivePower != 0.0
            format["unit"][3] = "[$(findKey(prefixList, prefix.reactivePower))VAr]"
            format["scale"][3] = system.base.power.value * system.base.power.prefix / prefix.reactivePower
        end

        minmaxQij = extrema(analysis.power.from.reactive)
        format["length"][3] = max(length(Printf.@sprintf("%.4f", minmaxQij[1] * format["scale"][3])), length(Printf.@sprintf("%.4f", minmaxQij[2] * format["scale"][3])), format["length"][3])

        minmaxQji = extrema(analysis.power.to.reactive)
        format["length"][5] = max(length(Printf.@sprintf("%.4f", minmaxQji[1] * format["scale"][3])), length(Printf.@sprintf("%.4f", minmaxQji[2] * format["scale"][3])), format["length"][5])

        minmaxQsi = extrema(analysis.power.charging.reactive)
        format["length"][7] = max(length(Printf.@sprintf("%.4f", minmaxQsi[1] * format["scale"][3])), length(Printf.@sprintf("%.4f", minmaxQsi[2] * format["scale"][3])), format["length"][7])

        minmaxQli = extrema(analysis.power.series.reactive)
        format["length"][9] = max(length(Printf.@sprintf("%.4f", minmaxQli[1] * format["scale"][3])), length(Printf.@sprintf("%.4f", minmaxQli[2] * format["scale"][3])), format["length"][9])
    end

    if format["current"]
        if prefix.currentMagnitude != 0.0
            format["unit"][4] = "[$(findKey(prefixList, prefix.currentMagnitude))A]"
        else
            maxIij = maximum(analysis.current.from.magnitude)
            format["length"][10] = max(length(Printf.@sprintf("%.4f", maxIij)), format["length"][10])

            maxIji = maximum(analysis.current.to.magnitude)
            format["length"][12] = max(length(Printf.@sprintf("%.4f", maxIji)), format["length"][12])

            maxIs = maximum(analysis.current.series.magnitude)
            format["length"][14] = max(length(Printf.@sprintf("%.4f", maxIs)), format["length"][14])
        end

        if prefix.currentAngle != 0.0
            format["unit"][5] = "[deg]"
            format["scale"][5] = 1 / prefix.currentAngle
        end

        minmaxWij = extrema(analysis.current.from.angle)
        format["length"][11] = max(length(Printf.@sprintf("%.4f", minmaxWij[1] * format["scale"][5])), length(Printf.@sprintf("%.4f", minmaxWij[2] * format["scale"][5])), format["length"][11])

        minmaxWji = extrema(analysis.current.to.angle)
        format["length"][13] = max(length(Printf.@sprintf("%.4f", minmaxWji[1] * format["scale"][5])), length(Printf.@sprintf("%.4f", minmaxWji[2] * format["scale"][5])), format["length"][13])

        minmaxWs = extrema(analysis.current.series.angle)
        format["length"][15] = max(length(Printf.@sprintf("%.4f", minmaxWs[1] * format["scale"][5])), length(Printf.@sprintf("%.4f", minmaxWs[2] * format["scale"][5])), format["length"][15])
    end

    @inbounds for (label, i) in system.branch.label
        format["length"][1] = max(length(label), format["length"][1])

        if format["current"] && prefix.currentMagnitude != 0.0
            from = system.branch.layout.from[i]
            scaleIij = system.base.power.value * system.base.power.prefix / (sqrt(3) * system.base.voltage.value[from] * system.base.voltage.prefix * prefix.currentMagnitude)
            format["length"][10] = max(length(Printf.@sprintf("%.4f", analysis.current.from.magnitude[i] * scaleIij)), format["length"][10])

            to = system.branch.layout.to[i]
            scaleIji = system.base.power.value * system.base.power.prefix / (sqrt(3) * system.base.voltage.value[to] * system.base.voltage.prefix * prefix.currentMagnitude)
            format["length"][12] = max(length(Printf.@sprintf("%.4f", analysis.current.to.magnitude[i] * scaleIji)), format["length"][12])

            format["length"][14] = max(length(Printf.@sprintf("%.4f", analysis.current.series.magnitude[i] * scaleIij)), format["length"][14])
        end
    end

    return format
end

function printFormatBranch(system::PowerSystem, analysis::DC)
    format = Dict(
        "length" => [5; 14; 12; 6],
        "unit" => "[pu]",
        "scale" => 1.0,
        "power" => !isempty(analysis.power.from.active),
    )

    if format["power"]
        if prefix.activePower != 0.0
            format["unit"] = "[$(findKey(prefixList, prefix.activePower))W]"
            format["scale"] = system.base.power.value * system.base.power.prefix / prefix.activePower
        end

        minmaxPij = extrema(analysis.power.from.active)
        format["length"][2] = max(length(Printf.@sprintf("%.4f", minmaxPij[1] * format["scale"])), length(Printf.@sprintf("%.4f", minmaxPij[2] * format["scale"])), format["length"][2])

        minmaxPji = extrema(analysis.power.to.active)
        format["length"][3] = max(length(Printf.@sprintf("%.4f", minmaxPji[1] * format["scale"])), length(Printf.@sprintf("%.4f", minmaxPji[2] * format["scale"])), format["length"][2])
    end

    @inbounds for (label, i) in system.branch.label
        format["length"][1] = max(length(label), format["length"][1])
    end

    return format
end

function printFormatGenerator(system::PowerSystem, analysis::AC)
    format = Dict(
        "length" => [5; 6; 8; 6],
        "unit" => ["[pu]"; "[pu]"],
        "scale" => [1.0; 1.0],
        "power" => !isempty(analysis.power.generator.active)
    )

    if format["power"]
        if prefix.activePower != 0.0
            format["unit"][1] = "[$(findKey(prefixList, prefix.activePower))W]"
            format["scale"][1] = system.base.power.value * system.base.power.prefix / prefix.activePower
        end

        minmaxPg = extrema(analysis.power.generator.active)
        format["length"][2] = max(length(Printf.@sprintf("%.4f", minmaxPg[1] * format["scale"][1])), length(Printf.@sprintf("%.4f", minmaxPg[2] * format["scale"][1])), format["length"][2])

        if prefix.reactivePower != 0.0
            format["unit"][2] = "[$(findKey(prefixList, prefix.reactivePower))VAr]"
            format["scale"][2] = system.base.power.value * system.base.power.prefix / prefix.reactivePower
        end

        minmaxQg = extrema(analysis.power.generator.reactive)
        format["length"][3] = max(length(Printf.@sprintf("%.4f", minmaxQg[1] * format["scale"][2])), length(Printf.@sprintf("%.4f", minmaxQg[2] * format["scale"][2])), format["length"][3])
    end

    @inbounds for (label, i) in system.generator.label
        format["length"][1] = max(length(label), format["length"][1])
    end

    return format
end

function printFormatGenerator(system::PowerSystem, analysis::DC)
    format = Dict(
        "length" => [5; 12; 6],
        "unit" => "[pu]",
        "scale" => 1.0,
        "power" => !isempty(analysis.power.generator.active)
    )

    if format["power"]
        if prefix.activePower != 0.0
            format["unit"] = "[$(findKey(prefixList, prefix.activePower))W]"
            format["scale"] = system.base.power.value * system.base.power.prefix / prefix.activePower
        end

        minmaxPg = extrema(analysis.power.generator.active)
        format["length"][2] = max(length(Printf.@sprintf("%.4f", minmaxPg[1] * format["scale"][1])), length(Printf.@sprintf("%.4f", minmaxPg[2] * format["scale"][1])), format["length"][2])
    end

    @inbounds for (label, i) in system.generator.label
        format["length"][1] = max(length(label), format["length"][1])
    end

    return format
end

"""
    printBusSummary(system::PowerSystem, analysis::Analysis, io::IO)

The function prints a summary of the electrical quantities related to buses. Optionally,
an `IO` may be passed as the last argument to redirect output.

!!! compat "Julia 1.10"
    The function [`printBusSummary`](@ref printBusSummary) requires Julia 1.10 or later.

# Example
```jldoctest
system = powerSystem("case14.h5")

analysis = newtonRaphson(system)
for i = 1:10
    stopping = mismatch!(system, analysis)
    if all(stopping .< 1e-8)
        break
    end
    solve!(system, analysis)
end
power!(system, analysis)

printBusSummary(system, analysis)
```
"""
function printBusSummary(system::PowerSystem, analysis::AC, io::IO = stdout)
    format = printFormatBusSummary(system, analysis)
    Printf.@printf io "\n"

    maxLine = sum(format["length"][:]) + 34

    sentence = "In the power system with $(system.bus.number) $(plosg("bus", system.bus.number)),
        in-service generators are located at $(format["device"][1]) $(plosg("bus", format["device"][1])),
        while loads are installed at $(format["device"][2]) $(plosg("bus", format["device"][2])),
        and shunts are present at $(format["device"][3]) $(plosg("bus", format["device"][3]))."

    summaryHeader(io, maxLine, cutSentenceParts(sentence, maxLine - 2), "Bus Summary")
    summarySubheader(io, maxLine, format["length"])

    summaryBlockHeader(io, format["length"], "Bus Voltage")
    summaryBlock(io, format["V"], format["length"], format["unit"][1], "Magnitude")
    summaryBlock(io, format["θ"], format["length"], format["unit"][2], "Angle"; line = true)

    if format["power"]
        if format["device"][1] != 0
            summaryBlockHeader(io, format["length"], "Power Generation")
            summaryBlock(io, format["Ps"], format["length"], format["unit"][3], "Active")
            summaryBlock(io, format["Qs"], format["length"], format["unit"][4], "Reactive"; line = true)
        end

        if format["device"][2] != 0
            summaryBlockHeader(io, format["length"], "Power Demand")
            summaryBlock(io, format["Pl"], format["length"], format["unit"][3], "Active")
            summaryBlock(io, format["Ql"], format["length"], format["unit"][4], "Reactive"; line = true)
        end

        summaryBlockHeader(io, format["length"], "Power Injection")
        summaryBlock(io, format["Pi"], format["length"], format["unit"][3], "Active")
        summaryBlock(io, format["Qi"], format["length"], format["unit"][4], "Reactive"; line = true)

        if format["device"][3] != 0
            summaryBlockHeader(io, format["length"], "Shunt Power")
            summaryBlock(io, format["Ph"], format["length"], format["unit"][3], "Active")
            summaryBlock(io, format["Qh"], format["length"], format["unit"][4], "Reactive"; line = true)
        end
    end

    if format["current"]
        summaryBlockHeader(io, format["length"], "Shunt Power")
        summaryBlock(io, format["I"], format["length"], format["unit"][5], "Magnitude")
        summaryBlock(io, format["ψ"], format["length"], format["unit"][6], "Angle"; line = true)
    end
end

function printBusSummary(system::PowerSystem, analysis::DC, io::IO = stdout)
    format = printFormatBusSummary(system, analysis)
    Printf.@printf io "\n"

    maxLine = sum(format["length"][:]) + 34

    sentence = "In the power system with $(system.bus.number) $(plosg("bus", system.bus.number)),
        in-service generators are located at $(format["device"][1]) $(plosg("bus", format["device"][1])),
        while loads are installed at $(format["device"][2]) $(plosg("bus", format["device"][2])),
        and shunts are present at $(format["device"][3]) $(plosg("bus", format["device"][3]))."

    summaryHeader(io, maxLine, cutSentenceParts(sentence, maxLine - 2), "Bus Summary")
    summarySubheader(io, maxLine, format["length"])

    summaryBlockHeader(io, format["length"], "Bus Voltage")
    summaryBlock(io, format["θ"], format["length"], format["unit"][1], "Angle"; line = true)

    if format["power"]
        if format["device"][1] != 0
            summaryBlockHeader(io, format["length"], "Power Generation")
            summaryBlock(io, format["Ps"], format["length"], format["unit"][2], "Active"; line = true)
        end

        if format["device"][2] != 0
            summaryBlockHeader(io, format["length"], "Power Demand")
            summaryBlock(io, format["Pl"], format["length"], format["unit"][2], "Active"; line = true)
        end

        summaryBlockHeader(io, format["length"], "Power Injection")
        summaryBlock(io, format["Pi"], format["length"], format["unit"][2], "Active"; line = true)
    end
end

"""
    printBranchSummary(system::PowerSystem, analysis::Analysis, io::IO)

The function prints a summary of the electrical quantities related to branches. Optionally,
an `IO` may be passed as the last argument to redirect output.

!!! compat "Julia 1.10"
    The function [`printBranchSummary`](@ref printBranchSummary) requires Julia 1.10 or later.

# Example
```jldoctest
system = powerSystem("case14.h5")

analysis = newtonRaphson(system)
for i = 1:10
    stopping = mismatch!(system, analysis)
    if all(stopping .< 1e-8)
        break
    end
    solve!(system, analysis)
end
power!(system, analysis)

printBranchSummary(system, analysis)
```
"""
function printBranchSummary(system::PowerSystem, analysis::AC, io::IO = stdout)
    format = printFormatBranchSummary(system, analysis)
    Printf.@printf io "\n"

    maxLine = sum(format["length"][:]) + 34

    sentence = "The power system comprises $(system.branch.number) $(plosg("branch", system.branch.number)), of which $(system.branch.layout.inservice) $(isare(system.branch.layout.inservice)) in-service.
        These include $(format["device"][1]) $(plosg("line", format["device"][1]; pl = "s")) ($(format["device"][4]) in-service),
        $(format["device"][2]) $(plosg("in-phase transformer", format["device"][2]; pl = "s")) ($(format["device"][5]) in-service),
        and $(format["device"][3]) $(plosg("phase-shifting transformer", format["device"][3]; pl = "s")) ($(format["device"][6]) in-service)."

    summaryHeader(io, maxLine, cutSentenceParts(sentence, maxLine - 2), "Branch Summary")
    summarySubheader(io, maxLine, format["length"])

    if format["power"]
        summaryBlockHeader(io, format["length"], "From-Bus Power")
        summaryBlock(io, format["Pij"], format["length"], format["unit"][1], "Active")
        summaryBlock(io, format["Qij"], format["length"], format["unit"][2], "Reactive"; line = true)

        summaryBlockHeader(io, format["length"], "To-Bus Power")
        summaryBlock(io, format["Pji"], format["length"], format["unit"][1], "Active")
        summaryBlock(io, format["Qji"], format["length"], format["unit"][2], "Reactive"; line = true)

        summaryBlockHeader(io, format["length"], "Shunt Power")
        summaryBlock(io, format["Pc"], format["length"], format["unit"][1], "Active")
        summaryBlock(io, format["Qc"], format["length"], format["unit"][2], "Reactive"; line = true)

        summaryBlockHeader(io, format["length"], "Series Power")
        summaryBlock(io, format["Pl"], format["length"], format["unit"][1], "Active")
        summaryBlock(io, format["Ql"], format["length"], format["unit"][2], "Reactive"; line = true)
    end

    if format["current"]
        summaryBlockHeader(io, format["length"], "From-Bus Current")
        summaryBlock(io, format["Iij"], format["length"], format["unit"][3], "Magnitude")
        summaryBlock(io, format["ψij"], format["length"], format["unit"][4], "Angle"; line = true)

        summaryBlockHeader(io, format["length"], "To-Bus Current")
        summaryBlock(io, format["Iji"], format["length"], format["unit"][3], "Magnitude")
        summaryBlock(io, format["ψji"], format["length"], format["unit"][4], "Angle"; line = true)

        summaryBlockHeader(io, format["length"], "Series Current")
        summaryBlock(io, format["Is"], format["length"], format["unit"][3], "Magnitude")
        summaryBlock(io, format["ψs"], format["length"], format["unit"][4], "Angle"; line = true)
    end
end

function printBranchSummary(system::PowerSystem, analysis::DC, io::IO = stdout)
    format = printFormatBranchSummary(system, analysis)
    Printf.@printf io "\n"

    maxLine = sum(format["length"][:]) + 34

    sentence = "The power system comprises $(system.branch.number) $(plosg("branch", system.branch.number)), of which $(system.branch.layout.inservice) $(isare(system.branch.layout.inservice)) in-service.
        These include $(format["device"][1]) $(plosg("line", format["device"][1]; pl = "s")) ($(format["device"][4]) in-service),
        $(format["device"][2]) $(plosg("in-phase transformer", format["device"][2]; pl = "s")) ($(format["device"][5]) in-service),
        and $(format["device"][3]) $(plosg("phase-shifting transformer", format["device"][3]; pl = "s")) ($(format["device"][6]) in-service)."

    summaryHeader(io, maxLine, cutSentenceParts(sentence, maxLine - 2), "Branch Summary")
    summarySubheader(io, maxLine, format["length"])

    if format["power"]
        summaryBlockHeader(io, format["length"], "From-Bus Power")
        summaryBlock(io, format["Pij"], format["length"], format["unit"][1], "Active"; line = true)

        summaryBlockHeader(io, format["length"], "To-Bus Power")
        summaryBlock(io, format["Pji"], format["length"], format["unit"][1], "Active"; line = true)
    end
end

"""
    printGeneratorSummary(system::PowerSystem, analysis::Analysis, io::IO)

The function prints a summary of the electrical quantities related to generators.
Optionally, an `IO` may be passed as the last argument to redirect output.

!!! compat "Julia 1.10"
    The function [`printGeneratorSummary`](@ref printGeneratorSummary) requires Julia 1.10 or later.

# Example
```jldoctest
system = powerSystem("case14.h5")

analysis = newtonRaphson(system)
for i = 1:10
    stopping = mismatch!(system, analysis)
    if all(stopping .< 1e-8)
        break
    end
    solve!(system, analysis)
end
power!(system, analysis)

printGeneratorSummary(system, analysis)
```
"""
function printGeneratorSummary(system::PowerSystem, analysis::AC, io::IO = stdout)
    format = printFormatGeneratorSummary(system, analysis)
    Printf.@printf io "\n"

    maxLine = sum(format["length"][:]) + 34

    sentence = "The power system comprises $(system.generator.number) $(plosg("generator", system.generator.number; pl = "s")),
        of which $(system.generator.layout.inservice) $(isare(system.generator.layout.inservice)) in-service."

    summaryHeader(io, maxLine, cutSentenceParts(sentence, maxLine - 2), "Generator Summary")
    summarySubheader(io, maxLine, format["length"])

    if format["power"]
        summaryBlockHeader(io, format["length"], "Output Power")
        summaryBlock(io, format["Pg"], format["length"], format["unit"][1], "Active")
        summaryBlock(io, format["Qg"], format["length"], format["unit"][2], "Reactive"; line = true)
    end
end

function printGeneratorSummary(system::PowerSystem, analysis::DC, io::IO = stdout)
    format = printFormatGeneratorSummary(system, analysis)
    Printf.@printf io "\n"

    maxLine = sum(format["length"][:]) + 34

    sentence = "The power system comprises $(system.generator.number) $(plosg("generator", system.generator.number; pl = "s")),
        of which $(system.generator.layout.inservice) $(isare(system.generator.layout.inservice)) in-service."

    summaryHeader(io, maxLine, cutSentenceParts(sentence, maxLine - 2), "Generator Summary")
    summarySubheader(io, maxLine, format["length"])

    if format["power"]
        summaryBlockHeader(io, format["length"], "Output Power")
        summaryBlock(io, format["Pg"], format["length"], format["unit"][1], "Active"; line = true)
    end
end

Base.@kwdef mutable struct SummaryData
    idxMin::Int64 = -1
    min::Float64 = Inf
    idxMax::Int64 = -1
    max::Float64 = -Inf
    total::Float64 = 0.0
    strmin::String = ""
    labelmin::String = ""
    strmax::String = ""
    labelmax::String = ""
    strtotal::String = "-"
end

function printFormatBusSummary(system::PowerSystem, analysis::AC)
    format = Dict(
        "V" => SummaryData(), "θ" => SummaryData(),
        "Ps" => SummaryData(), "Qs" => SummaryData(),
        "Pl" => SummaryData(), "Ql" => SummaryData(),
        "Pi" => SummaryData(), "Qi" => SummaryData(),
        "Ph" => SummaryData(), "Qh" => SummaryData(),
        "I" => SummaryData(), "ψ" => SummaryData(),
        "scale" => [1.0; 1.0; 1.0; 1.0; 1.0; 1.0],
        "unit" => ["[pu]"; "[rad]"; "[pu]"; "[pu]"; "[pu]"; "[rad]"],
        "length" => [0; 0; 0; 0; 5],
        "device" => [0; 0; 0],
        "power" => !isempty(analysis.power.injection.active),
        "current" => !isempty(analysis.current.injection.magnitude)
    )

    if prefix.voltageMagnitude != 0.0
        format["unit"][1] = "[$(findKey(prefixList, prefix.voltageMagnitude))V]"
    end

    if prefix.voltageAngle != 0.0
        format["unit"][2] = "[deg]"
        format["scale"][2] = 1 / prefix.voltageAngle
    end

    if prefix.activePower != 0.0
        format["unit"][3] = "[$(findKey(prefixList, prefix.activePower))W]"
        format["scale"][3] = system.base.power.value * system.base.power.prefix / prefix.activePower
    end

    if prefix.reactivePower != 0.0
        format["unit"][4] = "[$(findKey(prefixList, prefix.reactivePower))VAr]"
        format["scale"][4] = system.base.power.value * system.base.power.prefix / prefix.reactivePower
    end

    if prefix.currentMagnitude != 0.0
        format["unit"][5] = "[$(findKey(prefixList, prefix.currentMagnitude))A]"
    end

    if prefix.currentAngle != 0.0
        format["unit"][6] = "[deg]"
        format["scale"][6] = 1 / prefix.currentAngle
    end

    for i = 1:system.bus.number
        if prefix.voltageMagnitude != 0.0
            voltageMagnitude = (analysis.voltage.magnitude[i]) * (system.base.voltage.value[i] * system.base.voltage.prefix) / prefix.voltageMagnitude
        else
            voltageMagnitude = analysis.voltage.magnitude[i]
        end

        minmaxsumPrint!(format["V"], voltageMagnitude, i)
        minmaxsumPrint!(format["θ"], analysis.voltage.angle[i], i)

        if !isempty(system.bus.supply.generator[i])
            format["device"][1] += 1
        end

        if system.bus.demand.active[i] != 0.0 || system.bus.demand.reactive[i] != 0.0
            format["device"][2] += 1
        end

        if system.bus.shunt.conductance[i] != 0.0 || system.bus.shunt.susceptance[i] != 0.0
            format["device"][3] += 1
        end

        if format["power"]
            if !isempty(system.bus.supply.generator[i])
                minmaxsumPrint!(format["Ps"], analysis.power.supply.active[i], i)
                minmaxsumPrint!(format["Qs"], analysis.power.supply.reactive[i], i)
            end

            if system.bus.demand.active[i] != 0.0 || system.bus.demand.reactive[i] != 0.0
                minmaxsumPrint!(format["Pl"], system.bus.demand.active[i], i)
                minmaxsumPrint!(format["Ql"], system.bus.demand.reactive[i], i)
            end

            minmaxsumPrint!(format["Pi"], analysis.power.injection.active[i], i)
            minmaxsumPrint!(format["Qi"], analysis.power.injection.reactive[i], i)

            if system.bus.shunt.conductance[i] != 0.0 || system.bus.shunt.susceptance[i] != 0.0
                minmaxsumPrint!(format["Ph"], analysis.power.shunt.active[i], i)
                minmaxsumPrint!(format["Qh"], analysis.power.shunt.reactive[i], i)
            end
        end

        if format["current"]
            if prefix.currentMagnitude != 0.0
                currentMagnitude = analysis.current.injection.magnitude[i] * system.base.power.value * system.base.power.prefix / (sqrt(3) * system.base.voltage.value[i] * system.base.voltage.prefix * prefix.currentMagnitude)
            else
                currentMagnitude = analysis.current.injection.magnitude[i]
            end

            minmaxsumPrint!(format["I"], currentMagnitude, i)
            minmaxsumPrint!(format["ψ"], analysis.current.injection.angle[i], i)
        end
    end

    formatSummary!(format["V"], format["length"], system.bus.label, 1.0; total = false)
    formatSummary!(format["θ"], format["length"], system.bus.label, format["scale"][2]; total = false)

    if format["power"]
        if format["device"][1] != 0
            formatSummary!(format["Ps"], format["length"], system.bus.label, format["scale"][3])
            formatSummary!(format["Qs"], format["length"], system.bus.label, format["scale"][4])
        end

        if format["device"][2] != 0
            formatSummary!(format["Pl"], format["length"], system.bus.label, format["scale"][3])
            formatSummary!(format["Ql"], format["length"], system.bus.label, format["scale"][4])
        end

        formatSummary!(format["Pi"], format["length"], system.bus.label, format["scale"][3])
        formatSummary!(format["Qi"], format["length"], system.bus.label, format["scale"][4])

        if format["device"][3] != 0
            formatSummary!(format["Ph"], format["length"], system.bus.label, format["scale"][3])
            formatSummary!(format["Qh"], format["length"], system.bus.label, format["scale"][4])
        end
    end

    if format["current"]
        formatSummary!(format["I"], format["length"], system.bus.label, format["scale"][5]; total = false)
        formatSummary!(format["ψ"], format["length"], system.bus.label, format["scale"][6]; total = false)
    end

    return format
end

function printFormatBusSummary(system::PowerSystem, analysis::DC)
    format = Dict(
        "θ" => SummaryData(),
        "Ps" => SummaryData(),
        "Pl" => SummaryData(),
        "Pi" => SummaryData(),
        "scale" => [1.0; 1.0],
        "unit" => ["[rad]"; "[pu]"],
        "length" => [0; 0; 0; 0; 5],
        "device" => [0; 0; 0],
        "power" => !isempty(analysis.power.injection.active),
    )

    if prefix.voltageAngle != 0.0
        format["unit"][1] = "[deg]"
        format["scale"][1] = 1 / prefix.voltageAngle
    end

    if prefix.activePower != 0.0
        format["unit"][2] = "[$(findKey(prefixList, prefix.activePower))W]"
        format["scale"][2] = system.base.power.value * system.base.power.prefix / prefix.activePower
    end

    for i = 1:system.bus.number
        minmaxsumPrint!(format["θ"], analysis.voltage.angle[i], i)

        if !isempty(system.bus.supply.generator[i])
            format["device"][1] += 1
        end

        if system.bus.demand.active[i] != 0.0 || system.bus.demand.reactive[i] != 0.0
            format["device"][2] += 1
        end

        if system.bus.shunt.conductance[i] != 0.0 || system.bus.shunt.susceptance[i] != 0.0
            format["device"][3] += 1
        end

        if format["power"]
            if !isempty(system.bus.supply.generator[i])
                minmaxsumPrint!(format["Ps"], analysis.power.supply.active[i], i)
            end

            if system.bus.demand.active[i] != 0.0 || system.bus.demand.reactive[i] != 0.0
                minmaxsumPrint!(format["Pl"], system.bus.demand.active[i], i)
            end

            minmaxsumPrint!(format["Pi"], analysis.power.injection.active[i], i)
        end
    end

    formatSummary!(format["θ"], format["length"], system.bus.label, format["scale"][1]; total = false)

    if format["power"]
        if format["device"][1] != 0
            formatSummary!(format["Ps"], format["length"], system.bus.label, format["scale"][2])
        end

        if format["device"][2] != 0
            formatSummary!(format["Pl"], format["length"], system.bus.label, format["scale"][2])
        end

        formatSummary!(format["Pi"], format["length"], system.bus.label, format["scale"][2])
    end

    return format
end

function printFormatBranchSummary(system::PowerSystem, analysis::AC)
    format = Dict(
        "Pij" => SummaryData(), "Qij" => SummaryData(),
        "Pji" => SummaryData(), "Qji" => SummaryData(),
        "Pc" => SummaryData(), "Qc" => SummaryData(),
        "Pl" => SummaryData(), "Ql" => SummaryData(),
        "Ph" => SummaryData(), "Qh" => SummaryData(),
        "Iij" => SummaryData(), "ψij" => SummaryData(),
        "Iji" => SummaryData(), "ψji" => SummaryData(),
        "Is" => SummaryData(), "ψs" => SummaryData(),
        "scale" => [1.0; 1.0; 1.0; 1.0; 1.0; 1.0],
        "unit" => ["[pu]"; "[rad]"; "[pu]"; "[pu]"; "[pu]"; "[rad]"],
        "length" => [0; 0; 0; 0; 5],
        "device" => [0; 0; 0; 0; 0; 0],
        "power" => !isempty(analysis.power.injection.active),
        "current" => !isempty(analysis.current.injection.magnitude)
    )

    if prefix.activePower != 0.0
        format["unit"][1] = "[$(findKey(prefixList, prefix.activePower))W]"
        format["scale"][1] = system.base.power.value * system.base.power.prefix / prefix.activePower
    end

    if prefix.reactivePower != 0.0
        format["unit"][2] = "[$(findKey(prefixList, prefix.reactivePower))VAr]"
        format["scale"][2] = system.base.power.value * system.base.power.prefix / prefix.reactivePower
    end

    if prefix.currentMagnitude != 0.0
        format["unit"][3] = "[$(findKey(prefixList, prefix.currentMagnitude))A]"
    end

    if prefix.currentAngle != 0.0
        format["unit"][4] = "[deg]"
        format["scale"][4] = 1 / prefix.currentAngle
    end

    for i = 1:system.branch.number
        if system.branch.parameter.turnsRatio[i] == 1 && system.branch.parameter.shiftAngle[i] == 0
            format["device"][1] += 1
            if system.branch.layout.status[i] == 1
                format["device"][4] += 1
            end
        elseif system.branch.parameter.turnsRatio[i] != 1 && system.branch.parameter.shiftAngle[i] == 0
            format["device"][2] += 1
            if system.branch.layout.status[i] == 1
                format["device"][5] += 1
            end
        else
            format["device"][3] += 1
            if system.branch.layout.status[i] == 1
                format["device"][6] += 1
            end
        end

        if system.branch.layout.status[i] == 1
            if format["power"]
                minmaxsumPrint!(format["Pij"], analysis.power.from.active[i], i)
                minmaxsumPrint!(format["Qij"], analysis.power.from.reactive[i], i)

                minmaxsumPrint!(format["Pji"], analysis.power.to.active[i], i)
                minmaxsumPrint!(format["Qji"], analysis.power.to.reactive[i], i)

                if system.branch.parameter.conductance[i] != 0.0 || system.branch.parameter.susceptance[i] != 0.0
                    minmaxsumPrint!(format["Pc"], analysis.power.charging.active[i], i)
                    minmaxsumPrint!(format["Qc"], analysis.power.charging.reactive[i], i)
                end

                minmaxsumPrint!(format["Pl"], analysis.power.series.active[i], i)
                minmaxsumPrint!(format["Ql"], analysis.power.series.reactive[i], i)
            end

            if format["current"]
                from = system.branch.layout.from[i]
                to = system.branch.layout.to[i]
                if prefix.currentMagnitude != 0.0
                    currentFrom = analysis.current.from.magnitude[i] * system.base.power.value * system.base.power.prefix / (sqrt(3) * system.base.voltage.value[from] * system.base.voltage.prefix * prefix.currentMagnitude)
                    currentTo = analysis.current.to.magnitude[i] * system.base.power.value * system.base.power.prefix / (sqrt(3) * system.base.voltage.value[to] * system.base.voltage.prefix * prefix.currentMagnitude)
                    currentSeries = analysis.current.series.magnitude[i] * system.base.power.value * system.base.power.prefix / (sqrt(3) * system.base.voltage.value[from] * system.base.voltage.prefix * prefix.currentMagnitude)
                else
                    currentFrom = analysis.current.from.magnitude[i]
                    currentTo = analysis.current.to.magnitude[i]
                    currentSeries = analysis.current.series.magnitude[i]
                end

                minmaxsumPrint!(format["Iij"], currentFrom, i)
                minmaxsumPrint!(format["ψij"], analysis.current.from.angle[i], i)

                minmaxsumPrint!(format["Iji"], currentTo, i)
                minmaxsumPrint!(format["ψji"], analysis.current.to.angle[i], i)

                minmaxsumPrint!(format["Is"], currentSeries, i)
                minmaxsumPrint!(format["ψs"], analysis.current.series.angle[i], i)
            end
        end
    end

    if format["power"]
        formatSummary!(format["Pij"], format["length"], system.branch.label, format["scale"][1]; total = false)
        formatSummary!(format["Qij"], format["length"], system.branch.label, format["scale"][2]; total = false)

        formatSummary!(format["Pji"], format["length"], system.branch.label, format["scale"][1]; total = false)
        formatSummary!(format["Qji"], format["length"], system.branch.label, format["scale"][2]; total = false)

        formatSummary!(format["Pc"], format["length"], system.branch.label, format["scale"][1])
        formatSummary!(format["Qc"], format["length"], system.branch.label, format["scale"][2])

        formatSummary!(format["Pl"], format["length"], system.branch.label, format["scale"][1])
        formatSummary!(format["Ql"], format["length"], system.branch.label, format["scale"][2])
    end

    if format["current"]
        formatSummary!(format["Iij"], format["length"], system.branch.label, format["scale"][3]; total = false)
        formatSummary!(format["ψij"], format["length"], system.branch.label, format["scale"][4]; total = false)

        formatSummary!(format["Iji"], format["length"], system.branch.label, format["scale"][3]; total = false)
        formatSummary!(format["ψji"], format["length"], system.branch.label, format["scale"][4]; total = false)

        formatSummary!(format["Is"], format["length"], system.branch.label, format["scale"][3]; total = false)
        formatSummary!(format["ψs"], format["length"], system.branch.label, format["scale"][4]; total = false)
    end

    return format
end

function printFormatBranchSummary(system::PowerSystem, analysis::DC)
    format = Dict(
        "Pij" => SummaryData(),
        "Pji" => SummaryData(),
        "scale" => [1.0],
        "unit" => ["[pu]"],
        "length" => [0; 0; 0; 0; 5],
        "device" => [0; 0; 0; 0; 0; 0],
        "power" => !isempty(analysis.power.injection.active),
    )

    if prefix.activePower != 0.0
        format["unit"][1] = "[$(findKey(prefixList, prefix.activePower))W]"
        format["scale"][1] = system.base.power.value * system.base.power.prefix / prefix.activePower
    end

    for i = 1:system.branch.number
        if system.branch.parameter.turnsRatio[i] == 1 && system.branch.parameter.shiftAngle[i] == 0
            format["device"][1] += 1
            if system.branch.layout.status[i] == 1
                format["device"][4] += 1
            end
        elseif system.branch.parameter.turnsRatio[i] != 1 && system.branch.parameter.shiftAngle[i] == 0
            format["device"][2] += 1
            if system.branch.layout.status[i] == 1
                format["device"][5] += 1
            end
        else
            format["device"][3] += 1
            if system.branch.layout.status[i] == 1
                format["device"][6] += 1
            end
        end

        if format["power"]
            if system.branch.layout.status[i] == 1
                minmaxsumPrint!(format["Pij"], analysis.power.from.active[i], i)
                minmaxsumPrint!(format["Pji"], analysis.power.to.active[i], i)
            end
        end
    end

    if format["power"]
        formatSummary!(format["Pij"], format["length"], system.branch.label, format["scale"][1]; total = false)
        formatSummary!(format["Pji"], format["length"], system.branch.label, format["scale"][1]; total = false)
    end

    return format
end

function printFormatGeneratorSummary(system::PowerSystem, analysis::AC)
    format = Dict(
        "Pg" => SummaryData(), "Qg" => SummaryData(),
        "scale" => [1.0; 1.0],
        "unit" => ["[pu]"; "[pu]"],
        "length" => [0; 0; 0; 0; 5],
        "device" => [0; 0; 0],
        "power" => !isempty(analysis.power.generator.active),
    )

    if prefix.activePower != 0.0
        format["unit"][1] = "[$(findKey(prefixList, prefix.activePower))W]"
        format["scale"][1] = system.base.power.value * system.base.power.prefix / prefix.activePower
    end

    if prefix.reactivePower != 0.0
        format["unit"][2] = "[$(findKey(prefixList, prefix.reactivePower))VAr]"
        format["scale"][2] = system.base.power.value * system.base.power.prefix / prefix.reactivePower
    end

    if format["power"]
        for i = 1:system.generator.number
            if system.generator.layout.status[i] == 1
                minmaxsumPrint!(format["Pg"], analysis.power.generator.active[i], i)
                minmaxsumPrint!(format["Qg"], analysis.power.generator.reactive[i], i)
            end
        end
        formatSummary!(format["Pg"], format["length"], system.bus.label, format["scale"][1])
        formatSummary!(format["Qg"], format["length"], system.bus.label, format["scale"][2])
    end

    return format
end

function printFormatGeneratorSummary(system::PowerSystem, analysis::DC)
    format = Dict(
        "Pg" => SummaryData(), "Qg" => SummaryData(),
        "scale" => [1.0],
        "unit" => ["[pu]"],
        "length" => [0; 0; 0; 0; 5],
        "device" => [0; 0; 0],
        "power" => !isempty(analysis.power.generator.active),
    )

    if prefix.activePower != 0.0
        format["unit"][1] = "[$(findKey(prefixList, prefix.activePower))W]"
        format["scale"][1] = system.base.power.value * system.base.power.prefix / prefix.activePower
    end

    if format["power"]
        for i = 1:system.generator.number
            if system.generator.layout.status[i] == 1
                minmaxsumPrint!(format["Pg"], analysis.power.generator.active[i], i)
            end
        end
        formatSummary!(format["Pg"], format["length"], system.bus.label, format["scale"][1])
    end

    return format
end


function plosg(word::String, count::Int; pl = "es")
    if count == 1
        return word
    else
        return word * pl
    end
end

function isare(count::Int)
    if count == 1
        return "is"
    else
        return "are"
    end
end

function justifyLine(words::Vector{String}, max_length::Int)
    if length(words) == 1
        return words[1]
    end
    total_length = sum(length, words)
    total_spaces = max_length - total_length
    num_gaps = length(words) - 1
    even_space = div(total_spaces, num_gaps)
    extra_space = mod(total_spaces, num_gaps)

    justified_line = ""
    for (i, word) in enumerate(words)
        justified_line *= word
        if i < length(words)
            justified_line *= " " ^ (even_space + (i <= extra_space ? 1 : 0))
        end
    end
    return justified_line
end

function cutSentenceParts(sentence::String, max_points::Int)
    words = split(sentence)
    parts = String[]
    current_part = String[]
    current_length = 0

    for word in words
        word_length = length(word)
        if current_length + word_length + (current_length == 0 ? 0 : 1) > max_points
            push!(parts, justifyLine(current_part, max_points))
            current_part = String[]
            current_length = 0
        end
        push!(current_part, word)
        current_length += word_length + (current_length == 0 ? 0 : 1)
    end
    if !isempty(current_part)
        push!(parts, join(current_part, " "))
    end

    return parts
end

function minmaxsumPrint!(data::SummaryData, value::Float64, i::Int64)
    if value < data.min || data.idxMin == -1
        data.min = value
        data.idxMin = i
    end

    if value > data.max || data.idxMax == -1
        data.max = value
        data.idxMax = i
    end

    data.total += value
end

function formatSummary!(data::SummaryData, span::Array{Int64,1}, label, scale; total = true)
    data.labelmin = iterate(label, data.idxMin)[1][1]
    data.strmin = Printf.@sprintf("%.4f", data.min * scale)

    data.labelmax = iterate(label, data.idxMax)[1][1]
    data.strmax = Printf.@sprintf("%.4f", data.max * scale)

    span[1] = max(span[1], length(data.labelmin))
    span[2] = max(span[2], length(data.strmin))
    span[3] = max(span[3], length(data.labelmax))
    span[4] = max(span[4], length(data.strmax))

    if total
        data.strtotal = Printf.@sprintf("%.4f", data.total * scale)
        span[5] = max(span[5], length(data.strtotal))
    end
end

function summaryHeader(io::IO, maxLine::Int64, sentence::Array{String,1}, header::String)
    Printf.@printf(io, "|%s|\n", "-"^maxLine)
    Printf.@printf(io, "| %s %*s |\n", header, maxLine - length(header) - 3, "")
    for part in sentence
        Printf.@printf(io, "| %s %*s|\n", part, maxLine - 2 - length(part), "")
    end
    Printf.@printf(io, "|%s|\n", "-"^maxLine)
end

function summarySubheader(io::IO, maxLine::Int64, span::Array{Int64,1})
    Printf.@printf(io, "| %*s | %*s%s%*s | %*s%s%*s | %*s%s%*s |\n",
        17, "",
        floor(Int, (span[1] + span[2] - 4) / 2), "", "Minimum", ceil(Int, (span[1] + span[2] - 4) / 2) , "",
        floor(Int, (span[3] + span[4] - 4) / 2), "", "Maximum", ceil(Int, (span[3] + span[4] - 4) / 2) , "",
        floor(Int, (span[5] - 5) / 2), "", "Total", ceil(Int, (span[5] - 5) / 2) , "",
    )
    Printf.@printf(io, "|%s|\n", "-"^maxLine)
end

function summaryBlockHeader(io::IO, span::Array{Int64,1}, header::String)
    Printf.@printf(io, "| %s | %*s%s%*s | %*s%s%*s | %*s%s%*s |\n",
        header * " "^(17 - length(header)),
        floor(Int, (span[1] + span[2] + 3) / 2), "", "", ceil(Int, (span[1] + span[2] + 3) / 2) , "",
        floor(Int, (span[3] + span[4] + 3) / 2), "", "", ceil(Int, (span[3] + span[4] + 3) / 2) , "",
        floor(Int, (span[5]) / 2), "", "", ceil(Int, (span[5]) / 2) , "",
    )
end

function summaryBlock(io::IO, data1::SummaryData, span::Array{Int64,1}, unit::String, subHeader1::String; line = false)
    subHeader1 = string(" ", subHeader1, " ", unit)

    Printf.@printf(io, "| %s | %*s | %*s | %*s | %*s | %*s |\n",
        subHeader1 * " "^(17 - length(subHeader1)),
        span[1], data1.labelmin,
        span[2], data1.strmin,
        span[3], data1.labelmax,
        span[4], data1.strmax,
        span[5], data1.strtotal,
    )

    if line
        Printf.@printf(io, "|%s|\n", "-"^(sum(span[:]) + 34))
    end
end

function printTitle(maxLine::Int64, title::String, io::IO)
    Printf.@printf(io, "\n|%s|\n", "-"^maxLine)
    Printf.@printf(io, "| %s%*s|\n", title, maxLine - length(title) - 1, "")
    Printf.@printf(io, "|%s|\n", "-"^maxLine)
end