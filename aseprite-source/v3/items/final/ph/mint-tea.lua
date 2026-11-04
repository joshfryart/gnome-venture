-- mint-tea (final, Opus single pass). Slim tulip tea glass on a small glazed saucer: golden-green tea seen through
-- glass (bright left rim, darker right wall, pale empty core above the tea, lit meniscus), a gilt band with dots
-- below the lip, a fresh mint sprig standing in the glass (opposite pairs of oval, serrated leaves with midrib and
-- veins, 6-tone). Saucer with a dark well and contact shadow under the glass; ground shadow.
-- quirk: one mint leaf has dropped off onto the saucer.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_4.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs, sin, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.pi
local c = A.new("mint-tea")
local TEA  = { "#3e3410", "#625016", "#8a721e", "#b2962a", "#d4ba48", "#efdc84" }
local MINT = { "#163c2c", "#1f5a38", "#2c7a42", "#43994a", "#6cbc58", "#a6dc78" }
local DISH = { "#3a3a5e", "#56648a", "#7c98b2", "#a8c6cc", "#d2e6de", "#f2f8ec" }
local GOLD = { "#7a4a1e", "#c88a2a", "#f2c84a", "#fff0a8" }
local SPEC = "#fff4d6"

c:groundShadow(32, 56, 16, 1.5)

-- saucer
local sau = A.ell(32, 52, 15.5, 3.6)
local sbias = {}
local well = A.ell(32, 51.5, 7, 1.3)
well:each(function(x, y) sbias[K(x, y)] = -1 end)
local stok = { r = { name = "dish" } }
A.shade(c, sau, A.ellN(31, 50.5, 15.5, 4.6, sau, 2.6), DISH, { tok = stok, bias = sbias })
for x = 19, 27 do c:put(x, 50, DISH[6], stok) end -- lit rim
c:put(20, 50, SPEC, stok)

-- glass profile (tulip): half width by row
local CX = 31
local function gw(y)
  if y <= 26 then return 7.6 end
  if y <= 40 then return 7.6 - (y - 26) / 14 * 2.3 end
  return 5.3 + (y - 40) / 9 * 1.6
end
local glass = HP.mask()
for y = 22, 50 do local w = gw(y) for x = floor(CX - w + .5), floor(CX + w + .5) do glass:set(x, y) end end
local gtok = { r = { name = "glass" } }
local TOP = 28 -- tea surface
local gn = {}
glass:each(function(x, y) local w = gw(y)
  local t = max(-0.96, min(0.96, (x - CX) / (w + 0.5)))
  gn[K(x, y)] = { A.norm(t, -0.1, sqrt(1 - t*t)) } end)
local gv = X.light(gn, { amb = 0.1, wrap = 0.35 })
local tea = HP.mask() glass:each(function(x, y) if y >= TOP then tea:set(x, y) end end)
local tb = {}
tea:each(function(x, y) if y >= 47 then tb[K(x, y)] = -1 end end)
local tidx = X.tone(c, tea, gv, TEA, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = gtok, bias = tb })
-- transmitted glow: the light comes through to the lower-right inside
tea:each(function(x, y) local w = gw(y)
  local u = (x - CX) / w
  if u > 0.15 and u < 0.65 and y > 38 and y < 47 then c:put(x, y, TEA[5], gtok) end end)
-- meniscus
for x = floor(CX - gw(TOP) + 1.5), floor(CX + gw(TOP) - .5) do c:put(x, TOP, TEA[6], gtok) end
for x = floor(CX - gw(TOP + 1) + 1.5), floor(CX - gw(TOP + 1) + 5) do c:put(x, TOP + 1, TEA[5], gtok) end
-- empty glass above the tea: pale core
glass:each(function(x, y) if y < TOP then
  local w = gw(y) local u = (x - CX) / w
  c:put(x, y, u > 0.55 and "#9cc2b8" or (u < -0.75 and "#f4fbf0" or "#d8ece2"), gtok) end end)
