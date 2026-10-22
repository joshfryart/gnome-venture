-- ph/guide-csa : blue region guidebook with cream label and gold star badge
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function star(cx, cy, ro, ri)
  local pts = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local r = (i % 2 == 0) and ro or ri
    pts[#pts + 1] = { cx + r * math.cos(a), cy + r * math.sin(a) }
  end
  return c:poly(pts)
end

local cover = c:rrect(14, 8, 52, 56, 4):add(c:rect(14, 8, 18, 56))
c:build{
  { "spine", c:rrect(10, 8, 17, 56, 2), GV.ramp("#2f6290"), { gloss = false } },
  { "cover", cover, "water", { gloss = { 20, 11 } } },
  { "label", c:rrect(22, 15, 46, 30, 3), "#f4f0e0", { pale = true, gloss = false, contact = false } },
  { "star", star(41.5, 46.5, 9, 4), "gold", { gloss = { 39, 42 } } },
}
-- label lines
c:fill(c:rect(26, 21, 42, 22), "#2a1a10")
c:fill(c:rect(26, 25, 36, 26), "#2a1a10")
-- spine seam
c:seam({ {16, 12}, {16, 52} }, { free = true })

local t = c:save(O .. "aseprite/ph/guide-csa.aseprite", O .. "png/ph/guide-csa.png")
print(GV.report(t))
