local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "r" }
local O = D .. "img-redraw-full/"

-- leafy body: overlapping puffs, left cap at x 24, bleeding off the right
local puffs = { {32, 32, 8, 7}, {39, 30, 8, 8}, {46, 32, 8, 7}, {53, 30, 8, 8}, {60, 32, 8, 7}, {67, 30, 8, 8} }
local whole = c:mask()
for _, p in ipairs(puffs) do whole:add(c:ellipse(p[1], p[2], p[3], p[4])) end
whole:add(c:rect(26, 32, 63, 39))
local leaf = GV.ramp("#58a03e", { shade = "#4a8a3e", deep = "#2f5a2a", rim = "#a4b86a" })
local list = {}
-- base slab under the puffs so the bottom reads as one mound
list[#list + 1] = { "slab", c:rrect(25, 30, 63, 39, 3), leaf, { light = whole, gloss = false } }
for i, p in ipairs(puffs) do
  local m = c:ellipse(p[1], p[2], p[3], p[4]):cut(c:rect(0, 40, 63, 63))
  list[#list + 1] = { "p" .. i, m, leaf, { light = whole, contour = "#2f5a2a", gloss = (i == 1) and { 28, 27 } or false, contact = false } }
end
c:build(list)

-- blooms: violet row above, lilac row below (staggered)
local vio = { ".vv.", "Vvvv", "vvvd", ".dd." }
local lil = { ".ll.", "Llll", "llls", ".ss." }
local VL = { v = "#7a5cc0", V = "#a894dc", d = "#3e2f66" }
local LL = { l = "#c3b2ea", L = "#ece4fa", s = "#8d78c8" }
for i, x in ipairs({ 30, 37, 44, 51, 57, 63 }) do
  local y = (i % 2 == 0) and 25 or 27
  c:paint(vio, x - 2, y, VL)
end
for i, x in ipairs({ 33, 40, 47, 54, 61 }) do
  local y = (i % 2 == 0) and 32 or 33
  c:paint(lil, x - 1, y, LL)
end

c:ground(44, 41, 20, 1.5)
local t = c:save(O .. "aseprite/ph/lavender-border-end.aseprite", O .. "png/ph/lavender-border-end.png")
print(GV.report(t))
