using GarishPrint
using AWSBraket
using Test

using JSON
using HTTP
using Configurations
using AWS
using AWS: @service

@service Braket


info = AWSBraket.get_device("arn:aws:braket:::device/quantum-simulator/amazon/sv1")
pprint(info)

dev, _ = AWSBraket.search_devices(;aws_config=AWS.global_aws_config(region="us-west-1"))
pprint(dev[1])

dev[1].deviceArn
dev[2].deviceArn
dev[3].deviceArn
dev[4].deviceArn


Braket.search_quantum_tasks([])
Braket.create_quantum_task

using AWSBraket.Schema

dev = Braket.search_devices([]; aws_config=AWS.global_aws_config(region="us-east-1"))["devices"]
map(dev) do d
    from_dict(Schema.DeviceInfo, d)
end

from_dict(Schema.DeviceInfo, dev[1])

AWS.global_aws_config(region="us-east-1")