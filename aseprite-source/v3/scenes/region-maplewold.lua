-- region-maplewold PASS 2 (final). 300x200 grid, x6 = 1800x1200; thumb 450x300 (x1.5, same grid).
-- One composed autumn valley: a waterfall drops from the far ridge, the stream winds through the hamlet
-- under a humped footbridge and out at the bottom; a sandy lane climbs from the bottom-right over the
-- bridge to the sugar shack. Planes: far = sky + dusk ridge + moss.hi hill with a 2-tone tree line;
-- mid = hamlet, trees, fields (deep-tone edges on objects); near = ink-edged maple canopies (top
-- corners), fern bank + mushrooms (bottom-left), birches + gold bush (bottom-right).
-- Jigsaw 6x4 (50x50): every cell has its own landmark, neighbouring cells change hue:
--  r0: gold canopy | geese + shack steam + cloud | sun + waterfall | windmill | balloon | red canopy
--  r1: gold maple + swing | sugar shack | red maple + sap bucket + stream | red barn | stubble field,
--      haystacks, sheep | maple trunk with owl + birdhouse
--  r2: pumpkin field | scarecrow + crow | BRIDGE + BEAR | lamp + log stack + chopping block |
--      apple tree + ladder | wheelbarrow of pumpkins
--  r3: ferns + mushrooms | cattails + duck | lily pads + frog + log | signpost + fox | big pumpkins +
--      crate | birches + gold bush
-- quirk: a bear in a tiny scarf fishing under the footbridge (bucket with one fish).
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local c = HP.canvas{ w = 300, h = 200, scale = 6, name = "region-maplewold" }
local floor, sin, abs = math.floor, math.sin, math.abs
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local PUMP = { hi = P.gold.hi, base = P.gold.base, shade = P.gold.shade, deep = P.gold.deep }
local BEAR = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = P.ink }
local BIRCH = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local function hash(a, b) return ((a * 73856093) ~ (b * 19349663)) % 1000 end

------------------------------------------------------------------ FAR
c:stripes(0, 44, { P.sky.shade, P.sky.base, P.sky.hi }, { 2, 3, 3 })
c:fillMask(E(124, 13, 7, 7), P.gold.base) c:fillMask(E(123, 12, 4, 4), P.gold.hi)
c:cloud(78, 24, 26, P.cream, P.sky.hi)
c:cloud(150, 16, 20, P.cream, P.sky.hi)
c:cloud(244, 34, 18, P.cream, P.sky.hi)
local function ridge(x) return 31 + 5 * sin(x / 26 + 1) + 3 * sin(x / 11) end
c:terrain(ridge, P.dusk.hi)
local function hill(x) return 41 + 3 * sin(x / 19 + 2) + 2 * sin(x / 8) end
c:terrain(hill, P.moss.hi)
-- far tree line: clusters, each 2 tones (top + underside), varied size and gaps
do
  local x, k = 0, 0
  local pairs_ = { { P.ember.hi, P.ember.base }, { P.gold.hi, P.gold.base }, { P.gold.base, P.gold.shade }, { P.ember.base, P.ember.shade } }
  while x < 300 do
    local n = 2 + (k * 7) % 3
    local pr = pairs_[k % 4 + 1]
    for j = 0, n - 1 do
      local cx = x + j * 4 local r = 2 + (j + k) % 3
      local cy = floor(hill(cx)) - r + 2
      c:fillMask(E(cx, cy, r, r), pr[1])
      c:fillMask(E(cx, cy, r, r):clip(c:rect(0, cy + 1, 299, cy + r + 1)), pr[2])
    end
    x = x + n * 4 + 4 + (k * 5) % 7
    k = k + 1
  end
end

------------------------------------------------------------------ MID ground
local function ground(x) return 46 + 2 * sin(x / 15) end
c:terrain(ground, P.moss.base)
-- meadow lightness: a few soft swells of moss.hi (no rugs: they follow the hill line)
for _, p in ipairs{ {100, 64, 18, 5} } do
  c:fillMask(E(p[1], p[2], p[3], p[4]):add(E(p[1] - p[3] * .5, p[2] + 2, p[3] * .5, p[4] * .7)), P.moss.hi)
end
-- grass ticks
for i = 0, 140 do
  local x, y = hash(i, 3) % 300, 50 + hash(i, 7) % 148
  if c:get(x, y) == P.moss.base:lower() and c:get(x + 2, y) == P.moss.base:lower() then
    c:px(x, y, P.moss.shade) c:px(x + 1, y - 1, P.moss.shade) c:px(x + 2, y, P.moss.shade)
  end
