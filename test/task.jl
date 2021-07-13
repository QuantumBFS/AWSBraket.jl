using AWSBraket
using AWSBraket.Schema
using Configurations
using JSON

# bell = Schema.Program(;
#     instructions=[
#         Schema.H(;target=0),
#         Schema.CNot(;control=0, target=1),
#     ],
#     results=[
#         Schema.Results(;
#             type=Schema.EXPECTATION,
#             observable=["x"],
#             targets=[1],
#         )
#     ]
# )

bell = Schema.Program(;
    instructions=[
        Schema.H(;target=0),
        Schema.CNot(;control=0, target=1),
    ],
)

deviceParameters = Schema.GateModelSimulatorDeviceParameters(
    paradigmParameters=Schema.GateModelParameters(
        qubitCount=2, disableQubitRewiring=false,
    )
)

JSON.json(to_dict(bell; include_defaults=true, exclude_nothing=true), 2)|>print

# # direct call
# task = Braket.create_quantum_task(
#     JSON.json(to_dict(bell; include_defaults=true, exclude_nothing=true)),
#     string(uuid1()),
#     "arn:aws:braket:::device/quantum-simulator/amazon/sv1",
#     "amazon-braket-8865d8c99645",
#     "braket",
#     100,
#     Dict(
#         "deviceParameters" => JSON.json(to_dict(deviceParameters; include_defaults=true)),
#     ),
# )

# high level
using UUIDs

task, status = AWSBraket.create_quantum_task(;
    program=bell,
    device_arn="arn:aws:braket:::device/quantum-simulator/amazon/sv1",
    bucket="amazon-braket-8865d8c99645",
    folder="braket",
)

info = AWSBraket.get_quantum_task(task)
# AWSBraket.cancel_quantum_task(info.id, task)

info = from_dict(AWSBraket.Schema.BraketTaskInfo, meta)

using HTTP
using AWS: @service
@service Braket
@service S3

S3.list_objects(info.outputS3Bucket)["Contents"]
content = S3.get_object(info.outputS3Bucket, info.outputS3Directory * "/results.json")
s = String(content)
JSON.parse(s)
