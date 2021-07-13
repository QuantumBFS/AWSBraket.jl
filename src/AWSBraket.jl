module AWSBraket

using Configurations
using GarishPrint
using Dates

include("schema/schema.jl")

using AWS
using UUIDs
using HTTP
using JSON
using Configurations: from_dict_validate
using AWS: @service

@service STS
@service Braket

function parse_device_info(d)
    # need to be fixed upstream
    if d["deviceCapabilities"] isa AbstractString
        d["deviceCapabilities"] = JSON.parse(d["deviceCapabilities"])
    end

    return from_dict_validate(Schema.DeviceInfo, d)::Schema.DeviceInfo
end

function get_device(arn::String; aws_config=AWS.global_aws_config())
    # NOTE: the AWS dev docs
    d = Braket.get_device(HTTP.escapeuri(arn); aws_config)
    return parse_device_info(d)
end

function search_devices(filters=[]; max_results::Maybe{Int}=nothing, next_token::Maybe{String}=nothing, aws_config=AWS.global_aws_config())
    params = Dict{String, Any}()
    max_results === nothing || (params["maxResults"] = max_results)
    next_token === nothing || (params["nextToken"] = next_token)

    d = Braket.search_devices(filters, params; aws_config)
    return map(parse_device_info, d["devices"]), get(d, "nextToken", nothing)
end

function make_device_parameters(program::Schema.Program, arn::String, disable_qubit_rewiring::Bool)
    paradigm_parameters = Schema.GateModelParameters(
        qubitCount=Schema.count_qubits(program),
        disableQubitRewiring=disable_qubit_rewiring
    )

    if occursin("ionq", arn)
        device_parameters = Schema.IonqDeviceParameters(
            paradigmParameters=paradigm_parameters
        )
    elseif occursin("rigetti", arn)
        device_parameters = Schema.RigettiDeviceParameters(
            paradigmParameters=paradigm_parameters
        )
    else # default to use simulator
        device_parameters = Schema.GateModelSimulatorDeviceParameters(
            paradigmParameters=paradigm_parameters
        )
    end

    return device_parameters
end

function create_quantum_task(;
        program::Schema.Program,
        device_arn::String,
        bucket::String,
        folder::String,
        disable_qubit_rewiring::Bool = false,
        device_parameters = make_device_parameters(program, device_arn, disable_qubit_rewiring),
        nshots::Int = 100,
        client_token::UUID = uuid1(),
        tags::Dict{String, String} = Dict{String, String}(),
    )
    
    response = Braket.create_quantum_task(
        JSON.json(to_dict(program; include_defaults=true, exclude_nothing=true)),
        string(client_token),
        device_arn,
        bucket,
        folder,
        nshots,
        Dict(
            "deviceParameters" => JSON.json(to_dict(device_parameters; include_defaults=true, exclude_nothing=true)),
            "tags" => tags,
        ),
    )
    return response["quantumTaskArn"], response["status"]
end

function get_quantum_task(task_arn::String)
    from_dict(Schema.BraketTaskInfo, Braket.get_quantum_task(HTTP.escapeuri(task_arn)))
end

function cancel_quantum_task(client_token::String, task_arn::String)
    Braket.cancel_quantum_task(client_token, HTTP.escapeuri(task_arn))
end

using Crayons.Box
using REPL.TerminalMenus
include("menu.jl")

end
