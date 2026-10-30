-- ph/sukuma-wiki (Gourmand P2 dish): flat black skillet, long handle to the right, heaped dark collard ribbons with tomato cubes and onion curls
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "sukuma-wiki"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local iron = GV.ramp("#2f3338", { rim = "#5b6470", gloss = "#8b939e", dot = "#b4bcc6", shade = "#22252a", deep = "#1a1c20", bounce = "#2a2d33" })
-- long handle with a hang hole
local handle = c:line({ {45, 41}, {54, 38} }, 4):cut(c:rect(52, 39, 52, 39))
c:part(handle, iron, { flat = true, contact = false })
-- pan
local pan = c:ellipse(28, 41, 22, 10)
c:part(pan, iron, { cres = 3, gloss = false })
c:fill(c:ellipse(28, 39, 19, 7), "#4a5058")
c:fill(c:ellipse(28, 39, 19, 7):edge():clip(c:rect(0, 39, 63, 63)), "#3a3f46")
-- collard heap: lumpy tangle
local heap = c:ellipse(28, 36, 16, 5):add(c:ellipse(22, 31, 8, 5)):add(c:ellipse(33, 29, 9, 6)):add(c:ellipse(28, 26, 5, 3))
c:part(heap, "#2f6a2a", { contour = "#1a1c20", cres = 3, gloss = false, contact = false })
local rib = {
  { {14, 36}, {19, 33}, {24, 35}, {29, 32} },
  { {26, 28}, {31, 25}, {35, 27} },
  { {32, 34}, {37, 31}, {42, 34} },
  { {18, 30}, {22, 28}, {25, 30} },
  { {22, 39}, {27, 37}, {33, 39}, {38, 37} },
}
for _, l in ipairs(rib) do c:fill(c:line(l, 2), "#4f8a3a"); c:fill(c:line(l, 1), "#6aa648") end
-- tomato cubes
for _, p in ipairs({ {19, 33}, {33, 28}, {38, 35}, {26, 37} }) do
  c:paint({ "lrr", "rrr", "rrd" }, p[1], p[2], { l = "#f2806a", r = "#d6322b", d = "#8a1a22" })
end
-- onion curls
for _, p in ipairs({ {24, 30}, {29, 34}, {15, 38} }) do
  c:paint({ ".oo.", "o..o" }, p[1], p[2], { o = "#f1ece0" })
end
c:ground(29, 54, 18, 1.2)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
