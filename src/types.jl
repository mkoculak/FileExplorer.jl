"""
    ExpNode

Abstract type for representing all the objects in the file system.
"""
abstract type ExpNode end

"""
    AbstractFolder <: ExpNode

Abstract type for representing folder types in the file system.
"""
abstract type AbstractFolder <: ExpNode end

"""
    AbstractFile <: ExpNode

Abstract type for representing file types in the file system.
"""
abstract type AbstractFile <: ExpNode end


"""
    Folder <: AbstractFolder

Represent a folder and its contents as a nested structure.

Properties
----------

| Name | Type | Description |
| :--- | :--- | :---------- |
| `path` | `String` | The path to the folder |
| `stat` | `FS.StatStruct` | The stat information |
| `style` | `Dict{Symbol, AbstractString}` | Styling parameters |
| `children` | `OrderedDict{String, ExpNode}` | The contents of the folder |
| `nFolders` | `Int64` | The number of subfolders |
| `nFiles` | `Int64` | The number of files |

"""
struct Folder <: AbstractFolder
    path::String
    stat::FS.StatStruct
    style::Dict{Symbol, AbstractString}
    children::OrderedDict{String, ExpNode}
    nFolders::Int64
    nFiles::Int64
end

"""
    Folder(path::String; hidden=false, lazy=false)

Represent a folder and its contents as a nested structure.

- `path`: The path to the folder.
- `hidden=false`: Whether to include hidden files and folders.
- `lazy=false`: Whether to map contents of the subfolders.
- `index_files=true`: Whether to include files. Set to `false` to see only the folder structure.
"""
function Folder(path::String; hidden=false, lazy=false, index_files=true)
    # Check if the path exists and normalize its form (trailing slashes, etc.)
    path = realpath(path)
    # Get all the elements in the directory
    root, folderPaths, filePaths = first(walkdir(path, follow_symlinks=true))

    # Discard all files and leave just folders in the structure
    !index_files && empty!(filePaths)

    # Filter out hidden files and folders unless specified
    if !hidden
        folderPaths = filter(x -> !startswith(x, '.'), folderPaths)
        filePaths = filter(x -> !startswith(x, '.'), filePaths)
    end

    # Prepare empty containers
    style = Dict{Symbol, AbstractString}()
    children = OrderedDict{String, ExpNode}()
    nFolders = length(folderPaths)
    nFiles = length(filePaths)

    # Map folders in the directory
    for element in folderPaths
        elPath = joinpath(path, element)
        children[element] = lazy ? Folder(elPath, Base.stat(path), style, children, 0, 0) : Folder(elPath, hidden=hidden, lazy=lazy, index_files=index_files)
    end

    # Map files in the directory
    for element in filePaths
        children[element] = File(joinpath(path, element))
    end

    return Folder(path, Base.stat(path), style, children, nFolders, nFiles)
end

"""
    File <: AbstractFile

Represent a file in the file system.

Properties
----------

| Name | Type | Description |
| :--- | :--- | :---------- |
| `path` | `String` | The path to the file |
| `stat` | `FS.StatStruct` | The stat information |
| `style` | `Dict{Symbol, AbstractString}` | Styling parameters |

"""
struct File <: AbstractFile
    path::String
    stat::FS.StatStruct
    style::Dict{Symbol, AbstractString}
end

"""
    File(path::String)

Represent a file in the file system.

- `path`: The path to the file.
"""
function File(path::String)
    style = Dict{Symbol, AbstractString}()
    return File(path, Base.stat(path), style)
end

# Common operations on default node types
Base.getindex(f::AbstractFolder, key::String) = getindex(getproperty(f, :children), key)

# Implementing the iteration interface
Base.iterate(f::AbstractFolder) = iterate(getproperty(f, :children))
Base.iterate(f::AbstractFolder, state) = iterate(getproperty(f, :children), state)
Base.IteratorSize(::Type{<:AbstractFolder}) = Base.IteratorSize{OrderedDict{String, ExpNode}}()
Base.IteratorEltype(::Type{<:AbstractFolder}) = Base.IteratorEltype{OrderedDict{String, ExpNode}}()
Base.length(f::AbstractFolder) = length(getproperty(f, :children))
Base.eltype(f::AbstractFolder) = eltype(getproperty(f, :children))
Base.isdone(f::AbstractFolder, state) = Base.isdone(getproperty(f, :children), state)

function Base.show(io::IO, d::AbstractFolder)
    print(io, "Folder: $(basename(d.path)) ($(d.nFolders) folders, $(d.nFiles) files)")
end

function Base.show(io::IO, f::AbstractFile)
    print(io, "File: $(basename(f.path))")
end

# Dirty way to remove files from the structure for plotting only folder structure.
# WARN: Resulting object has incorrect nFiles field and should not be used outside plotting call.
function _remove_files(f::AbstractFolder)
    f.nFiles == 0 && return f

    f = deepcopy(f)
    _remove_files!(f)

    return f
end

function _remove_files!(f::AbstractFolder)
    for child in keys(f.children)
        if typeof(f.children[child]) <: AbstractFolder
            _remove_files!(f.children[child])
        elseif typeof(f.children[child]) <: AbstractFile
            delete!(f.children, child)
        end
    end
end