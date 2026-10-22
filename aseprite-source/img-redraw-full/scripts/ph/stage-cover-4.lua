local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local soilR = GV.ramp("#8c4a1a")
local soil = c:part(c:ellipse(31.5, 48.5, 21, 7), soilR)
c:fill(c:ellipse(31.5, 47.5, 17, 3.5):clip(soil.m), "#a5663a")

local dark, light = GV.ramp("#58a03e"), "moss"
local cs = { {14.5,45,dark}, {21,42,light}, {28,45,dark}, {35,42,light}, {42,45,dark}, {48.5,42,light} }
for i, b in ipairs(cs) do
  c:part(c:ellipse(b[1], b[2], 7, 7), b[3], { cres = 3, deep = 1 })
end

local petal = GV.ramp("#e46a9b")
local fl = { {20,37}, {32,33}, {44,37}, {27,44} }
for _, f in ipairs(fl) do
  local m = c:ellipse(f[1], f[2], 3.5, 3.5)
  c:part(m, petal, { flat = true, contact = false })
  c:paint({ "gg", "gG" }, f[1] - 1, f[2] - 1, { g = "#f5cf6a", G = "#e8a317" })
end

local t = c:save(O .. "aseprite/ph/stage-cover-4.aseprite", O .. "png/ph/stage-cover-4.png")
print(GV.report(t))
