function scaleVoltage(voltage::BaseVoltage, prefix::PrefixLive, i::Int64)
    return (voltage.value[i] * voltage.prefix) / prefix.voltageMagnitude
end

function scaleVoltage(prefix::PrefixLive, voltage::BaseVoltage, i::Int64)
    if prefix.voltageMagnitude == 0.0
        scaleV = 1.0
    else
        scaleV = scaleVoltage(voltage, prefix, i)
    end

    return scaleV
end

function scaleCurrent(system::PowerSystem, prefix::PrefixLive, i::Int64)
    return system.base.power.value * system.base.power.prefix / (sqrt(3) * system.base.voltage.value[i] * system.base.voltage.prefix * prefix.currentMagnitude)
end

function scaleCurrent(prefix::PrefixLive, system::PowerSystem, i::Int64)
    if prefix.currentMagnitude == 0.0
        scaleI = 1.0
    else
        scaleI = scaleCurrent(system, prefix, i)
    end

    return scaleI
end

function printScale(system::PowerSystem, prefix::PrefixLive)
    return scale = Dict(
        "θ" => prefix.voltageAngle != 0.0 ? 1 / prefix.voltageAngle : 1.0,
        "P" => prefix.activePower != 0.0 ? system.base.power.value * system.base.power.prefix / prefix.activePower : 1.0,
        "Q" => prefix.reactivePower != 0.0 ? system.base.power.value * system.base.power.prefix / prefix.reactivePower : 1.0,
        "S" => prefix.apparentPower != 0.0 ? system.base.power.value * system.base.power.prefix / prefix.apparentPower : 1.0,
        "ψ" => prefix.currentAngle != 0.0 ? 1 / prefix.currentAngle : 1.0,
    )
end

function printTitle(io::IO, maxLine::Int64, delimiter::String, title::Bool, header::Bool, style::Bool, caption::String)
    if style && title
        print(io, format(Format("$delimiter%s$delimiter\n"), "-"^maxLine))
        print(io, format(Format("$delimiter %s%*s$delimiter\n"), caption, maxLine - textwidth(caption) - 1, ""))
        if !header
            print(io, format(Format("$delimiter%s$delimiter\n"), "-"^maxLine))
        end
    end
end

function formPrint(label::L, container::Union{P,M}, labels::OrderedDict{String, Int64}, title::B, header::B, footer::B, component::String)
    if isset(label)
        dictIterator = Dict(getLabel(container, label, component) => labels[getLabel(container, label, component)])
        if !isset(header)
            header = false
        end
        if !isset(title)
            title = false
        end
        if !isset(footer)
            footer = false
        end
    else
        dictIterator = labels
        if !isset(header)
            header = true
        end
        if !isset(title)
            title = true
        end
        if !isset(footer)
            footer = true
        end
    end

    return dictIterator, title, header, footer
end

function toggleLabel(label::L, container::Union{P,M}, labels::OrderedDict{String, Int64}, component::String)
    if isset(label)
        dictIterator = Dict(getLabel(container, label, component) => labels[getLabel(container, label, component)])
    else
        dictIterator = labels
    end

    return dictIterator
end

function fminmax(fmt::Dict{String, String}, width::Dict{String, Int64}, show::OrderedDict{String, Bool}, vector::Array{Float64,1}, scale::Float64, key::String)
    if show[key]
        minmax = extrema(vector)
        width[key] = max(textwidth(format(Format(fmt[key]), 0, minmax[1] * scale)), textwidth(format(Format(fmt[key]), 0, minmax[2] * scale)), width[key])
    end
end

function fmax(fmt::Dict{String, String}, width::Dict{String, Int64}, show::OrderedDict{String, Bool}, vector::Array{Float64,1}, scale::Float64, key::String)
    if show[key]
        maxVal = maximum(vector)
        width[key] = max(textwidth(format(Format(fmt[key]), 0, maxVal * scale)), width[key])
    end
end

function fmax(fmt::Dict{String, String}, width::Dict{String, Int64}, show::OrderedDict{String, Bool}, vector::Array{Float64,1}, i::Int64, scale::Float64, key::String)
    if show[key]
        width[key] = max(textwidth(format(Format(fmt[key]), 0, vector[i] * scale)), width[key])
    end
end

function fmax(fmt::Dict{String, String}, width::Dict{String, Int64}, show::OrderedDict{String, Bool}, value::Float64, key::String)
    if show[key]
        width[key] = max(textwidth(format(Format(fmt[key]), 0, value)), width[key])
    end
