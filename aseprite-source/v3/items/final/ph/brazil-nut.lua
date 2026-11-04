-- brazil-nut (final, Opus aB10_2). One whole Brazil nut in its shell lying on the diagonal: a slim, curved, three-faced
-- wedge (lit upper face, front face, shaded lower face) with pale ridges on the facet edges, wrinkled woody fibre
-- grooves running its length and a paler attachment scar at the blunt end. In front of it lies a shelled kernel:
-- creamy, waxy, slim crescent, half covered in thin papery brown skin, cool reflected light on its shade side.
-- quirk: the kernel's tip has a tiny gnome-sized bite taken out of it, showing the paler flesh inside.
local NAME = "brazil-nut"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, pi = math.floor, math.abs, math.max, math.min, math.sin, math.pi
local c = A.new(NAME)
local SHELL = { "#2a1820", "#4a2a26", "#6e3f2c", "#955a36", "#bb7c48", "#dea468" }
local KERN = { "#8a6a4a", "#b8946a", "#dcc094", "#eedcb2", "#faf0d2", "#fff4d6" }
local SKIN = { "#4e2c22", "#74442c", "#9a6038" }
local COOL = "#b8c0c4"

-- kernel first (front), shell drawn behind it
local kp = { { 19, 52 }, { 29, 48 }, { 39, 42 }, { 45, 32 } }
local km, kn, KT, KS = A.tube(kp, function(t) return max(0.6, 3.6 * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.6) end)
-- quirk: bite out of the upper tip (scalloped)
local bite = c:ellipse(45, 33, 2.6, 2.6)
km:cut(bite)
local bitef = HP.mask()
km:each(function(x, y) if bite:grow(1):has(x, y) then bitef:set(x, y) end end)

-- shell: curved wedge, blunt end lower-left, point upper-right
local sp = { { 12, 46 }, { 16, 31 }, { 28, 18 }, { 47, 12 } }
local shield = km:grow(1)
local sm, ST, SS, sidx, stok = A.shell(c, sp, function(t)
  if t > 0.99 then return 0.4 end
  return max(0.6, 9.0 * sin(pi * (0.12 + t * 0.88)) ^ 0.7)
end, SHELL, { cut = shield, seed = 7 })
-- attachment scar at the blunt end: paler oval patch
sm:each(function(x, y) local k = K(x, y)
  if ST[k] < 0.07 and abs(SS[k]) < 0.55 then c:put(x, y, SS[k] < 0 and SHELL[6] or SHELL[5], stok) end
  if ST[k] >= 0.07 and ST[k] < 0.1 and abs(SS[k]) < 0.55 then c:put(x, y, SHELL[2], stok) end
end)
-- one specular glint on the lit ridge
c:put(22, 23, "#f4d49a", stok) c:put(23, 22, "#f4d49a", stok)
-- contact shadow on the shell where the kernel lies over it
km:shift(-1, -1):each(function(x, y) if sm:has(x, y) and not km:has(x, y) then A.shift(c, x, y, SHELL, -2, stok) end end)

-- kernel paint
local ktok = { r = { name = "kernel" } }
local kv = X.light(kn, { amb = 0.15, wrap = 0.35 })
local kidx = X.tone(c, km, kv, KERN, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.88 }, tok = ktok })
km:each(function(x, y) local k = K(x, y)
  local s, t = KS[k], KT[k]
  -- papery skin patches on the lower / outer side
  local h = X.hash(floor(t * 14), floor((s + 1) * 2.2), 4)
  if s > 0.15 and h < 0.7 or (s > -0.2 and h < 0.25) then
    c:put(x, y, SKIN[s > 0.6 and 1 or (X.hash(x, y, 6) < 0.3 and 3 or 2)], ktok)
  end
  -- cool reflected light along the lower rim
  if s > 0.8 and t > 0.2 and t < 0.8 then c:put(x, y, COOL, ktok) end
end)
-- waxy specular on the kernel
c:put(30, 45, KERN[6], ktok) c:put(31, 45, KERN[6], ktok)
-- bite face: paler flesh with a darker rim
bitef:each(function(x, y) c:put(x, y, bite:grow(1):shift(-1, 1):has(x, y) and KERN[5] or KERN[3], ktok) end)

A.save(c, NAME)
