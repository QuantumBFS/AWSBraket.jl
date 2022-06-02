using BrokenRecord
using AWSBraket
using AWSBraket.Schema
using Configurations
using JSON
using HTTP
using Test
using AWS
using AWS: @service
@service Braket
@service S3

BrokenRecord.configure!(path=joinpath(pkgdir(AWSBraket), "test", "records"), ignore_headers=["Authorization"])

bell = Schema.Program(;
    instructions=[
        Schema.H(;target=0),
        Schema.CNot(;control=0, target=1),
    ],
)

#task, status = BrokenRecord.playback("create_quantum_task.json") do
task, status = AWSBraket.create_quantum_task(;
        program=bell,
        device_arn="arn:aws:braket:::device/quantum-simulator/amazon/sv1",
        bucket="amazon-braket-8865d8c99645",
        folder="braket",
    )    

#info = BrokenRecord.playback("get_quantum_task.json") do
info = AWSBraket.get_quantum_task(task)
#end


@test_throws AWS.AWSExceptions.AWSException BrokenRecord.playback("cancel_quantum_task.json") do
    AWSBraket.cancel_quantum_task(info.id, task)    
end

content = BrokenRecord.playback("get_result_object.json") do
    S3.get_object(info.outputS3Bucket, info.outputS3Directory * "/results.json")    
end

result = JSON.parse(String(content))
result["measurements"]


# NOTE: the results type is broken currently
bell = Schema.Program(;
    instructions=[
        Schema.H(;target=0),
        Schema.CNot(;control=0, target=1),
    ],
    results=[
        Schema.Results(;
            type=Schema.EXPECTATION,
            observable=["x"],
            targets=[1],
        )
    ]
)
