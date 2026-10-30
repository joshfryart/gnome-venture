-- ph/ginger-beer (Pantry cordial): fat champagne-style fizz bottle, gold foil neck, wired cork cage, golden ginger beer with bubbles, ginger-root emblem on a dark green oval label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "ginger-beer"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:rrect(16, 31, 48, 56, 8):add(c:rect(27, 14, 37, 26))
glass:add(c:poly({ {27, 21}, {38, 21}, {44, 27}, {48, 34}, {16, 34}, {20, 27} }))
c:build{
  { "glass",  glass, GV.ramp("#c8dde4"), { pale = false } },
  { "liquid", c:rrect(18, 31, 46, 54, 7):add(c:poly({ {24, 28}, {41, 28}, {46, 35}, {18, 35} })), GV.ramp("#e8c070", { shade = "#c89040" }), { contour = "#a87a30", gloss = { 21, 33 } } },
  { "label",  c:ellipse(32, 44, 11, 8), GV.ramp("#2f6a3a", { rim = "#4f9a45", shade = "#1f4a32", deep = "#1f3f3a", bounce = "#2f5a2a" }), { gloss = false, contact = false, cres = 2, deep = 0 } },
}
-- gold foil over the neck, cork mushroom on top, wire muselet
c:part(c:rrect(26, 12, 38, 22, 1), "gold", { gloss = false, cres = 3 })
for _, x in ipairs({ 28, 31, 34 }) do c:fill(c:rect(x, 19, x, 21), "#b8661a") end
c:part(c:rrect(26, 6, 38, 12, 3), "#c9a96e", { gloss = false })
c:px(29, 8, "#9a6b3f"); c:px(34, 9, "#9a6b3f"); c:px(31, 10, "#9a6b3f")
c:fill(c:line({ {28, 7}, {28, 16} }, 1):add(c:line({ {36, 7}, {36, 16} }, 1)):add(c:rect(26, 15, 38, 15)), "#8b8f96")
c:fill(c:rect(27, 16, 37, 16), "#5b6470")
c:part(c:ascii({ ".x.", "x.x", ".x." }, 38, 14), "#8b8f96", { flat = true, contact = false })   -- twist
-- rising bubbles
for _, b in ipairs({ {23, 37}, {27, 33}, {37, 33}, {41, 40}, {22, 49}, {42, 50}, {24, 44} }) do c:px(b[1], b[2], "#fbf6e8") end
-- dark green oval label with a cream rim, so the bright ginger root pops (was tan on cream)
c:fill(c:ellipse(32, 44, 11, 8):edge(), "#e8d8b0")
-- ginger root: chunky gold hand with three knobby fingers, umber outline, ring lines, green shoot
c:paint({
  "....kk.....kk....",
  "...kGgk...kGgk...",
  ".kkkggk.kkkggk...",
  "kGgkggkkGgkggkkk.",
  "kggggrggggggrgGgk",
  "kgrggggggrgggggsk",
  ".kssggggggggsssk.",
  "..kkksssssssskk..",
  ".....kkkkkkkk....",
}, 24, 39, { k = "#4e2a16", g = "#e8c080", G = "#f8e6b8", r = "#a8742f", s = "#c08a3a" })
c:ground(32, 57, 15, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
