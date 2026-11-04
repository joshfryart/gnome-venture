-- golden-carp (Opus single pass, aB35_1). A slim gilded carp swimming right, side view, a touch nose-up.
-- Material: per-pixel tube light on the body (6-tone gold, violet-brown shade), overlapping crescent scales (dark rim +
-- lit lip), gill-cover arc, lateral line, specular streak along the back, cool reflected light on the belly edge.
-- Fins in a warmer orange ramp with darker rays: forked tail, long low dorsal, pelvic, pectoral laid over the flank.
-- AO where the fins join the body; barbel at the mouth; gold-ringed eye.
-- quirk: a single air bubble rising from its lips.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "golden-carp"
local c = G.new2(NAME)
local GOLD = { "#5a2a22", "#8f4a1f", "#c8701f", "#eb9b24", "#f8c640", "#ffe993" }
local FIN  = { "#6e2a2c", "#a8452a", "#d86a2a", "#f4913a", "#ffb860", "#ffdc98" }
local SPEC, COOL, INK = "#fff6dc", "#b8786a", "#2b1c26"
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- body tube (computed first so fins can reference it)
local p = { { 15, 37 }, { 25, 31 }, { 40, 28 }, { 51, 31 } }
local function hw(t)
  if t < 0.58 then return 2.0 + 5.2 * sin(t / 0.58 * pi / 2) ^ 1.3 end
  return 7.2 * sqrt(max(0, 1 - ((t - 0.58) / 0.43) ^ 2)) + 0.3
end
local bm, bn, BT, BS, samp = G.tube(p, hw)
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end

local ftok = { r = { name = "fin" } }
local function fin(poly, base, rays, R)
  local m = c:poly(poly)
  m:cut(bm)
  local bias = {}
  X.ao(bias, m, bm, 1, -1)
  local idx = X.tone(c, m, X.light(X.pillow(m, R or 2), { amb = 0.16, wrap = 0.35 }), FIN, { cuts = CUTS, bias = bias, tok = ftok })
  -- rays: lines from base to edge points, one tone darker
  for _, r in ipairs(rays) do
    local n = max(abs(r[1] - base[1]), abs(r[2] - base[2]))
    for s = 1, n do
      local x = floor(base[1] + (r[1] - base[1]) * s / n + .5)
      local y = floor(base[2] + (r[2] - base[2]) * s / n + .5)
      if m:has(x, y) and not bias[K(x, y)] then G.step(c, idx, FIN, x, y, -1, ftok) end
    end
  end
  return m, idx
end

-- tail: forked, two lobes
local tail = fin({ { 17, 34 }, { 12, 30 }, { 7, 24 }, { 6, 27 }, { 9, 32 }, { 11, 37 }, { 9, 42 }, { 6, 47 }, { 8, 49 }, { 13, 44 }, { 17, 40 } },
  { 16, 37 }, { { 7, 25 }, { 9, 29 }, { 10, 33 }, { 10, 41 }, { 8, 45 }, { 7, 48 } }, 2)
-- dorsal: long, low, raked back
local dx0, dy0 = G.at(samp, 0.34, -0.85)
local dx1, dy1 = G.at(samp, 0.64, -0.85)
local dorsal = fin({ { dx0, dy0 + 1 }, { dx0 + 3, dy0 - 7 }, { dx0 + 6, dy0 - 6 }, { dx1 - 1, dy1 - 3 }, { dx1 + 1, dy1 + 1 } },
  { dx0 + 4, dy0 + 2 }, { { dx0 + 3, dy0 - 6 }, { dx0 + 7, dy0 - 5 }, { dx0 + 11, dy0 - 4 }, { dx1 - 3, dy1 - 2 } }, 1.6)
-- pelvic fin under the belly
local px0, py0 = G.at(samp, 0.5, 0.95)
local pelvic = fin({ { px0 + 3, py0 - 1 }, { px0 - 3, py0 + 5 }, { px0 - 4, py0 + 3 }, { px0 - 3, py0 } },
  { px0 + 2, py0 - 1 }, { { px0 - 3, py0 + 4 } }, 1.4)
-- anal fin
local ax0, ay0 = G.at(samp, 0.24, 0.95)
local anal = fin({ { ax0 + 2, ay0 - 1 }, { ax0 - 2, ay0 + 3 }, { ax0 - 3, ay0 + 2 }, { ax0 - 2, ay0 - 1 } },
  { ax0 + 1, ay0 - 1 }, {}, 1.2)

