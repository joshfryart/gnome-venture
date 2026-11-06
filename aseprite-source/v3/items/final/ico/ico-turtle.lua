-- ico-turtle (final, Opus). A friendly box turtle plodding right in side view: high domed shell, slim neck and head
-- stretched forward, two stubby legs mid-step, pointed tail.
-- Material: per-pixel dome light on the amber shell (6-tone) with raised hex scutes (dark seams, lit upper lips,
-- concentric growth ring per scute), a separate marginal rim band with notched plates, pale plastron edge; pebbly
-- olive skin (pillow light, scale flecks); AO where the shell overhangs neck and legs; contact shadow under the shell.
-- quirk: it wears a tiny red knitted scarf whose end flaps back over the shell.
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR0_5.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = R.new("ico-turtle")
local SKIN  = { "#1f3d33", "#2f5a3c", "#4a7d44", "#6c9e4c", "#98c060", "#cde08a" }
local SHELL = { "#3a1e24", "#5c3028", "#84482c", "#ac6834", "#d08e42", "#f0be62" }
local RIM   = { "#3a2024", "#5a3226", "#7e4a2c", "#a26a34", "#c48c44", "#e2b468" }
local BELLY = { "#6a4a22", "#a87a30", "#d6a63e", "#f0c85a", "#ffe28a", "#fff0bc" }
local SCARF = { "#5e1a30", "#8e2434", "#c23a3a", "#e8593e", "#ff8a5c", "#ffb88a" }
local kt, ht, rt, bt, ft = { r = { name = "skin" } }, { r = { name = "shell" } }, { r = { name = "rim" } }, { r = { name = "belly" } }, { r = { name = "scarf" } }

c:groundShadow(31, 51, 21, 1)

---------------------------------------------------------------- legs, tail, neck + head (skin, under the shell)
local legB = HP.rrect(15, 38, 21, 50, 2)                 -- back leg (stepping back)
legB:add(HP.rect(13, 48, 21, 50))
local legF = HP.rrect(39, 38, 45, 50, 2)                 -- front leg
legF:add(HP.rect(39, 48, 47, 50))
local tail = c:poly{ { 14, 39 }, { 6.5, 44.5 }, { 15, 43 } }
local neck = select(1, X.cyl(43, 38, 51, 31, function(t) return 3.2 - t * 0.5 end))
local head = c:ellipse(53, 28.5, 5.5, 4.5)
head:add(c:ellipse(56.5, 30, 2.6, 2.6))                  -- snout
local skin = legB:copy():add(legF):add(tail):add(neck):add(head)
local sb = {}
local sidx, sn = R.pil(c, skin, SKIN, 2.4, { amb = 0.1, wrap = 0.3, tok = kt, bias = sb })
-- far-side leg darker (behind): back leg one step down
legB:each(function(x, y) R.step(c, sidx, SKIN, x, y, -1, kt) end)
-- toes: dark nicks at the foot front
for _, p in ipairs{ { 15, 50 }, { 18, 50 }, { 42, 50 }, { 45, 50 } } do R.step(c, sidx, SKIN, p[1], p[2], -2, kt) end
-- pebbly scale flecks on legs and neck
skin:each(function(x, y) if not head:has(x, y) and X.hash(x, y, 11) > 0.86 then R.step(c, sidx, SKIN, x, y, -1, kt) end end)
-- head: lighter jaw line, eye, nostril, smile
for x = 49, 58 do if head:has(x, 31) then R.step(c, sidx, SKIN, x, 31, 1, kt) end end
c:fillMask(HP.rect(53, 26, 54, 28), R.INK) c:put(53, 26, R.CREAM, kt)
c:put(58, 28, SKIN[1], kt)
for _, p in ipairs{ { 54, 31 }, { 55, 32 }, { 56, 32 }, { 57, 32 } } do c:put(p[1], p[2], SKIN[2], kt) end
c:put(51, 27, SKIN[3], kt) -- brow ridge
c:put(50, 25, SKIN[6], kt) c:put(51, 25, SKIN[6], kt)

