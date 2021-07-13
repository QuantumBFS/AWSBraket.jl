module Schema

export DeviceInfo

using Dates
using UUIDs
using GarishPrint
using Configurations

abstract type BraketSchema end

Base.show(io::IO, x::BraketSchema) = pprint_struct(io, x)

include("device.jl")
include("jaqcd.jl")
include("task.jl")

end
