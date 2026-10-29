-- banner-WCA-pets.lua : Cat Fish pet shop banner for "Drum & Den" (Greatcanopy, WCA market town).
-- Matches the region banners in game/assets/img/scenes/banner-*.png: 240x60 grid written at 2x -> 480x120,
-- gvlib "scene" mode (no black border), the Greatcanopy canopy-ceiling top band and moss greens of banner-WCA.png,
-- gold hem stitch top and bottom, colour cap 24.
-- Focal: one round mud-brick house with painted zigzag bands (West African painted-wall nod), a conical thatch
-- roof with two thatch cat ears, a warm glowing arched door, kente-coloured bunting, talking drums by the door
-- (a cat sits on one), stacked calabash bowls, a round woven cat sign (no text), a ginger cat napping on a mat,
-- and a canopy tree with weaver-bird nests to the right.
-- Run: AppRun -b --script banner-WCA-pets.lua   (writes art22/out/banner-WCA-pets.png + .aseprite)
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local c = GV.canvas{ w = 240, h = 60, mode = "scene", out = 2, ol = 1, olx = 1 }
local W, H = c.W, c.H
local floor, sin = math.floor, math.sin

-- shared palette (keep <= 24 colours)
local K = {
  u3 = "#2a1a10", u2 = "#4a2c1a", u1 = "#74462a",
  can = "#2f5a2a", leafS = "#2f6a3a", moss = "#4f9a45", leafL = "#7ab55c", haze = "#a4b86a", haze2 = "#c4c97e",
  wood = "#8a4f2a", mud = "#b07a45", thatch = "#d9a660", sand = "#f5cf6a", glow = "#fff3c8", cream = "#f2e4c0",
  path = "#c9a96e", pathL = "#d8c49a", red = "#dd3a2a", redS = "#ae2a2a", goldB = "#e8a317", ginger = "#f08a24",
  goldS = "#d0862a",
}
local function R(t) return { gloss = t[1], dot = t[2], rim = t[3], base = t[4], shade = t[5], deep = t[6], bounce = t[7] } end
local MUD    = R{ K.thatch, K.sand, K.thatch, K.mud, K.wood, K.u1, K.wood }
local THATCH = R{ K.sand, K.glow, K.sand, K.thatch, K.goldS, K.wood, K.goldS }
local WOOD   = R{ K.mud, K.thatch, K.mud, K.wood, K.u1, K.u2, K.u1 }
local GOLD   = R{ K.sand, K.glow, K.sand, K.goldB, K.goldS, K.wood, K.goldS }
local CALA   = R{ K.sand, K.glow, K.sand, K.thatch, K.goldS, K.wood, K.goldS }
local CAT    = R{ K.sand, K.glow, K.sand, K.ginger, K.goldS, K.wood, K.goldS }
local CREAMC = R{ K.glow, K.glow, K.glow, K.cream, K.pathL, K.path, K.pathL }
local LEAF   = R{ K.leafL, K.haze, K.leafL, K.moss, K.leafS, K.can, K.leafS }
local RED    = R{ K.ginger, K.sand, K.ginger, K.red, K.redS, K.u1, K.redS }
local GREEN  = R{ K.leafL, K.haze, K.leafL, K.moss, K.leafS, K.can, K.leafS }

----------------------------------------------------------------- sky: canopy air in hard bands + leafy ceiling
c:fill(c:rect(0, 0, W - 1, 14), K.haze)
c:fill(c:rect(0, 15, W - 1, 27), K.haze2)
c:fill(c:rect(0, 28, W - 1, 36), K.haze)
-- canopy ceiling: dark leaf mass with a wavy lower edge and hanging drips
for x = 0, W - 1 do
  local d = 4 + floor(1.3 * sin(x / 7) + 0.9 * sin(x / 3.1) + 0.5)
  c:fill(c:rect(x, 0, x, d), K.can)
  if d > 4 then c:px(x, d + 1, K.leafS) end
end
for x = 3, W - 1, 11 do
  if x > 96 and x < 146 then goto skip end
  local h = 3 + (x * 5) % 6
  c:fill(c:rect(x, 4, x, 4 + h), K.leafS)
  c:fill(c:rect(x - 1, 4 + h, x + 1, 5 + h), K.moss)
  ::skip::
end
-- glinting light motes in the canopy air (1 px)
for _, p in ipairs({ { 20, 12 }, { 47, 9 }, { 70, 16 }, { 172, 11 }, { 205, 15 }, { 228, 9 } }) do c:px(p[1], p[2], K.glow) end

----------------------------------------------------------------- far trees and huts (flat, no outline)
local farT = c:mask()
for _, t in ipairs({ { 12, 26, 13 }, { 40, 24, 11 }, { 64, 27, 9 }, { 214, 25, 12 }, { 236, 27, 9 } }) do
  farT:add(c:ellipse(t[1], t[2], t[3], t[3] * 0.7))
