local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local wood = GV.ramp("#b07a45", { rim = "#d9a660" })
-- handles: thick wooden grips splaying down, rounded ends
local hl = c:line({ {30, 36}, {21, 52} }, 7):add(c:ellipse(20, 53, 4, 4))
local hr = c:line({ {34, 36}, {43, 52} }, 7):add(c:ellipse(44, 53, 4, 4))
-- blades: tapered curved steel blades pointing up
local bl = c:poly({ {27, 37}, {35, 34}, {24, 15}, {18, 5}, {14, 8}, {17, 18} })
local br = c:poly({ {37, 37}, {29, 34}, {40, 15}, {46, 5}, {50, 8}, {47, 18} })

local p = c:build{
  { "hl", hl, wood },
  { "hr", hr, wood },
  { "br", br, "stone", { gloss = false } },
  { "bl", bl, "stone", { gloss = { 20, 16 } } },
  { "pivot", c:ellipse(32, 34, 5, 5), GV.ramp("#5b6470"), { gloss = { 30, 31 } } },
}
-- lit inner blade edges
c:line({ {22, 18}, {29, 31} }, 1):each(function(x, y) if p.bl.m:has(x, y) then c:px(x, y, "#c9c5bc") end end)
c:line({ {44, 18}, {37, 29} }, 1):each(function(x, y) if p.br.m:has(x, y) then c:px(x, y, "#c9c5bc") end end)
c:px(30, 32, "#c9c5bc")

local t = c:save(O .. "aseprite/ph/pruning-shears.aseprite", O .. "png/ph/pruning-shears.png")
print(GV.report(t))
