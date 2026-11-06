-- ico-shop (final, Opus single pass). Narrow village shopfront: plum shingle mansard roof (scalloped courses, AO
-- under each course), a striped ember/cream canvas awning with a scalloped hem (each stripe rounded, fold shade,
-- AO where it tucks under the roof), cream plaster wall between oak corner posts with grain, a mullioned display
-- window (bright glass rim, pale core, diagonal reflection, a pumpkin and a jam jar on the sill), a plank door with
-- an arched head, dark recess and brass knob, a stone step and a ground shadow.
-- quirk: a crooked little brick chimney puffs one curl of smoke.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA9_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-shop")
local PL = { "#2c2048", "#40306a", "#5a459e", "#7a62c0", "#9c86dc", "#c4b2f2" }
local RD = { "#6e2038", "#9a2a3c", "#c9393e", "#e8533f", "#ff7f5a", "#ffab84" }
local CRM = { "#8a6a5a", "#b8977a", "#dcc09a", "#f0dcb6", "#fbecce", "#fff6e2" }
local WD = { "#4a2a28", "#6e3f2e", "#935a36", "#b97a4a", "#d89c62", "#f0c286" }
local GL = { "#2a4a7a", "#3a6ea0", "#5fa4c8", "#8fd0dc", "#c0ecea", "#e8fbf6" }
local STN = { "#444663", "#5c5e7a", "#74758c", "#9192a6", "#b4b4c4", "#d8d8e2" }
local BRK = { "#5a2030", "#8a3436", "#b4503e", "#d27456" }
local SMK = { "#9a9ab0", "#c6c6d4", "#e8e8f0" }
local T = function(n) return A.tok(n) end
local rtok, atok, wtok, ptok, gtok, stok, dtok = T("roof"), T("awning"), T("wall"), T("post"), T("glass"), T("stone"), T("door")
local function flat(m) local n = {} m:each(function(x, y) n[K(x, y)] = { 0, 0, 1 } end) return n end

c:groundShadow(32, 54, 21, 1.5)

-- quirk first (behind the roof): crooked chimney + two puffs of smoke
local chim = c:poly{ { 38, 11 }, { 42, 10 }, { 43, 15 }, { 39, 15 } }
chim:each(function(x, y)
  local row = (y - 10) % 2
  local mortar = (row == 0 and (x + 1) % 4 == 0) or (row == 1 and (x + 3) % 4 == 0)
  local tone = x <= 39 and 4 or (x >= 42 and 2 or 3)
  c:put(x, y, mortar and BRK[1] or BRK[tone], rtok)
end)
A.map(c, { "abbb", ".ccd" }, 37, 9, { a = STN[6], b = STN[5], c = STN[3], d = STN[2] }, stok)
A.map(c, {
  "...aab.",
  "..abbbc",
  "ab.bbc.",
  "bbc....",
}, 42, 5, { a = SMK[3], b = SMK[2], c = SMK[1] }, stok)

-- wall first (awning hangs over its top): plaster between oak posts, stone plinth
local WX0, WX1, WY0, WY1 = 14, 49, 27, 50
local wall = c:rect(WX0, WY0, WX1, WY1)
local wn = flat(wall)
A.bulge(wn, 26, 32, 28, 26, 0.35)
local wb = {}
wall:each(function(x, y) local k = K(x, y)
  if y <= 30 then wb[k] = -1 end                        -- contact shadow under the awning
  if X.hash(x, y, 11) > 0.94 then wb[k] = (wb[k] or 0) - 1 end   -- plaster texture
end)
A.shade(c, wall, wn, CRM, { amb = 0.2, wrap = 0.3, bias = wb, tok = wtok, cuts = { 0.12, 0.26, 0.42, 0.62, 0.86 } })
for _, px0 in ipairs{ WX0, WX1 - 2 } do
  local post = c:rect(px0, WY0, px0 + 2, WY1)
  local pn = X.pillow(post, 1.2)
  local pb = {}
  post:each(function(x, y) if y <= 30 then pb[K(x, y)] = -1 end
    if x == px0 + 1 and (y % 7 == 3 or y % 7 == 4) then pb[K(x, y)] = -1 end end)
  A.shade(c, post, pn, WD, { amb = 0.1, wrap = 0.3, bias = pb, tok = ptok })
end
local plinth = c:rect(WX0, 48, WX1, 50)
local plb = {}
plinth:each(function(x, y) if x % 7 == 0 then plb[K(x, y)] = -2 end end)
A.shade(c, plinth, X.pillow(plinth, 1), STN, { amb = 0.1, wrap = 0.3, bias = plb, tok = stok })

