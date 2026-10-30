-- ph/papaya-chutney (Pantry chutney): tall teardrop jar narrowing upward, dark coconut-shell dome cap with eyes
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "papaya-chutney"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local drop = c:ellipse(32, 41, 15, 14):add(c:poly({ {19, 36}, {46, 36}, {39, 16}, {26, 16} })):closed(2)
c:build{
  { "glass", drop, "glass" },
  { "fill",  drop:shrink(2):cut(c:rect(0, 0, 63, 20)), "#f09a40", { contour = "#a8561a", gloss = { 25, 26 } } },
}
for _, p in ipairs({ {30,23}, {35,26}, {24,31}, {41,31}, {21,48}, {27,51}, {37,51}, {43,46} }) do c:px(p[1], p[2], "#f5cf6a") end
c:part(c:rrect(22, 34, 42, 46, 2), "cream", { gloss = false, contact = false })
-- emblem: papaya halved lengthwise, orange flesh with a cavity of dark seeds
c:paint({
  "...gggg...",
  "..goooog..",
  ".gooOooog.",
  ".goykkyog.",
  "gooykkkyog",
  "goykkkkyog",
  "goykkkkyog",
  ".gooyyyog.",
  "..ggggggg.",
}, 23, 36, { o = "#f08a24", O = "#ffd38a", y = "#f5b860", k = "#2a1a10", g = "#7ab55c" })
c:paint({ "uuu", "", "uu" }, 35, 39, { u = "#7a5a3a" })
-- coconut-shell dome
local dome = c:ellipse(32, 15, 10, 8):cut(c:rect(0, 17, 63, 63)):add(c:rrect(22, 14, 42, 18, 1))
c:part(dome, "#7a4a1f", { contour = "#3d2a1c", gloss = { 27, 10 } })
for _, p in ipairs({ {29, 11}, {33, 10}, {31, 13} }) do c:paint({ "uu", "uu" }, p[1], p[2], { u = "#2a1a10" }) end
for _, p in ipairs({ {25,15}, {38,13}, {36,16} }) do c:px(p[1], p[2], "#9a6b3f") end
c:seam({ {24, 18}, {40, 18} })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
