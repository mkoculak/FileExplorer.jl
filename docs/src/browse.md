# Tree view

`FileExplorer.jl` provides also a tree-like view into the contents of a folder. Right now it is only a thin wrapper around the functionality provided by the `AbstractTrees.jl` package.

## browse

Calling `browse` on a path or a folder structure will display its contents in a hierarchical view.

```@setup browse
pathToFileExplorer = "../../"
```

```@example browse
using FileExplorer

f = Folder(pathToFileExplorer)
browse(f)
```

We set only a few keyword arguments differently than `AbstractTrees.jl`, but the function passes all of them further, so you can use all options they provide. For example, you can change the `maxdepth` option to display deeper folder structures and also decide to show that there are more elements in the folder than displayed.

```@example browse
browse(f, maxdepth=2, indicate_truncation=true)
```

In the future, we want to provide an easy way to customise most of the elements of the output, however right now only very basic customisation is available. For details, please look at the [Customisation](@ref) section.