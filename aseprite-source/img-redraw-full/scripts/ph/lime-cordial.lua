-- ph/lime-cordial (Pantry cordial): slim flat hip-flask, tiny ribbed screw cap on a tether, green lime cordial, lime-wheel oval label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "lime-cordial"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:rrect(20, 16, 42, 56, 8):add(c:rrect(22, 14, 40, 22, 4))
c:build{
  { "glass",  glass, "#d8ecf0", { pale = false } },
  { "liquid", c:rrect(22, 22, 40, 54, 6), GV.ramp("#7ab55c", { shade = "#4f9a45", deep = "#2f6a3a" }), { contour = "#4f9a45", gloss = { 24, 25 } } },
  { "label",  c:ellipse(31, 41, 7, 8.5), "cream", { gloss = false, contact = false } },
}
c:part(c:rrect(26, 7, 36, 14, 2), "stone", { gloss = false })
for _, x in ipairs({ 28, 31, 34 }) do c:fill(c:rect(x, 8, x, 13), "#5b6470") end
c:seam({ {27, 15}, {35, 15} }, { free = true })
-- tether loop from cap to flask shoulder
c:part(c:line({ {37, 10}, {40, 11}, {42, 15}, {41, 19} }, 1), "#8b8f96", { flat = true, contact = false })
-- lime wheel
c:fill(c:ellipse(31, 41, 5), "#4f9a45")
c:fill(c:ellipse(31, 41, 4), "#a4b86a")
for _, d in ipairs({ {0, -3}, {0, -2}, {0, 2}, {0, 3}, {-3, -1}, {-2, -1}, {3, 1}, {2, 1}, {-2, 2}, {-3, 2}, {2, -2}, {3, -2} }) do c:px(31 + d[1], 41 + d[2], "#f4f0e0") end
c:px(31, 41, "#c8d77a")
c:ground(31, 57, 11, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
