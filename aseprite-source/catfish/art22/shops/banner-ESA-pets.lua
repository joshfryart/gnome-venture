-- banner-ESA-pets.lua : Cat Fish pet shop banner for "Thornacre Trading Den" (Thornacre Savanna, ESA), the shop in
-- the region's market town (claude/plan-catfish-petshops.md section 1, claude/catfish-shops-art-spec.md naming).
-- Size matches game/assets/img/scenes/banner-*.png: 240x60 grid, gvlib "scene" mode, out = 2 -> 480x120,
-- opaque, no border, gold hem stitch top + bottom, <= 24 colours (art-style-guide Part E banner row).
-- Focal subject: one round clay-walled trading hut, centre, under a tall conical thatch roof with a woven cat-head
-- finial; a striped cloth awning over an open stall counter (yarn balls, a fish toy, a basket and a sleeping ginger
-- cat), a carved wooden door with gold studs and warm light, a round woven-basket sign with a cat face (no text),
-- clay pots, and a tabby lounging on a woven mat. Region flavour: golden savanna grass, flat-topped acacias, a big
-- baobab, a far snow-capped mountain, warm late-afternoon sky. Light from the upper left.
-- Run: AppRun -b --script banner-ESA-pets.lua   Writes ../out/banner-ESA-pets.png + .aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("(.*)/") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local W, H = 240, 60
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 1 }

-- palette (banner cap 24) --------------------------------------------------------------------------------------------
local SKY1, SKY2, SKY3 = "#f5b860", "#f9d49c", "#fff1c8"
local CREAM = "#fff1c8"
local UMB = "#2a1a10"
local GRASS1, GRASS2, TUFT = "#f5cf6a", "#e8a317", "#d0862a"
local FAR = "#ecc58a"
local STRAW = GV.ramp("#e8a317", { rim = "#f5cf6a", gloss = "#fff1c8", dot = "#fff1c8", shade = "#b8661a", deep = "#8a4f2a", bounce = "#b8661a" })
local CLAY = GV.ramp("#c98a4a", { rim = "#ecc58a", gloss = "#ecc58a", shade = "#a8582f", deep = "#8a4f2a", bounce = "#a8582f" })
local WOOD = GV.ramp("#8a4f2a", { rim = "#b07a45", gloss = "#c98a4a", shade = "#5e2f1e", deep = "#5e2f1e", bounce = "#5e2f1e" })
local BARK = GV.ramp("#b07a45", { rim = "#ecc58a", gloss = "#ecc58a", shade = "#8a4f2a", deep = "#5e2f1e", bounce = "#8a4f2a" })
local RED = GV.ramp("#dd3a2a", { rim = "#f2793a", shade = "#ae2a2a", deep = "#6b1b2c", bounce = "#ae2a2a", gloss = "#f2793a" })
local BLUE = GV.ramp("#3f8fb0", { rim = "#8fcbd8", shade = "#2f6290", deep = "#2f6290", bounce = "#2f6290", gloss = "#8fcbd8" })
local LEAF = GV.ramp("#7ab55c", { rim = "#a4b86a", shade = "#4a8a3e", deep = "#4a8a3e", bounce = "#4a8a3e", gloss = "#a4b86a" })
local GLOW = GV.ramp("#f5cf6a", { rim = "#fff1c8", shade = "#e8a317", deep = "#e8a317", bounce = "#e8a317", gloss = "#fff1c8" })
local GINGER = GV.ramp("#f2793a", { rim = "#f5b860", shade = "#ae2a2a", deep = "#ae2a2a", bounce = "#ae2a2a", gloss = "#f5b860" })
local NF = { flat = true, contact = false }

local function band(top)
  local m = c:mask()
  for x = 0, W - 1 do for y = math.floor(top(x) + 0.5), H - 1 do m:set(x, y) end end
  return m
end

-- sky: three hard bands + a low warm sun upper left ---------------------------------------------------------------------
c:fill(c:rect(0, 0, W - 1, 13), SKY1); c:fill(c:rect(0, 14, W - 1, 25), SKY2); c:fill(c:rect(0, 26, W - 1, H - 1), SKY3)
c:fill(c:ellipse(30, 11, 7, 7), SKY2)
c:fill(c:ellipse(30, 11, 5, 5), CREAM)
local function cloud(cx, cy, rx)
  c:fill(c:ellipse(cx, cy, rx, 1.5):add(c:ellipse(cx - rx * 0.3, cy - 1, rx * 0.45, 1.5)), SKY2)
end
cloud(70, 7, 8); cloud(176, 9, 9); cloud(214, 5, 5)

