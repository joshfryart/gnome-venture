local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local g = GV.ramp("#dcb06a", { rim = "#f5cf6a" })
local base = c:rrect(17, 50, 46, 57, 3)
local post = c:rect(29, 14, 34, 51)
local beam = c:rrect(10, 15, 53, 19, 2)
local finial = c:ellipse(31.5, 11, 4.5, 4.5)
local chains = c:line({ {15, 19}, {10, 35} }, 3)
chains:add(c:line({ {15, 19}, {22, 35} }, 3))
chains:add(c:line({ {48, 19}, {41, 35} }, 3))
chains:add(c:line({ {48, 19}, {53, 35} }, 3))
local panL = c:ellipse(16, 35, 9, 9):cut(c:rect(0, 0, 63, 34))
local panR = c:ellipse(47, 35, 9, 9):cut(c:rect(0, 0, 63, 34))
local pans = panL:copy():add(panR)

local p = c:build{
  { "post", post, g },
  { "base", base, g },
  { "beam", beam, g },
  { "finial", finial, g },
  { "chains", chains, g, { flat = true } },
  { "pans", pans, "gold" },
}
-- hanging hooks on the beam
c:fill(c:rect(14, 18, 16, 20), "#b8661a")
c:fill(c:rect(47, 18, 49, 20), "#b8661a")
-- pan rims
c:fill(c:rect(8, 35, 24, 35), "#fff1c8")
c:fill(c:rect(39, 35, 55, 35), "#fff1c8")

local t = c:save(D .. "img-redraw-full/aseprite/ico/ico-scales.aseprite", D .. "img-redraw-full/png/ico/ico-scales.png")
print(GV.report(t))
