## Abstract Types
```@docs
FileExplorer.ExpNode
FileExplorer.AbstractFolder
FileExplorer.AbstractFile
```

## Folder
```@docs
Folder
Folder(path::String; hidden=false, lazy=false)
```

## File
```@docs
File
File(path::String)
```

## List elements
```@docs
ls(folder::FileExplorer.AbstractFolder)
dir(folder::FileExplorer.AbstractFolder)
```

## Browse elements
```@docs
browse(folderpath::String; hidden=false, lazy=false, kwargs...)
browse(folder::FileExplorer.AbstractFolder; maxdepth=1, indicate_truncation=false, prefix=" ", kwargs...)
```

## Styling
```@docs
FileExplorer.style
```