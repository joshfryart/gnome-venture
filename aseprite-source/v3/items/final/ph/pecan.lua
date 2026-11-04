-- pecan (final, Opus single pass). A slim, long in-shell pecan leaning on the diagonal (pointed tip up-right, blunt
-- stem end down-left), and a shelled half kernel resting against its foot: two ridged lobes split by a deep groove.
-- Material: per-pixel tube light on the shell (6-tone warm brown, violet shade), the pecan's dark lengthwise streaks
-- and flecks, a pale suture ridge, glossy 2x1 specular, cool reflected light on the lower-right; the kernel has wavy
-- cross-wrinkles, a dark centre groove, red-brown skin and paler crests. AO + contact shadow where kernel meets shell.
-- quirk: a squirrel has nibbled the kernel's tip (tooth notch with paler bitten meat).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("pecan")

local SHELL = { "#36201f", "#5a2e22", "#82442a", "#a8622f", "#c98848", "#e8b070" }
local KERN  = { "#45201a", "#6c321f", "#924c26", "#b86d34", "#d8964c", "#f2c27c" }
local MEAT  = "#f6dca4"
local STREAK, STREAK2 = "#2a1a1e", "#4a2a24"
local BOUNCE, SPEC = "#8a7aa8", "#fff2d8"
local stok, ktok = { r = { name = "shell" } }, { r = { name = "kernel" } }

-- kernel (front): drawn first as a mask so the shell can be cut / shaded against it
local kp = { { 30, 50 }, { 36, 48 }, { 43, 45 }, { 49, 41 } }
local km, kn, KT, KS = A.tube(kp, function(t) return 4.6 * sin(pi * (0.06 + 0.9 * t)) ^ 0.45 + 0.2 end)
-- quirk: nibble notch at the tip (two rounded bites)
local bite = HP.mask()
for _, b in ipairs{ { 49.5, 39.2, 1.9 }, { 51.2, 42.0, 1.6 } } do
  for y = 35, 46 do for x = 45, 55 do if (x - b[1]) ^ 2 + (y - b[2]) ^ 2 <= b[3] ^ 2 then bite:set(x, y) end end end
end
km:cut(bite)

-- shell: tube on a gentle curve, pointed at the top end
local sp = { { 15, 49 }, { 19, 36 }, { 27, 22 }, { 38, 12 } }
local sm, sn, ST, SS = A.tube(sp, function(t)
  local w = 7.4 * sin(pi * (0.04 + 0.94 * t)) ^ 0.62
  if t > 0.8 then w = w * (1 - (t - 0.8) * 1.6) end
  return w + 0.3
end)
-- blend in a bit of pillow so the ends round over
local np = X.pillow(sm, 4)
for k, a in pairs(sn) do local b = np[k] if b then sn[k] = { A.norm(a[1] * 0.75 + b[1] * 0.25, a[2] * 0.75 + b[2] * 0.25, a[3] * 0.75 + b[3] * 0.25) } end end
local svis = sm:copy():cut(km)
local sb = {}
X.ao(sb, svis, km, 1, -1)
A.cast(sb, svis, km, -1, -1, -1)
local sidx = A.shade(c, svis, sn, SHELL, { amb = 0.08, wrap = 0.26, bias = sb, tok = stok })
-- dark lengthwise streaks: band index across the shell, broken along the length
svis:each(function(x, y) local k = K(x, y)
  local s, t = SS[k], ST[k]
  local band = floor((s + 1) * 4.2)
  local wob = sin(t * 23 + band * 2.1) * 0.5 + X.hash(band, floor(t * 14), 7) - 0.45
  if wob > 0.45 and abs(s) < 0.86 and t > 0.06 and t < 0.94 then
    c:put(x, y, (sidx[k] or 3) >= 4 and STREAK2 or STREAK, stok)
  elseif X.hash(x, y, 9) > 0.93 and (sidx[k] or 1) >= 3 then
    c:put(x, y, STREAK2, stok)
  end
  -- pale suture ridge just lit-side of centre
  if s > -0.2 and s < -0.08 and t > 0.12 and t < 0.86 and X.hash(x, y, 2) > 0.2 then c:put(x, y, SHELL[min(6, (sidx[k] or 3) + 1)], stok) end
end)
-- cool reflected light on the shade-side edge
local rim = X.rim(sn)
svis:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.6 and ST[k] > 0.1 and ST[k] < 0.85 then c:put(x, y, BOUNCE, stok) end end)
-- glossy specular 2x1 + glint on the upper lit shoulder
c:put(22, 30, SPEC, stok) c:put(23, 29, SPEC, stok) c:put(24, 29, SHELL[6], stok)
-- tip point and stem-end scar
c:put(38, 12, SHELL[1], stok) c:put(37, 13, SHELL[2], stok)
for _, p in ipairs{ { 15, 48 }, { 16, 48 }, { 15, 47 } } do if svis:has(p[1], p[2]) then c:put(p[1], p[2], SHELL[1], stok) end end
c:put(16, 47, SHELL[5], stok)

-- kernel: ridged lobes, centre groove, cross wrinkles
local kidx = A.shade(c, km, kn, KERN, { amb = 0.1, wrap = 0.3, tok = ktok })
local klen = 26
km:each(function(x, y) local k = K(x, y)
  local s, t = KS[k], KT[k]
  local i = kidx[k] or 3
  if abs(s) < 0.13 then c:put(x, y, KERN[1], ktok) return end
  if abs(s) < 0.26 then c:put(x, y, KERN[max(1, i - 1)], ktok) return end
  local w = sin(t * klen * 1.25 + abs(s) * 3.2)
  if w > 0.72 and abs(s) < 0.88 then c:put(x, y, KERN[max(1, i - 2)], ktok)
  elseif w < -0.8 and abs(s) < 0.8 then c:put(x, y, KERN[min(6, i + 1)], ktok) end
end)
-- bitten meat inside the notch
bite:grow(1):each(function(x, y) if km:has(x, y) then c:put(x, y, MEAT, ktok) end end)
-- tooth grooves
c:put(48, 40, KERN[4], ktok) c:put(49, 42, KERN[4], ktok)
-- kernel specular
c:put(36, 45, SPEC, ktok) c:put(37, 45, KERN[6], ktok)

A.save(c, "pecan")
