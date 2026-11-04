-- heliconia-seed (final, Opus single pass). One glossy cobalt heliconia drupe (bloom-dusted, bright specular, cool
-- bounce light) and two pale bony seed stones (ridged triangular pyrenes, warm tan) on a long torn strip of a paddle
-- leaf (midrib, dense parallel lateral veins, wind splits along the veins at the far end, cool edge, AO + contact
-- shadows). One stone has sprouted: a rolled cigar leaf beside a petiole carrying the first small paddle leaf with
-- its parallel veins and a pale midrib.
-- quirk: a little red lobster-claw bract tip, yellow-lipped, has fallen beside the berry.
local NAME = "heliconia-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#123634", "#1a4f44", "#24684c", "#348555", "#52a462", "#8ccc7c" }
local VEIN, COOL, TORN = "#bfe6a0", "#3c7e8c", "#d6eeb0"
local BLUE = { "#141a48", "#1e2a74", "#2a40a0", "#3c5ec8", "#6a8ee6", "#a8c4ff" }
local BLOOM = "#8a9cd4"
local STONE = { "#4a3424", "#74563a", "#9c7c54", "#c0a274", "#dcc496", "#f2e4bc" }
local SPR = { "#14402e", "#1f5a3a", "#2e7844", "#45984e", "#6cb85c", "#a4d880" }
local CIG = { "#5a8a50", "#8cba6c", "#bcdc94", "#e2f2bc" }
local BRACT = { "#5a1028", "#8e1c30", "#c42c34", "#ea4a3a", "#ff8058" }
local LIP = { "#c8a020", "#f5d83a" }

-- leaf strip, slightly arched, torn at the left end, wind-split along veins at the right
local PER = 3.4
local lm, ln, LT, LS, len = A.blade(8, 51, 31, 45, 57, 52, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 7.2 * sin(pi * min(1, t * 0.7 + 0.22)) ^ 0.5)
end, { fold = 0.3 })
local torn = A.tear(lm, LT, LS, 0.05, 0.04, 31, 0.03, true)
local function phase(k) return (LT[k] * len - abs(LS[k]) * 1.2) / PER + (LS[k] > 0 and 0.5 or 0) end
local split = HP.mask()
lm:each(function(x, y) local k = K(x, y)
  local ph = phase(k) local n = floor(ph) local f = abs((ph - n) - 0.5) * 2
  local s = LS[k]
  if f > 0.82 and ((s > 0.25 and (n == 11 or n == 14)) or (s < -0.3 and n == 13)) then split:set(x, y) end
end)
lm:cut(split)
-- ragged strip ends: nibble the outer edge just past each split
lm:each(function(x, y) local k = K(x, y)
  if LT[k] > 0.8 and abs(LS[k]) > 0.85 and X.hash(x, y, 5) > 0.55 then split:set(x, y) end end)
lm:cut(split)

-- parts
local DR = { 20, 42, 3.6 }
local dm, dn = A.oval(DR[1], DR[2], DR[3], DR[3] - 0.3, 0, 1)
local st1 = { 28, 47, 3.2, 2.2, 0.35 }
local st2 = { 38, 47, 3.0, 2.1, -0.2 }
local m1 = A.oval(st1[1], st1[2], st1[3], st1[4], st1[5], 0.8)
local m2 = A.oval(st2[1], st2[2], st2[3], st2[4], st2[5], 0.8)
local bm = HP.mask()
for _, q in ipairs{ {10,45},{11,45},{12,45},{11,44},{12,44},{13,44},{13,43},{14,43},{14,42},{15,42},{13,46},{12,46},{14,45} } do bm:set(q[1], q[2]) end
bm:cut(dm)
local pet = { { 39, 45 }, { 40, 38 }, { 40, 31 }, { 41, 24 } }
local pm, pn, PT, PS = A.tube(pet, function(t) return 1.0 end)
local cig = { { 38, 45 }, { 36, 38 }, { 35, 31 }, { 34, 25 } }
local cm, cn, CT, CS = A.tube(cig, function(t) return 1.7 * (1 - t) ^ 0.5 + 0.4 end)

