module JAQCD

using Configurations

for each in [:H, :I, :X, :Y, :Z, :S, :T, :Si, :Ti]
    @eval @option struct $each
        type::String = $(lowercase(string(name)))
        target::Int
    end
end

for each in [:Rx, :Ry, :Rz]
    @eval @option struct $each
        type::String = $(lowercase(string(name)))
        target::Int
        angle::Float64
    end
end

for each in [:Swap, :CSwap, :ISwap]
    @eval @option struct $each
        type::String = $(lowercase(string(each)))
        targets::Vector{Int}
    end
end

for each in [:PSwap, :XY, :PhaseShift]
    @eval @option struct $each
        type::String = $(lowercase(string(each)))
        angle::Float64
        targets::Vector{Int}
    end
end

for each in [:CPhaseShift, :CPhaseShift00, :CPhaseShift01, :CPhaseShift10]
    @eval @option struct $each
        type::String = $(lowercase(string(each)))
        control::Int
        angle::Float64
        target::Int
    end
end

@option struct CNot
    type::String = "cnot"
    control::Int
    target::Int
end

@option struct CZ
    type::String = "cz"
    control::Int
    target::Int
end

@option struct XX
    type::String = "xx"
    targets::Vector{Int}
    angle::Float64
end

@option struct YY
    type::String = "yy"
    targets::Vector{Int}
    angle::Float64
end

@option struct ZZ
    type::String = "zz"
    targets::Vector{Int}
    angle::Float64
end

@option struct V
    type::String = "v"
    target::Int
end

@option struct Vi
    type::String = "vi"
    target::Int
end

@option struct Unitary
    type::String = "unitary"
    targets::Vector{Int}
    matrix::Vector{Vector{Float64}}
end

end
