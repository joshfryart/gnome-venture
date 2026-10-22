local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leafL = c:poly({{31,23},{25,18},{23,13},{25,9},{29,10},{32,15},{34,23}})
local leafR = c:poly({{30,23},{32,15},{36,10},{40,9},{42,13},{39,18},{34,23}})
local bulb = c:ellipse(32, 32, 14, 12)
bulb:add(c:poly({{21,38},{44,38},{34,50},{31,50}}))
bulb:add(c:line({{32,48},{32,53}}, 2))
local p = c:build{
  { "leafL", leafL, GV.ramp("#58a03e"), { gloss = {26,12} } },
  { "leafR", leafR, GV.ramp("#4f9638"), { gloss = {37,12} } },
  { "bulb", bulb, GV.ramp("#f1ece0"), { gloss = {24,28} } },
}
-- pink ring stripes, curved, inset from the body edge
local inner = bulb:shrink(2)
local b1 = c:ellipse(32, 12, 20, 18):cut(c:ellipse(32, 12, 20, 15)):clip(inner)
local b2 = c:ellipse(32, 18, 18, 22):cut(c:ellipse(32, 18, 18, 19)):clip(inner)
local function band(m)
  m:each(function(x, y)
    if (x - 32) + (y - 33) > 8 then c:px(x, y, "#b84a7e") else c:px(x, y, "#e46a9b") end
  end)
end
band(b1); band(b2)
local t = c:save(B .. "aseprite/ph/turnip.aseprite", B .. "png/ph/turnip.png")
print(GV.report(t))
