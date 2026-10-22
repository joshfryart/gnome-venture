-- ico/ico-calendar
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local pageR = GV.ramp("#f8eed2")
local headR = GV.ramp("#9c2a1e")
local ringR = GV.ramp("#54404a")
local cellR = GV.ramp("#968f96")
local hotR = GV.ramp("#bf6f4f")

local page = c:rrect(10, 13, 54, 57, 5)
local head = c:rrect(10, 13, 54, 27, 5):add(c:rect(10, 20, 54, 27))
c:build{
  { "page", page, pageR, { gloss = false } },
  { "head", head, headR },
}
-- punch holes under the rings
c:fill(c:rrect(18, 17, 24, 21, 2), headR.deep)
c:fill(c:rrect(40, 17, 46, 21, 2), headR.deep)
c:build{
  { "ringL", c:rrect(19, 8, 23, 19, 2), ringR, { gloss = false } },
  { "ringR", c:rrect(41, 8, 45, 19, 2), ringR, { gloss = false } },
}

for _, p in ipairs({ { 17, 34 }, { 28, 34 }, { 17, 45 }, { 28, 45 } }) do
  c:part(c:rect(p[1], p[2], p[1] + 7, p[2] + 6), cellR, { gloss = false, contact = false })
end
c:part(c:rect(39, 34, 46, 40), hotR, { gloss = { 40, 35 }, contact = false })

local t = c:save(O .. "aseprite/ico/ico-calendar.aseprite", O .. "png/ico/ico-calendar.png")
print(GV.report(t))
