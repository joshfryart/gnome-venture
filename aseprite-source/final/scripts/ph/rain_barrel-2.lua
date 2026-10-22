local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pipe = GV.ramp("#968f96")
local iron = GV.ramp("#6a6070")
local spout = c:rrect(7, 6, 12, 23, 2):add(c:rrect(7, 18, 22, 23, 2))
local p = c:build{
  { "pole", c:rect(47, 11, 48, 24), "#44281c", { flat = true } },
  { "flag", c:poly({ { 49, 11 }, { 58, 15 }, { 49, 19 } }), GV.ramp("#d6322b"), { gloss = false } },
  { "body", c:rrect(14, 21, 49, 55, 8), GV.ramp("#a5663a") },
  { "hoop1", c:rect(14, 29, 49, 32):clip(c:rrect(14, 21, 49, 55, 8)), iron, { gloss = false } },
  { "hoop2", c:rect(14, 45, 49, 48):clip(c:rrect(14, 21, 49, 55, 8)), iron, { gloss = false } },
  { "rim", c:ellipse(31.5, 21, 18, 5.5), GV.ramp("#8c4a1a"), { gloss = false } },
  { "water", c:ellipse(31.5, 21.5, 14.5, 3.5), "water", { gloss = { 22, 20 } } },
  { "spout", spout, pipe, { gloss = { 9, 9 } } },
  { "tap", c:rect(29, 50, 34, 52), iron, { flat = true } },
}
-- stave lines between hoops
for _, x in ipairs({ 23, 32, 41 }) do
  for y = 27, 53 do
    local m = p.body.m
    if m:has(x, y) and not p.hoop1.m:has(x, y) and not p.hoop2.m:has(x, y) and not p.tap.m:has(x, y) then
      c:px(x, y, "#5e2f1e")
    end
  end
end
-- ripple and pouring stream
c:paint({ "ww..www..ww" }, 26, 22, { w = "#a9d6ea" })
c:paint({ "w", "w" }, 20, 24, { w = "#a9d6ea" })
c:px(31, 53, "#a9d6ea"); c:px(32, 54, "#a9d6ea")
c:seam({ { 18, 54 }, { 46, 54 } })
c:ground(31.5, 56, 17, 1.5)
local t = c:save(O .. "aseprite/ph/rain_barrel-2.aseprite", O .. "png/ph/rain_barrel-2.png")
print(GV.report(t))
