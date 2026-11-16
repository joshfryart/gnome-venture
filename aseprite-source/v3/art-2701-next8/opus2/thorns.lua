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

local CX, CY, R = 31, 35, 14

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
        local L = 5 + floor(O.hash(i, j, 7) * 4) + (j == 0 and 1 or 0)
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
      O.step(c, hidx, HUSK, jx, jy, 2, tok)
      O.step(c, hidx, HUSK, jx + 1, jy + 1, -2, tok)
    end
  end end
  -- split lips: pale fleshy lining on the cut faces, dark just below
  husk:each(function(x, y)
    if split:has(x, y - 1) or split:has(x + 1, y) or split:has(x - 1, y) then
      c:put(x, y, "#e8e0b8", tok)
      if husk:has(x, y + 1) then c:put(x, y + 1, HUSK[2], tok) end
    end
  end)
end

-- one fat chestnut sitting in the open split
do
  local tok = O.tok("nut")
  for _, q in ipairs{ { CX + 0.5, CY - R + 2.5, 0.15 } } do
    local m, n = O.oval(q[1], q[2], 6, 5.4, q[3])
    local cut = husk:copy()
    m:cut(cut)
    local idx = O.shade(c, m, n, NUT, { tok = tok, amb = 0.12, wrap = 0.2 })
    -- dark rim on the shade side
    m:each(function(x, y) if not m:has(x + 1, y) or not m:has(x, y + 1) then O.set(c, idx, NUT, x, y, 2, tok) end end)
    -- pale tuft at the tip
    local tx, ty = floor(q[1] + q[3] * 5 + .5), floor(q[2] - 5.5)
    c:put(tx, ty - 1, HIL[2], tok) c:put(tx, ty, HIL[2], tok) c:put(tx, ty + 1, HIL[1], tok) c:put(tx + 1, ty + 1, NUT[3], tok) c:put(tx - 1, ty + 1, NUT[4], tok)
    -- grain line + specular
    for y = floor(q[2]) - 3, floor(q[2]) + 2 do if m:has(floor(q[1]) + 2, y) then O.step(c, idx, NUT, floor(q[1]) + 2, y, -1, tok) end end
    c:put(floor(q[1]) - 2, floor(q[2]) - 2, NUT[6], tok) c:put(floor(q[1]) - 1, floor(q[2]) - 3, NUT[6], tok)
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
