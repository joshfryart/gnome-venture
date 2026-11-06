-- almond (final, Opus). One slim almond kernel lying in the lower half of its cracked-open shell, on the diagonal.
-- Kernel: flattened teardrop, warm brown skin with wavy lengthwise grooves and lit ridges, a darker hilum at the
-- pointed tip, one waxy specular. Shell: pale tan, porous (pits stretched along the axis), a bright broken lip, an
-- ambient-dark gap where the kernel sits in it. quirk: a single pink almond-blossom petal stuck to the shell.
local NAME = "almond"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local KER = { "#3a1c16", "#5a2c1c", "#7e4024", "#a2582e", "#c27842", "#e09c60" }
local SHELL = { "#5c3c24", "#80582e", "#a67a40", "#c69a58", "#dfb878", "#f3d79c" }
local PET = { "#a84a72", "#d9789c", "#f5a6c0", "#ffd4e2" }

-- teardrop half-width along t (0 = rounded base, 1 = point), broadest a third of the way up
local function tw(scale) return function(t)
  local u = 0.12 + 0.88 * t ^ 0.7
  return scale * (sin(pi * u) ^ 0.6) + 0.3
end end
local shp = { { 15, 54 }, { 24, 42 }, { 38, 27 }, { 52, 14 } }
local shm, shn, ST, SS = A.tube(shp, tw(9.4))
local kp = { { 15, 51 }, { 23, 39 }, { 36, 24 }, { 49, 12 } }
local km, kn, KT, KS = A.tube(kp, tw(6.9))
for k, n in pairs(kn) do local l = sqrt(n[1]^2 + n[2]^2 + (n[3] * 1.5)^2) kn[k] = { n[1] / l, n[2] / l, n[3] * 1.5 / l } end
-- shell front (near, lower-right half below a jagged broken lip) and shell back (far inner wall)
local front = HP.mask()
shm:each(function(x, y) local k = K(x, y)
  local lim = 0.3 + 0.12 * sin(ST[k] * 31) + 0.1 * (X.hash(floor(ST[k] * 40), 0, 2) - 0.5)
  if SS[k] > lim then front:set(x, y) end
end)
local back = shm:copy():cut(front)

---------------------------------------------------------------- shell back: concave far wall, in shade, pale cut rim
local stok = { r = { name = "shellback" } }
back:cut(km)
back:each(function(x, y) local k = K(x, y)
  local i = 3
  if km:grow(1):has(x, y) then i = 1 elseif km:grow(2):has(x, y) then i = 2 end
  if not shm:has(x - 1, y) or not shm:has(x, y - 1) then i = 6 end      -- broken rim edge catches light
  if X.hash(x, y, 6) > 0.85 and i == 3 then i = 2 end
  c:put(x, y, SHELL[i], stok)
end)

---------------------------------------------------------------- kernel
local ktok = { r = { name = "kernel" } }
local kb = {}
local kidx = A.toneN(c, km, kn, KER, { tok = ktok, bias = kb, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.08, wrap = 0.25 })
-- wavy lengthwise grooves with a lit ridge beside each
km:each(function(x, y) local k = K(x, y)
  local t, s = KT[k], KS[k]
  if t < 0.06 or t > 0.93 then return end
  local i = kidx[k] or 3
  for _, g in ipairs{ -0.55, -0.15, 0.25 } do
    local gg = g + 0.07 * sin(t * 26 + g * 9)
    if abs(s - gg) < 0.1 then c:put(x, y, KER[max(1, i - 2)], ktok)
    elseif abs(s - (gg - 0.17)) < 0.06 and X.hash(x, y, 8) > 0.2 then c:put(x, y, KER[min(6, i + 1)], ktok) end
  end
end)
-- hilum at the tip, AO where the kernel sits into the shell on the lower-right
local tx, ty = A.bez(kp, 0.97)
c:put(floor(tx + .5), floor(ty + .5), KER[1], ktok) c:put(floor(tx + .5) - 1, floor(ty + .5) + 1, KER[2], ktok)
km:edge():each(function(x, y) local k = K(x, y) if KS[k] > 0.7 then c:put(x, y, KER[max(1, (kidx[k] or 2) - 1)], ktok) end end)
-- one waxy specular on the shoulder
c:put(25, 33, KER[6], ktok) c:put(26, 33, "#f6c890", ktok) c:put(25, 34, KER[6], ktok)

---------------------------------------------------------------- shell front: convex, pitted, bright broken lip
local ftok = { r = { name = "shellfront" } }
local fb = {}
local sidx = A.toneN(c, front, shn, SHELL, { tok = ftok, bias = fb, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.12, wrap = 0.35 })
front:each(function(x, y) local k = K(x, y)
  if not front:has(x - 1, y) or not front:has(x, y - 1) then c:put(x, y, SHELL[6], ftok) return end
  if not front:has(x - 2, y) or not front:has(x, y - 2) then c:put(x, y, SHELL[5], ftok) return end
  if X.hash(x, y, 4) > 0.82 then
    local i = sidx[k] or 3
    c:put(x, y, SHELL[max(1, i - 2)], ftok)
    if front:has(x + 1, y + 1) then c:put(x + 1, y + 1, SHELL[min(6, i + 1)], ftok) end
  end
  if SS[k] > 0.86 and ST[k] > 0.08 and ST[k] < 0.9 then c:put(x, y, SHELL[1], ftok) end
end)
-- contact shadow of the lip on the kernel
front:shift(-1, -1):each(function(x, y) if km:has(x, y) and not front:has(x, y) then c:put(x, y, KER[1], ktok) end end)

---------------------------------------------------------------- quirk: almond-blossom petal stuck on the shell
c:paint({
  ".lhh.",
  "lmmhl",
  "dmmml",
  ".dmd.",
  "..d..",
}, 34, 39, { h = PET[4], l = PET[3], m = PET[2], d = PET[1] })

A.save(c, NAME)
