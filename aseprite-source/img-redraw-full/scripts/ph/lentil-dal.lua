local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local metal = GV.ramp("#8b8f96", { shade = "#5b6470", deep = "#35161f" })
local metalD = GV.ramp("#5b6470", { rim = "#c9c5bc", shade = "#3e2f66" })

-- steam wisps
local steam = c:line({ {27, 11}, {25, 13}, {27, 15}, {25, 18} }, 2)
steam:add(c:line({ {37, 10}, {39, 12}, {37, 15}, {39, 18} }, 2))
-- handles
local lugs = c:rrect(9, 25, 15, 31, 2):add(c:rrect(48, 25, 54, 31, 2))
-- pot body
local body = c:ellipse(31.5, 34, 19, 18):cut(c:rect(0, 0, 63, 27))
body:add(c:rect(13, 27, 50, 34))
body:cut(c:rect(0, 50, 63, 63))
body:add(c:rrect(17, 44, 46, 50, 4))
-- rim
local rim = c:ellipse(31.5, 27, 20, 6)
-- dal surface
local dal = c:ellipse(31.5, 27, 16, 3.5)

local p = c:build{
  { "steam", steam, "cream", { flat = true } },
  { "lugs", lugs, metalD, { gloss = false } },
  { "body", body, metal, { gloss = { 19, 34 } } },
  { "rim", rim, metalD, { gloss = false } },
  { "dal", dal, GV.ramp("#f08a24", { gloss = "#f5cf6a" }), { gloss = false, rim = false, contact = false } },
}
-- lit streak on dal
c:fill(c:rect(22, 25, 29, 25), "#f5cf6a")
-- lentil bits
c:fill(c:ellipse(26, 28, 1, 1), "#8a4f2a")
c:px(40, 29, "#8a4f2a"); c:px(20, 27, "#8a4f2a")
-- coriander sprig
c:paint({ ".ll.ll", "lLllLl", ".l..l." }, 34, 25, { l = "#7ab55c", L = "#c8d77a" })
c:px(36, 28, "#4a8a3e"); c:px(37, 28, "#4a8a3e")
-- rivets on lugs
c:button(10, 26); c:button(50, 26)

local t = c:save(B .. "img-redraw-full/aseprite/ph/lentil-dal.aseprite", B .. "img-redraw-full/png/ph/lentil-dal.png")
print(GV.report(t))
