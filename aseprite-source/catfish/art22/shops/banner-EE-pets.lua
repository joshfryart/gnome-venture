-- banner-EE-pets.lua : Cat Fish pet shop banner for "Birch Hut Pets" (Birchbramble Steppe, EE), the shop in the
-- region's market town (claude/plan-catfish-petshops.md section 1, claude/catfish-shops-art-spec.md naming).
-- Size matches game/assets/img/scenes/banner-*.png: 240x60 grid, gvlib "scene" mode, out = 2 -> 480x120,
-- opaque, no border, gold hem stitch top + bottom, <= 24 colours (art-style-guide Part E banner row).
-- Focal subject: one carved log hut (izba-style) shop front, centre: red felt-shingle gable roof with a cat-ear
-- ridge finial, cream carved bargeboards, blue shutters, a lit window with a cat sitting on the sill, a warm
-- half-open door, a cat-head hanging sign (no text), sunflowers, a bench with yarn balls and a felt boot.
-- Region flavour from banner-EE: birch trees, golden steppe, moss hills, pale sky. Light from the upper left.
-- Run: AppRun -b --script banner-EE-pets.lua   Writes ../out/banner-EE-pets.png + .aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("(.*)/") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local W, H = 240, 60
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 1 }

-- shared palette (kept small: banners stay <= 24 colours)
local SKY1, SKY2, SKY3 = "#a9d6ea", "#bfe2f0", "#fff1c8"
local CREAM = "#f4f0e0"
local UMB = "#2a1a10"
local GOLD = GV.ramp("#e8a317", { rim = "#f5cf6a", gloss = "#fff1c8", dot = "#fff1c8", shade = "#d9a660", deep = "#8a4f2a", bounce = "#d9a660" })
local WOOD = GV.ramp("#b07a45", { rim = "#d9a660", gloss = "#ecc58a", shade = "#8a4f2a", deep = "#5e2f1e", bounce = "#8a4f2a" })
local RED = GV.ramp("#dd3a2a", { rim = "#f2793a", shade = "#ae2a2a", deep = "#6b1b2c", bounce = "#ae2a2a", gloss = "#f2793a" })
local BLUE = GV.ramp("#3f8fb0", { rim = "#8fcbd8", shade = "#2f6290", deep = "#2f6290", bounce = "#2f6290", gloss = "#8fcbd8" })
local MOSS = GV.ramp("#a4b86a", { rim = "#c8d77a", shade = "#7ab55c", deep = "#7ab55c", bounce = "#7ab55c", gloss = "#c8d77a" })
local PALE = GV.ramp(CREAM, { rim = CREAM, shade = "#d9a660", deep = "#d9a660", bounce = "#d9a660", gloss = CREAM })
local GLOW = GV.ramp("#f5cf6a", { rim = "#fff1c8", shade = "#e8a317", deep = "#e8a317", bounce = "#e8a317", gloss = "#fff1c8" })
local NF = { gloss = false, contact = false }

local function band(top)
  local m = c:mask()
  for x = 0, W - 1 do for y = math.floor(top(x) + 0.5), H - 1 do m:set(x, y) end end
  return m
end

-- sky: three hard bands, warm near the horizon -------------------------------------------------------------------------
c:bands(c:rect(0, 0, W - 1, H - 1), { SKY1, SKY2, SKY3 }, { dir = "v" })
c:fill(c:rect(0, 0, W - 1, 11), SKY1); c:fill(c:rect(0, 12, W - 1, 21), SKY2); c:fill(c:rect(0, 22, W - 1, H - 1), SKY3)
local function cloud(cx, cy, rx)
  local m = c:ellipse(cx, cy, rx, 2):add(c:ellipse(cx - rx * 0.35, cy - 1.5, rx * 0.5, 2)):cut(c:rect(0, cy + 2, W, H))
  c:fill(m, CREAM)
end
cloud(34, 8, 9); cloud(196, 6, 8); cloud(64, 16, 5); cloud(222, 15, 5)

