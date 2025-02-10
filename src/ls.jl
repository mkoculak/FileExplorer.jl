"""
    dir()

Shorthand for listing the contents of the current directory.
"""
dir(; kwargs...) = dir("."; kwargs...)

"""
    dir(path::String; kwargs...)
    dir(folder::AbstractFolder; kwargs...)

List the contents of a directory in a long version, similar to the behavior of `dir` in Windows. Under the hood it is just calling `ls` with `long=true`. Other keyword arguments are passed to the `ls` call. Please look there for more detailed list.
"""
dir(path; kwargs...) = ls(path; long=true, kwargs...)
dir(folder::AbstractFolder; kwargs...) = ls(folder; long=true, kwargs...)

"""
    ls()

Shorthand for listing the contents of the current directory.
"""
ls(; kwargs...) = ls("."; kwargs...)

"""
    ls(path::String; kwargs...)
    
List the contents of a directory at the given path in a grid format.
Function creates a `Folder` object and passes it to the proper method. See [`ls(structure::AbstractFolder; kwargs...)`](@ref) for more details on the possible keyword arguments.

- `path`: The path to the folder.
"""
function ls(path::String; kwargs...)
    # Create directory tree
    folder = Folder(path, lazy=true)

    ls(folder; kwargs...)
end

"""
    ls(folder::AbstractFolder; kwargs...)

List the contents of a folder in a grid format. Function mimics the behavior of `ls` command in Unix-like systems. By default, it tries to fit all elements in the most vertically compact layout (with some default settings, like padding size). There is a number of keyword arguments that can be used to customize the output. Most notably, passing `long=true` will display the content in a single column with typical details like permissions, size, and modification date, similarly to `ls -l`. The actual displayed information will depend on the operating system.

Possible keyword arguments:
- `long::Bool`: Display the content in a single column view. Default is `false`.
- `padding::Int`: The number of spaces between the columns. Default is 2.
- `dims::Int`: The direction of the layout. For elements ordered column-wise use `1`, for row-wise use `2`. Default is `1`.
- `maxWidth::Int`: The maximum width of the columns in characters. Default is 30.
- `unit::Symbol`: The unit to use for file sizes. Possible values are `:none`, `:mem`, and `:memi`. Default is `:none`.
- `precision::Int`: The number of decimal places to show for file sizes. Default is 2.
- `uid::Bool`: Display the user ID. Default is `false`.
- `gid::Bool`: Display the group ID. Default is `false`.
- `header::Bool`: Display the header with column names. Default is `false`.
"""
function ls(folder::AbstractFolder; long=false, kwargs...)
    # Get all elements in the directory
    elements = collect(keys(folder.children))
    nElements = length(elements)

    if long
        # Print the elements in long format
        long_layout(folder, elements, nElements; kwargs...)
    else
        # Print the elements in grid format
        grid_layout(folder, elements, nElements; kwargs...)
    end
end

