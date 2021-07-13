
abstract type BraketDeviceSchema <: BraketSchema end

@option struct Header <: BraketDeviceSchema
    name::String
    version::VersionNumber
end

# NOTE: braket Python implementation is not using semantic versioning?
Configurations.to_dict(::Type{Header}, x::VersionNumber) = string(x.major)

@enum ExecutionDay begin
    EVERYDAY
    WEEKDAYS
    WEEKENDS # shuold be "Weekends" in JSON (instead of "Weekend")?
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

function Base.convert(::Type{DeviceActionType}, x::String)
    if x == "braket.ir.jaqcd.program"
        return JAQCD
    elseif x == "braket.ir.annealing.problem"
        return ANNEALING
    else
        error("invalid value: $x")
    end
end

function Base.convert(::Type{ExecutionDay}, x::String)
    string_map = Dict(
        "Everyday"=>EVERYDAY,
        "Weekdays"=>WEEKDAYS,
        "Weekend"=>WEEKENDS,
        "Monday"=>MONDAY,
        "Tuesday"=>TUESDAY,
        "Wednesday"=>WEDNESDAY,
        "Thursday"=>THURSDAY,
        "Friday"=>FRIDAY,
        "Saturday"=>SATURDAY,
        "Sunday"=>SUNDAY,
    )
    return string_map[x]
end

# TODO: use Unitful here
@option struct DeviceCost  <: BraketDeviceSchema
    price::Float64
    unit::String
end

@option struct DeviceDocumentation  <: BraketDeviceSchema
    imageUrl::Maybe{String} = nothing
    summary::Maybe{String} = nothing
    externalDocumentationUrl::Maybe{String} = nothing
end

@option struct DeviceExecutionWindow  <: BraketDeviceSchema
    executionDay::ExecutionDay
    windowStartHour::Time
    windowEndHour::Time
end

function Configurations.convert_to_option(::Type{DeviceExecutionWindow}, ::Type{Time}, x::String)
    Time(x)
end

@option struct DeviceServiceProperties  <: BraketDeviceSchema
    braketSchemaHeader::Header = Header(;name="braket.device_schema.device_service_properties", version=v"1")
    executionWindows::Vector{DeviceExecutionWindow}
    shotsRange::Tuple{Int, Int}
    deviceCost::Maybe{DeviceCost} = nothing
    deviceDocumentation::Maybe{DeviceDocumentation} = nothing
    deviceLocation::Maybe{String} = nothing
    updatedAt::Maybe{DateTime} = nothing
end

function Configurations.convert_to_option(::Type{DeviceServiceProperties}, ::Type{NTuple{2, Int}}, x::Vector{Any})
    @assert length(x) == 2
    return (x[1], x[2])
end

function Configurations.convert_to_option(::Type{DeviceServiceProperties}, ::Type{DateTime}, x::String)
    DateTime(split(x, '.')[1]) # truncate microsecond etc.
end

@option struct ResultType  <: BraketDeviceSchema
    name::String
    observables::Maybe{Vector{String}} = nothing
    minShots::Maybe{Int} = nothing
    maxShots::Maybe{Int} = nothing
end

@option struct DeviceActionProperties  <: BraketDeviceSchema
    version::Vector{VersionNumber}
    actionType::DeviceActionType
    supportedOperations::Maybe{Vector{String}} = nothing
    supportedResultTypes::Maybe{Vector{ResultType}} = nothing
    disabledQubitRewiringSupported::Maybe{Bool} = nothing
end

@option struct DeviceConnectivity  <: BraketDeviceSchema
    fullyConnected::Bool
    connectivityGraph::Dict{String, Any}
end

@option struct GateModelQpuParadigmProperties <: BraketDeviceSchema
    braketSchemaHeader::Header = Header(;name="braket.device_schema.gate_model_qpu_paradigm_properties", version=v"1")
    qubitCount::Int
    connectivity::Maybe{DeviceConnectivity} = nothing
    nativeGateSet::Maybe{Vector{String}} = nothing
end

@option struct GateModelParameters <: BraketDeviceSchema
    braketSchemaHeader::Header = Header(name="braket.device_schema.gate_model_parameters", version=v"1")
    qubitCount::Int
    disableQubitRewiring::Bool = false
end

abstract type BraketDeviceParametersSchema <: BraketDeviceSchema end

@option struct IonqDeviceParameters <: BraketDeviceParametersSchema
    braketSchemaHeader::Header = Header(;name="braket.device_schema.ionq.ionq_device_parameters", version=v"1")
    paradigmParameters::GateModelParameters
end

@option struct RigettiDeviceParameters <: BraketDeviceParametersSchema
    braketSchemaHeader::Header = Header(;name="braket.device_schema.rigetti.rigetti_device_parameters", version=v"1")
    paradigmParameters::GateModelParameters
end

@option struct GateModelSimulatorDeviceParameters <: BraketDeviceParametersSchema
    braketSchemaHeader::Header = Header(;name="braket.device_schema.simulators.gate_model_simulator_device_parameters", version=v"1")
    paradigmParameters::GateModelParameters
end

# enum name not consistent
@enum PostProcessingType begin
    SAMPLING# = "SAMPLING"
    OPTIMIZATION# = "OPTIMIZATION"
end

function Base.convert(::Type{PostProcessingType}, x::String)
    if x == "SAMPLING"
        return SAMPLING
    elseif x == "OPTIMIZATION"
        return OPTIMIZATION
    else
        error("cannot convert string \"$x\" to PostProcessingType")
    end
end

@enum ResultFormat begin
    RAW# = "RAW"
    HISTOGRAM# = "HISTOGRAM"
end

