using AWSBraket
using Test

using AWS: @service
@service Braket
Braket.get_device("arn:aws:braket:::device/quantum-simulator/amazon/sv1")

AWSBraket.aws_account_id()
@service Braket
AWSBraket.BRAKET_ARNS["Braket-SV1-Simulator"]
Braket.get_device("arn:aws:braket:::device/qpu/ionq/ionQdevice")

@testset "AWSBraket.jl" begin
    # Write your tests here.
end

using AWS
using HTTP
using JSON
@service Braket
devices = Braket.search_devices()["devices"]
dev = devices[3]
dev = Braket.get_device(HTTP.escapeuri(dev["deviceArn"]))
