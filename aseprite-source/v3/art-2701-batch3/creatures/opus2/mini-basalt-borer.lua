-- mini-basalt-borer (81x49 still, side view, faces right). Opus second pass.
-- Kept from the game picture: violet basalt grub, segments growing toward the head, two swept horns,
-- two eyes on a big head, the ember crack (quirk). Fixed: the muddy segments are now separate faceted
-- basalt plates (lit top facet, flat side, dark underside, a deep gap between plates, small crystal
-- studs), the head is its own darker capsule with a clear face (eyes, brow, a pale boring jaw with a
-- notch), and stubby claw legs show under the front plates.
local NAME = "mini-basalt-borer"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local PLATE = R("#a690e0", "#6a55b4", "#4a3b8a", "#2f2558")
local HEAD = R("#8e78d4", "#55438e", "#3c2f6c", "#281f4a")
local HORN = R("#d8c8f8", "#a48ae0", "#7058b0", "#46367a")
local JAW = R("#f4e8d0", "#d4c4b4", "#a2949c", "#6c6278")
local LEG = R("#7a64b8", "#4e3e86", "#382c64", "#281f48")

local c = HP.canvas{ w = 81, h = 49, scale = 1, name = NAME }
c:groundShadow(40, 45, 36, 2.5)
for y = 0, c.h - 1 do for x = 0, c.w - 1 do local i = y * c.w + x
  if c.pix[i] and not c.pix[i - 1] and not c.pix[i + 1] then c.pix[i], c.own[i] = nil, nil end end end

-- stubby legs (behind the plates, only the feet and shins show)
for _, x in ipairs{ 33, 44, 54 } do
  c:part(c:poly{ { x, 38 }, { x + 4, 38 }, { x + 3, 43 }, { x + 5, 44 }, { x - 1, 44 } }, LEG, { band = 1, nopop = true })
end
-- basalt plates, tail to head; each overlaps the one behind it
local plates = {
  { 2, 31, 14, 43 }, { 10, 26, 24, 43 }, { 20, 22, 35, 42 }, { 31, 19, 47, 42 }, { 43, 18, 57, 41 },
}
local masks = {}
for i, p in ipairs(plates) do
  local m = c:rrect(p[1], p[2], p[3], p[4], 4)
  c:part(m, PLATE, { band = 3, nopop = true, sep = true })
  -- lit top facet: 2 rows under the top edge, then a facet line
  local l = {}
  m:each(function(x, y)
    if c:get(x, y) == PLATE.base then
      local hgt = p[4] - p[2]
      if y <= p[2] + 2 and x < p[3] - 2 then l[#l + 1] = { x, y, PLATE.hi } elseif y == p[2] + 3 and x < p[3] - 1 then l[#l + 1] = { x, y, PLATE.shade }
      elseif y >= p[4] - math.floor(hgt * 0.35) then l[#l + 1] = { x, y, PLATE.shade } end
    end
  end)
  for _, q in ipairs(l) do c:put(q[1], q[2], q[3]) end
  -- column crease down the plate side
  local cx = p[1] + math.floor((p[3] - p[1]) * 0.55)
  for y = p[2] + 5, p[4] - 2 do if m:has(cx, y) and c:get(cx, y) == PLATE.base then c:put(cx, y, PLATE.shade) end end
  -- crystal stud on the top edge
  if i >= 2 then
    local sx = p[1] + 4
    c:part(c:poly{ { sx, p[2] + 1 }, { sx + 2, p[2] - 3 }, { sx + 4, p[2] + 1 } }, HORN, { band = 1, nopop = true })
  end
  masks[i] = m
end
-- stubby claw legs in front of the lower plates
for _, x in ipairs{ 24, 36, 48 } do
  c:part(c:poly{ { x, 40 }, { x + 3, 40 }, { x + 4, 43 }, { x + 7, 45 }, { x, 45 } }, HEAD, { band = 1, nopop = true })
  c:put(x + 1, 41, HEAD.hi) c:put(x + 5, 44, JAW.base) c:put(x + 6, 45, JAW.shade)
end
-- ember crack glowing through two plates (quirk)
c:fillMask(c:line({ { 26, 25 }, { 28, 30 }, { 26, 34 }, { 29, 39 } }, 1):clip(masks[3]), P.ember.base)
c:put(28, 30, P.gold.hi) c:put(26, 34, P.ember.hi)
c:fillMask(c:line({ { 37, 26 }, { 39, 31 } }, 1):clip(masks[4]), P.ember.shade)

-- head capsule, its own darker shell
local hd = c:ellipse(64, 30, 12, 11)
hd:clip(c:rect(0, 0, 80, 42))
c:part(hd, HEAD, { band = 3, pop = { x = 58, y = 22 } })
-- brow ridge
c:fillMask(c:line({ { 58, 26 }, { 74, 26 } }, 1):clip(hd), HEAD.deep)
-- swept horns (thick at the base, a lit front edge)
local function horn(pts)
  local m = c:line({ pts[1], pts[2] }, 5)
  m:add(c:line({ pts[2], pts[3] }, 3))
  m:add(c:line({ pts[3], pts[4] }, 1))
  m:clip(c:rect(0, 0, 80, pts[1][2]))
  c:part(m, HORN, { band = 1, nopop = true })
  c:fillMask(c:line({ pts[1], pts[2], pts[3] }, 1):shift(-1, 0):clip(m), HORN.hi)
  -- growth rings across the horn
  for k = 1, 3 do local y = pts[1][2] - 3 * k
    local l = {} m:each(function(x, yy) if yy == y and c:get(x, yy) ~= HORN.hi then l[#l + 1] = x end end)
    for _, x in ipairs(l) do c:put(x, y, HORN.shade) end end
end
horn{ { 58, 22 }, { 56, 14 }, { 53, 8 }, { 50, 4 } }
horn{ { 68, 21 }, { 72, 13 }, { 76, 8 }, { 79, 6 } }
-- boring jaw: pale beak with a notch, low on the front of the head
c:part(c:poly{ { 70, 31 }, { 77, 32 }, { 80, 36 }, { 76, 35 }, { 70, 35 } }, JAW, { band = 1, pop = { x = 72, y = 32 } })
c:part(c:poly{ { 70, 37 }, { 75, 37 }, { 78, 39 }, { 74, 41 }, { 70, 40 } }, JAW, { band = 1, nopop = true })
c:fillMask(c:line({ { 70, 36 }, { 76, 36 } }, 1), HEAD.deep)
-- two eyes (3/4 view), the far one a little smaller and set back
c:eyeSmall(63, 28)
c:eyeSmall(70, 28)
c:put(61, 33, P.petal.base) c:put(62, 33, P.petal.base)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
