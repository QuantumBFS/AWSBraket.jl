for each in [:Expectation, :Sample, :Variance]
    @eval @option struct $each
        type::String = $(lowercase(string(each)))
        targets::Maybe{Vector{Int}} = nothing
        observable::Union{String, Matrix{Float64}}
    end
end

struct StateVector
    type::String = "statevector"
end

struct Amplitude
    type::String = "amplitude"
    states::Vector{String}
end

struct Probability
    type::String = "probability"
    targets::Maybe{Vector{Int}} = nothing
end

const Results = Union{Amplitude, Expectation, Probability, Sample, StateVector, Variance}
