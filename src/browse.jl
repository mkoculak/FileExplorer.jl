AbstractTrees.children(d::AbstractFolder) = collect(values(d.children))
AbstractTrees.children(f::AbstractFile) = ()

function AbstractTrees.printnode(io::IO, f::AbstractFolder)
    icon = get(f.style, :icon, style[:folder_icon])
    color = get(f.style, :color, style[:folder_color])
    name = basename(f.path)
    print(io, "$icon ")
    printstyled(io, name, color=Symbol(color))
end

function AbstractTrees.printnode(io::IO, f::AbstractFile)
    icon = get(f.style, :icon, style[:file_icon])
    color = get(f.style, :color, style[:file_color])
    name = basename(f.path)
    print(io, "$icon ")
    printstyled(io, name, color=Symbol(color))
end

function browse(folderpath; hidden=false, lazy=false, kwargs...)
    folder = Folder(folderpath; hidden=hidden, lazy=lazy)
    return browse(folder; kwargs...)
end

function browse(folder::AbstractFolder; maxdepth=1, indicate_truncation=false, prefix=" ", kwargs...)
    return AbstractTrees.print_tree(folder; maxdepth=maxdepth, 
            indicate_truncation=indicate_truncation, prefix=prefix, kwargs...)
end