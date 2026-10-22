local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bx, by = 32, 36
-- pointed oval leaf from base toward angle (deg from vertical), length L, half-width W
local function leaf(ang, L, W)
  local a = math.rad(ang)
  local dx, dy = math.sin(a), -math.cos(a)
  local nx, ny = -dy, dx
  local pts, N = {}, 16
  for i = 0, N do
    local t = i / N
    local w = W * math.sin(math.pi * t) ^ 0.8
    pts[#pts+1] = { bx + dx*L*t + nx*w, by + dy*L*t + ny*w }
  end
  for i = N, 0, -1 do
    local t = i / N
    local w = W * math.sin(math.pi * t) ^ 0.8
    pts[#pts+1] = { bx + dx*L*t - nx*w, by + dy*L*t - ny*w }
  end
  return c:poly(pts)
end
local moss = GV.ramp("#7ab55c", { gloss = "#c8d77a", shade = "#4a8a3e" })
local sage = GV.ramp("#8fb36a", { gloss = "#d8e09a", shade = "#5a8a48" })
local all = leaf(-70,25,5.5):add(leaf(70,25,5.5)):add(leaf(-35,27,6)):add(leaf(35,27,6)):add(leaf(0,28,6))
local p = c:build{
  { "stem", c:rrect(30, 36, 34, 55, 1), GV.ramp("#4a8a3e"), { gloss = false } },
  { "oL", leaf(-70, 25, 5.5), sage, { light = all } },
  { "oR", leaf(70, 25, 5.5), sage, { light = all } },
  { "mL", leaf(-35, 27, 6), moss, { light = all } },
  { "mR", leaf(35, 27, 6), moss, { light = all } },
  { "cL", leaf(0, 28, 6.5), GV.ramp("#58a03e", { gloss = "#c8d77a" }), { light = all } },
  { "bead", c:ellipse(32, 35, 4, 4), GV.ramp("#b0bc66") },
}
-- leaf midribs
local function rib(ang, L)
  local a = math.rad(ang)
  c:seam({ { bx + math.sin(a)*7, by - math.cos(a)*7 }, { bx + math.sin(a)*(L-6), by - math.cos(a)*(L-6) } }, { on = 2, off = 1 })
end
rib(-70, 25); rib(70, 25); rib(-35, 27); rib(35, 27); rib(0, 28)
c:ground(32, 57, 12, 1.5)
local t = c:save(O .. "aseprite/ph/desert-sage.aseprite", O .. "png/ph/desert-sage.png")
print(GV.report(t))
