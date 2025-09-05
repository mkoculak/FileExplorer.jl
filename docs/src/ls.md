# List view

`FileExplorer.jl` makes it easy to quickly display contents of a folder in the REPL. Since it tries to mimic the behavior of popular commands like `ls` and `dir`, functions under these names are exported.

## LS

The default display of content shows just the names of the elements in a grid.
```@setup ls
pathToFileExplorer = "../../"
```

```@example ls
using FileExplorer

f = Folder(pathToFileExplorer)
ls(f)
```

The default settings should provide a familiar experience to similar commands in the terminal. However, package provides a number of additional options for customisation. For example, you can increase the spacing between elements with the `padding` keyword argument (default is 2 characters).
```@example ls
ls(f, padding=10)
```

Increased padding reveals that elements are populated in the grid column-wise. You can change the direction with the `dims` keyword argument (default is 1).
```@example ls
ls(f, padding=10, dims=2)
```

Additionally, there is also a "long" format available that displays elements in a single column with additional information about each element (similarly to `ls -l` command).
```@example ls
ls(f, long=true)
```

Since there is more information displayed, additional keywords are available to customise the output. For example, you can change the format of file sizes to include units as well as control the degree of rounding the numbers.
```@example ls
ls(f, long=true, unit=:mem, precision=0)
```

There is also an option to display only the folder structure without files.
```@example ls
ls(f, show_files=false)
```

Please check the reference tab or the docstrings for a complete list of available options.

## DIR

Package also provides a `dir` function, but it is only an alias for `ls` with the `long` keyword argument set to `true`. It is provided to make it easier for users to get this popular display style without the need for keywords. However, you can use the same keywords to change the output - they will be passed to the `ls` method. For example, we can add the header to the columns.
```@example ls
dir(f, header=true)
```