-- far mountain with a snow cap (right), far plain ----------------------------------------------------------------------
local mtn = c:poly({ { 186, 38 }, { 206, 18 }, { 214, 17 }, { 236, 38 } })
c:fill(mtn, FAR)
c:fill(c:poly({ { 201, 23 }, { 206, 18 }, { 214, 17 }, { 219, 22 }, { 215, 21 }, { 212, 23 }, { 209, 21 }, { 205, 23 } }), CREAM)
c:fill(band(function(x) return 35 + 0.8 * math.sin(x / 13) end), FAR)

-- distant flat-topped acacias and a giraffe, small, muted ---------------------------------------------------------------
local function farAcacia(x, y, r)
  c:fill(c:rect(x, y, x, y + 5), TUFT)
  c:fill(c:ellipse(x, y, r, 1.5), "#a4b86a")
end
farAcacia(12, 31, 6); farAcacia(64, 32, 4); farAcacia(176, 32, 5); farAcacia(226, 33, 4)
-- giraffe silhouette (long neck, ossicones), far left
c:paint({
  "..oo...",
  "..oooo.",
  "..o....",
  "..o....",
  "..o....",
  ".oo....",
  "oooooo.",
  "oooooo.",
  "o.o.o.o",
  "o.o.o.o",
}, 26, 27, { o = TUFT })

-- mid savanna and near grass ------------------------------------------------------------------------------------------
c:fill(band(function(x) return 39 + 0.8 * math.sin(x / 9 + 1) end), GRASS1)
c:fill(band(function(x) return 50 + 0.8 * math.sin(x / 7) end), GRASS2)
for i = 0, 22 do
  local x = 4 + i * 11 + (i % 3) * 2
  local y = 42 + (i % 3) * 2
  if x < 76 or x > 166 then c:px(x, y, TUFT); c:px(x + 1, y - 1, TUFT); c:px(x + 2, y, TUFT) end
end
-- path from the door
c:fill(c:poly({ { 122, 51 }, { 146, 51 }, { 162, H }, { 110, H } }), "#ecc58a")

-- acacia tree, left third ---------------------------------------------------------------------------------------------
c:part(c:line({ { 46, 48 }, { 48, 36 }, { 44, 26 } }, 2):add(c:line({ { 48, 36 }, { 56, 27 } }, 2)), WOOD, NF)
local canopy = c:ellipse(49, 22, 17, 3.5):add(c:ellipse(40, 21, 7, 3)):add(c:ellipse(59, 21, 7, 3))
c:part(canopy, LEAF, { cres = 2, deep = 0, gloss = false, contact = false })
for x = 36, 62, 5 do c:px(x, 19, "#a4b86a") end

-- baobab, right of the shop: fat trunk, stubby root-like branches with tufts ------------------------------------------
local bx = 190
local trunk = c:rrect(bx - 8, 22, bx + 8, 50, 4):add(c:ellipse(bx, 49, 10, 2))
local br = c:line({ { bx - 5, 23 }, { bx - 9, 16 }, { bx - 13, 14 } }, 2)
br:add(c:line({ { bx - 1, 22 }, { bx - 1, 13 } }, 2)):add(c:line({ { bx + 4, 23 }, { bx + 8, 15 }, { bx + 12, 13 } }, 2))
br:add(c:line({ { bx - 9, 17 }, { bx - 7, 12 } }, 2)):add(c:line({ { bx + 8, 16 }, { bx + 5, 11 } }, 2))
c:part(trunk:copy():add(br), BARK, { cres = 4, deep = 0, gloss = false, contact = false })
for _, y in ipairs({ 28, 34, 40, 45 }) do c:px(bx - 3 + (y % 3), y, BARK.shade); c:px(bx - 2 + (y % 3), y + 1, BARK.shade) end
for _, t in ipairs({ { bx - 14, 12 }, { bx - 7, 10 }, { bx - 1, 11 }, { bx + 5, 9 }, { bx + 13, 11 } }) do
  c:part(c:ellipse(t[1], t[2], 3, 2), LEAF, { flat = true, contact = false })
end

-- THE SHOP: round clay trading hut ------------------------------------------------------------------------------------
local X0, X1, WT, WB = 88, 152, 30, 50
-- wall
c:part(c:rrect(X0, WT, X1, WB, 2), CLAY, { cres = 4, deep = 0, gloss = false })
-- painted zigzag skirting band (cream + red triangles)
for x = X0 + 1, X1 - 1 do
  local k = (x - X0) % 6
  local hgt = (k < 3) and k or (5 - k)
  c:fill(c:rect(x, WB - 2 - hgt, x, WB - 1), (k < 3) and RED.base or CREAM)
end
c:fill(c:rect(X0 + 1, WB - 6, X1 - 1, WB - 6), CLAY.shade)

