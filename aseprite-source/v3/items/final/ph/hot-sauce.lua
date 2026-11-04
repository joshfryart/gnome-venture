-- hot-sauce (final, Opus single pass). A slim woozy-style glass bottle (long neck, sloped shoulders) full of glossy red
-- sauce, a green knurled screw cap like a chili stem, and a wrap-around cream label with a red chili pepper.
-- Material: per-pixel cylinder light on sauce (6 tones) and glass headspace (6 tones), bright glass rim streak + glint,
-- thick dark glass base, meniscus line, knurled cap ridges + lit bevel, label curving with the bottle (shaded
-- edges, gold border rows), twisted twine. Ground shadow.
-- quirk: a tiny dried chili hangs from a twine loop tied round the neck, like a lucky charm.
local NAME = "hot-sauce"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local SAUCE = { "#4e1430", "#7e1c34", "#b42a3a", "#e0423a", "#ff6e48", "#ffa880" }
local GLASS = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#8bd4d8", "#c4eee6", "#eafaf4" }
local CAP = A.LEAF
local LABEL = { "#9c8a80", "#c8b49c", "#e8d6b4", "#f8ead0", "#fff4d6", "#fff4d6" }
local TW = { "#864c33", "#b97a4a", "#e8b982" }

c:groundShadow(32, 56, 11, 2)

local neck = HP.rect(29, 15, 35, 25)
local shoulder = HP.poly{ { 29, 23 }, { 36, 23 }, { 41, 31 }, { 24, 31 } }
local body = HP.rrect(24, 30, 40, 55, 3)
local bottle = neck:copy():add(shoulder):add(body)
local lip = HP.rect(28, 15, 36, 16)
bottle:add(lip)
local CX = 32.5
local function fy(y) return y > 52 and (y - 52) * 0.35 or 0 end
local bn = {}
bottle:each(function(x, y)
  local hw = (y >= 31) and 8.5 or ((y <= 23) and 3.5 or (3.5 + (y - 23) * 5 / 8))
  local sn = max(-0.97, min(0.97, (x + 0.5 - CX) / (hw + 0.5)))
  local ny = -0.1 + fy(y) + ((y > 23 and y < 31) and -0.35 or 0)
  bn[K(x, y)] = { A.norm(sn, ny, sqrt(1 - sn*sn)) }
end)
local MEN = 19
local sauce, glass = HP.mask(), HP.mask()
bottle:each(function(x, y) if y >= MEN and y <= 54 and not lip:has(x, y) then sauce:set(x, y) else glass:set(x, y) end end)
local gtok, stok = { r = { name = "glass" } }, { r = { name = "sauce" } }
local gidx = A.shade(c, glass, bn, GLASS, { tok = gtok, amb = 0.1, wrap = 0.3 })
local sidx = A.shade(c, sauce, bn, SAUCE, { tok = stok, amb = 0.06, wrap = 0.2 })
-- thick glass base
bottle:each(function(x, y) if y >= 55 then c:put(x, y, x < 30 and "#7e3a4a" or "#4e2438", gtok) end end)
-- meniscus
for x = 29, 35 do c:put(x, MEN, x < 32 and SAUCE[5] or SAUCE[4], stok) end
-- glass wall: dark right edge, pale left streaks + glint
bottle:edge():each(function(x, y) if y >= MEN and y < 55 and x > CX + 2 then c:put(x, y, SAUCE[1], stok) end end)
for y = 34, 52 do c:put(26, y, SAUCE[6], stok) end
for y = 20, 24 do c:put(30, y, SAUCE[6], stok) end
c:put(30, 17, GLASS[6], gtok) c:put(30, 18, GLASS[6], gtok) c:put(26, 36, A.CREAM, stok)
for _, q in ipairs{ { 27, 30 }, { 28, 29 }, { 26, 31 } } do c:put(q[1], q[2], SAUCE[6], stok) end
-- lip bevel
for x = 28, 36 do c:put(x, 15, x < 31 and GLASS[6] or GLASS[4], gtok) c:put(x, 16, x < 31 and GLASS[4] or GLASS[2], gtok) end

-- label (wraps: tone follows the bottle light)
local lab = HP.rect(24, 37, 40, 50)
lab:each(function(x, y) local k = K(x, y)
  local i = sidx[k] or 3
  local col = LABEL[max(1, min(6, i + 1))]
  if y == 37 or y == 50 then col = ({ "#8f4a1f", "#8f4a1f", "#d98322", "#d98322", "#f5b82e", "#ffe38a" })[i] end
  if x == 24 or x == 40 then col = LABEL[max(1, i - 1)] end
  c:put(x, y, col, stok) end)
-- shadow line under the top label edge
for x = 25, 39 do c:put(x, 38, LABEL[max(1, min(6, (sidx[K(x, 38)] or 3)))], stok) end
-- chili pepper on the label
c:paint({
  "....gg",
  "...Gg.",
  "..hRR.",
  ".hRRr.",
  ".RRRr.",
  "RRRr..",
  "RRr...",
  "Rr....",
  "r.....",
}, 29, 39, { g = "#3f9150", G = "#7cc35a", h = "#ff8a5c", R = "#e8493b", r = "#b52e3f" })
-- label 'text' rows
for x = 27, 37 do if x % 3 ~= 0 then c:put(x, 48, "#8f4a1f", stok) end end

-- cap: knurled green
local cap = HP.rrect(28, 7, 36, 14, 1)
local ctok = { r = { name = "cap" } }
local cidx = A.shade(c, cap, A.vcyl(cap, 32.5, 4.5, -0.2), CAP, { tok = ctok, amb = 0.1, wrap = 0.25 })
cap:each(function(x, y) local i = cidx[K(x, y)] or 3
  if y >= 9 and y <= 13 and x % 2 == 1 then c:put(x, y, CAP[max(1, i - 1)], ctok) end
  if y == 7 then c:put(x, y, CAP[min(6, i + 1)], ctok) end
  if y == 14 then c:put(x, y, CAP[max(1, i - 2)], ctok) end
end)
c:put(30, 8, "#e2f2bc", ctok)

-- quirk: twine round the neck (twist) with a dangling dried chili
local twt = { r = { name = "twine" } }
for x = 29, 35 do c:put(x, 21, (x % 2 == 0) and TW[3] or TW[2], twt) c:put(x, 22, (x % 2 == 0) and TW[1] or TW[2], twt) end
c:put(36, 21, TW[2], twt) c:put(36, 22, TW[1], twt) c:put(37, 22, TW[2], twt)  -- knot
A.line(c, { { 37, 23 }, { 38, 25 } }, TW[2], twt)
local ch = { r = { name = "charm" } }
c:paint({
  ".g.",
  "RRr",
  "hRr",
  "hRr",
  ".Rr",
  ".Rr",
  "..r",
}, 37, 26, { g = "#3f9150", R = "#c2303a", h = "#ff7a50", r = "#7e1c34" })
for y = 26, 32 do for x = 37, 39 do if c:get(x, y) and c.own[y * 64 + x] == true then c.own[y * 64 + x] = ch end end end
-- contact shadow on the bottle right of the charm
for _, q in ipairs{ { 40, 28 }, { 40, 29 }, { 40, 30 } } do if bottle:has(q[1], q[2]) then c:put(q[1], q[2], SAUCE[1], stok) end end

A.save(c, NAME)