end

function fmax(width::Dict{String, Int64}, show::OrderedDict{String, Bool}, value::String, key::String)
    if show[key]
        width[key] = max(textwidth(value), width[key])
    end
end

function fmax(width::Dict{String, Int64}, show::OrderedDict{String, Bool}, label::OrderedDict{String, Int64}, heading::String)
    if show[heading]
        width[heading] = max(maximum(textwidth, collect(keys(label))), width[heading])
    end
end


function fmax(width::Dict{String, Int64}, show::OrderedDict{String, Bool}, label::Array{String, 1}, headings::String...)
    if !isempty(label)
        maxWidth = maximum(textwidth, label)

        for heading in headings
            if show[heading]
                width[heading] = max(maxWidth, width[heading])
            end
        end
    end
end


function printFormat(_fmt::Dict{String, String}, fmt::Dict{String, String}, _width::Dict{String, Int64}, width::Dict{String, Int64}, _show::OrderedDict{String, Bool}, show::Dict{String, Bool}, style::Bool)
    @inbounds for (key, value) in fmt
        if haskey(_fmt, key)
            aligment, span, precision, specifier = fmtRegex(value)

            if precision !== nothing
                _fmt[key] = "%" * aligment * "*." * precision * specifier
            else
                _fmt[key] = "%" * aligment * "*" * specifier
            end

            if !isempty(span) && style
                _width[key] = max(parse(Int, span), _width[key])
            end
        end
    end

    if style
        @inbounds for (key, value) in width
            if haskey(_width, key)
                _width[key] = max(value - 2, _width[key])
            end
        end
    end

    @inbounds for (key, value) in show
        if haskey(_show, key)
            _show[key] = _show[key] && value
        end
    end

    return _fmt, _width, _show
end

function _fmt_(_fmt::String; format::String = "%*.4f")
    return isempty(_fmt) ? format : _fmt
end

function _width_(_width::Int64, span::Int64, style::Bool)
    return max(span, _width) * style
end

function _show_(_show::Bool, value::Union{Array{Float64,1}, Dict{Int64, ConstraintRef}, Dict{Int64, Float64}})
    return !isempty(value) & _show
end

function _show_(_show::Bool, value::Bool)
    return value & _show
end

function _header_(headerMain::String, headerStyle::String, style::Bool)
    return style ? headerMain : headerStyle
end

function _blank_(width::Dict{String, Int64}, show::OrderedDict{String, Bool}, keys::String...)
    blankWidth = -3
    for key in keys
        if show[key]
            blankWidth += width[key] + 3
        end
    end

    return blankWidth
end

function _blank_(width::Dict{String, Int64}, show::OrderedDict{String, Bool}, style::Bool, heading::String, keys::String...)
    if style
        countTrue = 0
        maxWidth = 0
        for key in keys
            if show[key]
                countTrue += show[key]
                maxWidth += width[key]
            end
        end

        if maxWidth < textwidth(heading)
            for key in keys
                if show[key]
                    width[key] = max(textwidth(heading) + width[key] - maxWidth - 3 * (countTrue - 1), width[key])
                    break
                end
            end
        end
    end

    return _blank_(width, show, keys...)
end

function fmtRegex(fmt::String)
    regexPattern = r"%([-]?)(\d*)\.?(\d+)?([a-zA-Z])"
    matchRresult = match(regexPattern, fmt)

    if matchRresult !== nothing
        return matchRresult.captures[1], matchRresult.captures[2], matchRresult.captures[3], matchRresult.captures[4]
    else
        throw(ErrorException("Invalid format string: $fmt"))
    end
end

function howManyPrint(width::Dict{String, Int64}, show::OrderedDict{String, Bool}, style::Bool, title::Bool, heading::String)
    howMany = 0
    @inbounds for (key, value) in show
        if value
            howMany += 1
        end
    end

    if style && title && howMany == 1
        @inbounds for (key, value) in show
            if value
                width[key] = max(textwidth(heading), width[key])
            end
        end
    end

    return howMany > 0
end

