-- nav-festival (final pass, Opus aC2r1_1). A glowing red paper lantern hanging from the low point of a twisted
-- twine cord strung with four little cloth pennants (gold, moss, sea, petal). Lantern: sphere light mixed with an
-- inner glow (warm-yellow core), curved wire hoops, gold lacquered caps, a twisted tassel. Cord: 2 px rope twist.
-- Pennants: pillow-lit cloth with a fold crease and a darker row where they hang from the cord.
-- quirk: a pale moth has settled on the warm lantern.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("nav-festival")
local PAPER = { "#5e1a30", "#8e2434", "#c0383a", "#e45a40", "#f88a52", "#ffc070" }
local GOLD  = { "#6a3a1c", "#9a5e20", "#c8862a", "#eaae3a", "#fad468", "#fff2b0" }
local TWINE = { "#5a3a2a", "#8a6040", "#b98a58", "#dcb47c" }
local FLAG = {
  { "#7a3a18", "#b0601e", "#d98322", "#f5b82e", "#ffd862", "#ffeca0" },
  { "#1c4a3c", "#28684a", "#3f9150", "#64b058", "#94cc6c", "#c4e48c" },
  { "#223e70", "#2e5e9c", "#3a86b0", "#5fb0c8", "#8ed4d8", "#c4f0e8" },
  { "#5a1c48", "#8a2c62", "#c0487c", "#e86c96", "#f89ab6", "#ffc8d8" },
}

-- cord: sags to a low point at the centre where the lantern hangs
local function cy(x) local u = abs(x - 32) / 24 return 18 - 7 * u ^ 1.25 end
-- pennants first (cord painted over their tops)
local fx = { 10, 18, 40, 48 }
for i, x0 in ipairs(fx) do
  local x1, xm = x0 + 6, x0 + 3
  local fm = c:poly{ { x0, floor(cy(x0) + 1.5) }, { x1, floor(cy(x1) + 1.5) }, { xm, floor(cy(xm) + 10) } }
  local b = A.bias()
  fm:each(function(x, y) if y <= floor(cy(x) + 2.5) then b[K(x, y)] = -1 end end)   -- dark row under the cord
  local fi = A.pill(c, fm, 1.4, FLAG[i], { bias = b })
  -- fold crease: from the top a third in, down toward the tip; lit strip beside it
  fm:each(function(x, y)
    local top = cy(x0 + 2) + 3
    local fxl = x0 + 2 + (y - top) * 0.22
    if y > top and abs(x - fxl) < 0.5 then A.step(c, fi, FLAG[i], x, y, -1)
    elseif y > top and abs(x - fxl - 1) < 0.5 then A.step(c, fi, FLAG[i], x, y, 1) end
  end)
end
-- cord: 2 px twist
for x = 8, 56 do
  local y = floor(cy(x) + 0.5)
  local ph = (x % 3)
  c:put(x, y, ph == 0 and TWINE[2] or TWINE[4])
  c:put(x, y + 1, ph == 1 and TWINE[1] or TWINE[3])
end
-- knot at the hanging point + hanging string
c:put(31, 18, TWINE[3]) c:put(32, 18, TWINE[4]) c:put(33, 18, TWINE[2])
c:put(31, 19, TWINE[2]) c:put(32, 19, TWINE[3]) c:put(33, 19, TWINE[1])
for y = 20, 22 do c:put(32, y, (y % 2 == 0) and TWINE[3] or TWINE[2]) end

-- lantern body
local LX, LY, RX, RY = 32, 35, 10, 10.5
local lm, ln = A.oval(LX, LY, RX, RY, 0)
local add = {}
lm:each(function(x, y) local dx, dy = (x - LX) / RX, (y - LY) / RY
  add[K(x, y)] = 0.32 * (1 - (dx * dx + dy * dy)) - 0.05 end)       -- inner glow
local li = A.shade(c, lm, ln, PAPER, { add = add, amb = 0.1, wrap = 0.3 })
-- wire hoops (curved: seen from slightly above)
for _, yk in ipairs{ 28, 32, 36.5, 41 } do
  lm:each(function(x, y) local dx = (x - LX) / RX
    local yy = yk + 1.4 * (1 - dx * dx) - 0.4
    if abs(y - yy) < 0.5 then A.step(c, li, PAPER, x, y, -1) end end)
end
-- caps (gold lacquer) top and bottom, with a dark row where they meet the paper
local cap1 = c:rrect(26, 23, 38, 26, 1)
local cap2 = c:rrect(27, 44, 37, 47, 1)
local lb = A.bias()
A.ao(lb, lm, cap1, 1, -1) A.ao(lb, lm, cap2, 1, -1)
lm:each(function(x, y) local k = K(x, y) if lb[k] and not cap1:has(x, y) and not cap2:has(x, y) then A.step(c, li, PAPER, x, y, -1) end end)
A.pill(c, cap1, 1.3, GOLD)
A.pill(c, cap2, 1.3, GOLD)
c:put(28, 24, GOLD[6]) c:put(29, 24, GOLD[6])
-- tassel: knot + twisted strands
c:put(31, 48, GOLD[4]) c:put(32, 48, GOLD[5]) c:put(33, 48, GOLD[3])
for y = 49, 55 do
  for x = 31, 33 do
    local t = (x + y) % 3
    local col = (t == 0) and PAPER[5] or ((t == 1) and PAPER[3] or PAPER[2])
    if y == 55 and x ~= 32 then col = nil end
    if col then c:put(x, y, col) end
  end
end
c:put(32, 49, GOLD[5])

-- quirk: a moth resting on the warm lantern (upper right)
A.map(c, {
  "ww.ww",
  "wvbvw",
  ".vbv.",
  "..b..",
}, 35, 28, { w = "#f2e6cc", v = "#c8b090", b = "#6a5040" })
A.save(c, "nav-festival")
