-- ico-boat (final, Opus). A little sailboat side-on, bow to the right: a deep curved clinker hull, a slim mast with
-- a red pennant, a tall cream mainsail on a boom and a gold jib forward, riding a short band of waves.
-- Material: hull lit per pixel as a rounded shell (6-tone wood) with overlapping strakes (dark lap line + lit lip),
-- grain flecks, a gold-trimmed gunwale and a pale end grain at the transom; mast lit as a cylinder; sails billow
-- (lit per pixel) with panel seams and a stitched foot hem; waves 5-tone sea with cream foam, AO on the hull at the
-- waterline. quirk: a striped sock hung out to dry from the end of the boom.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs, sin, cos, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.cos, math.pi
local c = A.new("ico-boat")
local WD = { "#3a2228", "#5c3530", "#864c33", "#b0703f", "#d39a5c", "#efc58a" }
local SL = { "#6a5a72", "#a2949e", "#cfc2b4", "#e8dcc4", "#f6eed8", "#fff4d6" }
local JB = { "#7a3a1f", "#b6602a", "#e08d2a", "#f5b82e", "#ffd765", "#fff0a8" }
local SEA = { "#2a4a7a", "#3a76a8", "#4fa6c0", "#7fcfd0", "#b6f0e0" }
local EM = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local GO = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local wt, st, jt, at = { r = { name = "wood" } }, { r = { name = "sail" } }, { r = { name = "jib" } }, { r = { name = "sea" } }

-- mast (3 px), boom
local MX = 30
local mast = c:rect(MX - 1, 8, MX + 1, 40)
mast:each(function(x, y) c:put(x, y, (x == MX - 1) and WD[5] or (x == MX and WD[4] or WD[2]), wt) end)
c:put(MX - 1, 8, WD[6], wt) c:put(MX, 8, WD[5], wt)
-- pennant (two-tone, forked tail)
A.map(c, {
  "hbbbb..",
  "bbbbbbb",
  "sbbbs..",
  "ss.....",
}, MX + 2, 8, { h = EM[4], b = EM[3], s = EM[2] }, jt)
c:put(MX + 6, 10, EM[2], jt)