function setupPrint(fmt::Dict{String, String}, width::Dict{String, Int64}, show::OrderedDict{String, Bool}, delimiter::String, style::Bool)
    pfmt = Dict{String, Format}()
    hfmt = Dict{String, Format}(
        "Empty" => Format(" %*s " * delimiter),
        "Break" => Format("-%s-" * delimiter)
    )

    firstTrue = ""
    for (key, value) in show
        if value
            firstTrue = key
            break
        end
    end

    maxLine = -1
    if !isempty(firstTrue)
        if style
            for (key, value) in show
                if value
                    pfmt[key] = Format(" $(fmt[key]) $delimiter")
                    hfmt[key] = Format(" %*s " * delimiter)
                    maxLine += width[key] + 3
                end
            end
            pfmt[firstTrue] = Format("$delimiter $(fmt[firstTrue]) $delimiter")
            hfmt[firstTrue] = Format(delimiter * " %*s " * delimiter)
        else
            for (key, value) in show
                if value
                    pfmt[key] = Format(delimiter * fmt[key])
                    hfmt[key] = Format(delimiter * "%*s")
                end
            end
            pfmt[firstTrue] = Format(fmt[firstTrue])
            hfmt[firstTrue] = Format("%*s")
        end
    end

    return maxLine, pfmt, hfmt
end

function printf(io::IO, fmt::Dict{String, Format}, show::OrderedDict{String, Bool}, width::Dict{String, Int64}, vector::Array{Float64,1}, i::Int64, scale::Float64, key::String)
    if show[key]
        print(io, format(fmt[key], width[key], vector[i] * scale))
    end
end

function printf(io::IO, fmt::Dict{String, Format}, show::OrderedDict{String, Bool}, width::Dict{String, Int64}, dual::Dict{Int64, Float64}, i::Int64, scale::Float64, key::String)
    if show[key]
        print(io, format(fmt[key], width[key], dual[i] / scale))
    end
end

function printf(io::IO, fmt::Dict{String, Format}, show::OrderedDict{String, Bool}, width::Dict{String, Int64}, constraint::Dict{Int64, ConstraintRef}, i::Int64, scale::Float64, key::String)
    if show[key]
        print(io, format(fmt[key], width[key], value(constraint[i]) * scale))
    end
end

function printf(io::IO, fmt::Dict{String, Format}, show::OrderedDict{String, Bool}, width::Dict{String, Int64}, value::String, keys::String...)
    for key in keys
        if show[key]
            print(io, format(fmt[key], width[key], value))
        end
    end
end

function printf(io::IO, fmt::Dict{String, Format}, show::OrderedDict{String, Bool}, width::Dict{String, Int64}, vector::Array{Int8,1}, i::Int64, key::String)
    if show[key]
        print(io, format(fmt[key], width[key], vector[i]))
    end
end

function printf(io::IO, fmt::Dict{String, Format}, show::OrderedDict{String, Bool}, width::Dict{String, Int64}, value::Float64, key::String)
    if show[key]
        print(io, format(fmt[key], width[key], value))
    end
end

function printf(io::IO, fmt::Dict{String, Format}, show::OrderedDict{String, Bool}, width::Dict{String, Int64}, vector1::Array{Float64,1}, vector2::Array{Float64,1}, i::Int64, j::Int64, scale::Float64, key::String)
    if show[key]
        print(io, format(fmt[key], width[key], (vector1[i] - vector2[j]) * scale))
    end
end

function minmaxPrimal(show::OrderedDict{String, Bool}, constraint::ConstraintRef, scale::Float64, minmaxprimal::Array{Float64,1}, key::String)
    if show[key]
        primalValue = value(constraint) * scale
        minmaxprimal[1] = max(primalValue, minmaxprimal[1])
        minmaxprimal[2] = min(primalValue, minmaxprimal[2])
    end

    return minmaxprimal
end

function minmaxDual(show::OrderedDict{String, Bool}, dual::Dict{Int64, Float64}, i::Int64, scale::Float64, minmaxdual::Array{Float64,1}, key::String)
    if show[key] && haskey(dual, i)
        dualValue = dual[i] / scale
        minmaxdual[1] = max(dualValue, minmaxdual[1])
        minmaxdual[2] = min(dualValue, minmaxdual[2])
    end

    return minmaxdual
end

function minmaxValue(show::OrderedDict{String, Bool}, vector::Array{Float64,1}, i::Int64, scale::Float64, minmavalue::Array{Float64,1}, key::String)
    if show[key]
        val = vector[i] * scale
        minmavalue[1] = max(val, minmavalue[1])
        minmavalue[2] = min(val, minmavalue[2])
    end

    return minmavalue
end

