module Schema

export DeviceInfo

using Dates
using Configurations

include("jaqcd.jl")
include("results.jl")

@option struct DeviceInfo
    providerName::String
    deviceArn::String
    deviceName::String
    deviceType::String
    deviceStatus::String
    deviceCapabilities::String
end

@option struct Header
    name::String
    version::VersionNumber
end

@enum ExecutionDay begin
    EVERYDAY
    WEEKDAYS
    WEEKENDS
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
end

@enum DeviceActionType begin
    JAQCD
    ANNEALING
end

@option struct DeviceExecutionWindow
    executionDay::ExecutionDay
    windowStartHour::Time
    windowEndHour::Time
end

# TODO: use Unitful here
@option struct DeviceCost
    price::Float64
    unit::String
end

@option struct DeviceDocumentation
    imageUrl::Maybe{String} = nothing
    summary::Maybe{String} = nothing
    externalDocumentationUrl::Maybe{String} = nothing
end

@option struct DeviceServiceProperties
    braketSchemaHeader::Header = Header(;name="braket.device_schema.device_service_properties", version=v"1")
    executionWindows::Vector{DeviceExecutionWindow}
    shotsRange::Tuple{Int, Int}
    deviceCost::Maybe{DeviceCost} = nothing
    deviceDocumentation::Maybe{DeviceDocumentation} = nothing
    deviceLocation::Maybe{String} = nothing
    updatedAt::Maybe{DateTime} = nothing
end

@option struct DeviceActionProperties
    version::Vector{VersionNumber}
    actionType::DeviceActionType
end

@option struct ResultType
    name::String
    observables::Maybe{Vector{String}} = nothing
    minShots::Maybe{Int} = nothing
    maxShots::Maybe{Int} = nothing
end

@option struct JaqcdDeviceActionProperties
    version::Vector{VersionNumber}
    actionType::DeviceActionType
    supportedOperations::Vector{String}
    supportedResultTypes::Maybe{Vector{ResultType}} = nothing
    disabledQubitRewiringSupported::Maybe{Bool} = nothing
end

@option struct DeviceCapabilities
    services::DeviceServiceProperties
    action::Dict{DeviceActionType, DeviceActionProperties}
    deviceParameters::Dict{String, Any}
end

@option struct GateModelSimulatorParadigmProperties
    braketSchemaHeader::Header = Header(name="braket.device_schema.simulators.gate_model_simulator_paradigm_properties", version="1")
    qubitCount::Int
end

@option struct GateModelSimulatorDeviceParameters
    braketSchemaHeader::Header = Header(name="braket.device_schema.simulators.gate_model_simulator_device_parameters", version="1")
    paradigmParameters::GateModelParameters
end

@option struct GateModelSimulatorDeviceCapabilities
    braketSchemaHeader::Header = Header(;name="braket.device_schema.simulators.gate_model_simulator_device_capabilities", version=v"1")
    services::DeviceServiceProperties
    action::Dict{DeviceActionType, JaqcdDeviceActionProperties}
    paradigm::GateModelSimulatorParadigmProperties
    deviceParameters::Dict{String, Any}
end

@option struct Program
   braketSchemaHeader::Header = Header(name="braket.ir.jaqcd.program", version=v"1")
   instructions::Vector{Any}
   results::Maybe{Vector{Results}} = nothing
   basis_rotation_instructions::Maybe{Vector{Any}} = nothing
end

end
