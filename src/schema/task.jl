abstract type BraketTaskSchema <: JAQCDInstruction end

@option struct TaskMetadata <: BraketTaskSchema
    braketSchemaHeader::Header = Header(name="braket.task_result.task_metadata", version=v"1")
    id::String
    shots::Int
    deviceId::String
    deviceParameters::Maybe{Dict{String, Any}} = nothing
    createdAt::Maybe{String} = nothing
    endedAt::Maybe{String} = nothing
    status::Maybe{String} = nothing
    failureReason::Maybe{String} = nothing
end

@option struct BraketTaskInfo
    createdAt::String
    deviceArn::String
    deviceParameters::String
    endedAt::String
    failureReason::Maybe{String} = nothing
    id::String
    outputS3Bucket::String
    outputS3Directory::String
    quantumTaskArn::String
    shots::Int
    status::String
    tags::Dict{String, String}
end

Base.show(io::IO, x::BraketTaskInfo) = pprint_struct(io, x)
