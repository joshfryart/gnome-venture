-- iced-tea-concentrate (final, Opus single pass aC12_5). A tall, slim swing-top glass bottle (square shoulders, short
-- neck) full of dark amber tea concentrate, closed by a cream ceramic stopper with a red rubber gasket and a steel
-- wire bail. A pale-blue label with a lemon slice and an ice cube, gold border rows.
-- Material: per-pixel cylinder light on the tea (6 tones) and glass headspace, warm glow through the lit side,
-- bright vertical glass streak + glint, thick dark glass base, meniscus line, cold condensation beads (lit top, dark
-- foot) on the glass, glazed stopper with specular, steel wire bevel, label curving with the bottle. Ground shadow.
-- quirk: a sprig of mint is tucked under the wire bail.
local NAME = "iced-tea-concentrate"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local TEA = { "#2e0e14", "#56181a", "#86301c", "#b8521e", "#e2842e", "#ffbe62" }
local GLASS = { "#2a4a6a", "#3e7090", "#6aa8b8", "#9ed2d4", "#d0f0ea", "#f0fcf6" }
local CER = { "#6a6078", "#9a92a4", "#c8c2c8", "#e6e0d8", "#f6f0e4", "#fff8ec" }
local STEEL = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local LAB = { "#5a7a9a", "#7ea6c0", "#a8cede", "#cce8ee", "#e8f6f4", "#f6fcf8" }
local LEAF = A.LEAF
local gtok, ttok, ctok, wtok = { r = { name = "glass" } }, { r = { name = "tea" } }, { r = { name = "stopper" } }, { r = { name = "wire" } }

c:groundShadow(32, 54, 10, 2)

-- bottle: neck 7 wide, square shoulder, body 15 wide
local CX = 32.5
local neck = HP.rect(29, 14, 35, 21)
local lip = HP.rect(28, 13, 36, 15)
local shoulder = HP.poly{ { 29, 20 }, { 35, 20 }, { 39, 25 }, { 25, 25 } }
local body = HP.rrect(25, 24, 39, 53, 2)
local bottle = neck:copy():add(lip):add(shoulder):add(body)
local bn = {}
bottle:each(function(x, y)
  local hw = (y >= 25) and 7.5 or ((y <= 20) and 3.5 or (3.5 + (y - 20) * 4 / 5))
  local sn = max(-0.97, min(0.97, (x + 0.5 - CX) / (hw + 0.5)))
  local ny = -0.08 + ((y > 20 and y < 25) and -0.45 or 0) + (y > 50 and 0.4 or 0)
  bn[K(x, y)] = { A.norm(sn, ny, sqrt(1 - sn * sn)) }
end)
local MEN = 22
local tea, glass = HP.mask(), HP.mask()
bottle:each(function(x, y) if y >= MEN and y <= 51 then tea:set(x, y) else glass:set(x, y) end end)
local gidx = A.shade(c, glass, bn, GLASS, { tok = gtok, amb = 0.12, wrap = 0.3 })
local tidx = A.shade(c, tea, bn, TEA, { tok = ttok, amb = 0.04, wrap = 0.18 })
-- warm glow through the lit side (light passes through the tea)
tea:each(function(x, y) if x == 27 and y > 27 and y < 52 then c:put(x, y, TEA[5], ttok) end end)
-- thick glass base
bottle:each(function(x, y) if y >= 52 then c:put(x, y, (x < 30) and "#7a4a40" or "#4a2a30", gtok) end end)
-- meniscus
for x = 26, 38 do if bottle:has(x, MEN) then c:put(x, MEN, (x < 31) and TEA[6] or TEA[4], ttok) end end
-- dark right wall, glass streak + glint left
bottle:edge():each(function(x, y) if y > MEN and y < 52 and x > CX + 3 then c:put(x, y, TEA[1], ttok) end end)
for y = 27, 51 do if y < 35 or y > 45 then c:put(26, y, GLASS[5], gtok) end end
for y = 15, 20 do c:put(30, y, GLASS[6], gtok) end
c:put(26, 28, A.CREAM, gtok)
-- shoulder highlight
for _, q in ipairs{ { 27, 24 }, { 28, 23 }, { 29, 22 } } do c:put(q[1], q[2], TEA[6], ttok) end
-- lip bevel
for x = 28, 36 do c:put(x, 13, (x < 31) and GLASS[6] or GLASS[4], gtok) c:put(x, 15, (x < 31) and GLASS[3] or GLASS[1], gtok) end

