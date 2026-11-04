-- dragon-fruit (final pass, Opus). A slim upright pitaya: tall magenta ovoid, per-pixel sphere light on a 6-tone
-- magenta ramp, waxy bloom specks on the lit half, one 2x1 specular, cool violet reflected light on the lower right.
-- Leafy scale-bracts lie on the skin in staggered rows, pink at the base and lime-green at the tip; edge bracts
-- flare out past the silhouette (spiky read at 16 px). AO + contact shadow under every bract.
-- quirk: a single fat dewdrop clings to the skin (bright rim, pale core, glint).
local NAME = "dragon-fruit"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_2.lua")
local G, HP, X, K = D.G, D.HP, D.X, D.K
local floor, abs, sqrt, max, min, sin, cos = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos
local c = D.new(NAME)
local SKIN = { "#5a1040", "#8c1a56", "#c0246c", "#e4428c", "#ff74aa", "#ffb0cf" }
local BR = { "#1d4632", "#2d683a", "#4a8a3a", "#78ae44", "#a8d05e", "#dcef8e" }
local BRP = { "#6a1844", "#9a2a5c", "#c84a7a", "#e8709a", "#f8a0bc", "#ffd0dc" }
local FL = { "#8a7486", "#b6a6b2", "#dcd0d6", "#f2eaea", "#fff8f0" }
local COOLR = "#7c4aa6"

local cx, cy, rx, ry, ang = 32, 33, 12.5, 18, 0.1
local body, bn = G.oval(cx, cy, rx, ry, ang, 0.9)
-- bite: two overlapping circles at the lower right
local bite = HP.mask()
-- (no bite in this version)
body:cut(bite)
-- flesh band along the bite edge (inside the fruit)
local flesh = HP.mask()
local bg = bite:grow(3)
body:each(function(x, y) if bg:has(x, y) then flesh:set(x, y) end end)
local rind = HP.mask()
local bg2 = bite:grow(4)
body:each(function(x, y) if bg2:has(x, y) and not flesh:has(x, y) then rind:set(x, y) end end)

-- bracts: base point on the skin, direction up/out
local bracts = {}
local rows = {
  { -0.93, { -0.5, 0.0, 0.5 }, 8.5 },
  { -0.5, { -0.98, -0.25, 0.4, 0.98 }, 8 },
  { 0.0, { -1.0, -0.6, 0.05, 0.62, 1.0 }, 7.5 },
  { 0.48, { -0.95, -0.3, 0.35, 0.95 }, 7 },
  { 0.86, { -0.55, 0.15 }, 5.5 },
}
for _, r in ipairs(rows) do
  local v = r[1]
  for _, u in ipairs(r[2]) do
    local w = sqrt(max(0, 1 - v * v))
    local bx, by = cx + u * rx * w * 0.92, cy + v * ry * 0.92
    local dx, dy = u * 0.75, -1 + (r[1] < -0.8 and 0 or 0.15)
    if r[1] < -0.8 then dx = u * 1.1 end
    local l = sqrt(dx * dx + dy * dy) dx, dy = dx / l, dy / l
    local L = r[3] * (abs(u) > 0.9 and 1.25 or 1)
    local tx, ty = bx + dx * L, by + dy * L
    -- skip bracts in the bite
    if not bg2:has(floor(bx + .5), floor(by + .5)) and not bg2:has(floor(tx + .5), floor(ty + .5)) then
      bracts[#bracts + 1] = { bx, by, tx, ty, u }
    end
  end
end

-- body tone
local bias = {}
local bmasks = {}
for i, b in ipairs(bracts) do
  local mx, my = (b[1] + b[3]) / 2 + (b[4] - b[2]) * 0.0, (b[2] + b[4]) / 2
  local m, n, T, S = G.blade(b[1], b[2], mx + (b[1] < cx and -0.6 or 0.6), my, b[3], b[4], function(t)
    if t > 0.97 then return -1 end
    return max(0.4, 3.0 * (1 - t) ^ 0.75)
  end, { fold = 0.35 })
  bmasks[i] = { m = m, n = n, T = T, S = S }
  X.ao(bias, body, m, 1, -1)
  G.cast(bias, body, m, 1, 1, -1)
end
local btok = D.tok("skin")
local v = X.light(bn, { amb = 0.08, wrap = 0.3 })
local rim = X.rim(bn)
local idx = X.tone(c, body, v, SKIN, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, bias = bias, tok = btok })
-- cool reflected light + waxy bloom
body:edge():each(function(x, y) local k = K(x, y)
  if rim[k] and rim[k] > 0.55 and not bias[k] and not bite:grow(1):has(x, y) then c:put(x, y, COOLR, btok) end end)