-- body
local bias = {}
bm:each(function(x, y) local k = K(x, y) if BT[k] < 0.05 then bias[k] = -1 end end)
local btok = { r = { name = "body" } }
local v = X.light(bn, { amb = 0.08, wrap = 0.3 })
local idx = X.tone(c, bm, v, GOLD, { cuts = CUTS, bias = bias, tok = btok })
-- scales: staggered crescents over the flank (not the head), dark rim, lit lip on the upper half
bm:each(function(x, y) local k = K(x, y)
  local t, s = BT[k], BS[k]
  if t < 0.1 or t > 0.71 or abs(s) > 0.86 then return end
  local w = samp[floor(t * (#samp - 1)) + 1].w
  local across = s * w / 3.0
  local row = floor(across + 0.5)
  local fv = across - row
  local u = (t * LEN) / 3.6 + (row % 2) * 0.5 + fv * fv * 1.3
  local d = u - floor(u)
  local i = idx[k]
  if d < 0.28 then c:put(x, y, GOLD[max(1, i - 1)], btok)
  elseif d < 0.52 and s < 0.2 and i < 6 then c:put(x, y, GOLD[min(6, i + 1)], btok) end
end)
-- gill cover arc + lateral line
bm:each(function(x, y) local k = K(x, y)
  local t, s = BT[k], BS[k]
  local d = (t - 0.74) * LEN + s * s * 3.0
  if d > -0.5 and d < 0.5 and abs(s) < 0.85 then c:put(x, y, GOLD[max(1, idx[k] - 2)], btok) end
  if t > 0.16 and t < 0.7 and abs(s - 0.12) < 0.07 and floor(t * LEN) % 3 == 0 then c:put(x, y, GOLD[max(1, idx[k] - 2)], btok) end
end)
-- cool reflected light along the belly edge
local rim = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.62 and BS[k] > 0.75 and BT[k] > 0.2 and BT[k] < 0.86 then c:put(x, y, COOL, btok) end end)
-- specular streak on the back + glint
for _, t in ipairs{ 0.5, 0.53, 0.56, 0.6, 0.64 } do local x, y = G.at(samp, t, -0.62) c:put(x, y, GOLD[6], btok) end
do local x, y = G.at(samp, 0.62, -0.6) c:put(x, y, SPEC, btok) c:put(x + 1, y, SPEC, btok) end

-- pectoral fin laid over the flank, behind the gill
local qx, qy = G.at(samp, 0.7, 0.35)
local pec = c:poly{ { qx, qy - 1 }, { qx + 1, qy + 1 }, { qx - 4, qy + 5 }, { qx - 6, qy + 4 }, { qx - 4, qy + 1 } }
pec:clip(bm)
local pidx = X.tone(c, pec, X.light(X.pillow(pec, 1.4), { amb = 0.2, wrap = 0.4 }), FIN, { cuts = CUTS, tok = ftok })
-- contact shadow under the pectoral on the flank
pec:shift(1, 1):each(function(x, y) if bm:has(x, y) and not pec:has(x, y) then G.step(c, idx, GOLD, x, y, -1, btok) end end)
c:put(qx - 3, qy + 3, FIN[3], ftok) c:put(qx - 2, qy + 2, FIN[3], ftok)

-- eye: gold ring, ink pupil, cream glint
local ex, ey = G.at(samp, 0.87, -0.28)
local EYE = { "..rr..", ".rKKr.", ".rKKr.", "..rr.." }
local EC = { r = "#ffe993", K = INK }
for yy, row in ipairs(EYE) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if EC[ch] then c:put(ex + xx - 4, ey + yy - 3, EC[ch], btok) end end end
c:put(ex - 2, ey - 1, "#fff6dc", btok)
c:put(ex - 1, ey + 1, GOLD[2], btok) c:put(ex, ey + 1, GOLD[2], btok)
-- mouth: dark lip line at the snout tip, barbel trailing down
local mx, my = G.at(samp, 0.985, 0.25)
c:put(mx, my, GOLD[1], btok) c:put(mx - 1, my, GOLD[2], btok)
for _, q in ipairs{ { 0, 2 }, { 0, 3 }, { -1, 4 }, { -2, 5 } } do
  local x, y = mx + q[1] - 1, my + q[2]
  if not bm:has(x, y) then c:put(x, y, FIN[3], ftok) end
end

-- quirk: one air bubble rising from the lips
local bx, by = mx - 2, my - 13
local BUB = { ".ss.", "shhs", "sh.s", ".ss." }
local BC = { s = "#5f9ad0", h = "#e4f6ff" }
for yy, row in ipairs(BUB) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if BC[ch] then c:put(bx + xx - 1, by + yy - 1, BC[ch]) end end end
c:put(bx + 2, by + 2, "#b9e2f5")
G.save2(c, NAME)
