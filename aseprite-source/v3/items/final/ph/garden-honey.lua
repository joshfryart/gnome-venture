-- garden-honey (final, Opus single pass). Slim, tall glass jar of amber honey: shoulders rounding into a short
-- neck, gingham cloth cap tied with twisted twine and a little bow. Material: glass rim + pale air gap above the
-- honey line, per-pixel cylinder light through amber (6 tones, AO at the base), long specular streak, cool
-- reflected light on the right, tiny bubbles, a parchment label with a honeycomb mark, cloth checks + fold lines.
-- quirk: a bee has landed on the cap knot and a slow drip has escaped down the glass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_3.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local c = A.new("garden-honey")
local H, GL, CL, CK, TW = R.honey, R.glass, R.cloth, R.check, R.twine

c:groundShadow(32, 56, 14, 2)

-- jar body (slim): x 21..42, y 25..55, neck 24..39 y 20..26
local body = c:rrect(21, 27, 42, 55, 5)
body:add(c:rrect(23, 24, 40, 30, 3))
local neck = c:rect(25, 20, 38, 25)
local jar = body:copy():add(neck)
local n = A.vcyl(jar, 21, 42, 3, 0.3)
local tokJ = { r = { name = "jar" } }
-- honey fill (below the honey line y 30)
local honey = body:copy():clip(c:rect(0, 30, 63, 63)):shrink(1)
local bias = {}
honey:each(function(x, y) local k = K(x, y)
  if y >= 52 then bias[k] = -1 end
  if y >= 54 then bias[k] = -2 end
  if y == 31 then bias[k] = 1 end
end)
-- glass everywhere first
local gidx = A.shade(c, jar, n, GL, { amb = 0.3, wrap = 0.4, tok = tokJ, cuts = { 0.15, 0.3, 0.45, 0.62, 0.86 } })
-- amber honey through glass
local hidx = A.shade(c, honey, n, H, { amb = 0.08, wrap = 0.3, bias = bias, tok = tokJ, cuts = { 0.22, 0.4, 0.56, 0.72, 0.9 } })
-- glass wall: honey-side rim 1px dark amber on the right, lit left
honey:edge():each(function(x, y)
  if x >= 40 then c:put(x, y, H[2], tokJ) elseif x <= 22 then c:put(x, y, H[4], tokJ) end
  if y >= 54 then c:put(x, y, H[1], tokJ) end
end)
-- meniscus: bright honey line + curve up at the walls
for x = 23, 40 do c:put(x, 30, (x < 32) and H[6] or H[5], tokJ) end
c:put(22, 29, H[5], tokJ) c:put(41, 29, H[4], tokJ)
-- air gap glass inside neck/shoulder stays pale; inner back rim line
for x = 25, 38 do c:put(x, 21, GL[3], tokJ) end
for x = 26, 37 do c:put(x, 20, GL[5], tokJ) end
-- shoulder line where body meets neck (glass thickness)
for x = 24, 39 do c:put(x, 26, GL[(x < 30) and 5 or 3], tokJ) end
-- specular streak (long, left) + short twin, cream glint
for y = 33, 49 do c:put(24, y, (y < 36) and A.CREAM or H[6], tokJ) end
for y = 34, 39 do c:put(26, y, H[6], tokJ) end
c:put(25, 32, A.CREAM, tokJ)
-- cool reflected light lower right
for y = 38, 51 do c:put(41, y, "#c46a5a", tokJ) end
c:put(40, 52, "#b0584e", tokJ)
-- bubbles (lit top, dark under)
for _, b in ipairs{ { 29, 50 }, { 36, 47 }, { 33, 34 }, { 38, 40 } } do
  c:put(b[1], b[2], H[6], tokJ) c:put(b[1], b[2] + 1, H[2], tokJ) end

