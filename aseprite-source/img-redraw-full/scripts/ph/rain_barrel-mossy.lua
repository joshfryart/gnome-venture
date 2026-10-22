local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pipe = c:rect(8, 7, 13, 24):add(c:rect(8, 19, 22, 24)):add(c:ellipse(12.5, 21.5, 4.5, 3.5):clip(c:rect(8,18,16,24)))
local body = c:rrect(15, 22, 50, 54, 8):add(c:ellipse(32.5, 38, 18.5, 15))
body:clip(c:rect(14, 22, 51, 54))
local stone = GV.ramp("#968f96")
local iron = GV.ramp("#6a6070")
local p = c:build{
  { "pipe", pipe, stone },
  { "drip", c:ellipse(10, 28.5, 1.5, 2), GV.ramp("#a9d6ea"), { flat = true } },
  { "body", body, "wood" },
}
-- staves
for _, x in ipairs({ 23, 32, 41 }) do
  for y = 25, 54 do if p.body.m:has(x, y) then c:px(x, y, "#8a4f2a") end end
end
local hoop1 = c:rect(14, 29, 51, 32):clip(body)
local hoop2 = c:rect(14, 46, 51, 49):clip(body)
c:part(hoop1, iron, { light = body, contact = false })
c:part(hoop2, iron, { light = body, contact = false })
c:part(c:ellipse(32.5, 22, 18, 5.5), GV.ramp("#8c4a1a"), { gloss = false })
c:part(c:ellipse(32.5, 22.5, 15, 4), "water", { gloss = false, contact = false })
c:paint({ "ww..www", "..ww..." }, 26, 21, { w = "#c8ecdc" })
c:part(c:rect(30, 48, 35, 52), iron, { flat = true })
c:part(c:rect(32, 53, 33, 54), GV.ramp("#a9d6ea"), { flat = true })
-- moss
local m1 = c:ellipse(20, 19.5, 5, 3.5):add(c:ellipse(16.5, 23, 3, 3)):add(c:rect(16, 24, 18, 36)):add(c:ellipse(17,37,1.5,1.5))
local m2 = c:ellipse(44, 21, 5.5, 3.5):add(c:ellipse(48, 24, 3, 3)):add(c:rect(47, 25, 49, 40))
local m3 = c:ellipse(32.5, 17.5, 4, 2.5)
local mb = c:ellipse(23, 54, 6, 2.5):add(c:ellipse(40, 54.5, 5, 2))
c:part(m1, "moss"); c:part(m2, "moss"); c:part(m3, GV.ramp("#58a03e"), { gloss = false })
c:part(mb, GV.ramp("#58a03e"))
c:spot(c:rect(19, 18, 20, 18), "#c8d77a"); c:spot(c:rect(42, 20, 43, 20), "#c8d77a")
c:ground(32.5, 56, 19, 1)
local t = c:save(O .. "aseprite/ph/rain_barrel-mossy.aseprite", O .. "png/ph/rain_barrel-mossy.png")
print(GV.report(t))
