local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function star(cx, cy, R, r)
  local pts = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local rr = (i % 2 == 0) and R or r
    pts[#pts + 1] = { cx + rr * math.cos(a), cy + rr * math.sin(a) }
  end
  return c:poly(pts)
end
local cover = c:rrect(14, 8, 51, 55, 4):add(c:rect(14, 8, 20, 55))
local p = c:build{
  { "pages", c:rrect(16, 10, 53, 57, 3), GV.ramp("#f1ece0"), { flat = true } },
  { "cover", cover, GV.ramp("#c88a1c") },
  { "spine", c:rrect(10, 8, 16, 55, 2), GV.ramp("#5e2f1e"), { gloss = false } },
  { "label", c:rrect(23, 15, 46, 30, 3), GV.ramp("#f4f0e0") },
  { "star", star(41.5, 45, 8, 3.8), GV.ramp("#f5cf6a") },
}
c:fill(c:rect(27, 21, 42, 22), "#4a2c1a")
c:fill(c:rect(27, 25, 36, 26), "#4a2c1a")
c:seam({ {19, 13}, {19, 52} })
c:button(11, 10)
local t = c:save(O .. "aseprite/ph/guide-cb.aseprite", O .. "png/ph/guide-cb.png")
print(GV.report(t))