---------------------------------------------------------------- shell dome
local CX, CY, RX, RY = 30, 37, 19, 17
local dome = c:ellipse(CX, CY, RX, RY):clip(HP.rect(0, 0, 63, CY - 1))
local dn = {}
dome:each(function(x, y)
  local nx, ny = (x + .5 - CX) / (RX + .5), (y + .5 - CY) / (RY + 1)
  local q = 1 - nx * nx - ny * ny
  dn[K(x, y)] = { R.norm(nx * 1.1, ny * 1.1, sqrt(max(q, 0.03)) * 0.85) }
end)
local hb = {}
local hidx = R.shade(c, dome, dn, SHELL, { amb = 0.05, wrap = 0.2, tok = ht, bias = hb, cuts = { 0.3, 0.47, 0.62, 0.76, 0.9 } })
-- scutes: centre vertebral hex + two costals each side; seams as dark lines, lit lip on each scute's upper-left
local seams = {
  { { 24, 24 }, { 36, 24 } }, { { 24, 24 }, { 21, 30 } }, { { 36, 24 }, { 39, 30 } }, { { 21, 30 }, { 24, 36 } }, { { 39, 30 }, { 36, 36 } },
  { { 24, 24 }, { 22, 20 } }, { { 36, 24 }, { 38, 20 } },
  { { 21, 30 }, { 13, 28 } }, { { 39, 30 }, { 47, 28 } },
  { { 22, 20 }, { 15, 25 } }, { { 38, 20 }, { 45, 25 } },
}
local sm = HP.mask()
for _, s in ipairs(seams) do sm:add(HP.line(s, 1)) end
sm:clip(dome)
sm:each(function(x, y) c:put(x, y, SHELL[min(2, hidx[K(x, y)] or 2)], ht) hidx[K(x, y)] = 2 end)
-- lit lip just below/right of each seam (raised scute edge)
sm:shift(1, 1):each(function(x, y) if dome:has(x, y) and not sm:has(x, y) then R.step(c, hidx, SHELL, x, y, 1, ht) end end)
-- growth rings: small inner hex outline in the centre and costal scutes
for _, r in ipairs{ { { 27, 27 }, { 33, 27 }, { 35, 30 }, { 33, 33 }, { 27, 33 }, { 25, 30 }, { 27, 27 } },
                    { { 15, 30 }, { 19, 31 } }, { { 41, 31 }, { 45, 30 } }, { { 24, 21 }, { 30, 21 } } } do
  HP.line(r, 1):clip(dome):each(function(x, y) if not sm:has(x, y) then R.step(c, hidx, SHELL, x, y, -1, ht) end end)
end
-- specular on the dome
do local bx, by = R.specAt(dome, dn, 30) c:put(bx, by, SHELL[6], ht) c:put(bx + 1, by, SHELL[6], ht) c:put(bx, by + 1, SHELL[6], ht) end

---------------------------------------------------------------- marginal rim + plastron
local rim = HP.rrect(9, 36, 51, 40, 2)
local rn = {}
rim:each(function(x, y) local ty = (y + .5 - 38) / 3 rn[K(x, y)] = { R.norm((x - 30) / 60, ty, 1 - abs(ty) * 0.4) } end)
local ridx = R.shade(c, rim, rn, RIM, { amb = 0.12, wrap = 0.3, tok = rt })
for x = 13, 49, 5 do for y = 37, 40 do if rim:has(x, y) then c:put(x, y, RIM[2], rt) end end end
rim:each(function(x, y) if y == 36 then R.step(c, ridx, RIM, x, y, 1, rt) end end)
-- dark seam where dome sits on the rim (AO)
dome:each(function(x, y) if y == CY - 1 then c:put(x, y, SHELL[1], ht) end end)
-- pale plastron edge peeking under the rim
local pl = HP.rect(14, 41, 44, 42)
pl:cut(legB):cut(legF)
pl:each(function(x, y) c:put(x, y, y == 41 and BELLY[4] or BELLY[3], bt) end)
-- AO on skin under the rim / plastron (legs + neck tucked under)
legF:copy():add(legB):add(neck):add(tail):each(function(x, y)
  if (rim:has(x, y - 1) or pl:has(x, y - 1) or dome:has(x - 1, y) or rim:has(x - 1, y)) and not rim:has(x, y) and not pl:has(x, y) and not dome:has(x, y) then
    R.step(c, sidx, SKIN, x, y, -2, kt) end
end)
for y = 43, 44 do for x = 39, 45 do if legF:has(x, y) then R.step(c, sidx, SKIN, x, y, -1, kt) end end end

---------------------------------------------------------------- quirk: knitted scarf on the neck, tail flapping back over the shell
local band = R.lmask(48.4, 33.0, 0.77, -0.64, 0.64, 0.77, function(a, b) return abs(a) <= 1.7 and abs(b) <= 4.3 end, 8)
local tailS = c:poly{ { 46, 34 }, { 49.5, 35 }, { 49, 43 }, { 46, 43 } }
local scarf = band:copy():add(tailS)
local fidx = R.pil(c, scarf, SCARF, 1.6, { amb = 0.12, wrap = 0.3, tok = ft })
-- knit ribs (diagonal) + fringe
scarf:each(function(x, y) if (x + y) % 3 == 0 then R.step(c, fidx, SCARF, x, y, -1, ft) end end)
for _, p in ipairs{ { 46, 43 }, { 48, 43 } } do c:put(p[1], p[2], SCARF[3], ft) end
-- contact shadow of the scarf tail on the shell
R.castOn(c, ridx, RIM, rim, tailS, 1, 1, -2, rt)
R.castOn(c, sidx, SKIN, legF, tailS, 1, 1, -2, kt)
scarf:grow(1):cut(scarf):each(function(x, y) if dome:has(x, y) then c:put(x, y, SHELL[1], ht) end end)
R.sepLine(c, band, tailS, SCARF[2], ft)

-- one cream sparkle on the shell
c:put(23, 26, R.CREAM, ht)
R.save(c, "ico-turtle")
