-- aphid-wings (final pass, Opus single pass). One side's shed pair, still joined at the hinge: a long slim forewing
-- sweeping up to the upper right and a small hindwing tucked under it. Material: glassy membrane (6-tone cool green
-- glass, pillow-lit), bright rim on the lit edge and a pale core, faint thin-film iridescence bands (pink / lilac),
-- dark costal vein with a long olive pterostigma, a curved radial vein and a twice-forked media, two cubitus veins;
-- the double layer reads darker where the wings overlap; the hinge sclerite carries the AO where they meet.
-- quirk: a single dew drop sits on the forewing, magnifying (and bending) the vein under it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.pi
local c = A.new("aphid-wings")
local GL   = { "#4a6e86", "#6f9cb4", "#98c4d2", "#bcdee4", "#d8eef0", "#eff9f6" }
local VEIN, VEIND = "#7c8a62", "#4a5238"
local STIG = { "#3a3e2c", "#5e6a3e", "#9aa864" }
local PINK, LILAC = "#f2d8ea", "#d2ddf6"
local SCL = { "#2e3a2a", "#4e6040", "#7c9058", "#a8bc78" }
local DROP = { "#3a86b0", "#7cc8d8", "#b6f0e0", "#eafff8" }

local function wingPaint(m, n, T, S, wf, veins, tok, bias)
  local idx = A.shade(c, m, n, GL, { tok = tok, bias = bias, amb = 0.3, wrap = 0.5, cuts = { 0.22, 0.4, 0.56, 0.72, 0.9 } })
  -- thin-film iridescence on the pale membrane
  m:each(function(x, y) local k = K(x, y) local i = idx[k]
    if i >= 3 then
      local b = (T[k] * 6.5 + S[k] * 1.4 + 10) % 1
      if b > 0.3 and b < 0.36 then c:put(x, y, PINK, tok) elseif b > 0.36 and b < 0.42 then c:put(x, y, LILAC, tok) end
    end end)
  -- pale glass core
  m:each(function(x, y) local k = K(x, y) if idx[k] >= 5 and abs(S[k]) < 0.32 and T[k] > 0.3 and T[k] < 0.85 then c:put(x, y, GL[6], tok) end end)
  -- veins: pixel distance to s = f(t) curves in blade space
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    local w = wf(t) + 0.6
    for _, v in ipairs(veins) do
      if t >= v.t0 and t <= v.t1 then
        local sv = v.f(t)
        if abs(s - sv) * w < (v.wpx or 0.55) then c:put(x, y, v.col or VEIN, tok) idx[k] = 0 end
      end
    end
  end)
  return idx
end

-- hindwing (behind)
local htok = { r = { name = "hind" } }
local hw = function(t) return 4.3 * sin(pi * min(1, t ^ 1.25)) ^ 0.55 - 0.2 end
local hm, hn = nil, nil
local HT, HS
hm, hn, HT, HS = A.blade(20, 47, 33, 46, 46, 40, hw, { fold = 0.0 })
local hidx = wingPaint(hm, hn, HT, HS, hw, {
  { t0 = 0.2, t1 = 0.8, f = function(t) return -0.6 end, wpx = 0.45 },
  { t0 = 0.35, t1 = 0.85, f = function(t) return -0.55 + (t - 0.35) * 2.4 end, wpx = 0.45 },
}, htok)

