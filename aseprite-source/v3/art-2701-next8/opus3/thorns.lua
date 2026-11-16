-- thorns (Opus third pass, richness): a serrated chestnut leaf with midrib and veins behind the burr (says "plant",
-- never "germ"), a bigger glossy chestnut pair in the split with pale hilum bases and grain, calmer spine-base
-- stipple, a pale lining rim on the split lips, and a cool bounce line on the husk's lower-right edge.
-- thorns (Opus second pass). Tag "thorns" (Thorn Hide: blocked hits prick back). Replaces Haiku's cactus (a desert
-- plant that read as a pickle at small size). A sweet-chestnut burr: nature's thorn hide. A round husk bristling with
-- long needle spines all the way round (spiky silhouette that reads at 16 px), short spine bases stippled over the
-- face, split open at the top where a glossy chestnut peeks out. Material: 6-tone husk (lit upper left, cool shade
-- lower right), spines with dark roots and pale sharp tips, nut with a hard specular and a pale hilum cap.
-- quirk: a tuft of grey fur is snagged on one spine: something tried it and got pricked back.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local HP, X, K = O.HP, O.X, O.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = O.new("thorns")

local HUSK = { "#1e3a30", "#2e5a3a", "#4a8040", "#7aa844", "#b0cc5a", "#e2ec98" }
local SP   = { "#3a5a30", "#8aa848", "#d4e08a", "#f6f4c8" }
local NUT  = { "#3a1c1c", "#5e2c22", "#8a4428", "#b4643a", "#dc9a64", "#ffd8a8" }
local HIL  = { "#b49a7a", "#e2ceaa" }
local FUR  = { "#5c5868", "#8a8696", "#bcb8c4", "#e0dce4" }
local INK  = "#2b1c26"

local CX, CY, R = 29, 31, 13
local LEAF = { "#1e4430", "#2e6438", "#46883e", "#6eaa48", "#a2cc66", "#d6ec9c" }

-- a chestnut leaf behind the burr: long, lance-shaped, serrated, bent down to the lower right
do
  local tok = O.tok("leaf")
  local P = { { 36, 40 }, { 44, 46 }, { 52, 50 }, { 60, 58 } }
  local lm, ln, T, S = O.tube(P, function(t) return 0.6 + sin(pi * min(1, t * 1.15)) * 4.2 end)
  local li = O.shade(c, lm, ln, LEAF, { tok = tok, amb = 0.12, wrap = 0.3 })
  -- serrated edge: tooth every 3 px along the rim
  lm:edge():each(function(x, y)
    if (x + 2 * y) % 3 == 0 and lm:has(x, y) then
      for _, d in ipairs{ { 0, -1 }, { 1, 0 }, { -1, 0 }, { 0, 1 } } do
        if not lm:has(x + d[1], y + d[2]) then
          c:put(x + d[1], y + d[2], (S[K(x, y)] or 0) < 0 and LEAF[5] or LEAF[2], tok) break
        end
      end
    end
  end)
  -- midrib (pale, along S = 0) and side veins slanting forward toward the tip, every 4 px
  lm:each(function(x, y)
    local k = K(x, y)
    local a = T[k] * 30 - abs(S[k]) * 3.5
    if abs(S[k]) < 0.16 and T[k] < 0.93 then c:put(x, y, LEAF[5], tok)
    elseif (a % 4) < 1 and abs(S[k]) < 0.85 and T[k] > 0.06 then O.step(c, li, LEAF, x, y, -2, tok) end
  end)
end

