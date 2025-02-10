"""
    style::Dict{Symbol, AbstractString}

Dictionary containing styling options implemented in the package.
Currently, the following options are available:

| Key | Value |
| :-- | :---- |
| `:folder_icon` | "📁" |
| `:file_icon` | "📄" |
| `:folder_color` | "blue" |
| `:file_color` | "white" |
"""
const style = Dict{Symbol, AbstractString}(
    :folder_icon => "📁",
    :file_icon => "📄",
    :folder_color => "blue",
    :file_color => "white",
)