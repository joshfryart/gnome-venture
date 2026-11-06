-- tools.lua : crafting area map tile "tools" (claude/craftmap-art-brief.md), 64x64, gvlib "icon" mode,
-- Stitched Toy (art-style-guide Part D). Dominant colour: steel blue + wood.
-- Subject: a hammer (steel head, wooden handle with a gold-thread grip wrap) crossed over an open-ended
-- spanner (steel, ring end at the bottom). House look follows aseprite-source/catfish/cf_icons.lua
-- (felt ramps with one shade, enamel comma, gold thread seams 2 on / 1 off, umber contours).
-- Run: AppRun -b --script tools.lua        Writes out/tools.png + out/tools.aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/out/"

-- felt(hex): gvlib ramp with deep = shade and bounce = base (4 felt steps + gloss, like cf_icons)
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end

local STEEL = felt("#5b88b8", { gloss = "#e8f2fa", dot = "#e8f2fa", rim = "#9cc0e0", shade = "#36588e" })
local WOOD = felt("#b07a45", { gloss = "#ecc58a", dot = "#ecc58a", rim = "#d9a660", shade = "#8a4f2a" })

-- oriented box: centre (cx,cy), unit axis (ux,uy), half-length a along it, half-width b across
local function obox(c, cx, cy, ux, uy, a0, a1, b0, b1)
  local vx, vy = -uy, ux
  local function P(t, s) return { cx + 0.5 + ux * t + vx * s, cy + 0.5 + uy * t + vy * s } end
  return c:poly({ P(a0, -b0), P(a1, -b1), P(a1, b1), P(a0, b0) })
end

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- spanner: shaft from lower right to upper left, open jaw head at the top left, ring end at the bottom right
local shaft = c:line({ { 46, 47 }, { 18, 19 } }, 5)
local jaw = c:ellipse(15.5, 16.5, 8.5)
jaw:cut(obox(c, 11.5, 12.5, -0.7071, -0.7071, -2, 9, 3, 3.5))     -- the open slot, facing up-left
local ring = c:ellipse(47, 47, 6)
local hole = c:ellipse(47, 47, 2)

-- hammer: wooden handle from lower left to upper right, steel head across its top
local handle = c:line({ { 13, 51 }, { 39, 23 } }, 5)
local ux, uy = 0.73, 0.68                                        -- head axis, across the handle
local hx, hy = 39, 21
local head = obox(c, hx, hy, ux, uy, -14, 7, 3.5, 5)             -- tapered peen up-left, body
local face = obox(c, hx, hy, ux, uy, 6, 12, 6.5, 6.5)               -- flared striking face down-right

c:build{
  { "shaft", shaft, STEEL, { cres = 2, gloss = false } },
  { "jaw", jaw, STEEL, { cres = 4, gloss = { 11, 14 } } },
  { "ring", ring, STEEL, { cres = 3, gloss = false } },
  { "handle", handle, WOOD, { cres = 2, gloss = false } },
  { "head", head, STEEL, { cres = 3, gloss = false } },
  { "face", face, STEEL, { cres = 3, gloss = false } },
}
c:fill(hole, GV.C.ol3)
c:paint({ "gg", "g." }, 44, 43, { g = STEEL.rim })                     -- ring glint
c:paint({ "..gg", ".g..", "g..." }, 31, 11, { g = STEEL.gloss })        -- enamel comma on the head
c:px(36, 14, STEEL.gloss)
c:paint({ ".g", "g." }, 22, 39, { g = WOOD.gloss })                   -- handle sheen

-- grip wrap on the hammer handle: two bands of gold twine (lit pixels thread gold, shaded thread shade)
for _, q in ipairs({ { 14, 45, 19, 50 }, { 18, 41, 23, 46 } }) do
  local band = c:line({ { q[1], q[2] }, { q[3], q[4] } }, 2):clip(handle)
  band:each(function(x, y) c:px(x, y, ((x - 18) + (y - 46) < 0) and "#f5cf6a" or "#e8a317") end)
end
-- spanner shaft centre seam
c:seam({ { 21, 22 }, { 29, 30 } }, { gap = STEEL.shade })

print(GV.report(c:save(OUT .. "tools.aseprite", OUT .. "tools.png")))
