-- plum-chutney (aC35_3 final, Opus single pass). A round-shouldered clip-top glass jar packed with chunky plum chutney:
-- 6-tone russet base (per-pixel cylinder light), glossy plum chunks with lit top faces and dark undersides, pale golden
-- onion slivers, dark raisins and mustard seeds pressed against the glass. Glass dome lid with a bright rim, an orange
-- rubber seal with a pull tab, and a steel wire bail and lever (bevel + bright edge). Tall left specular streak, cool bounce
-- on the right, thick base, ground shadow. History: Sonnet draft replaced.
-- quirk: a whole star anise is pressed flat against the glass among the chunks.
local NAME = "plum-chutney"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = A.new(NAME)
local CH    = { "#2a0f1e", "#4a1a26", "#6e2a2c", "#93402e", "#b85e36", "#d88a4a" }
local PLUMC = { "#2e1240", "#4e1e5e", "#74307a", "#9a4a94", "#c070b0", "#e6a0cc" }
local ONION = { "#a8783a", "#d8a84e", "#f4d47a", "#fff0b0" }
local GLASS = { "#3f5f7e", "#62889f", "#93bcc8", "#c6e4ea", "#eaf8f6" }
local RUB   = { "#7a2a1e", "#c24a22", "#ee7a2e", "#ffb060" }
local WIRE  = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local ANISE = { "#3a2020", "#6a3a28", "#9a5e38", "#c88e58" }

c:groundShadow(32, 58, 14, 1.4)
local gtok = A.tok("glass")
local body = HP.rrect(20, 28, 44, 57, 6)
local neck = HP.rect(23, 25, 41, 29)
local jar = body:copy():add(neck)
A.tone(c, jar, A.vcylN(jar, 20, 44, 0), GLASS, { tok = gtok, amb = 0.25, wrap = 0.4, cuts = { 0.3, 0.5, 0.7, 0.88 } })
-- chutney fill (to the shoulder, lumpy top)
local fill = body:shrink(1):clip(HP.rect(0, 31, 63, 55))
for x = 21, 43 do if (x % 5 == 1 or x % 7 == 3) then fill.s[K(x, 31)] = nil end end
local ftok = A.tok("chutney")
local fb = {}
fill:each(function(x, y) if y >= 53 then fb[K(x, y)] = -1 end end)
local fidx = A.tone(c, fill, A.vcylN(fill, 21, 43, 0), CH, { tok = ftok, amb = 0.05, wrap = 0.2, bias = fb, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
-- plum chunks: rounded wedges with lit top edge and a dark underside row
local chunks = { { 24, 35, 2.6, 1.8 }, { 33, 33, 2.4, 1.7 }, { 40, 38, 2.2, 1.9 }, { 28, 42, 2.8, 2.0 },
                 { 37, 47, 2.6, 1.8 }, { 24, 50, 2.3, 1.7 }, { 32, 52, 2.0, 1.5 } }
for _, p in ipairs(chunks) do
  local m = HP.ellipse(p[1], p[2], p[3], p[4]):clip(fill)
  local n = X.pillow(m, 1.6)
  local base = {}
  local li = X.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.3 }), PLUMC, { cuts = A.CUTS, tok = ftok })
  -- dark underside row (ambient where chunk meets the mass)
  m:each(function(x, y) if not m:has(x, y + 1) and fill:has(x, y + 1) then c:put(x, y + 1, CH[1], ftok) end end)
  c:put(floor(p[1] - p[3] / 2), floor(p[2] - p[4] / 2), PLUMC[6], ftok)       -- wet gloss
end
-- onion slivers (curved pale strips), raisins, mustard seeds
for _, s in ipairs{ { { 29, 37 }, { 31, 36 }, { 33, 37 } }, { { 21, 45 }, { 22, 44 }, { 23, 44 } }, { { 40, 43 }, { 41, 42 }, { 42, 42 } },
                     { { 28, 55 }, { 30, 54 }, { 31, 54 } }, { { 34, 41 }, { 35, 40 } } } do
  for i, q in ipairs(s) do if fill:has(q[1], q[2]) then c:put(q[1], q[2], ONION[(i == 1) and 2 or 3], ftok) end end