end
-- stubble field (r1 c4)
local stub = c:poly{ {200, 66}, {262, 62}, {268, 96}, {204, 100} }
c:fillMask(stub, P.gold.hi)
for k = 0, 12 do c:fillMask(c:line({ {196 + k * 6, 102}, {206 + k * 6, 60} }, 1):clip(stub), P.gold.base) end
-- ploughed pumpkin field (r2 c0-c1)
local field = c:poly{ {0, 104}, {66, 99}, {90, 118}, {80, 146}, {0, 151} }
c:fillMask(field, P.wood.base)
for y = 106, 148, 6 do c:fillMask(c:line({ {0, y}, {90 - (y - 100) * 0.2, y - 3} }, 1):clip(field), P.wood.shade) end
c:rim(field, P.wood.shade)

-- stream (smooth, widening toward the viewer)
local sp = { {150, 40}, {147, 47}, {141, 55}, {133, 64}, {128, 74}, {130, 86}, {137, 97}, {142, 108}, {144, 118},
  {139, 128}, {128, 138}, {114, 147}, {100, 157}, {90, 169}, {85, 183}, {83, 199} }
local water = HP.mask()
for i = 1, #sp - 1 do water:add(c:line({ sp[i], sp[i + 1] }, 2 + floor(i * 0.45))) end
c:rim(water, P.sea.shade)
c:fillMask(water, P.sea.base)
for i = 2, #sp - 1 do
  local x, y = sp[i][1] - 1, sp[i][2] + 3
  if i % 2 == 0 then c:px(x, y, P.sea.hi) c:px(x + 1, y, P.sea.hi) else c:px(x + 1, y, P.sky.hi) end
end
-- waterfall + foam (r0 c2)
R(148, 32, 152, 41, P.sky.hi) R(150, 32, 150, 41, P.sea.hi) R(147, 41, 147, 41, P.cream) R(153, 41, 153, 41, P.cream)
c:fillMask(E(150, 43, 4, 1), P.cream)
-- stones in the stream
for _, s in ipairs{ {130, 78}, {139, 124}, {92, 174} } do c:part(E(s[1], s[2], 2, 1), "stone", { band = 1, nopop = true }) end

-- sandy lane: bottom-right up to the bridge, then to the sugar shack
local lane = c:line({ {216, 199}, {209, 182}, {196, 162}, {179, 142}, {167, 122}, {161, 110} }, 7)
lane:add(c:line({ {122, 106}, {106, 98}, {92, 90}, {84, 86} }, 5))
c:fillMask(lane, P.wood.hi)
c:rim(lane, P.gold.shade, c:rect(0, 0, 299, 199):cut(water))
for i = 0, 30 do -- pebbles + leaves on the lane
  local x, y = 150 + hash(i, 11) % 70, 108 + hash(i, 13) % 92
  if lane:has(x, y) and lane:has(x + 1, y) and lane:has(x - 1, y) then c:px(x, y, (i % 3 == 0) and P.ember.base or P.wood.base) end
end

------------------------------------------------------------------ helpers
local function maple(x, y, s, ramp, o)
  o = o or {}
  local tr = c:poly{ {x - 2, y}, {x + 2, y}, {x + 1, y - 8 * s}, {x - 1, y - 8 * s} }
  local cr = E(x, y - 13 * s, 9 * s, 7 * s):add(E(x - 7 * s, y - 9 * s, 6 * s, 5 * s)):add(E(x + 7 * s, y - 9 * s, 6 * s, 5 * s))
    :add(E(x - 4 * s, y - 18 * s, 5 * s, 4 * s)):add(E(x + 4 * s, y - 17 * s, 5 * s, 4 * s)):add(E(x, y - 21 * s, 3 * s, 2 * s))
  c:fillMask(E(x, y + 1, 9 * s, 2), P.moss.shade)
  c:rim(tr:copy():add(cr), o.edge or P[ramp].deep)
  c:part(tr, "wood", { band = 1, nopop = true })
  c:part(cr, o.r or ramp, { band = 3 })
  -- leaf clumps: little shade crescents give the crown lobes
  local rr = type(o.r) == "table" and o.r or P[ramp]
  for _, l in ipairs{ { -4, -15 }, { 4, -11 }, { -6, -8 } } do
    local lx, ly = floor(x + l[1] * s), floor(y + l[2] * s)
    c:px(lx, ly, rr.shade) c:px(lx + 1, ly, rr.shade) c:px(lx + 2, ly - 1, rr.shade)
  end
  -- fallen leaves around the foot
  for i = 0, 5 do
    local lx, ly = x - 10 * s + hash(x + i, y) % floor(20 * s), y + 1 + hash(y + i, x) % 4
    if c:get(lx, ly) == P.moss.base:lower() or c:get(lx, ly) == P.moss.shade:lower() then c:px(lx, ly, rr.base) c:px(lx + 1, ly, rr.shade) end
  end
  return cr
