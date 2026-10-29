-- banner-MENA-pets.lua : Cat Fish pet shop banner for "Lantern & Lounge" (Dunewhisper, MENA market town).
-- Matches the region banners in game/assets/img/scenes/banner-*.png: 240x60 grid written at 2x -> 480x120,
-- gvlib "scene" mode (no black border), cavern-ceiling top band + Dunewhisper desert cave air (same colours as
-- banner-MENA.png), gold hem stitch top and bottom, colour cap 24.
-- Focal: one whitewashed shop with a gold cat-eared dome, a glowing horseshoe-arch door, two striped awnings,
-- brass lanterns, a hanging cat sign (no text), a kilim rug, a ginger cat napping on a cushion, a cream cat by the pots.
-- Run: AppRun -b --script banner-MENA-pets.lua   (writes art22/out/banner-MENA-pets.png + .aseprite)
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local c = GV.canvas{ w = 240, h = 60, mode = "scene", out = 2, ol = 1, olx = 1 }
local W, H = c.W, c.H
local floor, sin = math.floor, math.sin

-- shared palette (keep <= 24 colours)
local K = {
  rock = "#3d2a1c", u3 = "#2a1a10", u2 = "#4a2c1a", u1 = "#74462a",
  terra = "#a8582f", clay = "#d9885a", sand = "#f5cf6a", goldB = "#e8a317", goldS = "#d0862a",
  dune = "#c9a96e", stone = "#d8c49a", cream = "#f2e4c0", glow = "#fff3c8",
  teal = "#3f8fb0", tealS = "#2f6290", red = "#dd3a2a", redS = "#ae2a2a", ginger = "#f08a24",
  leaf = "#4f9a45", leafS = "#2f5a2a", leafL = "#7ab55c", wood = "#8a4f2a", woodD = "#5e2f1e",
}
local function R(t) return { gloss = t[1], dot = t[2], rim = t[3], base = t[4], shade = t[5], deep = t[6], bounce = t[7] } end
local WALL  = R{ K.glow, K.glow, K.glow, K.cream, K.stone, K.dune, K.stone }
local GOLD  = R{ K.glow, K.glow, K.sand, K.goldB, K.goldS, K.terra, K.goldS }
local TEAL  = R{ K.cream, K.glow, K.teal, K.teal, K.tealS, K.tealS, K.tealS }
local RED   = R{ K.ginger, K.sand, K.red, K.red, K.redS, K.redS, K.redS }
local CAT   = R{ K.sand, K.glow, K.sand, K.ginger, K.goldS, K.terra, K.goldS }
local CREAMCAT = R{ K.glow, K.glow, K.glow, K.stone, K.dune, K.goldS, K.dune }
local WOOD  = R{ K.terra, K.terra, K.terra, K.wood, K.woodD, K.woodD, K.woodD }
local POT   = R{ K.clay, K.sand, K.clay, K.terra, K.wood, K.woodD, K.wood }
local LEAF  = R{ K.leafL, K.leafL, K.leafL, K.leaf, K.leafS, K.leafS, K.leafS }

----------------------------------------------------------------- sky: Dunewhisper cave air + ceiling
c:fill(c:rect(0, 0, W - 1, 11), K.terra)
c:fill(c:rect(0, 12, W - 1, 23), K.clay)
c:fill(c:rect(0, 24, W - 1, H - 1), K.sand)
for x = 0, W - 1 do
  local d = 3 + floor(1.2 * sin(x / 9) + 0.8 * sin(x / 4.3) + 0.5)
  c:fill(c:rect(x, 0, x, d), K.rock)
end
local i = 0
for x = 6, W - 1, 15 do
  i = i + 1
  if x > 98 and x < 142 then goto skip end
  local h = 4 + (x * 7) % 5; if i % 4 == 0 then h = h + 5 end
  c:fill(c:poly({ { x - 3, 3 }, { x, 3 + h }, { x + 3, 3 } }), K.u3)
  ::skip::
end
-- spore-mist wisp (flat)
local function wisp(x, y, s)
  local m = c:ellipse(x, y, 9 * s, 2):add(c:ellipse(x + 5 * s, y - 1, 6 * s, 2))
  c:fill(m, K.sand)
end
wisp(40, 9, 1); wisp(196, 8, 0.8)