-- forewing (front)
local ftok = { r = { name = "fore" } }
local fw = function(t) return 6.6 * sin(pi * min(1, t ^ 1.3)) ^ 0.55 - 0.2 end
local fm, fn, FT, FS = A.blade(18, 46, 31, 27, 50, 12, fw, { fold = 0.0 })
local fb = {}
fm:each(function(x, y) if hm:has(x, y) then fb[K(x, y)] = -1 end end)   -- double layer darker
local fidx = wingPaint(fm, fn, FT, FS, fw, {
  { t0 = 0.03, t1 = 0.5, f = function(t) return -0.84 end, wpx = 0.45, col = VEIN },                  -- costa
  { t0 = 0.5, t1 = 0.93, f = function(t) local u = (t - 0.5) / 0.43 return -0.72 + u * 0.5 + u * u * 0.1 end }, -- radial sector
  { t0 = 0.15, t1 = 0.4, f = function(t) return -0.12 + (t - 0.08) * 0.25 end },                       -- media stem
  { t0 = 0.4, t1 = 0.92, f = function(t) return -0.04 - (t - 0.4) * 0.35 end },                        -- M1
  { t0 = 0.4, t1 = 0.62, f = function(t) return -0.04 + (t - 0.4) * 1.1 end },                         -- M fork
  { t0 = 0.62, t1 = 0.8, f = function(t) return 0.2 + (t - 0.62) * 2.6 end },                          -- M3
  { t0 = 0.17, t1 = 0.38, f = function(t) return 0.1 + (t - 0.17) * 3.4 end },                          -- Cu1
  { t0 = 0.14, t1 = 0.24, f = function(t) return 0.3 + (t - 0.14) * 5.5 end },                         -- Cu2
}, ftok, fb)
-- costa = leading edge vein (1 px inside the outline), pterostigma = 2 px deep dark cell with a lit core
local fe1 = fm:edge()
local fe2 = fm:copy():shrink(1):edge()
fe1:each(function(x, y) local k = K(x, y) local t = FT[k]
  if FS[k] < -0.3 and t > 0.08 and t < 0.66 then c:put(x, y, (t > 0.5) and STIG[1] or VEIN, ftok) end end)
fe2:each(function(x, y) local k = K(x, y) local t = FT[k]
  if FS[k] < -0.3 and t > 0.5 and t < 0.66 then c:put(x, y, (t > 0.53 and t < 0.63) and STIG[3] or STIG[2], ftok) end end)
-- glass rim: bright inner edge on the lit (leading) side, cool edge on the trailing side
fm:edge():each(function(x, y) local k = K(x, y)
  if FS[k] < -0.3 and FT[k] > 0.66 then c:put(x, y, GL[6], ftok)
  elseif FS[k] > 0.4 and not hm:has(x, y) then c:put(x, y, GL[3], ftok) end end)
hm:edge():each(function(x, y) local k = K(x, y) if not fm:has(x, y) and HS[k] > 0.4 then c:put(x, y, GL[3], htok) end end)
-- separating line where the forewing edge lies on the hindwing
fm:edge():each(function(x, y) if hm:grow(1):has(x, y) and FS[K(x, y)] > 0.2 then c:put(x, y, GL[2], ftok) end end)
-- tip glint
c:put(47, 15, A.CREAM, ftok) c:put(48, 15, GL[6], ftok)
c:put(40, 43, A.CREAM, htok) c:put(41, 43, GL[6], htok)
-- sparkle on the glossy forewing
c:sparkle(40, 24)

-- hinge sclerite where both wings meet
local stok = { r = { name = "hinge" } }
A.map(c, { ".bb.", "bcbb", "bbba", ".aa." }, 16, 45, { a = SCL[1], b = SCL[2], c = SCL[4] }, stok)
c:put(20, 47, SCL[2], stok) c:put(19, 48, SCL[1], stok)

-- quirk: dew drop on the forewing, the vein under it bent and magnified
local dx, dy = 31, 30
local dtok = { r = { name = "drop" } }
c:put(dx + 2, dy + 3, GL[1], dtok) c:put(dx + 3, dy + 2, GL[1], dtok)
A.map(c, {
  ".aab.",
  "abccb",
  "acvcd",
  "bvcdd",
  ".bdd.",
}, dx - 2, dy - 2, { a = DROP[1], b = DROP[2], c = DROP[3], d = DROP[4], v = VEIND }, dtok)
c:put(dx - 1, dy - 1, A.CREAM, dtok)

A.save(c, "aphid-wings")
