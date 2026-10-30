-- ph/cured-olives (Pantry preserve): terracotta amphora with two big ear handles, pointed cork, painted olive band, olives heaped at the shoulder
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "cured-olives"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local terra = GV.ramp("#b0683a", { shade = "#8a4a2a", deep = "#5e2f1e", bounce = "#9a5030", rim = "#d08a5a", gloss = "#f0b880", dot = "#ffd8a8" })
local olive = GV.ramp("#3d3a2a", { rim = "#6a8a3a", gloss = "#a4b86a", dot = "#c8d77a", shade = "#2a2618", deep = "#1e1a10", bounce = "#4a4630" })
-- ear handles (behind the body)
c:part(c:ellipse(14, 27, 6, 8):cut(c:ellipse(14, 27, 3, 5)), terra, { gloss = false, contact = false, cres = 2, deep = 0 })
c:part(c:ellipse(50, 27, 6, 8):cut(c:ellipse(50, 27, 3, 5)), terra, { gloss = false, contact = false, cres = 2, deep = 0 })
local body = c:poly({ {26, 14}, {39, 14}, {40, 18}, {50, 27}, {49, 43}, {40, 53}, {24, 53}, {15, 43}, {14, 27}, {24, 18} })
c:part(body, terra, { gloss = { 19, 30 } })
c:part(c:rrect(28, 52, 36, 56, 1), terra, { gloss = false, cres = 2, deep = 0 })   -- little foot
-- painted band with an olive sprig
c:fill(c:rect(15, 33, 49, 35):clip(body), "#3d2a1c")
c:paint({ "l.l.ll.l.l.l.l", ".l.l..l.l.l.l." }, 18, 33, { l = "#6a8a3a" })
c:paint({ "oo", "oo" }, 25, 34, { o = "#1e1a10" }); c:paint({ "oo", "oo" }, 38, 33, { o = "#1e1a10" })
-- emblem on the belly: olive branch with two olives
c:paint({
  ".........l.",
  "..l....ll..",
  "...l..lk...",
  ".ll.lkl....",
  "....kl.....",
  "...kk......",
  "..koO......",
  ".kooo..oO..",
  "..oo..ooo..",
  "......oo...",
}, 26, 39, { l = "#6a8a3a", k = "#5e2f1e", o = "#3d3a2a", O = "#a4b86a" })
-- pointed cork in the mouth
c:part(c:poly({ {28, 15}, {37, 15}, {36, 9}, {33, 6}, {31, 6}, {28, 9} }), "#c9a96e", { gloss = false, cres = 2, deep = 0 })
c:px(30, 9, "#efdcae"); c:px(34, 11, "#9a6b3f"); c:px(31, 13, "#9a6b3f")
-- olives heaped on the shoulder around the cork
for _, p in ipairs({ {23, 19}, {28, 17}, {37, 17}, {42, 19}, {32, 20} }) do
  c:part(c:ellipse(p[1], p[2], 3.5, 3), olive, { gloss = false, contact = false, cres = 2, deep = 0 })
  c:px(p[1] - 1, p[2] - 1, "#a4b86a")
end
c:ground(32, 57, 13, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
