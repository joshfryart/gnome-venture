local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local copper = GV.ramp("#8a4f2a")
local tin = GV.ramp("#c4925f")

-- arch handle: outer half-ellipse minus inner (opening >= 3 px cream)
local handle = c:ellipse(26, 30, 13, 17):cut(c:ellipse(26, 30, 9.5, 13.5)):cut(c:rect(0, 29, 63, 63))
-- spout: diagonal tube from body side up to the right, flared rose at the tip
local spout = c:line({ {37, 40}, {48, 28} }, 5)
local rose = c:poly({ {45, 24}, {51, 20}, {54, 25}, {50, 31} })
local body = c:poly({ {12, 30}, {41, 30}, {38, 54}, {15, 54} })
local rim = c:rrect(10, 27, 42, 31, 1)

local p = c:build{
  { "handle", handle, tin },
  { "spout",  spout, tin },
  { "rose",   rose, GV.ramp("#d9a660") },
  { "body",   body, copper, { light = body:copy():add(rim) } },
  { "rim",    rim, "#d9a660", { gloss = false } },
}
-- spout top highlight
c:line({ {40, 38}, {46, 31} }, 1):each(function(x, y) if p.spout.m:has(x, y) and not p.body.m:has(x, y) then c:px(x, y, "#f0d49a") end end)
-- rose holes
c:paint({ "h.h", ".h.", "h.h" }, 49, 23, { h = "#5e2f1e" })
-- water droplet
c:build{ { "drop", c:poly({ {55, 9}, {58, 14}, {57, 16}, {53, 16}, {52, 14} }), GV.ramp("#8fcbd8"), { flat = true } } }
-- rim seam
c:seam({ {12, 29}, {40, 29} })
-- riveted band on body
c:seam({ {14, 44}, {38, 44} }, { on = 1, off = 2, gap = nil })
c:ground(26.5, 56, 13, 1.5)
local t = c:save(O .. "aseprite/ph/tin-watering-can.aseprite", O .. "png/ph/tin-watering-can.png")
print(GV.report(t))
