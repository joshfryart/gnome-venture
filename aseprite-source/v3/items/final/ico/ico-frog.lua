-- ico-frog (final, Opus): a tree-pond frog sitting up, front view. Wide head with two domed eyes on top, a
-- pear-shaped body, slim front arms on splayed three-toed hands, folded haunches with long webbed feet out sideways.
-- Material: per-pixel round light on wet skin (6-tone green, violet-teal shade), darker spots with a lit lip,
-- glossy specular glints on head and eye domes, cream-yellow belly with throat creases, cool bounce on the shade side,
-- AO where the arms cross the belly, under the chin and where haunch meets body; 2-tone ground shadow.
-- Face: locked cream eyes with ink pupils, a wide smile, two nostril pits (the nose), petal cheeks.
-- quirk: the tip of a pink tongue pokes out of the corner of its smile.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_5.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, max, min, abs, floor = math.sqrt, math.max, math.min, math.abs, math.floor
local c = A.new("ico-frog")
local GR = { "#173528", "#235538", "#327640", "#4b9844", "#77ba50", "#b0d870" }
local BL = { "#7a6544", "#ad945c", "#d5bd7a", "#ecdc9e", "#faf0c6" }
local SPEC, BOUNCE, LINE = "#f4ffe0", "#3f7a6a", "#16301f"
local gt, bt = { r = { name = "frog" } }, { r = { name = "belly" } }

c:groundShadow(32, 56, 13, 1)

-- haunches + long feet (behind the body)
local hidx, hm = {}, HP.mask()
for _, sd in ipairs{ -1, 1 } do
  local fx = 32 + sd * 11
  -- foot: tapered tube from heel outwards, then 3 toes
  local fp = { { 32 + sd * 9, 53 }, { 32 + sd * 14, 54 }, { 32 + sd * 16, 54 }, { 32 + sd * 19, 53 } }
  local m, n = A.tube(fp, function(t) return 1.6 - t * 0.4 end)
  for _, toe in ipairs{ { -0.6, -2.2 }, { 0.2, -0.6 }, { 0.7, 1.4 } } do
    local ex, ey = 32 + sd * (19 + toe[1] * 2), 53 + toe[2]
    local tm2, tn2 = A.tube({ { 32 + sd * 17, 53 }, { 32 + sd * 18, 53 + toe[2] * 0.5 }, { ex - sd * 0.6, ey }, { ex, ey } },
      function(t) return 0.7 end)
    m:add(tm2) for k, v in pairs(tn2) do n[k] = n[k] or v end
    -- toe pads
    local pad = HP.ellipse(floor(ex + .5), floor(ey + .5), 1, 1)
    pad:each(function(x, y) if not m:has(x, y) then m:set(x, y) n[K(x, y)] = { 0, 0, 1 } end end)
  end
  local id = A.shade(c, m, n, GR, { tok = gt, amb = 0.12, wrap = 0.3 })
  for k, v in pairs(id) do hidx[k] = v end
  hm:add(m)
  -- haunch
  local th = HP.ellipse(fx, 46, 5.5, 6)
  local tn3 = A.body(th, fx - 1, 45, 6, 3, 0.7)
  local id2 = A.shade(c, th, tn3, GR, { tok = gt, amb = 0.08 })
  for k, v in pairs(id2) do hidx[k] = v end
  A.sep(c, m, hidx, GR, th, -1, gt)
  hm:add(th)
  -- haunch spots
  for _, s in ipairs{ { fx - 2 * sd, 42 }, { fx + 1 * sd, 47 } } do
    for _, d in ipairs{ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } } do A.step(c, hidx, GR, s[1] + d[1], s[2] + d[2], -2, gt) end
    A.step(c, hidx, GR, s[1], s[2] - 1, 1, gt)
  end
end

-- head + body: one wet-skin mass
local head = HP.ellipse(32, 27, 13.5, 8.5)
local bodym = HP.ellipse(32, 42, 9.5, 10)
local eyeL, eyeR = HP.ellipse(23, 18, 5.5, 5.5), HP.ellipse(41, 18, 5.5, 5.5)
local mass = head:copy():add(bodym)
local nb = A.body(mass, 31, 32, 14, 5, 0.55, 14)
local idx = A.shade(c, mass, nb, GR, { tok = gt, amb = 0.06, wrap = 0.2 })
A.sep(c, hm, hidx, GR, mass, -1, gt)
-- eye domes (spheres, sit on top of the head)
local didx = {}
for _, e in ipairs{ { eyeL, 23 }, { eyeR, 41 } } do
  local ne = X.sphere(e[2] - 0.5, 17.5, 5.5, e[1])
  local id = A.shade(c, e[1], ne, GR, { tok = gt, amb = 0.1, wrap = 0.25 })
  for k, v in pairs(id) do didx[k] = v idx[k] = v end
end
-- dome meets head: ambient row on the head just below each dome
local domes = eyeL:copy():add(eyeR)
domes:each(function(x, y) if not domes:has(x, y + 1) and mass:has(x, y + 1) and x > 20 and x < 44 then
  A.step(c, idx, GR, x, y + 1, -1, gt) end end)
