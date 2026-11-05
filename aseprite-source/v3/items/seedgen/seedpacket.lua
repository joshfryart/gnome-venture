-- seedpacket: seed icon as a paper seed packet, big seeds in a label window, sprout peeking from the top.
-- Same params as seedgen.lua (seed, leaf, sleaf, stem, sl, sw, taper, marks, markc, drop ignored). Extra: paper={6 hex}, band="#hex"
return function(P)
local NAME = P.name
local G = dofile(P.dir .. "/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, max, min = math.floor, math.abs, math.sin, math.cos, math.max, math.min
local LEAF = P.leaf or { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
local SLEAF = P.sleaf or LEAF
local SEED = P.seed or { "#3a1a1e", "#62262a", "#8c3c32", "#b45c3c", "#d68650", "#f0b878" }
local STEM = P.stem or { "#5a2a30", "#86403a", "#a85c48", "#7a8a48", "#9cae5a" }
local PAPER = P.paper or { "#7a5a48", "#a98466", "#cfae86", "#e8cfa2", "#f6e4bc", "#fdf2d2" }
local sl = max(0.9, min(1.3, P.sl or 1)) ; local sw = max(0.9, min(1.3, P.sw or 1))
local function flat(m, base, shade, hi, name)
  local tk = { r = { name = name or "p" } }
  m:each(function(x, y)
    local col = base
    if not m:has(x + 1, y) or not m:has(x, y + 1) then col = shade
    elseif not m:has(x - 1, y) or not m:has(x, y - 1) then col = hi end
    c:put(x, y, col, tk)
  end)
end
c:groundShadow(32, 58, 17, 3)
-- body + flap
local body = c:rect(14, 11, 49, 56)
flat(body, PAPER[4], PAPER[2], PAPER[5], 'paper')
local flap = c:rect(14, 11, 49, 17)
flat(flap, PAPER[3], PAPER[2], PAPER[5], 'flap')
for x = 15, 48, 2 do c:put(x, 11, PAPER[2], { r = { name = "crimp" } }) end
for x = 14, 49 do c:put(x, 17, PAPER[1], { r = { name = "fold" } }) end
-- window with leaf-colour backdrop
local win = c:rrect(18, 20, 45, 45, 2)
flat(win, LEAF[3], LEAF[1], LEAF[4], 'win')
-- big seeds
local spots = { { 26, 29, -0.7 }, { 38, 28, 0.55 }, { 28, 39, 0.25 }, { 39, 39, -0.9 } }
local n = 4
for i = 1, n do
  local s = spots[i]
  local sm, sn = G.oval(s[1], s[2], 5.4 * sl, 3.9 * sw, s[3], 0.8)
  G.toneN(c, sm, sn, SEED, { bias = {}, tok = { r = { name = "seed" } }, amb = 0.08, wrap = 0.2 })
  local tk = { r = { name = "mark" } }
  local mc = P.markc or SEED[1]
  if P.marks == "pits" then
    c:put(s[1] - 1, s[2], mc, tk) c:put(s[1] + 1, s[2] + 1, mc, tk)
  elseif P.marks == "spots" then
    c:put(s[1], s[2] - 1, mc, tk) c:put(s[1] + 2, s[2], mc, tk) c:put(s[1] - 2, s[2] + 1, mc, tk)
  elseif P.marks == "stripes" then
    for d = -2, 2 do c:put(s[1] + d, s[2] + floor(d * s[3]), mc, tk) end
  end
  c:put(s[1] - 2, s[2] - 2, SEED[6], { r = { name = "glint" } })
end
-- bottom band: seed-coloured stripe with label dashes
local band = c:rect(14, 47, 49, 56)
flat(band, P.band or SEED[4], SEED[2], SEED[5], 'band')
for _, x in ipairs{ 19, 20, 21, 23, 24, 26, 27, 28, 29 } do c:put(x, 51, PAPER[5], { r = { name = "txt" } }) end
for _, x in ipairs{ 19, 20, 21, 22, 23, 24 } do c:put(x, 54, PAPER[4], { r = { name = "txt" } }) end
-- sprout peeking over the flap
local STK = { r = { name = "stem" } }
for y = 6, 11 do c:put(32, y, STEM[4], STK) c:put(33, y, STEM[5], STK) end
local l1, n1 = G.oval(27, 5, 4.5, 2.4, -0.45, 0.8)
G.toneN(c, l1, n1, SLEAF, { bias = {}, tok = { r = { name = "leaf" } }, amb = 0.1 })
local l2, n2 = G.oval(38, 5, 4.5, 2.4, 0.45, 0.8)
G.toneN(c, l2, n2, SLEAF, { bias = {}, tok = { r = { name = "leaf" } }, amb = 0.1 })
G.save(c, NAME)
end
