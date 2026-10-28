-- haven-lemon-grove-monastery : southern-European terraced lemon grove at dawn. Quiet brown-robed monks, herbs, a book.
local REPO = "/home/user/gnome-venture/"
local H = dofile(REPO .. "aseprite-source/final/scripts/wonders/h3lib.lua")
local L, GV = H.L, H.GV
local c = L.new()
local W, HT = L.W, L.H
local HOR = 66

L.sky(c, "dawn", HOR)
-- rising sun on the sea
c:fill(c:ellipse(196, HOR, 12, 12):clip(c:rect(0, 0, W, HOR)), "#fff1c8")
c:fill(c:ellipse(196, HOR, 8, 8):clip(c:rect(0, 0, W, HOR)), "#fbe0a8")
L.cloud(c, 40, 24, 18, "#f0aa98", "#f8c890"); L.cloud(c, 120, 14, 14, "#a48ac0", "#d49ab8"); L.cloud(c, 230, 34, 10, "#f0aa98", "#f8c890")
L.stars(c, 6, 16, 3)
-- sea
c:bands(c:rect(0, HOR + 1, W - 1, 88), { "#8fcbd8", "#6aa8c8", "#4a8ab4", "#3a7aa8" }, { dir = "v" })
for i, x in ipairs({ 150, 170, 190, 205, 180, 218 }) do c:fill(c:rect(x, HOR + 2 + (i % 3) * 3, x + 6, HOR + 2 + (i % 3) * 3), "#fbe0a8") end
-- far headland
c:part(c:poly({ {120,HOR+1},{140,HOR-6},{170,HOR-4},{190,HOR+1} }), GV.ramp("#a894dc"), { gloss = false, rim = false, bounce = false, outline = false })
-- hill behind monastery
c:part(L.below(c, function(x) return 54 + (x < 140 and 0 or (x - 140) * 0.5) + math.sin(x / 16) * 2 end), GV.ramp("#a4b86a"), { cres = 6, deep = 10, gloss = false, outline = false, rim = false })
-- cypress
for _, p in ipairs({ {30,52},{20,58},{134,50} }) do c:part(c:ellipse(p[1], p[2], 3, 11), GV.ramp("#2f5a2a"), { cres = 2, deep = 3, gloss = false, outline = false }) end