function fmtwidth(show::OrderedDict{String, Bool})
    fmt = Dict{String, String}()
    width = Dict{String, Int64}()

    @inbounds for key in keys(show)
        fmt[key] = ""
        width[key] = 0
    end

    return fmt, width
end

function printHeader(io::IO, hfmt::Dict{String, Format}, width::Dict{String, Int64}, show::OrderedDict{String, Bool},
    heading::OrderedDict{String, Int64}, subheading::Dict{String, String}, unit::Dict{String, String}, delimiter::String,
    header::Bool, style::Bool, repeat::Int64, printing::Bool, maxLine::Int64, lineNumber::Int64)

    if (lineNumber - 1) % repeat == 0 || printing
        if header
            if style
                printf(io, delimiter, maxLine, style, header)
                printf(io, heading, delimiter)
                printf(io, hfmt["Empty"], heading, delimiter)
            end
            printf(io, hfmt, width, show, delimiter, style, subheading, unit)
            printing = false
        end
    end

    return printing
end

function printHeader(io::IO, hfmt::Dict{String, Format}, width::Dict{String, Int64}, show::OrderedDict{String, Bool},
    heading::OrderedDict{String, Int64}, subheading::Dict{String, String}, delimiter::String,
    header::Bool, style::Bool, maxLine::Int64)

    if header
        if style
            printf(io, delimiter, maxLine, style, header)
            printf(io, heading, delimiter)
            printf(io, hfmt["Empty"], heading, delimiter)
        end
        printf(io, hfmt, width, show, delimiter, style, subheading)
    end
end

function printf(io::IO, delimiter::String, maxLine::Int64, style::Bool, flag::Bool)
    if flag && style
        print(io, format(Format(delimiter * "%s" * delimiter * "\n"), "-"^maxLine))
    end
end

function printf(io::IO, heading::OrderedDict{String, Int64}, delimiter::String)
    print(io, delimiter)
    for (title, width) in heading
        if width >= 0
            print(io, format(Format(" %*s%s%*s $delimiter"), floor(Int, (width - textwidth(title)) / 2), "", title, ceil(Int, (width - textwidth(title)) / 2) , ""))
        end
    end
    @printf io "\n"
end

function printf(io::IO, fmt::Dict{String, Format}, width::Dict{String, Int64}, show::OrderedDict{String, Bool}, delimiter::String, style::Bool, dicts::Dict{String, String}...)
    for data in dicts
        for (key, value) in show
            if value
                print(io, format(fmt[key], width[key], data[key]))
            end
        end
        @printf io "\n"
    end

    if style
        print(io, delimiter)
        for (key, value) in show
            if value
                print(io, format(fmt["Break"], "-" ^ width[key]))
            end
        end
        @printf io "\n"
    end
end

function printf(io::IO, fmt::Dict{String, Format}, width::Dict{String, Int64}, show::OrderedDict{String, Bool}, delimiter::String, style::Bool)
    if style
        print(io, delimiter)
        for (key, value) in show
            if value
                print(io, format(fmt["Break"], "-" ^ width[key]))
            end
        end
        @printf io "\n"
    end
end

function printf(io::IO, fmt::Format, heading::OrderedDict{String, Int64}, delimiter::String)
    print(io, delimiter)
    for (key, width) in heading
        if width >= 0
            print(io, format(fmt, width, ""))
        end
    end
    @printf io "\n"
end

function printf(io::IO, fmt::Dict{String, Format}, show::OrderedDict{String, Bool}, width::Dict{String, Int64}, value::Array{String,1}, i::Int64, key::String)
    if show[key]
        print(io, format(fmt[key], width[key], value[i]))
    end
end

function printf(io::IO, fmt::Dict{String, Format}, show::OrderedDict{String, Bool}, width::Dict{String, Int64}, value::OrderedDict{String, Int64}, i::Int64, key::String)
    if show[key]
        print(io, format(fmt[key], width[key], iterate(value, i)[1][1]))
    end
end

function getLabel(show::OrderedDict{String, Bool}, label::L, labelComponent::OrderedDict{String, Int64}, headings::String...)
    if isset(label)
        busLabel = labelComponent
    else
        anyshow = false
        for heading in headings
            if show[heading]
                anyshow = true
                break
            end
        end

        if anyshow
            busLabel = collect(keys(labelComponent))
        else
            busLabel = String[]
        end
    end

    return busLabel
end

function getLabel(label::OrderedDict{String, Int64}, i::Int64)
    return iterate(label, i)[1][1]
end