-- label: wraps with the bottle light
local lab = HP.rect(25, 35, 39, 46)
lab:each(function(x, y) local k = K(x, y)
  local i = tidx[k] or 3
  local li = max(1, min(6, i + 1))
  local col = LAB[li]
  if y == 35 or y == 46 then col = ({ "#8f4a1f", "#8f4a1f", "#d98322", "#d98322", "#f5b82e", "#ffe38a" })[i] end
  if x == 25 or x == 39 then col = LAB[max(1, li - 2)] end
  c:put(x, y, col, ttok) end)
for x = 26, 38 do c:put(x, 36, LAB[max(1, min(6, (tidx[K(x, 36)] or 3)))], ttok) end
-- lemon slice (rind ring, pale pith, segments)
A.paint(c, {
  ".oyyo.",
  "oyYpYo",
  "yYpYpy",
  "ypYpYy",
  "oYpYyo",
  ".oyyo.",
}, 27, 38, { o = "#d98322", y = "#f5b82e", Y = "#ffe38a", p = "#fff4d6" }, ttok)
-- ice cube
A.paint(c, {
  "abbc",
  "bddc",
  "bdec",
  "ccce",
}, 34, 39, { a = "#f0fcf6", b = "#d0f0ea", d = "#9ed2d4", c = "#6aa8b8", e = "#3e7090" }, ttok)
-- 'x3' text row
for x = 28, 37 do if x % 3 ~= 0 then c:put(x, 45, "#2a4a7a", ttok) end end

-- condensation beads (lit top, dark foot)
for _, q in ipairs{ { 29, 29 }, { 34, 27 }, { 37, 31 }, { 31, 49 }, { 36, 49 }, { 28, 50 }, { 33, 32 } } do
  c:put(q[1], q[2], TEA[6], ttok) c:put(q[1], q[2] + 1, TEA[2], ttok) end
c:put(37, 32, TEA[1], ttok)

-- swing-top ceramic stopper + red gasket
local stop = HP.rrect(28, 6, 36, 11, 2)
local sidx = A.shade(c, stop, A.vcyl(stop, CX, 4.5, -0.45), CER, { tok = ctok, amb = 0.12, wrap = 0.3 })
c:put(30, 7, A.CREAM, ctok) c:put(31, 7, CER[6], ctok)
for x = 28, 36 do c:put(x, 12, (x < 31) and "#e8493b" or "#b52e3f", ctok) end
c:put(36, 12, "#6e2038", ctok)
-- wire bail: loop over the stopper, levers down the neck sides to a pivot ring
local function wire(pts)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local n = max(abs(x1 - x0), abs(y1 - y0))
    for j = 0, n do local t = n == 0 and 0 or j / n
      local x, y = floor(x0 + (x1 - x0) * t + 0.5), floor(y0 + (y1 - y0) * t + 0.5)
      c:put(x, y, (x < 32) and STEEL[3] or STEEL[2], wtok) end
  end
end
wire{ { 27, 10 }, { 27, 13 }, { 28, 17 }, { 28, 19 } }
wire{ { 37, 10 }, { 37, 13 }, { 36, 17 }, { 36, 19 } }
for x = 28, 36 do c:put(x, 9, (x < 31) and STEEL[4] or STEEL[2], wtok) end
-- pivot ring round the neck
for x = 28, 36 do c:put(x, 19, (x < 31) and STEEL[3] or STEEL[1], wtok) end
c:put(27, 9, STEEL[3], wtok) c:put(37, 9, STEEL[1], wtok)

-- quirk: mint sprig tucked under the right wire
local mtok = { r = { name = "mint" } }
A.paint(c, {
  "...ab.",
  "..abbc",
  ".s.bcc",
  "s.ab..",
  "s.abc.",
  "s..cc.",
}, 37, 9, { a = LEAF[6], b = LEAF[5], c = LEAF[3], s = "#5b9a52" }, mtok)
c:put(36, 14, "#5b9a52", mtok) c:put(36, 15, LEAF[2], mtok)
A.save(c, NAME)
