-- cane-syrup (final, Opus single pass, replaces the Sonnet jar draft). A slim, tall glass bottle (round shoulders, narrow
-- neck, flared lip) two-thirds full of dark amber cane syrup. Glass: per-pixel cylinder light, a bright rim on the lit
-- edge, a long vertical specular streak, a pale empty headspace. Syrup: 6-tone deep amber with the warm inner glow light
-- makes on the far side of a filled bottle, and a lit meniscus line. A cork with end grain, a twisted twine wrap with a
-- loose tail, a cream paper label (curved with the bottle) with a little sugar-cane stalk drawn on it, ground shadow.
-- quirk: a fat drip of syrup has escaped down the neck and is about to fall off the shoulder.
local NAME = "cane-syrup"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new(NAME)

local GLASS = { "#2a4a6a", "#3e7090", "#69a4b8", "#9ccfd2", "#c8eae2", "#eefaf2" }
local SYR   = { "#3a120e", "#621e12", "#913414", "#c0561a", "#e4832a", "#ffbe58" }
local CORK  = { "#51302b", "#744630", "#9a6a44", "#c0925e", "#dcb682", "#f0d8a8" }
local TWINE = { "#6a4a2a", "#a07a46", "#d2ae70", "#ecd49a" }
local PAPER = { "#a8907c", "#cdb89c", "#e8d8b8", "#f8ecd2", "#fff4e0" }
local CANE  = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local SPEC  = "#fffbea"

local CX = 31.5
local function hw(y)
  if y < 11 then return -1 end
  if y <= 12 then return 4.0 end                  -- lip
  if y <= 18 then return 2.9 end                  -- neck
  if y <= 26 then local t = (y - 18) / 8 return 2.9 + (9.6 - 2.9) * sin(t * pi / 2) ^ 0.8 end
  if y <= 51 then return 9.6 end
  if y <= 54 then return 9.6 - ({ 0.4, 1.2, 2.6 })[y - 51] end
  return -1
end
local FILL = 29
c:groundShadow(32, 55, 13, 2)
local bottle = HP.mask()
local n, S = {}, {}
for y = 11, 54 do local w = hw(y) for x = floor(CX - w - 0.5) + 1, floor(CX + w + 0.5) - 1 do
  local s = (x - CX) / (w + 0.3)
  if abs(s) <= 1.02 then
    bottle:set(x, y)
    local sn = max(-0.96, min(0.96, s))
    local ny = 0
    if y > 18 and y <= 26 then ny = -0.55 * (1 - (y - 18) / 8) end
    if y > 51 then ny = 0.4 end
    n[K(x, y)] = { A.norm(sn, ny, sqrt(1 - sn * sn)) } S[K(x, y)] = sn
  end
end end
local syrup, glass = HP.mask(), HP.mask()
bottle:each(function(x, y) if y >= FILL and abs(S[K(x, y)]) < 0.86 and y < 52 then syrup:set(x, y) else glass:set(x, y) end end)
local gtok, stok = { r = { name = "glass" } }, { r = { name = "syrup" } }
local gi = A.shade(c, glass, n, GLASS, { amb = 0.2, wrap = 0.35, cuts = { 0.2, 0.36, 0.52, 0.7, 0.88 }, tok = gtok })
-- the glass walls around the syrup: tinted amber-dark
glass:each(function(x, y) if y >= FILL and y < 52 then
  local i = gi[K(x, y)] c:put(x, y, i >= 4 and SYR[5] or SYR[2], gtok) end end)
local si = A.shade(c, syrup, n, SYR, { amb = 0.1, wrap = 0.2, cuts = { 0.22, 0.4, 0.56, 0.72, 0.9 }, tok = stok })
-- inner glow on the far (right) side, lower body
syrup:each(function(x, y) local s = S[K(x, y)]
  if s > 0.25 and s < 0.7 and y > FILL + 6 and y < 52 then
    local g = (y > FILL + 12 and s > 0.35 and s < 0.6) and 3 or 2
    c:put(x, y, SYR[min(6, si[K(x, y)] + g)], stok) end end)
-- meniscus
for x = floor(CX - 8), floor(CX + 8) do if syrup:has(x, FILL) then c:put(x, FILL, abs(x - CX) < 6 and SYR[6] or SYR[4], stok) end end
-- glass base: thick bottom
for x = floor(CX - 9), floor(CX + 9) do for y = 52, 54 do if bottle:has(x, y) then
  c:put(x, y, y == 52 and GLASS[3] or (x < CX and GLASS[2] or GLASS[1]), gtok) end end end
