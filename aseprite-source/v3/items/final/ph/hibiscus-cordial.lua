-- hibiscus-cordial (aC11_5, Opus single pass). A slim, tall glass bottle of deep ruby hibiscus cordial with rounded
-- shoulders, a glass lip collar and a cork stopper; twine is wound twice round the neck and carries a little paper tag
-- stamped with a hibiscus. Material: vertical-cylinder light through the liquid (6-tone ruby), bright glass rim streak
-- and a pale transmitted-light core, cool reflected edge, lit meniscus, thick dark glass base, pale empty glass in the
-- neck, cork grain with paler end grain, twisted twine, ambient under the tag. Ground shadow (it stands).
-- quirk: one sticky drip has run down the neck from the lip.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, sqrt, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.sqrt, math.max, math.min
local c = G.new2("hibiscus-cordial")
local RU = { "#3a0a1e", "#62102e", "#921a3a", "#c22a46", "#e45664", "#ff9690" }
local GL = { "#6e5466", "#9c8296", "#c8b4c4", "#e8dce6", "#fbf2f6" }
local WD = { "#4e2e2a", "#7a4a32", "#a8703f", "#cf9a5c", "#ecc48a" }
local CX = 31.5
local LEVEL = 24
local function hw(y)
  if y < 10 then return nil end
  if y <= 11 then return 4.3 end
  if y <= 19 then return 3.2 end
  if y <= 27 then local t = (y - 19) / 8 return 3.2 + 4.8 * sin(t * pi / 2) end
  if y <= 49 then return 8.0 end
  if y == 50 then return 7.6 end
  if y == 51 then return 7.0 end
  return nil
end
c:groundShadow(32, 52, 12, 1)
local bot = HP.mask()
for y = 10, 51 do local w = hw(y) for x = 10, 54 do if abs(x + 0.5 - (CX + 0.5)) <= w then bot:set(x, y) end end end
-- normals: vertical cylinder, tilted up on the shoulder
local n = {}
bot:each(function(x, y) local w = hw(y) local t = max(-0.96, min(0.96, (x - CX) / (w + 0.5)))
  local ny = (y > 19 and y <= 27) and -0.55 or 0
  n[K(x, y)] = { G.norm(t, ny, sqrt(1 - t * t)) } end)
local v = X.light(n, { amb = 0.1, wrap = 0.35 })
local liq, air = HP.mask(), HP.mask()
bot:each(function(x, y) if y >= LEVEL and y <= 49 then liq:set(x, y) else air:set(x, y) end end)
local idx = X.tone(c, liq, v, RU, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.9 } })
X.tone(c, air, v, GL, { cuts = { 0.25, 0.5, 0.7, 0.88 } })
-- thick glass base (dark glass with a lit upper row)
for y = 50, 51 do for x = 10, 54 do if bot:has(x, y) then c:put(x, y, (x < CX - 3) and RU[2] or RU[1]) end end end
for x = 10, 54 do if bot:has(x, 49) and x > CX - 6 and x < CX + 4 then c:put(x, 49, RU[3]) end end
-- glass lip collar: darker underside row
for x = 10, 54 do if bot:has(x, 11) and not bot:has(x, 12) then c:put(x, 11, GL[2]) end end
for x = 10, 54 do if bot:has(x, 11) then c:put(x, 11, (x < CX) and GL[3] or GL[2]) end end
-- meniscus: lit line at the liquid level
for x = 10, 54 do if liq:has(x, LEVEL) and liq:has(x - 1, LEVEL) and liq:has(x + 1, LEVEL) then c:put(x, LEVEL, RU[5]) end end
-- pale transmitted-light core (lower right inside the liquid)
liq:each(function(x, y) local dx, dy = (x - (CX + 2.5)) / 2.6, (y - 42) / 5.5
  if dx * dx + dy * dy <= 1 then c:put(x, y, RU[min(6, (idx[K(x, y)] or 3) + 2)]) end end)