end
c:fill(farT, K.leafL)
for _, t in ipairs({ { 12, 33 }, { 40, 31 }, { 64, 33 }, { 214, 32 }, { 236, 33 } }) do c:fill(c:rect(t[1] - 1, t[2], t[1], 40), K.mud) end
-- little round huts far away
local function farHut(cx, w)
  local wall = c:rect(cx - w, 36, cx + w, 42)
  c:fill(wall, K.pathL)
  c:fill(c:rect(cx + w, 36, cx + w, 42), K.path)
  c:fill(c:poly({ { cx - w - 2, 37 }, { cx, 29 }, { cx + w + 3, 37 } }), K.thatch)
  c:fill(c:rect(cx - 1, 39, cx, 42), K.u1)
end
farHut(26, 5); farHut(52, 4); farHut(202, 5); farHut(226, 4)

----------------------------------------------------------------- ground
c:fill(c:rect(0, 42, W - 1, H - 1), K.moss)
c:fill(c:rect(0, 42, W - 1, 42), K.leafL)
for _, d in ipairs({ { 8, 50 }, { 28, 54 }, { 46, 49 }, { 62, 56 }, { 186, 55 }, { 206, 50 }, { 226, 54 } }) do
  c:paint({ "x.x", ".x." }, d[1], d[2], { x = K.leafS })
end
-- packed earth market yard in front of the shop
local yard = c:poly({ { 84, 46 }, { 158, 46 }, { 172, 58 }, { 70, 58 } })
c:fill(yard, K.path)
c:fill(c:rect(84, 46, 158, 46), K.pathL)
for _, d in ipairs({ { 80, 55 }, { 150, 52 }, { 162, 56 }, { 92, 51 } }) do c:fill(c:rect(d[1], d[2], d[1] + 1, d[2]), K.pathL) end

----------------------------------------------------------------- canopy tree with weaver-bird nests (right of shop)
c:part(c:line({ { 191, 50 }, { 191, 38 }, { 190, 28 }, { 189, 20 } }, 4), WOOD, { gloss = false, cres = 2, deep = 0 })
c:part(c:line({ { 191, 30 }, { 199, 24 } }, 2), WOOD, { flat = true })
local crown = c:ellipse(190, 15, 20, 9):add(c:ellipse(176, 19, 9, 6)):add(c:ellipse(205, 19, 9, 6))
c:part(crown, LEAF, { gloss = false, cres = 3, deep = 1 })
c:fill(c:ellipse(183, 12, 7, 2.5):clip(crown:shrink(1)), K.leafL)
c:px(180, 11, K.haze)
-- weaver nests: straw teardrops hanging on short threads
local function nest(x, y)
  c:fill(c:rect(x + 1, y - 3, x + 1, y - 1), K.u1)
  local m = c:ellipse(x + 1, y + 2, 2, 3)
  c:part(m, THATCH, { flat = true })
  c:px(x + 1, y + 4, K.u2)                     -- entrance hole
end
nest(176, 25); nest(203, 26); nest(197, 28)
-- a little yellow weaver bird at its nest
c:fill(c:rect(205, 30, 207, 31), K.sand); c:px(208, 30, K.goldS); c:px(205, 30, K.u2)

----------------------------------------------------------------- the shop: round mud house
local roofY = 29
local wall = c:rect(86, 24, 154, 48)
wall:cut(c:rect(86, 24, 87, 27)):cut(c:rect(153, 24, 154, 27))
-- thatch cat ears, drawn first so the roof overlaps their bases
local earL = c:poly({ { 101, 15 }, { 104, 3 }, { 113, 11 } })
local earR = c:poly({ { 127, 11 }, { 136, 3 }, { 139, 15 } })
c:part(earL, THATCH, { cres = 2, deep = 0, gloss = false })
c:part(earR, THATCH, { cres = 2, deep = 0, gloss = false })
c:fill(c:poly({ { 104, 12 }, { 105, 7 }, { 109, 11 } }), K.redS)
c:fill(c:poly({ { 131, 11 }, { 135, 7 }, { 136, 12 } }), K.redS)
c:part(wall, MUD, { cres = 5, deep = 2, gloss = false })
-- conical thatch roof with a fringed eave
local roof = c:poly({ { 78, roofY + 1 }, { 92, 18 }, { 106, 11 }, { 120, 8 }, { 134, 11 }, { 148, 18 }, { 163, roofY + 1 } })
for x = 79, 161, 3 do roof:rect(x, roofY + 1, x + 1, roofY + 2) end
c:part(roof, THATCH, { cres = 4, deep = 2, gloss = { 98, 18 } })
-- thatch rows: broken 1 px strokes, darker
for _, r in ipairs({ { 14, 112, 128 }, { 18, 100, 142 }, { 22, 92, 150 }, { 26, 84, 157 } }) do
  for x = r[2], r[3], 4 do
    if roof:has(x, r[1]) and roof:has(x + 1, r[1]) then
      c:px(x, r[1], K.goldS); c:px(x + 1, r[1], K.goldS)
    end
  end
