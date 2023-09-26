export AC, DC, ACPowerFlow, OptimalPowerFlow
export NewtonRaphson, DCPowerFlow, DCOptimalPowerFlow, ACOptimalPowerFlow

########### Abstract Types ###########
abstract type AC end
abstract type DC end
abstract type ACPowerFlow <: AC end
abstract type OptimalPowerFlow end

########### Powers in the AC Framework ###########
mutable struct Power
    injection::Cartesian
    supply::Cartesian
    shunt::Cartesian
    from::Cartesian
    to::Cartesian
    series::Cartesian
    charging::Cartesian
    generator::Cartesian
end

########### Currents in the AC Framework ###########
mutable struct Current
    injection::Polar
    from::Polar
    to::Polar
    series::Polar
end

########### Powers in the DC Framework ###########
mutable struct DCPower
    injection::CartesianReal
    supply::CartesianReal
    from::CartesianReal
    to::CartesianReal
    generator::CartesianReal
end

########### Newton-Raphson ###########
struct NewtonRaphsonMethod
    jacobian::SparseMatrixCSC{Float64,Int64}
    mismatch::Array{Float64,1}
    increment::Array{Float64,1}
    pq::Array{Int64,1}
    pvpq::Array{Int64,1}
end

struct NewtonRaphson <: ACPowerFlow
    voltage::Polar
    power::Power
    current::Current
    method::NewtonRaphsonMethod
    uuid::UUID
end

########### Fast Newton-Raphson ###########
struct FastNewtonRaphsonModel
    jacobian::SparseMatrixCSC{Float64,Int64}
    mismatch::Array{Float64,1}
    increment::Array{Float64,1}
    factorization::SuiteSparse.UMFPACK.UmfpackLU{Float64, Int64}
end

struct FastNewtonRaphsonMethod
    active::FastNewtonRaphsonModel
    reactive::FastNewtonRaphsonModel
    pq::Array{Int64,1}
    pvpq::Array{Int64,1}
end

struct FastNewtonRaphson <: ACPowerFlow
    voltage::Polar
    power::Power
    current::Current
    method::FastNewtonRaphsonMethod
    uuid::UUID
end

########### Gauss-Seidel ###########
struct GaussSeidelMethod
    voltage::Array{ComplexF64,1}
    pq::Array{Int64,1}
    pv::Array{Int64,1}
end

struct GaussSeidel <: ACPowerFlow
    voltage::Polar
    power::Power
    current::Current
    method::GaussSeidelMethod
    uuid::UUID
end

########### DC Power Flow ###########
struct DCPowerFlow <: DC
    voltage::PolarAngle
    power::DCPower
    factorization::SuiteSparse.CHOLMOD.Factor{Float64}
    uuid::UUID
end

######### Constraints ##########
struct CartesianFlowRef
    from::Dict{Int64, JuMP.ConstraintRef}
    to::Dict{Int64, JuMP.ConstraintRef}
end

struct ACPiecewise
    active::Dict{Int64, Array{JuMP.ConstraintRef,1}}
    reactive::Dict{Int64, Array{JuMP.ConstraintRef,1}}
end

struct CapabilityRef
    active::Dict{Int64, JuMP.ConstraintRef}
    reactive::Dict{Int64, JuMP.ConstraintRef}
    lower::Dict{Int64, JuMP.ConstraintRef}
    upper::Dict{Int64, JuMP.ConstraintRef}
end

struct Constraint
    slack::PolarAngleRef
    balance::CartesianRef
    voltage::PolarRef
    flow::CartesianFlowRef
    capability::CapabilityRef
    piecewise::ACPiecewise
end

######### AC Optimal Power Flow ##########
struct ACVariable
    active::Array{JuMP.VariableRef,1}
    reactive::Array{JuMP.VariableRef,1}
    magnitude::Array{JuMP.VariableRef,1}
    angle::Array{JuMP.VariableRef,1}
    actwise::Dict{Int64, VariableRef}
    reactwise::Dict{Int64, VariableRef}
end

struct ACNonlinear
    active::Dict{Int64, JuMP.NonlinearExpr}
    reactive::Dict{Int64, JuMP.NonlinearExpr}
end

mutable struct ACObjective
    quadratic::JuMP.QuadExpr
    nonlinear::ACNonlinear
end

mutable struct ACOptimalPowerFlow <: AC
    voltage::Polar
    power::Power
    current::Current
    jump::JuMP.Model
    variable::ACVariable
    constraint::Constraint
    objective::ACObjective
    uuid::UUID
end

######### DC Optimal Power Flow ##########
struct DCVariable
    active::Array{JuMP.VariableRef,1}
    angle::Array{JuMP.VariableRef,1}
    actwise::Dict{Int64, VariableRef}
end

struct DCPiecewise
    active::Dict{Int64, Array{JuMP.ConstraintRef,1}}
end

struct DCConstraint
    slack::PolarAngleRef
    balance::CartesianRealRef
    voltage::PolarAngleRef
    flow::CartesianRealRef
    capability::CartesianRealRef
    piecewise::DCPiecewise
end

mutable struct DCOptimalPowerFlow <: DC
    voltage::PolarAngle
    power::DCPower
    jump::JuMP.Model
    variable::DCVariable
    constraint::DCConstraint
    objective::JuMP.QuadExpr
    uuid::UUID
end