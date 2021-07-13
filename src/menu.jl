mutable struct DeviceMenu <: TerminalMenus.AbstractMenu
    options::Vector{Schema.DeviceInfo}
    regions::Vector{String}
    pagesize::Int
    indent::Int
    pageoffset::Int
    selected::Int
end

function DeviceMenu(; pagesize::Int=5)
    all_devices = Schema.DeviceInfo[]
    regions = String[]
    for region in ["us-east-1", "us-west-1", "us-west-2"]
        devices, _ = search_devices(;aws_config = AWSConfig(;region))
        append!(all_devices, devices)
        append!(regions, fill(region, length(devices)))
    end
    return DeviceMenu(all_devices, regions; pagesize)
end

function DeviceMenu(
        devices::Vector{Schema.DeviceInfo},
        regions::Vector{String} = fill(AWS.region(AWS.global_aws_config()), length(devices))
        ; pagesize::Int=5, warn::Bool=true
    )

    length(devices) < 1 && error("DeviceMenu must have at least one option")
    pagesize < 4 && error("minimum pagesize must be larger than 4")
    pagesize = pagesize == -1 ? length(devices) : pagesize
    # pagesize shouldn't be bigger than options
    pagesize = min(length(devices), pagesize)
    # after other checks, pagesize must be greater than 1
    pagesize < 1 && error("pagesize must be >= 1")

    pageoffset = 0
    selected = -1 # none
    indent = maximum(x->length(device_name(x)), devices) + 2
    return DeviceMenu(devices, regions, pagesize, indent, pageoffset, selected)
end

function device_name(dev::Schema.DeviceInfo)
    string(dev.providerName, ":", dev.deviceName)
end

function TerminalMenus.options(m::DeviceMenu)
    return m.options
end

TerminalMenus.cancel(m::DeviceMenu) = m.selected = -1

function TerminalMenus.pick(m::DeviceMenu, cursor::Int)
    m.selected = cursor
    return true #break out of the menu
end

function TerminalMenus.printmenu(out::IO, m::DeviceMenu, cursoridx::Int; oldstate=nothing, init::Bool=false)
    buf = IOBuffer()
    lastoption = length(m.options)
    ncleared = oldstate === nothing ? m.pagesize-1 : oldstate

    if init
        # like clamp, except this takes the min if max < min
        m.pageoffset = max(0, min(cursoridx - m.pagesize ÷ 2, lastoption - m.pagesize))
    else
        print(buf, "\x1b[999D\x1b[$(ncleared)A")   # move left 999 spaces and up `ncleared` lines
    end

    firstline = m.pageoffset+1
    lastline = min(m.pagesize+m.pageoffset, lastoption)
    curr_device = m.options[cursoridx]

    for i in firstline:lastline
        # clearline
        print(buf, "\x1b[2K")

        upscrollable = i == firstline && m.pageoffset > 0
        downscrollable = i == lastline && i != lastoption

        if upscrollable && downscrollable
            print(buf, TerminalMenus.updown_arrow(m)::Union{Char,String})
        elseif upscrollable
            print(buf, TerminalMenus.up_arrow(m)::Union{Char,String})
        elseif downscrollable
            print(buf, TerminalMenus.down_arrow(m)::Union{Char,String})
        else
            print(buf, ' ')
        end

        # TODO: use 1.6's implementation when we drop 1.5
        # TerminalMenus.printcursor(buf, m, i == cursoridx)
        print(buf, i == cursoridx ? '→' : ' ', ' ')

        name = device_name(m.options[i])
        indent = " "^(m.indent - length(name))
        device = m.options[cursoridx]::Schema.DeviceInfo

        line_idx = i - firstline + 1
        print(buf, GREEN_FG(name))
 
        if !isnothing(device.deviceCapabilities) && !isnothing(device.deviceCapabilities.paradigm)
            nqubits = device.deviceCapabilities.paradigm.qubitCount
        else
            nqubits = "unknown"
        end

        if line_idx == 1
            print(buf, indent, LIGHT_BLUE_FG("nqubits: "), GREEN_FG(string(nqubits)))
        elseif line_idx == 2
            print(buf, indent, LIGHT_BLUE_FG("status: "), GREEN_FG(device.deviceStatus))
        elseif line_idx == 3
            print(buf, indent, LIGHT_BLUE_FG("region: "), GREEN_FG(m.regions[cursoridx]))
        end

        (firstline == lastline || i != lastline) && print(buf, "\r\n")
    end

    newstate = lastline-firstline  # final line doesn't have `\n`
    if newstate < ncleared && oldstate !== nothing
        # we printed fewer lines than last time. Erase the leftovers.
        for i = newstate+1:ncleared
            print(buf, "\r\n\x1b[2K")
        end
        print(buf, "\x1b[$(ncleared-newstate)A")
    end

    print(out, String(take!(buf)))

    return newstate
end
