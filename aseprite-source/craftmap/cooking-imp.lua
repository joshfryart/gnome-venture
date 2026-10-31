-- cooking-imp.lua : crafting-area map tile "cooking" (claude/craftmap-art-brief.md), 64x64, gvlib "icon" mode,
-- Stitched Toy (art-style-guide Part D). Impeccable-lens comparison of the plain cooking tile.
-- Run: AppRun -b --script cooking-imp.lua      Writes out/cooking-imp.png + out/cooking-imp.aseprite.
-- Subject: a black-iron skillet seen from above at 3/4, full of red tomato stew (the red/orange hero colour),
-- on a tiny gold flame, one cream steam curl, a wooden spoon standing in the stew, a red felt handle sleeve
-- (gold seam: the one real stitched join; a button crowded the 5 px handle, so it is left out).
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

local IRON  = felt("#52526a", { gloss = "#bcbcd2", dot = "#e2e0ea", rim = "#7c7c98", shade = "#342c46" })
local STEW  = felt("#dd3a2a", { gloss = "#ff9158", dot = "#ffc27a", rim = "#f2793a", shade = "#ae2a2a" })
local WOOD  = felt("#b07a45", { gloss = "#ecc58a", dot = "#ecc58a", rim = "#d9a660", shade = "#8a4f2a" })
local FLAME = felt("#f08a24", { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", shade = "#e0501f" })
local STEAM = GV.R.cream

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- skillet: rim ellipse + 4 px wall
local CX, CY, RX, RY = 26, 30, 19, 10
local pan = c:ellipse(CX, CY, RX, RY):add(c:rect(CX - RX, CY, CX + RX, CY + 4)):add(c:ellipse(CX, CY + 4, RX, RY):cut(c:rect(0, 0, 63, CY + 3)))
local inner = c:ellipse(CX, CY - 0.5, RX - 3, RY - 2.5)
local stew = c:ellipse(CX, CY + 0.5, RX - 3, RY - 3)
local handle = c:line({ { 43, 32 }, { 54, 27 } }, 5)
local sleeve = handle:copy():clip(c:rect(47, 0, 63, 63))
-- tiny flame: three upward tongues, the outer two lick up past the pan bottom
local function tongue(x, y, r, tip) return c:ellipse(x, y, r, r):add(c:poly({ {x - r, y}, {x + 0.5, tip}, {x + r + 1, y} })) end
local flame = tongue(19, 50, 3, 41):add(tongue(26, 51, 4, 43)):add(tongue(33, 50, 3, 41))
local core = tongue(26, 52, 2, 47)
local spoon = c:line({ { 33, 29 }, { 47, 12 } }, 4):add(c:ellipse(48, 10.5, 3, 3))
local steam = c:line({ { 20, 23 }, { 17, 20 }, { 17, 17 }, { 20, 14 }, { 21, 10 }, { 18, 7 } }, 4)

c:build{
  { "flame", flame, FLAME, { cres = 3, gloss = false } },
  { "pan", pan, IRON, { cres = 4, gloss = { 10, 27 } } },
  { "handle", handle, IRON, { cres = 2, gloss = false } },
  { "sleeve", sleeve, STEW, { cres = 2, gloss = false } },
}
c:fill(core:cut(pan), FLAME.rim)
c:fill(inner, IRON.shade)
c:build{
  { "stew", stew, STEW, { cres = 3, gloss = false } },
  { "spoon", spoon, WOOD, { cres = 2, gloss = false } },
  { "steam", steam, STEAM, { flat = true } },
}
c:paint({ "..gggd", ".g....", "g....." }, 11, 28, { g = STEW.gloss, d = STEW.dot })     -- enamel comma: the hero's highlight
for _, b in ipairs({ { 21, 31 }, { 29, 33 } }) do                                  -- two simmer bubbles
  c:paint({ ".gg.", "g..s", ".ss." }, b[1], b[2], { g = STEW.gloss, s = STEW.shade })
end
c:seam({ { 48, 30 }, { 55, 27 } }, { gap = STEW.shade })                            -- sleeve seam

local t = c:save(OUT .. "cooking-imp.aseprite", OUT .. "cooking-imp.png")
print("cooking-imp " .. GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3, "check failed")
