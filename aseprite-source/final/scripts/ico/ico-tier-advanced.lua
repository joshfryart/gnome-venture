-- ico-tier-advanced: tier badge 2 of 3 (Advanced, 96 pieces). TWO gold pieces locked side by side:
-- the left piece's tab sits in the right piece's socket; one outer tab up (left piece), one down (right piece).
-- Run: python3 aseprite-source/tools/aseshim.py aseprite-source/final/scripts/ico/ico-tier-advanced.lua
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ico/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- two 22x22 cells: left x 8..29, right x 30..51, y 20..41
local knob = c:ellipse(34, 30.5, 5):add(c:rect(30, 28, 31, 33))           -- joint tab, left -> right
local L = c:rect(8, 20, 29, 41):add(knob)
L:add(c:ellipse(18.5, 13, 5)):add(c:rect(16, 15, 21, 20))                 -- outer tab up
local R = c:rect(30, 20, 51, 41):cut(knob)
R:add(c:ellipse(41.5, 48, 5)):add(c:rect(39, 41, 44, 46))                 -- outer tab down
c:build{
  { "left",  L, "gold", { gloss = { 11, 23 } } },
  { "right", R, GV.ramp("#d0862a", { shade = "#a8541c", rim = "#f0a94e" }), { gloss = { 34, 23 }, light = L:copy():add(R) } },
}
-- the cut line: right-piece pixels that touch the left piece go umber
local cut = c:mask()
R:each(function(x, y) if L:has(x-1, y) or L:has(x+1, y) or L:has(x, y-1) or L:has(x, y+1) then cut:set(x, y) end end)
c:fill(cut, "#4a2c1a")
local t = c:save(D .. "final/aseprite/ico/ico-tier-advanced.aseprite", PNG .. "ico-tier-advanced.png")
print("ico-tier-advanced", GV.report(t))
