# Customisation

Current implementation allows for basic customisation of how the elements are displayed. This is handled by the `style` property each `Folder` and `File` object has. There, we can change the color of the text as well as the Unicode icon that is used in the tree view.

```@setup customisation
pathToFileExplorer = "../../"
```

```@example customisation
using FileExplorer
f = Folder(pathToFileExplorer)
browse(f)
```

```@example customisation
f["docs"].style[:color] = "red"
f["Project.toml"].style[:icon] = "🗼"
browse(f)
```

There is also a rudimentary system of changing there properties for all elements of the same type through a global `style` dictionary (which is not exported).

```@example customisation
FileExplorer.style[:file_color] = "green"
FileExplorer.style[:folder_icon] = "💼"

browse(f)
```

As you can see, local object setting superseed the global style dictionary. In the future, we would like this functionality to be handled by `Preferences.jl`.