-- conical thatch roof
local AX, AY = 120, 6
local roof = c:poly({ { 76, 34 }, { AX - 3, AY }, { AX + 4, AY }, { 165, 34 } })
c:part(roof, STRAW, { cres = 4, deep = 0, gloss = { 102, 16 }, contact = false })
-- thatch rows (stitch-like dashed lines following the cone)
for i, y in ipairs({ 13, 19, 25, 31 }) do
  local half = (y - AY) * 1.57 + 3
  local m = c:mask()
  for x = math.floor(AX - half + 2), math.floor(AX + half - 2) do if (x + i) % 3 ~= 0 then m:set(x, y) end end
  c:fill(m:clip(roof), STRAW.shade)
end
-- ragged straw fringe
for x = 77, 164, 2 do c:fill(c:rect(x, 34, x, 34 + ((x % 4 == 1) and 1 or 0)), STRAW.shade) end
-- woven cat-head finial on the peak
local fin = c:ellipse(AX + 0.5, AY - 0.5, 5, 3.5)
fin:add(c:poly({ { AX - 5, AY - 1 }, { AX - 4, AY - 6 }, { AX - 1, AY - 3 } })):add(c:poly({ { AX + 2, AY - 3 }, { AX + 5, AY - 6 }, { AX + 6, AY - 1 } }))
c:part(fin, WOOD, { flat = true, contact = false })
c:px(AX - 2, AY - 1, GLOW.base); c:px(AX + 3, AY - 1, GLOW.base); c:px(AX, AY + 1, RED.rim); c:px(AX + 1, AY + 1, RED.rim)

-- open stall (left): warm interior, shelves of goods, counter
local SX0, SX1, SY0, SY1 = 93, 117, 38, 46
c:part(c:rect(SX0, SY0, SX1, SY1), GLOW, { cres = 3, deep = 0, gloss = false, contact = false, outline = false, contour = WOOD.deep })
c:fill(c:rect(SX0 + 1, SY0 + 4, SX1 - 1, SY0 + 4), WOOD.base)                    -- shelf
-- goods on the shelf: yarn balls, a blue fish
for i, col in ipairs({ RED, BLUE, RED }) do
  local gx = SX0 + 3 + (i - 1) * 4
  c:fill(c:ellipse(gx, SY0 + 2.5, 1.5, 1.5), col.base); c:px(gx - 1, SY0 + 2, col.rim)
end
c:fill(c:ellipse(SX1 - 5, SY0 + 2.5, 2.5, 1), BLUE.base); c:px(SX1 - 2, SY0 + 1, BLUE.base); c:px(SX1 - 2, SY0 + 3, BLUE.base); c:px(SX1 - 6, SY0 + 2, UMB)
-- counter plank
c:part(c:rect(SX0 - 2, SY1 + 1, SX1 + 2, SY1 + 3), WOOD, { flat = true, contact = false })
-- sleeping ginger cat on the counter (curled loaf, ears, tail)
local CX = 100
local cat = c:ellipse(CX, SY1 - 1, 5, 2.5):add(c:ellipse(CX + 4, SY1 - 2, 2.5, 2.5))
cat:add(c:poly({ { CX + 2, SY1 - 3 }, { CX + 3, SY1 - 6 }, { CX + 4, SY1 - 4 } })):add(c:poly({ { CX + 5, SY1 - 4 }, { CX + 6, SY1 - 6 }, { CX + 7, SY1 - 3 } }))
c:part(cat, GINGER, { cres = 2, deep = 0, gloss = false, contact = false })
c:px(CX + 3, SY1 - 2, UMB); c:px(CX + 5, SY1 - 2, UMB)                     -- closed eyes
c:px(CX - 2, SY1 - 3, GINGER.shade); c:px(CX, SY1 - 3, GINGER.shade)        -- stripes
-- woven basket on the counter
local bk = c:rrect(108, SY1 - 3, 115, SY1, 1)
c:part(bk, STRAW, { flat = true, contact = false })
c:px(110, SY1 - 2, STRAW.shade); c:px(113, SY1 - 2, STRAW.shade); c:px(111, SY1 - 1, STRAW.shade); c:px(114, SY1 - 1, STRAW.shade)
c:fill(c:ellipse(112, SY1 - 4, 1.5, 1.5), BLUE.base)

