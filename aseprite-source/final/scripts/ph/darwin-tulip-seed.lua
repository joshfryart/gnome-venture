local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rrect(15, 22, 49, 55, 2)
-- folded flap with zigzag crimp top edge
local flap = c:poly({ {15, 13}, {20, 10}, {26, 13}, {32, 10}, {38, 13}, {44, 10}, {50, 13}, {50, 25}, {15, 25} })
local win = c:rrect(20, 29, 44, 51, 5)
local winIn = c:rrect(22, 31, 42, 49, 4)
local seed = c:ellipse(32, 42, 7, 6.5)

local p = c:build{
  { "body", body, "#f1ece0" },
  { "flap", flap, "#dcb06a", { cres = 2, deep = 1 } },
  { "ring", win, "gold", { gloss = false, contact = false } },
  { "win", winIn, "#f4f0e0", { gloss = false, contact = false, cres = 1, deep = 0 } },
  { "seed", seed, "gold" },
}
for x = 15, 50 do if p.body.m:has(x, 25) then c:px(x, 25, "#c9a96e") end end
-- sprout
c:paint({
  "...llll",
  "..lllll",
  "..s.ll.",
  "..s....",
  "..s....",
}, 30, 31, { s = "#4a8a3e", l = "#7ab55c" })
c:px(32, 36, "#4a8a3e")
c:seam({ {17, 24}, {48, 24} })
c:px(26, 53, "#8c4a1a"); c:px(32, 53, "#8c4a1a"); c:px(38, 53, "#8c4a1a")
local t = c:save(O .. "aseprite/ph/darwin-tulip-seed.aseprite", O .. "png/ph/darwin-tulip-seed.png")
print(GV.report(t))