-- far moss hills, golden steppe ------------------------------------------------------------------------------------------
c:fill(band(function(x) return 30 + 2 * math.sin(x / 11) + 1.2 * math.sin(x / 5 + 1) end), "#c8d77a")
c:fill(band(function(x) return 36 + 1 * math.sin(x / 8 + 2) end), "#f5cf6a")
for i = 0, 15 do local x = 3 + i * 15 + (i % 3) * 2; c:px(x, 39 + (i % 2), "#e8a317"); c:px(x + 1, 39 + (i % 2), "#e8a317") end

-- birch trees, calm thirds left and right --------------------------------------------------------------------------------
local function birch(x, h, by)
  local top = by - h
  local cr = c:ellipse(x + 0.5, top - 1, 4.5, 5):add(c:ellipse(x - 1.5, top + 3, 3, 2.5)):add(c:ellipse(x + 2.5, top + 2, 3, 2.5))
  c:part(cr, MOSS, { cres = 3, deep = 0, gloss = false, contact = false })
  c:part(c:rect(x, top + 2, x + 1, by), PALE, { flat = true, contact = false, contour = false })
  for j, ty in ipairs({ top + 6, top + math.floor(h * 0.45), top + math.floor(h * 0.7), by - 2 }) do c:px(x + (j % 2), ty, UMB) end
  c:px(x - 2, top - 4, "#c8d77a"); c:px(x - 1, top - 5, "#c8d77a")
end
for _, t in ipairs({ { 8, 22, 46 }, { 20, 16, 44 }, { 47, 24, 47 }, { 60, 14, 42 }, { 180, 15, 42 }, { 194, 23, 47 }, { 218, 18, 45 }, { 231, 24, 47 } }) do
  birch(t[1], t[2], t[3])
end
-- a little far hut on each side (town feel), muted
local function farhut(x, y)
  c:part(c:rect(x, y, x + 9, y + 6), WOOD, { flat = true, contact = false })
  c:part(c:poly({ { x - 2, y + 1 }, { x + 5, y - 5 }, { x + 12, y + 1 } }), RED, { flat = true, contact = false })
  c:fill(c:rect(x + 3, y + 2, x + 5, y + 4), GOLD.rim)
end
farhut(28, 37); farhut(204, 37)

-- path / ground ------------------------------------------------------------------------------------------------------------
c:fill(band(function(x) return 49 + 0.8 * math.sin(x / 9) end), "#c8d77a")
c:fill(c:poly({ { 96, H }, { 112, 50 }, { 136, 50 }, { 152, H } }), "#d9a660")
for _, p in ipairs({ { 14, 53 }, { 40, 55 }, { 70, 52 }, { 176, 54 }, { 208, 52 }, { 228, 55 } }) do
  c:px(p[1], p[2], "#7ab55c"); c:px(p[1] + 2, p[2], "#7ab55c"); c:px(p[1] + 1, p[2] + 1, "#7ab55c")
end

-- THE SHOP: log hut ---------------------------------------------------------------------------------------------------------
local X0, X1, WT, WB = 80, 160, 27, 50      -- wall box
-- log wall
local wall = c:rect(X0, WT, X1, WB)
c:part(wall, WOOD, { cres = 3, deep = 0, gloss = false })
for y = WT + 3, WB - 1, 4 do c:fill(c:rect(X0 + 1, y, X1 - 1, y), WOOD.shade) end           -- log seams
for y = WT + 1, WB - 2, 4 do for x = X0 + 6, X1 - 6, 17 do c:px(x, y, WOOD.rim) end end   -- knots/highlights
-- round log ends stacked at both corners
for y = WT + 1, WB - 1, 4 do
  c:part(c:ellipse(X0 - 1.5, y + 1.5, 2, 2), WOOD, { flat = true, contact = false, contour = false })
  c:px(X0 - 2, y + 1, WOOD.deep)
  c:part(c:ellipse(X1 + 1.5, y + 1.5, 2, 2), WOOD, { flat = true, contact = false, contour = false })
  c:px(X1 + 1, y + 1, WOOD.deep)
