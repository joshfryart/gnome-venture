-- silver-birch (lean E2_07)
local NAME = "silver-birch"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, ramp, R, name, amb, wrap)
  local n = X.pillow(m, R)
  local tok = { r = { name = name } }
  X.tone(c, m, X.light(n, { amb = amb or 0.08, wrap = wrap or 0.25 }), ramp, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.87 }, tok = tok })
  return n, tok
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
-- quirk: a curl of peeling white bark unrolling off the trunk, with a few black chevron marks
c:groundShadow(30, 56, 17, 3)
local trunk = c:poly({{20,56},{22,20},{40,16},{43,56}})
local tn, ttok = shade(c, trunk, { "#6a6880", "#8d8ba2", "#b4b2c6", "#d4d2e0", "#ebe9f2", "#f6f3e8" }, 11, "trunk", 0.08, 0.2)
-- horizontal lenticel dashes (black bark scars)
for _, r in ipairs{ {26,33,"#2b1c26"}, {32,29,"#2b1c26"}, {24,39,"#3a3248"}, {31,43,"#2b1c26"}, {27,48,"#3a3248"}, {35,51,"#2b1c26"}, {33,35,"#3a3248"} } do
  local y, x0 = r[1], r[2]
  for x = x0, x0 + 4 do if trunk:has(x, y) then c:put(x, y, r[3], ttok) end end
  for x = x0 + 1, x0 + 3 do if trunk:has(x, y + 1) then c:put(x, y + 1, "#6a6880", ttok) end end
end
-- cut top: tan rings ellipse
local top = c:ellipse(31, 18, 10, 4)
shade(c, top, { "#a8743c", "#c9954e", "#e0b26a", "#efc984", "#f6dca0", "#fbeab8" }, 6, "top", 0.1, 0.2)
for _, rr in ipairs{ {7,2.6}, {4,1.6} } do
  c:ellipse(31, 18, rr[1], rr[2]):edge():each(function(x, y) if top:has(x, y) then c:put(x, y, "#a8743c", { r = { name = "ring" } }) end end)
end
c:put(31, 18, "#7a4a28")
-- peeling bark curl on the right
local curl = c:line({{40,28},{46,30},{49,36},{47,41},{44,40}}, 2)
shade(c, curl, { "#8d8ba2", "#b4b2c6", "#d4d2e0", "#ebe9f2", "#f6f3e8", "#fbf8ee" }, 2, "curl", 0.15, 0.3)
c:put(44, 40, "#6a6880") c:put(45, 41, "#6a6880")
-- twig with heart leaves, golden-green
local twig = c:line({{21,36},{14,32},{9,26}}, 1)
twig:each(function(x, y) c:put(x, y, "#6a3f2c", { r = { name = "twig" } }) end)
local function leaf(cx, cy, a)
  local m = HP.mask()
  for y = cy - 5, cy + 5 do for x = cx - 5, cx + 5 do
    local dx, dy = x - cx, y - cy
    local u = (dx * cos(a) + dy * sin(a)) / 4.2
    local v = (-dx * sin(a) + dy * cos(a))
    if u > -1 and u < 1 then
      local hw = 3.1 * sqrt(max(0, 1 - u * u)) * (1.1 - 0.5 * u)
      if abs(v) <= hw then m:set(x, y) end
    end
  end end
  shade(c, m, { "#3a5a22", "#4f7a2a", "#6f9a32", "#92b83e", "#b8d450", "#e0ec7a" }, 2.6, "bl" .. cx .. cy, 0.1, 0.25)
  c:put(floor(cx + cos(a) * 1), floor(cy + sin(a) * 1), "#e0ec7a")
end
leaf(8, 21, -1.6) leaf(14, 26, -0.9) leaf(10, 33, 2.9) leaf(17, 30, -2.2)
c:sparkle(36, 24)
G.save(c, NAME)
