-- ph/kangkong-stir-fry (Gourmand P2 dish): black round-bottom wok with a loop handle on the left, tall bright-green water-spinach tangle, garlic and chili rings
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "kangkong-stir-fry"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local iron = GV.ramp("#2f3338", { rim = "#5b6470", gloss = "#8b939e", dot = "#b4bcc6", shade = "#22252a", deep = "#1a1c20", bounce = "#2a2d33" })
-- loop handle on the left
local loop = c:ellipse(11, 34, 5, 3):cut(c:ellipse(11, 34, 3, 1)):cut(c:rect(13, 0, 63, 63))
c:part(loop, iron, { flat = true, contact = false })
-- deep round-bottom wok
local wok = c:ellipse(34, 31, 22, 17):clip(c:rect(0, 33, 63, 63)):add(c:ellipse(34, 33, 22, 5))
wok:add(c:rrect(29, 46, 39, 49, 1))
c:part(wok, iron, { cres = 4, gloss = { 18, 38 } })
c:fill(c:ellipse(34, 33, 22, 5):edge():clip(c:rect(0, 26, 63, 33)), "#6a7480")
c:fill(c:ellipse(34, 33, 19, 3.5), "#1a1c20")
-- tall glossy heap of greens in the wok
local heap = c:ellipse(34, 31, 18, 4):add(c:ellipse(33, 24, 14, 8)):add(c:ellipse(24, 23, 6, 5)):add(c:ellipse(43, 22, 6, 5))
heap:add(c:ellipse(33, 16, 5, 3))
c:part(heap, "#3f9a32", { contour = "#1a1c20", cres = 3, gloss = false, contact = false })
-- pointed leaves lying at angles
local function lf(x, y, dx, dy)
  local m = c:poly({ {x, y}, {x + dx * 0.45 - dy * 0.3, y + dy * 0.45 + dx * 0.3}, {x + dx, y + dy}, {x + dx * 0.45 + dy * 0.3, y + dy * 0.45 - dx * 0.3} })
  c:fill(m, "#2a6e28"); c:fill(c:line({ {x, y}, {math.floor(x + dx * 0.8), math.floor(y + dy * 0.8)} }, 1), "#5fbf3a")
end
lf(20, 25, -1, -8); lf(29, 18, 6, -4); lf(44, 25, 7, -6); lf(37, 19, -2, -6); lf(26, 30, -8, 1)
-- crisscross hollow stems, bright green
local stems = {
  { {19, 30}, {27, 22}, {34, 18} },
  { {24, 31}, {33, 26}, {44, 19} },
  { {30, 17}, {37, 23}, {48, 28} },
  { {22, 22}, {30, 28}, {38, 31} },
  { {17, 31}, {13, 37} },          -- flopping over the rim
  { {49, 30}, {54, 35} },
}
for _, l in ipairs(stems) do
  c:part(c:line(l, 2), "#6ccc44", { flat = true, contact = false, contour = "#1f4a1f" })
end
-- hollow cut stem ends on the heap
for _, p in ipairs({ {30, 21}, {44, 27}, {21, 28} }) do
  c:paint({ "gg", "gd" }, p[1], p[2], { g = "#a8e070", d = "#2f5a2a" })
end
-- garlic slivers
for _, p in ipairs({ {33, 24}, {26, 31}, {45, 31}, {38, 32} }) do c:paint({ "ggs" }, p[1], p[2], { g = "#f1ece0", s = "#d8c49a" }) end
-- chili rings, scattered
for _, p in ipairs({ {40, 23}, {25, 27}, {33, 30} }) do
  c:paint({ "rrr", "ryR", "RRR" }, p[1], p[2], { r = "#d6322b", R = "#8a1a22", y = "#f6d27a" })
end
c:ground(34, 53, 16, 1.2)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
