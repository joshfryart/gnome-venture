-- garden-snips (final pass, Opus single pass). Bypass secateurs standing open in an X: a slim curved steel cutting
-- blade (bevelled edge, specular streak) crossing a darker hooked anvil jaw at a brass pivot bolt, two slender
-- shanks with a twisted wire spring between them, and ribbed red rubber grips with rounded ends.
-- Material: per-pixel cylinder light on 6-tone steel and 6-tone red, bevel line + bright edge on the blade, dark
-- bolt eye, AO where the front piece crosses the back piece, cool reflected light on the grips' shade side.
-- quirk: a freshly snipped leaf is still caught in the open jaws.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local c = A.new("garden-snips")
local STEEL = { "#2c2f4c", "#474b6c", "#6c7090", "#979bb4", "#c6c9da", "#eef0f6" }
local DARK  = { "#272640", "#3a3a58", "#555675", "#767895", "#a1a3bb", "#d2d4e2" }
local RED   = { "#5c1830", "#8c2232", "#bf3636", "#e4573c", "#fb8657", "#ffbe92" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local BRASS = { "#5a3020", "#8f4a1f", "#c57a22", "#eaa52c", "#ffd56a", "#fff1c4" }
local PX, PY = 32, 29

local function seg(p, wfn, ramp, tok, bias)
  return A.stem(c, p, wfn, ramp, { tok = tok, bias = bias, amb = 0.1, wrap = 0.3 })
end

-- BACK piece: hooked anvil jaw (up-left) + shank/grip to lower-right
local btok = { r = { name = "back" } }
local jawB = seg({ { PX, PY }, { 29, 22 }, { 25, 16 }, { 23, 9 } },
  function(t) return 3.2 - t * 1.6 end, DARK, btok)
-- hook at the jaw tip
local hook = A.HP.ellipse(24, 9, 2, 2)
do local n = X.sphere(24, 9, 2.5, hook) A.shade(c, hook, n, DARK, { tok = btok }) end
local shB = seg({ { PX, PY }, { 34, 34 }, { 36, 37 }, { 37, 40 } }, function() return 1.8 end, STEEL, btok)
local gB, gBn, gBT, gBS, gBi = seg({ { 37, 39 }, { 40, 45 }, { 43, 50 }, { 46, 56 } },
  function(t) if t > 0.86 then return 2.6 * math.sqrt(max(0, (1 - t) / 0.14)) + 0.6 end return 2.4 + t * 0.4 end, RED, btok)

-- FRONT piece: cutting blade (up-right) + shank/grip to lower-left
local ftok = { r = { name = "front" } }
local bm, bn, bT, bS, bidx = A.stem(c, { { PX, PY + 1 }, { 35, 21 }, { 39, 14 }, { 44, 7 } },
  function(t) return 3.4 * (1 - t) ^ 0.8 + 0.3 end, STEEL, { tok = ftok, amb = 0.12, wrap = 0.35 })
-- bevel: the lit (upper-left) cutting edge gets a bright line, a darker bevel row just inside it
bm:each(function(x, y) local k = K(x, y)
  if bS[k] < -0.62 and bT[k] < 0.9 then c:put(x, y, STEEL[6], ftok)
  elseif bS[k] < -0.3 and bS[k] >= -0.62 and bT[k] < 0.8 then c:put(x, y, STEEL[3], ftok) end
end)
-- specular streak along the blade flat
for _, p in ipairs{ { 36, 18 }, { 37, 17 }, { 38, 16 } } do if bm:has(p[1], p[2]) then c:put(p[1], p[2], STEEL[6], ftok) end end
local shF = seg({ { PX, PY }, { 30, 34 }, { 28, 37 }, { 27, 40 } }, function() return 1.8 end, STEEL, ftok)
local gm, gn, gT, gS, gidx = seg({ { 27, 39 }, { 24, 45 }, { 21, 50 }, { 18, 56 } },
  function(t) if t > 0.86 then return 2.6 * math.sqrt(max(0, (1 - t) / 0.14)) + 0.6 end return 2.4 + t * 0.4 end, RED, ftok)

-- grip ribs (grooves across the rubber) + cool bounce on the shade edge, both grips
local function ribs(m, T, S, idx, tok, n)
  local rim = X.rim(n)
  m:each(function(x, y) local k = K(x, y)
    local t = T[k]
    if t > 0.08 and t < 0.8 and floor(t * 17) % 3 == 0 and abs(S[k]) < 0.8 then
      c:put(x, y, RED[max(1, (idx[k] or 3) - 1)], tok) end
    if rim[k] > 0.65 and S[k] > 0.7 and t > 0.1 and t < 0.9 then c:put(x, y, "#9a4a6a", tok) end
  end)
end
ribs(gB, gBT, gBS, gBi, btok, gBn)
ribs(gm, gT, gS, gidx, ftok, gn)
-- ferrules where steel meets rubber: a dark collar row
for _, q in ipairs{ { 27, 39 }, { 26, 40 }, { 28, 40 }, { 37, 39 }, { 36, 40 }, { 38, 40 } } do c:put(q[1], q[2], STEEL[2]) end

-- AO: back piece darkened where the front piece crosses over it
local front = HP.mask():add(bm):add(shF)
local ring = front:grow(1):cut(front)
ring:each(function(x, y) local v = c:get(x, y)
  if v and (jawB:has(x, y) or shB:has(x, y)) then c:put(x, y, DARK[1], btok) end end)

-- twisted wire spring between the shanks
local spring = { { 29, 37, 1 }, { 30, 36, 2 }, { 31, 37, 1 }, { 32, 36, 2 }, { 33, 37, 1 }, { 34, 36, 2 }, { 35, 37, 1 },
  { 30, 37, 0 }, { 32, 37, 0 }, { 34, 37, 0 } }
for _, s in ipairs(spring) do c:put(s[1], s[2], ({ [0] = BRASS[2], BRASS[3], BRASS[5] })[s[3]]) end

-- brass pivot bolt with a dark slotted eye
local bolt = HP.ellipse(PX, PY, 2, 2)
do local n = X.sphere(PX, PY, 2.6, bolt) A.shade(c, bolt, n, BRASS, {}) end
c:put(PX, PY, BRASS[1]) c:put(PX + 1, PY, BRASS[2]) c:put(PX - 1, PY - 1, BRASS[6])

-- quirk: snipped leaf caught between the jaws
local lm = A.leaf(c, 29, 18, 34, 13, 37, 17, 2.3, LEAF, { vs = 2.6 })
c:put(29, 19, "#5b9a52") c:put(28, 19, "#8cc066") -- the cut stalk end, pale
A.save(c, "garden-snips")
