local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- axis from (11,40) toward upper right
local ax, ay = 11, 40
local L = math.sqrt(42*42 + 25*25)
local ux, uy = 42 / L, -25 / L
local nx, ny = -uy, ux
local function P(t, s) return ax + ux * t + nx * s, ay + uy * t + ny * s end
local function seg(t0, t1, h0, h1)
  local a = { P(t0, -h0) }; local b = { P(t1, -h1) }; local d = { P(t1, h1) }; local e = { P(t0, h0) }
  return c:poly({ a, b, d, e })
end
local function oval(tc, ra, rb)
  local pts = {}
  for i = 0, 23 do
    local ang = i / 24 * math.pi * 2
    pts[#pts + 1] = { P(tc + math.cos(ang) * ra, math.sin(ang) * rb) }
  end
  return c:poly(pts)
end

local legs = c:line({ {31, 33}, {21, 54} }, 4):add(c:line({ {32, 33}, {43, 54} }, 4))
local mount = c:rrect(27, 29, 36, 35, 2)
local eye   = seg(0, 8, 2.5, 2.5)
local mid1  = seg(7, 19, 4, 4)
local mid2  = seg(18, 31, 5.5, 5.5)
local obj   = seg(30, 42, 7, 7.5)
local lens  = oval(42.5, 2.5, 6.5)

local p = c:build{
  { "legs",  legs,  GV.ramp("#c4925f") },
  { "mount", mount, "wood" },
  { "eye",   eye,   GV.ramp("#b8661a"), { gloss = false } },
  { "mid1",  mid1,  "gold" },
  { "mid2",  mid2,  GV.ramp("#d49a3a") },
  { "obj",   obj,   GV.ramp("#c08a4a") },
  { "lens",  lens,  "water" },
}

local function ring(t, h)
  local x0, y0 = P(t, -h + 1); local x1, y1 = P(t, h - 1)
  c:seam({ { math.floor(x0 + 0.5), math.floor(y0 + 0.5) }, { math.floor(x1 + 0.5), math.floor(y1 + 0.5) } })
end
ring(16.5, 4); ring(28.5, 5.5); ring(39.5, 7.2)

local t = c:save(R .. "img-redraw-full/aseprite/ico/ico-telescope.aseprite", R .. "img-redraw-full/png/ico/ico-telescope.png")
print(GV.report(t))