function Base.convert(::Type{ResultFormat}, x::String)
    if x == "RAW"
        return RAW
    elseif x == "HISTOGRAM"
        return HISTOGRAM
    else
        error("cannot convert string \"$x\" to ResultFormat")
    end
end

# NOTE: copy pasted properties?
@option struct DwaveProviderLevelParameters <: BraketDeviceSchema
    braketSchemaHeader::Header = Header(;name="braket.device_schema.dwave.dwave_provider_level_parameters", version=v"1")
    annealingOffsets::Maybe{Vector{Float64}} = nothing
    annealingSchedule::Maybe{Vector{Vector{Float64}}} = nothing
    annealingDuration::Maybe{Int} = nothing # greater than 0
    autoScale::Maybe{Bool} = nothing
    beta::Maybe{Float64} = nothing
    chains::Maybe{Vector{Vector{Int}}} = nothing
    compensateFluxDrift::Maybe{Bool} = nothing
    fluxBiases::Maybe{Vector{Float64}} = nothing
    initialState::Maybe{Vector{Int}} = nothing
    maxResults::Maybe{Int} = nothing # greater than 0
    postprocessingType::Maybe{PostProcessingType} = nothing

    programmingThermalizationDuration::Maybe{Int} = nothing
    readoutThermalizationDuration::Maybe{Int} = nothing
    reduceIntersampleCorrelation::Maybe{Bool} = nothing
    reinitializeState::Maybe{Bool} = nothing
    resultFormat::Maybe{ResultFormat} = nothing
    spinReversalTransformCount::Maybe{Int} = nothing # greater than 0
end

@option struct DwaveAdvantageDeviceLevelParameters <: BraketDeviceSchema
    braketSchemaHeader::Header = Header(;name="braket.device_schema.dwave.dwave_advantage_device_level_parameters", version=v"1")
    annealingOffsets::Maybe{Vector{Float64}} = nothing
    annealingSchedule::Maybe{Vector{Vector{Float64}}} = nothing
    annealingDuration::Maybe{Int} = nothing # greater than 0
    autoScale::Maybe{Bool} = nothing

    compensateFluxDrift::Maybe{Bool} = nothing
    fluxBiases::Maybe{Vector{Float64}} = nothing
    initialState::Maybe{Vector{Int}} = nothing
    maxResults::Maybe{Int} = nothing # greater than 0

    programmingThermalizationDuration::Maybe{Int} = nothing
    readoutThermalizationDuration::Maybe{Int} = nothing
    reduceIntersampleCorrelation::Maybe{Bool} = nothing
    reinitializeState::Maybe{Bool} = nothing
    resultFormat::Maybe{ResultFormat} = nothing
    spinReversalTransformCount::Maybe{Int} = nothing # greater than 0
end

@option struct Dwave2000QDeviceLevelParameters <: BraketDeviceSchema
    braketSchemaHeader::Header = Header(;name="braket.device_schema.dwave.dwave_2000Q_device_level_parameters", version=v"1")
    annealingOffsets::Maybe{Vector{Float64}} = nothing
    annealingSchedule::Maybe{Vector{Vector{Float64}}} = nothing
    annealingDuration::Maybe{Int} = nothing # greater than 0
    autoScale::Maybe{Bool} = nothing
    beta::Maybe{Float64} = nothing
    chains::Maybe{Vector{Vector{Int}}} = nothing
    compensateFluxDrift::Maybe{Bool} = nothing
    fluxBiases::Maybe{Vector{Float64}} = nothing
    initialState::Maybe{Vector{Int}} = nothing
    maxResults::Maybe{Int} = nothing # greater than 0
    postprocessingType::Maybe{PostProcessingType} = nothing
    programmingThermalizationDuration::Maybe{Int} = nothing
    readoutThermalizationDuration::Maybe{Int} = nothing
    reduceIntersampleCorrelation::Maybe{Bool} = nothing
    reinitializeState::Maybe{Bool} = nothing
    resultFormat::Maybe{ResultFormat} = nothing
    spinReversalTransformCount::Maybe{Int} = nothing # greater than 0
end

@option struct DwaveDeviceParameters <: BraketDeviceSchema
    braketSchemaHeader::Header = Header(;name="braket.device_schema.dwave.dwave_device_parameters", version=v"1")
    providerLevelParameters::Maybe{DwaveProviderLevelParameters} = nothing
    deviceLevelParameters::Maybe{Union{DwaveAdvantageDeviceLevelParameters, Dwave2000QDeviceLevelParameters}} = nothing
end

@option struct DeviceCapabilities <: BraketDeviceSchema
    braketSchemaHeader::Header = Header(;name="", version=v"1")
    service::DeviceServiceProperties
    action::Dict{DeviceActionType, DeviceActionProperties}
    deviceParameters::Dict{String, Any}
    paradigm::Maybe{GateModelQpuParadigmProperties} = nothing
    provider::Maybe{Dict{String, Any}} = nothing
end

function Configurations.convert_to_option(::Type{DeviceCapabilities}, ::Type{Dict{DeviceActionType, DeviceActionProperties}}, x::Dict{String, Any})
    d = Dict{DeviceActionType, DeviceActionProperties}()
    for (k, v) in x
        d[convert(DeviceActionType, k)] = from_dict(DeviceActionProperties, v)
    end
    return d
end

@option struct DeviceInfo <: BraketDeviceSchema
    providerName::String
    deviceArn::String
    deviceName::String
    deviceType::String
    deviceStatus::String
    deviceCapabilities::Maybe{DeviceCapabilities} = nothing
end

function Configurations.convert_to_option(::Type{BraketDeviceSchema}, ::Type{VersionNumber}, x)
    VersionNumber(x)
end

function Configurations.convert_to_option(::Type{DeviceActionProperties}, ::Type{Vector{VersionNumber}}, x::Vector{Any})
    map(VersionNumber, x)
end
