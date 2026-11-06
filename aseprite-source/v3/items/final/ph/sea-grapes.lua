-- sea-grapes (D15, final pass, Sonnet). One round, leathery, rose-veined leaf hanging off the top of a slim reddish raceme;
-- eight round fruit alternate left/right on tiny pedicels and ripen from green at the top through peach-rose and wine
-- to purple at the bottom. Per-pixel sphere light on every grape (6 tones), cool reflected light on the shade side,
-- waxy bloom specks on the ripe ones, 2x1 specular. Leaf: V-folded blade light, pale rose midrib and angled veins,
-- glossy streak, salt crust on the rim. Rachis: lit tube with contact shadow under each pedicel.
-- quirk: a bead of sea spray is sliding down the lowest grape.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("sea-grapes")

local LEAF = { "#12332f", "#1b4d3a", "#276a42", "#388a48", "#58a852", "#86c566" }
local GREEN = { "#1a4238", "#255f43", "#33804b", "#4f9f52", "#78bd5c", "#b0dc7c" }
local LIME = { "#2a4a22", "#43682a", "#6a8a32", "#92ad3e", "#bcc95a", "#e6ea92" }
local ROSE = { "#4a1d3c", "#7a2c4e", "#a8445a", "#cc6258", "#e88a6a", "#ffc29a" }
local WINE = { "#2a1030", "#4a1a48", "#722660", "#9a3c78", "#c06094", "#eea0c0" }
local PURP = { "#1c1442", "#31235e", "#4e3484", "#6e4aa6", "#9470c6", "#c6aaea" }
local STEM = { "#4a2230", "#7a3a3a", "#a85a40", "#d48a58" }
local ltok = { r = { name = "leaf" } }
local stok = { r = { name = "stem" } }

-- raceme geometry ---------------------------------------------------------------------------------------------
local rach = { { 35, 27 }, { 37, 34 }, { 35, 44 }, { 36, 53 } }
local function rx(y) -- rachis x at row y (search the bezier)
  local bx, bd = 36, 1e9
  for i = 0, 100 do local x, yy = G.bez(rach, i / 100) if abs(yy - y) < bd then bd, bx = abs(yy - y), x end end
  return bx
end
local grapes = {
  { 41, 29, GREEN, "#6aa890" }, { 30, 32.5, GREEN, "#6aa890" }, { 41.5, 36, LIME, "#78ae8a" }, { 30, 39.5, ROSE, "#9a7ab0" },
  { 41.5, 43, ROSE, "#9a7ab0" }, { 30, 46.5, WINE, "#8a7ad0" }, { 41, 50, PURP, "#7a88d8" }, { 30.5, 53, PURP, "#7a88d8" },
}
local GR = 3.3
local gm = {}
for i, g in ipairs(grapes) do
  gm[i] = c:ellipse(floor(g[1]) + (g[1] % 1 > 0.4 and 0.5 or 0), floor(g[2]) + (g[2] % 1 > 0.4 and 0.5 or 0), GR, GR)
end