end
-- roof tip knot
c:part(c:rrect(118, 5, 122, 9, 1), WOOD, { flat = true })

-- painted wall band: cream zigzag between two umber lines (painted-house pattern)
local band = c:rect(88, 31, 152, 34):clip(wall)
c:fill(band, K.cream)
c:fill(c:rect(88, 31, 152, 31):clip(wall), K.u2)
c:fill(c:rect(88, 35, 152, 35):clip(wall), K.u2)
for x = 88, 152, 4 do
  c:paint({ "u...", ".u.u", "..u." }, x, 32, { u = K.redS })
end
-- lower wall: little painted triangles at the foot
for x = 90, 150, 6 do
  if not (x > 108 and x < 130) then c:paint({ ".m.", "mmm" }, x, 45, { m = K.u1 }) end
end

-- door: tall arch, warm glowing inside
local door = c:rect(111, 34, 128, 48):add(c:ellipse(119.5, 33, 9, 8))
local frame = door:grow(2):cut(door):cut(c:rect(0, 49, W, H))
c:part(frame, WOOD, { cres = 2, deep = 0, gloss = false })
c:fill(door, K.sand)
c:fill(door:copy():cut(door:shrink(1)):cut(c:rect(0, 48, W, H)), K.goldB)
-- inside: a shelf of calabash treat bowls, a fish hanging, a cat bed on the floor
c:fill(c:rect(112, 37, 127, 37), K.wood)
c:part(c:ellipse(115.5, 35, 2.5, 1.5):cut(c:rect(0, 0, W, 34)), CALA, { flat = true, outline = false })
c:part(c:ellipse(121.5, 35, 2.5, 1.5):cut(c:rect(0, 0, W, 34)), RED, { flat = true, outline = false })
c:fill(c:rect(125, 35, 126, 36), K.goldS)
c:fill(c:rect(119, 26, 119, 28), K.wood)
c:paint({ ".ff.f", "fffff", ".ff.f" }, 117, 29, { f = K.u1 })   -- dried-fish treat silhouette
c:part(c:ellipse(119.5, 46, 6, 2), RED, { flat = true, outline = false })
c:fill(c:rect(114, 45, 125, 45), K.ginger)

-- round windows with warm glow, a cream kitten peeking in the right one
local function window(cx)
  local m = c:ellipse(cx, 40, 4, 3.5)
  c:fill(m:grow(1):cut(m), K.u2)
  c:fill(m, K.sand)
  c:fill(m:copy():cut(m:shrink(1)), K.goldB)
  return m
end
window(98); local wR = window(141)
c:fill(c:rect(94, 40, 102, 40), K.wood)
c:fill(c:ellipse(141, 42, 3, 2):add(c:poly({ { 138, 42 }, { 138, 38 }, { 141, 40 } })):add(c:poly({ { 141, 40 }, { 144, 38 }, { 144, 42 } })):clip(wR), K.cream)
c:px(140, 41, K.u3); c:px(142, 41, K.u3)

