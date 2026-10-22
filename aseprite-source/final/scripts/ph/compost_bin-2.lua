local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"

local soil = GV.ramp("#44281c")
local wood = GV.ramp("#a5663a")
local slat = GV.ramp("#b6814d")

local mound = c:ellipse(29.5, 36, 16, 22):cut(c:rect(0, 36, 63, 63))
local body = c:rrect(13, 33, 46, 51, 2)
local whole = body:copy():add(mound)
c:build{
  { "pole",   c:rect(46, 13, 47, 33), soil, { flat = true } },
  { "flag",   c:poly({ {48, 13}, {54, 17}, {48, 22} }), "#d6322b", { gloss = false } },
  { "mound",  mound, soil, { gloss = { 20, 20 } } },
  { "body",   body, wood, { light = whole, gloss = false } },
  { "slat1",  c:rect(16, 36, 43, 39), slat, { light = whole, gloss = false } },
  { "slat2",  c:rect(16, 42, 43, 45), slat, { light = whole, gloss = false } },
  { "slat3",  c:rect(16, 48, 43, 50), slat, { light = whole, gloss = false } },
  { "postL",  c:rrect(11, 31, 15, 52, 1), slat, { light = whole, gloss = false } },
  { "postR",  c:rrect(44, 31, 48, 52, 1), slat, { light = whole, gloss = false } },
}
-- top rims on slats, gloss dot on the top-left slat
for _, y in ipairs({ 36, 42, 48 }) do
  for x = 17, 42 do c:px(x, y, "#f0d49a") end
end
c:px(18, 37, "#fff1c8")
c:px(49, 15, "#ff9158")
-- scraps on the mound
c:paint({ ".g.", "ggg", "Gg." }, 22, 23, { g = "#58a03e", G = "#2f5a2a" })
c:paint({ "oo.", "ooo", ".oO" }, 32, 19, { o = "#e0501f", O = "#ae2a2a" })
c:paint({ "yy.", "yyy", ".yY" }, 28, 28, { y = "#e8a317", Y = "#b8661a" })
c:paint({ "..l.", ".ll.", "llL.", "lLL." }, 37, 24, { l = "#7ab55c", L = "#4a8a3e" })
c:paint({ ".c", "cc" }, 18, 30, { c = "#c9a96e" })
c:paint({ "pp" }, 27, 18, { p = "#e46a9b" })
-- base trim
for x = 16, 43 do c:px(x, 51, "#e8a317") end

c:ground(29.5, 53, 20, 1.5)
local t = c:save(O .. "aseprite/ph/compost_bin-2.aseprite", O .. "png/ph/compost_bin-2.png")
print(GV.report(t))