body:each(function(x, y) local k = K(x, y)
  if idx[k] and idx[k] >= 3 and idx[k] <= 5 and not bias[k] and X.hash(x, y, 11) > 0.965 then c:put(x, y, SKIN[idx[k] + 1], btok) end end)

-- flesh + rind
local ftok = D.tok("flesh")
local fn = X.pillow(flesh, 2)
-- flesh is a concave scoop: invert lighting so the inner edge (toward the bite) is lit from the lower right
for k, nn in pairs(fn) do fn[k] = { -nn[1], -nn[2], nn[3] } end
D.toneV(c, flesh, fn, FL, { cuts = { 0.2, 0.42, 0.62, 0.82 }, amb = 0.25, tok = ftok })
rind:each(function(x, y) c:put(x, y, (x + y) % 5 == 0 and SKIN[3] or SKIN[2], btok) end)
local seeds = { {39,35}, {38,39}, {40,42}, {37,44}, {39,47}, {41,45}, {36,41} }
for _, s in ipairs(seeds) do if flesh:has(s[1], s[2]) then c:put(s[1], s[2], D.INK, ftok) end end

-- bracts over the skin, top rows first (tips of lower rows overlap upper bases)
for i, b in ipairs(bracts) do
  local B = bmasks[i]
  local tok = D.tok("bract" .. i)
  local vv = X.light(B.n, { amb = 0.12, wrap = 0.3 })
  local own = HP.mask()
  B.m:each(function(x, y) if not bite:has(x, y) then own:set(x, y) end end)
  local bb = {}
  for j = i + 1, #bracts do X.ao(bb, own, bmasks[j].m, 1, -1) end
  own:each(function(x, y) local k = K(x, y)
    local t, s = B.T[k], B.S[k]
    local val = vv[k] or 0
    local ii = 1
    for jj, ct in ipairs({ 0.2, 0.36, 0.52, 0.68, 0.84 }) do if val >= ct then ii = jj + 1 end end
    if bb[k] then ii = ii - 1 end
    ii = max(1, min(6, ii))
    local ramp = t < 0.22 and BRP or BR
    -- midrib groove
    if abs(s) < 0.2 and t > 0.15 and t < 0.8 then ii = max(1, ii - 1) end
    c:put(x, y, ramp[ii], tok)
  end)
  -- bright lit edge on the upper-left side of the tip
  own:edge():each(function(x, y) local k = K(x, y)
    if B.S[k] < -0.5 and B.T[k] > 0.4 and B.T[k] < 0.9 and not bb[k] then c:put(x, y, BR[6], tok) end end)
end

-- specular: 2x1 on the upper-left of the skin, plus one cream sparkle
local sx, sy = G.specAt(body, bn, 40)
c:put(sx, sy, SKIN[6], btok) c:put(sx + 1, sy, "#fff0f4", btok)
-- quirk: dewdrop
local DEW = { "#7a3a8a", "#c08ad8", "#ffe4f0", "#fff4d6" }
for _, d in ipairs{ {37,40,2}, {38,40,2}, {36,41,2}, {37,41,3}, {38,41,3}, {39,41,1}, {36,42,2}, {37,42,3}, {38,42,2}, {39,42,1}, {37,43,1}, {38,43,1} } do c:put(d[1], d[2], DEW[d[3]], D.tok("dew")) end
c:put(37, 41, DEW[4], D.tok("dew"))
-- small dried flower scar at the base
c:put(33, 51, SKIN[1], btok) c:put(34, 51, BR[2], btok)

D.save(c, NAME)
