local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pointed blade: lens shape from pivot outward, rotated deg (0 = up, + = clockwise)
local function blade(px, py, len, half, deg, off)
  local a = math.rad(deg); local pts = {}
  local function put(u, v) -- u along blade, v across
    pts[#pts + 1] = { px + v * math.cos(a) + u * math.sin(a) + 0.5, py + v * math.sin(a) - u * math.cos(a) + 0.5 }
  end
  local n = 14
  for i = 0, n do local u = off + (len - off) * i / n; put(u, half * math.sin(math.pi * i / n) ^ 0.7) end
  for i = n, 0, -1 do local u = off + (len - off) * i / n; put(u, -half * math.sin(math.pi * i / n) ^ 0.7) end
  return c:poly(pts)
end

local moss = GV.ramp("#7ab55c")
local mid = GV.ramp("#58a03e")
c:build{
  { "stem", c:rect(30, 34, 33, 56), GV.ramp("#2e5a2c") },
  { "outerL", blade(32, 34, 24, 5, -70, 2), moss },
  { "outerR", blade(32, 34, 24, 5, 70, 2), moss },
  { "midL", blade(32, 34, 28, 5, -35, 2), moss },
  { "midR", blade(32, 34, 28, 5, 35, 2), moss },
  { "centre", blade(32, 34, 30, 5, 0, 2), mid },
  { "knot", c:ellipse(32, 33, 5), "gold" },
}

local t = c:save(O .. "aseprite/ph/cattail-root.aseprite", O .. "png/ph/cattail-root.png")
print(GV.report(t))
