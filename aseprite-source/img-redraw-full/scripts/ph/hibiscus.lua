local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cx, cy = 31.5, 37
-- five rounded petals around the centre
local bloom = c:ellipse(cx, cy, 9, 9)
local tips = {}
for i = 0, 4 do
  local a = -math.pi / 2 + i * 2 * math.pi / 5
  local px, py = cx + math.cos(a) * 10, cy + math.sin(a) * 10
  bloom:add(c:ellipse(px, py, 8, 8))
  tips[#tips + 1] = { a = a }
end
local leaf = c:poly({ {33,20}, {35,13}, {39,8}, {44,5}, {45,10}, {42,16}, {37,20} })
local stem = c:rect(31, 15, 33, 22)
local p = c:build{
  { "stem", stem, "#2f5a2a", { flat = true } },
  { "leaf", leaf, GV.ramp("#58a03e"), { gloss = false } },
  { "bloom", bloom, "petal", { gloss = { 23, 27 } } },
}
-- petal notch lines between petals (from throat outward)
for i = 0, 4 do
  local a = -math.pi / 2 + (i + 0.5) * 2 * math.pi / 5
  c:fill(c:line({ { math.floor(cx + math.cos(a) * 6 + 0.5), math.floor(cy + math.sin(a) * 6 + 0.5) },
                  { math.floor(cx + math.cos(a) * 14 + 0.5), math.floor(cy + math.sin(a) * 14 + 0.5) } }, 1), "#c0447a")
end
-- leaf vein
c:fill(c:line({ {35, 19}, {42, 9} }, 1), "#2f5a2a")
-- throat
c:fill(c:ellipse(cx, cy, 5, 5), "#ae2a2a")
c:fill(c:ellipse(cx, cy, 2.5, 2.5), "#6b1b2c")
-- stamen
c:fill(c:line({ {32, 37}, {35, 33}, {37, 30} }, 2), "#e8a317")
c:fill(c:rrect(36, 27, 39, 30, 1), "#f5cf6a")
c:px(36, 27, "#fff1c8"); c:px(39, 30, "#b8661a")
c:px(35, 29, "#f5cf6a"); c:px(40, 28, "#f5cf6a")
local t = c:save(O .. "aseprite/ph/hibiscus.aseprite", O .. "png/ph/hibiscus.png")
print(GV.report(t))