end
-- stone footing
c:part(c:rect(X0 - 3, WB + 1, X1 + 3, WB + 2), WOOD, { flat = true, contact = false })

-- gable (wood triangle) and roof slopes
local AX, AY = 120, 3
c:part(c:poly({ { X0 + 2, WT + 1 }, { AX, AY + 5 }, { X1 - 1, WT + 1 } }), WOOD, { cres = 3, deep = 0, gloss = false, contact = false })
for y = AY + 10, WT - 1, 4 do c:fill(c:rect(AX - (y - AY - 5) * 1.5 + 2, y, AX + (y - AY - 5) * 1.5 - 2, y):clip(c:poly({ { X0 + 2, WT + 1 }, { AX, AY + 5 }, { X1 - 1, WT + 1 } })), WOOD.shade) end
local roofL = c:poly({ { X0 - 10, WT + 2 }, { AX, AY - 1 }, { AX + 1, AY + 6 }, { X0 - 2, WT + 3 } })
local roofR = c:poly({ { AX, AY - 1 }, { X1 + 11, WT + 2 }, { X1 + 3, WT + 3 }, { AX, AY + 6 } })
c:part(roofL:add(roofR), RED, { cres = 3, deep = 0, gloss = { AX - 22, AY + 11 }, contact = false })
-- gold stitch down each slope (felt roof seams)
c:seam({ { X0 - 6, WT }, { AX - 1, AY + 2 } })
c:seam({ { AX + 2, AY + 2 }, { X1 + 7, WT } })
-- cream carved bargeboards under the slopes with scalloped drops
local bL = c:line({ { X0 - 1, WT + 2 }, { AX, AY + 7 } }, 2)
local bR = c:line({ { AX, AY + 7 }, { X1 + 1, WT + 2 } }, 2)
c:part(bL:add(bR), PALE, { flat = true, contact = false })
for i = 1, 6 do
  local t = i / 7
  local xl = math.floor(X0 - 1 + (AX - X0 + 1) * t); local yl = math.floor(WT + 2 + (AY + 7 - WT - 2) * t) + 2
  local xr = math.floor(X1 + 1 - (X1 + 1 - AX) * t); local yr = yl
  c:fill(c:rect(xl, yl, xl + 1, yl + 1), CREAM); c:px(xl, yl + 2, CREAM)
  c:fill(c:rect(xr - 1, yr, xr, yr + 1), CREAM); c:px(xr, yr + 2, CREAM)
end
-- cat-ear ridge finial (instead of the carved horse head): two felt ears and a little face
c:part(c:poly({ { AX - 5, AY + 4 }, { AX - 5, AY - 3 }, { AX - 1, AY + 1 }, { AX + 2, AY + 1 }, { AX + 6, AY - 3 }, { AX + 6, AY + 4 } }), WOOD, { flat = true, contact = false })
c:px(AX - 4, AY - 1, RED.rim); c:px(AX - 4, AY, RED.rim); c:px(AX + 5, AY - 1, RED.rim); c:px(AX + 5, AY, RED.rim)
c:px(AX - 2, AY + 2, UMB); c:px(AX + 3, AY + 2, UMB)

-- round attic window with a cat face peeking out
c:part(c:ellipse(AX + 0.5, 16.5, 5, 5), PALE, { flat = true, contact = false })
c:fill(c:ellipse(AX + 0.5, 16.5, 3.5, 3.5), GLOW.base)
local catface = c:ellipse(AX + 0.5, 18, 3, 2.5)
catface:add(c:poly({ { AX - 3, 18 }, { AX - 2, 13 }, { AX + 1, 16 } })):add(c:poly({ { AX, 16 }, { AX + 3, 13 }, { AX + 4, 18 } }))
c:fill(catface:clip(c:ellipse(AX + 0.5, 16.5, 3.5, 3.5)), "#3e2f66")
c:px(AX - 1, 17, GOLD.rim); c:px(AX + 2, 17, GOLD.rim)

