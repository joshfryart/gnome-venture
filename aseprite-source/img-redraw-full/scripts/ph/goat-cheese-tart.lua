local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wall = c:ellipse(31.5, 42, 26, 12)
local top = c:ellipse(31.5, 36, 26, 10)
local cheese = c:ellipse(31.5, 35, 19, 7)
local p = c:build{
  { "wall", wall, GV.ramp("#a5663a") },
  { "crust", top, GV.ramp("#dcb06a", { rim = "#ecc58a" }), { gloss = { 12, 31 }, cres = 2, deep = 1 } },
  { "cheese", cheese, GV.ramp("#f8dc80", { gloss = "#fff3c8", dot = "#ffffff", rim = "#fff1c8" }), { gloss = { 20, 31 } } },
}
-- X score
c:fill(c:line({ {22, 32}, {41, 38} }, 2), "#b07a45")
c:fill(c:line({ {41, 32}, {22, 38} }, 2), "#b07a45")
-- crimp marks around crust ring
local crimp = { {9,34},{11,30},{15,27},{20,25},{26,24},{37,24},{43,25},{48,27},{52,30},{54,34},{53,39},{49,43},{44,45},{38,46},{32,47},{25,46},{19,45},{14,43},{10,39} }
for _, q in ipairs(crimp) do c:px(q[1], q[2], "#8a4f2a") end
-- wall flutes
for x = 10, 53, 4 do c:px(x, 48, "#5e2f1e") end
c:ground(31.5, 54, 22, 1.5)
local t = c:save(O .. "aseprite/ph/goat-cheese-tart.aseprite", O .. "png/ph/goat-cheese-tart.png")
print(GV.report(t))
