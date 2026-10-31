-- potions.lua : crafting area map tile "potions" (claude/craftmap-art-brief.md), 64x64, gvlib "icon" mode,
-- Stitched Toy (art-style-guide Part D), house look of aseprite-source/catfish/cf_icons.lua.
-- Subject: a round glass flask of green/teal potion, cork stopper, gold twine tied round the neck, two gold
-- 4-point sparkles. Dominant colour: teal green.
-- Run: AppRun -b --script potions.lua        Writes out/potions.png + out/potions.aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/out/"
local C = GV.C

-- felt(hex): gvlib ramp with deep = shade and bounce = base (one shade only, like cf_icons.lua)
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end
-- 4-point star: long arms R, waist r
local function star(c, cx, cy, R, r)
  local pts = {}
  for i = 0, 7 do
    local ang = i * math.pi / 4 - math.pi / 2
    local d = (i % 2 == 0) and R or r
    pts[#pts + 1] = { cx + 0.5 + math.cos(ang) * d, cy + 0.5 + math.sin(ang) * d }
  end
  return c:poly(pts)
end

local GLASS = felt("#bfe6e0", { gloss = "#f2fbf0", dot = "#f2fbf0", rim = "#e2f6ee", shade = "#7fb8c0", pale = false })
local POT = felt("#2fae7e", { gloss = "#d8f8b8", dot = "#f2fbf0", rim = "#6fd49a", shade = "#1d7a66", deep = "#17575a" })
local WOOD = felt("#b07a45", { gloss = "#ecc58a", dot = "#ecc58a", rim = "#d9a660", shade = "#8a4f2a" })
local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local bulb = c:ellipse(31.5, 39, 17, 16)
local neck = c:rect(26, 13, 37, 26)
local glass = bulb:copy(); glass:add(neck)
local cork = c:rrect(27, 6, 36, 13, 1)
local lip = c:rrect(23, 12, 40, 15, 1)
local liquid = bulb:shrink(2):clip(c:rect(0, 31, 63, 63))
local band = c:rect(25, 19, 38, 21)
local big = star(c, 50, 13, 7, 2.2)
local small = star(c, 12, 18, 4.5, 1.6)

local p = c:build{
  { "cork", cork, WOOD, { cres = 3, gloss = false } },
  { "glass", glass, GLASS, { gloss = false } },
  { "lip", lip, GLASS, { cres = 2, gloss = false } },
  { "liquid", liquid, POT, { cres = 6, deep = 3, gloss = false, contour = "#17575a", contact = false } },
  { "band", band, GOLD, { cres = 2, gloss = false } },
  { "small", small, GOLD, { flat = true, contact = false } },
  { "big", big, GOLD, { cres = 2, gloss = false, bounce = false, contact = false } },
}
-- liquid surface: a lit ellipse at the top of the potion
c:ellipse(31.5, 32, 13, 1.5):clip(liquid):each(function(x, y)
  if c:get(x, y) == POT.base then c:px(x, y, POT.rim) end
end)
-- bubbles (lit)
c:paint({ ".r.", "r.r", ".r." }, 36, 41, { r = POT.rim })
c:paint({ "gg", "gr" }, 40, 36, { g = POT.gloss, r = POT.rim })
c:px(34, 47, POT.rim)
-- potion enamel comma, upper left of the liquid
c:paint({
  "..gggd",
  ".gg...",
  "gg....",
  "g.....",
}, 21, 35, { g = POT.gloss, d = POT.dot })
-- glass window streak: a 1 px arc on the left wall of the bulb, top to middle
c:paint({
  "....gg",
  "..ggg.",
  ".gg...",
  "gg....",
}, 18, 25, { g = GLASS.gloss })
c:paint({ "g", "g", "g" }, 28, 16, { g = GLASS.gloss })              -- neck glint
c:seam({ { 25, 20 }, { 33, 20 } }, { gap = GOLD.shade })            -- twine thread
c:button(34, 19)                                                    -- twine knot button
c:paint({ "gg", "g." }, 29, 7, { g = WOOD.gloss })                  -- cork comma
c:px(50, 13, GOLD.gloss); c:px(49, 12, GOLD.gloss)                  -- star glint

local t = c:save(OUT .. "potions.aseprite", OUT .. "potions.png")
print("potions " .. GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
