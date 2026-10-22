local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:ellipse(31.5, 37, 17, 16)
local cup = c:ellipse(31.5, 37, 17, 16):clip(c:rect(0, 42, 63, 63))
cup:add(c:poly({ {15, 43}, {20, 38}, {25, 43}, {31, 38}, {37, 43}, {43, 38}, {48, 43}, {48, 46}, {15, 46} }):clip(body))
local stem = c:rrect(30, 15, 33, 23, 1)
local leaf = c:poly({ {33, 18}, {36, 11}, {41, 6}, {46, 5}, {46, 9}, {43, 14}, {38, 18} })

c:build{
  { "stem", stem, GV.ramp("#3f7a34") },
  { "body", body, GV.ramp("#dcb06a"), { light = body } },
  { "cup", cup, GV.ramp("#a8582f"), { light = body, gloss = false } },
  { "leaf", leaf, "moss", { gloss = { 39, 11 } } },
}
c:paint({ "u", "u" }, 26, 30, { u = "#a8582f" })
c:paint({ "u", "u" }, 35, 34, { u = "#a8582f" })
c:paint({ "u", "u" }, 22, 37, { u = "#a8582f" })
c:fill(c:line({ {37, 15}, {43, 9} }, 1), "#4a8a3e")
local t = c:save(O .. "aseprite/ph/jute-mallow.aseprite", O .. "png/ph/jute-mallow.png")
print(GV.report(t))