end
for _, q in ipairs{ { 36, 36 }, { 21, 39 }, { 33, 45 }, { 42, 52 }, { 27, 47 } } do
  if fill:has(q[1], q[2]) then c:put(q[1], q[2], "#1e0b18", ftok) end
  if fill:has(q[1] + 1, q[2]) then c:put(q[1] + 1, q[2], CH[2], ftok) end
end
fill:each(function(x, y) if X.hash(x, y, 9) < 0.035 and y > 32 then c:put(x, y, ONION[4], ftok) end end)

-- quirk: star anise pressed on the glass
local star = {
  "...a...",
  "..aba..",
  "aabcbaa",
  ".abcb..",
  "..bcb..",
  ".ab.ba.",
  ".a...a.",
}
local SA = { a = ANISE[2], b = ANISE[3], c = ANISE[1] }
for j, row in ipairs(star) do for i = 1, #row do local ch = row:sub(i, i)
  if SA[ch] then c:put(32 + i, 40 + j, SA[ch], ftok) end end end
c:put(36, 43, ANISE[4], ftok)

-- glass highlights
for y = 32, 52 do c:put(22, y, GLASS[5], gtok) end
for y = 34, 44 do c:put(23, y, GLASS[4], gtok) end
for y = 33, 53 do c:put(43, y, GLASS[3], gtok) end
for x = 25, 39 do c:put(x, 56, x < 30 and GLASS[4] or GLASS[3], gtok) end
for x = 23, 41 do if not fill:has(x, 31) then c:put(x, 31, GLASS[2], gtok) end end   -- headspace shadow line

-- rubber seal + pull tab (left)
local rtok = A.tok("rubber")
for x = 21, 43 do c:put(x, 24, x < 30 and RUB[3] or RUB[2], rtok) c:put(x, 25, RUB[1], rtok) end
for _, p in ipairs{ { 17, 24, 3 }, { 18, 24, 3 }, { 19, 24, 3 }, { 20, 24, 3 }, { 17, 25, 2 }, { 18, 25, 2 }, { 19, 25, 2 }, { 20, 25, 1 }, { 17, 23, 4 } } do
  c:put(p[1], p[2], RUB[p[3]], rtok) end
-- glass dome lid
local lid = HP.ellipse(32, 23, 11, 5):clip(HP.rect(0, 0, 63, 23))
local ln = X.pillow(lid, 3)
local lidx = A.tone(c, lid, ln, GLASS, { tok = gtok, amb = 0.25, wrap = 0.35, cuts = { 0.3, 0.5, 0.7, 0.88 } })
for x = 22, 42 do if lid:has(x, 23) then c:put(x, 23, GLASS[2], gtok) end end
c:put(26, 20, GLASS[5], gtok) c:put(27, 19, GLASS[5], gtok) c:put(28, 19, "#fff4d6", gtok)
-- steel wire bail: loop over the lid top + side wires down to the lever on the neck
local wtok = A.tok("wire")
A.curve(c, { { 22, 27 }, { 22, 14 }, { 42, 14 }, { 42, 27 } }, function(t) return t < 0.45 and WIRE[4] or WIRE[3] end, wtok, 120)
for y = 26, 29 do c:put(21, y, WIRE[3], wtok) c:put(43, y, WIRE[2], wtok) end
-- lever clasp on the right of the neck
for _, p in ipairs{ { 44, 26, 3 }, { 45, 27, 3 }, { 45, 28, 2 }, { 46, 29, 2 }, { 46, 30, 1 }, { 44, 27, 2 } } do c:put(p[1], p[2], WIRE[p[3]], wtok) end
A.save(c, NAME)
