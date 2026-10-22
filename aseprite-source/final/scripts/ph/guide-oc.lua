local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function star(cx, cy, r)
  local pts = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local rr = (i % 2 == 0) and r or r * 0.45
    pts[#pts + 1] = { cx + rr * math.cos(a), cy + rr * math.sin(a) }
  end
  return c:poly(pts)
end

local cover = c:rrect(14, 11, 51, 52, 4)
c:build{
  { "cover", cover, GV.ramp("#7a5cc0", { gloss = "#a894dc" }), { gloss = { 24, 34 } } },
  { "spine", c:rrect(11, 11, 17, 52, 2), "dusk", { gloss = false } },
  { "label", c:rrect(22, 16, 45, 29, 3), GV.ramp("#f4f0e0") },
  { "star", star(40.5, 43, 7.5), GV.ramp("#f5cf6a") },
}
c:fill(c:rect(26, 21, 41, 22), "#3e2f66")
c:fill(c:rect(26, 25, 37, 26), "#3e2f66")
c:seam({ {19, 18}, {19, 50} })
c:button(18, 13)
local t = c:save(O .. "aseprite/ph/guide-oc.aseprite", O .. "png/ph/guide-oc.png")
print(GV.report(t))
