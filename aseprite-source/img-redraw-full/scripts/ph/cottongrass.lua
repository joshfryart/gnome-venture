local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local px, py = 32, 33
-- pointed leaf from pivot, angle deg from vertical, length L, half-width w
local function leaf(deg, L, w)
  local a = math.rad(deg)
  local dx, dy = math.sin(a), -math.cos(a)
  local nx, ny = -dy, dx
  local pts, back = {}, {}
  local N = 14
  for i = 0, N do
    local t = i / N
    local hw = w * math.sin(math.pi * (0.15 + 0.85 * t)) ^ 0.8
    if i == N then hw = 0 end
    local cx, cy = px + dx * L * t, py + dy * L * t
    pts[#pts+1] = { cx + nx * hw, cy + ny * hw }
    table.insert(back, 1, { cx - nx * hw, cy - ny * hw })
  end
  for _, p in ipairs(back) do pts[#pts+1] = p end
  return c:poly(pts)
end
local moss = "moss"
local mid = GV.ramp("#58a03e")
c:build{
  { "stem", c:rrect(30, 34, 33, 56, 1), GV.ramp("#2e5a2c"), { flat = true } },
  { "l70", leaf(-68, 23, 4.5), moss },
  { "r70", leaf(68, 23, 4.5), moss },
  { "l35", leaf(-34, 26, 4.5), moss },
  { "r35", leaf(34, 26, 4.5), moss },
  { "mid", leaf(0, 28, 5), mid },
  { "hub", c:ellipse(31.5, 33.5, 4.5, 4.5), GV.ramp("#7a5cc0") },
}
c:ground(31.5, 57, 8, 1.5)
local t = c:save(O .. "aseprite/ph/cottongrass.aseprite", O .. "png/ph/cottongrass.png")
print(GV.report(t))
