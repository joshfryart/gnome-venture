local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local fringe = c:poly({ {19, 40}, {27, 40}, {23, 53} }):add(c:poly({ {28, 40}, {36, 40}, {32, 54} })):add(c:poly({ {37, 40}, {45, 40}, {41, 53} }))
local body = c:ellipse(31.5, 33, 19, 12)
for i = 0, 4 do body:add(c:ellipse(16.5 + i * 7.5, 22, 4.5, 4)) end
local cap = c:mask()
for i = 0, 4 do cap:add(c:ellipse(16.5 + i * 7.5, 22, 4.5, 4)) end
cap:add(c:rect(13, 22, 50, 25)):clip(body)
local wav = c:mask()
for i = 0, 4 do wav:add(c:ellipse(16.5 + i * 7.5, 26, 4, 1.5)) end
cap:add(wav:clip(body))
local p = c:build{
  { "fringe", fringe, "#d0862a" },
  { "body", body, "gold", { stitch = { side = "lit" } } },
  { "cap", cap, "#fff1c8", { pale = true, light = body } },
}
local s = "#b8661a"
c:paint({ "s.", "s.", ".s", ".s", "s." }, 21, 31, { s = s })
c:paint({ ".s", ".s", "s.", "s.", ".s" }, 40, 31, { s = s })
c:paint({ "ss...ss", "..sss.." }, 28, 37, { s = s })
local t = c:save(O .. "aseprite/ph/frost-fur.aseprite", O .. "png/ph/frost-fur.png")
print(GV.report(t))
