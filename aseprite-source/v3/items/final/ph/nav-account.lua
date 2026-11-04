-- nav-account (final, Opus single pass). Bold nav icon: a bevelled steel cog (eight tapered teeth, machined groove
-- ring, bright edge and specular on the lit teeth, recessed inner bevel) holding a domed brass medallion that shows
-- the player's gnome: red pointed hat, skin face with a lit nose, cream beard. Reads at 16 px as "cog + red hat".
-- quirk: the gnome's floppy hat tip spills over the medallion rim and drapes across the cog.
local NAME = "nav-account"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC25_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)

local STEEL = { "#2c2d47", "#4a4c6a", "#6f718e", "#9a9cb4", "#c6c7d8", "#eceaf2" }
local GOLD = { "#5a2f1c", "#8f4a1f", "#c47324", "#e8a133", "#f8cd5c", "#fff0a8" }
local HAT = { "#4e1630", "#7c2238", "#b02f3c", "#e04a3c", "#ff8a5c", "#ffc09a" }
local SKIN = { "#7a4036", "#c98462", "#f0b98d", "#ffe0bd" }
local BEARD = { "#8d8496", "#cfc7cf", "#ece4dc", "#fff4d6" }
local CX, CY = 32, 32

-- cog mask
local cog = HP.mask()
for y = CY - 23, CY + 23 do for x = CX - 23, CX + 23 do
  local dx, dy = x - CX, y - CY
  local r = sqrt(dx * dx + dy * dy)
  local ok = r <= 14.8
  if not ok and r <= 21.3 then
    for i = 0, 7 do
      local a = i * pi / 4
      local ax, ay = cos(a), sin(a)
      local along = dx * ax + dy * ay
      local perp = abs(-dx * ay + dy * ax)
      local hw = 4.1 - (along - 14) * 0.2
      if along > 0 and perp <= hw then ok = true break end
    end
  end
  if ok then cog:set(x, y) end
end end
local MR = 9.6
local med = HP.mask()
cog:each(function(x, y) if (x - CX)^2 + (y - CY)^2 <= MR * MR then med:set(x, y) end end)
local steel = cog:copy():cut(med)
local n = X.pillow(steel, 3)
-- recess: inner ring slopes down toward the medallion (normal points inward)
steel:each(function(x, y)
  local dx, dy = x - CX, y - CY
  local r = sqrt(dx * dx + dy * dy)
  if r < MR + 1.6 then n[K(x, y)] = { A.norm(-dx / r * 0.8, -dy / r * 0.8, 0.6) } end
end)
local stok = { r = { name = "steel" } }
local sidx = A.shade(c, steel, n, STEEL, { tok = stok, amb = 0.1, wrap = 0.3 })
-- machined groove ring + bright bevel line just outside it
steel:each(function(x, y)
  local dx, dy = x - CX, y - CY
  local r = sqrt(dx * dx + dy * dy)
  if abs(r - 12.9) < 0.5 then A.step(c, sidx, STEEL, x, y, -1, stok)
  elseif abs(r - 13.9) < 0.45 and (dx + dy) < -2 then A.step(c, sidx, STEEL, x, y, 1, stok) end
end)
-- specular on the upper-left tooth tip and a bright edge
for _, q in ipairs{ { CX - 13, CY - 14 }, { CX - 14, CY - 13 }, { CX - 12, CY - 15 }, { CX - 1, CY - 20 }, { CX - 20, CY - 1 } } do
  if steel:has(q[1], q[2]) then c:put(q[1], q[2], STEEL[6], stok) end
end
c:put(CX - 13, CY - 13, "#fff4d6", stok)

-- brass medallion dome
local gtok = { r = { name = "medal" } }
local mn = X.sphere(CX, CY, MR + 3, med)
local midx = A.shade(c, med, mn, GOLD, { tok = gtok, amb = 0.12, wrap = 0.3 })
med:edge():each(function(x, y) if (x - CX) + (y - CY) > 2 then c:put(x, y, GOLD[2], gtok) else c:put(x, y, GOLD[5], gtok) end end)

