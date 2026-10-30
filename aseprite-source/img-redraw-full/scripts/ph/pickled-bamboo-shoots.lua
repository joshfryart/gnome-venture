-- ph/pickled-bamboo-shoots (Pantry pickle): a real bamboo section as canister, two bulging node rings, cut window of ivory
-- shoot slices. Redraw B: the gabled leaf cap (read as a lantern / birdhouse roof) becomes a low leaf wrap tied over the
-- mouth with one long bamboo leaf sweeping off to the upper right and a short flap hanging down the left side.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-bamboo-shoots"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bam = GV.ramp("#a8b45a", { shade = "#7a8a3a", deep = "#4f5a24", bounce = "#8a8a3a" })
local leaf = GV.ramp("#7ab55c", { shade = "#4f9a45", deep = "#2f6a3a" })
-- a narrower, taller culm so it reads as a cylinder, not a box
local tube = c:rrect(21, 22, 43, 56, 3)
c:part(tube, bam, { cres = 5, deep = 2, contour = "#4a2c1a", gloss = { 24, 33 } })
-- node rings: bulge 2 px past the tube, dark groove with a lit lip
for _, y in ipairs({ 31, 48 }) do
  c:part(c:rrect(19, y - 1, 45, y + 2, 1), bam, { cres = 1, deep = 0, gloss = false, contact = false, contour = "#4a2c1a" })
  c:fill(c:rect(20, y + 1, 44, y + 1), "#4f5a24")
  c:fill(c:rect(20, y - 1, 38, y - 1), "#c8d77a")
end
for _, x in ipairs({ 25, 39 }) do c:fill(c:rect(x, 51, x, 54), "#7a8a3a"); c:fill(c:rect(x, 34, x, 36), "#7a8a3a") end   -- fibres
c:fill(c:rect(23, 24, 23, 29), "#c8d77a"); c:fill(c:rect(23, 50, 23, 54), "#c8d77a")   -- long lit stripe of the culm
-- oval cut window showing stacked shoot slices
c:part(c:ellipse(32, 39.5, 6, 5.5), "#e8d890", { gloss = false, contact = false, contour = "#5e2f1e" })
for i, y in ipairs({ 36, 39, 42 }) do
  local w = (i == 2) and 4 or 3
  c:fill(c:rect(32 - w, y, 32 + w, y + 1), "#f4f0e0")
  c:fill(c:rect(32 - w + 1, y + 1, 32 + w, y + 1), "#c9b878")
  c:px(32 - w, y, "#fbf6e8")
end
-- shoot-cone emblem below the lower node
c:paint({
  "...b...",
  "..byb..",
  ".byrrb.",
  ".byyyb.",
  "byrrryb",
  ".bbbbb.",
}, 29, 50, { b = "#9a6b3f", y = "#e8d890", r = "#c9b878" })
-- leaf wrap: low rounded cap overhanging the mouth (no peak)
local cap = c:ellipse(32, 22, 13.5, 5):cut(c:rect(0, 25, 63, 63))
c:part(cap, leaf, { cres = 2, deep = 1, contour = "#2f5a2a", gloss = { 23, 19 } })
c:fill(c:line({ {22, 21}, {27, 19}, {33, 18} }, 1), "#4f9a45")
-- short leaf flap hanging down the left side of the culm
c:part(c:poly({ {19, 24}, {24, 24}, {23, 30}, {20, 33}, {19, 30} }), leaf, { flat = true, contact = false, contour = "#2f5a2a" })
-- long bamboo leaf sweeping from the knot to the upper right: narrow, pointed, with a mid vein
local blade = c:poly({ {32, 19}, {36, 14}, {42, 10}, {48, 8}, {53, 7}, {49, 11}, {44, 15}, {38, 19}, {35, 21} })
c:part(blade, leaf, { cres = 2, deep = 1, contact = false, contour = "#2f5a2a", gloss = false })
c:fill(c:line({ {34, 19}, {39, 15}, {45, 11}, {51, 8} }, 1), "#2f6a3a")
c:px(37, 14, "#c8e09a"); c:px(41, 11, "#c8e09a")
-- twine round the rim with a knot under the leaf
c:part(c:rect(19, 24, 45, 25), "#9a6b3f", { flat = true, contour = false })
for x = 20, 44, 3 do c:px(x, 25, "#5e2f1e") end
c:paint({ ".tt.", "t..t", ".tt." }, 30, 23, { t = "#7a4a1f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