----------------------------------------------------------------- far town (flat, no outline)
local far = c:mask()
local function house(x0, x1, top) far:rect(x0, top, x1, 45) end
local function dome(cx, cy, r) far:add(c:ellipse(cx, cy, r, r * 0.85):cut(c:rect(0, cy + 1, W, H))); far:rect(cx - r, cy, cx + r, 45) end
house(0, 12, 33); dome(22, 30, 8); house(30, 44, 35); house(46, 58, 31); dome(65, 34, 6)
house(174, 188, 32); dome(198, 30, 7); house(206, 220, 35); dome(229, 31, 9)
far:rect(52, 24, 55, 31); far:rect(51, 23, 56, 24)        -- slim tower on the left
far:rect(212, 26, 215, 35); far:rect(211, 25, 216, 26)    -- and one on the right
c:fill(far, K.stone)
-- shaded right faces, windows (small arches)
for _, w in ipairs({ { 4, 37 }, { 34, 39 }, { 50, 36 }, { 178, 37 }, { 184, 37 }, { 210, 39 }, { 224, 36 }, { 19, 36 }, { 196, 35 } }) do
  c:fill(c:rect(w[1], w[2], w[1] + 1, w[2] + 2), K.dune)
end
for _, x in ipairs({ 12, 44, 58, 188, 220 }) do c:fill(c:rect(x, 30, x, 45), K.dune) end

----------------------------------------------------------------- ground
c:fill(c:rect(0, 45, W - 1, H - 1), K.dune)
c:fill(c:rect(0, 45, W - 1, 45), K.stone)
for _, d in ipairs({ { 8, 52 }, { 30, 55 }, { 52, 50 }, { 176, 54 }, { 196, 51 }, { 222, 55 }, { 64, 56 }, { 208, 57 } }) do
  c:paint({ "x.x", ".x." }, d[1], d[2], { x = K.goldS })
end
-- tiled path from the door (stone slabs)
local path = c:poly({ { 107, 49 }, { 133, 49 }, { 140, 58 }, { 100, 58 } })
c:fill(path, K.stone)
for y = 52, 57, 3 do c:fill(c:rect(100, y, 140, y):clip(path), K.dune) end

----------------------------------------------------------------- palm, left of the shop (behind wall edge)
c:part(c:line({ { 70, 48 }, { 70, 40 }, { 71, 32 }, { 73, 25 } }, 3), WOOD, { gloss = false, cres = 2, deep = 0 })
local fronds = c:mask()
for _, f in ipairs({
  { { 73, 24 }, { 66, 22 }, { 61, 25 } }, { { 73, 24 }, { 80, 22 }, { 85, 25 } },
  { { 73, 24 }, { 69, 18 }, { 64, 17 } }, { { 73, 24 }, { 77, 18 }, { 82, 17 } },
  { { 73, 24 }, { 67, 27 }, { 64, 31 } },
}) do fronds:add(c:line(f, 3)) end
c:part(fronds, LEAF, { gloss = false, cres = 2, deep = 0 })

----------------------------------------------------------------- the shop
-- wall block, parapet, dome with cat ears
local wall = c:rect(82, 21, 158, 47)
local parapet = c:rect(80, 18, 160, 21)
for x = 82, 156, 6 do parapet:rect(x, 16, x + 2, 17) end      -- little merlons
local domeM = c:ellipse(119.5, 17, 15, 11):cut(c:rect(0, 18, W, H))
domeM:add(c:poly({ { 105, 12 }, { 107, 2 }, { 114, 7 } }))
domeM:add(c:poly({ { 125, 7 }, { 132, 2 }, { 134, 12 } }))
c:part(domeM, GOLD, { cres = 4, deep = 2 })
c:part(wall, WALL, { cres = 5, deep = 2, gloss = false })
c:part(parapet, WALL, { cres = 2, deep = 1, gloss = false })
c:fill(c:ellipse(119.5, 1, 1.5, 1.5), K.goldB)                 -- finial
c:px(119, 1, K.sand)
-- inner ears (teal felt)
c:fill(c:poly({ { 107, 10 }, { 108, 5 }, { 112, 8 } }), K.redS)
c:fill(c:poly({ { 127, 8 }, { 131, 5 }, { 132, 10 } }), K.redS)
-- dome seam (stitched gores)
c:seam({ { 105, 16 }, { 112, 10 }, { 119, 7 }, { 127, 10 }, { 134, 16 } })