-- gnome: beard, face, nose, hat (hat tip spills out over the cog = quirk)
local btok, ftok, htok = { r = { name = "beard" } }, { r = { name = "face" } }, { r = { name = "hat" } }
local beard = HP.mask()
for y = CY + 1, CY + 8 do local w = 4.6 - (y - CY - 1) * 0.55 for x = floor(CX - w + .5), floor(CX + w + .5) do beard:set(x, y) end end
beard:clip(med)
beard:each(function(x, y)
  local i = (x < CX - 1) and 4 or (x < CX + 2) and 3 or 2
  if y == CY + 1 then i = 2 end
  if (x + y) % 4 == 0 and y > CY + 2 then i = max(1, i - 1) end -- wavy strands
  c:put(x, y, BEARD[i], btok)
end)
local face = HP.mask()
for y = CY - 2, CY + 1 do for x = CX - 4, CX + 4 do
  if ((x - CX) / 4.4)^2 + ((y - CY + 0.5) / 2.2)^2 <= 1 then face:set(x, y) end end end
face:each(function(x, y) c:put(x, y, x < CX - 1 and SKIN[4] or x < CX + 3 and SKIN[3] or SKIN[2], ftok) end)
-- eyes (2x? small pills) and nose
c:put(CX - 2, CY - 1, A.INK, ftok) c:put(CX + 2, CY - 1, A.INK, ftok)
for _, q in ipairs{ { CX, CY, "#ffb4a0" }, { CX - 1, CY, "#f08a74" }, { CX, CY + 1, "#c95f52" }, { CX + 1, CY, "#c95f52" }, { CX - 1, CY + 1, "#c95f52" } } do
  c:put(q[1], q[2], q[3], ftok) end
c:put(CX - 4, CY, "#f5809f", ftok) c:put(CX + 4, CY, "#f5809f", ftok)
-- hat: brim band + cone that curls over to the upper right
local hm, hn, HT, HS = A.tube({ { CX, CY - 3 }, { CX - 1, CY - 9 }, { CX + 4, CY - 13 }, { CX + 11, CY - 13 } },
  function(t) return max(0.7, 5.2 * (1 - t) ^ 0.9) end)
local brim = HP.mask()
for x = CX - 6, CX + 6 do brim:set(x, CY - 3) brim:set(x, CY - 4) end
hm:add(brim)
for x = CX - 6, CX + 6 do hm.s[K(x, CY - 2)] = nil end
hm:each(function(x, y) if not hn[K(x, y)] then hn[K(x, y)] = { A.norm((x - CX) / 7, 0.2, 0.9) } end end)
-- contact shadow of the hat on what is under it
hm:shift(1, 1):each(function(x, y)
  if not hm:has(x, y) then
    if med:has(x, y) and not face:has(x, y) then A.step(c, midx, GOLD, x, y, -2, gtok)
    elseif steel:has(x, y) then A.step(c, sidx, STEEL, x, y, -2, stok) end
  end
end)
local hidx = A.shade(c, hm, hn, HAT, { tok = htok, amb = 0.12, wrap = 0.3 })
-- brim band a step darker with a lit top edge, fold crease on the cone
for x = CX - 6, CX + 6 do
  local i = x < CX - 2 and 4 or x < CX + 3 and 3 or 2
  c:put(x, CY - 3, HAT[i], htok) c:put(x, CY - 4, HAT[i + 1], htok)
end
for _, q in ipairs{ { CX - 2, CY - 9 }, { CX - 1, CY - 10 }, { CX, CY - 11 } } do if hm:has(q[1], q[2]) then c:put(q[1], q[2], HAT[6], htok) end end
for _, q in ipairs{ { CX + 3, CY - 10 }, { CX + 4, CY - 11 } } do if hm:has(q[1], q[2]) then c:put(q[1], q[2], HAT[2], htok) end end

A.save(c, NAME)