function long_layout(structure, elements, nElements; padding=2, kwargs...)
    # Get terminal size
    height, width = displaysize(stdout)

    filemode_padding = 10 + padding

    unit = get(kwargs, :unit, :none)
    precision = get(kwargs, :precision, 2)
    precision_padding = precision > 0 ? precision + 1 : 0

    numDigs = map(x -> ndigits(x.stat.size), values(structure.children))
    maxSize = maximum(numDigs)
    maxDig = maximum(mod1.(numDigs, 3))

    if unit == :none
        size_align = maxSize
        units = nothing
        factor = 1
    elseif unit == :mem
        size_align = maxDig + 3 + precision_padding
        units = _mem_units
        factor = 1000
    elseif unit == :memi
        size_align = maxDig + 4 + precision_padding
        units = _memi_units
        factor = 1024
    end
    size_padding = size_align + padding
    date_padding = 12 + padding

    user = get(kwargs, :uid, false)
    group = get(kwargs, :gid, false)

    uid_padding = user ? findmax(x -> x.stat.uid==0 ? 2 : length(FS.getusername(x.stat.uid)), structure.children)[1]+padding : 0
    gid_padding = group ? findmax(x -> x.stat.gid==0 ? 2 : length(FS.getgroupname(x.stat.gid)), structure.children)[1]+padding : 0

    println("Path: $(structure.path)")
    println("Total elements: $nElements")

    if get(kwargs, :header, false)
        filemode_padding = max(filemode_padding, 11+padding)
        printstyled("Permissions", underline=true) 
        print(rpad("", filemode_padding-11))

        size_align = max(size_align, 4)
        size_padding = size_align + padding
        print(lpad("", size_align-4))
        printstyled("Size", underline=true)
        print(rpad("", padding))

        if user
            uid_padding = max(uid_padding, 4+padding)
            printstyled("User", underline=true)
            print(rpad("", uid_padding-4))
        end
        if group
            gid_padding = max(gid_padding, 5+padding)
            printstyled("Group", underline=true)
            print(rpad("", gid_padding-5))
        end

        date_padding = max(date_padding, 4+padding)
        printstyled("Date", underline=true)
        print(rpad("", date_padding-4))
        printstyled("Name", underline=true)
        println()
    end

    maxElementWidth = width - (filemode_padding + size_padding + uid_padding + gid_padding + date_padding)

    for el in elements
        stel = structure.children[el]
        print(rpad(FS.filemode_string(stel.stat), filemode_padding))
        print(rpad(format_size(stel.stat.size, units, precision, factor, size_align), size_padding))
        print(format_owners(stel.stat, user, group, uid_padding, gid_padding))
        print(rpad(format_date(stel.stat.mtime), 12+padding))
        if get(kwargs, :tree, false)
            printnode(stdout, stel)
        else
            print_element(structure, el, min(length(el), maxElementWidth))
        end
        println()
    end
end

# Format the size in a human-readable format, based on Base.format_bytes
const _memi_units = ["B", "KiB", "MiB", "GiB", "TiB", "PiB"]
const _mem_units = ["B", "KB", "MB", "GB", "TB", "PB"]

function format_size(bytes, units, precision, factor, size_align)
    if isnothing(units)
        return lpad(bytes, size_align)
    else
        bytes, mb = Base.prettyprint_getunits(bytes, length(units), Int64(factor))
        mb == 1 ? (units[end] == "PB" ? size_align -= 1 : size_align -= 2) : nothing
        return lpad(string(writefixed(Float64(bytes), precision), " ", units[mb]), size_align)
    end
end

function format_owners(stat, user, group, uid_padding, gid_padding)
    if user
        username = FS.getusername(stat.uid)
        username = isnothing(username) ? "--" : username
        print(rpad(username, uid_padding))
    end
    if group
        groupname = FS.getgroupname(stat.gid)
        groupname = isnothing(groupname) ? "--" : groupname
        print(rpad(groupname, gid_padding))
    end
    return ""
end

# Format the date in a human-readable format, show hour for new files and year for old files
function format_date(timestamp)
    datetime = unix2datetime(timestamp)
    if datetime < now() - Year(1)
        return format(datetime, "dd u  yyyy")
    else
        return format(datetime, "dd u HH:mm")
    end
end

function grid_layout(structure, elements, nElements; padding=2, dims=1, maxWidth=30, kwargs...)
    # Check if maxWidth is not too small
    maxWidth < 5 && throw(ArgumentError("maxWidth must be at least 5"))
    # Get necessary filename information
    nameLengths = length.(elements)
    replace!(x -> x > maxWidth ? maxWidth : x, nameLengths)

    # Get terminal size
    height, width = displaysize(stdout)

    # Estimate a reasonably compact layout for the elements
    rows, cols = estimate_layout(nameLengths, width, padding, dims)

    # Print the elements in the calculated layout
    println("Path: $(structure.path)")
    println("Total elements: $nElements")
    print_grid(structure, elements, nameLengths, rows, cols, padding, dims)
end

function estimate_layout(nameLengths, width, padding, dims)
    # Start with worst case scenario so we only need to make the layout more compact.
    # Every column is of maximal size.
    maxCols = cld(width, maximum(nameLengths) + padding)
    nColumns = maxCols > length(nameLengths) ? length(nameLengths) : maxCols
    nRows = cld(length(nameLengths), nColumns)

    # Test if the layout can be improved by adding more columns
    return test_layout(nameLengths, nRows, nColumns, width, padding, dims, true)
end