end
local function pumpkin(x, y, r)
  local m = E(x, y, r + 1, r)
  c:rim(m, P.gold.deep)
  c:part(m, PUMP, { band = 1 })
  if r >= 3 then R(x, y - r + 1, x, y + r - 1, P.gold.shade) end
  R(x, y - r - 2, x, y - r, P.moss.deep) c:px(x + 1, y - r - 2, P.moss.shade)
end

------------------------------------------------------------------ r0 (sky row)
-- c1: geese V
for _, g in ipairs{ {58, 8}, {62, 10}, {66, 12}, {54, 10}, {50, 12} } do c:px(g[1], g[2], P.ink) c:px(g[1] - 1, g[2] - 1, P.ink) c:px(g[1] + 1, g[2] - 1, P.ink) end
-- c3: windmill on the far hill
do
  local tw = c:poly{ {181, 44}, {191, 44}, {189, 30}, {183, 30} }
  c:fillMask(tw, P.cream) c:fillMask(c:rect(187, 31, 190, 44):clip(tw), P.stone.hi)
  c:fillMask(c:poly{ {182, 31}, {186, 25}, {190, 31} }, P.ember.base)
  R(185, 38, 187, 44, P.wood.shade)
  for _, b in ipairs{ { -9, -7 }, { 8, -8 }, { 9, 7 }, { -8, 8 } } do c:fillMask(c:line({ {186, 28}, {186 + b[1], 28 + b[2]} }, 2), P.wood.shade) end
  for _, b in ipairs{ { -7, -6 }, { 6, -6 }, { 7, 5 }, { -6, 6 } } do c:px(186 + b[1], 28 + b[2], P.cream) end
  c:px(186, 28, P.wood.deep)
end
-- c4: hot-air balloon
do
  local b = E(226, 13, 8, 9)
  c:rim(b, P.ember.deep)
  c:part(b, "ember", { band = 2 })
  for x = 220, 232, 4 do c:fillMask(c:rect(x, 4, x + 1, 22):clip(b), P.gold.base) end
  c:fillMask(c:line({ {220, 20}, {223, 27} }, 1), P.wood.deep) c:fillMask(c:line({ {232, 20}, {229, 27} }, 1), P.wood.deep)
  c:part(c:rect(222, 27, 230, 31), "wood", { band = 1, nopop = true }) R(222, 28, 230, 28, P.wood.deep)
end

------------------------------------------------------------------ r1
-- c0: gold maple + swing
maple(30, 94, 1.3, "gold")
c:fillMask(c:line({ {20, 80}, {20, 96} }, 1), P.wood.deep) c:fillMask(c:line({ {28, 81}, {28, 96} }, 1), P.wood.deep)
c:part(c:rect(18, 96, 30, 97), "ember", { band = 1, nopop = true })
-- c1: sugar shack (mid object, wood.deep edge), steam from the roof vent, syrup jugs on the porch
do
  local w = c:rect(58, 66, 92, 85)
  local rf = c:poly{ {54, 68}, {75, 53}, {96, 68} }
  local cup = c:rect(71, 46, 79, 54) local cap2 = c:poly{ {69, 47}, {75, 41}, {81, 47} }
  local porch = c:rect(56, 86, 94, 88)
  local all = w:copy():add(rf):add(cup):add(cap2):add(porch)
  c:fillMask(E(75, 89, 22, 2), P.moss.shade)
  c:rim(all, P.wood.deep)
  c:part(w, "wood", { band = 2, nopop = true })
  for y = 69, 84, 3 do R(58, y, 92, y, P.wood.shade) end
  c:part(rf, "ember", { band = 2, pop = { 66, 62 } })
  for k = 0, 3 do c:fillMask(c:line({ {75, 54 + k * 0}, {56 + k * 0, 67} }, 1):shift(k * 5, 0):clip(rf), P.ember.shade) end
  c:part(cup, "wood", { band = 1, nopop = true }) c:part(cap2, "ember", { band = 1, nopop = true })
  R(73, 48, 77, 52, P.ink) c:px(74, 49, P.gold.base)
  R(80, 71, 87, 85, P.wood.deep) R(81, 72, 86, 85, P.ember.shade) R(83, 72, 84, 85, P.ember.deep) c:px(85, 79, P.gold.hi)
  local win = c:rect(63, 72, 72, 79)
  c:fillMask(win, P.gold.hi) R(67, 72, 68, 79, P.wood.deep) R(63, 75, 72, 76, P.wood.deep) c:px(64, 73, P.cream)
  c:part(porch, "wood", { band = 1, nopop = true })
  for _, j in ipairs{ {60, 82}, {64, 83} } do c:part(c:rrect(j[1], j[2], j[1] + 2, j[2] + 3, 1), "gold", { nopop = true, band = 1 }) c:px(j[1] + 1, j[2] - 1, P.wood.deep) end
  for i, s in ipairs{ {75, 37, 3, 2}, {71, 31, 4, 3}, {77, 24, 5, 3}, {70, 16, 4, 3}, {76, 9, 3, 2} } do c:fillMask(E(s[1], s[2], s[3], s[4]), i % 2 == 1 and P.cream or P.stone.hi) end
