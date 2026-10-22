local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local lent = GV.ramp("#f08a24")
local body = c:rrect(22, 16, 41, 52, 2)
local flap = c:poly({ {22,16}, {42,16}, {32,31} })
local band = c:rect(25, 36, 38, 43)
local function bean(cx, cy) return c:ellipse(cx, cy, 2.5, 2) end
local spill = bean(27.5, 14):add(bean(33.5, 12)):add(bean(38.5, 14))
local p = c:build{
  { "spill", spill, lent, { flat = true } },
  { "body", body, "cream" },
  { "flap", flap, "#dcb06a", { light = body } },
  { "band", band, lent, { light = body } },
  { "fall1", bean(15.5, 50), lent, { flat = true } },
  { "fall2", bean(48.5, 51), lent, { flat = true } },
}
for _, d in ipairs({ {28,14}, {34,12}, {39,14}, {16,50}, {49,51} }) do c:px(d[1], d[2], "#8c4a1a") end
c:seam({ {23,17}, {31,29} }); c:seam({ {40,17}, {32,29} })
c:button(30, 27)
c:ground(31.5, 53, 12, 1.5)
local t = c:save(O .. "aseprite/ph/lentil-seed.aseprite", O .. "png/ph/lentil-seed.png")
print(GV.report(t))
