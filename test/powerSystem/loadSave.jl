@testset "powerSystem, savePowerSystem" begin
    systemMat = powerSystem(string(pathData, "case14test.m"))
    savePowerSystem(systemMat; path = string(pathData, "case14test.h5"))
    systemH5 = powerSystem(string(pathData, "case14test.h5"))

    ######## Bus Data ##########
    @test systemMat.bus.label == systemH5.bus.label
    @test systemMat.bus.number == systemH5.bus.number

    @test systemMat.bus.layout.type == systemH5.bus.layout.type
    @test systemMat.bus.layout.area == systemH5.bus.layout.area
    @test systemMat.bus.layout.lossZone == systemH5.bus.layout.lossZone
    @test systemMat.bus.layout.slackIndex == systemH5.bus.layout.slackIndex
    @test systemMat.bus.layout.slackImmutable == systemH5.bus.layout.slackImmutable
    @test systemMat.bus.layout.renumbering == systemH5.bus.layout.renumbering

    @test systemMat.bus.demand.active == systemH5.bus.demand.active
    @test systemMat.bus.demand.reactive == systemH5.bus.demand.reactive

    @test systemMat.bus.shunt.conductance == systemH5.bus.shunt.conductance
    @test systemMat.bus.shunt.susceptance == systemH5.bus.shunt.susceptance

    @test systemMat.bus.voltage.magnitude == systemH5.bus.voltage.magnitude
    @test systemMat.bus.voltage.angle == systemH5.bus.voltage.angle
    @test systemMat.bus.voltage.minMagnitude == systemH5.bus.voltage.minMagnitude
    @test systemMat.bus.voltage.maxMagnitude == systemH5.bus.voltage.maxMagnitude
    @test systemMat.bus.voltage.base == systemH5.bus.voltage.base

    @test systemMat.bus.supply.active == systemH5.bus.supply.active
    @test systemMat.bus.supply.reactive == systemH5.bus.supply.reactive
    @test systemMat.bus.supply.inService == systemH5.bus.supply.inService

    ######## Branch Data ##########
    @test systemMat.branch.label == systemH5.branch.label
    @test systemMat.branch.number == systemH5.branch.number

    @test systemMat.branch.layout.from == systemH5.branch.layout.from
    @test systemMat.branch.layout.to == systemH5.branch.layout.to
    @test systemMat.branch.layout.status == systemH5.branch.layout.status
    @test systemMat.branch.layout.renumbering == systemH5.branch.layout.renumbering

    @test systemMat.branch.parameter.resistance == systemH5.branch.parameter.resistance
    @test systemMat.branch.parameter.reactance == systemH5.branch.parameter.reactance
    @test systemMat.branch.parameter.susceptance == systemH5.branch.parameter.susceptance
    @test systemMat.branch.parameter.turnsRatio == systemH5.branch.parameter.turnsRatio
    @test systemMat.branch.parameter.shiftAngle == systemH5.branch.parameter.shiftAngle

    @test systemMat.branch.rating.longTerm == systemH5.branch.rating.longTerm
    @test systemMat.branch.rating.shortTerm == systemH5.branch.rating.shortTerm
    @test systemMat.branch.rating.emergency == systemH5.branch.rating.emergency

    @test systemMat.branch.voltage.minAngleDifference == systemH5.branch.voltage.minAngleDifference
    @test systemMat.branch.voltage.maxAngleDifference == systemH5.branch.voltage.maxAngleDifference

    ######## Generator Data ##########
    @test systemMat.generator.label == systemH5.generator.label
    @test systemMat.generator.number == systemH5.generator.number

    @test systemMat.generator.layout.bus == systemH5.generator.layout.bus
    @test systemMat.generator.layout.area == systemH5.generator.layout.area
    @test systemMat.generator.layout.status == systemH5.generator.layout.status

    @test systemMat.generator.output.active == systemH5.generator.output.active
    @test systemMat.generator.output.reactive == systemH5.generator.output.reactive

    @test systemMat.generator.voltage.magnitude == systemH5.generator.voltage.magnitude

    @test systemMat.generator.capability.minActive == systemH5.generator.capability.minActive
    @test systemMat.generator.capability.maxActive == systemH5.generator.capability.maxActive
    @test systemMat.generator.capability.minReactive == systemH5.generator.capability.minReactive
    @test systemMat.generator.capability.maxReactive == systemH5.generator.capability.maxReactive
    @test systemMat.generator.capability.lowerActive == systemH5.generator.capability.lowerActive
    @test systemMat.generator.capability.minReactiveLower == systemH5.generator.capability.minReactiveLower
    @test systemMat.generator.capability.maxReactiveLower == systemH5.generator.capability.maxReactiveLower
    @test systemMat.generator.capability.upperActive == systemH5.generator.capability.upperActive
    @test systemMat.generator.capability.minReactiveUpper == systemH5.generator.capability.minReactiveUpper
    @test systemMat.generator.capability.maxReactiveUpper == systemH5.generator.capability.maxReactiveUpper

    @test systemMat.generator.rampRate.loadFollowing == systemH5.generator.rampRate.loadFollowing
    @test systemMat.generator.rampRate.reserve10minute == systemH5.generator.rampRate.reserve10minute
    @test systemMat.generator.rampRate.reserve30minute == systemH5.generator.rampRate.reserve30minute
    @test systemMat.generator.rampRate.reactiveTimescale == systemH5.generator.rampRate.reactiveTimescale

    @test systemMat.generator.cost.activeModel == systemH5.generator.cost.activeModel
    @test systemMat.generator.cost.activeStartup == systemH5.generator.cost.activeStartup
    @test systemMat.generator.cost.activeShutdown == systemH5.generator.cost.activeShutdown
    @test systemMat.generator.cost.activeDataPoint == systemH5.generator.cost.activeDataPoint
    @test systemMat.generator.cost.activeCoefficient == systemH5.generator.cost.activeCoefficient
    @test systemMat.generator.cost.reactiveModel == systemH5.generator.cost.reactiveModel
    @test systemMat.generator.cost.reactiveStartup == systemH5.generator.cost.reactiveStartup
    @test systemMat.generator.cost.reactiveShutdown == systemH5.generator.cost.reactiveShutdown
    @test systemMat.generator.cost.reactiveDataPoint == systemH5.generator.cost.reactiveDataPoint
    @test systemMat.generator.cost.reactiveCoefficient == systemH5.generator.cost.reactiveCoefficient

    ######## Base Power ##########
    @test systemMat.basePower == systemH5.basePower
end