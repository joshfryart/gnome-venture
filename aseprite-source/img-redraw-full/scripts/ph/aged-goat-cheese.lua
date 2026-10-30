-- ph/aged-goat-cheese (Pantry dairy): truncated-pyramid goat cheese, ash vein and bloomy mould, on a woven straw mat
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "aged-goat-cheese"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local rind = GV.ramp("#e8d890", { shade = "#c9b878", deep = "#9a8a50", bounce = "#d8c080", rim = "#f6eab0", gloss = "#fff3c8", dot = "#fbf6e8", pale = false })
local top = GV.ramp("#f4f0e0", { shade = "#e0d4b0", deep = "#c9b878", dot = "#fbf6e8" })
-- straw mat
local mat = c:poly({ {10, 47}, {54, 47}, {57, 56}, {7, 56} })
c:part(mat, "#c9a96e", { gloss = false })
for y = 49, 55, 3 do for x = 9, 55, 4 do c:fill(c:rect(x + (y % 2), y, x + 1 + (y % 2), y), "#9a6b3f") end end
-- cheese: sloped sides, flat top face, wider foot
c:part(c:poly({ {17, 46}, {24, 21}, {41, 21}, {48, 46} }):add(c:rrect(16, 43, 48, 50, 2)), rind, { gloss = { 23, 28 } })
c:part(c:ellipse(32.5, 21, 8.5, 3), top, { gloss = false, contact = false, cres = 2, deep = 0 })
-- ash vein: grey zigzag line down the front
c:fill(c:line({ {32, 24}, {30, 29}, {33, 34}, {30, 39}, {33, 44}, {31, 49} }, 2), "#5b6470")
c:px(31, 26, "#8b8f96"); c:px(32, 36, "#8b8f96")
-- bloomy mould specks
for _, p in ipairs({ {21, 38}, {26, 31}, {43, 37}, {39, 28}, {44, 45}, {20, 46} }) do
  c:paint({ "ab", "b." }, p[1], p[2], { a = "#c3b2ea", b = "#a9d6ea" })
end
-- emblem: goat head silhouette pressed into the rind
c:paint({
  "k......k",
  ".k....k.",
  "kkkkkkkk",
  ".kkkkkk.",
  "..kkkk..",
  "..kkkk..",
  "...kk...",
  "...k....",
}, 35, 31, { k = "#9a6b3f" })
-- crumbs on the mat
c:px(13, 52, "#f4f0e0"); c:px(51, 51, "#f4f0e0"); c:px(52, 52, "#e8d890")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
