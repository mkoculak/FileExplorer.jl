# FileExplorer.jl

*Explore folders and files as Julia structures.*

Package provides structures to represent files and folders without leaving the REPL as well as methods to display them in the terminal. This not only allows for exploring the contents of the filesystem but also provides an easy way to interact with it in Julia.

!!! note
    This package is in its early development stage and many things might change in the future. We are also open to suggestions and contributions.

## Installation

Package can be installed directly from the Julia package manager:

```
pkg> add FileExplorer
```

To get the version with not yet released features, you can install it directly from GitHub:

```
pkg> add https://github.com/mkoculak/FileExplorer.jl.git
```

## Basic usage

The core of the package is a nested structure of `Folder` and `File` objects that represents the selected directory and its contents. To create a new `Folder` object, simply provide the path to the directory:

```@setup path
pathToFileExplorer = "../../"
```

```@example path
using FileExplorer

f = Folder(pathToFileExplorer)
```

Contents of the folder are stored as separate structures in the `children` field in a dictionary:

```@example path
f.children
```

You can access the contents directly by using the dictionary syntax (and this can be chained):

```@example path
f["docs"]["src"]
```

Each `Folder` and `File` object contains additional information about itself in the `stat` field. This provides infromation from the `stat` function from the `Base` module and returns a `StatStruct` object.

```@example path
f["src"]["FileExplorer.jl"].stat
```

## Additional options

Default settings map the full hierarchy of subfolders at once as well as ignore hidden files and folders. You can change this behavior by providing additional keyword arguments.

```@example path
f = Folder(pathToFileExplorer; hidden=true)
f.children
```

Using the `lazy` keyword argument will prevent mapping anything else but the direct children of the folder. At the moment, you will have to repeat the call without the option or call the `Folder` method on the desired subfolder to map its contents.

```@example path
f = Folder(pathToFileExplorer; lazy=true)
f.children
```