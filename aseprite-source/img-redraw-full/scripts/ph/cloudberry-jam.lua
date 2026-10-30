-- ph/cloudberry-jam (Pantry jam): low round pot sealed with a lumpy amber wax cap, one drip running down the right
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "cloudberry-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local wax = c:ellipse(32, 28, 18, 5):add(c:ellipse(22, 24, 8, 5)):add(c:ellipse(33, 22, 9, 5)):add(c:ellipse(43, 25, 7, 5))
wax:add(c:rect(14, 28, 50, 32))
for _, x in ipairs({ 18, 26, 37 }) do wax:add(c:ellipse(x, 33, 2, 1)) end   -- small lumps on the overhang
wax:add(c:rect(45, 30, 48, 38)):add(c:ellipse(46, 40, 2, 2))              -- the drip and its bead
c:build{
  { "glass", c:rrect(13, 30, 51, 54, 9), "glass" },
  { "jam",   c:rrect(15, 34, 49, 52, 7), "#f0a030", { contour = "#a8582f", gloss = false } },
  { "label", c:ellipse(30, 44, 6, 6), "cream", { gloss = false, contact = false } },
  { "wax",   wax, "gold", { gloss = { 24, 20 } } },
}
for _, s in ipairs({ {18, 38}, {22, 49}, {39, 48}, {41, 37}, {17, 45}, {37, 51} }) do
  c:px(s[1], s[2], "#ffc27a"); c:px(s[1] + 1, s[2] + 1, "#b8661a")    -- drupelet bits in the jam
end
c:fill(c:rect(46, 31, 46, 37), "#f5cf6a")              -- lit edge of the drip
-- label: cloudberry, lumpy golden drupe with green sepals
c:paint({
  "g.g.g.g",
  ".ggggg.",
  ".oOoso.",
  "oOosoos",
  "oosoosd",
  ".osods.",
  "..ddd..",
}, 27, 40, { g = "#4f9a45", o = "#e8a317", O = "#f5cf6a", s = "#d0862a", d = "#b8661a" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
