-- ico-chart (final, Opus). A rising bar chart: three slim enamel bars (sea, gold, ember) climbing left to right on a
-- brushed-steel L axis, with a bold green trend arrow sweeping up above them.
-- Material: bars = pillow-bevel per-pixel light (6 tones each) with a lit top cap face, a specular streak and a cool
-- bounce on the shade edge; axis = 6-tone steel with a bright bevel edge, tick notches and a dark bolt eye at the corner;
-- arrow = 6-tone glossy ribbon with a lit spine. AO row where bars stand on the axis; contact shadow of the arrow.
-- quirk: a tiny snail is slowly climbing the tallest bar, leaving a shiny trail.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA2_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min = math.floor, math.max, math.min
local c = A.new("ico-chart")
local STEEL = { "#3a3c58", "#5a5c78", "#82849c", "#a8aabd", "#cfd0dc", "#eeeef4" }
local SEA   = { "#203f6a", "#2c6694", "#3a8fb4", "#55b8c6", "#8adcd4", "#c4f4e6" }
local GOLD  = { "#7a3c1c", "#b8621e", "#e08f22", "#f5b82e", "#ffd666", "#fff0b0" }
local EMB   = { "#5e1a34", "#94263c", "#c63a3c", "#e8573e", "#ff8a5c", "#ffc09a" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local SPEC, BOUNCE = "#fff4d6", "#8a6fd0"

-- axis: vertical post + floor rail, 4 px thick
local AX0, AY1 = 8, 55
local axis = c:rect(AX0, 14, AX0 + 3, AY1):add(c:rect(AX0, AY1 - 3, 56, AY1))
local atok = A.tok("axis")
local an = X.pillow(axis, 1.6)
local aidx = A.shade(c, axis, an, STEEL, { tok = atok, amb = 0.15, wrap = 0.3 })
-- bright bevel edge on the lit sides, tick notches on the post
for y = 14, AY1 - 4 do c:put(AX0, y, STEEL[6], atok) end
for x = AX0 + 1, 56 do c:put(x, AY1 - 3, STEEL[5], atok) end
for _, y in ipairs{ 22, 30, 38, 46 } do c:put(AX0 + 2, y, STEEL[2], atok) c:put(AX0 + 3, y, STEEL[1], atok) end
-- rounded top of the post
c:put(AX0, 14, STEEL[4], atok) c:put(AX0 + 3, 14, STEEL[3], atok)
-- bolt eye at the corner
c:put(AX0 + 1, AY1 - 2, STEEL[1], atok) c:put(AX0 + 2, AY1 - 2, STEEL[2], atok)
c:put(AX0 + 1, AY1 - 1, STEEL[2], atok) c:put(AX0 + 2, AY1 - 1, STEEL[3], atok)

-- bars
local bars = {
  { x0 = 15, x1 = 23, top = 40, R = SEA },
  { x0 = 28, x1 = 36, top = 31, R = GOLD },
  { x0 = 41, x1 = 49, top = 21, R = EMB },
}
local base = AY1 - 4
for i, b in ipairs(bars) do
  local m = c:rect(b.x0, b.top, b.x1, base)
  local tok = A.tok("bar" .. i)
  local n = X.pillow(m, 2.2)
  local bias = {}
  -- AO: two rows above the axis darker
  for x = b.x0, b.x1 do bias[K(x, base)] = -2 bias[K(x, base - 1)] = -1 end
  local idx = A.shade(c, m, n, b.R, { tok = tok, bias = bias, amb = 0.1, wrap = 0.28 })
  -- lit cap face (2 rows) with a darker lip under it
  for x = b.x0 + 1, b.x1 - 1 do c:put(x, b.top, b.R[6], tok) c:put(x, b.top + 1, b.R[5], tok) c:put(x, b.top + 2, b.R[3], tok) end
  c:put(b.x0, b.top, b.R[5], tok) c:put(b.x1, b.top, b.R[4], tok)
  c:put(b.x1, b.top + 1, b.R[3], tok)
  -- specular streak down the lit side
  for y = b.top + 4, b.top + 4 + min(8, base - b.top - 9) do c:put(b.x0 + 2, y, b.R[6], tok) end
  c:put(b.x0 + 2, b.top + 4, SPEC, tok)
  -- cool bounce on the shade edge, low down
  for y = base - 6, base - 3 do c:put(b.x1, y, BOUNCE, tok) end
  -- engraved band line across the bar (enamel seam)
  local sy = floor((b.top + base) / 2) + 2
  for x = b.x0 + 1, b.x1 - 1 do c:put(x, sy, b.R[2], tok) c:put(x, sy + 1, b.R[5], tok) end
end

-- trend arrow above the bars
local pts = { { 15, 35 }, { 26, 27 }, { 31, 29 }, { 45, 15 } }
local am = A.stroke(pts, 1.6)
-- arrowhead pointing up-right
local head = HP.poly{ { 52, 6 }, { 51, 17 }, { 47, 13 }, { 41, 11 } }
am:add(head)
local ltok = A.tok("arrow")
-- clear a 1 px air gap around the arrow so the bars do not merge with it
local gap = am:grow(1)
gap:each(function(x, y) if not am:has(x, y) and c.pix[y * c.w + x] then c.pix[y * c.w + x] = nil end end)
local ln = X.pillow(am, 1.5)
local lidx = A.shade(c, am, ln, LEAF, { tok = ltok, amb = 0.1, wrap = 0.3 })
-- lit spine along the ribbon
for i = 1, #pts - 1 do
  local ax, ay, bx, by = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
  local n = math.max(math.abs(bx - ax), math.abs(by - ay))
  for s = 1, n - 1 do
    local x, y = floor(ax + (bx - ax) * s / n + .5), floor(ay + (by - ay) * s / n + .5) - 1
    if am:has(x, y) then c:put(x, y, LEAF[5], ltok) end
  end
end
c:put(47, 11, LEAF[6], ltok) c:put(48, 10, LEAF[6], ltok) c:put(49, 9, SPEC, ltok)

-- quirk: tiny snail climbing the tallest bar's left face (shell + body), with a shiny trail below it
local sx, sy = 43, 27
A.map(c, {
  ".k..",
  ".k..",
  "BSSs",
  "BShs",
  "BSsd",
  "bss.",
  "bb..",
}, sx, sy, { k = "#6e5a7a", B = "#e6c8a0", b = "#b08a70", S = "#d98322", s = "#8f4a1f", h = "#ffe38a", d = "#51302b" })
for y = sy + 7, sy + 11 do c:put(sx + 1, y, "#ffd2bf") end
A.save(c, "ico-chart")
