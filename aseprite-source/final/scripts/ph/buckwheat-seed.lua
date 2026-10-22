local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rect(13, 14, 51, 56)
-- crimped bottom edge: small teeth
for x = 13, 51, 4 do body:del(x, 56); body:del(x + 1, 56) end
local flap = c:poly({ { 13, 9 }, { 52, 9 }, { 52, 21 }, { 32.5, 26 }, { 13, 21 } })
flap:cut(c:rect(13, 9, 14, 10)):cut(c:rect(50, 9, 51, 10))

local p = c:build{
  { "body", body, GV.ramp("#f1ece0") },
  { "flap", flap, GV.ramp("#dcb06a") },
}

-- fold crease across the flap
c:fill(c:rect(16, 14, 48, 15), "#b07a45")
-- crimp seam along the notched flap edge
c:seam({ { 15, 19 }, { 32, 23 }, { 49, 19 } })

-- label panel with gold border
local panel = c:rrect(19, 29, 45, 50, 4)
c:fill(panel, "#f5cf6a")
c:fill(panel:shrink(2), "#f4f0e0")

-- sprig
c:fill(c:line({ { 32, 33 }, { 32, 47 } }, 2), "#2f5a2a")
local L = { "gg..", "ggg.", ".ggd", "..dd" }
local R = { "..gg", ".ggg", "dgg.", "dd.." }
local function bean(rows, x, y, col)
  c:paint(rows, x, y, { g = col, d = "#b07a45" })
end
bean(L, 27, 34, "#f5cf6a"); bean(R, 34, 34, "#dcb06a")
bean(L, 27, 39, "#dcb06a"); bean(R, 34, 39, "#f5cf6a")
c:paint({ ".g.", "ggg", "ggg", "ggd", ".d." }, 31, 30, { g = "#f5cf6a", d = "#b07a45" })
-- leaf
c:paint({ ".ll..", "lllll", "llll.", ".ll.." }, 26, 44, { l = "#58a03e" })
c:px(27, 44, "#a4b86a")

-- printed text dots
c:fill(c:rect(26, 53, 27, 54):add(c:rect(32, 53, 33, 54)):add(c:rect(38, 53, 39, 54)), "#8c4a1a")

local t = c:save(O .. "aseprite/ph/buckwheat-seed.aseprite", O .. "png/ph/buckwheat-seed.png")
print(GV.report(t))
