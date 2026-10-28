-- ico-tier-expert: tier badge 3 of 3 (Expert, 216 pieces). THREE pieces in an ember ramp (orange top, red left, crimson right) locked in a pyramid
-- (two on the bottom, one riding on top), with a gold star stud on the top piece.
-- Run: python3 aseprite-source/tools/aseshim.py aseprite-source/final/scripts/ico/ico-tier-expert.lua
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ico/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- cells 21x21: bottom-left x 9..29, bottom-right x 30..50 (y 31..51); top x 20..40 (y 10..30)
local kLR = c:ellipse(33.5, 41, 4.5):add(c:rect(30, 39, 31, 43))          -- bottom-left tab -> bottom-right
local kTL = c:ellipse(25, 34.5, 4.5):add(c:rect(23, 31, 27, 32))          -- top tab down -> bottom-left
local kRT = c:ellipse(36, 26.5, 4.5):add(c:rect(34, 29, 38, 30))          -- bottom-right tab up -> top
local T  = c:rect(20, 10, 40, 30):add(kTL):cut(kRT)
local BL = c:rect(9, 31, 29, 51):add(kLR):cut(kTL)
local BR = c:rect(30, 31, 50, 51):add(kRT):cut(kLR)
local all = T:copy():add(BL):add(BR)
c:build{
  { "bl",  BL, "red", { gloss = { 12, 34 }, light = all } },
  { "br",  BR, GV.ramp("#a8304a", { shade = "#7a2242", deep = "#4a1a34", rim = "#d0505a" }), { gloss = false, light = all } },
  { "top", T,  GV.ramp("#f07a3a", { shade = "#c4502c", deep = "#8a2c26", rim = "#ffa860", gloss = "#ffd27a", dot = "#fff1c8" }), { gloss = { 23, 13 }, light = all } },
}
-- cut lines between the three pieces (umber, lit side a step lighter)
local function cutline(a, b, hex)
  local m = c:mask()
  b:each(function(x, y) if a:has(x-1, y) or a:has(x+1, y) or a:has(x, y-1) or a:has(x, y+1) then m:set(x, y) end end)
  c:fill(m, hex)
end
cutline(BL, BR, "#2a1a10"); cutline(BL, T, "#4a2c1a"); cutline(BR, T, "#2a1a10")
-- gold star stud on the top piece: the prize tier
c:paint({ "...s...", "..sss..", "sssssss", ".sssss.", "..sss..", ".ss.ss." }, 27, 15, { s = "#f5cf6a" })
c:paint({ "...h...", "..h...." }, 27, 15, { h = "#fff1c8" })
local t = c:save(D .. "final/aseprite/ico/ico-tier-expert.aseprite", PNG .. "ico-tier-expert.png")
print("ico-tier-expert", GV.report(t))
