-- trek-foot-h (family 6, marker, 12x12): footprints for an east-west walk. Two flat horizontal oval prints
-- (no outline: marks on the ground), left one higher, each with a toe dot ahead of it to the east.
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local NAME, W, H = "trek-foot-h", 12, 12

local THREAD, THREAD2, GLOSS = "#f5cf6a", "#e8a317", "#fff1c8"
local c = GV.canvas{ w = W, h = H, mode = "scene" }
-- one print: 6x4 sole, rounded at the heel (west) corners and the top toe corner,
-- 1 px gloss upper-left, 1 px thread2 at the lower-right, toe dot 1 px ahead
local function print_(x, y)
  c:paint({
    ".GTTT.",
    "TTTTTT",
    "TTTTTT",
    ".TTTTS",
  }, x, y, { T = THREAD, G = GLOSS, S = THREAD2 })
  c:px(x + 7, y + 1, THREAD) -- toe dot
end
print_(0, 1)   -- print A: x0..5, y1..4, toe (7,2)
print_(4, 7)   -- print B: x4..9, y7..10, toe (11,8) (1 px left of the spec box so its toe dot keeps the same 1 px gap as print A)

local t = c:save(ROOT .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", ROOT .. "trek-pixel/png/" .. NAME .. ".png")
print(NAME .. ": " .. GV.report(t))
