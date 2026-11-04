-- spotted-hide (lean D2o_5)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "spotted-hide" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local function tshade(m, n, ramp, o) o = o or {}
  local v = X.light(n, { amb = o.amb or 0.12, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return v
end
local HIDE = { "#5a3320", "#8a5530", "#b87a40", "#d9a35c", "#efc983", "#fbe6b0" }
local body = c:ellipse(32, 33, 11, 14)
body:add(G.rell(18, 19, -0.71, -0.71, 9, 4.8)):add(G.rell(46, 19, 0.71, -0.71, 9, 4.8))
body:add(G.rell(18, 47, -0.71, 0.71, 9, 4.8)):add(G.rell(46, 47, 0.71, 0.71, 9, 4.8))
body:add(G.rell(32, 14, 0, -1, 7, 4.2)):add(G.rell(32, 52, 0, 1, 7, 2.2))
-- ragged torn edge
local nib = HP.mask()
body:edge():each(function(x, y) if X.hash(x, y, 9) > 0.8 then nib:set(x, y) end end)
body:cut(nib)
local bias = {}
X.ao(bias, body, c:ellipse(32, 33, 4, 5), 3, -1)
shade(body, HIDE, 8, { bias = bias })
-- hem: lit upper-left, shaded lower-right
local inner = body:copy():shrink(1)
body:each(function(x, y) if not inner:has(x, y) then c:px(x, y, (x + y < 64) and HIDE[5] or HIDE[2]) end end)
-- fur grain flecks
body:each(function(x, y) if inner:has(x, y) and X.hash(x, y, 3) > 0.93 then c:px(x, y, HIDE[4]) end end)
-- spots
local spots = { {28,24,2.4}, {38,30,2.8}, {27,38,2.2}, {36,42,2.4}, {32,33,1.5}, {17,17,1.8}, {47,17,1.8}, {17,48,1.8}, {47,46,2}, {32,12,1.5}, {43,23,1.4}, {23,31,1.3} }
for _, s in ipairs(spots) do
  local sm = c:ellipse(s[1], s[2], s[3], s[3] * 0.85):clip(inner)
  sm:each(function(x, y) c:px(x, y, "#3a2018") end)
  sm:each(function(x, y) if x >= s[1] and y >= s[2] then c:px(x, y, "#24130f") end end)
  if sm:has(floor(s[1] - 1), floor(s[2] - 1)) then c:px(floor(s[1] - 1), floor(s[2] - 1), "#6e4a34") end
end
-- quirk: a crude stitched repair seam on the right hind flap
for i = 0, 5 do local x, y = 38 + i * 1.6, 41 + i * 1.7
  c:px(floor(x), floor(y), "#2b1c26") c:px(floor(x) + 1, floor(y) - 1, HIDE[1]) end
-- tail tuft + eye-hole nicks on head flap
c:px(32, 57, "#3a2018") c:px(31, 56, "#3a2018") c:px(33, 56, "#3a2018")
c:px(30, 11, "#24130f") c:px(34, 11, "#24130f")
G.fin(c, "spotted-hide")
