local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function star(cx, cy, ro, ri)
  local pts = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local r = (i % 2 == 0) and ro or ri
    pts[#pts + 1] = { cx + r * math.cos(a) + 0.5, cy + r * math.sin(a) + 0.5 }
  end
  return c:poly(pts)
end

local rim = c:ellipse(31.5, 45, 22, 8)
local well = c:ellipse(31.5, 43.5, 17, 5.5)
-- golden mound: dome with a flat bottom
local mound = c:ellipse(31.5, 40, 16, 15):cut(c:rect(0, 43, 63, 63))
local p = c:build{
  { "rim", rim, "#d6c9b6" },
  { "well", well, "#f4f0e0", { gloss = false } },
  { "mound", mound, "gold" },
  { "fruitL", c:ellipse(24, 36, 4, 4), GV.ramp("#e8a317", { base = "#d0862a" }), { gloss = { 22, 34 } } },
  { "fruitR", c:ellipse(39.5, 35, 4.5, 4.5), "moss", { gloss = { 37, 32 } } },
  { "fruitT", c:ellipse(31.5, 29, 3.5, 3.5), GV.ramp("#e8a317", { base = "#d0862a" }), { gloss = false } },
  { "star", star(31.5, 18, 7, 3.2), GV.ramp("#e8a317"), { gloss = false } },
}
c:px(30, 27, "#fff1c8")
c:px(29, 16, "#fff1c8"); c:px(30, 15, "#fff1c8")
c:seam({ {12, 47}, {51, 47} })
local t = c:save(O .. "aseprite/ph/feast-maizehollow-mole.aseprite", O .. "png/ph/feast-maizehollow-mole.png")
print(GV.report(t))
