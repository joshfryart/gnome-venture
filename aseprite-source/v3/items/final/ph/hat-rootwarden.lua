-- hat-rootwarden (lean P1b_O2)
local NAME = "hat-rootwarden"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local drawn = HP.mask()
-- lit(mask, normals, ramp, opts): tone with normals; opts.seam = colour for the border where it overlaps earlier art
local function lit(m, n, ramp, o)
  o = o or {}
  local prior = drawn:copy()
  local _, v = G.toneN(c, m, n, ramp, o)
  if o.seam then m:edge():each(function(x, y) if prior:has(x, y) then c:px(x, y, o.seam) end end) end
  drawn:add(m)
  return v
end
local function pil(m, ramp, R, o) return lit(m, X.pillow(m, R), ramp, o) end
local function hx(x, y, s) return X.hash(x, y, s or 1) end
-- rootwarden's hat: cracked-earth crown, root-woven brim with hanging rootlet tendrils, red band with gold buckle, a two-leaf sprout; quirk: a pink worm peeks out of the crown
local S = { "#2e1f1a", "#4a3226", "#6e4a34", "#946a46", "#bb9060", "#dcb97f" }
local RT = { "#3a2418", "#5a3a26", "#7e5434", "#a6743f", "#cc9a58", "#e8c07c" }
local RD = { "#4a0e22", "#7a1530", "#a82638", "#cf3c3a", "#ee6a48", "#ffa070" }
local GD = { "#6a4a10", "#a37a1c", "#d8a828", "#f4cc48", "#fff0a0", "#fffbd0" }
local LF = { "#17402e", "#1f5e3a", "#2f8040", "#4da44c", "#7cc660", "#b0e284" }
local function tube(pts, w, ramp, o) local m, n, T, S2 = G.tube(pts, w) lit(m, n, ramp, o) return m end
-- tendrils (behind brim)
local ends = {
  { {12, 44}, {9, 50}, {14, 54}, {11, 58} }, { {22, 47}, {20, 52}, {25, 55}, {22, 59} },
  { {32, 50}, {30, 53}, {35, 55}, {33, 58} }, { {43, 47}, {45, 52}, {40, 55}, {44, 59} },
  { {53, 44}, {56, 50}, {51, 54}, {54, 57} },
}
for _, e in ipairs(ends) do tube(e, function(t) return 1.9 - 1.2 * t end, RT, { seam = RT[1] }) end
c:fillMask(c:line({ {44, 59}, {46, 59}, {46, 57} }, 1), RT[4])   -- curled tip
-- brim
local brim = c:ellipse(32, 42, 26, 8)
local bn = X.pillow(brim, 5)
lit(brim, bn, S, { seam = S[1], amb = 0.12 })
brim:each(function(x, y)
  local a = atan((y - 42) * 3.4, (x - 32))
  if floor(a * 16) % 3 == 0 and hx(x, y, 6) > 0.2 then c:px(x, y, y > 42 and S[2] or S[4]) end
end)
-- crown
local full = c:ellipse(32, 33, 17, 12)
local crown = HP.mask()
full:each(function(x, y) if y <= 41 then crown:set(x, y) end end)
local cn = X.pillow(crown, 7)
lit(crown, cn, S, { seam = S[1], amb = 0.06 })
crown:each(function(x, y) local h = hx(x, y, 2) if h > 0.93 then c:px(x, y, S[6]) elseif h < 0.06 then c:px(x, y, S[1]) end end)
c:fillMask(c:line({ {26, 24}, {28, 27}, {27, 31}, {29, 34} }, 1), S[1])
c:fillMask(c:line({ {38, 22}, {37, 26}, {40, 29} }, 1), S[1])
-- band + buckle
local band = HP.mask()
crown:each(function(x, y) local k = 0.015 * (x - 32) ^ 2 if y >= 34 + k and y <= 38.5 + k then band:set(x, y) end end)
lit(band, X.pillow(band, 3), RD, { seam = RD[1], amb = 0.1 })
local buckle = c:rect(28, 33, 35, 40)
lit(buckle, X.pillow(buckle, 3), GD, { seam = GD[1] })
c:fillMask(c:rect(30, 35, 33, 38), RD[1])
c:px(29, 34, GD[6])
-- worm
tube({ {41, 30}, {46, 28}, {46, 24}, {42, 23} }, function() return 1.3 end, { "#7a2f4a", "#b04f68", "#d8788a", "#f0a0a8", "#ffd0cc", "#ffe8e4" }, { seam = "#5a1f38" })
c:px(42, 23, "#2a1a1e")
-- sprout
tube({ {32, 22}, {32, 19}, {32, 17}, {32, 14} }, function() return 1.2 end, { "#2f6a3c", "#4d8c4c", "#86b868", "#bde096" }, { seam = LF[1] })
for _, L in ipairs{ { 32, 14, 22, 8, 14, 12 }, { 32, 14, 42, 6, 50, 9 } } do
  local m, n, T, S2 = G.blade(L[1], L[2], L[3], L[4], L[5], L[6], function(t) return t > 0.98 and -1 or 4 * sin(pi * min(1, t * 1.05 + 0.04)) ^ 0.7 end, { fold = 0.6 })
  lit(m, n, LF, { seam = LF[1] })
  m:each(function(x, y) local k = K(x, y) if abs(S2[k]) < 0.13 and T[k] > 0.1 and T[k] < 0.9 then c:px(x, y, LF[6]) end end)
end
G.save(c, NAME)
