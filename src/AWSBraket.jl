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

const DOC_AWS_CONFIG = """
# AWS Service Configuration

You can specify custom configuration via `aws_config` keyword argument, 
to select another regions or use a different account, default
is `AWS.global_aws_config()`, e.g you can choose a different region in
this config

```julia
using AWS
config = AWSConfig(;region="us-west-1")
```

See the [AWS Julia Interface](https://github.com/JuliaCloud/AWS.jl) documentation
for more advanced usage.
"""

"""
    get_device(arn::String; aws_config=AWS.global_aws_config())

Retrieves the devices available in Amazon Braket.

# Arguments

- `arn`: The ARN of the device to retrieve.

$(DOC_AWS_CONFIG)
"""
function get_device(arn::String; aws_config=AWS.global_aws_config())
    # NOTE: the AWS dev docs
    d = Braket.get_device(HTTP.escapeuri(arn); aws_config)
    return parse_device_info(d)
end

"""
    search_devices(filters=[]; max_results::Maybe{Int}=nothing, next_token::Maybe{String}=nothing, aws_config=AWS.global_aws_config())

Searches for devices using the specified filters.

# Arguments

- `filters`: The filter values to use to search for a device.

# Keyword Arguments (Optional)

- `max_results`: The maximum number of results to return in the response.
- `next_token`: A token used for pagination of results returned in the response. Use the token returned from
    the previous request continue results where the previous request ended.

$(DOC_AWS_CONFIG)
"""
function search_devices(filters=[]; max_results::Maybe{Int}=nothing, next_token::Maybe{String}=nothing, aws_config=AWS.global_aws_config())
    params = Dict{String, Any}()
    max_results === nothing || (params["maxResults"] = max_results)
    next_token === nothing || (params["nextToken"] = next_token)

    d = Braket.search_devices(filters, params; aws_config)
    return map(parse_device_info, d["devices"]), get(d, "nextToken", nothing)
end

"""
    make_device_parameters(program::Schema.Program, arn::String, disable_qubit_rewiring::Bool)

Create device parameters from given `program`, device `arn` and `disable_qubit_rewiring` option.
"""
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

"""
    create_quantum_task(;kw...)

Create a quantum task in braket service.

# Required Keyword Arguments

- `program::Schema.Program`: the program one wants to execute.
- `device_arn::String`: device arn.
- `bucket::String`: S3 bucket to store the results in.
- `folder::String`: S3 bucket folder.

# Optional Keyword Arguments

- `disable_qubit_rewiring::Bool`: disable qubit rewiring in braket service, default is `false`.
- `device_parameters`: device parameters, such as [`Schema.IonqDeviceParameters`](@ref),
    [`Schema.RigettiDeviceParameters`](@ref), default is inferred from previous arguments.
- `nshots`: number of shots, default is `100`.
- `client_token`: a `UUID` for the client token, will generate one by default.
- `tags::Dict{String, String}`: a list of tags you would to attach to this task.

$(DOC_AWS_CONFIG)
"""
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
        aws_config=AWS.global_aws_config(),
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
        );
        aws_config
    )
    return response["quantumTaskArn"], response["status"]
end

"""
    get_quantum_task(task_arn::String)

Get the quantum task from `task_arn`.

$(DOC_AWS_CONFIG)
"""
function get_quantum_task(task_arn::String; aws_config=AWS.global_aws_config())
    from_dict(
        Schema.BraketTaskInfo,
        Braket.get_quantum_task(HTTP.escapeuri(task_arn); aws_config)
    )
end

"""
    cancel_quantum_task(client_token::String, task_arn::String)

Cancel quantum task given by `client_token` and its `task_arn`.

$(DOC_AWS_CONFIG)
"""
function cancel_quantum_task(client_token::String, task_arn::String; aws_config=AWS.global_aws_config())
    Braket.cancel_quantum_task(
        client_token,
        HTTP.escapeuri(task_arn);
        aws_config
    )
end

using Crayons.Box
using REPL.TerminalMenus
include("menu.jl")

end
