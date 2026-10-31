-- cooking-imp.lua : crafting-area map tile "cooking" (claude/craftmap-art-brief.md), 64x64, gvlib "icon" mode,
-- Stitched Toy (art-style-guide Part D). Impeccable-lens comparison of the plain cooking tile.
-- Run: AppRun -b --script cooking-imp.lua      Writes out/cooking-imp.png + out/cooking-imp.aseprite.
-- Subject: a black-iron skillet seen from above at 3/4, full of red tomato stew (the red/orange hero colour),
-- on a tiny gold flame, one cream steam curl, a wooden spoon standing in the stew, a red felt handle sleeve
-- (gold seam + button: the one real stitched join).
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/out/"
local C = GV.C

-- felt(hex): gvlib ramp with deep = shade and bounce = base (one shade, like the cf icons)
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end

local IRON  = felt("#4a4a5e", { gloss = "#b4b4c8", dot = "#e2e0ea", rim = "#6e6e86", shade = "#302a40" })
local STEW  = felt("#dd3a2a", { gloss = "#ff9158", dot = "#ffc27a", rim = "#f2793a", shade = "#ae2a2a" })
local WOOD  = felt("#b07a45", { gloss = "#ecc58a", dot = "#ecc58a", rim = "#d9a660", shade = "#8a4f2a" })
local FLAME = felt("#f08a24", { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", shade = "#e0501f" })
local STEAM = GV.R.cream

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- skillet: rim ellipse + 4 px wall
local CX, CY, RX, RY = 25, 31, 18, 9
local pan = c:ellipse(CX, CY, RX, RY):add(c:rect(CX - RX, CY, CX + RX, CY + 4)):add(c:ellipse(CX, CY + 4, RX, RY):cut(c:rect(0, 0, 63, CY + 3)))
local inner = c:ellipse(CX, CY - 0.5, RX - 3, RY - 2.5)
local stew = c:ellipse(CX, CY + 0.5, RX - 3, RY - 3)
local handle = c:line({ { 41, 33 }, { 56, 28 } }, 5)
local sleeve = handle:copy():clip(c:rect(47, 0, 63, 63))
-- tiny flame: three tongues under the pan bottom
local flame = c:poly({ {17, 44}, {19, 50}, {21, 46}, {25, 56}, {29, 46}, {31, 50}, {33, 44} })
local spoon = c:line({ { 31, 30 }, { 47, 11 } }, 4):add(c:ellipse(47.5, 10.5, 3, 3))
local steam = c:line({ { 18, 25 }, { 15, 21 }, { 15, 17 }, { 19, 14 }, { 20, 10 }, { 17, 7 } }, 3)

c:build{
  { "flame", flame, FLAME, { cres = 3, gloss = false } },
  { "pan", pan, IRON, { cres = 4, gloss = { 10, 28 } } },
  { "handle", handle, IRON, { cres = 2, gloss = false } },
  { "sleeve", sleeve, STEW, { cres = 2, gloss = false } },
}
c:fill(inner, IRON.shade)
c:build{
  { "stew", stew, STEW, { cres = 3, gloss = { 16, 28 } } },
  { "spoon", spoon, WOOD, { cres = 2, gloss = false } },
  { "steam", steam, STEAM, { flat = true } },
}
c:seam({ { 49, 30 }, { 56, 28 } }, { gap = STEW.shade })
c:button(45, 29)

local t = c:save(OUT .. "cooking-imp.aseprite", OUT .. "cooking-imp.png")
print("cooking-imp " .. GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3, "check failed")