-- shop window (left): carved cream frame with a crown, blue shutters, warm glow, cat on the sill
local WX0, WX1, WY0, WY1 = 90, 112, 35, 45
c:part(c:poly({ { WX0 - 3, WY0 }, { (WX0 + WX1) / 2, WY0 - 7 }, { (WX0 + WX1) / 2 + 1, WY0 - 7 }, { WX1 + 4, WY0 } }), PALE, { flat = true, contact = false })
c:px((WX0 + WX1) / 2, WY0 - 3, RED.base); c:px((WX0 + WX1) / 2 - 1, WY0 - 2, RED.base); c:px((WX0 + WX1) / 2 + 1, WY0 - 2, RED.base)
c:part(c:rect(WX0 - 1, WY0 - 1, WX1 + 1, WY1 + 2), PALE, { flat = true, contact = false })
c:part(c:rect(WX0 + 1, WY0 + 1, WX1 - 1, WY1), GLOW, { cres = 3, deep = 0, gloss = false, contact = false, outline = false, contour = WOOD.deep })
c:fill(c:rect((WX0 + WX1) / 2, WY0 + 1, (WX0 + WX1) / 2, WY1), WOOD.shade)             -- mullion
c:fill(c:rect(WX0 + 1, WY0 + 5, WX1 - 1, WY0 + 5), WOOD.shade)                          -- transom
-- shutters
for _, sx in ipairs({ WX0 - 7, WX1 + 3 }) do
  c:part(c:rect(sx, WY0, sx + 4, WY1 + 1), BLUE, { flat = true, contact = false })
  c:px(sx + 2, WY0 + 3, CREAM); c:px(sx + 2, WY1 - 2, CREAM)
  c:fill(c:rect(sx + 1, WY0 + 6, sx + 3, WY0 + 6), BLUE.shade)
end
-- cat sitting on the sill (silhouette against the glow), tail curling
local cx0 = 96
local cat = c:ellipse(cx0 + 0.5, WY1 - 2, 3, 3):add(c:ellipse(cx0 + 0.5, WY1 - 6, 2.5, 2.2))
cat:add(c:poly({ { cx0 - 2, WY1 - 7 }, { cx0 - 2, WY1 - 10 }, { cx0, WY1 - 8 } })):add(c:poly({ { cx0 + 1, WY1 - 8 }, { cx0 + 3, WY1 - 10 }, { cx0 + 3, WY1 - 7 } }))
cat:add(c:line({ { cx0 + 3, WY1 }, { cx0 + 6, WY1 }, { cx0 + 7, WY1 - 2 } }, 1))
c:fill(cat:clip(c:rect(WX0 + 1, WY0 + 1, WX1 - 1, WY1)), "#3e2f66")
c:px(cx0 - 1, WY1 - 6, GOLD.rim); c:px(cx0 + 2, WY1 - 6, GOLD.rim)
-- a hanging fish toy in the right pane
c:fill(c:rect(107, WY0 + 1, 107, WY0 + 6), WOOD.deep)
c:fill(c:ellipse(107, WY0 + 8, 2, 1), RED.base); c:px(110, WY0 + 7, RED.base); c:px(110, WY0 + 9, RED.base); c:px(106, WY0 + 8, UMB)
-- flower box under the window
c:part(c:rect(WX0 - 2, WY1 + 3, WX1 + 2, WY1 + 5), RED, { flat = true, contact = false })
for x = WX0, WX1, 4 do c:px(x, WY1 + 2, (x % 8 == 0) and GOLD.rim or CREAM); c:px(x + 1, WY1 + 2, "#7ab55c") end

