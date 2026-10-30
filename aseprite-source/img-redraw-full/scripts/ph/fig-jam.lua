-- ph/fig-jam (Pantry jam): teardrop bulb jar with a narrow neck and a tall cork, dark seedy fig jam
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "fig-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local bulb = c:ellipse(32, 41, 18, 13):add(c:poly({ {26, 13}, {39, 13}, {39, 20}, {46, 32}, {19, 32}, {26, 20} }))
local fill = c:ellipse(32, 42, 16, 11):add(c:poly({ {28, 19}, {37, 19}, {37, 22}, {43, 32}, {22, 32}, {28, 22} }))
c:build{
  { "glass", bulb, "glass" },
  { "jam",   fill, "#4a2038", { contour = "#291d4a", gloss = false } },
  { "label", c:rrect(22, 37, 42, 48, 2), "cream", { gloss = false, contact = false } },
  { "cork",  c:rrect(25, 7, 39, 15, 1), "#c9a96e", { gloss = false } },
}
for _, g in ipairs({ {28, 9}, {33, 11}, {29, 13}, {36, 8}, {35, 13} }) do c:px(g[1], g[2], "#9a6b3f") end   -- cork grain
c:fill(c:rect(26, 8, 38, 8), "#e6d4ac")
c:seam({ {26, 14}, {38, 14} })
for _, s in ipairs({ {20, 40}, {23, 36}, {29, 33}, {35, 31}, {40, 35}, {44, 40}, {19, 47}, {25, 51}, {32, 50}, {39, 51}, {45, 47}, {31, 25}, {34, 28} }) do
  c:px(s[1], s[2], "#f5cf6a")                           -- seed specks
end
c:paint({ ".gg", "g..", "g.." }, 18, 34, { g = "#c3b2ea" })   -- lilac gloss comma on the dark belly
-- label: halved fig, purple skin, pink flesh with cream seeds
c:paint({
  "....k....",
  "...vvv...",
  "..vpppv..",
  ".vpcpcpv.",
  ".vppcppv.",
  "vpcpppcpv",
  "vppcpcppv",
  ".vpppppv.",
  "..vvvvv..",
}, 28, 38, { v = "#7a5cc0", p = "#e46a9b", c = "#f4f0e0", k = "#7a4a1f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
