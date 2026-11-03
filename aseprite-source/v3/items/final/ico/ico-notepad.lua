-- ico-notepad (final pass, Opus single pass). Bold icon: a slim upright spiral-bound notepad with a pencil leaning
-- across its right side. Pad: cream top sheet (pillow bevel, 6 tones), red glued header band, blue ruled lines,
-- a pink margin rule, three lines of handwriting, a stack of page edges and a card back peeking out lower-right,
-- a dog-eared bottom corner folded over (flap catches the light, dark crease). Spiral: six bevelled steel coils with
-- a bright edge, dark punch holes beneath. Pencil: hexagonal gold body (lit / mid / shade facets), steel ferrule
-- with crimp bands, pink eraser, sharpened pale wood cone with grain, graphite tip with a glint; contact shadow on
-- the page beneath it.
-- quirk: a little red gnome hat is doodled in the page margin.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA7_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-notepad")
local PAGE  = { "#8a6e66", "#b89c8a", "#dcc6a8", "#efe0c0", "#f9efd6", "#fff6e2" }
local CARD  = { "#4a3030", "#6e4a3a", "#93684a", "#b88c62" }
local RED   = { "#5e1c32", "#8e2a3a", "#c03c3e", "#e45a44", "#ff8a5c" }
local STEEL = { "#3a3c56", "#5e6080", "#8a8ca6", "#b8b8cc", "#e2e0ea", "#fff4d6" }
local GOLD  = { "#7a3e1c", "#b8661e", "#e09a28", "#f6c23e", "#ffe28a" }
local WOODP = { "#9a6a44", "#c8966a", "#ecc89a" }
local ERAS  = { "#8a3a5a", "#c95a7e", "#f088a0", "#ffbccc" }
local INKB, LINE, MARG = "#3a3466", "#8bb6e0", "#f08a9a"
local ptok, ktok = A.tok("page"), A.tok("card")

local X0, Y0, X1, Y1 = 15, 16, 40, 53
-- card back and page stack (offset lower-right)
local back = c:rect(X0 + 2, Y0 + 2, X1 + 2, Y1 + 2)
A.shade(c, back, X.pillow(back, 1), CARD, { amb = 0.2, wrap = 0.3, tok = ktok })
local stack = c:rect(X0 + 1, Y0 + 1, X1 + 1, Y1 + 1)
stack:each(function(x, y) c:put(x, y, (x == X1 + 1 and y % 2 == 0) and PAGE[2] or PAGE[3], A.tok("stack")) end)
for x = X0 + 1, X1 + 1 do if x % 2 == 0 then c:put(x, Y1 + 1, PAGE[2]) end end

-- top sheet with dog-ear cut
local m = c:rect(X0, Y0, X1, Y1)
local D = 7
local function cut(x, y) return (x - X1) + (y - Y1) > -D end
local cm = HP.mask() m:each(function(x, y) if cut(x, y) then cm:set(x, y) end end)
m:cut(cm)
local n = X.pillow(m, 2)
local idx = A.shade(c, m, n, PAGE, { amb = 0.35, wrap = 0.4, tok = ptok, cuts = { 0.1, 0.2, 0.3, 0.55, 0.8 } })
-- header band
local hb = c:rect(X0, Y0, X1, Y0 + 4)
local hidx = A.shade(c, hb, X.pillow(hb, 1.5), RED, { amb = 0.2, wrap = 0.35, tok = A.tok("hdr") })
for x = X0, X1 do c:put(x, Y0 + 5, PAGE[2], ptok) end   -- AO under the band
-- ruled lines + margin
for y = Y0 + 10, Y1 - 2, 4 do for x = X0 + 1, X1 - 1 do if m:has(x, y) and not cut(x, y) then c:put(x, y, LINE, ptok) end end end
for y = Y0 + 6, Y1 - 1 do if m:has(X0 + 6, y) then c:put(X0 + 6, y, MARG, ptok) end end
-- handwriting on the first three lines
local words = { { 23, 28, 0 }, { 30, 37, 0 }, { 23, 34, 4 }, { 23, 26, 8 }, { 28, 31, 8 } }
for _, w in ipairs(words) do
  for x = w[1], w[2] do
    local y = Y0 + 9 + w[3] - ((x % 3 == 0) and 1 or 0)
    c:put(x, y, INKB, ptok)
  end