-- kente-coloured bunting under the eave: gold / green / red flags on a sagging string
do
  local pts = {}
  for x = 88, 152 do pts[#pts + 1] = { x, roofY + 4 + floor(2.2 * sin((x - 88) / 64 * math.pi) + 0.5) } end
  for _, p in ipairs(pts) do c:px(p[1], p[2], K.u2) end
  local cols = { K.goldB, K.moss, K.red }
  local n = 0
  for i = 3, #pts - 3, 5 do
    local x, y = pts[i][1], pts[i][2]
    if not (x > 108 and x < 131) then
      n = n + 1
      local col = cols[(n - 1) % 3 + 1]
      c:fill(c:poly({ { x - 1, y + 1 }, { x + 3, y + 1 }, { x + 1, y + 5 } }), col)
      c:px(x, y + 1, K.u2)
    end
  end
end

-- hanging sign: bracket on a post + round woven disc with a cat head (no text)
c:part(c:rect(164, 22, 166, 50), WOOD, { gloss = false, cres = 1, deep = 0 })
c:part(c:rect(155, 22, 166, 23), WOOD, { flat = true })
c:fill(c:rect(158, 24, 158, 25), K.u2)
local sign = c:ellipse(158, 31, 6, 6)
c:part(sign, GOLD, { cres = 3, deep = 1, gloss = false })
c:fill(sign:copy():shrink(1):cut(sign:shrink(2)), K.goldS)          -- woven ring
local cathead = c:ellipse(158, 32.5, 3.5, 2.5):add(c:poly({ { 154, 32 }, { 154, 28 }, { 157, 30 } })):add(c:poly({ { 159, 30 }, { 162, 28 }, { 162, 32 } }))
c:fill(cathead, K.u2)
c:px(156, 32, K.sand); c:px(160, 32, K.sand)

----------------------------------------------------------------- talking drums by the door, a cat on the left one
local function drum(x0, y0, h)
  -- hourglass body
  local m = c:poly({ { x0, y0 }, { x0 + 8, y0 }, { x0 + 6, y0 + h / 2 }, { x0 + 8, y0 + h }, { x0, y0 + h }, { x0 + 2, y0 + h / 2 } })
  c:part(m, WOOD, { cres = 2, deep = 0, gloss = false })
  c:part(c:rect(x0, y0 - 1, x0 + 7, y0), CREAMC, { flat = true })          -- skin head
  for x = x0 + 1, x0 + 6, 2 do c:fill(c:rect(x, y0 + 1, x, y0 + h - 1):clip(m), K.sand) end   -- tension cords
  return m
end
drum(100, 40, 8)
drum(130, 41, 7)
-- grey-cream cat sitting on the left drum, tail hanging
local sitB = c:ellipse(104, 36, 3.5, 2.5)
local sitH = c:ellipse(103.5, 31, 3.5, 3):add(c:poly({ { 100, 30 }, { 100, 26 }, { 103, 28 } })):add(c:poly({ { 104, 28 }, { 107, 26 }, { 107, 30 } }))
local sitT = c:line({ { 107, 38 }, { 109, 40 }, { 109, 44 } }, 2)
c:build{
  { "stail", sitT, CAT, { flat = true } },
  { "sbody", sitB, CAT, { cres = 2, deep = 1, gloss = false } },
  { "shead", sitH, CAT, { cres = 2, deep = 1, gloss = false } },
}
c:px(102, 31, K.u3); c:px(105, 31, K.u3)
c:px(103, 32, K.redS)
c:paint({ "s.s" }, 102, 29, { s = K.goldS })

-- stacked calabash bowls on a low bench (right of the door)
c:part(c:rect(140, 46, 152, 47), WOOD, { flat = true })
c:fill(c:rect(141, 48, 141, 49), K.u2); c:fill(c:rect(151, 48, 151, 49), K.u2)
c:part(c:ellipse(145, 44, 4, 2.5):cut(c:rect(0, 0, W, 42)), CALA, { cres = 1, deep = 0, gloss = false })
c:part(c:ellipse(149.5, 44, 2.5, 2):cut(c:rect(0, 0, W, 43)), CALA, { cres = 1, deep = 0, gloss = false })
c:fill(c:rect(142, 43, 147, 43), K.goldS)
c:paint({ "z.z.z" }, 143, 44, { z = K.u1 })                       -- carved zigzag

----------------------------------------------------------------- front: woven mat and a ginger cat napping
local mat = c:poly({ { 106, 50 }, { 134, 50 }, { 137, 56 }, { 103, 56 } })
c:part(mat, THATCH, { cres = 2, deep = 0, gloss = false, outline = false })
c:fill(mat:copy():cut(mat:shrink(1)), K.red)
for y = 52, 54, 2 do c:fill(c:rect(104, y, 136, y):clip(mat:shrink(1)), K.goldS) end
for x = 108, 133, 6 do c:fill(c:rect(x, 51, x + 1, 55):clip(mat:shrink(1)), K.moss) end
c:outline(mat)
-- napping ginger cat (loaf, closed eyes)
local catB = c:ellipse(124.5, 51, 6, 3)
local catH = c:ellipse(117, 50, 3.5, 3):add(c:poly({ { 114, 50 }, { 114, 45 }, { 117, 47 } })):add(c:poly({ { 118, 47 }, { 121, 45 }, { 121, 50 } }))
local tail = c:line({ { 130, 53 }, { 132, 51 }, { 131, 49 } }, 2)
c:build{
  { "tail", tail, CAT, { flat = true } },
  { "body", catB, CAT, { cres = 2, deep = 1 } },
  { "head", catH, CAT, { cres = 2, deep = 1, gloss = false } },
}
c:paint({ "u..u" }, 115, 50, { u = K.u3 })
c:px(117, 51, K.redS)
c:paint({ "s.s.s" }, 122, 48, { s = K.goldS })

----------------------------------------------------------------- hem stitch
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })

local t = c:save(OUT .. "banner-WCA-pets.aseprite", OUT .. "banner-WCA-pets.png")
print(GV.report(t))
