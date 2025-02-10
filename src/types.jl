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
| :--- | :--: | :---------- |
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
"""
function Folder(path::String; hidden=false, lazy=false)
    # Check if the path exists and normalize its form (trailing slashes, etc.)
    path = realpath(path)
    # Get all the elements in the directory
    root, folderPaths, filePaths = first(walkdir(path, follow_symlinks=true))

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
        children[element] = lazy ? Folder(elPath, Base.stat(path), style, children, 0, 0) : Folder(elPath, hidden=hidden, lazy=lazy)
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
| :--- | :--: | :---------- |
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
Base.getindex(f::AbstractFolder, key::String) = f.children[key]

function Base.show(io::IO, d::AbstractFolder)
    print(io, "Folder: $(basename(d.path)) ($(d.nFolders) folders, $(d.nFiles) files)")
end

function Base.show(io::IO, f::AbstractFile)
    print(io, "File: $(basename(f.path))")
end