-- door (right): carved frame, half open, warm interior
local DX0, DX1, DY0 = 125, 139, 31
c:part(c:rrect(DX0 - 2, DY0 - 2, DX1 + 2, WB, 3), PALE, { flat = true, contact = false })
c:part(c:rrect(DX0, DY0, DX1, WB, 2), GLOW, { cres = 3, deep = 0, gloss = false, contact = false, outline = false, contour = WOOD.deep })
local leaf = c:poly({ { DX0, DY0 + 1 }, { DX0 + 6, DY0 + 3 }, { DX0 + 6, WB + 1 }, { DX0, WB + 1 } })
c:part(leaf, BLUE, { flat = true, contact = false, outline = false, contour = WOOD.deep })
c:px(DX0 + 4, DY0 + 11, GOLD.rim)
for y = DY0 + 4, WB - 2, 5 do c:fill(c:rect(DX0 + 1, y, DX0 + 5, y), BLUE.shade) end
-- warm light spilling onto the path
c:fill(c:poly({ { DX0 + 6, WB + 4 }, { DX1, WB + 4 }, { DX1 + 6, H - 3 }, { DX0 + 6, H - 3 } }), GOLD.rim)
-- porch step
c:part(c:rect(DX0 - 3, WB + 1, DX1 + 3, WB + 3), WOOD, { flat = true, contact = false })

-- hanging sign: wooden bracket + cat-head board (no text) with a fish painted on it
c:part(c:rect(143, 30, 156, 31), WOOD, { flat = true, contact = false })
c:fill(c:rect(146, 32, 146, 33), UMB); c:fill(c:rect(154, 32, 154, 33), UMB)
local sign = c:ellipse(150, 39, 6, 4.5):add(c:poly({ { 144, 37 }, { 145, 32 }, { 149, 35 } })):add(c:poly({ { 151, 35 }, { 155, 32 }, { 157, 37 } }))
c:part(sign, GOLD, { cres = 3, deep = 0, gloss = { 146, 36 }, contact = false })
c:px(147, 37, UMB); c:px(153, 37, UMB); c:px(150, 38, RED.shade)
c:fill(c:ellipse(149.5, 41, 2.5, 1), RED.base); c:px(152, 40, RED.base); c:px(152, 42, RED.base); c:px(148, 41, CREAM)

-- sunflowers left of the window and by the door
local function sunflower(x, y, stem)
  c:fill(c:rect(x, y + 2, x, y + stem), "#7ab55c"); c:px(x + 1, y + 6, "#7ab55c"); c:px(x - 1, y + 9, "#7ab55c")
  c:part(c:ellipse(x, y, 3, 3), GLOW, { flat = true, contact = false })
  c:fill(c:ellipse(x, y, 1, 1), WOOD.deep)
end
sunflower(72, 36, 17); sunflower(66, 41, 12); sunflower(167, 38, 15); sunflower(173, 43, 10)

-- felt boot (valenok) in front of the left corner with a ginger kitten curled inside, a yarn ball beside it
local BX = 79
local boot = c:rrect(BX, 47, BX + 5, 55, 1):add(c:rrect(BX, 51, BX + 9, 55, 2))
c:part(boot, PALE, { flat = true, contact = false })
c:fill(c:rect(BX + 1, 49, BX + 4, 49), RED.base); c:fill(c:rect(BX + 1, 50, BX + 4, 50), BLUE.base)
local kit = c:ellipse(BX + 2.5, 45.5, 3, 2.5):add(c:poly({ { BX - 1, 45 }, { BX, 41 }, { BX + 2, 43 } })):add(c:poly({ { BX + 3, 43 }, { BX + 5, 41 }, { BX + 6, 45 } }))
c:part(kit, GOLD, { flat = true, contact = false })
c:px(BX + 1, 46, UMB); c:px(BX + 4, 46, UMB); c:px(BX + 2, 47, RED.shade)
c:part(c:ellipse(BX + 13.5, 53.5, 2, 2), RED, { flat = true, contact = false }); c:px(BX + 13, 52, CREAM)
c:fill(c:rect(BX + 16, 55, BX + 19, 55), RED.base)

-- hem stitch top and bottom
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })

local t = c:save(OUT .. "banner-EE-pets.aseprite", OUT .. "banner-EE-pets.png")
print("banner-EE-pets " .. GV.report(t))
