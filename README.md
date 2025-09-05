# <img src="https://raw.githubusercontent.com/mkoculak/FileExplorer.jl/refs/heads/main/docs/src/assets/favicon.ico" height=30px> FileExplorer

[![Build Status](https://github.com/mkoculak/FileExplorer.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/mkoculak/FileExplorer.jl/actions/workflows/CI.yml?query=branch%3Amaster)

Package provides a simple interface to explore your filesystem as a tree structure and print it in the REPL.  
It has two main functions:  
#### 1. represent the chosen directory or file as a Julia struct
```julia
julia> using FileExplorer
julia> f = Folder("path/to/FileExplorer.jl")
Folder: FileExplorer.jl (2 folders, 4 files)
```
Its contents can be found in `children` filed and accessed as a dictionary:
```julia
julia> f.children
OrderedCollections.OrderedDict{String, FileExplorer.ExpNode} with 6 entries:
  "src"           => Folder: src (0 folders, 5 files)…
  "test"          => Folder: test (0 folders, 1 files)…
  "LICENSE"       => File: LICENSE…
  "Manifest.toml" => File: Manifest.toml…
  "Project.toml"  => File: Project.toml…
  "README.md"     => File: README.md…

julia> f["Project.toml"]
File: Project.toml
```
Additionally, each folder and file contains more information about itself in the `stat` field.
&nbsp;  
#### 2. display the contents in the REPL
We mimic the behavior of popular commands like `ls` and `dir` to provide a text-only overview:
```julia
julia> ls(f)
Path: D:\Github\FileExplorer.jl
Total elements: 6
src  test  LICENSE  Manifest.toml  Project.toml  README.md

julia> ls(z, long=true)
Path: D:\Github\FileExplorer.jl
Total elements: 6
drw-rw-rw-     0  07 Sep 12:09  src
drw-rw-rw-     0  09 Apr 14:04  test
-rw-rw-rw-  1115  09 Apr 14:04  LICENSE
-rw-rw-rw-   764  17 Sep 22:09  Manifest.toml
-rw-rw-rw-   438  17 Sep 22:09  Project.toml
-rw-rw-rw-   332  25 Nov 01:11  README.md
```
As well as a richer tree representation:
```julia
julia> browse(f)
📁 FileExplorer.jl
 ├─ 📁 src
 ├─ 📁 test
 ├─ 📄 LICENSE
 ├─ 📄 Manifest.toml
 ├─ 📄 Project.toml
 └─ 📄 README.md
```
Package allows for a number of customisations to the displayed output through keyword arguments. For more information, please refer to the documentation or the docstrings.
&nbsp;

## Roadmap
FileExplorer.jl is a work in progress and we are open to suggestions and contributions.
There is a number of features that we would like to add in the future, such as:
- [ ] interface to easily extend the package with custom folder/file types
- [ ] styling handled by `Preferences.jl`
- [ ] a dedicated REPL mode to browse the filesystem
- [ ] interactive browsing in the REPL  

If you have any ideas how to implement them or would like to contribute in any other way, please let us know!
&nbsp;

## Acknowledgements
This package is mostly an extension of an [example](https://github.com/JuliaCollections/AbstractTrees.jl/blob/master/test/examples/fstree.jl) in the AbstractTrees.jl package. Many thanks to the authors of the package for the inspiration.