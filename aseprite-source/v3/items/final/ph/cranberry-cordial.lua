-- cranberry-cordial (final, Opus single pass). A tall slim glass bottle: cork stopper, rolled lip, narrow neck tied
-- with twisted twine, round shoulders, filled to the shoulder with deep ruby cordial; a cream wrap-round label.
-- Material: glass = bright left rim, pale cool core in the empty neck, long specular streak + short echo, dark
-- right edge; liquid = 6-tone ruby with a meniscus line and a glowing lit-through patch lower-right; cork = pores
-- and a pale top face; twine = 2-tone alternating twist with a frayed tail; label = cylinder-shaded paper with a
-- berry mark. Ground shadow (2-tone) under it.
-- quirk: one sticky drip has run down the neck and stopped on the twine.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB22_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("cranberry-cordial")
local GL   = { "#34405e", "#526a8c", "#7e9cb8", "#aecadb", "#d6eaee", "#f2faf4" }
local LIQ  = { "#3c0b28", "#661230", "#911b38", "#ba283f", "#de474d", "#ff8a78" }
local CORK = { "#4a2e22", "#6e4630", "#946240", "#b8844f", "#d6a86c", "#efcd92" }
local PAP  = { "#8a6650", "#b8916c", "#dcbf90", "#f0dcb0", "#fbecc8" }
local TW   = { "#6a4528", "#a8794a", "#dcb074" }
local CX = 32
c:groundShadow(CX, 55, 12, 1)

-- profile: half width per row
local function hw(y)
  if y < 6 then return nil end
  if y <= 12 then return y == 6 and 2 or 2 end           -- cork
  if y <= 14 then return 4 end                              -- rolled lip
  if y <= 24 then return 3 end                              -- neck
  if y <= 31 then local t = (y - 24) / 7 return floor(3 + 6 * sqrt(1 - (1 - t) ^ 2) + 0.5) end -- shoulder
  if y <= 51 then return 9 end
  if y == 52 then return 8 end
  if y == 53 then return 7 end
  return nil
end
local LIQTOP = 33
local cork, glass, liq = HP.mask(), HP.mask(), HP.mask()
local n, S = {}, {}
for y = 6, 53 do local w = hw(y)
  for x = CX - w, CX + w do
    local s = (x - CX) / (w + 0.5)
    local k = K(x, y)
    local ny = (y > 24 and y <= 31) and -0.55 or (y >= 52 and 0.5 or 0)
    n[k] = { A.norm(s, ny, sqrt(max(0.05, 1 - s*s))) }
    S[k] = s
    if y <= 12 then cork:set(x, y) elseif y >= LIQTOP then liq:set(x, y) else glass:set(x, y) end
  end
end
-- cork
local ctok = { r = { name = "cork" } }
local cidx = A.shade(c, cork, n, CORK, { tok = ctok, amb = 0.15, wrap = 0.3 })
cork:each(function(x, y) if X.hash(x, y, 5) < 0.18 and y > 6 then A.step(c, cidx, CORK, x, y, -2, ctok) end end)
for x = CX - 1, CX + 1 do c:put(x, 6, CORK[6], ctok) end
c:put(CX + 2, 6, CORK[4], ctok) c:put(CX - 2, 6, CORK[5], ctok)
for x = CX - 2, CX + 2 do c:put(x, 12, CORK[2], ctok) end        -- AO where cork enters the lip

-- empty glass (lip, neck, shoulder top): pale cool core, bright left rim, dark right edge
local gtok = { r = { name = "glass" } }
local gidx = A.shade(c, glass, n, GL, { tok = gtok, amb = 0.35, wrap = 0.4, cuts = { 0.15, 0.3, 0.45, 0.62, 0.8 } })
glass:each(function(x, y) local s = S[K(x, y)]
  if s < -0.7 then c:put(x, y, GL[6], gtok) elseif s > 0.7 then c:put(x, y, GL[2], gtok)
  elseif abs(s) < 0.4 then c:put(x, y, GL[5], gtok) end end)
