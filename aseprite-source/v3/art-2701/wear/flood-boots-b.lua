-- flood-boots-b ICON redo (64x64): cut b = a stitched mustard cloth patch sewn on the boot shaft (was a gem-like orange block on the toe).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(DIR .. "/_patch.lua")
local c = M.start("flood-boots-b", "flood-boots")
M.patch(c, 18, 30, 8, 7, { edge = "#7a4a1c", base = "#e0a03e", alt = "#c98a30", thread = "#fff0c8" })
M.save(c, "flood-boots-b")