mass:add(domes)
-- back spots (dark blotch, lit lower lip)
for _, s in ipairs{ { 21, 26, 2 }, { 44, 28, 2 }, { 32, 21, 1 }, { 24, 38, 1 }, { 40, 39, 2 } } do
  local sm = HP.ellipse(s[1], s[2], s[3] * 0.7 + 0.3, s[3] * 0.5 + 0.2)
  sm:each(function(x, y) if mass:has(x, y) then A.step(c, idx, GR, x, y, -2, gt) end end)
end

-- belly + throat
local belly = HP.ellipse(32, 44, 7, 7.5):clip(bodym)
local throat = HP.ellipse(32, 35, 9, 2.2):clip(mass):cut(HP.rect(0, 0, 63, 34))
belly:add(throat)
local bn = A.body(belly, 30, 41, 9, 3, 0.7)
local bidx = A.shade(c, belly, bn, BL, { tok = bt, amb = 0.12, wrap = 0.3, cuts = { 0.22, 0.42, 0.62, 0.8 } })
-- chin AO on the belly top, throat creases
belly:each(function(x, y) if not belly:has(x, y - 1) then A.step(c, bidx, BL, x, y, -1, bt) end end)
for _, cr in ipairs{ { 27, 37, 37 }, { 28, 39, 36 } } do
  for x = cr[1], cr[3] do if belly:has(x, cr[2]) then A.step(c, bidx, BL, x, cr[2], -1, bt) end end
end

-- front arms + three-toed hands
local aidx, am = {}, HP.mask()
for _, sd in ipairs{ -1, 1 } do
  local p = { { 32 + sd * 7, 38 }, { 32 + sd * 8.5, 43 }, { 32 + sd * 8, 48 }, { 32 + sd * 7, 52 } }
  local m, n = A.tube(p, function(t) return 1.5 - t * 0.2 end)
  for _, toe in ipairs{ -2, 0, 2 } do
    local ex, ey = 32 + sd * 7 + toe, 54
    local pad = HP.rect(ex, ey - 1, ex + (toe == 0 and 0 or 0), ey)
    pad:each(function(x, y) m:set(x, y) n[K(x, y)] = { 0, 0.3, 0.95 } end)
  end
  local hand = HP.rect(32 + sd * 7 - 2, 52, 32 + sd * 7 + 2, 53)
  hand:each(function(x, y) m:set(x, y) n[K(x, y)] = n[K(x, y)] or { sd * 0.2, 0.2, 0.95 } end)
  local id = A.shade(c, m, n, GR, { tok = gt, amb = 0.12, wrap = 0.3 })
  for k, v in pairs(id) do aidx[k] = v end
  am:add(m)
end
-- toe gaps (pad tips lit)
for _, sd in ipairs{ -1, 1 } do
  local bx = 32 + sd * 7
  for _, x in ipairs{ bx - 1, bx + 1 } do c.pix[54 * 64 + x] = nil c.own[54 * 64 + x] = nil end
  for _, x in ipairs{ bx - 2, bx, bx + 2 } do A.step(c, aidx, GR, x, 54, 1, gt) end
end
A.sep(c, belly, bidx, BL, am, -1, bt)
A.sep(c, mass, idx, GR, am, -1, gt)

-- cool bounce on the lower-right shade side
local rim = X.rim(nb)
mass:edge():each(function(x, y) local k = K(x, y)
  if rim[k] and rim[k] > 0.62 and y > 26 and y < 47 and not am:has(x, y) and not belly:has(x, y) then c:put(x, y, BOUNCE, gt) end end)

-- face
c:eyeLocked(21, 16) c:eyeLocked(39, 16)
-- lid line over each eye
for _, ex in ipairs{ 21, 39 } do for x = ex + 1, ex + 3 do c:put(x, 15, GR[2], gt) end end
-- nostrils (the nose): two pits with a lit rim above
for _, nx in ipairs{ 30, 34 } do c:put(nx, 25, LINE, gt) c:put(nx, 24, GR[6], gt) end
-- smile: a wide gentle U with up-turned corners
local smile = { { 21, 28 }, { 22, 29 }, { 23, 29 }, { 24, 30 }, { 25, 30 }, { 26, 31 }, { 38, 31 }, { 39, 30 }, { 40, 30 }, { 41, 29 }, { 42, 29 }, { 43, 28 } }
for x = 27, 37 do smile[#smile + 1] = { x, 31 } end
for _, p in ipairs(smile) do c:put(p[1], p[2], LINE, gt) end
-- lit lip under the smile
for x = 26, 38 do A.step(c, idx, GR, x, 32, 1, gt) end
for _, p in ipairs(smile) do A.step(c, idx, GR, p[1], p[2] - 1, -1, gt) end
c:cheek(20, 30) c:cheek(43, 30)
-- quirk: tongue tip poking out of the right corner of the smile
c:put(39, 31, "#e8607e", gt) c:put(40, 31, "#f590a8", gt) c:put(39, 32, "#c94f84", gt) c:put(40, 32, "#e8607e", gt)
c:put(40, 30, "#c94f84", gt)

-- wet-skin glints: head, both domes
c:put(26, 22, SPEC, gt) c:put(27, 22, SPEC, gt) c:put(25, 23, GR[6], gt)
c:put(20, 14, SPEC, gt) c:put(38, 14, SPEC, gt) c:put(39, 13, GR[6], gt) c:put(21, 13, GR[6], gt)
A.save(c, "ico-frog")
