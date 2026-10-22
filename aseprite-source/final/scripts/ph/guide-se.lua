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

local ribbon = c:rect(33, 48, 35, 54)
ribbon:add(c:poly({ {33, 54}, {36, 54}, {36, 57}, {34.5, 55.5}, {33, 57} }))
local cover = c:rrect(15, 6, 51, 52, 4)
local spine = c:rrect(10, 6, 17, 52, 2)
local label = c:rrect(22, 13, 45, 27, 3)
local st = star(42, 43, 8.5, 3.8)

local p = c:build{
  { "ribbon", ribbon, "red", { flat = true } },
  { "cover", cover, GV.ramp("#d0862a") },
  { "spine", spine, GV.ramp("#7a4a1f") },
  { "label", label, GV.ramp("#f4f0e0"), { gloss = false } },
  { "star", st, GV.ramp("#f5cf6a", { shade = "#e8a317" }) },
}

-- edge stitch on the cover shaded side
c:stitch(p.cover.m, { side = "shade" })
-- abstract label lines
c:fill(c:rect(26, 18, 41, 19), "#4a2c1a")
c:fill(c:rect(26, 22, 35, 23), "#4a2c1a")
-- spine seam + button
c:seam({ {18, 12}, {18, 49} })
c:button(19, 8)

local t = c:save(O .. "aseprite/ph/guide-se.aseprite", O .. "png/ph/guide-se.png")
print(GV.report(t))