# Test the layout with the given number of columns
function test_layout(nameLengths, nRows, nColumns, width, padding, dims, previousOk)
    nElements = length(nameLengths)

    # If initial gues was zero, default to one column
    if iszero(nColumns)
        return nElements, 1
    end

    # Create a temporary layout to test
    layout = fill(0, nRows, nColumns)
    fill_layout!(layout, nElements, values=nameLengths, dims=dims)

    # Group elements into columns and sum the longest name from each
    maxCols = maximum.(eachcol(layout))
    rowLengths = sum(maxCols) + padding*(nColumns-1)
    
    # Check if the length of the row exceeds the width
    if rowLengths <= width
        thisOk = true
        if previousOk
            if dims == 2 
                newColumns = nColumns+1
                newRows = cld(nElements, nColumns+1)
            elseif dims == 1
                nRows == 1 && return nRows, nColumns
                newRows = nRows-1
                newColumns = cld(nElements, newRows)
            end
        else
            return nRows, nColumns
        end
    else
        thisOk = false
        # Layout is too wide, so we return the previous (fitting) layout
        if dims == 2
            newColumns = nColumns-1
            newRows = cld(nElements, nColumns-1)
        else
            newRows = nRows+1
            newColumns = cld(nElements, nRows+1)
        end
    end
    return test_layout(nameLengths, newRows, newColumns, width, padding, dims, thisOk)
end

# This is a temporary workaround to allocating eachslice.
# Should be merged into one after it is fixed (although it might not happen due to instability issues).
function fill_layout!(layout, nElements; values=1:nElements, dims=1)
    if dims == 1
        fill_eachcol!(layout, nElements, values)
    elseif dims == 2
        fill_eachrow!(layout, nElements, values)
    else
        throw(ArgumentError("dims must be either 1 or 2"))
    end
end

function fill_eachcol!(layout, nElements, values)
    element = 0
    for slice in eachcol(layout)
        for i in eachindex(slice)
            if element < nElements
                element += 1
                slice[i] = values[element]
            end
        end
    end
end

function fill_eachrow!(layout, nElements, values)
    element = 0
    for slice in eachrow(layout)
        for i in eachindex(slice)
            if element < nElements
                element += 1
                slice[i] = values[element]
            end
        end
    end
end

# Print the elements in the calculated layout
# function print_grid(structure, elements, rows, cols, colWidths, padding, width, dims, maxWidth)
function print_grid(structure, elements, nameLengths, rows, cols, padding, dims)
    # If its a single column, we can just print the elements in order
    if cols == 1
        for el in elements
            print_element(el, colWidths[1], maxWidth=maxWidth)
            println()
        end

        return nothing
    end

    nElements = length(elements)

    itemLayout = fill(0, rows, cols)
    fill_layout!(itemLayout, nElements, dims=dims)

    sizeLayout = fill(0, rows, cols)
    fill_layout!(sizeLayout, nElements, values=nameLengths, dims=dims)

    # Calculate the width of each column
    colWidths = maximum.(eachcol(sizeLayout))
    colWidths[1:end-1] .+= padding

    # Print the elements in the calculated layout
    for row in axes(itemLayout, 1)
        for col in axes(itemLayout, 2)
            index = itemLayout[row, col]
            element = index != 0 ? elements[index] : ""
            print_element(structure, element, colWidths[col], maxWidth=sizeLayout[row, col])
        end
        println()
    end

    return nothing
end

function print_element(structure, element, colWidth; maxWidth=colWidth)
    if isempty(element) 
        print(rpad("", colWidth))
        return nothing
    end

    color = structure[element] isa Folder ? get(style, :folder_color, "white") : get(style, :file_color, "white")

    if length(element) > maxWidth
        element = shorten(element, maxWidth)
    end

    printstyled(rpad(element, colWidth), color=Symbol(color))

    return nothing
end

function shorten(str::String, n::Int)
    strlen = length(str)

    if strlen > n
        # Account for the ellipsis
        n -= 3
        if iseven(n)
            fp = lp = n ÷ 2
        else
            fp = (n ÷ 2) + 1
            lp = n - fp
        end

        return first(str, fp) * "..." * last(str, lp)
    else
        return str
    end
end