-- display window: oak frame, glass with rim + pale core + reflection, mullion cross, goods on the sill
local frame = c:rect(17, 32, 32, 45)
A.shade(c, frame, X.pillow(frame, 1.5), WD, { amb = 0.1, wrap = 0.3, tok = ptok })
local glass = c:rect(19, 34, 30, 43)
glass:each(function(x, y)
  local d = min(x - 19, 30 - x, y - 34, 43 - y)
  local tone = d == 0 and ((x == 19 or y == 34) and 2 or 1) or (d == 1 and 3 or 4)
  if (x - 19) + (y - 34) < 4 then tone = 5 end
  c:put(x, y, GL[tone], gtok)
end)
for i = 0, 5 do c:put(20 + i, 41 - i, GL[6], gtok) c:put(21 + i, 41 - i, GL[5], gtok) end
for i = 0, 2 do c:put(27 + i, 42 - i, GL[5], gtok) end
for y = 34, 43 do c:put(24, y, WD[3], ptok) c:put(25, y, WD[4], ptok) end
for x = 19, 30 do c:put(x, 38, WD[4], ptok) end
for x = 16, 33 do c:put(x, 45, WD[5], ptok) c:put(x, 46, WD[2], ptok) end
A.map(c, { ".bab.", "babbc", "bbbcc", ".ccd." }, 19, 40, { a = "#7cc35a", b = "#f5a03a", c = "#d06a22", d = "#8f4a1f" }, gtok)
A.map(c, { "eee", "aba", "abc", "bcc" }, 27, 40, { e = "#f5b82e", a = "#ff6a6a", b = "#c9393e", c = "#7d2038" }, gtok)

-- door: arched head, planks, recess shade, brass knob
local door = c:rect(36, 35, 45, 50):add(A.ellM(40.5, 35, 4.5, 3.2))
local dframe = door:grow(1):clip(c:rect(35, 30, 46, 50))
A.shade(c, dframe, X.pillow(dframe, 1.5), WD, { amb = 0.1, wrap = 0.3, tok = ptok })
local db = {}
door:each(function(x, y) local k = K(x, y)
  if x == 39 or x == 42 then db[k] = -1 end
  if y <= 33 or x <= 37 then db[k] = (db[k] or 0) - 1 end
end)
local dn = flat(door)
A.bulge(dn, 39, 40, 8, 14, 0.4)
A.shade(c, door, dn, { "#3a1e22", "#55302a", "#74442e", "#93573a", "#b0703f", "#c88a52" }, { amb = 0.1, wrap = 0.3, bias = db, tok = dtok })
c:put(43, 43, "#ffd96a", dtok) c:put(44, 43, "#c48a26", dtok) c:put(43, 44, "#8f5a1f", dtok)
local step = c:rect(34, 51, 47, 52)
A.shade(c, step, X.pillow(step, 1), STN, { amb = 0.1, wrap = 0.3, tok = stok })

-- roof: mansard trapezoid of scalloped shingle courses
local roof = c:poly{ { 17, 13 }, { 46, 13 }, { 51, 22 }, { 12, 22 } }
local rn = X.pillow(roof, 1.6)
A.bulge(rn, 32, 17, 20, 10, 0.25)
local rb = {}
roof:each(function(x, y) local k = K(x, y)
  local ly = (y - 14) % 3
  local row = floor((y - 14) / 3)
  local ph = (x + (row % 2) * 2) % 4
  if ly == 2 then rb[k] = -2 end
  if ly ~= 2 and ph == 0 then rb[k] = -1 end
  if ly == 0 and ph == 1 then rb[k] = 1 end
end)
A.shade(c, roof, rn, PL, { amb = 0.1, wrap = 0.3, bias = rb, tok = rtok })
for x = 17, 46 do c:put(x, 13, x < 30 and PL[6] or PL[5], rtok) end

-- awning: vertical stripes, scalloped hem
local AX0 = 11
local aw = c:rect(AX0, 22, AX0 + 41, 27)
for i = 0, 6 do aw:add(A.ellM(AX0 + i * 6 + 2.5, 27.5, 2.6, 1.9)) end
local an, ab = {}, {}
aw:each(function(x, y) local k = K(x, y)
  local u = ((x - AX0) % 6 + 0.5) / 6 * 2 - 1
  local fy = (y - 22) / 7
  an[k] = { A.norm(u * 0.7 - 0.05, -0.6 + fy * 0.9, 0.75) }
  if y <= 23 then ab[k] = -1 end
  if y >= 29 then ab[k] = (ab[k] or 0) - 1 end
end)
local redM, crM = HP.mask(), HP.mask()
aw:each(function(x, y) if floor((x - AX0) / 6) % 2 == 0 then redM:set(x, y) else crM:set(x, y) end end)
A.shade(c, redM, an, RD, { amb = 0.12, wrap = 0.35, bias = ab, tok = atok, cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 } })
A.shade(c, crM, an, CRM, { amb = 0.14, wrap = 0.35, bias = ab, tok = atok, cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 } })
for x = AX0, AX0 + 41 do c:put(x, 26, ((floor((x - AX0) / 6) % 2 == 0) and RD[2] or CRM[2]), atok) end
A.save(c, "ico-shop")
