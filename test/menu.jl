using AWS
using AWSBraket
using REPL.TerminalMenus


devices, _ = AWSBraket.search_devices(;aws_config=AWSConfig(;region="us-east-1"))

menu = AWSBraket.DeviceMenu(devices);

menu = AWSBraket.DeviceMenu()
request("select a device:", menu)



devices, _ = AWSBraket.search_devices(;aws_config=AWSConfig(;region="us-west-2"))

AWS.@service Braket

devices = Braket.search_devices([];aws_config=AWSConfig(;region="us-west-2"))["devices"]

using JSON
using AWSBraket.Schema
using Configurations

from_dict(Schema.DeviceInfo, devices[4])

devices[1]["deviceCapabilities"] = JSON.parse(devices[1]["deviceCapabilities"])

AWSBraket.parse_device_info(devices[4])
devices[4]