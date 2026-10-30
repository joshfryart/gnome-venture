-- ph/dried-figs (Pantry dried): drawstring linen bag, three dried figs spilling from the mouth, hanging tag
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "dried-figs"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bag = c:rrect(15, 30, 49, 56, 9):add(c:poly({ {19, 28}, {45, 28}, {49, 34}, {15, 34} }))
local mouth = c:poly({ {16, 21}, {24, 24}, {32, 22}, {40, 24}, {48, 21}, {46, 30}, {18, 30} })
local p = c:build{
  { "back", mouth, "#e8d8b0", { gloss = false } },
}
-- figs: teardrops with a stem nub, back two first
local function fig(x, y)
  local m = c:ellipse(x + 0.5, y + 2, 5, 4.5):add(c:poly({ {x - 1, y - 5}, {x + 3, y - 5}, {x + 5, y + 1}, {x - 4, y + 1} }))
  c:part(m, "#6a3a4a", { cres = 3, contact = false })
  c:fill(c:rect(x, y - 7, x + 1, y - 5), "#5e2f1e")
  c:px(x - 1, y + 2, "#c98a6a"); c:px(x + 2, y + 3, "#c98a6a"); c:px(x, y + 4, "#c98a6a")   -- seed flecks
end
fig(23, 20); fig(41, 20); fig(32, 15)
c:part(bag, "#e8d8b0", { stitch = true })
-- gathered neck: frill band with fold lines above a dark drawstring
c:part(c:poly({ {17, 25}, {47, 25}, {45, 32}, {19, 32} }), "#e8d8b0", { gloss = false, cres = 2, deep = 0 })
for x = 21, 43, 4 do c:fill(c:rect(x, 27, x, 31), "#c9a96e") end
c:fill(c:rect(18, 32, 46, 33), "#8a5a2f")
c:fill(c:rect(18, 32, 46, 32), "#a8582f")
-- bow
c:paint({ "bbb...bbb", "bBbbkbbBb", "bbbbkbbbb", ".bb.k.bb.", "..b...b..", ".b.....b." }, 28, 30, { b = "#a8582f", B = "#d9a660", k = "#5e2f1e" })
-- tag on a string
c:fill(c:line({ {32, 36}, {32, 38} }, 1), "#8a5a2f")
c:part(c:rrect(26, 38, 38, 47, 1), "cream", { gloss = false, contact = false })
c:paint({ ".k.", "fff", "fff", ".f." }, 31, 40, { f = "#6a3a4a", k = "#5e2f1e" })
c:ground(32, 57, 15, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
