-- work-gloves-b ICON redo (64x64): cut b = a stitched denim patch sewn on the palm of the front glove (was a green gem-like block on the cuff).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(DIR .. "/_patch.lua")
local c = M.start("work-gloves-b", "work-gloves")
M.patch(c, 22, 33, 9, 7, { edge = "#243a5e", base = "#4a76ae", alt = "#3d6399", thread = "#f6e8c0" })
M.save(c, "work-gloves-b")
