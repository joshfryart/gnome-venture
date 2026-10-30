-- ph/cherry-cordial (Pantry cordial): pear-shaped cut-glass decanter, glass ball stopper, faceted shoulders, deep red cherry cordial, cherry-pair shield label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "cherry-cordial"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 45, 16, 11):add(c:poly({ {25, 27}, {40, 27}, {48, 44}, {16, 44} }))
local neck = c:poly({ {28, 18}, {37, 18}, {40, 29}, {25, 29} })
c:build{
  { "glass",  body:add(neck), "#d8ecf0", { pale = false } },
  { "liquid", c:ellipse(32, 46, 13, 8.5):add(c:poly({ {27, 30}, {38, 30}, {45, 45}, {19, 45} })), GV.ramp("#8a1f2a", { gloss = "#c8344a", rim = "#a8243a" }), { contour = "#5e1420", gloss = { 25, 38 } } },
}
-- faceted shoulder lines
c:fill(c:line({ {21, 36}, {25, 30} }, 1):add(c:line({ {43, 36}, {39, 30} }, 1)), "#c8dde4")
c:part(c:rrect(25, 37, 39, 47, 1):add(c:poly({ {25, 47}, {40, 47}, {32.5, 53} })), "cream", { gloss = false, contact = false })
c:part(c:rect(27, 15, 37, 18), "#c8dde4", { flat = true })
c:seam({ {27, 18}, {37, 18} }, { free = true })
c:part(c:ellipse(32, 11, 4), GV.ramp("#c8dde4", { dot = "#f4f0e0" }), { gloss = false })
c:px(30, 9, "#f4f0e0"); c:px(29, 10, "#eef8f2")
-- two cherries, stem V
c:fill(c:line({ {29, 44}, {32, 39}, {35, 44} }, 1), "#4f9a45")
c:paint({ "gg", ".g" }, 32, 38, { g = "#4f9a45" })
for _, x in ipairs({ 28, 34 }) do c:paint({ ".rr.", "rRrr", "rrrs", ".ss." }, x - 1, 44, { r = "#8a1f2a", R = "#c8344a", s = "#5e1420" }) end
c:ground(32, 57, 13, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
