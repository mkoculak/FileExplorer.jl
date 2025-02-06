module FileExplorer

import Base.Filesystem as FS
import Base.Ryu: writefixed
import AbstractTrees
import Dates: format, unix2datetime, Year, now
import OrderedCollections: OrderedDict

include("types.jl")
export Folder, File

include("ls.jl")
export ls, dir

include("browse.jl")
export browse

include("styling.jl")

end # module
