-- ph/kangkong-stir-fry (Gourmand P2 dish): an oval plate with a low bundle of long hollow water-spinach stems
-- lying the same way (cut ends show the hollow), a few arrow leaves, golden garlic chips and red chili rings
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "kangkong-stir-fry"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- oval plate with a blue rim band
local plate = c:ellipse(31.5, 38, 25, 15)
c:part(plate, GV.ramp("#e6e2d6", { dot = "#f6f2e6" }), { cres = 2, gloss = false })
c:fill(c:ellipse(31.5, 38, 22, 12):edge(), "#3f8fb0")
c:fill(c:ellipse(31.5, 38, 21, 11), "#d8d2c2")                               -- plate well
c:seam({ {14, 49}, {49, 49} }, { gap = "#2f6290" })
-- two arrow-shaped leaves tucked under the stems
local function leaf(pts, vein)
  c:part(c:poly(pts), "#3f8a32", { cres = 2, gloss = false, contact = false, contour = "#1f4a1f" })
  c:fill(c:line(vein, 1), "#7ab55c")
end
leaf({ {12, 33}, {20, 27}, {27, 29}, {19, 35} }, { {14, 33}, {24, 29} })
leaf({ {37, 46}, {46, 42}, {53, 43}, {45, 48} }, { {39, 46}, {51, 43} })
-- hollow stems: four long, thick tubes lying the same way, spaced so the plate shows between them;
-- each right end is a fresh cut showing the hollow
local function sy(b, x) return b - 0.3 * (x - 30) end
for _, st in ipairs({ { 29, 19, 44 }, { 34, 13, 48 }, { 39, 14, 50 }, { 44, 16, 46 }, { 48.5, 23, 41 } }) do
  local b, x0, x1 = st[1], st[2], st[3]
  local l = { { x0, sy(b, x0) }, { x1, sy(b, x1) } }
  c:part(c:line(l, 3), "#5cb83a", { cres = 1, deep = 0, gloss = false, contour = "#1f4a1f" })
  c:fill(c:line({ { x0 + 1, sy(b, x0) - 1 }, { x1 - 2, sy(b, x1) - 1 } }, 1), "#a8e070")   -- lit top of the tube
  local ex, ey = math.floor(x1 + 0.5), math.floor(sy(b, x1) + 0.5)
  c:paint({ "rrr", "rhr", "rrr" }, ex - 1, ey - 1, { r = "#c8f0a0", h = "#1f4a1f" })
end
-- golden fried garlic chips
for _, p in ipairs({ {25, 31}, {38, 33}, {29, 41}, {19, 38}, {35, 46} }) do
  c:paint({ "gg", "gs" }, p[1], p[2], { g = "#f5d88a", s = "#c98a3a" })
end
-- red chili rings with seeds
for _, p in ipairs({ {32, 27}, {21, 41}, {41, 37} }) do
  c:paint({ ".rr.", "rysr", "rssR", ".RR." }, p[1], p[2], { r = "#e0402b", R = "#8a1a22", y = "#f6d27a", s = "#f0b84a" })
end
c:ground(31.5, 55, 18, 1.2)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
