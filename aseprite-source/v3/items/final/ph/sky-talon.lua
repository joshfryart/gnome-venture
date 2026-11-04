-- sky-talon (lean D2o_0)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c
local function shade(m, ramp, R, o) local n = X.pillow(m, R) return G.toneN(c, m, n, ramp, o), n end
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sky-talon" }
local SKY = { "#3b5578", "#5c7ea6", "#86a9c9", "#b0cde0", "#d6e8f0", "#f6fbff" }
local AMB = { "#5a2f17", "#7e4620", "#a8662b", "#cf8c3a", "#eab35a", "#fbd98a" }
local CORD = { "#6b5438", "#9a7d52", "#c8aa74", "#e8d2a0" }
local FEA = { "#6c6a9a", "#9a98c0", "#c4c4e0", "#e8e8f6", "#fafaff" }
-- the claw: wide amber base sweeping into a hooked sky-blue tip
local m, n, T, S, len = G.blade(22, 8, 54, 26, 28, 56, function(t)
  if t > 0.995 then return -1 end
  return 0.6 + 7.6 * (1 - t) ^ 0.9 * (1 - 0.1 * t)
end, { fold = 0.5 })
local amb, sky = HP.mask(), HP.mask()
m:each(function(x, y) if T[K(x, y)] < 0.3 then amb:set(x, y) else sky:set(x, y) end end)
G.toneN(c, amb, n, AMB)
G.toneN(c, sky, n, SKY)
-- keratin growth grooves along the blade
m:each(function(x, y)
  local k = K(x, y)
  if T[k] > 0.3 and T[k] < 0.92 and abs(S[k] + 0.12) < 0.13 then c:px(x, y, SKY[2]) end
  if T[k] > 0.3 and T[k] < 0.85 and abs(S[k] + 0.55) < 0.1 then c:px(x, y, SKY[6]) end
  if T[k] > 0.9 and S[k] < 0 and abs(S[k]) < 0.5 then c:px(x, y, SKY[6]) end
end)
-- wound cord bands at the base
m:each(function(x, y)
  local t = T[K(x, y)]
  if t > 0.0 and t < 0.2 then
    local b = floor(t * len / 1.7) % 2
    local l = S[K(x, y)] < 0
    c:px(x, y, b == 0 and (l and CORD[4] or CORD[2]) or (l and CORD[3] or CORD[1]))
  end
end)
-- quirk: a little feather charm hanging from the cord
local fm, fn = G.blade(26, 14, 22, 21, 24, 29, function(t) if t > 0.98 then return -1 end return 0.5 + 2.4 * sin(pi * min(1, t * 1.05)) ^ 0.7 end)
G.toneN(c, fm, fn, FEA)
c:fillMask(c:line({ {26, 14}, {24, 29} }, 1):clip(fm), FEA[2])
G.save(c, "sky-talon")
