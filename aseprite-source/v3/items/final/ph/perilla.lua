-- perilla (final, Opus aC33_1). A perilla (shiso) sprig: slim square purple-green stem with an edge highlight, one pair
-- of broad ovate saw-toothed leaves (left shows the green, veined upper face; right is twisted to show its purple
-- underside with pale raised veins), a small purple-tinged top pair and a bud; AO at the leaf joints, cool edges.
-- quirk: one round dew drop sits on the green leaf (bright rim, pale core, tiny cast shadow).
local NAME = "perilla"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, exp = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.exp
local c = A.new(NAME)
local GR = { "#173f34", "#235c3c", "#337a44", "#4f9a4c", "#7cbc5c", "#b4dc80" }
local PU = { "#2a1838", "#46245a", "#673478", "#884a94", "#aa6cb0", "#d6a4d6" }
local TOP = { "#2a2a3c", "#3c4a4a", "#56704c", "#7a9256", "#a6b86a", "#d4dc98" }
local STEM = { "#3a2244", "#5e3a5e", "#7e5a6a", "#a68a7a", "#ccb894" }
local COOL = "#3b6e7c"

-- stem: square (flat front with a lit left edge and a dark right edge), slight lean
local stok = { r = { name = "stem" } }
local sm = HP.mask()
local function sx(y) return floor(31 + (58 - y) * 0.06 + 0.5) end
for y = 12, 57 do local x = sx(y)
  for d = 0, 2 do sm:set(x + d, y) end end
sm:each(function(x, y) local d = x - sx(y)
  c:put(x, y, d == 0 and STEM[4] or (d == 1 and STEM[3] or STEM[2]), stok) end)
for y = 13, 57, 5 do c:put(sx(y) + 1, y, STEM[2], stok) end  -- faint groove ticks (square stem)
c:put(sx(57), 57, STEM[3], stok) c:put(sx(57) + 1, 57, STEM[5], stok)   -- cut end

-- serrated ovate leaf: blade -> saw teeth -> tone -> veins
local function leaf(ax, ay, cx, cy, bx, by, w, ramp, o)
  local m, n, T, S, len = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.08) ^ 0.72) ^ 0.9)
  end, { fold = o.fold or 0.35 })
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local ph = T[k] * len / 3.0 + (S[k] > 0 and 0.5 or 0)
    local f = ph - floor(ph)              -- sawtooth: teeth lean toward the tip
    if T[k] > 0.15 and T[k] < 0.93 and abs(S[k]) > 0.97 - f * 0.34 then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  m:cut(sm)
  local tok = { r = { name = o.name } }
  local idx = A.toneN(c, m, n, ramp, { tok = tok, bias = o.bias, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local s, t, i = S[k], T[k], idx[k] or 3
    if abs(s) < 0.12 and t > 0.03 and t < 0.92 then
      c:put(x, y, o.under and ramp[6] or (s <= 0 and ramp[6] or ramp[3]), tok) return end
    if t > 0.08 and t < 0.85 and abs(s) > 0.18 and abs(s) < 0.8 then
      local d = (t * len - abs(s) ^ 1.2 * w * 1.3) % 4.4
      if d < 0.85 then
        if o.under then c:put(x, y, ramp[min(6, i + 2)], tok)
        else c:put(x, y, s < 0 and ramp[min(6, i + 1)] or ramp[max(1, i - 1)], tok) end
      end
    end
  end)
  m:edge():each(function(x, y) local k = K(x, y)
    if S[k] > 0.7 and T[k] > 0.1 and T[k] < 0.9 and not o.under then c:put(x, y, COOL, tok) end end)
  return m, idx, tok, T, S
end

-- main pair (drawn after stem; AO where they meet it)
local ab = {}
local lm, lidx, ltok = leaf(30, 36, 19, 26, 7, 31, 7.4, GR, { name = "leafL", bias = ab })
local rm, ridx, rtok = leaf(34, 34, 46, 23, 57, 29, 6.8, PU, { name = "leafR", under = true, fold = 0.2 })
-- ambient shading on the stem just under each leaf joint
for _, p in ipairs{ { 0, 36 }, { 1, 36 }, { 2, 36 }, { 2, 34 }, { 2, 35 } } do c:put(sx(p[2]) + p[1], p[2], STEM[1], stok) end
-- right leaf: a sliver of green upper face curling over its top edge (the twist)
rm:edge():each(function(x, y) if not rm:has(x, y - 1) and x > 38 and x < 52 and (x % 3 ~= 0) then c:put(x, y, GR[5], rtok) end end)

-- top pair: small, purple-flushed, and a bud
local t1 = leaf(31, 19, 26, 13, 21, 14, 3.2, TOP, { name = "topL" })
local t2 = leaf(34, 18, 39, 12, 44, 12, 3.0, TOP, { name = "topR" })
local btok = { r = { name = "bud" } }
A.map(c, { ".2.", "232", "121", ".1." }, sx(12), 8, { ["1"] = PU[3], ["2"] = PU[5], ["3"] = PU[6] }, btok)
for x = sx(13), sx(13) + 2 do c:put(x, 12, STEM[2], stok) end

-- quirk: dew drop on the green leaf (shadow first)
local dx, dy = 20, 29
local dtok = { r = { name = "dew" } }
for _, p in ipairs{ { 1, 3 }, { 2, 3 }, { 3, 2 }, { 3, 1 } } do if lm:has(dx + p[1], dy + p[2]) then c:put(dx + p[1], dy + p[2], GR[1], ltok) end end
A.map(c, { ".bb.", "bccb", "bcdb", ".ba." }, dx - 1, dy - 1, { a = "#3a86b0", b = "#5fc4c8", c = "#b6f0e0", d = "#e4f6ff" }, dtok)
c:put(dx, dy, A.CREAM, dtok)
A.save(c, NAME)