end
-- c2: red maple at the stream bend, with a sap bucket on the trunk
maple(110, 86, 1.0, "ember")
c:part(c:rect(111, 80, 113, 83), "stone", { band = 1, nopop = true }) c:px(110, 79, P.stone.deep)
-- c3: red barn with gold roof, hayloft
do
  local w = c:rect(162, 64, 194, 87) local rf = c:poly{ {158, 66}, {167, 52}, {189, 52}, {198, 66} }
  c:fillMask(E(178, 88, 20, 2), P.moss.shade)
  c:rim(w:copy():add(rf), P.ember.deep)
  c:part(w, "ember", { band = 2, nopop = true })
  for x = 165, 192, 4 do R(x, 67, x, 87, P.ember.shade) end
  c:part(rf, "gold", { band = 2, pop = { 168, 55 } })
  local dr = c:rect(171, 72, 185, 87)
  c:fillMask(dr, P.cream) c:fillMask(c:rect(173, 74, 183, 87), P.ember.base)
  c:fillMask(c:line({ {173, 74}, {183, 87} }, 1), P.cream) c:fillMask(c:line({ {183, 74}, {173, 87} }, 1), P.cream)
  R(178, 74, 178, 87, P.cream)
  c:fillMask(c:rect(174, 56, 182, 62), P.wood.deep) c:fillMask(c:rect(175, 57, 181, 62), P.gold.base)
  for x = 175, 181, 2 do c:px(x, 57, P.gold.hi) end
  c:px(176, 50, P.ember.base) c:px(177, 49, P.ember.base) R(178, 48, 178, 51, P.wood.deep) -- weathervane
end
-- c4: haystacks + sheep on the stubble
for _, h in ipairs{ {216, 84, 8}, {234, 90, 6}, {250, 78, 5} } do
  local m = E(h[1], h[2], h[3], h[3] + 2):clip(c:rect(0, 0, 299, h[2] + 3))
  c:rim(m, P.gold.deep) c:part(m, "gold", { band = 2 })
  for i = -h[3] + 2, h[3] - 2, 3 do c:px(h[1] + i, h[2] - 1, P.gold.shade) c:px(h[1] + i + 1, h[2] + 1, P.gold.shade) end
end
local function sheep(x, y, flip)
  local s = flip and -1 or 1
  local b = E(x, y, 4, 3):add(E(x - 2 * s, y - 1, 2, 2))
  c:rim(b, P.stone.base) c:part(b, BIRCH, { band = 1, nopop = true })
  R(math.min(x + 4 * s, x + 6 * s), y - 2, math.max(x + 4 * s, x + 6 * s), y, P.ink) c:px(x + 5 * s, y - 2, P.cream)
  R(x - 2, y + 3, x - 2, y + 4, P.ink) R(x + 2, y + 3, x + 2, y + 4, P.ink)
end
sheep(242, 70) sheep(208, 72, true)

