-- trek-foot-v (family 6, marker, 12x12): footprints for a north-south walk. Two flat upright oval prints
-- (no outline), side by side and offset in depth, each with a transparent heel notch.
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local NAME, W, H = "trek-foot-v", 12, 12

local THREAD, THREAD2, GLOSS = "#f5cf6a", "#e8a317", "#fff1c8"
local c = GV.canvas{ w = W, h = H, mode = "scene" }
-- one print: 4x6 upright sole, rounded toe, heel row split by a 1 px notch (second column),
-- 1 px gloss at the upper-left, 1 px thread2 at the lower-right
local function print_(x, y)
  c:paint({
    ".TT.",
    "TGTT",
    "TTTT",
    "TTTT",
    "TTTT",
    "T.TS",
  }, x, y, { T = THREAD, G = GLOSS, S = THREAD2 })
end
print_(1, 0)   -- print A: x1..4, y0..5, gloss (2,1), thread2 (4,5), notch (2,5)
print_(7, 6)   -- print B: x7..10, y6..11, gloss (8,7), thread2 (10,11), notch (8,11)

local t = c:save(ROOT .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", ROOT .. "trek-pixel/png/" .. NAME .. ".png")
print(NAME .. ": " .. GV.report(t))
