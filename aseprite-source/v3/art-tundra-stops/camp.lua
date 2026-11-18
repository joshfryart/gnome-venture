-- camp.lua : "Camp" stop look, TUNDRA (tundra_frost), 480x270 gate view.
-- Same composition and story as the Maplewold camp (art-2701-batch3/stops/opus3/camp.lua), re-cast as a sled-dog camp:
-- road's end: a double khaki wall tent (the mess) under snow with a stove pipe, skis leaning on it, between spruces.
-- Back left: a red canvas ridge tent behind a snow-block wall; a basket dog sled parked with a husky curled beside it,
-- runner tracks to the road. A drying line from a spruce to a bare birch: mittens, a Nordic sweater, dog booties,
-- dried char, a sock; a gnome pegging. Right: a smoke-darkened canvas lavvu with a Sami band, glowing door, antlers on
-- a pole. Back right: a freight sled with a lashed tarp load and a gang-line. Left: driftwood stacked between stakes
-- under snow, an ermine. Hero: the fire in a snow-capped stone ring inside a curved snow-block windbreak, a sooty
-- coffee kettle on a birch tripod, driftwood seats with reindeer hides, a squeezebox player, a gnome toasting a char,
-- a mug gnome, a husky asleep. Bottom left: a grub-box table with frying fish and bannock. Right: a dog stake-out line
-- with three huskies, straw beds and bowls. Quirk: an arctic fox in a red gnome hat climbing out of the green pack
-- with a sausage, its white brush over the rim.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-tundra-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "camp", out = DIR, farTrees = { 24, 52, 160, 196, 290, 318, 440 }, treeLineGap = { 194, 286 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local G, IR, S = L.glow, L.iron, L.snow
local CANVAS = F.rp("#ecdcb2 #ccb888 #a69268 #7a6a52 #4a4038") -- oiled khaki canvas: reads on snow
local LAVVU = F.rp("#d6c8b2 #b0a08a #8a7a6a #625650 #3c3236")  -- smoke-darkened lavvu cloth
local HIDE = F.rp("#d8c2a2 #b08e6c #866852 #5e4840 #3a2c2a")   -- reindeer hide
local DOG = L.rock                                                -- grey husky saddle
local COPPER = F.rp("#e8b48a #c8805a #9a5a44 #6c3e34 #442624")   -- a red husky
local SABLE = F.rp("#8e8ea4 #62627c #4a4a62 #36364c #24243a")    -- a dark husky

-- local helpers ------------------------------------------------------------------------
local function paws(pts, step)
  F.obj()
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local len = math.sqrt((b[1] - a[1]) ^ 2 + (b[2] - a[2]) ^ 2)
    for d = 0, len, step do
      local t = d / len
      local x, y = floor(a[1] + (b[1] - a[1]) * t + .5), floor(a[2] + (b[2] - a[2]) * t + .5) + ((d // step) % 2 == 0 and 0 or 2)
      px(x, y + 1, S.deep) px(x - 1, y, S.shade) px(x + 1, y, S.shade) px(x, y - 1, S.shade)
    end
  end
end
local function runnerTracks(pts)
  F.obj()
  for i = 1, #pts - 1 do
    line({ pts[i], pts[i + 1] }):each(function(x, y)
      px(x, y, S.shade) px(x, y + 3, S.shade)
      if hash(x, y, 7) < .3 then px(x, y + 1, S.hi) end
      if hash(x, y, 8) < .15 then px(x, y + 3, S.deep) end
    end)
  end
end
-- husky: pose "stand" | "sit" | "howl"; s = 1 faces right, -1 faces left; drawn at 1.4x the base grid
local function husky(x, yb, s, pose, coat)
  coat = coat or DOG
  local k = 1.4
  local function P(dx, dy) return { x + dx * s * k, yb + dy * k } end
  local function R(a, b, a2, b2) return poly{ P(a - .5, b - .5), P(a2 + .5, b - .5), P(a2 + .5, b2 + .5), P(a - .5, b2 + .5) } end
  local function E(dx, dy, rx, ry) return c:ellipse(x + dx * s * k, yb + dy * k, rx * k, ry * k) end
  local body, head, muzzle, ears, legs, tail, neck
  local hx, hy
  if pose == "sit" then
    body = poly{ P(-6, 0), P(-7, -4), P(-4, -9), P(0, -12), P(4, -12), P(5, -6), P(5, 0) }
    hx, hy = 4, -15
    muzzle = R(6, -15, 8, -13)
    ears = union(poly{ P(1, -17), P(2, -21), P(4, -17) }, poly{ P(4, -17), P(6, -21), P(7, -17) })
    legs = union(R(2, -6, 2, 0), R(4, -6, 4, 0))
    tail = E(-8, -2, 3, 2)
  else
    body = E(0, -8, 7, 3)
    local up = pose == "howl" and -3 or 0
    hx, hy = 9, -13 + up
    neck = poly{ P(3, -10), P(8, -15 + up), P(11, -12 + up), P(7, -6) }
    muzzle = pose == "howl" and union(R(10, -17 + up, 12, -16 + up), R(12, -18 + up, 13, -17 + up)) or R(11, -13, 13, -11)
    local ex = pose == "howl" and -2 or 0
    ears = union(poly{ P(6 + ex, -15 + up), P(7 + ex, -19 + up), P(9 + ex, -15 + up) }, poly{ P(9 + ex, -15 + up), P(10 + ex, -19 + up), P(11 + ex, -15 + up) })
    legs = union(R(-6, -6, -6, 0), R(-4, -6, -4, 0), R(4, -6, 4, 0), R(6, -6, 6, 0))
    tail = E(-7, -12, 3, 3)
  end
  head = E(hx, hy, 3, 3)
  local hcx, hcy = x + hx * s * k, yb + hy * k
  local m = union(body, head, muzzle, ears, legs, tail, neck or HP.mask())
  F.shadowM(c:ellipse(x + 3, yb + 1, 11, 1))
  rimOf(m, coat)
  fill(m, coat.base)
  m:each(function(xx, yy)
    local below = pose == "sit" and (yy > yb - 9 * k + (xx - x) * s * -.6) or (yy > yb - 8 * k)
    if legs:has(xx, yy) or (body:has(xx, yy) and below) then px(xx, yy, L.fur.base) end
    if body:has(xx, yy) and not m:has(xx, yy - 1) then px(xx, yy, coat.hi) end
  end)
  if neck then neck:each(function(xx, yy) if (xx - x) * s > 6 * k and yy > yb - 13 * k then px(xx, yy, L.fur.base) end end) end
  if pose == "sit" then body:each(function(xx, yy) if (xx - x) * s >= 2.5 * k and yy < yb - 2 and yy > yb - 12 * k then px(xx, yy, L.fur.base) end end) end
  head:each(function(xx, yy) if yy >= hcy then px(xx, yy, L.fur.base) end if (xx - hcx) * s > 1 and yy >= hcy - 1 then px(xx, yy, L.fur.hi) end end)
  fill(muzzle, L.fur.base)
  fill(tail, coat.base) tail:each(function(xx, yy) if not tail:has(xx, yy + 1) or not tail:has(xx, yy - 1) then px(xx, yy, L.fur.shade) end end)
  legs:each(function(xx, yy) if yy >= yb - 1 then px(xx, yy, L.fur.shade) end end)
  fill(ears, coat.shade) ears:each(function(xx, yy) if not ears:has(xx, yy - 1) then px(xx, yy, coat.deep) end end)
  local ex, ey = floor(hcx + s * 1.5 + .5), floor(hcy - 1)
  px(ex, ey, L.timber.edge) px(ex, ey - 1, coat.deep) px(ex + s, ey - 2, L.fur.hi) px(ex - s, ey - 2, L.fur.hi) -- eye, white brows
  local nb = { muzzle:bbox() }
  px(s > 0 and nb[3] or nb[1], nb[2], L.timber.edge) px(s > 0 and nb[3] - 1 or nb[1] + 1, nb[2], L.timber.deep) -- nose
  if pose == "howl" then for q = 0, 2 do px(floor(hcx) + (6 + q) * s, floor(hcy) - 8 - q * 2, S.deep) px(floor(hcx) + (7 + q) * s, floor(hcy) - 8 - q * 2, S.deep) end end
  return m
end
-- a curled sleeping husky (nose under tail)
local function sleeper(x, y, coat, flip)
  local rows = {
    ".ee.............",
    "eDDe....DDDDD...",
    "DDeDDDDDDDDDDD..",
    "nWDDDDDDDDdDDDt.",
    "WWWDDDDDDDDDDDtt",
    ".WWwwwwwwwwwww..",
  }
  if flip then for i, r in ipairs(rows) do rows[i] = r:reverse() end end
  F.shadowM(c:ellipse(x + 9, y + 6, 9, 1))
  F.sprite(rows, x, y, { e = coat.deep, D = coat.base, d = coat.shade, n = L.timber.edge, W = L.fur.hi, w = L.fur.shade, t = L.fur.base })
  hline(flip and x + 12 or x + 2, flip and x + 13 or x + 3, y + 2, L.timber.edge)
end

-- trampled snow clearing around the fire: boot-packed snow, with a melted bare ring near the stones
local clear = c:ellipse(150, 214, 92, 30)
clear:each(function(x, y) if not F.roadM:has(x, y) and x < F.xl(y) - 1 then
  local d = ((x - 150) / 92) ^ 2 + ((y - 214) / 30) ^ 2
  local v = hash(x, y, 3)
  if d < .85 then
    local b = F.vnoise(x / 6, y / 3, 4)
    local h = b < .4 and S.base or (b < .7 and S.shade or L.ground.base)
    if v < .05 then h = S.hi elseif v > .95 then h = S.deep end
    if (x + y * 3) % 11 == 0 and hash(x // 2, y, 5) < .4 then h = S.deep end -- boot prints
    px(x, y, h)
  elseif v < .4 then px(x, y, S.shade) end
end end)
runnerTracks({ { 142, 160 }, { 182, 156 }, { 226, 152 } })
paws({ { 150, 168 }, { 190, 176 }, { 214, 186 } }, 7)

---------------------------------------------------------------- back trees (plane 1)
F.depth(1)
F.tree(10, 140, 46, 1)
F.tree(318, 136, 46, 0)
F.tree(384, 140, 58, 6)
F.tree(444, 136, 44, 5)

---------------------------------------------------------------- road's end: the double khaki wall tent (the mess)
F.depth(2)
F.tree(292, 128, 50, 2)
F.tree(188, 126, 40, 1)
do
  local cx, yb = 240, 128
  local wall = rect(cx - 34, yb - 16, cx + 34, yb)
  local roofm = poly{ { cx - 42, yb - 15 }, { cx - 16, yb - 44 }, { cx, yb - 32 }, { cx + 16, yb - 44 }, { cx + 42, yb - 15 } }
  local poles = rect(cx - 17, yb - 52, cx - 16, yb - 44):add(rect(cx + 16, yb - 52, cx + 17, yb - 44))
  F.shadow(cx - 34, cx + 34, yb, 10, 3)
  rimOf(union(wall, roofm, poles), L.timber)
  roofm:each(function(x, y)
    local pk = x < cx and cx - 16 or cx + 16
    local h = x < pk and CANVAS.hi or CANVAS.base
    if x > pk + 2 and (x - pk) + (y - (yb - 44)) * .4 > 14 then h = CANVAS.shade end
    if x < pk and (pk - x) % 7 == 0 then h = CANVAS.base end
    if x > pk and (x - pk) % 7 == 0 then h = CANVAS.shade end
    if x == pk then h = CANVAS.deep end
    if hash(x, y, 80) < .03 then h = CANVAS.shade end
    px(x, y, h)
  end)
  F.snowCap(roofm, 5, 81, { cx = cx - 8 })
  -- walls: seams, a darker damp hem, falu-red binding
  wall:each(function(x, y)
    local h = ((x - cx) % 9 == 0) and CANVAS.shade or (x > cx + 22 and CANVAS.shade or CANVAS.base)
    if x < cx - 26 then h = (x - cx) % 9 == 0 and CANVAS.base or CANVAS.hi end
    if y >= yb - 3 then h = hash(x, y, 82) < .5 and CANVAS.deep or CANVAS.shade end
    px(x, y, h)
  end)
  hline(cx - 42, cx + 42, yb - 15, L.wall2.base) hline(cx - 42, cx + 42, yb - 14, L.wall2.deep)
  for x = cx - 40, cx + 40, 8 do px(x, yb - 15, L.wall2.hi) end
  F.icicles(cx - 40, cx + 40, yb - 13, 3, 83, .35)
  -- door with warm light, tied flaps
  local door = poly{ { cx - 8, yb }, { cx - 5, yb - 12 }, { cx + 5, yb - 12 }, { cx + 8, yb } }
  fill(door, G.shade) fill(rect(cx - 3, yb - 9, cx + 3, yb), G.base) px(cx - 2, yb - 8, G.hi) px(cx - 1, yb - 8, G.hi)
  fill(poly{ { cx - 8, yb }, { cx - 5, yb - 12 }, { cx - 10, yb - 2 } }, CANVAS.shade)
  fill(poly{ { cx + 8, yb }, { cx + 5, yb - 12 }, { cx + 10, yb - 2 } }, CANVAS.deep)
  part(poles, L.timber, { nopop = true, noshade = true })
  for _, p in ipairs({ { cx - 16, L.wall2 }, { cx + 17, L.accent } }) do fill(poly{ { p[1] + 1, yb - 52 }, { p[1] + 10, yb - 50 }, { p[1] + 1, yb - 47 } }, p[2].base) px(p[1] + 2, yb - 51, p[2].hi) end
  for _, g in ipairs({ { cx - 42, cx - 50 }, { cx + 42, cx + 50 } }) do line({ { g[1], yb - 15 }, { g[2], yb + 1 } }):each(function(x, y) px(x, y, L.board.deep) end) end
  -- stove pipe with a spark cap
  local pipe = rect(cx + 25, yb - 42, cx + 27, yb - 30)
  rimOf(pipe, IR) fill(pipe, IR.base) vline(cx + 25, yb - 42, yb - 30, IR.hi) hline(cx + 23, cx + 29, yb - 43, IR.deep)
  F.smoke(cx + 26, yb - 46, 5, .6, 2)
  -- snow banked along the walls
  F.drift(cx - 26, yb + 1, 14, 3, 84) F.drift(cx + 28, yb + 1, 12, 3, 85)
  -- skis and poles leaning on the right wall
  for k, sx in ipairs({ cx + 30, cx + 33 }) do
    local ski = line({ { sx, yb }, { sx + 3, yb - 22 } }, 1)
    fill(ski, k == 1 and L.wall2.base or L.accent.base) px(sx + 3, yb - 22, L.timber.edge) px(sx + 2, yb - 23, k == 1 and L.wall2.hi or L.accent.hi)
  end
  line({ { cx + 37, yb }, { cx + 38, yb - 18 } }):each(function(x, y) px(x, y, L.timber.deep) end) fill(rect(cx + 36, yb - 4, cx + 39, yb - 4), L.timber.deep)
  -- a stack of driftwood ends on the left
  for k = 0, 2 do F.logEnd(cx - 46 + k * 4, yb - 2, 2) end
  for k = 0, 1 do F.logEnd(cx - 44 + k * 4, yb - 6, 2) end
  hline(cx - 46, cx - 37, yb - 9, S.hi)
end

---------------------------------------------------------------- back left: red ridge tent behind a snow-block wall
local function ridgeTent(x, yb, w, h, r, flap)
  local front = poly{ { x - w, yb }, { x, yb - h }, { x + w, yb } }
  local side = poly{ { x, yb - h }, { x + w + 18, yb - h + 4 }, { x + w + 22, yb - 2 }, { x + w, yb } }
  local door = poly{ { x - w // 3, yb }, { x, yb - h * 2 // 3 }, { x + w // 3, yb } }
  F.shadow(x - w, x + w + 22, yb, 6, 3)
  rimOf(union(front, side), r)
  part(side, r, { noshade = true }) side:each(function(xx, y) if (xx - x) % 6 == 0 then px(xx, y, r.shade) end end)
  part(front, r, { sep = true })
  F.snowCap(side, 3, 86)
  fill(door, r.deep) fill(poly{ { x - 1, yb }, { x, yb - h * 2 // 3 }, { x + w // 3, yb } }, G.deep)
  if flap then fill(poly{ { x, yb - h * 2 // 3 }, { x - w // 3 - 4, yb - 2 }, { x - w // 3, yb } }, r.hi) end
  vline(x, yb - h - 4, yb - h, L.timber.base)
  line({ { x - w - 4, yb + 1 }, { x - w + 2, yb - 4 } }):each(function(xx, y) px(xx, y, L.board.shade) end)
  line({ { x + w + 26, yb + 1 }, { x + w + 18, yb - 6 } }):each(function(xx, y) px(xx, y, L.board.shade) end)
end
local function snowBlocks(m, y0, rowH, bw, seed)
  m:each(function(x, y)
    local row = (y - y0) // rowH
    local ry, rx = (y - y0) % rowH, (x + (row % 2) * (bw // 2)) % bw
    local h = (x < (seed or 0)) and S.base or S.shade
    if hash(x // bw, row, 9) < .3 then h = S.base end
    if ry == 0 then h = S.hi elseif ry == rowH - 1 or rx == 0 then h = S.deep elseif rx == bw - 1 then h = S.shade end
    px(x, y, h)
  end)
end
F.depth(1)
ridgeTent(36, 146, 14, 18, L.awnA, true)
do
  local wb = poly{ { 4, 150 }, { 6, 141 }, { 22, 140 }, { 22, 150 } }
  rimOf(wb, S) snowBlocks(wb, 141, 3, 5, 12)
end
F.willow(70, 150, 5, 6, 3)

---------------------------------------------------------------- back: a basket dog sled parked, a husky curled beside it
F.depth(2)
do
  local x0, yb = 98, 156
  local runner = line({ { x0, yb }, { x0 + 38, yb } }):add(line({ { x0, yb }, { x0 - 4, yb - 3 }, { x0 - 3, yb - 6 } }))
  local stan = HP.mask()
  for k = 0, 3 do stan:add(rect(x0 + 4 + k * 10, yb - 7, x0 + 4 + k * 10, yb - 1)) end
  local bed = rect(x0 + 2, yb - 4, x0 + 36, yb - 3)
  local rail = line({ { x0 - 2, yb - 8 }, { x0 + 34, yb - 8 } })
  local bow = line({ { x0 + 34, yb - 1 }, { x0 + 36, yb - 16 }, { x0 + 39, yb - 16 } }, 1)
  local m = union(runner, stan, bed, rail, bow)
  F.shadow(x0, x0 + 38, yb + 1, 4, 2)
  rimOf(m, L.timber)
  fill(m, L.timber.base) hline(x0, x0 + 38, yb, L.timber.hi) fill(bow, L.board.shade) fill(rail, L.board.base)
  -- a canvas sled bag with a red strap
  local bag = c:rrect(x0 + 6, yb - 14, x0 + 28, yb - 5, 3)
  rimOf(bag, CANVAS) part(bag, CANVAS) vline(x0 + 17, yb - 14, yb - 5, L.wall2.base)
  F.snowCap(bag, 2, 87)
end
sleeper(146, 150, COPPER, true)
F.depth(1)

---------------------------------------------------------------- drying line from a spruce to a bare birch
F.tree(84, 140, 46, 4)
F.depth(2)
F.birch(184, 140, 46, 37)
local function sagY(x) local t = (x - 88) / (182 - 88) return floor(108 + 8 * sin(t * pi)) end
for x = 88, 182 do px(x, sagY(x), L.board.deep) end
do
  -- mittens
  for k = 0, 1 do
    local x = 96 + k * 7 local y = sagY(x) + 1
    local m = c:rrect(x, y + 2, x + 5, y + 10, 2):add(rect(x - 1, y + 4, x, y + 7)):add(rect(x, y, x + 5, y + 2))
    rimOf(m, L.awnA) part(m, L.awnA, { nopop = true }) hline(x, x + 5, y + 1, L.fur.base) hline(x + 1, x + 4, y + 5, L.fur.hi)
    px(x + 2, y - 1, L.timber.base)
  end
  -- a Nordic sweater
  local x, y = 112, sagY(112) + 1
  local sw = rect(x - 3, y, x + 11, y + 4):add(rect(x + 1, y, x + 7, y + 14))
  rimOf(sw, L.accent) part(sw, L.accent, { nopop = true })
  for xx = x - 3, x + 11 do if xx % 2 == 0 then px(xx, y + 2, L.fur.hi) end px(xx, y + 1, L.fur.base) end
  for xx = x + 1, x + 7 do if (xx + 1) % 3 == 0 then px(xx, y + 6, L.fur.hi) end px(xx, y + 13, L.fur.base) end
  hline(x + 3, x + 5, y + 4, L.fur.hi)
  px(x, y - 1, L.timber.base) px(x + 8, y - 1, L.timber.base)
  -- dog booties
  for k = 0, 3 do
    local bx = 128 + k * 4 local by = sagY(bx) + 1
    local b = rect(bx, by, bx + 2, by + 5)
    rimOf(b, L.wall2) fill(b, k % 2 == 0 and L.wall2.base or L.accent.base) px(bx, by, k % 2 == 0 and L.wall2.hi or L.accent.hi) hline(bx, bx + 2, by + 5, L.fur.shade)
  end
  -- dried char hanging by the tail
  for k = 0, 2 do
    local fx = 148 + k * 6 local fy = sagY(fx) + 1
    local f = poly{ { fx, fy }, { fx + 2, fy }, { fx + 3, fy + 8 }, { fx + 1, fy + 11 }, { fx - 1, fy + 8 } }
    rimOf(f, L.timber) fill(f, L.rust.shade)
    f:each(function(xx, yy) if xx <= fx then px(xx, yy, L.rust.hi) end if yy > fy + 7 then px(xx, yy, L.iron.base) end end)
    px(fx + 1, fy + 9, L.timber.edge)
  end
  -- a striped sock
  x = 168 y = sagY(x) + 1
  local so = rect(x, y, x + 3, y + 8):add(rect(x, y + 6, x + 6, y + 9))
  rimOf(so, L.lav) part(so, L.lav, { nopop = true }) hline(x, x + 3, y, L.lav.hi) hline(x, x + 3, y + 3, L.fur.hi) px(x + 1, y - 1, L.timber.base)
end

---------------------------------------------------------------- right: the lavvu
F.depth(3)
local function lavvu(cx, yb)
  local ax, ay = cx, yb - 66
  local cone = poly{ { cx - 52, yb }, { ax - 3, ay }, { ax + 3, ay }, { cx + 52, yb } }
  local poles = HP.mask()
  for _, p in ipairs({ { -14, -14 }, { -6, -16 }, { 3, -17 }, { 10, -15 }, { 15, -12 } }) do poles:add(line({ { ax + p[1] // 3, ay + 2 }, { ax + p[1], ay + p[2] } }, 1)) end
  F.shadow(cx - 50, cx + 52, yb, 16, 5)
  rimOf(union(cone, poles), L.timber)
  part(poles, L.timber, { nopop = true, noshade = true })
  poles:each(function(x, y) if hash(x, y, 70) < .3 then px(x, y, L.timber.hi) end end)
  cone:each(function(x, y)
    local u = (x - ax) / math.max(1, (y - ay + 2))
    local lit = u < -.15
    local h = lit and LAVVU.hi or (u < .2 and LAVVU.base or LAVVU.shade)
    if u > .55 then h = LAVVU.deep end
    if abs((u * 7 + 20) % 1) < .09 then h = lit and LAVVU.base or LAVVU.deep end -- cloth seams
    if y < ay + 14 and hash(x, y, 71) < .5 + (ay + 14 - y) * .03 then h = (y < ay + 6) and L.soil.shade or LAVVU.deep end -- soot round the smoke hole
    if hash(x, y, 72) < .02 then h = LAVVU.shade end
    px(x, y, h)
  end)
  -- the Sami band: blue with red and yellow lines
  cone:each(function(x, y)
    if y >= yb - 16 and y <= yb - 10 then
      local h = (y == yb - 16 or y == yb - 10) and L.awnA.base or (y == yb - 13 and L.gold.base or L.accent.base)
      if y > yb - 16 and y < yb - 10 and y ~= yb - 13 and (x - ax) > (y - ay) * .35 then h = L.accent.shade end
      if y == yb - 12 and (x - ax) < -(y - ay) * .3 then h = L.accent.hi end
      px(x, y, h)
    end
  end)
  -- door: flap tied back, firelight inside, a rug of hides
  local door = poly{ { cx - 11, yb }, { cx - 4, yb - 32 }, { cx + 4, yb - 32 }, { cx + 11, yb } }
  fill(door, G.shade) fill(poly{ { cx - 7, yb }, { cx - 3, yb - 26 }, { cx + 3, yb - 26 }, { cx + 7, yb } }, G.base)
  fill(rect(cx - 2, yb - 20, cx + 2, yb - 12), G.hi) px(cx, yb - 22, G.hi)
  fill(rect(cx - 6, yb - 5, cx + 6, yb - 1), HIDE.base) hline(cx - 6, cx + 6, yb - 5, HIDE.hi) for x = cx - 5, cx + 5, 3 do px(x, yb - 3, HIDE.shade) end
  local flap = poly{ { cx - 11, yb }, { cx - 4, yb - 32 }, { cx - 20, yb - 4 } } fill(flap, LAVVU.shade) c:edgeIn(flap, LAVVU.deep)
  hline(cx - 18, cx - 14, yb - 14, L.awnA.base)
  local flapR = poly{ { cx + 11, yb }, { cx + 4, yb - 32 }, { cx + 14, yb - 2 } } fill(flapR, LAVVU.deep) c:edgeIn(flapR, L.soil.deep)
  -- snow banked round the hem, lumps on the windward cloth
  cone:each(function(x, y) if y >= yb - 4 + floor(hash(x // 4, 0, 73) * 3) and not door:has(x, y) then px(x, y, x < cx and S.base or S.shade) end end)
  for x = cx - 50, cx + 50 do if not door:has(x, yb - 4) and hash(x // 3, 1, 74) < .5 then px(x, yb - 5, S.hi) end end
  cone:each(function(x, y) if x < cx - 20 and y < yb - 20 and hash(x // 2, y // 2, 75) < .04 then px(x, y, S.hi) end end)
  -- smoke and steam from the smoke hole
  F.smoke(ax + 2, ay - 12, 7, .6, 2)
  -- guy ropes and pegs
  for _, g in ipairs({ { cx - 40, yb - 16, cx - 62, yb + 4 }, { cx + 40, yb - 16, cx + 62, yb + 4 } }) do
    line({ { g[1], g[2] }, { g[3], g[4] } }):each(function(x, y) px(x, y, L.board.deep) end)
    fill(rect(g[3] - 1, g[4] - 2, g[3], g[4] + 1), L.timber.base) px(g[3] - 1, g[4] - 2, S.hi)
  end
end
lavvu(350, 196)
-- antlers on a pole by the lavvu door
do
  local p = rect(306, 160, 307, 196) rimOf(p, L.timber) part(p, L.timber, { nopop = true, noshade = true })
  local antl = HP.mask()
  for _, a in ipairs({ { { 306, 161 }, { 301, 154 }, { 300, 146 } }, { { 307, 161 }, { 312, 154 }, { 313, 146 } }, { { 302, 154 }, { 297, 152 } }, { { 301, 149 }, { 297, 145 } }, { { 311, 154 }, { 316, 152 } }, { { 312, 149 }, { 316, 145 } } }) do antl:add(line(a, 1)) end
  rimOf(antl, L.timber) fill(antl, L.board.base) antl:each(function(x, y) if hash(x, y, 76) < .4 then px(x, y, L.board.hi) end end)
  hline(305, 308, 196, S.hi)
end

---------------------------------------------------------------- back right: a freight sled with a lashed tarp load
local function freightSled(x0, yb)
  local bed = rect(x0, yb - 6, x0 + 56, yb - 3)
  local curl = line({ { x0, yb - 3 }, { x0 - 5, yb - 6 }, { x0 - 6, yb - 11 }, { x0 - 3, yb - 13 } }, 2)
  local runner = line({ { x0 - 2, yb }, { x0 + 56, yb } })
  local load = c:rrect(x0 + 3, yb - 26, x0 + 54, yb - 6, 6)
  F.shadow(x0, x0 + 58, yb, 10, 3)
  rimOf(union(bed, curl, runner, load), L.timber)
  part(union(bed, curl), L.board) F.planks(bed, L.board, 5, true, 21)
  fill(runner, IR.base) hline(x0 - 2, x0 + 56, yb, IR.hi)
  part(load, L.roof2)
  load:each(function(x, y) if (x + y) % 9 == 0 or (x - y) % 9 == 0 then px(x, y, L.board.shade) end end) -- lashing
  F.snowCap(load, 4, 22, { cx = x0 + 22 })
  fill(c:ellipse(x0 + 58, yb - 14, 3, 3), IR.base) px(x0 + 57, yb - 15, IR.hi) px(x0 + 59, yb - 13, IR.deep) -- kettle off the back
  -- gang-line laid out in front, harnesses in a heap
  line({ { x0 - 4, yb - 2 }, { x0 - 30, yb + 4 } }):each(function(x, y) px(x, y, L.awnA.shade) end)
  for k = 0, 1 do local hx = x0 - 18 - k * 9 local hy = yb + 1 + k * 2 hline(hx - 2, hx + 2, hy, L.accent.base) px(hx - 2, hy - 1, L.accent.hi) px(hx + 2, hy + 1, L.accent.deep) end
end
F.depth(2)
freightSled(406, 152)
F.tree(470, 150, 46, 5)
-- a raven on the load
F.sprite({ "..kk...", ".kKkk..", "bkkkkkk", "..kkkkk", "...o.o." }, 430, 117, { k = "#4a4656", K = "#8a88a0", b = L.gold.deep, o = L.timber.edge })
F.depth(3)

---------------------------------------------------------------- left: driftwood stacked between stakes, an ermine
local function woodStack(x0, x1, yb)
  local stakes = rect(x0 - 2, yb - 22, x0, yb):add(rect(x1, yb - 22, x1 + 2, yb))
  local stack = rect(x0 + 1, yb - 18, x1 - 1, yb)
  F.shadow(x0, x1 + 2, yb, 6, 3)
  rimOf(union(stakes, stack), L.timber)
  part(stakes, L.timber, { nopop = true, noshade = true })
  fill(stack, L.timber.edge)
  for row = 0, 3 do for k = 0, (x1 - x0) // 6 do
    local x, y = x0 + 3 + k * 6 + (row % 2) * 3, yb - 3 - row * 5
    if x < x1 - 1 then F.logEnd(x, y, 2, (hash(k, row, 90) < .3) and L.redbark or L.timber) end
  end end
  F.snowCap(union(stakes, stack), 3, 91, { lip = true })
  F.icicles(x0, x1, yb - 15, 2, 92, .3)
  F.drift(x0 - 6, yb + 1, 10, 4, 93)
end
woodStack(22, 72, 196)
F.sprite({
  "............kk",
  "............Wb",
  ".kk.......WWWb",
  "kWWk....WWWWw.",
  "WeWWWWWWWWWw..",
  "nWWWWWWWWWww..",
  ".wW..wwW..w...",
}, 74, 188, { k = L.fur.deep, W = L.fur.hi, w = L.fur.shade, e = L.timber.edge, n = L.timber.edge, b = L.timber.edge })
-- a gnome pegging a mitten on the line
F.gnome(140, 134, { small = true, hat = L.produce, coat = L.wall2, arm = "up" })

---------------------------------------------------------------- the campfire (hero): windbreak, stone ring, birch tripod, kettle
local function campfire(cx, cy)
  -- curved snow-block windbreak behind the back seat
  local wb = HP.mask()
  for x = cx - 50, cx + 50 do
    local t = (x - cx) / 50
    local top = floor(cy - 46 + t * t * 10)
    for y = top, floor(cy - 28 + t * t * 6) do wb:set(x, y) end
  end
  rimOf(wb, S) snowBlocks(wb, cy - 46, 4, 7, cx - 10)
  wb:each(function(x, y) if not wb:has(x, y - 1) then px(x, y, S.hi) end end)
  local function seat(x0, x1, y, hide)
    local m = c:rrect(x0, y - 4, x1, y + 4, 4)
    F.shadow(x0, x1, y + 6, 4, 2)
    rimOf(m, L.timber) part(m, L.timber, { nopop = true })
    F.logs(m, L.timber, y - 4, 9)
    hline(x0 + 4, x1 - 4, y - 3, L.timber.hi)
    F.logEnd(x1 - 3, y, 4)
    if hide then
      local hx0, hx1 = x0 + 4, math.min(x1 - 8, x0 + 26)
      local h = rect(hx0, y - 5, hx1, y + 2):add(poly{ { hx0, y + 2 }, { hx0 + 3, y + 6 }, { hx1 - 3, y + 6 }, { hx1, y + 2 } })
      rimOf(h, HIDE) part(h, hide, { nopop = true })
      h:each(function(xx, yy) if hash(xx, yy, 95) < .2 then px(xx, yy, hide.hi) elseif hash(xx, yy, 96) < .1 then px(xx, yy, hide.deep) end end)
      for xx = hx0 + 1, hx1 - 1, 2 do px(xx, y + 6 + (xx % 4 == 1 and 1 or 0), hide.shade) end
      hline(hx0 + 2, hx1 - 2, y - 5, hide.hi)
    end
    F.snowCap(m:copy():clip(rect(x1 - 10, y - 6, x1 + 1, y + 6)), 1, x0)
  end
  seat(cx - 34, cx + 38, cy - 24, HIDE)
  local pit = c:ellipse(cx, cy, 17, 5)
  -- melted bare ring outside the stones: wet moss and lichen, steaming
  local wet = c:ellipse(cx, cy + 1, 30, 11):cut(pit)
  wet:each(function(x, y) local v = hash(x, y, 97) px(x, y, v < .3 and L.mossGround.shade or (v < .55 and L.tMoss[4] or (v < .8 and L.soil.shade or L.lichen.deep))) end)
  fill(pit, L.soil.deep)
  pit:each(function(x, y) if hash(x, y, 8) < .3 then px(x, y, L.road.shade) end end)
  for k = 0, 13 do
    local a = k / 14 * 2 * pi
    local x, y = floor(cx + cos(a) * 21), floor(cy + sin(a) * 7)
    local st = c:rrect(x - 4, y - 3, x + 3, y + 2, 2)
    rimOf(st, L.stone) part(st, L.stone, { nopop = k % 3 ~= 0 })
    if sin(a) < .2 then F.snowCap(st, 1, 98 + k) end
    if sin(a) > .5 then st:each(function(xx, yy) if hash(xx, yy, k) < .2 then px(xx, yy, G.deep) end end) end -- firelit faces
  end
  local logs = line({ { cx - 12, cy + 2 }, { cx + 10, cy - 4 } }, 3):add(line({ { cx - 10, cy - 4 }, { cx + 12, cy + 2 } }, 3))
  rimOf(logs, L.timber) part(logs, L.timber, { nopop = true })
  logs:each(function(x, y) if hash(x, y, 93) < .25 then px(x, y, G.deep) end end)
  pit:each(function(x, y) if hash(x, y, 9) < .25 and not logs:has(x, y) then px(x, y, G.deep) end end)
  local fl = poly{ { cx - 12, cy }, { cx - 9, cy - 16 }, { cx - 5, cy - 9 }, { cx - 2, cy - 28 }, { cx + 2, cy - 12 }, { cx + 6, cy - 22 }, { cx + 9, cy - 8 }, { cx + 12, cy } }
  fill(fl, G.deep)
  fill(fl:shrink(1), G.shade)
  fill(poly{ { cx - 8, cy }, { cx - 3, cy - 20 }, { cx + 1, cy - 9 }, { cx + 5, cy - 15 }, { cx + 8, cy } }, G.base)
  fill(poly{ { cx - 4, cy }, { cx - 1, cy - 12 }, { cx + 3, cy } }, G.hi)
  for i = 0, 14 do px(cx - 14 + floor(hash(i, 1, 31) * 30), cy - 32 - floor(hash(i, 2, 31) * 24), i % 3 == 0 and G.base or G.hi) end
  -- birch tripod
  local tri = line({ { cx - 18, cy + 4 }, { cx, cy - 40 } }, 2):add(line({ { cx + 18, cy + 4 }, { cx, cy - 40 } }, 2)):add(line({ { cx + 4, cy - 2 }, { cx, cy - 40 } }, 1))
  rimOf(tri, L.timber) part(tri, L.birch, { nopop = true, noshade = true })
  tri:each(function(x, y) if hash(x, y // 2, 94) < .15 then px(x, y, L.birch.edge) end end)
  hline(cx - 2, cx + 2, cy - 38, L.awnA.shade)
  vline(cx, cy - 37, cy - 33, IR.deep)
  -- the sooty coffee kettle: tapered body, spout, lid knob, bail
  local ket = poly{ { cx - 6, cy - 18 }, { cx - 4, cy - 29 }, { cx + 4, cy - 29 }, { cx + 6, cy - 18 } }
  local spout = line({ { cx + 5, cy - 22 }, { cx + 10, cy - 27 } }, 2)
  local lid = rect(cx - 3, cy - 31, cx + 3, cy - 30):add(rect(cx - 1, cy - 33, cx, cy - 32))
  local km = union(ket, spout, lid)
  rimOf(km, IR) part(ket, IR) part(spout, IR, { nopop = true, noshade = true }) fill(lid, IR.shade) px(cx - 1, cy - 33, IR.hi)
  vline(cx - 4, cy - 27, cy - 20, IR.hi) ket:each(function(x, y) if y > cy - 22 and hash(x, y, 77) < .5 then px(x, y, IR.deep) end end) -- soot
  line({ { cx - 5, cy - 29 }, { cx, cy - 33 }, { cx + 5, cy - 29 } }):each(function(x, y) if not km:has(x, y) then px(x, y, IR.deep) end end)
  F.steam(cx + 11, cy - 30, 4, .4, 11)
  F.smoke(cx + 1, cy - 42, 8, .5, 2)
  -- warm light on the snow
  local glowM = c:ellipse(cx, cy + 4, 46, 15):cut(c:ellipse(cx, cy + 1, 31, 12))
  glowM:each(function(x, y) if hash(x, y, 33) < .35 and not F.roadM:has(x, y) then px(x, y, hash(x, y, 34) < .5 and "#f4dcc4" or "#ecd2c4") end end)
  seat(cx - 46, cx - 22, cy + 4)
  seat(cx + 24, cx + 50, cy + 2, HIDE)
  seat(cx - 16, cx + 18, cy + 20, L.fur)
  F.steam(cx - 26, cy + 8, 3, .5, 12) F.steam(cx + 28, cy - 2, 3, .5, 13)
end
campfire(132, 214)
-- the back gnome plays a squeezebox
local _, lx, ly = F.gnome(104, 191, { hat = L.leaf, coat = L.roof2, arm = "hold", noShadow = true, hatBand = L.fur.base })
do
  local box = rect(lx - 2, ly - 4, lx + 7, ly + 1)
  rimOf(box, L.wall2) fill(box, L.wall2.base)
  for x = lx, lx + 5, 2 do vline(x, ly - 4, ly + 1, L.board.hi) end
  vline(lx - 2, ly - 4, ly + 1, L.wall2.hi) vline(lx + 7, ly - 4, ly + 1, L.wall2.deep) px(lx + 7, ly - 3, L.gold.hi)
  for _, n in ipairs({ { lx + 8, ly - 14 }, { lx + 13, ly - 18 } }) do vline(n[1] + 1, n[2] - 3, n[2], L.timber.edge) fill(rect(n[1], n[2], n[1] + 1, n[2] + 1), L.timber.edge) end
end
-- a gnome toasting a char on a stick
local _, mx, my = F.gnome(96, 210, { hat = L.awnA, coat = L.accent, arm = "out" })
fill(line({ { mx, my }, { mx + 12, my - 8 } }), L.board.base)
do
  local f = poly{ { mx + 9, my - 9 }, { mx + 15, my - 11 }, { mx + 17, my - 9 }, { mx + 13, my - 6 } }
  rimOf(f, L.timber) fill(f, L.rust.base) hline(mx + 11, mx + 15, my - 10, L.rust.hi) px(mx + 15, my - 9, L.timber.edge)
  fill(poly{ { mx + 7, my - 10 }, { mx + 9, my - 9 }, { mx + 7, my - 6 } }, L.rust.shade)
end
-- a gnome with a steaming mug
local _, ux, uy = F.gnome(174, 208, { hat = L.gold, coat = L.lav, arm = "out", flip = true, hatBand = L.fur.base })
fill(rect(ux - 3, uy - 3, ux, uy + 1), L.awnA.base) px(ux - 3, uy - 3, L.awnA.hi) px(ux, uy - 2, L.awnA.deep) hline(ux - 3, ux, uy - 3, L.fur.hi)
F.steam(ux - 2, uy - 5, 3, .2, 14)
-- a husky asleep by the fire
sleeper(154, 228, DOG)
paws({ { 196, 236 }, { 210, 244 } }, 6)

---------------------------------------------------------------- grub-box table on a sled base, bottom-left
do
  local top = rect(24, 236, 76, 239)
  local box = rect(28, 240, 72, 249)
  local run = line({ { 22, 252 }, { 76, 252 } }):add(line({ { 22, 252 }, { 18, 249 }, { 19, 246 } }))
  local legs = rect(30, 250, 31, 251):add(rect(68, 250, 69, 251))
  F.shadow(24, 76, 253, 6, 3)
  rimOf(union(top, box, run, legs), L.timber)
  part(top, L.board, { nopop = true }) F.planks(top, L.board, 9, true, 31)
  part(box, L.wall2) F.planks(box, L.wall2, 11, true, 32)
  fill(rect(48, 243, 52, 245), IR.base) px(48, 243, IR.hi) -- hasp
  fill(legs, L.timber.base) fill(run, IR.base) hline(22, 76, 252, IR.hi)
  hline(24, 76, 235, S.hi) hline(26, 30, 235, S.base)
end
local ket = c:ellipse(36, 231, 5, 4):add(rect(41, 228, 44, 229)) rimOf(ket, L.accent) part(ket, L.accent) fill(rect(34, 226, 38, 227), L.accent.shade)
F.steam(44, 226, 3, .3, 15)
local pan = c:ellipse(56, 234, 7, 2) rimOf(pan, IR) part(pan, IR, { nopop = true }) fill(rect(63, 233, 70, 234), L.timber.base)
for k = 0, 1 do local fx = 51 + k * 6 hline(fx, fx + 4, 233, L.rust.base) px(fx, 233, L.rust.hi) px(fx + 4, 233, L.rust.deep) end
local loaf = c:ellipse(70, 231, 4, 3) rimOf(loaf, L.board) part(loaf, L.leaf) px(68, 229, L.leaf.hi) hline(69, 72, 231, L.board.hi)
-- tin mugs, a dog-food bucket and snow-melt pot under the table
for _, m in ipairs({ { 28, 232 } }) do fill(rect(m[1], m[2], m[1] + 3, m[2] + 3), IR.base) px(m[1], m[2], IR.hi) end
do
  local bucket = rect(84, 242, 92, 251) rimOf(bucket, IR) part(bucket, IR, { nopop = true }) hline(84, 92, 244, IR.deep) hline(85, 91, 242, S.hi)
  line({ { 84, 242 }, { 88, 238 }, { 92, 242 } }):each(function(x, y) if y < 242 then px(x, y, IR.deep) end end)
end
F.willow(12, 252, 6, 8, 41) F.willow(100, 256, 5, 6, 42)

---------------------------------------------------------------- hide bedrolls, packs and the fox (right of the road)
local function bedroll(x, y, r)
  local m = c:rrect(x - 14, y - 5, x + 14, y + 5, 5)
  rimOf(m, r) part(m, r)
  m:each(function(xx, yy) if hash(xx, yy, 43) < .18 then px(xx, yy, r.hi) elseif hash(xx, yy, 44) < .08 then px(xx, yy, r.deep) end end)
  for k = -8, 8, 8 do vline(x + k, y - 5, y + 5, L.awnA.shade) end
  local e = c:ellipse(x + 12, y, 3, 5) fill(e, L.fur.base) c:ellipse(x + 12, y, 1, 3):edge():each(function(xx, yy) px(xx, yy, r.shade) end)
  F.snowCap(m, 1, x)
end
bedroll(300, 230, HIDE) bedroll(312, 240, L.deer)
local function pack(x, yb, r)
  local m = c:rrect(x - 8, yb - 18, x + 8, yb, 4)
  local flap = c:rrect(x - 8, yb - 20, x + 8, yb - 12, 3)
  F.shadow(x - 6, x + 8, yb, 5, 2)
  rimOf(union(m, flap), r) part(m, r) part(flap, r, { sep = true })
  fill(rect(x - 1, yb - 13, x + 1, yb - 11), L.gold.base) px(x - 1, yb - 13, L.gold.hi)
  vline(x - 5, yb - 11, yb - 2, r.deep) vline(x + 5, yb - 11, yb - 2, r.deep)
  fill(c:ellipse(x + 10, yb - 8, 4, 4), IR.base) px(x + 9, yb - 10, IR.hi) px(x + 12, yb - 6, IR.deep)
end
pack(346, 258, L.foliage)
pack(330, 262, L.leaf)
-- quirk: an arctic fox in a red gnome hat climbing out of the green pack, a sausage in its paws
F.sprite({
  ".......RRr......",
  "......RRRr......",
  "......RRRRr.....",
  ".....RRRRRr.....",
  ".kk..RRRRRRr.kk.",
  "kFFkhhhhhhhhkFFk",
  "kFpFFFFFFFFFFpFk",
  ".FFFFFFFFFFFFFF.",
  ".FFeFFFFFFFFeFf.",
  ".FFFFFFFFFFFFFf.",
  "..fFFFFnnFFFFf..",
  "...fFFFFFFFFf...",
  "..pffffffffffp..",
  "SSSSSSSSSSSSSs..",
  "ssSSSSSSSSSSSS..",
  "..pf........fp..",
}, 337, 222, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, k = L.fur.deep, F = L.fur.hi, f = L.fur.shade, p = L.petal.base,
  e = L.timber.edge, n = L.timber.edge, S = L.redbark.base, s = L.redbark.hi })
px(342, 222, L.awnA.hi) px(343, 223, L.awnA.hi)
-- its brush draped over the pack's rim
F.sprite({ ".ff.", "fFFf", "FFFF", "FFFf", "fFFf", ".FFf", ".fF.", "..F." }, 354, 236, { F = L.fur.hi, f = L.fur.shade })
F.depth(0)
F.birds({ { 330, 40, 2 }, { 344, 48, 1 }, { 120, 56, 2 } })
F.depth(3)

---------------------------------------------------------------- right: the dog stake-out line
do
  local y = 214
  F.drift(452, 218, 10, 4, 61)
  for _, sx in ipairs({ 392, 458 }) do local st = rect(sx, y - 9, sx + 1, y) rimOf(st, L.timber) part(st, L.timber, { nopop = true, noshade = true }) px(sx, y - 9, S.hi) px(sx + 1, y - 9, S.hi) end
  line({ { 393, y - 6 }, { 458, y - 6 } }):each(function(x, yy) px(x, yy, IR.deep) end)
  for _, b in ipairs({ { 404, 226 }, { 426, 227 }, { 449, 226 } }) do
    local bed = c:ellipse(b[1], b[2], 10, 2)
    bed:each(function(x, yy) local v = hash(x, yy, 62) px(x, yy, v < .3 and L.fern.hi or (v < .7 and L.fern.base or L.fern.shade)) end)
  end
  for _, b in ipairs({ { 413, 228 }, { 440, 229 } }) do fill(c:ellipse(b[1], b[2], 2, 1), IR.base) hline(b[1] - 1, b[1] + 1, b[2] - 1, IR.hi) end
  local function dog(rows, x0, yb, coat, flip)
    local r2 = {}
    for i, r in ipairs(rows) do r2[i] = flip and r:reverse() or r end
    F.shadowM(c:ellipse(x0 + #r2[1] // 2 + 3, yb + 1, #r2[1] // 2 + 2, 1))
    F.sprite(r2, x0, yb - #r2 + 1, { K = coat.deep, D = coat.base, d = coat.shade, H = coat.hi, W = L.fur.base, w = L.fur.shade,
      B = L.fur.hi, e = L.timber.edge, n = L.timber.edge }, { rimCol = coat.edge })
  end
  dog({
    "........K.K.....",
    ".......KDKDK....",
    ".......DDDDDD...",
    "......DDBeDDD...",
    "......DBBWWWWWn.",
    "......DBWWWWWW..",
    ".....DDWWWWWW...",
    "....DHDDWWWW....",
    "...DHDDDWWWW....",
    "..DHDDDdWWWW....",
    "..DHDDddWWWW....",
    ".DDDDddDWWWW....",
    ".DDDDdDWWW.W....",
    "DDDDddWWWW.W....",
    "DDDDdWWwWW.W....",
    "wWWWWWwwww.ww...",
  }, 394, 226, DOG, true)
  line({ { 404, 212 }, { 404, y - 6 } }):each(function(x, yy) px(x, yy, IR.shade) end)
  dog({
    ".............K.K......",
    "..DDD........DKDK.....",
    ".DHHHD.......DDDDD....",
    "DHwwwHD......DDBeDD...",
    "DHw..DD.....DDDBBWWWWn",
    "DHw...DDDDDDDDDBWWWWW.",
    ".Dw..DHHHHHHHHDWWWWW..",
    "....DHHDDDDDDDDdWWW...",
    "....DDDDDDDDDDddWW....",
    "....DDDdDDDDDddWWW....",
    "....WDDDdddDDdWWWW....",
    "....WWWWWWWWWWWWWW....",
    "....WW.WW....WW.WW....",
    "....WW.WW....WW.WW....",
    "....WW.WW....WW.WW....",
    "....ww.ww....ww.ww....",
  }, 414, 227, SABLE, false)
  line({ { 432, 213 }, { 433, y - 6 } }):each(function(x, yy) px(x, yy, IR.shade) end)
  sleeper(440, 220, COPPER, true)
  paws({ { 396, 232 }, { 376, 222 }, { 340, 206 } }, 6)
end
F.conifer(392, 206, 20, L.foliage2, 44)

---------------------------------------------------------------- by the road: lantern pole, sign
local lp = rect(286, 176, 287, 212) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
fill(rect(281, 176, 287, 177), L.timber.base) vline(281, 178, 180, L.timber.edge) hline(281, 287, 175, S.hi)
local lan = rect(278, 181, 284, 188) rimOf(lan, L.timber) fill(lan, G.base) px(279, 182, G.hi) vline(284, 182, 188, G.shade) hline(278, 284, 181, S.hi)
F.icicles(281, 287, 178, 3, 63, .5)
F.drift(288, 214, 8, 3, 64)
F.sign(212, 196, 20, 12, L.board)
fill(poly{ { 206, 205 }, { 212, 198 }, { 218, 205 } }, L.wall2.base) fill(poly{ { 211, 205 }, { 212, 202 }, { 213, 205 } }, G.base) px(210, 200, L.wall2.hi)
hline(201, 223, 195, S.hi) hline(203, 221, 194, S.base)
F.willow(200, 216, 4, 5, 65)
-- scattered: dry sedge through the snow, crowberries
for i = 0, 30 do
  local x, y = 20 + floor(hash(i, 1, 55) * 440), 150 + floor(hash(i, 2, 55) * 110)
  if not (x > 378 and y > 228) and not F.roadM:has(x, y) and c:get(x, y) == F.groundAt(x, y) then
    vline(x, y - 2, y, L.fern.shade) px(x + 1, y - 1, L.fern.base) if i % 4 == 0 then px(x - 1, y, L.apple.deep) end
  end
end
F.finish()