-- label: parchment rounded rect with honeycomb mark
local lab = c:rrect(26, 37, 37, 46, 2)
local ln = A.vcyl(lab, 21, 42, 2, 0.5)
local tokL = { r = { name = "label" } }
A.shade(c, lab, ln, R.cream, { amb = 0.3, wrap = 0.4, tok = tokL, cuts = { 0.12, 0.25, 0.4, 0.6, 0.82 } })
lab:edge():each(function(x, y) if x == 37 or y == 46 then c:put(x, y, R.cream[2], tokL) end end)
A.map(c, {
  ".gg.",
  "gHHg",
  "gHHg",
  ".gg.",
}, 30, 39, { g = H[2], H = H[5] }, tokL)
c:put(31, 40, H[6], tokL)
for x = 28, 35 do if x % 3 ~= 1 then c:put(x, 44, R.cream[3], tokL) end end

-- drip escaping down the right side of the glass
local drip = c:rect(38, 25, 39, 30):add(c:rect(39, 31, 40, 34)):add(c:rrect(39, 34, 41, 37, 1))
local dn = X.pillow(drip, 1.5)
A.shade(c, drip, dn, H, { amb = 0.2, wrap = 0.3, tok = { r = { name = "drip" } } })
c:put(39, 35, H[6], { r = { name = "drip" } })

-- cloth cap: dome over the neck, flaring skirt with a scalloped hem
local cap = c:poly{ { 23, 14 }, { 40, 14 }, { 44, 23 }, { 19, 23 } }
cap:add(c:ellipse(31.5, 14, 8, 3))
for x = 19, 44 do if (x - 19) % 4 == 1 or (x - 19) % 4 == 2 then cap:set(x, 24) end end
local cn = A.blend(X.pillow(cap, 2.5), A.vcyl(cap, 19, 44, 2, 0), 0.5)
local tokC = { r = { name = "cap" } }
local cidx = {}
local v = X.light(cn, { amb = 0.1, wrap = 0.3 })
cap:each(function(x, y) local k = K(x, y)
  local i = 1 for j, t in ipairs{ 0.22, 0.38, 0.54, 0.7, 0.86 } do if v[k] >= t then i = j + 1 end end
  local checker = (floor((x - 1) / 2) + floor(y / 2)) % 2 == 0
  local fold = (x == 24 or x == 30 or x == 36 or x == 42) and y >= 19
  if fold then i = max(1, i - 1) end
  cidx[k] = i
  c:put(x, y, checker and CK[i] or CL[i], tokC)
end)
-- fold lines of the skirt (darker crease + lit lip)
for _, fx in ipairs{ 24, 30, 36, 42 } do for y = 19, 23 do c:put(fx, y, CL[2], tokC) c:put(fx - 1, y, CL[5], tokC) end end
-- ambient row where cap sits on the glass
for x = 21, 42 do if not cap:has(x, 25) then c:put(x, 25, GL[1], tokJ) end end

-- twine: twisted band round the cap at y 18-19, bow on the left
local tokT = { r = { name = "twine" } }
for x = 21, 42 do
  local a = (x % 3)
  c:put(x, 18, a == 0 and TW[4] or (a == 1 and TW[3] or TW[2]), tokT)
  c:put(x, 19, a == 2 and TW[3] or (a == 0 and TW[2] or TW[1]), tokT)
end
A.map(c, {
  "lll..lll",
  "l.Ll.L.l",
  ".lLkkL l",
  "...kk...",
  "..d..d..",
  ".d....d.",
}, 18, 15, { l = TW[3], L = TW[4], k = TW[1], d = TW[2] }, tokT)

-- quirk: bee on the top of the cap
local tokB = { r = { name = "bee" } }
A.map(c, {
  "..ww.ww..",
  "..wWwWw..",
  ".KyyKyyK.",
  "KcyKyyKyd",
  ".KyyKydK.",
}, 33, 6, { K = A.INK, y = "#f5b82e", d = "#c47a1e", c = A.CREAM, w = "#cfeef2", W = "#f4fffb" }, tokB)
c:put(42, 9, A.INK, tokB)

A.save(c, "garden-honey")
