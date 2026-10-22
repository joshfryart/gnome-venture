local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cx, cy = 31.5, 31.5
local function arc(a0, a1)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, cy - y
    local r = math.sqrt(dx*dx + dy*dy)
    if r >= 12.5 and r <= 19.5 then
      local a = math.deg(math.atan(dy, dx)) % 360
      if a >= a0 and a <= a1 then m:set(x, y) end
    end
  end end
  return m
end
local function P(a, r) return { cx + r*math.cos(math.rad(a)), cy - r*math.sin(math.rad(a)) } end
-- upper arc: 20..165 deg, head at the right end pointing clockwise (down)
local up = arc(20, 168)
up:add(c:poly({ P(22, 7), P(22, 26), P(-22, 16) }))
-- lower arc: rotated 180
local lo = arc(200, 348)
lo:add(c:poly({ P(202, 7), P(202, 26), P(158, 16) }))
local g = GV.ramp("#58a03e")
c:build{
  { "upper", up, g },
  { "lower", lo, g, { gloss = false } },
}
local t = c:save(O .. "aseprite/ico/ico-refresh.aseprite", O .. "png/ico/ico-refresh.png")
print(GV.report(t))