-- door: horseshoe arch, warm glowing inside, teal tiled frame
local door = c:rect(112, 32, 127, 47):add(c:ellipse(119.5, 31, 8, 7))
local frame = door:grow(2):cut(door):cut(c:rect(0, 48, W, H))
c:part(frame, TEAL, { cres = 2, deep = 0, gloss = false, outline = false })
c:fill(door, K.sand)
c:fill(door:copy():cut(door:shrink(1)):cut(c:rect(0, 47, W, H)), K.goldB)   -- inner rim of warm light
for y = 28, 46, 3 do c:px(110, y, K.cream); c:px(129, y, K.cream) end        -- tile joints on the frame
-- inside: shelf with cushions and a lantern
c:fill(c:rect(113, 39, 126, 39), K.wood)
c:part(c:rrect(114, 35, 119, 38, 1), RED, { flat = true, outline = false })
c:part(c:rrect(120, 36, 125, 38, 1), TEAL, { flat = true, outline = false })
c:fill(c:rect(119, 25, 119, 27), K.wood)
c:part(c:rrect(118, 28, 121, 32, 1), GOLD, { flat = true, outline = false })
c:px(119, 30, K.glow); c:px(120, 30, K.glow)
-- cat bed (round basket) on the floor inside
c:part(c:ellipse(122, 45, 4, 2), WOOD, { flat = true, outline = false })

-- windows with mullions and glow
local function window(x0)
  local m = c:rect(x0, 31, x0 + 11, 40):add(c:ellipse(x0 + 5.5, 31, 5.5, 4))
  c:fill(m:grow(1):cut(m), K.u2)
  c:fill(m, K.sand)
  c:fill(m:copy():cut(m:shrink(1)), K.goldB)
  c:fill(c:rect(x0 + 5, 27, x0 + 6, 40), K.wood)
  c:fill(c:rect(x0, 35, x0 + 11, 35), K.wood)
  c:part(c:rect(x0 - 1, 41, x0 + 12, 42), WALL, { flat = true })   -- sill
  return m
end
window(88); window(140)
-- a ginger cat peeking up in the left window
c:fill(c:ellipse(94.5, 39, 3.5, 3):add(c:poly({ { 91, 38 }, { 91, 35 }, { 94, 37 } })):add(c:poly({ { 95, 37 }, { 98, 35 }, { 98, 38 } })), K.ginger)
c:px(93, 39, K.u3); c:px(96, 39, K.u3)
-- jars of treats in the right window
c:part(c:rrect(142, 37, 144, 40, 1), TEAL, { flat = true, outline = false })
c:part(c:rrect(148, 36, 150, 40, 1), RED, { flat = true, outline = false })
c:fill(c:rect(142, 36, 144, 36), K.wood); c:fill(c:rect(148, 35, 150, 35), K.wood)

-- striped awnings over the windows, scalloped hem
local function awning(x0, x1, y0)
  local m = c:poly({ { x0 + 1, y0 }, { x1, y0 }, { x1 + 2, y0 + 4 }, { x0 - 1, y0 + 4 } })
  for x = x0, x1 + 1, 4 do m:rect(x, y0 + 4, x + 2, y0 + 4) end
  local n = 0
  for x = x0 - 1, x1 + 2, 3 do
    local s = c:rect(x, y0, x + 2, y0 + 6):clip(m)
    c:part(s, (n % 2 == 0) and TEAL or WALL, { light = m, outline = false, gloss = false, contact = false, cres = 2, deep = 0, rim = false })
    n = n + 1
  end
  c:outline(m)
end
awning(86, 100, 24)
awning(138, 152, 24)

-- brass lanterns hanging from the parapet
local function lantern(x, y)
  c:fill(c:rect(x + 1, 22, x + 1, y - 1), K.woodD)
  c:part(c:poly({ { x - 1, y + 2 }, { x + 1.5, y - 1 }, { x + 4, y + 2 } }), GOLD, { flat = true })
  c:part(c:rrect(x, y + 2, x + 3, y + 6, 1), GOLD, { flat = true })
  c:px(x + 1, y + 4, K.glow); c:px(x + 2, y + 4, K.glow); c:px(x + 1, y + 3, K.glow)
  c:px(x + 1, y + 7, K.goldS); c:px(x + 2, y + 7, K.goldS)
end
lantern(104, 25)
lantern(133, 25)

