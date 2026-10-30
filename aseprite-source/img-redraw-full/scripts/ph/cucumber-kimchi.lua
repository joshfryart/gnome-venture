-- ph/cucumber-kimchi (Pantry kimchi): low wide clear tub with a red snap lid and latch tabs, stuffed cucumber rounds inside
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "cucumber-kimchi"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tub = GV.ramp("#c9e6f0", { gloss = "#eef8f2", dot = "#f8fcf4", rim = "#eef8f2", shade = "#a9d6ea", deep = "#6f98c4", bounce = "#8fb4d6", pale = false })
c:build{
  { "tub",  c:rrect(9, 28, 55, 55, 6), tub, { gloss = { 12, 33 } } },
  { "chili", c:rrect(12, 32, 52, 52, 3), "red", { gloss = false, contour = "#6b1b2c" } },
}
-- cucumber cross-sections: green skin ring, pale flesh, red stuffed cross
for _, p in ipairs({ {21, 42}, {32, 44}, {43, 42} }) do
  local x, y = p[1], p[2]
  c:part(c:ellipse(x, y, 5), "moss", { gloss = false, contact = false, cres = 2, deep = 0 })
  c:fill(c:ellipse(x, y, 3), "#e0f0c0")
  c:fill(c:rect(x - 3, y, x + 3, y), "#dd3a2a"); c:fill(c:rect(x, y - 3, x, y + 3), "#dd3a2a")
  c:px(x - 2, y - 2, "#fbfdf0")
end
for _, p in ipairs({ {15, 35}, {27, 50}, {49, 49}, {38, 34} }) do c:px(p[1], p[2], "#f5cf6a") end   -- garlic bits
-- red snap lid: latch tabs at the ends, raised handle ridge, cucumber slice emblem
c:part(c:rrect(7, 23, 10, 34, 1), "#a8241f", { gloss = false, cres = 2, deep = 0 })
c:part(c:rrect(53, 23, 56, 34, 1), "#a8241f", { gloss = false, cres = 2, deep = 0 })
c:part(c:rrect(9, 17, 55, 28, 4), "red", { gloss = { 13, 19 } })
c:part(c:rrect(22, 13, 42, 18, 2), "#a8241f", { gloss = false, cres = 2, deep = 0 })
c:seam({ {12, 27}, {52, 27} }, { gap = "#ae2a2a" })
c:paint({
  "..gggg..",
  ".gPPPPg.",
  "gPPsPPPg",
  "gPsPPsPg",
  ".gPPPPg.",
  "..gggg..",
}, 28, 19, { g = "#4a8a3e", P = "#e0f0c0", s = "#7ab55c" })
c:ground(32, 57, 22, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