-- striped cloth awning over the stall with a scalloped edge
local aw = c:poly({ { SX0 - 4, SY0 - 1 }, { SX0 - 1, SY0 - 5 }, { SX1 + 1, SY0 - 5 }, { SX1 + 4, SY0 - 1 } })
for x = SX0 - 4, SX1 + 4, 4 do aw:add(c:ellipse(x + 1.5, SY0 - 1, 1.5, 1.2)) end
c:part(aw, RED, { cres = 2, deep = 0, gloss = false, contact = false })
local awOnly = aw:copy()
awOnly:each(function(x, y) if (x - SX0) % 8 < 3 and c:get(x, y) == RED.base then c:px(x, y, GLOW.base) end end)
c:fill(c:rect(SX0 - 3, SY0 - 6, SX1 + 3, SY0 - 6), BLUE.base)              -- blue hem along the top
c:seam({ { SX0 - 2, SY0 - 4 }, { SX1 + 2, SY0 - 4 } })
-- poles
c:fill(c:rect(SX0 - 4, SY0, SX0 - 4, WB + 1), WOOD.deep); c:fill(c:rect(SX1 + 4, SY0, SX1 + 4, WB + 1), WOOD.deep)

-- carved wooden door (right) with gold studs, half open on warm light
local DX0, DX1, DY0 = 127, 141, 35
c:part(c:rrect(DX0 - 2, DY0 - 2, DX1 + 2, WB, 4), WOOD, { flat = true, contact = false })
c:part(c:rrect(DX0, DY0, DX1, WB, 3), GLOW, { cres = 3, deep = 0, gloss = false, contact = false, outline = false, contour = WOOD.deep })
local leaf = c:poly({ { DX0, DY0 + 2 }, { DX0 + 7, DY0 + 4 }, { DX0 + 7, WB + 1 }, { DX0, WB + 1 } })
c:part(leaf, WOOD, { flat = true, contact = false, outline = false, contour = WOOD.deep })
for y = DY0 + 6, WB - 2, 4 do c:px(DX0 + 2, y, STRAW.rim); c:px(DX0 + 5, y + 1, STRAW.rim) end
c:fill(c:rect(DX0 - 2, DY0 - 3, DX1 + 2, DY0 - 3), WOOD.deep)                 -- carved lintel line
-- warm light spilling onto the path
c:fill(c:poly({ { DX0 + 7, WB + 2 }, { DX1, WB + 2 }, { DX1 + 5, H - 4 }, { DX0 + 9, H - 4 } }), GLOW.base)

-- round woven-basket sign on a bracket (concentric rings, cat face, no text)
c:part(c:rect(150, 33, 163, 34), WOOD, { flat = true, contact = false })
c:fill(c:rect(158, 35, 158, 36), UMB)
local plate = c:ellipse(158, 42, 6, 6)
c:part(plate, STRAW, { cres = 3, deep = 0, gloss = { 155, 38 }, contact = false })
c:fill(c:ellipse(158, 42, 4, 4):cut(c:ellipse(158, 42, 3, 3)), RED.base)
local face = c:ellipse(158, 43, 2.5, 2):add(c:poly({ { 155, 43 }, { 156, 39 }, { 158, 41 } })):add(c:poly({ { 158, 41 }, { 160, 39 }, { 161, 43 } }))
c:fill(face:clip(c:ellipse(158, 42, 3, 3)), UMB)
c:px(157, 42, GLOW.base); c:px(159, 42, GLOW.base)

-- clay pots stacked by the left wall, a grass tuft
c:part(c:ellipse(82, 48, 4, 3.5):add(c:rect(80, 44, 84, 45)), CLAY, { cres = 2, deep = 0, gloss = { 80, 46 }, contact = false })
c:fill(c:rect(79, 48, 85, 48), RED.base)
c:part(c:ellipse(75, 50, 3, 2.5):add(c:rect(74, 47, 76, 47)), CLAY, { flat = true, contact = false })

-- woven mat in front of the door with a tabby lounging on it
local mat = c:rrect(144, 51, 160, 54, 1)
c:part(mat, RED, { flat = true, contact = false })
for x = 145, 159, 3 do c:px(x, 52, GLOW.base); c:px(x + 1, 53, BLUE.base) end
local tab = c:ellipse(152, 50, 5, 2):add(c:ellipse(146.5, 49, 2.5, 2.2))
tab:add(c:poly({ { 144, 48 }, { 144, 45 }, { 146, 47 } })):add(c:poly({ { 147, 47 }, { 149, 45 }, { 149, 48 } }))
tab:add(c:line({ { 157, 50 }, { 160, 49 }, { 161, 47 } }, 1))
c:part(tab, BARK, { cres = 2, deep = 0, gloss = false, contact = false })
c:px(145, 49, UMB); c:px(148, 49, UMB)
c:px(151, 49, BARK.deep); c:px(154, 49, BARK.deep)

-- hem stitch top and bottom
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })

local t = c:save(OUT .. "banner-ESA-pets.aseprite", OUT .. "banner-ESA-pets.png")
print("banner-ESA-pets " .. GV.report(t))
