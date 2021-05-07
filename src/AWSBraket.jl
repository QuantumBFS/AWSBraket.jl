module AWSBraket

export aws_account_id, BRAKET_ARNS

const BRAKET_ARNS = Dict{String, String}(
    "Rigetti-Aspen-8" => "arn:aws:braket:::device/qpu/rigetti/Aspen-8",
    "Dwave-Advantage-1" => "arn:aws:braket:::device/qpu/d-wave/Advantage_system1",
    "Dwave-2000Q" => "arn:aws:braket:::device/qpu/d-wave/DW_2000Q_6",
    "IONQ" => "arn:aws:braket:::device/qpu/ionq/ionQdevice",
    "Braket-SV1-Simulator" => "arn:aws:braket:::device/quantum-simulator/amazon/sv1",
)

using AWS
using AWS: @service

@service STS

function aws_account_id()
    STS.get_caller_identity()["GetCallerIdentityResult"]["Account"]
end

isqpu(arn::String) = "qpu" in arn

end
