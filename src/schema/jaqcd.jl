using Configurations

abstract type JAQCDInstruction <: BraketSchema end

for name in [:H, :I, :X, :Y, :Z, :S, :T, :Si, :Ti]
    @eval @option struct $name <: JAQCDInstruction
        type::String = $(lowercase(string(name)))
        target::Int
    end

    @eval nqubits(::$name) = 1
end

for name in [:Rx, :Ry, :Rz]
    @eval @option struct $name <: JAQCDInstruction
        type::String = $(lowercase(string(name)))
        target::Int
        angle::Float64
    end

    @eval nqubits(::$name) = 1
end

for name in [:Swap, :CSwap, :ISwap]
    @eval @option struct $name <: JAQCDInstruction
        type::String = $(lowercase(string(name)))
        targets::Vector{Int}
    end

    @eval nqubits(::$name) = 2
end

for name in [:PSwap, :XY]
    @eval @option struct $name <: JAQCDInstruction
        type::String = $(lowercase(string(name)))
        angle::Float64
        targets::Vector{Int}
    end

    @eval nqubits(::$name) = 2
end

@option struct PhaseShift <: JAQCDInstruction
    type::String = "phaseshift"
    angle::Float64
    target::Int
end

nqubits(::PhaseShift) = 1

for name in [:CPhaseShift, :CPhaseShift00, :CPhaseShift01, :CPhaseShift10]
    @eval @option struct $name <: JAQCDInstruction
        type::String = $(lowercase(string(name)))
        control::Int
        angle::Float64
        target::Int
    end

    @eval nqubits(::$name) = 2
end

@option struct CNot <: JAQCDInstruction
    type::String = "cnot"
    control::Int
    target::Int
end

nqubits(::CNot) = 2

@option struct CZ <: JAQCDInstruction
    type::String = "cz"
    control::Int
    target::Int
end

nqubits(::CZ) = 2

@option struct XX <: JAQCDInstruction
    type::String = "xx"
    targets::Vector{Int}
    angle::Float64
end

nqubits(::XX) = 2

@option struct YY <: JAQCDInstruction
    type::String = "yy"
    targets::Vector{Int}
    angle::Float64
end

nqubits(::YY) = 2

@option struct ZZ <: JAQCDInstruction
    type::String = "zz"
    targets::Vector{Int}
    angle::Float64
end

nqubits(::ZZ) = 2

@option struct V <: JAQCDInstruction
    type::String = "v"
    target::Int
end

nqubits(::V) = 1

@option struct Vi <: JAQCDInstruction
    type::String = "vi"
    target::Int
end

nqubits(::Vi) = 1

@option struct Unitary <: JAQCDInstruction
    type::String = "unitary"
    targets::Vector{Int}
    matrix::Matrix{ComplexF64}
end

nqubits(x::Unitary) = length(x.targets)

function Configurations.to_dict(::Type{Unitary}, m::Matrix{ComplexF64})
    m_re = [collect(T, real(row)) for row in eachrow(m)]
    m_im = [collect(T, imag(row)) for row in eachrow(m)]
    return [m_re, m_im]
end

@option struct BitFlip <: JAQCDInstruction
    type::String = "bit_flip"
    target::Int
end

nqubits(::BitFlip) = 1

@option struct PhaseFlip <: JAQCDInstruction
    type::String = "phase_flip"
    target::Int
end

nqubits(::PhaseFlip) = 1

@option struct PauliChannel <: JAQCDInstruction
    type::String = "pauli_channel"
    target::Int
end

nqubits(::PauliChannel) = 1

@option struct Depolarizing <: JAQCDInstruction
    type::String = "depolarizing"
    target::Int
end

nqubits(::Depolarizing) = 1

@option struct TwoQubitDepolarizing <: JAQCDInstruction
    type::String = "two_qubit_depolarizing"
    target::Int
end

nqubits(::TwoQubitDepolarizing) = 1

@option struct TwoQubitDephasing <: JAQCDInstruction
    type::String = "two_qubit_dephasing"
    target::Int
end

nqubits(::TwoQubitDephasing) = 1

@option struct AmplitudeDamping <: JAQCDInstruction
    type::String = "amplitude_damping"
    target::Int
end

nqubits(::AmplitudeDamping) = 1

@option struct GeneralizedAmplitudeDamping <: JAQCDInstruction
    type::String = "generalized_amplitude_damping"
    target::Int
end

nqubits(::GeneralizedAmplitudeDamping) = 1

@option struct PhaseDamping <: JAQCDInstruction
    type::String = "phase_damping"
    target::Int
end

nqubits(::PhaseDamping) = 1

@option struct Kraus <: JAQCDInstruction
    type::String = "kraus"
    targets::Vector{Int}
    matrices::Vector{Matrix{ComplexF64}}
end

nqubits(x::Kraus) = length(x.targets)

function Configurations.to_dict(::Type{Kraus}, xs::Vector{Matrix{ComplexF64}})
    return map(xs) do m
        m_re = [collect(T, real(row)) for row in eachrow(m)]
        m_im = [collect(T, imag(row)) for row in eachrow(m)]
        return [m_re, m_im]
    end
end

@enum JAQCDResultType begin
    EXPECTATION
    SAMPLE
    VARIANCE
    STATEVECTOR
    AMPLITUDE
    PROBABILITY
end

@option struct Results <: BraketSchema
    type::JAQCDResultType
    targets::Maybe{Vector{Int}} = nothing
    # NOTE: what's the rule between expectation observable and targets?
    observable::Maybe{Vector{T} where {T <: Union{String, Matrix{Float64}}}} = nothing
    states::Maybe{Vector{String}} = nothing
end

function Base.convert(::Type{JAQCDResultType}, x::String)
    result_map = Dict(
        "expectation" => EXPECTATION,
        "sample" => SAMPLE,
        "variance" => VARIANCE,
        "statevector" => STATEVECTOR,
        "amplitude" => AMPLITUDE,
        "probability" => PROBABILITY,
    )
    haskey(result_map, x) || error("do not have result type: $x")
    return result_map[x]
end

@option struct Program <: BraketSchema
    braketSchemaHeader::Header = Header(name="braket.ir.jaqcd.program", version=v"1")
    instructions::Vector{Any}
    results::Vector{Results} = Results[]
    basis_rotation_instructions::Vector{Any} = []
end

# TODO: support field name selector in upstream
function Configurations.to_dict(::Type{Program}, insts::Vector{Any}, option::Configurations.ConvertOption)
    map(insts) do inst
        to_dict(typeof(inst), inst, option)
    end
end

function count_qubits(prog::Program)
    count = 0
    for inst in prog.instructions
        count += nqubits(inst)
    end
    return count
end