-- spine clusters round the rim (three needles fanning from each root), drawn first so the husk overlaps the roots
local spines = {}
do
  local tok = O.tok("spines")
  local n = 15
  for i = 0, n - 1 do
    local a = -pi / 2 + (i + 0.5) * 2 * pi / n + (O.hash(i, 1, 4) - 0.5) * 0.15
    -- leave the split at the top open
    if not (a > -pi / 2 - 0.55 and a < -pi / 2 + 0.55) then
      for j = -1, 1 do
        local aa = a + j * 0.2
        local L = 4 + floor(O.hash(i, j, 7) * 4) + (j == 0 and 1 or 0)
        local ca, sa = cos(aa), sin(aa)
        for r = R - 1, R + L, 0.25 do
          local f = (r - R) / L
          local x, y = floor(CX + ca * r + .5), floor(CY + sa * r + .5)
          c:put(x, y, f < 0.2 and SP[1] or (f < 0.55 and SP[2] or (f < 0.85 and SP[3] or SP[4])), tok)
        end
        if j == 0 then spines[#spines + 1] = { a = aa, L = L } end
      end
    end
  end
end

-- husk, split open at the top: two lobes parting
local husk, hn = O.oval(CX, CY, R, R - 0.5)
local split = c:poly{ { CX - 9, CY - R - 2 }, { CX + 10, CY - R - 2 }, { CX + 4, CY - 6 }, { CX - 3, CY - 6 } }
husk:cut(split)
local hidx
do
  local tok = O.tok("husk")
  hidx = O.shade(c, husk, hn, HUSK, { tok = tok, amb = 0.1, wrap = 0.25 })
  -- face-on spine bases: little lit/dark tick pairs on a jittered grid
  for gy = CY - R + 2, CY + R - 1, 3 do for gx = CX - R + 1, CX + R - 1, 3 do
    local jx = gx + ((gy // 3) % 2) + floor(O.hash(gx, gy, 5) * 2)
    local jy = gy + floor(O.hash(gx, gy, 9) * 2)
    if husk:has(jx, jy) and husk:has(jx + 1, jy + 1) then
      O.step(c, hidx, HUSK, jx, jy, 1, tok)
      O.step(c, hidx, HUSK, jx + 1, jy + 1, -1, tok)
    end
  end end
  -- bounce line: the second ring in from the edge on the lower right goes one step lighter
  husk:shrink(1):edge():each(function(x, y)
    if (x - CX) + (y - CY) > 11 then O.step(c, hidx, HUSK, x, y, 1, tok) end
  end)
  -- split lips: pale fleshy lining on the cut faces, dark just below
  husk:each(function(x, y)
    if split:has(x, y - 1) or split:has(x + 1, y) or split:has(x - 1, y) then
      c:put(x, y, "#e8e0b8", tok)
      if husk:has(x, y + 1) then c:put(x, y + 1, HUSK[2], tok) end
    end
  end)
end

-- two glossy chestnuts sitting in the open split (the back one smaller, the front one big)
do
  local tok = O.tok("nut")
  for _, q in ipairs{ { CX + 5.5, CY - R + 0.5, 4.6, 4.4, 0.5 }, { CX - 1, CY - R + 1, 6.6, 5.8, -0.1 } } do
    local m, n = O.oval(q[1], q[2], q[3], q[4], q[5])
    m:cut(husk)
    local idx = O.shade(c, m, n, NUT, { tok = tok, amb = 0.12, wrap = 0.2 })
    -- dark rim on the shade side, bounce one inside it
    m:each(function(x, y) if not m:has(x + 1, y) or not m:has(x, y + 1) then O.set(c, idx, NUT, x, y, 1, tok) end end)
    m:each(function(x, y) if m:has(x + 1, y + 1) and (not m:has(x + 2, y + 1) or not m:has(x + 1, y + 2)) and x > q[1] then O.set(c, idx, NUT, x, y, 3, tok) end end)
    -- fine grain lines following the shell
    for _, gx in ipairs{ -2, 1, 3 } do
      for y = floor(q[2] - q[4]) + 1, floor(q[2] + q[4]) - 1 do
        local x = floor(q[1] + gx + (y - q[2]) * 0.15 * gx + .5)
        if m:has(x, y) and (idx[K(x, y)] or 0) >= 3 then O.step(c, idx, NUT, x, y, -1, tok) end
      end
    end
    -- pale tuft at the tip
    local tx, ty = floor(q[1] + q[5] * 4 + .5), floor(q[2] - q[4])
    c:put(tx, ty - 1, HIL[2], tok) c:put(tx, ty, HIL[2], tok) c:put(tx + 1, ty, HIL[1], tok)
    -- glossy specular
    c:put(floor(q[1]) - 2, floor(q[2]) - 2, NUT[6], tok) c:put(floor(q[1]) - 1, floor(q[2]) - 3, NUT[6], tok) c:put(floor(q[1]) - 2, floor(q[2]) - 1, NUT[5], tok)
  end
end

-- quirk: fur tuft snagged on a spine on the right
do
  local tok = O.tok("fur")
  local s = spines[4]
  local x, y = floor(CX + cos(s.a) * (R + s.L - 2) + .5), floor(CY + sin(s.a) * (R + s.L - 2) + .5)
  O.map(c, {
    "...h..l.",
    "l.hhl.h.",
    ".lhmmhl.",
    "..mmsm.l",
    ".m.s.m..",
    "m..s..s.",
  }, x - 3, y - 2, { l = FUR[3], h = FUR[4], m = FUR[2], s = FUR[1] }, tok)
end

O.save(c, "thorns")
