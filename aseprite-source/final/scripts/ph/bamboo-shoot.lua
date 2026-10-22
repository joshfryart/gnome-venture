local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local ax, ay, bx, by = 17, 45, 52, 21          -- base (lower-left) to tip (upper-right)
local len = math.sqrt((bx-ax)^2 + (by-ay)^2)
local ux, uy = (bx-ax)/len, (by-ay)/len
local function cone(t0, t1, r0, r1, side)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x + 0.5 - ax, y + 0.5 - ay
    local a = (dx*ux + dy*uy) / len
    local b = -dx*uy + dy*ux
    local ac = math.max(0, math.min(1, a))
    local r = r0 + (r1 - r0) * ac
    local px, py = dx - ac*len*ux, dy - ac*len*uy
    if a >= t0 and a <= t1 and math.sqrt(px*px + py*py) <= r and (not side or side(b, r)) then m:set(x, y) end
  end end
  return m
end
local body = cone(0.08, 1.2, 9, 1.5)
local tip = cone(0.68, 1.2, 9, 1.5)
local base = cone(-0.2, 0.12, 9, 1.5)
local lower = cone(0.12, 0.68, 9, 1.5, function(b, r) return b > r * 0.35 end)
local p = c:build{
  { "body", body:copy():cut(tip):cut(lower), GV.ramp("#b0bc66"), { light = body } },
  { "lower", lower, GV.ramp("#58a03e"), { light = body, gloss = false } },
  { "tip", tip, GV.ramp("#7ab55c"), { light = body, gloss = false } },
  { "base", base, GV.ramp("#2e5a2c"), { light = body, gloss = false } },
}
-- band line across the body at ~1/3 (2/3 is the tip join)
local function across(t, w)
  local mx, my = ax + ux*len*t, ay + uy*len*t
  return c:line({ { math.floor(mx - uy*-11 + 0.5), math.floor(my + ux*-11 + 0.5) }, { math.floor(mx - uy*11 + 0.5), math.floor(my + ux*11 + 0.5) } }, w)
end
local band = across(0.4, 2):clip(body)
c:fill(band, "#4a8a3e")
c:seam({ { math.floor(ax + ux*len*0.4 + uy*9), math.floor(ay + uy*len*0.4 - ux*9) },
         { math.floor(ax + ux*len*0.4 - uy*9), math.floor(ay + uy*len*0.4 + ux*9) } })
-- cut face dot on the base
c:paint({ "gg", "gg" }, 14, 44, { g = "#d9a660" })
local t = c:save(O .. "aseprite/ph/bamboo-shoot.aseprite", O .. "png/ph/bamboo-shoot.png")
print(GV.report(t))