end
-- dog-ear flap: the cut corner folded back over the sheet
local fm = HP.mask()
m:each(function(x, y) local mx, my = X1 - (y - Y1) - D + 1 + (X1 - x) * 0, 0
  local d = (x - X1) + (y - Y1)
  if d > -2 * D + 1 and d <= -D and x > X1 - D and y > Y1 - D then fm:set(x, y) end end)
fm:each(function(x, y) local d = (x - X1) + (y - Y1)
  c:put(x, y, d == -D and PAGE[1] or (d >= -D - 1 and PAGE[4] or PAGE[6]), A.tok("flap")) end)
fm:edge():each(function(x, y) local d = (x - X1) + (y - Y1) if d < -D and (x == X1 - D + 1 or y == Y1 - D + 1) then c:put(x, y, PAGE[2], A.tok("flap")) end end)
cm:each(function(x, y) if (x - X1) + (y - Y1) == -D + 1 then c:put(x, y, PAGE[2], A.tok("stack")) end end) -- shadow under the fold

-- quirk: doodled gnome hat in the margin
A.map(c, {
  "..r..",
  "..r..",
  ".rRr.",
  ".rRr.",
  "rRRRr",
  "ggggg",
}, X0 + 7, Y1 - 13, { r = "#c03c3e", R = "#e45a44", g = "#5a8a4e" }, ptok)

-- spiral: punch holes, then steel coils
for i = 0, 5 do
  local x = X0 + 2 + i * 4
  c:put(x, Y0 + 2, RED[1]) c:put(x + 1, Y0 + 2, RED[1])
  local cm2 = c:rrect(x, Y0 - 4, x + 1, Y0 + 2, 1)
  for y = Y0 - 4, Y0 + 1 do
    c:put(x, y, y == Y0 - 4 and STEEL[3] or STEEL[5], A.tok("coil" .. i))
    c:put(x + 1, y, y == Y0 - 4 and STEEL[2] or STEEL[3], A.tok("coil" .. i))
  end
  c:put(x, Y0 - 3, STEEL[6]) c:put(x + 1, Y0 + 1, STEEL[2])
end

-- pencil: eraser end upper-right, tip lower-left, leaning on the pad
local AX, AY, BX, BY = 55, 12, 34, 45
local function pw(t) if t < 0.8 then return 2.2 end return max(0.3, 2.2 * (1 - (t - 0.8) / 0.2)) end
local pm, pn, PT, PS = X.cyl(AX, AY, BX, BY, pw)
-- contact shadow on the page / card
pm:shift(2, 1):each(function(x, y)
  if not pm:has(x, y) then
    if idx[K(x, y)] and m:has(x, y) then A.step(c, idx, PAGE, x, y, -2, ptok) end
  end end)
local etok, ftok, btok, wtok = A.tok("eraser"), A.tok("ferrule"), A.tok("body"), A.tok("cone")
pm:each(function(x, y) local k = K(x, y)
  local t, s = PT[k], PS[k]
  local facet = s < -0.4 and 1 or (s < 0.35 and 2 or 3)
  if t < 0.09 then
    c:put(x, y, ERAS[({ 4, 3, 2 })[facet]], etok)
    if t < 0.025 then c:put(x, y, ERAS[facet == 3 and 1 or 2], etok) end
  elseif t < 0.2 then
    local band = floor((t - 0.09) / 0.11 * 4) % 2 == 1
    c:put(x, y, STEEL[({ 5, 4, 2 })[facet] - (band and 1 or 0)], ftok)
  elseif t < 0.8 then
    c:put(x, y, GOLD[({ 5, 4, 2 })[facet]], btok)
    if abs(s) > 0.32 and abs(s) < 0.42 then c:put(x, y, GOLD[facet == 1 and 3 or 1], btok) end
  elseif t < 0.94 then
    c:put(x, y, WOODP[({ 3, 2, 1 })[facet]], wtok)
    if X.hash(x, y, 6) > 0.75 and facet < 3 then c:put(x, y, WOODP[facet == 1 and 2 or 1], wtok) end
  else
    c:put(x, y, facet == 1 and STEEL[3] or STEEL[1], wtok)
  end
end)
-- scalloped cut where wood meets paint
pm:each(function(x, y) local t = PT[K(x, y)] if t >= 0.795 and t < 0.815 then c:put(x, y, GOLD[3], btok) end end)
-- AO band at the ferrule join and glint on the body
pm:each(function(x, y) local t = PT[K(x, y)] if t >= 0.2 and t < 0.225 then c:put(x, y, GOLD[2], btok) end end)
A.save(c, "ico-notepad")