local bias = {}
for _, m in ipairs{ dm, m1, m2, bm } do X.ao(bias, lm, m, 1, -1) A.cast(bias, lm, m, 1, 2, -1) end
A.cast(bias, lm, dm, 2, 3, -1)
A.cast(bias, lm, pm, 1, 1, -1) A.cast(bias, lm, cm, 1, 1, -1)
local ltok = A.tok("leaf")
A.leaf(c, lm, ln, LT, LS, len, LEAF, { bias = bias, tok = ltok, vein = VEIN, per = PER, sweep = 1.2, cool = COOL, vw = 0.8, vmax = 0.92 })
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN, ltok) end end)

-- quirk: lobster-claw bract tip (red boat, yellow lip on top edge)
local qtok = A.tok("bract")
bm:each(function(x, y) local i = (y <= 43) and 4 or ((y == 44) and 3 or 2) if y >= 46 then i = 1 end c:put(x, y, BRACT[i], qtok) end)
for _, q in ipairs{ {11,44,1},{12,43,2},{13,42,2},{14,41,1} } do c:put(q[1], q[2], LIP[q[3]], qtok) end
c:put(10, 44, BRACT[5], qtok)

-- sprout: cigar leaf (rolled, spiral seam), petiole, first paddle leaf
local ctok = A.tok("cigar")
cm:each(function(x, y) local k = K(x, y)
  local i = CS[k] < -0.4 and 4 or (CS[k] < 0.2 and 3 or (CS[k] < 0.6 and 2 or 1))
  local sp = (CT[k] * 6 + CS[k] * 0.9) % 1
  if sp < 0.16 and abs(CS[k]) < 0.8 then i = max(1, i - 1) end
  c:put(x, y, CIG[i], ctok) end)
local ptok = A.tok("petiole")
pm:each(function(x, y) local k = K(x, y) c:put(x, y, PS[k] < 0 and SPR[5] or SPR[3], ptok) end)
local gtok = A.tok("paddle")
local gm, gn, GT, GS = A.blade(41, 25, 44, 14, 52, 7, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 4.4 * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.6)
end, { fold = 0.32 })
gm:cut(pm)
local gidx = A.shade(c, gm, gn, SPR, { tok = gtok, cuts = A.CUTS, amb = 0.14 })
gm:each(function(x, y) local k = K(x, y)
  if abs(GS[k]) < 0.15 and GT[k] < 0.9 then c:put(x, y, GS[k] <= 0 and SPR[6] or SPR[4], gtok) return end
  local ph = (GT[k] * 20 - abs(GS[k]) * 1.0) / 2.6 + (GS[k] > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.8 and abs(GS[k]) > 0.2 and abs(GS[k]) < 0.85 and GT[k] > 0.1 and GT[k] < 0.88 then
    c:put(x, y, SPR[max(1, gidx[k] - 1)], gtok) end
end)
c:put(41, 25, SPR[1], gtok)

-- seed stones: ridged pyrenes
local function stone(s, m, tok, cut)
  local _, _, idx, vis = A.seed(c, s, STONE, tok, { cut = cut, rim = "#8c8a9c", spec = STONE[6], power = 30 })
  local ca, sa = math.cos(s[5]), math.sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local u = ((x - s[1]) * ca + (y - s[2]) * sa) / (s[3] + .45)
    if abs(u - 0.15) < 0.17 or abs(u + 0.45) < 0.13 then c:put(x, y, STONE[max(1, (idx[k] or 3) - 2)], tok) end
  end)
end
stone(st1, m1, A.tok("stone1"))
stone(st2, m2, A.tok("stone2"), pm:copy():add(cm))
-- split coat where the sprout leaves the second stone
c:put(37, 45, STONE[1], A.tok("stone2"))

-- drupe: glossy cobalt, bloom dusting, bright specular, cool bounce, tiny calyx scar
local dtok = A.tok("drupe")
local didx = A.shade(c, dm, dn, BLUE, { tok = dtok, amb = 0.1, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
local rim = X.rim(dn)
dm:each(function(x, y) local k = K(x, y)
  if rim[k] > 0.6 and didx[k] <= 3 then c:put(x, y, "#5a6ab8", dtok)
  elseif didx[k] == 4 and X.hash(x, y, 9) > 0.78 then c:put(x, y, BLOOM, dtok) end end)
local sx, sy = A.specAt(dm, dn, 60)
c:put(sx, sy, A.CREAM, dtok) c:put(sx + 1, sy, BLUE[6], dtok) c:put(sx, sy + 1, BLUE[6], dtok)
c:put(DR[1] + 1, DR[2] - 3, BLUE[1], dtok) c:put(DR[1] + 2, DR[2] - 3, BLUE[2], dtok)

A.save(c, NAME)