-- leaf --------------------------------------------------------------------------------------------------------
local LR = 10.2
local lm, ln, LT, LS, len = G.blade(31, 24, 20, 22, 11, 8, function(t)
  if t > 0.99 then return -1 end
  local u = min(1, t * 0.98 + 0.01)
  local w = LR * sqrt(max(0, 1 - (2 * u - 1) ^ 2))
  w = w * (1 + 0.035 * sin(t * 33)) + (t < 0.14 and 1.1 * (0.14 - t) / 0.14 or 0)   -- gently wavy rim + heart-shaped base
  return max(0.4, w)
end, { fold = 0.34 })
local lbias = {}
-- AO + shadow where the petiole and the first grape meet the leaf
local pet, pn, PT = G.tube({ { 32, 24 }, { 33, 25 }, { 34, 26 }, { 35, 27 } }, function(t) return 1.25 end)
X.ao(lbias, lm, pet, 1, -1)
local lidx = G.toneN(c, lm, ln, LEAF, { bias = lbias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
-- glossy sheen streak on the lit lobe
lm:each(function(x, y) local k = K(x, y)
  if LS[k] < -0.35 and LS[k] > -0.7 and LT[k] > 0.45 and LT[k] < 0.8 then c:put(x, y, LEAF[min(6, (lidx[k] or 3) + 1)], ltok) end end)
-- rose-pink veins: midrib + angled laterals (leathery sea-grape leaf)
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  if abs(s) < 0.13 and t > 0.03 and t < 0.93 then c:put(x, y, s <= 0 and "#f4cfa4" or "#b95a54", ltok) return end
  if t > 0.1 and t < 0.9 and abs(s) > 0.2 and abs(s) < 0.88 then
    local d = (t * len - abs(s) * 7.2) % 4.0
    if d < 0.85 then c:put(x, y, s < 0 and "#ecb890" or "#a8504e", ltok) end
  end
end)
-- cool reflected rim, lower-right
lm:edge():each(function(x, y) local k = K(x, y)
  if LS[k] > 0.6 and LT[k] > 0.1 and LT[k] < 0.9 then c:put(x, y, "#2f6e66", ltok) end end)
-- salt crust on the rim
for _, p in ipairs{ { 21, 29 }, { 22, 29 }, { 26, 27 } } do if lm:has(p[1], p[2]) then c:px(p[1], p[2], "#e6f0f6") end end
c:px(14, 12, "#d9f0e4") c:px(15, 12, "#d9f0e4")

-- petiole + raceme ---------------------------------------------------------------------------------------------
G.stem(c, { { 32, 24 }, { 33, 25 }, { 34, 26 }, { 35, 27 } }, function(t) return 1.25 end, STEM, { tok = stok, amb = 0.12 })
local rm, rn, RT, RS, ridx = G.stem(c, rach, function(t) return 1.2 - 0.25 * t end, STEM, { tok = stok, amb = 0.12 })
-- pedicels
for i, g in ipairs(grapes) do
  local y = floor(g[2] + 0.5)
  local x0 = floor(rx(y) + 0.5)
  local dir = (g[1] > x0) and 1 or -1
  local xe = floor(g[1] + 0.5) - dir * 3
  for x = min(x0, xe), max(x0, xe) do if not gm[i]:has(x, y) then c:put(x, y, STEM[(x == x0) and 2 or 3], stok) end end
  c:put(x0 + dir * 0, y + 1, STEM[1], stok)   -- contact shadow under the pedicel
end

-- grapes: sphere light, contact AO between neighbours, bloom, bounce, specular -----------------------------------
local ptok = {}
for i, g in ipairs(grapes) do
  local m = gm[i]
  local cx, cy = floor(g[1]) + (g[1] % 1 > 0.4 and 0.5 or 0), floor(g[2]) + (g[2] % 1 > 0.4 and 0.5 or 0)
  local n = X.sphere(cx, cy, GR, m)
  local bias = {}
  for j, o in ipairs(gm) do if j ~= i and abs(grapes[j][2] - g[2]) < 8 then X.ao(bias, m, o, 1, -1) end end
  X.ao(bias, m, rm, 1, -1)
  local tok = { r = { name = "grape" .. i } }
  local ramp = g[3]
  local v = X.light(n, { amb = 0.05, wrap = 0.2 })
  local idx = X.tone(c, m, v, ramp, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.85 }, bias = bias, tok = tok })
  local rim = X.rim(n)
  m:each(function(x, y) local k = K(x, y)
    -- cool reflected light on the shade rim
    if rim[k] > 0.8 and v[k] < 0.5 and (not bias[k]) then c:put(x, y, g[4], tok) end
  end)
  -- waxy bloom: pale blue-ish specks on the ripe fruit
  if ramp == PURP or ramp == WINE or ramp == ROSE then
    m:shrink(1):each(function(x, y) local k = K(x, y)
      if v[k] > 0.45 and v[k] < 0.8 and X.hash(x, y, 7 + i) > 0.78 then c:put(x, y, ramp[6], tok) end end)
  end
  -- calyx scar on the stem side
  local toward = (g[1] > rx(floor(g[2] + 0.5))) and -1 or 1
  local ex
  for x = floor(cx) - 5, floor(cx) + 5 do if m:has(x, floor(cy)) and (not ex or (toward < 0 and x < ex) or (toward > 0 and x > ex)) then ex = x end end
  if ex then c:put(ex, floor(cy), ramp[1], tok) end
  -- specular 2x1 up-left + glint
  local sx, sy = floor(cx - 1.4), floor(cy - 1.8)
  c:put(sx, sy, ramp[6], tok) c:put(sx + 1, sy, ramp[6], tok) c:put(sx, sy + 1, ramp[5], tok)
  if i % 2 == 0 then c:put(sx, sy, A.CREAM, tok) end
end

-- quirk: bead of sea spray on the lowest grape
local dx, dy = 31, 53
for _, p in ipairs{ { 1, 0, "#b6f0e0" }, { 0, 1, "#8ee0dc" }, { 1, 1, "#5fc4c8" }, { 2, 1, "#3a86b0" }, { 0, 2, "#5fc4c8" }, { 1, 2, "#3a86b0" }, { 2, 2, "#2a4a7a" }, { 1, 3, "#2a4a7a" } } do
  c:px(dx + p[1], dy + p[2], p[3])
end
c:px(dx, dy + 1, A.CREAM)
A.save(c, "sea-grapes")
