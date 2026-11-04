-- golem-pebble (B3, Opus single pass). A flat tumbled pebble of rose granite shed by a stone golem: smooth
-- pillowy body, dark and pale mineral flecks, a polished specular, cool bounce light, a carved rune groove that
-- glows gold from inside (shadowed upper-left wall, lit lower-right lip), small ground shadow.
-- quirk: a tuft of moss has taken root on its top shoulder.
local NAME = "golem-pebble"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new(NAME)
local ST = { "#4a2a48", "#743e5e", "#a1577a", "#c97690", "#e9a0ae", "#fbcdc8" }
local MOSS = { "#24544a", "#3f9150", "#5aab55", "#7cc35a", "#a6d46a", "#c4e07a" }
local GLOW = { "#d98322", "#f5b82e", "#ffe38a" }
local COOL = "#6f5a92"
c:groundShadow(32, 47, 19, 2)
local CX, CY = 32, 33
local pm, pn = A.oval(CX, CY, 20, 12, -0.1, 0.45)
local moss = HP.mask()
for _, q in ipairs{ { 36, 21, 2.2, 1.6 }, { 40, 21, 1.8, 1.4 }, { 33, 22, 1.4, 1.1 }, { 38, 19, 1.4, 1.2 } } do
  moss:add(A.rell(q[1], q[2], 1, 0, q[3], q[4])) end
local bias = {}
X.ao(bias, pm, moss, 1, -1)
local ptok = { r = { name = "pebble" } }
local idx = A.shade(c, pm, A.body(pm, CX - 1, CY - 2, 20, 6, 0.45), ST, { amb = 0.08, wrap = 0.3, bias = bias, tok = ptok })
local pn2 = A.body(pm, CX - 1, CY - 2, 20, 6, 0.45)
local rim = X.rim(pn2)
local e = pm:edge()
pm:each(function(x, y) local k = K(x, y)
  if e:has(x, y) and rim[k] > 0.5 and idx[k] <= 3 and y > CY then c:put(x, y, COOL, ptok) idx[k] = 2 end end)
-- flecks (granite): sparse dark mica and pale quartz
pm:each(function(x, y) local k = K(x, y)
  if e:has(x, y) then return end
  local h = X.hash(x, y, 7)
  if h > 0.955 then c:put(x, y, ST[max(1, idx[k] - 2)], ptok)
  elseif h < 0.03 and idx[k] >= 3 then c:put(x, y, ST[min(6, idx[k] + 2)], ptok) end end)
-- rune: diamond with a crossbar and two tails, carved and glowing
local runes = {
  { { 25, 33 }, { 31, 28 }, { 37, 33 }, { 31, 38 }, { 25, 33 } },
  { { 19, 34 }, { 25, 33 } }, { { 37, 33 }, { 44, 31 } }, { { 31, 28 }, { 31, 38 } },
}
local g = HP.mask()
for _, pl in ipairs(runes) do g:add(c:line(pl, 1)) end
g:clip(pm:shrink(2))
g:shift(-1, -1):each(function(x, y) if pm:has(x, y) and not g:has(x, y) then local k = K(x, y) c:put(x, y, ST[max(1, (idx[k] or 3) - 2)], ptok) end end)
g:shift(1, 1):each(function(x, y) if pm:has(x, y) and not g:has(x, y) and not g:shift(-1, -1):has(x, y) then local k = K(x, y) c:put(x, y, ST[min(6, (idx[k] or 3) + 1)], ptok) end end)
g:each(function(x, y) c:put(x, y, GLOW[2], ptok) end)
for _, p in ipairs{ { 31, 33 }, { 31, 32 }, { 28, 31 }, { 34, 35 } } do if g:has(p[1], p[2]) then c:put(p[1], p[2], GLOW[3], ptok) end end
for _, p in ipairs{ { 19, 34 }, { 44, 31 } } do if g:has(p[1], p[2]) then c:put(p[1], p[2], GLOW[1], ptok) end end
-- polish specular
local sx, sy = A.specAt(pm, pn2, 50)
c:put(sx, sy, "#fff4d6", ptok) c:put(sx + 1, sy, ST[6], ptok)
-- quirk: moss tuft
local mtok = { r = { name = "moss" } }
local midx = A.shade(c, moss, X.pillow(moss, 2), MOSS, { amb = 0.1, wrap = 0.3, tok = mtok })
moss:each(function(x, y) if X.hash(x, y, 3) > 0.7 then local k = K(x, y) c:put(x, y, MOSS[max(1, midx[k] - 1)], mtok) end end)
c:put(38, 17, MOSS[5], mtok) c:put(38, 16, "#fff4d6", mtok)
A.save(c, NAME)
