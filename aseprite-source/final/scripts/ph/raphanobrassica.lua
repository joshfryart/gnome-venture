local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bulb = c:ellipse(31.5, 38, 14, 13)
bulb:add(c:poly({ {29, 47}, {35, 47}, {32, 53} }))
local function lobe(cx, cy, rx, ry, n)
  local m = c:ellipse(cx, cy, rx, ry)
  for i = 0, n - 1 do
    local a = math.pi * (1.05 + 0.9 * i / (n - 1))
    m:add(c:ellipse(cx + math.cos(a) * rx, cy + math.sin(a) * ry, 2.5, 2.5))
  end
  return m
end
local L = lobe(22, 24, 8, 6, 4)
local R = lobe(41, 24, 8, 6, 4)
local M = lobe(31.5, 18, 7, 7, 4)
local p = c:build{
  { "root", c:line({ {32, 51}, {32, 55} }, 2), "#f6b8cf", { flat = true } },
  { "bulb", bulb, "#e46a9b", { gloss = { 22, 34 } } },
  { "left", L, "#6a9a3a" },
  { "right", R, "#4a8a3e" },
  { "mid", M, "#7ab55c" },
}
-- leaf veins (ruffle lines)
c:paint({ "v...", ".v..", "..v.", "...v" }, 19, 22, { v = "#2f5a2a" })
c:paint({ "...v", "..v.", ".v..", "v..." }, 40, 22, { v = "#2f5a2a" })
c:paint({ "v", "v", "v", "v", "v" }, 31, 14, { v = "#4a8a3e" })
-- bulb root hairs
c:paint({ "u..", ".u." }, 21, 44, { u = "#ae2a5a" })
c:paint({ "..u", ".u." }, 40, 43, { u = "#ae2a5a" })
local t = c:save(O .. "aseprite/ph/raphanobrassica.aseprite", O .. "png/ph/raphanobrassica.png")
print(GV.report(t))
