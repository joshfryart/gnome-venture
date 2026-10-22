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
local cover = c:rrect(14, 9, 47, 50, 4):add(c:rect(14, 9, 20, 50))
c:build{
  { "pages", c:rrect(18, 12, 50, 53, 2), "#f4f0e0", { gloss = false } },
  { "cover", cover, "water" },
  { "spine", c:rrect(11, 9, 18, 50, 2), "#2f6290", { gloss = false } },
  { "label", c:rrect(23, 15, 42, 28, 3), "#f4f0e0" },
  { "star", star(36.5, 41, 7, 3), "gold" },
}
c:seam({ { 18, 11 }, { 18, 49 } })
c:fill(c:rect(27, 20, 39, 21), "#2a1a10")
c:fill(c:rect(27, 24, 35, 25), "#2a1a10")
local t = c:save(O .. "aseprite/ph/guide-ea.aseprite", O .. "png/ph/guide-ea.png")
print(GV.report(t))