-- mainsail: luff on the mast, leech bowed out, foot on the boom
local function sail(m, ramp, tok, axis)
  local pn = X.pillow(m, 2.2, 0.8)
  local x0, y0, x1, y1 = m:bbox()
  local n = {}
  m:each(function(x, y) local k = K(x, y)
    local rx0, rx1 = x, x
    while m:has(rx0 - 1, y) do rx0 = rx0 - 1 end
    while m:has(rx1 + 1, y) do rx1 = rx1 + 1 end
    local u = (rx1 > rx0) and ((x - rx0) / (rx1 - rx0) * 2 - 1) or 0
    local v = (y - y0) / max(1, y1 - y0)
    n[k] = { A.norm(pn[k][1] + u * 0.75, pn[k][2] - 0.15 + v * 0.35, 1) }
  end)
  -- billow: tilt normals toward the lit side across the sail
  local bias = {}
  local idx = A.shade(c, m, n, ramp, { tok = tok, bias = bias, amb = 0.1, wrap = 0.35, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
  return idx
end
local main = HP.mask()
for y = 11, 36 do
  local t = (y - 11) / 25
  local xl = floor((MX - 2) + (14 - (MX - 2)) * t - 2.4 * sin(pi * t) + 0.5)
  for x = xl, MX - 2 do main:set(x, y) end
end
local midx = sail(main, SL, st)
-- panel seams parallel to the foot (1 tone darker, lit row under)
for _, sy in ipairs{ 17, 23, 29 } do
  main:each(function(x, y) if y == sy then A.step(c, midx, SL, x, y, -1, st) if main:has(x, y + 1) then A.step(c, midx, SL, x, y + 1, 1, st) end end end)
end
-- dark luff row against the mast
for y = 11, 36 do if main:has(MX - 2, y) then c:put(MX - 2, y, SL[2], st) end end
-- stitched foot hem
c:stitch{ { 16, 35 }, { MX - 3, 35 } }

-- jib: from near the masthead to the bow
local jib = HP.mask()
for y = 13, 37 do
  local t = (y - 13) / 24
  local xr = floor(MX + 2 + (48 - (MX + 2)) * t + 1.6 * sin(pi * t) + 0.5)
  for x = MX + 3, xr do jib:set(x, y) end
end
local jidx = sail(jib, JB, jt)
for _, sy in ipairs{ 22, 30 } do
  jib:each(function(x, y) if y == sy and x > MX + 3 then A.step(c, jidx, JB, x, y, -1, jt) end end)
end
for y = 13, 37 do if jib:has(MX + 3, y) then c:put(MX + 3, y, JB[2], jt) end end
-- forestay line 1px between jib and mast top
-- boom (2 px) under the mainsail
for x = 9, MX - 1 do c:put(x, 37, WD[4], wt) c:put(x, 38, WD[2], wt) end
c:put(9, 37, WD[6], wt) c:put(9, 38, WD[5], wt)

-- hull: curved shell, bow raked up to the right, square transom at the left
local hm = HP.mask()
local function sheer(x) return 40 - 2.0 * ((x - 30) / 22) ^ 2 - ((x > 44) and (x - 44) * 0.35 or 0) end
local function keel(x)
  local t = (x - 12) / 41
  local b = 40 + 11 * sqrt(max(0, 1 - ((t - 0.4) / 0.62) ^ 2)) ^ 1.2
  if x > 46 then b = b - (x - 46) * 1.1 end
  return b
end
for x = 12, 53 do
  local top, bot = sheer(x), keel(x)
  for y = floor(top + 0.5), floor(bot + 0.5) do if y >= floor(top + 0.5) then hm:set(x, y) end end
end
local hn = {}
local HT = {}
hm:each(function(x, y)
  local top, bot = sheer(x), keel(x)
  local t = (y - top) / max(1, bot - top)    -- 0 at gunwale, 1 at keel
  local ex = (x - 32) / 25
  HT[K(x, y)] = t
  hn[K(x, y)] = { A.norm(ex * 0.7, -0.4 + t * 1.25, 0.9) }
end)
local hidx = A.shade(c, hm, hn, WD, { tok = wt, amb = 0.06, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
-- strakes: lap lines following the sheer
hm:each(function(x, y) local k = K(x, y) local t = HT[k]
  for _, s in ipairs{ 0.36, 0.62, 0.84 } do
    local top, bot = sheer(x), keel(x)
    local yy = top + s * (bot - top)
    if abs(y - yy) < 0.5 then A.step(c, hidx, WD, x, y, -2, wt) if hm:has(x, y + 1) then A.step(c, hidx, WD, x, y + 1, 1, wt) end end
  end
  if (x * 5 + y * 3) % 11 == 0 and t > 0.2 then A.step(c, hidx, WD, x, y, -1, wt) end
end)
-- gunwale: gold trim row + dark rubbing strake
for x = 12, 53 do
  local y = floor(sheer(x) + 0.5)
  if hm:has(x, y) then c:put(x, y, (x < 30) and GO[4] or GO[3], wt) end
  if hm:has(x, y + 1) then c:put(x, y + 1, GO[1], wt) end
end
-- transom end grain (pale) on the left edge
for y = 40, 50 do if hm:has(12, y) and not (y == floor(sheer(12) + 0.5)) then c:put(12, y, WD[5], wt) end if hm:has(13, y) then A.step(c, hidx, WD, 13, y, -1, wt) end end
-- AO on mast foot / sails where they meet the gunwale
for x = MX - 1, MX + 1 do c:put(x, 39, WD[1], wt) end
for x = 13, 28 do if main:has(x, 36) then c:put(x, 36, SL[1], st) end end

-- waves in front of the hull
local sea = HP.mask()
local function crest(x) return 50 + 1.2 * sin((x - 6) * 2 * pi / 11) end
for x = 8, 56 do for y = floor(crest(x) + 0.5), 54 do sea:set(x, y) end end
-- trim the band ends into rounded caps
for _, p in ipairs{ { 8, 54 }, { 8, 53 }, { 9, 54 }, { 56, 54 }, { 56, 53 }, { 55, 54 } } do sea.s[K(p[1], p[2])] = nil end
-- AO: hull pixels just above the waterline
sea:each(function(x, y) if hm:has(x, y - 1) and not sea:has(x, y - 1) then local k = K(x, y - 1) c:put(x, y - 1, WD[1], wt) end end)
sea:each(function(x, y)
  local d = y - crest(x)
  local i = (d < 1) and 5 or ((d < 2) and 4 or ((d < 3.2) and 3 or 2))
  if y == 54 then i = 1 end
  if (x - 6) % 11 >= 7 and d < 1 then i = 4 end
  c:put(x, y, SEA[i], at)
end)
-- foam flecks on crests, one cream glint
for _, x in ipairs{ 9, 20, 31, 42 } do local y = floor(crest(x) + 0.5) if sea:has(x, y) then c:put(x, y, "#fff4d6", at) c:put(x + 1, y, SEA[5], at) end end
c:put(16, 52, SEA[4], at) c:put(38, 53, SEA[4], at) c:put(27, 52, SEA[4], at) c:put(49, 53, SEA[4], at)

-- quirk: striped sock hung from the boom end
local sk = { r = { name = "sock" } }
A.map(c, {
  "k",
  "cr",
  "rc",
  "cr",
  "rcrr",
  ".rrr",
}, 9, 39, { k = "#2b1c26", r = EM[3], c = "#fff4d6" }, sk)
c:put(10, 44, EM[2], sk) c:put(12, 44, EM[2], sk) c:put(9, 41, EM[2], sk) c:put(10, 43, EM[2], sk)
A.save(c, "ico-boat")
