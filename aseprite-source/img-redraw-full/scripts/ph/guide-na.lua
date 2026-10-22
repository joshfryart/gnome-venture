local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function star(cx, cy, r, ri)
  local pts = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local rr = (i % 2 == 0) and r or ri
    pts[#pts + 1] = { cx + rr * math.cos(a), cy + rr * math.sin(a) }
  end
  return c:poly(pts)
end

local coverR = GV.ramp("#7a5cc0", { gloss = "#a894dc", shade = "#291d4a" })
c:build{
  { "spine", c:rrect(10, 8, 18, 56, 2), GV.ramp("#3e2f66", { gloss = "#7b66b4" }), { gloss = false } },
  { "cover", c:rrect(15, 8, 52, 56, 4), coverR, { stitch = { side = "lit" } } },
  { "plaque", c:rrect(23, 16, 46, 31, 3), GV.ramp("#f4f0e0"), { pale = true } },
  { "star", star(40, 46, 7, 3), GV.ramp("#f5cf6a"), { cres = 2 } },
}
-- scribble lines on the plaque
c:fill(c:rect(27, 22, 42, 23), "#2a1a10")
c:fill(c:rect(27, 26, 36, 27), "#2a1a10")
-- spine seam and bands
c:seam({ { 17, 10 }, { 17, 54 } }, { free = true })
c:fill(c:rect(11, 14, 15, 15), "#7b66b4")
c:fill(c:rect(11, 49, 15, 50), "#7b66b4")
c:button(33, 13)
local t = c:save(O .. "aseprite/ph/guide-na.aseprite", O .. "png/ph/guide-na.png")
print(GV.report(t))