-- bright glass rim streak down the lit side + short second streak
for y = 27, 46 do c:put(floor(CX - 6), y, y < 30 and "#fff4d6" or "#ffc8c0") end
for y = 30, 37 do c:put(floor(CX - 4), y, RU[6]) end
for y = 12, 18 do c:put(floor(CX - 2), y, GL[5]) end
-- cool reflected light on the shade edge
for y = 30, 47 do c:put(floor(CX + 8), y, "#a8406e") end
-- bubbles
c:put(34, 33, RU[5]) c:put(36, 29, RU[6]) c:put(30, 45, RU[5])
-- cork with grain and a paler end grain
local cork = HP.mask()
for y = 4, 9 do local w = (y <= 5) and 3.0 or 2.4 for x = 20, 44 do if abs(x + 0.5 - (CX + 0.5)) <= w then cork:set(x, y) end end end
local cn = {}
cork:each(function(x, y) local t = max(-0.95, min(0.95, (x - CX) / 3.4)) cn[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
local ci = X.tone(c, cork, X.light(cn, { amb = 0.1, wrap = 0.3 }), WD, { cuts = { 0.25, 0.5, 0.7, 0.88 } })
cork:each(function(x, y) if y == 4 then c:put(x, y, x < CX + 1 and WD[5] or WD[4]) end
  if y >= 6 and (x == floor(CX) - 1 or (x == floor(CX) + 1 and y >= 7)) then c:put(x, y, WD[max(1, ci[K(x, y)] - 1)]) end end)
c:put(floor(CX), 4, WD[3]) -- end-grain pore
for x = 20, 44 do if cork:has(x, 9) then c:put(x, 9, WD[1]) end end -- ambient where cork meets glass
-- twine: two twisted wraps round the neck
local TW = { "#6a4626", "#b88a50", "#e8c888" }
for _, yy in ipairs{ 14, 16 } do
  for x = 10, 54 do if bot:has(x, yy) then
    c:put(x, yy, (x + yy) % 2 == 0 and TW[2] or TW[1])
    if (x + yy) % 4 == 0 and x < CX then c:put(x, yy, TW[3]) end
  end end
end
for x = 10, 54 do if bot:has(x, 15) then c:put(x, 15, GL[1]) end end -- shadow between wraps
-- tag: string from the neck knot to a paper tag hanging on the right
local knotx = floor(CX + 4)
c:put(knotx, 15, TW[1]) c:put(knotx + 1, 16, TW[2])
G.ln(c, knotx + 1, 17, knotx + 5, 20, TW[2])
local tag = G.rell(knotx + 8.5, 24.5, cos(0.35), sin(0.35), 4.6, 3.4)
-- contact shadow under the tag on the bottle
tag:shift(-1, 2):each(function(x, y) if bot:has(x, y) and not tag:has(x, y) then c:put(x, y, (liq:has(x, y)) and RU[1] or GL[1]) end end)
local tn = X.pillow(tag, 1.5)
local ti = X.tone(c, tag, X.light(tn, { amb = 0.15, wrap = 0.3 }), { "#9a7a5a", "#d0b48a", "#eedcb4", "#fff1d2" }, { cuts = { 0.3, 0.55, 0.8 } })
-- hole and stamp on the tag
c:put(knotx + 6, 22, "#7a5a40")
G.stamp(c, knotx + 8, 23, { ".p.", "pcp", ".p." }, { p = "#e2455a", c = "#f5b82e" })
-- quirk: drip down the neck from the lip
for y = 12, 19 do c:put(floor(CX - 4), y, y == 13 and RU[6] or RU[4]) end
G.stamp(c, floor(CX - 5), 20, { "ab", "cd" }, { a = RU[5], b = RU[4], c = RU[3], d = RU[2] })
c:put(floor(CX - 5), 20, "#ffd8d0")
G.save2(c, "hibiscus-cordial")
