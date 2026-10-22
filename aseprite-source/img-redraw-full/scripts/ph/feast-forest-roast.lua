local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function star(cx, cy, ro, ri)
  local p = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local r = (i % 2 == 0) and ro or ri
    p[#p + 1] = { math.floor(cx + r * math.cos(a) + 0.5), math.floor(cy + r * math.sin(a) + 0.5) }
  end
  return c:poly(p)
end
local mound = c:ellipse(31.5, 39, 16, 13):cut(c:rect(0, 46, 63, 63))
c:build{
  { "rim", c:ellipse(31.5, 45, 24, 8), "#d6c9b6" },
  { "well", c:ellipse(31.5, 43.5, 19, 5.5), "#f4f0e0", { gloss = false } },
  { "mound", mound, GV.ramp("#b0bc66") },
  { "herb1", c:ellipse(23, 37, 4, 4), "#58a03e" },
  { "herb2", c:ellipse(39, 35, 4.5, 4.5), "moss" },
  { "knob", c:ellipse(31.5, 28, 3, 3), "gold", { flat = true } },
  { "star", star(31.5, 16, 8, 3.5), "gold" },
}
c:ground(31.5, 53, 20, 1.5)
local t = c:save(O .. "aseprite/ph/feast-forest-roast.aseprite", O .. "png/ph/feast-forest-roast.png")
print(GV.report(t))
