abstract type ExpNode end

abstract type AbstractFolder <: ExpNode end
abstract type AbstractFile <: ExpNode end

struct Folder <: AbstractFolder
    path::String
    stat::FS.StatStruct
    style::Dict{Symbol, AbstractString}
    children::OrderedDict{String, ExpNode}
    nFolders::Int64
    nFiles::Int64
end

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

struct File <: AbstractFile
    path::String
    stat::FS.StatStruct
    style::Dict{Symbol, AbstractString}
end

function File(path::String)
    style = Dict{Symbol, AbstractString}()
    return File(path, Base.stat(path), style)
end

# Common operations on default node types
Base.getindex(f::AbstractFolder, key::String) = f.children[key]

function Base.show(io::IO, d::AbstractFolder)
    println(io, "Folder: $(basename(d.path)) ($(d.nFolders) folders, $(d.nFiles) files)")
end

function Base.show(io::IO, f::AbstractFile)
    println(io, "File: $(basename(f.path))")
end