-- hanging sign: wooden bracket + round gold disc with a teal cat head (no text)
c:part(c:rect(158, 22, 171, 23), WOOD, { flat = true })
c:fill(c:rect(165, 24, 165, 25), K.woodD); c:fill(c:rect(170, 24, 170, 25), K.woodD)
local sign = c:ellipse(167.5, 31, 6, 6)
c:part(sign, GOLD, { cres = 3, deep = 1, gloss = false })
local cathead = c:ellipse(167.5, 32.5, 3, 2.5):add(c:poly({ { 164, 32 }, { 164, 28 }, { 167, 30 } })):add(c:poly({ { 168, 30 }, { 171, 28 }, { 171, 32 } }))
c:fill(cathead, K.tealS)
c:px(166, 32, K.sand); c:px(169, 32, K.sand)

----------------------------------------------------------------- front: rug, cushion + napping cat, pots + sitting cat
-- kilim rug on the path
local rug = c:poly({ { 109, 48 }, { 131, 48 }, { 134, 53 }, { 106, 53 } })
c:part(rug, RED, { cres = 2, deep = 0, gloss = false, outline = false })
c:fill(rug:copy():cut(rug:shrink(1)), K.teal)
for _, x in ipairs({ 113, 120, 127 }) do
  c:paint({ ".g.", "gsg", ".g." }, x - 1, 49, { g = K.sand, s = K.teal })
end
c:outline(rug)

-- red floor cushion with a ginger cat napping (curled loaf, closed eyes)
c:ground(98, 49, 10, 1.5, K.goldS)
local cush = c:rrect(88, 44, 107, 49, 3)
c:part(cush, RED, { cres = 2, deep = 1, stitch = true })
c:button(96, 46)
local catB = c:ellipse(99, 41, 7, 3.5)
local catH = c:ellipse(92, 40, 4, 3.5):add(c:poly({ { 88, 39 }, { 88, 34 }, { 92, 37 } })):add(c:poly({ { 93, 37 }, { 96, 34 }, { 96, 39 } }))
local tail = c:line({ { 105, 43 }, { 107, 40 }, { 104, 38 } }, 2)
c:build{
  { "tail", tail, CAT, { flat = true } },
  { "body", catB, CAT, { cres = 3, deep = 1 } },
  { "head", catH, CAT, { cres = 2, deep = 1, gloss = false } },
}
c:paint({ "uu.uu" }, 90, 40, { u = K.u3 })                -- sleepy eyes
c:px(92, 42, K.redS)                                       -- nose
c:paint({ "s.s.s" }, 97, 38, { s = K.goldS })              -- tabby stripes

-- clay pots with catgrass, right of the door
local function pot(x, y, w, h)
  local m = c:rrect(x, y, x + w, y + h, 2)
  m:rect(x - 1, y, x + w + 1, y + 1)
  c:part(m, POT, { cres = 2, deep = 1, gloss = false })
  return m
end
local grass = c:mask()
for _, g in ipairs({ { 147, 36, 0 }, { 149, 35, 1 }, { 151, 36, 2 }, { 155, 38, 0 }, { 157, 37, 1 } }) do
  grass:add(c:line({ { g[1], 41 }, { g[1] + g[3] - 1, g[2] } }, 2))
end
c:part(grass, LEAF, { flat = true })
pot(146, 40, 7, 7)
pot(155, 42, 5, 5)

-- cream cat sitting up by the pots, looking out (small locked eyes)
c:ground(140, 48, 6, 1, K.goldS)
local sitB = c:ellipse(140, 44, 5, 4.5)
local sitH = c:ellipse(139.5, 37, 5, 4):add(c:poly({ { 135, 36 }, { 135, 31 }, { 139, 34 } })):add(c:poly({ { 140, 34 }, { 144, 31 }, { 144, 36 } }))
local sitT = c:line({ { 145, 47 }, { 147, 45 }, { 147, 42 } }, 2)
c:build{
  { "stail", sitT, CREAMCAT, { flat = true } },
  { "sbody", sitB, CREAMCAT, { cres = 3, deep = 1, gloss = false } },
  { "shead", sitH, CREAMCAT, { cres = 2, deep = 1, gloss = false } },
}
c:eye(136, 36, true); c:eye(140, 36, true)
c:px(139, 39, K.redS)
c:fill(c:rect(136, 41, 143, 41), K.teal)                   -- little collar
c:px(139, 42, K.goldB)

----------------------------------------------------------------- hem stitch
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })

local t = c:save(OUT .. "banner-MENA-pets.aseprite", OUT .. "banner-MENA-pets.png")
print(GV.report(t))