for x = CX - 4, CX + 4 do c:put(x, 13, x < CX and GL[6] or GL[4], gtok) c:put(x, 14, x < CX + 2 and GL[3] or GL[2], gtok) end
-- liquid
local qtok = { r = { name = "liquid" } }
local bias = {}
liq:each(function(x, y) if y >= 52 then bias[K(x, y)] = -1 end end)
local qidx = A.shade(c, liq, n, LIQ, { tok = qtok, amb = 0.06, wrap = 0.25, bias = bias })
-- lit-through glow lower-right
liq:each(function(x, y) local s = S[K(x, y)]
  if s > 0.35 and s < 0.75 and y > 41 and y < 51 then A.step(c, qidx, LIQ, x, y, 2, qtok) end end)
-- meniscus
for x = CX - 8, CX + 8 do c:put(x, LIQTOP, x < CX + 4 and LIQ[5] or LIQ[4], qtok) end
c:put(CX - 9, LIQTOP, LIQ[6], qtok)
-- left glass rim over the liquid
liq:each(function(x, y) if S[K(x, y)] < -0.85 and y < 52 then c:put(x, y, LIQ[5], qtok) end end)

-- label (wraps the cylinder)
local ptok = { r = { name = "label" } }
for y = 39, 47 do for x = CX - 7, CX + 7 do
  local s = (x - CX) / 9.5
  local v = 0.82 - (s + 0.3) * 0.75
  local i = v > 0.85 and 5 or v > 0.62 and 4 or v > 0.4 and 3 or v > 0.2 and 2 or 1
  if y == 39 or y == 47 then i = max(1, i - 1) end
  c:put(x, y, PAP[i], ptok)
end end
-- berry mark: three tiny berries and a leaf
local mark = { "...gG..", "..g....", ".r.r...", "rRr.r..", ".r.rRr.", "....r.." }
A.map(c, mark, CX - 3, 40, { r = LIQ[4], R = LIQ[6], g = "#3c7e41", G = "#6fa94b" }, ptok)
-- label line
for x = CX - 4, CX + 3 do if x % 2 == 0 then c:put(x, 46, PAP[2], ptok) end end

-- specular streak (glass over everything)
local stok = gtok
for y = 26, 50 do if y < 39 or y > 47 then
  local x = CX - 6 - (y < 31 and floor((31 - y) / 2) or 0)
  if hw(y) and x >= CX - hw(y) + 1 then c:put(x, y, y < LIQTOP and GL[6] or "#ffc9bc", stok) end
end end
for y = 49, 51 do c:put(CX - 4, y, "#ffc9bc", stok) end
c:put(CX - 6, 36, "#fff1cf", stok)
for y = 16, 22 do c:put(CX - 2, y, GL[6], stok) end

-- twine around the neck, twisted, frayed tail
local ttok = { r = { name = "twine" } }
for y = 20, 21 do for x = CX - 4, CX + 4 do
  local i = ((x + y) % 2 == 0) and 3 or 2
  if x > CX + 2 then i = i - 1 end
  c:put(x, y, TW[i], ttok)
end end
c:put(CX + 5, 21, TW[2], ttok) c:put(CX + 5, 22, TW[3], ttok) c:put(CX + 6, 23, TW[2], ttok)
c:put(CX + 6, 24, TW[1], ttok) c:put(CX + 4, 22, TW[2], ttok) c:put(CX + 4, 23, TW[1], ttok)

-- quirk: a drip down the neck from the lip, stopped on the twine
c:put(CX + 1, 15, LIQ[3], qtok) c:put(CX + 1, 16, LIQ[4], qtok) c:put(CX + 1, 17, LIQ[4], qtok)
c:put(CX + 1, 18, LIQ[3], qtok) c:put(CX + 2, 18, LIQ[2], qtok) c:put(CX + 1, 19, LIQ[2], qtok) c:put(CX + 2, 19, LIQ[1], qtok)
c:put(CX + 1, 16, LIQ[6], qtok)
A.save(c, "cranberry-cordial")
