-- stone-path (lean P1b_O13)
local NAME = "stone-path"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function T(nm) return { r = { name = nm } } end
local function ball(m, R, ramp, nm, o) local n = X.pillow(m, R) o = o or {} o.tok = T(nm) if not o.cuts then o.cuts = {0.2,0.38,0.55,0.72,0.86} end G.toneN(c, m, n, ramp, o) return n end
local SOIL = { "#1e1218", "#3a2420", "#5e3a2a", "#86583a", "#ae7e4a" }
local GREY = { "#3d3f58", "#5a5e7a", "#7e84a0", "#a2a8bf", "#c6cbdc", "#e6e9f2" }
local TAN  = { "#5a4030", "#7e5c42", "#a47c58", "#c89e72", "#e2be90", "#f6dcb4" }
local VIO  = { "#3e2c52", "#5c4272", "#7e5e92", "#a283b2", "#c4a8d2", "#e4d0ee" }
local GR   = { "#14402c", "#256a3a", "#3e9444", "#68bc50", "#9ada68" }
c:groundShadow(32, 57, 25, 3)
local soil = c:ellipse(32, 41, 26, 16)
ball(soil, 14, SOIL, "soil", { amb = 0.15, wrap = 0.25, cuts = {0.2,0.4,0.6,0.8,0.9} })
soil:each(function(x, y) local h = X.hash(x, y, 5) if h > 0.9 then c:put(x, y, SOIL[5], T("soil")) elseif h < 0.08 then c:put(x, y, SOIL[1], T("soil")) end end)
local stones = {
  { 32, 22, 6, 3.2, GREY, 1 }, { 40, 30, 7.5, 3.8, TAN, 2 }, { 22, 37, 9, 4.4, VIO, 3 },
  { 46, 43, 9, 4.4, GREY, 4 }, { 24, 50, 10, 4.8, TAN, 5 }, { 43, 53, 8, 3.8, VIO, 6 },
}
table.sort(stones, function(a, b) return a[2] < b[2] end)
for _, s in ipairs(stones) do
  local cx, cy, rx, ry, ramp, sd = s[1], s[2], s[3], s[4], s[5], s[6]
  local top, side = HP.mask(), HP.mask()
  local ph = sd * 1.7
  for y = floor(cy - ry - 3), floor(cy + ry + 4) do for x = floor(cx - rx - 3), floor(cx + rx + 3) do
    local dx, dy = x - cx, y - cy
    local th = 1 + 0.12 * sin(3 * atan2(dy, dx) + ph) + 0.07 * sin(5 * atan2(dy, dx) + ph * 2)
    if (dx / rx) ^ 2 + (dy / ry) ^ 2 <= th then top:set(x, y) end
    if (dx / rx) ^ 2 + ((dy - 2.5) / ry) ^ 2 <= th then side:set(x, y) end
  end end
  side:cut(top)
  side:each(function(x, y) c:put(x, y, (x - cx) > rx * 0.1 and ramp[1] or ramp[2], T("sd" .. sd)) end)
  local n = X.pillow(top, ry * 1.6)
  G.toneN(c, top, n, ramp, { tok = T("st" .. sd), cuts = {0.2,0.4,0.58,0.75,0.9}, amb = 0.18, wrap = 0.35 })
  top:each(function(x, y) local h = X.hash(x, y, sd)
    if h > 0.93 then c:put(x, y, ramp[2], T("st" .. sd)) elseif h < 0.05 then c:put(x, y, ramp[5], T("st" .. sd)) end end)
  -- crack
  local x0 = floor(cx - rx * 0.2)
  for i = 0, 3 do if top:has(x0 + i, floor(cy) + (i % 2)) then c:put(x0 + i, floor(cy) + (i % 2), ramp[1], T("st" .. sd)) end end
  -- bright top-left rim glint
  c:put(floor(cx - rx * 0.5), floor(cy - ry * 0.6), ramp[6], T("st" .. sd))
  c:put(floor(cx - rx * 0.5) + 1, floor(cy - ry * 0.6), ramp[6], T("st" .. sd))
end
-- grass tufts in the gaps
local function tuft(x, y) for i, d in ipairs{ -1, 0, 1 } do c:put(x + d, y - (i == 2 and 2 or 1), GR[i == 2 and 4 or 3], T("gr")) c:put(x + d, y, GR[2], T("gr")) end c:put(x, y - 3, GR[5], T("gr")) end
tuft(33, 32) tuft(12, 45) tuft(54, 36) tuft(34, 46) tuft(14, 33)
-- quirk: tiny blue flower in a gap
c:put(32, 40, "#4a8c3a", T("fl")) c:put(32, 41, "#4a8c3a", T("fl"))
for _, p in ipairs{ {31,38},{33,38},{32,37},{32,39} } do c:put(p[1], p[2], "#7ab0ff", T("fl")) end
c:put(32, 38, "#ffe27a", T("fl"))
G.save(c, NAME)