-- gilt band with dots (below the lip)
for x = floor(CX - 7.6 + .5), floor(CX + 7.6 + .5) do
  local u = (x - CX) / 7.6
  c:put(x, 24, u > 0.5 and GOLD[1] or GOLD[2], gtok)
  c:put(x, 26, u > 0.5 and GOLD[1] or GOLD[2], gtok)
  c:put(x, 25, (x % 2 == 0) and (u > 0.5 and GOLD[2] or GOLD[3]) or (u > 0.5 and "#9cc2b8" or "#d8ece2"), gtok)
end
c:put(CX - 5, 24, GOLD[4], gtok) c:put(CX - 4, 24, GOLD[4], gtok)
-- glass walls: bright rim left, dark wall right
glass:each(function(x, y)
  local w = gw(y)
  local l, r = floor(CX - w + .5), floor(CX + w + .5)
  if x == l and y > 22 then c:put(x, y, y < TOP and SPEC or "#f4f0c8", gtok) end
  if x == r and y > 22 then c:put(x, y, y < TOP and "#6e9a92" or TEA[1], gtok) end
end)
for x = floor(CX - 7.6 + .5), floor(CX + 7.6 + .5) do c:put(x, 22, (x - CX) > 4 and "#9cc2b8" or "#f4fbf0", gtok) end -- lip
for y = 30, 37 do c:put(floor(CX - gw(y) + 2.5), y, "#f4f0c8", gtok) end -- pale streak
c:put(floor(CX - gw(31) + 2.5), 31, SPEC, gtok)
-- foot contact on saucer
for x = floor(CX - 5), floor(CX + 7) do c:put(x, 51, DISH[1], stok) end

-- mint sprig: stem from the tea up, opposite leaf pairs
local mtok = { r = { name = "mint" } }
local stem = { { 34, 28 }, { 35, 22 }, { 36, 16 }, { 36, 11 } }
local function leaf(ax, ay, cx, cy, bx, by, w, serr)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.95 + 0.06)) ^ 0.65)
  end, { fold = 0.5 })
  if serr then -- serrated edge: notch every 3rd edge pixel
    local e = m:edge() local i = 0
    e:each(function(x, y) i = i + 1 if X.hash(x, y, 7) < 0.22 then m:cut(c:rect(x, y, x, y)) end end)
  end
  local idx = A.shade(c, m, n, MINT, { tok = mtok, amb = 0.12, wrap = 0.3, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 } })
  m:each(function(x, y) local k = K(x, y)
    local s, t, i = S[k], T[k], idx[k] or 3
    if not s then return end
    if abs(s) < 0.16 and t > 0.05 and t < 0.85 then c:put(x, y, MINT[max(1, i - 2)], mtok)
    elseif t > 0.15 and t < 0.8 and abs(s) > 0.3 and abs(s) < 0.75 and ((floor(t * 9 + abs(s) * 2.2)) % 2 == 0) and X.hash(x, y, 3) < 0.5 then
      c:put(x, y, MINT[max(1, i - 1)], mtok) end
  end)
  return m
end
leaf(34, 24, 28, 22, 23, 18, 3.3, true)
leaf(35, 23, 40, 20, 45, 19, 3.1, true)
-- stem
for i = 0, 40 do local t = i / 40
  local x, y = A.bez(stem, t)
  c:put(floor(x + .5), floor(y + .5), "#4e8a3e", mtok)
  if t < 0.6 then c:put(floor(x + .5) + 1, floor(y + .5), "#2a5a30", mtok) end
end
leaf(36, 16, 31, 13, 27, 10, 2.6, true)
leaf(36, 16, 40, 13, 43, 11, 2.5, true)
leaf(36, 12, 35, 9, 36, 6, 2.0, false)
c:put(26, 19, MINT[6], mtok) c:put(25, 19, SPEC, mtok)
-- AO: stem enters tea
c:put(34, TOP, TEA[2], gtok) c:put(35, TOP, TEA[2], gtok)

-- quirk: a fallen mint leaf on the saucer (right)
leaf(42, 52, 45, 50, 48, 51, 1.6, false)

A.save(c, "mint-tea")
