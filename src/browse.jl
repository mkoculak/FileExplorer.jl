AbstractTrees.children(d::AbstractFolder) = collect(values(d.children))
AbstractTrees.children(f::AbstractFile) = ()

function AbstractTrees.printnode(io::IO, f::AbstractFolder; kwargs...)
    icon = get(f.style, :icon, style[:folder_icon])
    color = get(f.style, :color, style[:folder_color])
    name = basename(f.path)
    print(io, "$icon ")
    printstyled(io, name, color=Symbol(color))
end

function AbstractTrees.printnode(io::IO, f::AbstractFile; kwargs...)
    icon = get(f.style, :icon, style[:file_icon])
    color = get(f.style, :color, style[:file_color])
    name = basename(f.path)
    print(io, "$icon ")
    printstyled(io, name, color=Symbol(color))
end

"""
    browse(folderpath::String; hidden=false, lazy=false, kwargs...)

Display the contents of a folder in a tree view.
Calling `browse` directly on a folder path will create a `Folder` object and pass it to the proper method. See [`browse(folder::AbstractFolder; kwargs...)`](@ref) for more details on the possible keyword arguments.

- `path`: The path to the folder.
- `hidden=false`: Whether to include hidden files and folders.
- `lazy=false`: Whether to map contents of the subfolders.
- `show_files=true`: Whether to show files.
"""
function browse(folderpath::String; hidden=false, lazy=false, show_files=true, kwargs...)
    folder = Folder(folderpath; hidden=hidden, lazy=lazy, index_files=show_files)
    return browse(folder; kwargs...)
end


"""
    browse(folder::AbstractFolder; maxdepth=1, indicate_truncation=false, prefix=" ", kwargs...)

Display the contents of a folder in a tree view.
Under the hood, this function is just a thin wrapper around `AbstractTrees.print_tree`. We provide a default configuration through the keyword arguments mentioned explicitly in the signature. See documentation of `AbstractTrees` for more details on other possible keyword arguments.

- `folder`: Folder object to display.
- `maxdepth=1`: Maximum depth to display. Defaults to only the immediate children.
- `indicate_truncation=false`: Whether to indicate that subfolders contain more objects.
- `prefix=" "`: Prefix to use for spacing from the tree structure glyphs.
- `show_files=true`: Whether to show files.
"""
function browse(folder::AbstractFolder; maxdepth=1, indicate_truncation=false, prefix=" ", show_files=true, kwargs...)
    # Replace the folder with a copy with no files to show only folder structure.
    if !show_files && folder.nFiles > 0
        folder = _remove_files(folder)
    end
    return AbstractTrees.print_tree(folder; maxdepth=maxdepth, 
            indicate_truncation=indicate_truncation, prefix=prefix, kwargs...)
end