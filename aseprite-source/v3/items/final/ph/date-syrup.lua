-- date-syrup (final, Opus single pass). A slim tall glass bottle (long neck, sloped shoulders) full of dark glossy
-- date syrup: glass wall with a bright rim and pale core streak, cool bounce on the shade side, an empty glass band
-- above the meniscus, a wood-grain cork with a pale end grain, twisted twine round the neck, ground shadow.
-- quirk: a fat drip of syrup has run from the lip down the neck and hangs as a bead on the shoulder.
local NAME = "date-syrup"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new(NAME)
local SYR = { "#2e120e", "#4f1d12", "#7a3014", "#a84a18", "#d6782a", "#ffb850" }
local GLS = { "#3e5a78", "#5f87a6", "#8fb8cc", "#c4e2e6", "#eaf8f2" }
local CORK = { "#51302b", "#7a4a32", "#a8703f", "#cf9a5e", "#ecc690" }
local TW = { "#8f6a3a", "#c9a368", "#ead2a0" }
local CX = 32

-- profile: half width per row
local function hw(y)
  if y < 10 then return nil end
  if y <= 15 then return 3.2 end                                  -- cork
  if y <= 17 then return 4.2 end                                  -- lip
  if y <= 27 then return 3.5 end                                  -- neck
  if y <= 35 then local t = (y - 27) / 8 return 3.5 + 6.9 * (1 - (1 - t) ^ 2) end -- shoulder
  if y <= 52 then return 10.4 end
  if y <= 55 then return 10.4 - ({ 0.6, 1.4, 2.6 })[y - 52] end   -- rounded heel
  return nil
end
local body, cork = HP.mask(), HP.mask()
for y = 10, 55 do local w = hw(y) for x = floor(CX - w - 0.5) + 1, floor(CX + w + 0.5) - 1 do
  if y <= 15 then cork:set(x, y) else body:set(x, y) end end end

-- ground shadow (stands)
c:groundShadow(CX + 2, 56, 13, 2)

-- glass + syrup normals: vertical cylinder, tilt up on the shoulder
local n, inner, glass = {}, HP.mask(), HP.mask()
body:each(function(x, y)
  local w = hw(y)
  local u = max(-0.98, min(0.98, (x + 0.5 - CX) / (w + 0.3)))
  local ny = 0
  if y > 27 and y <= 35 then ny = -0.55 elseif y >= 53 then ny = 0.5 elseif y <= 17 then ny = -0.2 end
  local nz = sqrt(max(0.02, 1 - u * u))
  local l = sqrt(u * u + ny * ny + nz * nz)
  n[K(x, y)] = { u / l, ny / l, nz / l }
  if body:has(x - 1, y) and body:has(x + 1, y) and body:has(x, y + 1) and y >= 18 then inner:set(x, y) else glass:set(x, y) end
end)
local MEN = 22 -- meniscus row
local syr, air = HP.mask(), HP.mask()
inner:each(function(x, y) if y > MEN then syr:set(x, y) else air:set(x, y) end end)
local v = X.light(n, { amb = 0.05, wrap = 0.2 })
local gtok, stok = { r = { name = "glass" } }, { r = { name = "syrup" } }
X.tone(c, glass, v, GLS, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = gtok })
-- syrup: deep inside, glows warm where light passes through the lower-right (back-lit caustic)
local sv = {}
syr:each(function(x, y) local k = K(x, y)
  local nn = n[k]
  local through = max(0, nn[1] * 0.6 + 0.3) * ((y - 30) / 24)       -- transmitted glow lower right
  sv[k] = 0.2 + 0.5 * v[k] + through * 0.45
end)
X.tone(c, syr, sv, SYR, { cuts = { 0.22, 0.32, 0.45, 0.6, 0.78 }, tok = stok })
-- empty glass band above the syrup
air:each(function(x, y) local u = (x + 0.5 - CX) / 3 c:put(x, y, u < -0.2 and GLS[4] or GLS[3], gtok) end)
-- meniscus: lit lip curving up at the walls
syr:each(function(x, y) if y == MEN + 1 then c:put(x, y, (x < CX) and SYR[6] or SYR[5], stok) end end)
-- pale core streak and bright rim (glass cue), syrup reads through
for y = 33, 50 do c:put(CX - 6, y, (y < 36 or y > 47) and SYR[4] or "#ffd690", stok) end
for y = 37, 45 do c:put(CX - 5, y, SYR[6], stok) end
for y = 18, 26 do c:put(CX - 2, y, GLS[5], gtok) end
c:put(CX - 6, 31, A.CREAM, gtok) c:put(CX - 7, 32, A.CREAM, gtok)                  -- shoulder glint
for y = 38, 52 do c:put(CX + 9, y, "#6fa4b8", gtok) end                              -- cool bounce
-- base: thick glass heel, AO at the bottom of the syrup
for x = CX - 8, CX + 8 do if syr:has(x, 52) then c:put(x, 52, SYR[2], stok) end end
-- lip ring bevel
for x = CX - 4, CX + 4 do if body:has(x, 16) then c:put(x, 16, x < CX - 1 and GLS[5] or (x > CX + 2 and GLS[2] or GLS[4]), gtok) end end

-- cork: wood grain lines, pale end grain on top, AO into the lip
local ctok = { r = { name = "cork" } }
local cn = {}
cork:each(function(x, y) local u = (x + 0.5 - CX) / 3.5 cn[K(x, y)] = { u, 0, sqrt(max(0.05, 1 - u * u)) } end)
local cidx = X.tone(c, cork, X.light(cn, { amb = 0.1, wrap = 0.3 }), CORK, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = ctok })
cork:each(function(x, y) local k = K(x, y)
  if y == 10 then c:put(x, y, x < CX + 1 and CORK[5] or CORK[4], ctok)
  elseif y == 15 then c:put(x, y, CORK[1], ctok)
  elseif X.hash(x, y, 11) > 0.72 then c:put(x, y, CORK[max(1, cidx[k] - 1)], ctok) end
end)
c:put(CX - 1, 10, A.CREAM, ctok)

-- twine twist round the neck (rows 19-20), short tail hanging right
local ttok = { r = { name = "twine" } }
for x = CX - 3, CX + 3 do for y = 19, 20 do
  local ph = (x + y) % 3
  c:put(x, y, ph == 0 and TW[1] or (ph == 1 and TW[2] or TW[3]), ttok) end end
c:put(CX + 4, 20, TW[2], ttok) c:put(CX + 5, 21, TW[1], ttok) c:put(CX + 5, 22, TW[2], ttok) c:put(CX + 6, 23, TW[1], ttok)
-- AO under the twine
for x = CX - 2, CX + 2 do c:put(x, 21, GLS[2], gtok) end

-- quirk: drip from the lip, down the left neck, swelling into a bead on the shoulder
local dtok = { r = { name = "drip" } }
for y = 17, 28 do c:put(CX - 4, y, SYR[y % 3 == 0 and 6 or 5], dtok) end
for _, q in ipairs{ { CX - 5, 28, 5 }, { CX - 5, 29, 6 }, { CX - 4, 29, 5 }, { CX - 6, 30, 5 }, { CX - 5, 30, 5 }, { CX - 4, 30, 4 },
  { CX - 6, 31, 4 }, { CX - 5, 31, 4 }, { CX - 4, 31, 3 }, { CX - 5, 32, 3 } } do c:put(q[1], q[2], SYR[q[3]], dtok) end
c:put(CX - 6, 29, A.CREAM, dtok)
A.save(c, NAME)