------------------------------------------------------------------ r2
-- c0 + c1: pumpkin field + scarecrow (patched shirt) + crow
for _, p in ipairs{ {10, 112, 4}, {28, 116, 5}, {48, 110, 3}, {16, 131, 5}, {40, 134, 4}, {60, 124, 4}, {6, 145, 3}, {30, 146, 3}, {56, 141, 3} } do pumpkin(p[1], p[2], p[3]) end
do
  local pole = c:rect(76, 108, 77, 138) local arm = c:rect(66, 114, 87, 115)
  local shirt = c:poly{ {70, 115}, {84, 115}, {85, 127}, {69, 127} }
  local head = E(76.5, 109, 4, 4) local hat = c:rect(73, 100, 80, 104):add(c:rect(70, 104, 83, 105))
  c:rim(pole:copy():add(arm):add(shirt):add(head):add(hat), P.wood.deep)
  c:fillMask(pole, P.wood.shade) c:fillMask(arm, P.wood.shade)
  c:part(shirt, "sea", { band = 2, nopop = true }) R(69, 121, 85, 121, P.sea.deep)
  R(79, 117, 82, 119, P.petal.base) c:px(79, 117, P.gold.base) c:px(82, 119, P.gold.base)
  c:part(head, "gold", { band = 1 })
  c:px(75, 108, P.ink) c:px(78, 108, P.ink) R(75, 111, 78, 111, P.gold.deep)
  c:part(hat, "ember", { band = 1, nopop = true }) R(73, 103, 80, 103, P.gold.base)
  R(65, 116, 66, 117, P.gold.hi) R(87, 116, 88, 117, P.gold.hi)
  c:paint({ "..##.", ".####", "#.##.", "..#.." }, 84, 109, { ["#"] = "#2b1c26" }) c:px(87, 110, P.gold.base)
end
-- c2 (+c3): HERO footbridge + QUIRK bear
do
  local deck = c:poly{ {119, 106}, {129, 99}, {151, 99}, {163, 106}, {163, 110}, {151, 104}, {129, 104}, {119, 110} }
  local rail = c:line({ {120, 99}, {129, 93}, {151, 93}, {162, 99} }, 1)
  local posts = HP.mask()
  for _, p in ipairs{ {120, 100}, {129, 94}, {140, 94}, {151, 94}, {162, 100} } do posts:add(c:rect(p[1], p[2], p[1], p[1] == 120 and 106 or p[1] == 162 and 106 or 100)) end
  local br = deck:copy():add(rail):add(posts)
  c:fillMask(c:poly{ {129, 105}, {151, 105}, {157, 109}, {124, 109} }:clip(water:copy():grow(1)), P.sea.deep) -- shadow under the arch
  c:rim(br, P.wood.deep)
  c:part(deck, "wood", { band = 2, pop = { 131, 100 } })
  for x = 123, 160, 4 do c:fillMask(c:rect(x, 99, x, 110):clip(deck), P.wood.shade) end
  c:fillMask(rail, P.wood.base) c:fillMask(posts, P.wood.shade)
  for _, p in ipairs{ 129, 140, 151 } do c:px(p, 93, P.wood.hi) end
  -- bear: west bank, just below the bridge
  local body = E(126, 124, 7, 6)
  local head = E(127, 114, 5, 4)
  local ears = E(123, 110, 1.5, 1.5):add(E(131, 110, 1.5, 1.5))
  local scarf = c:rect(121, 118, 133, 119):add(c:poly{ {121, 119}, {124, 119}, {123, 126}, {120, 125} })
  local bear = body:copy():add(head):add(ears):add(scarf)
  c:fillMask(E(127, 130, 9, 1), P.moss.shade)
  c:rim(bear, P.ink)
  c:part(body, BEAR, { band = 2, nopop = true, inner = false })
  c:part(head, BEAR, { band = 1, nopop = true, inner = false })
  c:fillMask(ears, P.wood.shade) c:px(123, 110, P.wood.base) c:px(131, 110, P.wood.base)
  c:fillMask(E(128, 116, 2, 1), P.wood.hi) c:px(128, 115, P.ink)
  c:px(125, 113, P.ink) c:px(130, 113, P.ink)
  c:fillMask(E(126, 125, 3, 3), P.wood.base)
  c:fillMask(scarf, P.ember.base) R(121, 119, 133, 119, P.ember.shade)
  for _, x in ipairs{ 125, 128, 131 } do c:px(x, 118, P.gold.base) end
  c:px(120, 126, P.gold.base) c:px(122, 126, P.gold.base)
  -- paws + rod + line + bobber
  R(131, 121, 134, 122, P.wood.shade)
  c:fillMask(c:line({ {133, 122}, {144, 106} }, 1), P.wood.hi)
  c:fillMask(c:line({ {144, 106}, {145, 120} }, 1), P.cream)
  c:px(145, 121, P.ember.base) c:px(145, 122, P.cream)
  -- bucket with one fish tail
  local bk = c:rect(114, 124, 118, 129)
  c:rim(bk, P.ink) c:part(bk, "stone", { band = 1, nopop = true }) R(114, 124, 118, 124, P.stone.hi)
  c:px(115, 122, P.gold.base) c:px(117, 122, P.gold.base) c:px(116, 123, P.gold.base)
