local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local L = c:poly({ {9, 15}, {24, 20}, {24, 53}, {9, 48} })
local M = c:poly({ {23, 20}, {42, 13}, {42, 47}, {23, 53} })
local R = c:poly({ {41, 13}, {56, 18}, {56, 51}, {41, 47} })
local paper = GV.ramp("#f8eed2")
local p = c:build{
  { "left",   L, paper, { light = L:copy():add(M):add(R) } },
  { "right",  R, paper, { light = L:copy():add(M):add(R) } },
  { "middle", M, GV.ramp("#dcb06a"), { gloss = false } },
}
-- route: rim then core
local pts = { {13, 43}, {17, 37}, {22, 32}, {27, 33}, {33, 36}, {38, 34}, {44, 28}, {48, 25} }
local route = c:line(pts, 3)
c:fill(route, "#bf6f4f")
c:fill(c:line(pts, 1):shift(-1, -1):clip(route), "#f0d49a")
-- dashes of route start marker
c:fill(c:rect(11, 43, 13, 45), "#bf6f4f")
-- fold seams
c:seam({ {24, 21}, {24, 52} }, { free = true })
c:seam({ {41, 14}, {41, 46} }, { free = true })
-- pin
c:part(c:ellipse(49.5, 22.5, 5.5, 5.5), GV.ramp("#dd3a2a", { base = "#9c2a1e" }), { gloss = { 47, 20 } })
local t = c:save(O .. "aseprite/ico/ico-world-map.aseprite", O .. "png/ico/ico-world-map.png")
print(GV.report(t))