-- bright rim on lit edge + specular streak
bottle:each(function(x, y) local s = S[K(x, y)]
  if s < -0.86 and y > 12 and y < 52 then c:put(x, y, y < FILL and GLASS[6] or SYR[5], gtok) end
  if s > -0.62 and s < -0.46 and ((y > 22 and y < 27) or (y > 31 and y < 51 and y ~= 37 and y ~= 38)) then c:put(x, y, (y > 33 and y < 46) and SPEC or GLASS[6], gtok) end
end)
c:put(floor(CX - 2), 13, GLASS[6], gtok) c:put(floor(CX - 2), 14, GLASS[6], gtok)

-- label (curves with the bottle): rows 37..48
local ltok = { r = { name = "label" } }
local lab = HP.mask()
for y = 37, 48 do for x = floor(CX - 7), floor(CX + 7) do
  local dy = 0.35 * ((x - CX) / 9.6) ^ 2 * 3
  if y + 0 >= 37 + floor(dy) and y <= 48 + floor(dy) then lab:set(x, y) end end end
lab:each(function(x, y) local s = S[K(x, y)] or 0
  local i = s < -0.55 and 4 or (s < 0.05 and 5 or (s < 0.5 and 4 or (s < 0.75 and 3 or 2)))
  c:put(x, y, PAPER[i], ltok) end)
lab:each(function(x, y)
  if not lab:has(x, y - 1) then c:put(x, y, PAPER[2], ltok) end
  if not lab:has(x, y + 1) then c:put(x, y, PAPER[1], ltok) end end)
-- tiny sugar-cane drawing on the label: two stalks with nodes + a leaf
local lx = floor(CX) - 1
for y = 39, 46 do c:put(lx, y, CANE[3], ltok) c:put(lx + 1, y, CANE[2], ltok) end
for y = 41, 46 do c:put(lx + 3, y, CANE[2], ltok) end
for _, y in ipairs{ 41, 44 } do c:put(lx, y, CANE[1], ltok) c:put(lx + 1, y, CANE[1], ltok) end
c:put(lx + 3, 43, CANE[1], ltok)
A.map(c, { "a.....", ".ab...", "..b.cd" }, lx - 3, 38, { a = CANE[2], b = CANE[3], c = CANE[3], d = CANE[2] }, ltok)

-- cork
local cork = c:rect(floor(CX - 2), 6, floor(CX + 2) + 1, 11)
local ctok = { r = { name = "cork" } }
local cn = {}
cork:each(function(x, y) local s = (x - CX) / 3.2 s = max(-0.95, min(0.95, s)) cn[K(x, y)] = { s, y == 6 and -0.8 or 0, sqrt(1 - s * s) } end)
local ci = A.shade(c, cork, cn, CORK, { amb = 0.15, wrap = 0.3, tok = ctok })
for x = floor(CX - 1), floor(CX + 2) do c:put(x, 6, x < CX + 1 and CORK[6] or CORK[5], ctok) end
c:put(floor(CX), 8, CORK[2], ctok) c:put(floor(CX + 1), 9, CORK[3], ctok) c:put(floor(CX - 1), 10, CORK[3], ctok)
for x = floor(CX - 3), floor(CX + 3) + 1 do if bottle:has(x, 11) then c:put(x, 11, CORK[1], ctok) end end -- AO under cork

-- twine wrap at the neck (rows 14-16) with twist, and a loose tail on the right
local ttok = { r = { name = "twine" } }
for y = 14, 16 do for x = floor(CX - 3), floor(CX + 3) + 1 do
  if bottle:has(x, y) or x == floor(CX - 3) or x == floor(CX + 3) + 1 then
    local ph = (x + y * 2) % 3
    local col = ph == 0 and TWINE[1] or (x < CX and TWINE[4] or TWINE[3])
    if ph ~= 0 and x > CX + 1.5 then col = TWINE[2] end
    c:put(x, y, col, ttok)
  end end end
for x = floor(CX - 3), floor(CX + 3) + 1 do if bottle:has(x, 17) then A.step(c, gi, GLASS, x, 17, -2, gtok) end end
A.map(c, { "ab.", ".ab", ".ab", "..a", ".ab", ".a." }, floor(CX + 4), 16, { a = TWINE[1], b = TWINE[3] }, ttok)

-- quirk: the drip, down the neck's left side and bulging on the shoulder
local dtok = { r = { name = "drip" } }
local DX = floor(CX - 3)
for y = 12, 13 do c:put(DX, y, SYR[3], dtok) end
for y = 17, 21 do c:put(DX, y, SYR[3], dtok) end
c:put(DX - 1, 21, SYR[4], dtok)
A.map(c, { ".bd", "aed", "ccd", ".d." }, DX - 3, 21, { a = SYR[6], b = SYR[4], c = SYR[3], d = SYR[2], e = SPEC }, dtok)

A.save(c, NAME)
