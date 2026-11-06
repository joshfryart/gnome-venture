-- ph/radish-kimchi, redraw B (2.2.1 leftovers, Opus + impeccable critique lens).
-- Critique: a brown crock with red trim is the same read as doenjang and tamarind (three brown pots in one shelf).
-- Fix (specificity + colour): kkakdugi itself, a heap of red-coated radish cubes (white cut faces showing) in a pale
-- celadon bowl, one green scallion bit. Red-on-pale is unique on the shelf.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "radish-kimchi", "B"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bowl = GV.ramp("#a8d0bc", { gloss = "#eaf8ee", dot = "#fbfdfe", rim = "#c8e6d4" })
local redc = GV.ramp("#d8322a", { gloss = "#ff9158", dot = "#ffc27a" })
local white = "#f8f0e2"
-- cubes, back row first; each: red body, white top face, darker right side
local function cube(x, y, s)
  local m = c:rect(x, y, x + s, y + s)
  c:part(m, redc, { flat = true, contact = false, contour = "#6b1b2c" })
  c:fill(c:rect(x + 1, y + 1, x + s - 2, y + 2), white)
  c:fill(c:rect(x + s - 1, y + 1, x + s, y + s), "#ae2a2a")
  c:px(x + 2, y + 4, "#ffc27a")
end
for _, q in ipairs({ {17, 22}, {27, 19}, {37, 22}, {22, 27}, {32, 26}, {41, 29}, {13, 30} }) do cube(q[1], q[2], 8) end
-- scallion
c:part(c:line({ {28, 16}, {33, 13} }, 3), "moss", { flat = true, contact = false })
-- bowl
local b = c:ellipse(32, 36, 24, 18):cut(c:rect(0, 0, 63, 35))
c:part(b, bowl, { gloss = { 14, 40 } })
c:fill(c:rect(9, 36, 55, 37):clip(b), "#7ab59a")
c:part(c:rrect(23, 52, 41, 56, 1), bowl, { flat = true })
c:ground(32, 57, 16, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
