local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- seed: pill rotated -35 deg centred (32,24)
local a = math.rad(-35); local ca, sa = math.cos(a), math.sin(a)
local seed = c:mask()
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x + 0.5 - 32, y + 0.5 - 25
  local u = dx*ca + dy*sa; local v = -dx*sa + dy*ca
  local hu = 20; local r = 6
  local cu = math.max(-hu+r, math.min(hu-r, u))
  if (u-cu)^2 + v^2 <= r*r then seed:set(x, y) end
end end
-- tip: upper-right end region
local tip = c:mask()
seed:each(function(x, y)
  local dx, dy = x + 0.5 - 32, y + 0.5 - 25
  if dx*ca + dy*sa > 13 then tip:set(x, y) end
end)
seed:cut(tip)
local planks = c:rect(13,30,51,35):add(c:rect(13,38,51,43)):add(c:rect(13,46,51,51))
local posts = c:rect(11,27,17,53):add(c:rect(47,27,53,53))
local brace = c:line({ {18,31}, {46,50} }, 2):add(c:line({ {18,50}, {46,31} }, 2)):clip(planks)
local p = c:build{
  { "back", c:rect(13,26,51,52), GV.ramp("#5e2f1e") },
  { "seed", seed, "gold" },
  { "tip", tip, GV.ramp("#4a8a3e"), { gloss = false } },
  { "planks", planks, "wood" },
  { "posts", posts, GV.ramp("#a8582f") },
}
c:fill(brace, "#8a4f2a")
-- stripe on seed (lower side)
seed:each(function(x, y)
  local dx, dy = x + 0.5 - 32, y + 0.5 - 25
  local v = -dx*sa + dy*ca
  if v > 1 and v <= 2.2 and y < 30 then c:px(x, y, "#b8661a") end
end)
c:paint({ "gg", "gG" }, 13, 28, { g = "#f5cf6a", G = "#e8a317" })
c:paint({ "gg", "gG" }, 49, 28, { g = "#f5cf6a", G = "#e8a317" })
c:ground(31.5, 55, 22, 1.5)
local t = c:save(O .. "aseprite/ph/fennel-seed.aseprite", O .. "png/ph/fennel-seed.png")
print(GV.report(t))
