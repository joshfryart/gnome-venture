-- ph/dried-cranberries (Pantry dried): stand-up foil pouch, crimped top with a hang hole, zip seal, oval window of red berries
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "dried-cranberries"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pouch = c:rrect(14, 8, 49, 55, 3)
c:part(pouch, "stone", { gloss = false })
c:part(c:rect(16, 17, 47, 52), "cream", { gloss = false, contact = false })
-- crimped heat-seal top and the punched hang hole
for x = 15, 48, 2 do c:fill(c:rect(x, 9, x, 15), "#5b6470") end
c:fill(c:rect(29, 11, 35, 12), "#2a1a10"); c:px(30, 11, "#3d2a1c"); c:fill(c:rect(30, 10, 34, 10), "#2a1a10"); c:fill(c:rect(30, 13, 34, 13), "#2a1a10")
c:fill(c:rect(28, 11, 28, 12), "#2a1a10"); c:fill(c:rect(36, 11, 36, 12), "#2a1a10")
-- zip seal
c:fill(c:rect(16, 19, 47, 20), "#a9d6ea"); c:fill(c:rect(16, 21, 47, 21), "#8b8f96")
-- side edge stitch dashes
for y = 24, 50, 3 do c:px(15, y, "#e8a317"); c:px(48, y, "#e8a317") end
-- window full of berries
local win = c:ellipse(32, 36, 12, 9.5)
c:fill(win:copy():grow(1), "#2a1a10")
c:fill(win, "#6b1b2c")
local function berry(x, y)
  local m = c:ellipse(x, y, 3, 3):clip(win)
  c:fill(m, "#a8241f")
  c:fill(c:ellipse(x, y, 3, 3):edge():clip(win):cut(c:rect(0, 0, x, y)), "#6b1b2c")
  c:px(x - 1, y - 1, "#d6322b"); c:px(x - 2, y - 1, "#d6322b"); c:px(x - 1, y - 2, "#f2793a")
end
for _, p in ipairs({ {24, 31}, {31, 29}, {38, 30}, {44, 35}, {21, 38}, {28, 36}, {35, 36}, {41, 41}, {25, 43}, {32, 43} }) do berry(p[1], p[2]) end
c:px(27, 30, "#eef8f2"); c:px(28, 30, "#eef8f2"); c:px(26, 31, "#eef8f2")   -- window glare
-- emblem: three tiny cranberries and a leaf
c:paint({
  "......ll",
  "rr.rr.rl",
  "rRrrRrrR",
  "rrrrrrrr",
  ".d..d..d",
}, 28, 47, { r = "#a8241f", R = "#f2793a", d = "#6b1b2c", l = "#4f9a45" })
c:fill(c:rect(16, 53, 47, 54), "#8b8f96")
c:px(18, 23, "#ffffff")
c:ground(32, 56, 18, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
