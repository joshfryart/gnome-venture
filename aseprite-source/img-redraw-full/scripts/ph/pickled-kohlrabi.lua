-- ph/pickled-kohlrabi (Pantry pickle): cream enamel pail, blue rolled rim, arched wire handle, kohlrabi sticks poking up
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "pickled-kohlrabi"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local enamel = GV.ramp("#f1ece0", { shade = "#c9c5bc", deep = "#8b8f96", bounce = "#d8d4cc", dot = "#fbf6e8" })
-- wire handle arch (behind the sticks), ends hooked into ears on the rim
local arch = {}
for i = 0, 20 do
  local a = math.pi * i / 20
  arch[#arch + 1] = { math.floor(32.5 - 21 * math.cos(a)), math.floor(25 - 19 * math.sin(a)) }
end
c:part(c:line(arch, 2), "stone", { flat = true, contact = false, solid = false })
-- kohlrabi sticks: five pale-green batons bunched above the rim
for i, x in ipairs({ 25, 29, 33, 37 }) do
  local top = ({ 17, 15, 16, 18 })[i]
  c:part(c:rect(x, top, x + 2, 25), "#a4b86a", { gloss = false, contact = false, cres = 2, deep = 0 })
end
local body = c:poly({ {13, 25}, {53, 25}, {48, 56}, {18, 56} })
c:part(body, enamel, { gloss = { 18, 31 } })
c:part(c:rect(17, 51, 49, 54):clip(body), "water", { gloss = false, contact = false })   -- blue base band
c:part(c:rrect(11, 21, 53, 27, 3), "water", { gloss = { 14, 23 } })                   -- rolled rim
c:px(12, 24, "#5b6470"); c:px(52, 24, "#5b6470")                                         -- ear rivets
-- emblem: kohlrabi bulb with two leaf stalks and a root tail
c:paint({
  "..gg.....gg..",
  "..ggg...ggg..",
  "...gg...gg...",
  "....g...g....",
  ".....g.g.....",
  "....KKKKK....",
  "..LLKKKKKKk..",
  ".LKKKKKKKKkk.",
  ".KKKKKKKKKkk.",
  "KKKKKKKKKKkkk",
  ".KKKKKKKKkkk.",
  ".KKKKKKKkkkk.",
  "..kKKKkkkkk..",
  "....kkkkk....",
  "......u......",
  "......u......",
}, 26, 33, { g = "#4f9a45", L = "#c8d77a", K = "#a4b86a", k = "#7ab55c", u = "#7a5a3a" })
c:fill(c:rect(18, 49, 19, 50), "#8b8f96")   -- chips on the enamel
c:px(45, 40, "#c9c5bc"); c:px(46, 41, "#c9c5bc")
c:ground(33, 57, 17, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