-- the monastery
c:part(c:rect(36, 56, 132, 94), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 6, deep = 9, gloss = false, pale = true })
c:part(c:poly({ {32, 58}, {42, 46}, {126, 46}, {136, 58} }), GV.ramp("#d6532b"), { cres = 4, deep = 7, gloss = false })
for i = 0, 8 do c:fill(c:rect(40 + i * 10, 49, 40 + i * 10, 57), "#a8301f") end
-- bell tower
c:part(c:rect(94, 22, 112, 48), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 4, deep = 6, gloss = false, pale = true })
c:part(c:rrect(98, 28, 108, 40, 4), GV.ramp("#291d4a"), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })
c:part(c:ellipse(103, 35, 3, 3.5), GV.ramp("#e8a317"), { flat = true, gloss = false, outline = false })
c:part(c:poly({ {91, 24}, {103, 8}, {115, 24} }), GV.ramp("#d6532b"), { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(103, 7, 2, 2), GV.ramp("#e8a317"), { flat = true, gloss = false })
-- arcade of arches
for i = 0, 5 do
  local x = 42 + i * 14
  c:part(c:rrect(x, 70, x + 8, 94, 4), GV.ramp("#291d4a"), { flat = true, gloss = false, outline = false, contour = "#8b6a4a" })
end
for i = 0, 5 do c:part(c:rect(40 + i * 14 + 9, 72, 40 + i * 14 + 10, 94), GV.ramp("#d8c496"), { flat = true, gloss = false, outline = false }) end
c:part(c:rect(36, 94, 132, 96), GV.ramp("#c9c5bc"), { cres = 1, deep = 2, gloss = false })
-- a lit lamp in one arch, a tiny window above
c:fill(c:rect(61, 78, 62, 81), "#f5cf6a"); c:px(61, 78, "#fff1c8")
for _, x in ipairs({ 52, 80, 120 }) do c:part(c:rrect(x, 58, x + 5, 66, 2), GV.ramp("#4e3a8a"), { flat = true, gloss = false, outline = false, contour = "#2a1a10" }) end

-- terraces: stone walls with lemon trees
local function terrace(y, soil, wall)
  c:part(L.below(c, function(x) return y end), GV.ramp(soil), { cres = 6, deep = 10, gloss = false, outline = false, rim = false })
  c:part(c:rect(0, y, W, y + 7), GV.ramp(wall), { cres = 3, deep = 5, gloss = false, outline = false, rim = false })
  for x = 3, W, 9 do c:fill(c:rect(x, y + 3, x + 4, y + 3), "#8b8f96"); c:fill(c:rect(x + 4, y + 6, x + 8, y + 6), "#8b8f96") end
end
terrace(96, "#7ab55c", "#c9c5bc")
local function lemon(x, y, s)
  c:part(c:rect(x - 1, y, x + 1, y + 8), GV.ramp("#8a4f2a"), { cres = 1, deep = 2, gloss = false, outline = false })
  c:part(c:ellipse(x, y - 4, 10 * s, 9 * s), GV.ramp("#4a8a3e"), { cres = 4, deep = 6, gloss = false })
  for _, o in ipairs({ {-6,-6},{1,-10},{6,-4},{-3,0},{4,2},{-8,-1} }) do
    local lx, ly = x + o[1] * s, y + o[2] * s
    c:fill(c:rect(lx, ly, lx + 2, ly + 2), "#f5cf6a"); c:px(lx, ly, "#fff1c8"); c:px(lx + 2, ly + 2, "#e8a317")
  end
end
lemon(150, 90, 1); lemon(178, 92, 1.1); lemon(208, 90, 1); lemon(230, 92, 0.9); lemon(18, 92, 0.9)
terrace(110, "#6a9a3a", "#d8c496")
-- front terrace: herb beds
local function bed(x0, x1, y0, y1, col, n)
  c:part(c:rect(x0, y0, x1, y1), GV.ramp("#5e2f1e"), { cres = 2, deep = 3, gloss = false })
  c:part(c:rect(x0, y0 + 4, x1, y1), GV.ramp("#3d2a1c"), { flat = true, gloss = false, outline = false, rim = false })
  for x = x0 + 3, x1 - 3, 5 do
    c:fill(c:rect(x, y0 - 3, x + 2, y0 + 3), col[(x % #col) + 1]); c:px(x, y0 - 3, "#c8d77a")
  end
end
bed(8, 58, 112, 120, { "#7ab55c", "#a4b86a", "#c3b2ea" })
-- herbs drying on a line
c:fill(c:rect(64, 100, 108, 100), "#2a1a10"); c:fill(c:rect(64, 100, 64, 112), "#2a1a10"); c:fill(c:rect(108, 100, 108, 112), "#2a1a10")
for i, x in ipairs({ 70, 78, 86, 94, 102 }) do c:fill(c:poly({ {x, 101}, {x + 4, 101}, {x + 2, 108} }), ({ "#7ab55c", "#a4b86a", "#c3b2ea", "#7ab55c", "#e46a9b" })[i]) end

-- monks (brown robes, rope belt)
local function monk(x, gy, o)
  o = o or {}
  o.cloth = o.cloth or "#8a5a3a"; o.hat = o.hat or "#6a4a2a"; o.big = true
  H.folk(c, x, gy, o)
  c:seam({ {x - 5, gy - 5}, {x + 5, gy - 5} }, { free = true, on = 2, off = 1 })
end
-- monk picking lemons with a basket
monk(210, 114)
c:part(c:rrect(218, 106, 232, 114, 2), GV.ramp("#d9a660"), { cres = 2, deep = 3, gloss = false })
for _, x in ipairs({ 220, 225, 230 }) do c:fill(c:rect(x, 103, x + 2, 105), "#f5cf6a") end
-- ladder against the tree
c:part(c:line({ {193, 100}, {201, 80} }, 2), GV.ramp("#b07a45"), { flat = true, gloss = false, outline = false })
-- monk reading on a bench, left; open book
c:part(c:rect(70, 120, 104, 123), GV.ramp("#b07a45"), { cres = 2, deep = 3, gloss = false })
c:part(c:rect(72, 123, 74, 128), GV.ramp("#8a4f2a"), { flat = true, gloss = false }); c:part(c:rect(100, 123, 102, 128), GV.ramp("#8a4f2a"), { flat = true, gloss = false })
monk(86, 121, { cloth = "#6a4fa8", hat = "#4e3a8a" })
c:part(c:rect(80, 110, 92, 116), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = true })
c:fill(c:rect(86, 110, 86, 116), "#b07a45")
c:seam({ {82, 112}, {85, 112} }, { free = true, on = 1, off = 1, gap = "#8a4f2a" }); c:seam({ {88, 113}, {91, 113} }, { free = true, on = 1, off = 1, gap = "#8a4f2a" })
-- herb trader with a table of jars, right front
c:part(c:rect(132, 118, 168, 121), GV.ramp("#d9a660"), { cres = 2, deep = 3, gloss = false })
c:part(c:rect(134, 121, 136, 129), GV.ramp("#8a4f2a"), { flat = true, gloss = false }); c:part(c:rect(164, 121, 166, 129), GV.ramp("#8a4f2a"), { flat = true, gloss = false })
for i, x in ipairs({ 138, 148, 158 }) do
  c:part(c:rrect(x, 108, x + 6, 117, 2), GV.ramp("#8fcbd8"), { cres = 2, deep = 3, gloss = false })
  c:fill(c:rect(x + 1, 111, x + 5, 116), ({ "#7ab55c", "#e46a9b", "#f5cf6a" })[i])
  c:part(c:rect(x + 1, 106, x + 5, 108), GV.ramp("#b07a45"), { flat = true, gloss = false, outline = false })
end
monk(184, 126, { cloth = "#8a5a3a", hat = "#6a4a2a", beard = "#d8c496" })
-- small hanging lantern at the door
L.finish(c, "haven-lemon-grove-monastery")
