local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local moss = GV.ramp("#7ab55c", { shade = "#4a8a3e" })
local outer = GV.ramp("#6a9a3a")
local rib = GV.ramp("#c8d77a")

-- outer ruffled leaves: pointed egg with scallops on both sides
local body = c:ellipse(31.5, 37, 19, 17)
body:add(c:poly({ {30, 9}, {34, 9}, {47, 28}, {16, 28} }))
for _, y in ipairs({ 22, 31, 40 }) do
  local dx = (y == 22) and 13 or ((y == 31) and 18 or 19)
  body:add(c:ellipse(31.5 - dx, y, 3, 3))
  body:add(c:ellipse(31.5 + dx, y, 3, 3))
end
body:cut(c:rect(0, 54, 63, 63))

-- inner heart leaf: narrower, lighter
local heart = c:ellipse(31.5, 38, 13, 14)
heart:add(c:poly({ {30, 13}, {34, 13}, {44, 31}, {19, 31} }))
heart:cut(c:rect(0, 53, 63, 63))

-- midrib tapered
local mid = c:poly({ {28, 53}, {36, 53}, {33, 17}, {31, 17} })

local p = c:build{
  { "outer", body, outer, { cres = 4, deep = 2 } },
  { "heart", heart, moss, { light = body, gloss = { 23, 26 } } },
  { "rib", mid, rib, { gloss = false, contact = false, cres = 2, deep = 1 } },
}
-- side veins
local V = "#4a8a3e"
c:fill(c:line({ {29, 26}, {23, 22} }, 2), V)
c:fill(c:line({ {29, 35}, {21, 30} }, 2), V)
c:fill(c:line({ {29, 44}, {22, 40} }, 2), V)
c:fill(c:line({ {35, 26}, {41, 22} }, 2), V)
c:fill(c:line({ {35, 35}, {43, 30} }, 2), V)
c:fill(c:line({ {35, 44}, {42, 40} }, 2), V)
-- leaf-edge notches between scallops
for _, y in ipairs({ 26, 35 }) do
  local dx = (y == 26) and 15 or 18
  c:px(31 - dx, y, "#2f5a2a"); c:px(32 - dx, y, "#2f5a2a")
  c:px(31 + dx + 1, y, "#2f5a2a"); c:px(30 + dx + 1, y, "#2f5a2a")
end
-- frilly tips at the top
c:paint({ "..t.t..", ".ttttt.", "t.ttt.t" }, 29, 9, { t = "#a4b86a" })

c:ground(31.5, 55, 14, 1.5)
local t = c:save(O .. "aseprite/ph/napa-cabbage.aseprite", O .. "png/ph/napa-cabbage.png")
print(GV.report(t))
