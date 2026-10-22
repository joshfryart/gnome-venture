local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "lrb" }
-- soft leafy band, broad gentle lobes
local band = c:mask()
for x = -4, 68, 8 do band:add(c:ellipse(x, 28, 5)); band:add(c:ellipse(x + 4, 36, 5)) end
band:add(c:rect(0, 27, 63, 37))
for y = 42, 72, 8 do band:add(c:ellipse(28, y, 5)); band:add(c:ellipse(36, y + 4, 5)) end
band:add(c:rect(27, 32, 37, 63))
local soil = c:rect(0, 37, 63, 44):add(c:rect(36, 37, 45, 63))
c:build{
  { "soil", soil, "#7a4a1f", { flat = true } },
  { "band", band, GV.ramp("#58a03e"), { gloss = false } },
}
-- purple spikes (5 px round) on the upper / left row
local function purple(x, y)
  c:paint({ ".ppp.", "ppppp", "ppppp", "ppppp", ".ppp." }, x, y, { p = "#7a5cc0" })
  c:paint({ "...d", "..dd", ".ddd." }, x + 1, y + 2, { d = "#54447f" })
  c:px(x + 1, y + 1, "#a894dc"); c:px(x + 2, y + 1, "#a894dc")
end
-- lilac spikes (4 px round, pale) on the lower / right row, offset half a step
local function lilac(x, y)
  c:paint({ ".ll.", "llll", "llll", ".ll." }, x, y, { l = "#c3b2ea" })
  c:px(x + 3, y + 2, "#9a86cc"); c:px(x + 2, y + 3, "#9a86cc")
  c:px(x + 1, y + 1, "#fff3c8")
end
for x = -1, 63, 6 do if x < 22 or x > 40 then purple(x, 27) end end
for x = 2, 63, 6 do if x < 24 or x > 40 then lilac(x, 33) end end
-- down the stem: purple row on left, lilac on right
purple(27, 27); purple(33, 27)
for y = 34, 63, 6 do purple(27, y) end
for y = 37, 63, 6 do lilac(33, y) end
local t = c:save(O .. "aseprite/ph/lavender-border-tee.aseprite", O .. "png/ph/lavender-border-tee.png")
print(GV.report(t))
