local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tall pointed oval: long upper half, round lower half
local egg = c:ellipse(31.5, 37, 14, 23):cut(c:rect(0, 37, 63, 63))
egg:add(c:ellipse(31.5, 37, 14, 13):cut(c:rect(0, 0, 63, 36)))

c:build{
  { "egg", egg, GV.ramp("#e8dcc0"), { pale = true } },
}
-- bean freckles, varied sizes and tilts
local F = "#7a5a36"
c:spot(c:ascii({ ".xx.", "xxxx", "xxx." }, 24, 29), F)            -- medium
c:spot(c:ascii({ ".xx", "xx." }, 37, 25), F)                       -- small tilted
c:spot(c:ascii({ "..xxx", ".xxxx", "xxxx.", ".xx.." }, 33, 39), F) -- big
c:spot(c:ascii({ "xx.", "xxx", ".x." }, 22, 43), F)                -- small
c:spot(c:ascii({ "xxx", ".xx" }, 39, 45), F)                       -- small
c:spot(c:ascii({ "xx" }, 30, 21), F)                               -- tiny
c:ground(31.5, 52, 11, 1.5)
local t = c:save(O .. "aseprite/animals/item-quail-egg.aseprite", O .. "png/animals/item-quail-egg.png")
print(GV.report(t))
