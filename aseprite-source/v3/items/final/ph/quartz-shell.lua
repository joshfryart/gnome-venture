-- quartz-shell (D10_5, redraw): a slim turret shell lying diagonally, six whorls tapering to the upper right, pale
-- peach nacre with lilac shade, slanted sutures, fine growth ribs; a flared pearly lip whose dark violet mouth is
-- crowded with three faceted quartz crystals growing outwards. Material: per-pixel cylinder light, groove + lit lip
-- on every suture, rib grain, nacre inner lip, crystal facets (lit / mid / shade) with bright edge lines and tips.
-- quirk: the broken apex of the shell has healed into a clear quartz point.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_5.lua")
local B, HP, X, K, H = D.B, D.HP, D.X, D.K, D.H
local floor, max, min, abs, sqrt, sin, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.pi
local c = D.new("quartz-shell")
local hash = D.hash

local SH = { "#4e3a52", "#7e5e6e", "#b08882", "#d8ae9a", "#f0cfb6", "#fff0dc" }
local Q = { "#4a3c82", "#7662b4", "#a692da", "#cdc0f0", "#eae2fc", "#fbf8ff" }
local NA = { "#3a2038", "#6a3c62", "#a4688a", "#d494b0", "#f4c4d4", "#fff0f0" }  -- nacre / mouth

c:groundShadow(28, 55, 15, 2)

-- axis from the mouth (base) to the apex
local ax, ay, bx, by = 20, 46, 43, 20
local len = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
local EDGE = { -0.06, 0.32, 0.54, 0.70, 0.82, 0.91, 0.97 }
local function whorl(t)
  for i = 1, #EDGE - 1 do if t < EDGE[i + 1] then return i, (t - EDGE[i]) / (EDGE[i + 1] - EDGE[i]) end end
  return #EDGE - 1, 1
end
local function wfn(t)
  if t > 0.91 then return -1 end
  local _, k = whorl(t)
  local taper = 9.8 * (1 - t) ^ 0.85 + 1.1
  return taper * (0.7 + 0.3 * sin(pi * min(1, max(0, k))) ^ 0.7)
end
local m, n, T, S = X.cyl(ax, ay, bx, by, wfn)

-- mouth lip (flared oval) is part of the silhouette
local lipC = { 18.5, 47.5 }
local lip = B.ell(lipC[1], lipC[2], 11, 6.8, 0.68)
local body = m:copy()
-- body: per-pixel cylinder light
local v = X.light(n, { amb = 0.12, wrap = 0.25 })
local bias = {}
m:each(function(x, y)
  local kk = K(x, y)
  local s, t = S[kk], T[kk]
  local i, k = whorl(t)
  -- slanted sutures (grooves) with a lit lip just above on the lit side
  local d = (t - EDGE[i + 1] + 0.035 * s) * len
  if abs(d) < 0.85 then bias[kk] = -3
  elseif d >= 0.85 and d < 1.9 then bias[kk] = -1
  elseif d <= -0.85 and d > -1.9 and s < 0.3 then bias[kk] = 1 end
  -- growth ribs: oblique fine lines
  local rr = ((s * 3.4 + t * len * 0.45) % 1)
  if rr < 0.14 and abs(d) > 2 and k > 0.08 then bias[kk] = (bias[kk] or 0) - 1 end
  -- slight lilac banding near the middle of each whorl
  if k > 0.45 and k < 0.6 and hash(x, y, 2) > 0.5 then bias[kk] = (bias[kk] or 0) - 1 end
end)
X.tone(c, m, v, SH, { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 }, bias = bias })
-- cool reflected light along the lower-right rim
local rim = X.rim(n)
m:edge():each(function(x, y) if rim[K(x, y)] > 0.75 and S[K(x, y)] > 0.4 and T[K(x, y)] > 0.1 then c:px(x, y, "#9a86b8") end end)
-- ------------------------------------------------------------ mouth
local lipM = lip:copy()
B.lit(c, lipM, NA, 2.6, { amb = 0.2 })
local mouth = B.ell(17.6, 48.2, 8.6, 4.6, 0.68)
mouth:each(function(x, y)
  local t = ((x - 9) + (y - 42) * 0.6) / 18
  local idx = t < 0.35 and 1 or (t < 0.62 and 2 or 3)
  c:px(x, y, NA[idx])
end)
-- glints inside the mouth rim (pearly)
mouth:edge():each(function(x, y) if x > 17 and y < 48 then c:px(x, y, NA[2]) end end)
-- specular streaks on the body whorls
c:px(21, 38, SH[6]) c:px(22, 37, SH[6]) c:px(23, 36, SH[6]) c:px(20, 39, SH[5])
c:px(29, 30, SH[6]) c:px(30, 29, SH[6])
-- lit upper-left of the outer lip
lip:copy():cut(mouth:grow(1)):each(function(x, y) if x + y < 61 and hash(x, y, 4) > 0.55 then c:px(x, y, NA[5]) end end)

