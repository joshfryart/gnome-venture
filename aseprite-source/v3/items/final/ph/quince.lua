-- quince (D10_5, redraw): a lean, lumpy pear-shaped quince leaning a little to the right, golden belly easing to a
-- lime-green neck, soft grey-white fuzz on the shade side, rubbed-smooth glossy patch on the lit side, two faint
-- lobe ridges, a dark calyx with dried sepals at the foot, a woody stalk and two veined leaves.
-- Material: per-pixel sphere-ish light on a 6-tone ramp (two ramps blended by a ragged line), bloom specks, bounce.
-- quirk: a tiny green inchworm is arched on the right shoulder.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_5.lua")
local B, HP, X, K, H = D.B, D.HP, D.X, D.K, D.H
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("quince")
local hash = D.hash

local YR = { "#6e4c0c", "#a87a18", "#d2a426", "#ecc83e", "#f8e468", "#fffbb6" }
local GR = { "#4a5a12", "#7c8c1e", "#a8b830", "#cad448", "#e4ea78", "#f8fbb4" }
local LF = { "#1d4a30", "#2c6a3c", "#468a46", "#68aa50", "#8ec868", "#bce090" }

c:groundShadow(31, 56, 12, 2)

-- profile (t along height) -> half width
local Y0, Y1 = 19, 53
local prof = { { 0, 3.2 }, { 0.05, 4.8 }, { 0.14, 5.9 }, { 0.26, 7.2 }, { 0.4, 9.4 }, { 0.54, 11.4 }, { 0.68, 12.3 }, { 0.8, 11.8 }, { 0.9, 9.6 }, { 0.96, 6.6 }, { 1.0, 3.4 } }
local function hw(y)
  local t = max(0, min(1, (y - Y0) / (Y1 - Y0)))
  for i = 1, #prof - 1 do
    local a, b = prof[i], prof[i + 1]
    if t <= b[1] then
      local u = (t - a[1]) / (b[1] - a[1])
      u = (1 - cos(u * pi)) / 2
      return a[2] + (b[2] - a[2]) * u
    end
  end
  return prof[#prof][2]
end
local function cx(y) return 31 + (36 - y) * 0.11 end
local function lumpL(y) return 0.9 * sin(y * 0.55 + 1.0) + 0.5 * sin(y * 1.35) end
local function lumpR(y) return 0.8 * sin(y * 0.5 + 3.0) + 0.5 * sin(y * 1.2 + 1) end
local F = HP.mask()
for y = Y0, Y1 do
  local h = hw(y)
  local x0 = floor(cx(y) - h - lumpL(y) * (h / 12) + 0.5)
  local x1 = floor(cx(y) + h + lumpR(y) * (h / 12) - 0.5)
  for x = x0, x1 do F:set(x, y) end
end

-- light
local n = X.pillow(F, 11)
local v = X.light(n, { amb = 0.07, wrap = 0.22 })
local bias = {}
-- two shallow lobe ridges (darker grooves) down the belly
for y = 33, 50 do
  if y % 5 ~= 0 then
    local h = hw(y)
    local gx = floor(cx(y) + h * 0.33 + 0.5)
    local k = K(gx, y) if F:has(gx, y) then bias[k] = -1 end
  end
end
local Mg, My = HP.mask(), HP.mask()
F:each(function(x, y)
  local edge = 29 + 2.6 * sin(x * 0.5) + (hash(x, y, 3) > 0.6 and 1 or 0) - (x - 31) * 0.15
  if y < edge then Mg:set(x, y) else My:set(x, y) end
end)
X.tone(c, Mg, v, GR, { bias = bias })
X.tone(c, My, v, YR, { bias = bias })
-- cool reflected light on the lower-right rim
local rim = X.rim(n)
F:edge():each(function(x, y) if rim[K(x, y)] > 0.8 and y > 36 and y < 52 and x > cx(y) then c:px(x, y, "#9fb88a") end end)
-- fuzz bloom on the shade side, absent where light is strong
F:shrink(1):each(function(x, y)
  local vv = v[K(x, y)]
  local h = hash(x, y, 17)
  if vv < 0.5 and h < 0.16 then c:px(x, y, h < 0.07 and "#f3efd0" or "#d8cf98")
  elseif vv < 0.72 and h < 0.04 then c:px(x, y, "#f6f2d4") end
end)
-- rubbed-smooth glossy patch (brighter band) + specular
local pt = B.ell(24.5, 40, 3.2, 5, 0.35):clip(F)
pt:each(function(x, y) local kk = K(x, y) c:px(x, y, YR[min(6, 4 + (v[kk] > 0.6 and 1 or 0))]) end)
c:px(23, 36, D.SPEC) c:px(23, 37, D.SPEC) c:px(24, 35, D.SPEC) c:px(22, 38, YR[6])

-- calyx at the foot
local cy_ = 51.5
c:fillMask(B.ell(cx(52) - 0.5, cy_, 3.4, 1.5, 0), "#4a300a")
c:fillMask(B.ell(cx(52) - 0.5, cy_ + 0.2, 2, 0.8, 0), "#2a1a08")
for _, p in ipairs({ { -4, -1 }, { 3, -1 }, { -2, 1 }, { 1, 1 } }) do
  c:px(floor(cx(52) - 0.5 + p[1] + 0.5), floor(cy_ + p[2] + 0.5), "#6a4a14")
end
c:px(floor(cx(52)) - 1, floor(cy_) - 1, "#8a6a22")

-- neck crown + stalk + leaves
local topx = cx(Y0)
c:fillMask(B.ell(topx, Y0 + 0.5, 3, 1.1, 0), GR[1])
D.tube(c, { { topx, Y0 }, { topx - 0.5, 16 }, { topx + 0.5, 14 }, { topx + 2, 12.5 } }, function() return 1.35 end, "wood", 1)
B.blade(c, topx + 1.5, 14, 48, 10, 4.2, LF, { veins = { 3, 6, 9, 12 }, slant = 2.0 })
B.blade(c, topx + 0.5, 13.5, 21, 10, 3.5, LF, { veins = { 3, 6, 9 }, slant = 2.0 })

-- inchworm on the right shoulder (quirk)
local WM = { "#2d7a2c", "#4aa83a", "#74cc4c", "#a4e46c", "#d2f69c" }
local pts = { { 37, 32 }, { 38, 30 }, { 39.5, 28.6 }, { 41.5, 28.2 }, { 43.5, 29.2 }, { 44.5, 31 }, { 44.5, 33 } }
local worm = c:line(pts, 2)
-- shadow under the worm
worm:shift(1, 1):cut(worm):clip(F):each(function(x, y) c:px(x, y, YR[2]) end)
local wn = X.pillow(worm, 1.6)
X.tone(c, worm, X.light(wn, { amb = 0.15, wrap = 0.3 }), WM, {})
-- body segment lines
c:px(39, 29, WM[2]) c:px(41, 28, WM[2]) c:px(43, 29, WM[2])
-- head (right end) with an eye, front feet pixels
c:px(44, 32, WM[3]) c:px(45, 32, WM[3]) c:px(45, 33, WM[2])
c:px(45, 32, D.INK)
c:px(37, 33, WM[1]) c:px(44, 34, WM[1])
D.fin(c)