end
-- c3: lamp post + log stack + chopping block with axe
do
  R(174, 108, 175, 132, P.ink) R(170, 101, 179, 101, P.ink)
  c:part(c:rect(171, 102, 178, 107), "gold", { band = 1, pop = { 172, 103 } }) R(174, 102, 175, 107, P.gold.shade)
  for j = 0, 2 do for i = 0, 2 - j do
    local lx, ly = 186 + i * 6 + j * 3, 132 - j * 5
    local lg = E(lx, ly, 2.5, 2.5)
    c:rim(lg, P.wood.deep) c:fillMask(lg, P.wood.hi)
    c:fillMask(E(lx, ly, 1, 1), P.wood.base) c:px(lx + 2, ly + 2, P.wood.shade)
  end end
  local blk = c:rect(186, 138, 194, 143) local tp = E(190, 138, 4, 1)
  c:rim(blk:copy():add(tp), P.wood.deep) c:part(blk, "wood", { band = 1, nopop = true }) c:fillMask(tp, P.wood.hi)
  c:fillMask(c:line({ {191, 137}, {196, 131} }, 1), P.wood.base) R(189, 136, 191, 137, P.stone.base) c:px(189, 136, P.stone.hi)
end
-- c4: apple tree (green crown so it pops among the reds) + ladder
do
  maple(232, 142, 1.25, "moss", { edge = P.moss.deep })
  for _, a in ipairs{ {224, 122}, {236, 116}, {242, 126}, {228, 132}, {218, 128}, {238, 134} } do
    R(a[1], a[2], a[1] + 1, a[2] + 1, P.ember.base) c:px(a[1], a[2], P.ember.hi)
  end
  local lad = c:line({ {247, 144}, {251, 118} }, 1):add(c:line({ {252, 144}, {256, 118} }, 1))
  for y = 122, 142, 4 do lad:add(c:rect(248 + (144 - y) // 6, y, 253 + (144 - y) // 6, y)) end
  c:fillMask(lad, P.wood.shade)
  c:part(c:rrect(212, 138, 220, 144, 1), "wood", { band = 1, nopop = true }) R(213, 137, 219, 137, P.ember.base)
end
-- c5: wheelbarrow of pumpkins
do
  local tub = c:poly{ {262, 122}, {290, 122}, {286, 132}, {266, 132} }
  c:rim(tub, P.sea.deep) c:part(tub, "sea", { band = 2, nopop = true })
  pumpkin(270, 119, 3) pumpkin(280, 118, 4) pumpkin(286, 120, 2)
  local wh = E(266, 135, 3, 3) c:rim(wh, P.ink) c:part(wh, "stone", { band = 1, nopop = true }) c:px(266, 135, P.stone.deep)
  R(286, 130, 297, 131, P.wood.shade) R(288, 132, 289, 138, P.wood.shade)
end

------------------------------------------------------------------ r3
-- c1: cattails + duck
for _, x in ipairs{ 68, 72, 76, 104, 108 } do R(x, 164, x, 177, P.moss.deep) R(x, 161, x, 166, P.wood.shade) c:px(x, 160, P.wood.base) end
do
  local dk = E(92, 182, 3, 2):add(E(95, 179, 2, 1.5))
  c:rim(dk, P.stone.base) c:fillMask(E(92, 182, 3, 2), P.cream) c:fillMask(E(95, 179, 2, 1.5), P.moss.shade)
  c:px(98, 179, P.gold.base) c:px(96, 178, P.ink) c:px(91, 181, P.stone.hi)
end
-- c2: lily pads + frog + log on the bank
do
  for _, l in ipairs{ {84, 192, 4, 2}, {78, 186, 3, 1} } do c:fillMask(E(l[1], l[2], l[3], l[4]), P.moss.base) c:px(l[1] + 1, l[2], P.sea.base) end
  c:px(79, 185, P.petal.base) c:px(80, 185, P.petal.hi)
  c:fillMask(E(84, 190, 2, 1), P.moss.shade) c:px(83, 189, P.moss.hi) c:px(85, 189, P.moss.hi) c:px(83, 188, P.ink) c:px(85, 188, P.ink)
  local lg = c:rect(106, 182, 128, 187)
  c:rim(lg, P.wood.deep) c:part(lg, "wood", { band = 1, nopop = true })
  c:fillMask(E(106, 184, 2, 2), P.wood.hi) c:px(106, 184, P.wood.base)
  c:fillMask(E(118, 181, 2, 1), P.moss.base) c:px(117, 180, P.moss.hi) -- moss tuft on the log
end
-- c3: signpost + fox trotting down the lane
do
  R(158, 164, 159, 194, P.wood.deep)
  local s1 = c:poly{ {146, 167}, {167, 167}, {171, 170}, {167, 173}, {146, 173} }
  local s2 = c:poly{ {151, 177}, {170, 177}, {170, 183}, {151, 183}, {147, 180} }
  c:rim(s1:copy():add(s2), P.wood.deep)
  c:part(s1, "wood", { band = 1, pop = { 148, 168 } }) c:part(s2, "wood", { band = 1, nopop = true })
  R(150, 170, 164, 170, P.wood.shade) R(155, 180, 166, 180, P.wood.shade)
  c:paint({
    "o..o..........",
    "oo.oo.........",
    "ooooo.........",
    "oeooo.........",
    "cooooooooo..tt",
    ".ccooooooooottt",
    "..cooooooooo.tc",
    "...o.o...o.o...",
    "...o.o...o.o...",
  }, 190, 166, { o = "ember.hi", e = "#2b1c26", c = "#fff4d6", t = "ember.base" })
  c:px(189, 170, P.ink)
end
-- c4: big pumpkins + crate of apples
pumpkin(234, 182, 7) pumpkin(249, 189, 5) pumpkin(222, 192, 3)
do
  local cr = c:rect(206, 176, 218, 186)
  c:rim(cr, P.wood.deep) c:part(cr, "wood", { band = 1, nopop = true }) R(206, 181, 218, 181, P.wood.shade)
  for x = 207, 217, 3 do R(x, 175, x + 1, 176, P.ember.base) c:px(x, 175, P.ember.hi) end
end

------------------------------------------------------------------ NEAR (ink-edged frame)
local NEARG = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = P.ink }
-- top-left gold canopy (r0 c0), lobed, with falling leaves
do
  local cr = E(10, 4, 30, 17):add(E(42, 2, 13, 9)):add(E(4, 28, 13, 12)):add(E(26, 22, 11, 9)):add(E(46, 12, 6, 5))
  c:rim(cr, P.ink) c:part(cr, "gold", { band = 3, pop = { 8, 6 } })
  for _, l in ipairs{ {22, 8}, {8, 22}, {34, 4}, {16, 30}, {38, 14} } do c:px(l[1], l[2], P.gold.shade) c:px(l[1] + 1, l[2], P.gold.shade) c:px(l[1] + 2, l[2] - 1, P.gold.shade) end
  for _, l in ipairs{ {20, 12}, {30, 6}, {6, 16} } do R(l[1], l[2], l[1] + 1, l[2], P.gold.hi) end
  for _, f in ipairs{ {44, 26}, {34, 38}, {52, 22}, {14, 46} } do c:px(f[1], f[2], P.gold.base) c:px(f[1] + 1, f[2] + 1, P.gold.shade) end
end
-- top-right red maple canopy + trunk: owl in its hole, birdhouse, mushrooms (r0 c5, r1 c5)
do
  local tr = c:poly{ {279, 112}, {298, 112}, {295, 30}, {284, 30} }
  local root = c:poly{ {274, 112}, {279, 104}, {300, 104}, {300, 112} }
  local cr = E(290, 6, 30, 19):add(E(261, 4, 13, 9)):add(E(297, 32, 12, 13)):add(E(272, 25, 11, 8)):add(E(256, 14, 5, 4))
  c:rim(tr:copy():add(root):add(cr), P.ink)
  c:part(tr:copy():add(root), "wood", { band = 3, nopop = true })
  for y = 40, 104, 9 do c:px(287 + (y % 3), y, P.wood.shade) c:px(287 + (y % 3), y + 1, P.wood.shade) end
  c:part(cr, "ember", { band = 3, pop = { 268, 5 } })
  for _, l in ipairs{ {280, 10}, {294, 20}, {268, 22}, {286, 30}, {298, 6} } do c:px(l[1], l[2], P.ember.shade) c:px(l[1] + 1, l[2], P.ember.shade) c:px(l[1] + 2, l[2] - 1, P.ember.shade) end
  for _, l in ipairs{ {276, 4}, {288, 14}, {262, 10} } do R(l[1], l[2], l[1] + 1, l[2], P.ember.hi) end
  for _, f in ipairs{ {256, 30}, {266, 40}, {250, 46}, {276, 48} } do c:px(f[1], f[2], P.ember.base) c:px(f[1] + 1, f[2] + 1, P.ember.shade) end
  -- owl hole
  c:fillMask(E(289, 66, 4, 5), P.wood.deep)
  c:fillMask(E(289, 68, 3, 3), P.wood.base)
  c:px(287, 66, P.gold.hi) c:px(291, 66, P.gold.hi) c:px(287, 67, P.ink) c:px(291, 67, P.ink) c:px(289, 68, P.gold.base)
  c:px(287, 63, P.wood.base) c:px(291, 63, P.wood.base)
  -- birdhouse
  local bh = c:rect(281, 82, 287, 89) local bhr = c:poly{ {279, 83}, {284, 78}, {289, 83} }
  c:rim(bh:copy():add(bhr), P.ink) c:part(bh, "sea", { band = 1, nopop = true }) c:part(bhr, "ember", { band = 1, nopop = true })
  c:fillMask(E(284, 85, 1, 1), P.ink)
  -- mushrooms at the roots
  for _, m in ipairs{ {272, 110, 3}, {266, 112, 2} } do
    local cp = E(m[1], m[2] - 2, m[3], 2):clip(c:rect(0, 0, 299, m[2] - 2)) local st = c:rect(m[1] - 1, m[2] - 1, m[1], m[2] + 1)
    c:rim(cp:copy():add(st), P.ink) c:fillMask(st, P.cream) c:part(cp, "petal", { band = 1, nopop = true }) c:px(m[1] - 1, m[2] - 4, P.cream)
  end
end
-- bottom-left fern bank + toadstools (r3 c0)
do
  local f = E(8, 196, 22, 12):add(E(34, 200, 14, 8))
  local fronds = HP.mask()
  local FR = { { 6, 190, 20, 166 }, { 18, 192, 38, 174 }, { -2, 186, 4, 158 }, { 28, 196, 48, 186 } }
  for _, fr in ipairs(FR) do
    local mx, my = (fr[1] + fr[3]) / 2, (fr[2] + fr[4]) / 2
    local dx, dy = fr[3] - fr[1], fr[4] - fr[2]
    local L = math.sqrt(dx * dx + dy * dy) local px, py = -dy / L * 3.5, dx / L * 3.5
    fronds:add(c:poly{ {fr[1], fr[2]}, {mx + px, my + py}, {fr[3], fr[4]}, {mx - px, my - py} })
  end
  c:rim(f:copy():add(fronds), P.ink)
  c:part(f, NEARG, { band = 3, pop = { 4, 188 } })
  c:part(fronds, { hi = P.moss.hi, base = P.moss.hi, shade = P.moss.base, deep = P.moss.shade }, { band = 1, nopop = true, inner = false })
  for _, fr in ipairs(FR) do c:fillMask(c:line({ {fr[1], fr[2]}, {fr[3], fr[4]} }, 1):clip(fronds), P.moss.shade) end
  for _, m in ipairs{ {46, 182, 5}, {54, 188, 3} } do
    local cp = E(m[1], m[2], m[3], m[3] - 1):clip(c:rect(0, 0, 299, m[2])) local st = c:rect(m[1] - 1, m[2] + 1, m[1] + 1, m[2] + 5)
    c:rim(cp:copy():add(st), P.ink) c:fillMask(st, P.cream) c:part(cp, "ember", { band = 1, nopop = true })
    c:px(m[1] - 2, m[2] - 2, P.cream) c:px(m[1] + 1, m[2] - m[3] + 2, P.cream)
  end
end
-- bottom-right birches + gold bush (r3 c5)
do
  local trunks = HP.mask()
  for _, t in ipairs{ {266, 160}, {282, 152}, {294, 158} } do trunks:add(c:rect(t[1], t[2], t[1] + 2, 199)) end
  local tops = E(270, 156, 9, 6):add(E(284, 148, 10, 7)):add(E(296, 154, 7, 6))
  local b = E(290, 192, 22, 14):add(E(266, 198, 12, 6))
  c:rim(trunks:copy():add(tops):add(b), P.ink)
  c:part(trunks, BIRCH, { band = 1, nopop = true })
  for _, t in ipairs{ {266, 166}, {282, 162}, {294, 168}, {267, 174}, {283, 172}, {295, 176} } do R(t[1], t[2], t[1] + 1, t[2], P.ink) end
  c:part(tops, "gold", { band = 2, pop = { 278, 144 } })
  for _, l in ipairs{ {274, 152}, {288, 146}, {296, 152} } do c:px(l[1], l[2], P.gold.shade) c:px(l[1] + 1, l[2], P.gold.shade) end
  c:part(b, "gold", { band = 3, pop = { 274, 184 } })
  for _, l in ipairs{ {280, 184}, {294, 180}, {286, 194}, {270, 194} } do c:px(l[1], l[2], P.ember.base) c:px(l[1] + 1, l[2], P.ember.shade) end
end

HP.report(c) HP.assertClean(c)
HP.cells(c, 6, 4)
c:save{ aseprite = out .. "region-maplewold.aseprite", png = out .. "region-maplewold.png", scale = 6 }
c:save{ png = out .. "region-maplewold-thumb.png", scale = 1.5 }