-- ------------------------------------------------------------ crystals
local function crystal(bx_, by_, tx_, ty_, w)
  local dx, dy = tx_ - bx_, ty_ - by_
  local L = sqrt(dx * dx + dy * dy)
  local ux, uy = dx / L, dy / L
  local px_, py_ = -uy, ux
  if px_ + py_ < 0 then px_, py_ = -px_, -py_ end   -- +s toward lower-right (shade)
  local sx, sy = bx_ + dx * 0.76, by_ + dy * 0.76
  local mm = HP.mask()
  mm:add(c:poly({ { bx_ - px_ * w, by_ - py_ * w }, { sx - px_ * w, sy - py_ * w }, { sx + px_ * w, sy + py_ * w }, { bx_ + px_ * w, by_ + py_ * w } }))
  mm:add(c:poly({ { sx - px_ * w, sy - py_ * w }, { sx + px_ * w, sy + py_ * w }, { tx_, ty_ } }))
  local tipcut = 0.76
  mm:each(function(x, y)
    local rx, ry = x - bx_, y - by_
    local t = (rx * ux + ry * uy) / L
    local s = (rx * px_ + ry * py_) / w
    local idx
    if t > tipcut then idx = (s < 0.05) and 6 or 3
    elseif s < -0.35 then idx = 5
    elseif s < 0.4 then idx = 4
    else idx = 2 end
    -- facet edge lines
    if t <= tipcut and abs(s + 0.35) < 0.17 then idx = 6 end
    if t <= tipcut and abs(s - 0.4) < 0.17 then idx = 3 end
    if t > tipcut and abs(s - 0.05) < 0.2 and (t - tipcut) < 0.2 then idx = 5 end
    if t < 0.12 then idx = max(1, idx - 2) end        -- ambient where it enters the mouth
    -- internal flaw: a milky streak
    if t > 0.25 and t < 0.6 and abs(s - 0.1) < 0.1 and hash(x, y, 7) > 0.3 then idx = max(2, idx - 1) end
    c:put(x, y, Q[idx])
  end)
  -- base shoulder line (hex termination)
  local sxx, syy = floor(sx + 0.5), floor(sy + 0.5)
  B.ln(c, floor(sx - px_ * w + 0.5), floor(sy - py_ * w + 0.5), floor(sx + px_ * w + 0.5), floor(sy + py_ * w + 0.5), Q[2])
  c:px(floor(tx_ + 0.5), floor(ty_ + 0.5), D.SPEC)
end
crystal(17, 48, 4, 53, 2.9)
crystal(19, 46, 6, 40, 2.7)
crystal(21, 50, 14, 59, 2.6)
-- apex quartz point (quirk), planted on the last whorl
crystal(40, 23, 47, 11, 2.5)
-- a single cream sparkle
c:sparkle(9, 31)
D.fin(c)
