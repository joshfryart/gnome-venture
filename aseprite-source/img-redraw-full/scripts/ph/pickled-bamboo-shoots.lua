-- ph/pickled-bamboo-shoots (Pantry pickle): a real bamboo section as canister, two node rings, cut window of ivory shoot slices, leaf cap folded to a point, twine
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-bamboo-shoots"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bam = GV.ramp("#a8b45a", { shade = "#7a8a3a", deep = "#4f5a24", bounce = "#8a8a3a" })
local tube = c:rrect(18, 21, 46, 56, 3)
c:part(tube, bam, { cres = 5, deep = 2, contour = "#4a2c1a", gloss = { 21, 31 } })
-- node rings: bulge 1 px past the tube, dark groove with a lit lip
for _, y in ipairs({ 29, 48 }) do
  c:part(c:rrect(16, y - 1, 48, y + 2, 1), bam, { cres = 1, deep = 0, gloss = false, contact = false, contour = "#4a2c1a" })
  c:fill(c:rect(17, y + 1, 47, y + 1), "#5e5a24")
  c:fill(c:rect(17, y - 1, 40, y - 1), "#c8d77a")
end
for _, x in ipairs({ 24, 37 }) do c:fill(c:rect(x, 50, x, 54), "#7a8a3a"); c:fill(c:rect(x, 31, x, 33), "#7a8a3a") end   -- fibres
-- oval cut window showing stacked shoot slices
c:part(c:ellipse(32, 38.5, 7, 6), "#e8d890", { gloss = false, contact = false, contour = "#5e2f1e" })
for i, y in ipairs({ 35, 38, 41 }) do
  local w = (i == 2) and 5 or 4
  c:fill(c:rect(32 - w, y, 32 + w, y + 1), "#f4f0e0")
  c:fill(c:rect(32 - w + 1, y + 1, 32 + w, y + 1), "#c9b878")
  c:px(32 - w, y, "#fbf6e8")
end
-- shoot-cone emblem below the lower node
c:paint({
  "....b....",
  "...byb...",
  "..byrrb..",
  "..byyyb..",
  ".byrrryb.",
  "..bbbbb..",
}, 28, 50, { b = "#9a6b3f", y = "#e8d890", r = "#c9b878" })
-- leaf cap folded to a point, with a mid vein, and twine round the rim
local cap = c:poly({ {17, 25}, {48, 25}, {44, 19}, {38, 14}, {36, 10}, {37, 6}, {33, 7}, {30, 10}, {27, 14}, {21, 19} })
c:part(cap, GV.ramp("#7ab55c", { shade = "#4f9a45" }), { contour = "#2f5a2a", gloss = { 25, 18 } })
c:fill(c:line({ {35, 8}, {33, 11}, {32, 16}, {33, 21} }, 1), "#2f5a2a")     -- fold / mid vein
c:fill(c:line({ {22, 22}, {27, 18} }, 1), "#4a8a3e"); c:fill(c:line({ {43, 22}, {39, 18} }, 1), "#4a8a3e")
c:part(c:rect(17, 22, 47, 23), "#9a6b3f", { flat = true, contour = false })
for x = 18, 46, 3 do c:px(x, 23, "#5e2f1e") end
c:paint({ "t.t", ".t.", "t.t" }, 45, 24, { t = "#9a6b3f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
