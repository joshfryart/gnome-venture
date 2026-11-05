-- frost-fur (lean P1b_O2)
local NAME = "frost-fur"
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
-- hanging tuft of icy fur: leather tab + loop, five tapering frosty locks, icicle tips; quirk: one drip about to fall
local FUR = { "#34406e", "#54709f", "#86aed0", "#bddbec", "#e6f5fa", "#f8feff" }
local LEA = { "#3a2216", "#5a3820", "#80532c", "#a8733c", "#cf9a56", "#ecc280" }
local locks = {
  { 24, 22, 8, 36, 11, 53, 4.6 }, { 40, 22, 56, 36, 53, 53, 4.6 },
  { 28, 22, 18, 40, 21, 57, 4.8 }, { 36, 22, 46, 40, 43, 56, 4.8 },
  { 32, 22, 31, 40, 32, 58, 5.4 },
}
for i, L in ipairs(locks) do
  local m, n, T, S = G.blade(L[1], L[2], L[3], L[4], L[5], L[6], function(t) return L[7] * (1 - t) ^ 0.75 + 0.5 end, { fold = 0.7 })
  lit(m, n, FUR, { seam = FUR[2], amb = 0.1 })
  m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
    if t > 0.12 and t < 0.9 then
      if abs(s) < 0.1 then c:px(x, y, s < 0 and FUR[5] or FUR[2])
      elseif hx(x, y, 5 + i) > 0.9 then c:px(x, y, FUR[2]) end
    end
    if t > 0.9 then c:px(x, y, s < 0 and "#c8f6ff" or "#6cc8e6") end
  end)
end
-- drip quirk under the left outer lock tip
c:px(11, 56, "#9fe6f6") c:px(11, 57, "#9fe6f6") c:px(11, 58, "#6cc8e6")
-- leather tab + loop
local loop = G.tube({ {27, 14}, {25, 2}, {39, 2}, {37, 14} }, function() return 1.5 end)
local lm, ln = loop
lit(lm, select(2, G.tube({ {27, 14}, {25, 2}, {39, 2}, {37, 14} }, function() return 1.5 end)), LEA, { seam = LEA[1] })
local tab = c:rrect(24, 13, 40, 25, 2)
pil(tab, LEA, 4, { seam = LEA[1] })
for x = 26, 38, 3 do c:px(x, 20, LEA[6]) c:px(x + 1, 20, LEA[6]) end
c:fillMask(c:rect(25, 24, 39, 24), LEA[1])
c:px(26, 15, "#fff0c0") c:px(27, 15, LEA[6])
G.save(c, NAME)
