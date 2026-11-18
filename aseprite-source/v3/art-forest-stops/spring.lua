-- spring.lua : "Spring" stop look, FOREST (forest_pinewood), 480x270 gate view.
-- Same composition as the Maplewold spring (art-2701-batch4/stops/opus3/spring.lua), re-cast for a pine wood:
-- Right hero: a big mossy granite outcrop under spruces, with a dressed-stone face and a carved stone gnome head; spring
-- water arcs from its mouth into a wide stone basin, a second trickle runs from a crack into a gnome's pail. The basin
-- overflows into a brook that winds down-left, under a stone bridge on the road, into a misted pond bottom-left.
-- Left: a log-crib well-head with a gnome winding the bucket up, birches and a log cabin. A gnome carries two pails on
-- a yoke down the road, another does the washing at the pond, another hauls a water cart. Road's end: a log hamlet with
-- a stave chapel. Dragonflies, a dipper on the bridge, ferns, mushrooms, mist lying on the water.
-- Quirk: a big green frog in a red gnome hat sits on a lily pad in the basin, eyes shut, taking a shower under the spout.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-forest-stops/"
local F = dofile(DIR .. "_frame.lua")
  .build{ name = "spring", out = DIR, farTrees = { 22, 60, 104, 150, 330, 372, 452 }, treeLineGap = { 188, 290 },
    clouds = { { 130, 42, 40 }, { 280, 30, 46 }, { 400, 58, 34 }, { 30, 82, 24 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local Wt = L.water
local GL = "#eef6e6" -- cool water glint
local moss = L.moss
local rock = F.rp("#dce2d2 #b0b8a8 #8a9488 #646f6c #40494e") -- cool mossy granite
local sand = F.rp("#e6e4cc #c4c2a6 #9e9c86 #747768 #4a504c") -- dressed grey-green sandstone
local lichen = { "#d4dca0", "#aebc80", "#e0a868" }

---------------------------------------------------------------- back row: a log hamlet with a stave chapel at the road's end
F.depth(1)
do
  local top, _, wall = F.building{ x0 = 196, x1 = 228, yb = 126, wh = 13, rh = 11, wall = L.timber, roof = L.roof, noFrame = true, noAttic = true, chimney = true, shingle = true }
  F.logs(wall, L.timber, top, 3)
  F.window(204, 117, 208, 120, L.timber)
end
F.smoke(219, 97, 4, .5, 2)
do -- a little stave chapel with a shingled spire right of the road
  local wall = rect(254, 112, 278, 126)
  local roof = poly{ { 251, 113 }, { 266, 102 }, { 281, 113 } }
  local tower = rect(256, 96, 263, 112)
  local spire = poly{ { 255, 97 }, { 259, 80 }, { 264, 97 } }
  rimOf(union(wall, roof, tower, spire), L.timber)
  part(wall, L.timber) F.planks(wall, L.timber, 3, true, 21)
  part(tower, L.board, { nopop = true }) F.planks(tower, L.board, 3, true, 22)
  part(roof, L.roof2, { nopop = true }) F.courses(roof, 102, 2, 4, L.roof2)
  part(spire, L.roof2, { nopop = true }) F.courses(spire, 80, 2, 3, L.roof2)
  F.moss(roof, .12, 23)
  fill(c:rrect(258, 99, 261, 104, 1), L.glow.shade) px(259, 79, L.gold.base) px(259, 78, L.gold.hi)
  F.window(270, 116, 273, 120, L.timber, true)
end
F.tree(300, 128, 28, 3)
F.tree(186, 128, 30, 2)
F.fenceP(120, 132, 190, 127, 6)
F.depth(2)
F.tree(184, 150, 36, 4)
F.tree(8, 156, 34, 1)
do -- mid-left: a cut stump, a fallen mossy log and bracken between the cabin and the well
  local function stump(x, yb, w)
    local body = rect(x - w, yb - w, x + w, yb)
    local top = c:ellipse(x, yb - w, w, math.max(1, w // 2))
    rimOf(union(body, top), L.timber) part(body, L.timber, { nopop = true })
    fill(top, L.board.base) px(x, yb - w, L.board.shade) px(x - 1, yb - w - 1, L.board.hi)
    F.moss(body, .2, x)
  end
  stump(30, 168, 4) stump(176, 168, 3)
  local lg = rect(20, 150, 48, 154) rimOf(lg, L.timber) part(lg, L.redbark, { nopop = true }) F.logs(lg, L.redbark, 150, 5) F.moss(lg, .22, 35)
  F.logEnd(48, 152, 2)
  for i = 1, 14 do
    local x, y = 18 + floor(hash(i, 1, 36) * 200), 142 + floor(hash(i, 2, 36) * 20)
    if not F.roadM:has(x, y) and (x < 104 or x > 168) then F.fern(x, y, 3 + (y - 140) // 8, hash(i, 3, 36) < .3 and L.needle or L.fern) end
  end
end

---------------------------------------------------------------- mid left: log cabin, birches, a spruce
F.depth(2)
do
  local top, _, wall = F.building{ x0 = 24, x1 = 70, yb = 136, wh = 20, rh = 16, wall = L.timber, roof = L.roof, chimney = true, noAttic = true, shingle = true, noFrame = true }
  F.logs(wall, L.timber, top, 3)
  for y = top + 1, 134, 3 do F.logEnd(23, y, 1) F.logEnd(71, y, 1) end
  F.window(30, 122, 35, 127, L.timber) F.door(50, 124, 57, 135, L.timber)
end
F.smoke(61, 88, 6, .5, 2)
F.birch(92, 150, 56, 31)
-- washing strung from the cabin gable to the birch (the washer at the pond has more to do)
F.washing(70, 118, 91, 120, { { "shirt", L.awnA }, { "sock", L.accent }, { "trousers", L.lav } }, 3)
F.birch(160, 140, 44, 34)
F.tree(124, 146, 40, 6)

---------------------------------------------------------------- right hero: the granite outcrop under the spruces
F.depth(2)
F.tree(446, 128, 70, 8)
F.conifer(404, 104, 44, L.foliage, 55)
F.conifer(352, 114, 38, L.foliage2, 56)
F.conifer(326, 136, 30, L.foliage, 57)
F.depth(3)
local boulders = {
  { 312, 158, 22, 22, 41 }, { 340, 128, 26, 24, 42 }, { 384, 114, 30, 22, 43 }, { 430, 120, 26, 24, 44 },
  { 452, 160, 20, 30, 45 }, { 300, 196, 16, 16, 46 }, { 436, 196, 26, 18, 47 },
  { 330, 190, 22, 18, 48 }, { 352, 166, 14, 16, 50 }, { 418, 150, 12, 16, 51 },
}
local rockM = HP.mask()
for _, b in ipairs(boulders) do
  local pts = {}
  for i = 0, 13 do
    local a = i / 14 * 2 * pi
    local k = .82 + .2 * hash(i, b[5], 3)
    pts[#pts + 1] = { b[1] + cos(a) * b[3] * k, b[2] + sin(a) * b[4] * k }
  end
  b.m = poly(pts)
  rockM:add(b.m)
end
local face = rect(352, 132, 420, 196)
local mass = poly{ { 294, 212 }, { 298, 172 }, { 312, 132 }, { 346, 106 }, { 388, 96 }, { 432, 98 }, { 466, 110 }, { 470, 212 } }
rockM:add(face):add(mass)
F.shadowM(c:ellipse(380, 214, 92, 5))
rimOf(rockM, rock)
mass:each(function(x, y)
  local v = hash(x, y, 77)
  local h = (hash(x // 5, y // 4, 78) < .5) and rock.shade or rock.deep
  if v < .06 then h = rock.base elseif v > .96 then h = rock.edge end
  if hash(x // 3, y // 3, 79) < .12 then h = moss.deep end -- damp moss in the crevices
  px(x, y, h)
end)
for _, b in ipairs(boulders) do
  local off = hash(b[5], 1, 2) * 2 * pi
  b.m:each(function(x, y)
    local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
    local r = math.sqrt(nx * nx + ny * ny)
    local a = math.atan(ny, nx)
    local sec = floor(((a + off) % (2 * pi)) / (2 * pi) * 7)
    local ca = sec / 7 * 2 * pi + pi / 7 - off
    local lit
    if r < .38 then lit = .25 - (nx * .6 + ny * .8) * .4
    else lit = -(cos(ca) * .6 + sin(ca) * .8) * math.min(1, r * 1.2) end
    lit = lit + (hash(x // 2, y // 2, b[5]) - .5) * .25
    local h
    if lit > .55 then h = rock.hi elseif lit > .1 then h = rock.base elseif lit > -.4 then h = rock.shade else h = rock.deep end
    if (x * 3 + y * 7 + b[5]) % 41 == 0 then h = rock.edge end
    if hash(x, y, b[5]) > .97 then h = rock.deep elseif hash(x, y, b[5]) < .03 then h = rock.hi end
    -- granite grain: pale feldspar flecks
    if lit > -.4 and hash(x, y, b[5] + 9) < .02 then h = "#e8eadc" end
    px(x, y, h)
  end)
  c:edgeIn(b.m, rock.edge)
  for k = 1, 2 do
    local x, y = floor(b[1] + (hash(k, b[5], 81) - .5) * b[3]), floor(b[2] - b[4] * .1 + (hash(k, b[5], 82) - .2) * b[4] * .6)
    for t = 0, floor(b[4] * .5) do
      if b.m:has(x, y) and b.m:has(x, y + 1) then px(x, y, rock.edge) if b.m:has(x - 1, y) then px(x - 1, y, rock.hi) end end
      y = y + 1 x = x + ((hash(t, k, b[5]) < .5) and 1 or -1) * ((t % 2) == 0 and 1 or 0)
    end
  end
  -- lichen rosettes: pale green-grey, and the odd orange one
  for k = 1, 4 do
    local x, y = floor(b[1] + (hash(k, b[5], 83) - .5) * b[3] * 1.2), floor(b[2] + (hash(k, b[5], 84) - .3) * b[4] * .8)
    local a1, a2 = lichen[1], lichen[2]
    if k == 4 then a1, a2 = lichen[3], "#b8804c" end
    if b.m:has(x, y) then px(x, y, a1) px(x + 1, y, a2) px(x, y + 1, a2) px(x - 1, y + 1, a1) end
  end
  -- a deep moss cushion on the top with a ragged hanging lower edge and dangling strands
  b.m:each(function(x, y)
    local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
    local cap = -.38 + .16 * sin(x * .31 + b[5]) + .2 * hash(x // 3, 3, b[5]) + .06 * hash(x, 4, b[5])
    if ny < cap and nx < .75 then
      local v = hash(x, y, 9)
      local edge = not b.m:has(x, y - 1)
      local lt = -(nx * .6 + ny * .8)
      local h = lt > .75 and moss.hi or (lt > .35 and moss.base or moss.shade)
      if v < .12 then h = moss.hi elseif v > .93 then h = L.fern.base end
      if edge then h = moss.edge end
      px(x, y, h)
      if not (ny + 0.06 < cap) then
        px(x, y + 1, moss.deep)
        if hash(x, b[5], 10) < .07 and b.m:has(x, y + 3) then px(x, y + 2, moss.shade) px(x, y + 3, moss.deep) end
      end
    end
  end)
end
-- small ferns and a sapling growing out of the rock ledges
for _, f in ipairs({ { 318, 140, 5 }, { 346, 112, 4 }, { 436, 104, 5 }, { 458, 140, 5 }, { 300, 182, 4 }, { 426, 136, 4 } }) do F.fern(f[1], f[2], f[3]) end
F.conifer(372, 100, 14, L.foliage2, 58)
-- the dressed face: ashlar courses, an arched niche
part(face, sand, { inner = false })
F.courses(face, 132, 7, 14, sand)
F.moss(face, .06, 59)
c:edgeIn(face, sand.edge)
local niche = c:rrect(362, 136, 410, 186, 20):clip(rect(362, 136, 410, 186))
fill(niche, rock.deep) c:edgeIn(niche, sand.edge)
niche:each(function(x, y)
  if (x - 386) + (y - 160) < -14 then px(x, y, rock.shade) end
  if hash(x, y, 5) < .04 then px(x, y, rock.edge) end
  if y > 176 and hash(x // 2, y, 6) < .35 then px(x, y, moss.deep) end -- wet moss at the back of the niche
end)
c:rrect(360, 134, 412, 188, 22):clip(rect(360, 134, 412, 186)):cut(c:rrect(362, 136, 410, 188, 20)):each(function(x, y) px(x, y, ((x + y) % 5 == 0) and sand.deep or sand.hi) end)
-- moss curtain hanging over the face, with long wet strands
for x = 352, 420 do if hash(x, 2, 8) < .7 then local n = 1 + floor(hash(x, 3, 8) * 5) if hash(x, 4, 8) < .12 then n = n + 6 end for k = 0, n do px(x, 132 + k, k == 0 and moss.hi or (k == n and moss.deep or (k % 3 == 2 and moss.shade or moss.base))) end end end
-- the carved stone gnome head spout
do
  local hx, hy = 386, 158
  local hat = poly{ { hx - 13, hy - 8 }, { hx + 13, hy - 8 }, { hx + 6, hy - 22 }, { hx + 11, hy - 26 }, { hx + 2, hy - 25 }, { hx - 6, hy - 18 } }
  local fc = c:rrect(hx - 11, hy - 9, hx + 11, hy + 3, 4)
  local beard = poly{ { hx - 12, hy - 1 }, { hx + 12, hy - 1 }, { hx + 9, hy + 12 }, { hx, hy + 18 }, { hx - 9, hy + 12 } }
  local head = union(hat, fc, beard)
  c:rim(head, sand.edge)
  part(fc, sand, { nopop = true }) part(beard, sand, { nopop = true }) part(hat, sand, { nopop = true })
  hline(hx - 13, hx + 13, hy - 8, sand.deep) hline(hx - 12, hx + 12, hy - 9, sand.hi)
  beard:each(function(x, y) if (x + 2 * y) % 5 == 0 and y > hy + 1 then px(x, y, sand.shade) end end)
  for _, ex in ipairs({ hx - 6, hx + 6 }) do px(ex - 2, hy - 4, sand.edge) px(ex - 1, hy - 3, sand.edge) px(ex, hy - 3, sand.edge) px(ex + 1, hy - 3, sand.edge) px(ex + 2, hy - 4, sand.edge) end
  local nose = c:ellipse(hx, hy - 1, 4, 3) c:rim(nose, sand.deep) part(nose, sand, { nopop = true }) px(hx - 2, hy - 3, sand.hi) px(hx - 1, hy - 3, sand.hi)
  px(hx - 9, hy - 1, sand.shade) px(hx + 9, hy - 1, sand.shade)
  -- a verdigris-green bronze pipe
  local pipe = rect(hx - 2, hy + 4, hx + 4, hy + 7) c:rim(pipe, L.timber.edge) fill(pipe, L.accent.shade) hline(hx - 2, hx + 4, hy + 4, L.accent.hi) fill(rect(hx + 3, hy + 5, hx + 4, hy + 6), Wt.deep)
  -- moss on the hat, lichen on the beard, green algae streak below the mouth
  for x = hx - 4, hx + 8 do px(x, hy - 21 + floor(abs(x - hx - 2) * .6), moss.base) px(x, hy - 22 + floor(abs(x - hx - 2) * .6), moss.hi) end
  px(hx - 7, hy + 6, lichen[1]) px(hx - 6, hy + 7, lichen[2]) px(hx + 6, hy + 9, lichen[1])
  for y = hy + 8, hy + 14 do px(hx + 1, y, moss.shade) end
end
-- the jet: an arc from the mouth down into the basin
local JX0, JY0 = 391, 164
local function jetY(x) local t = (x - JX0) / 18 return JY0 + floor(t * t * 22 + t * 2) end
for x = JX0, JX0 + 17 do
  local y0, y1 = jetY(x), jetY(x + 1)
  for y = y0, math.max(y0 + 3, y1 + 1) do px(x, y, Wt.base) px(x + 1, y, Wt.base) px(x + 2, y, Wt.shade) end
  px(x, y0, Wt.hi) px(x, y0 - 1, Wt.edge)
  if x % 3 == 0 then px(x + 1, y0 + 1, GL) end
end

---------------------------------------------------------------- the basin, its overflow and the frog
F.depth(3)
local BX, BY = 392, 202
do
  local outer = c:ellipse(BX, BY, 40, 10)
  local wall = rect(BX - 40, BY, BX + 40, BY + 8)
  local inner = c:ellipse(BX, BY - 1, 35, 7)
  rimOf(union(outer, wall), L.stone)
  part(union(outer, wall), L.stone)
  F.courses(wall, BY, 4, 9, L.stone)
  wall:each(function(x, y) if (x - BX) > 20 and y > BY + 2 then px(x, y, L.stone.shade) end end)
  outer:edge():each(function(x, y) if y < BY then px(x, y, L.stone.hi) end end)
  F.water(inner, Wt)
  -- reflection of the dark spruces in the far half of the basin
  inner:each(function(x, y) if y < BY - 2 and y > BY - 7 and hash(x // 4, 0, 13) < .45 and (x + y) % 2 == 0 then px(x, y, Wt.shade) end end)
  for x = BX - 40, BX + 40 do if hash(x, 4, 12) < .55 then local n = floor(hash(x, 5, 12) * 5) for k = 0, n do px(x, BY + 8 - k, k == n and moss.hi or moss.base) end end end
end
-- the trickle from a crack in the rock into a gnome's pail
do
  local cx, cy = 334, 168
  fill(line({ { cx - 3, cy - 4 }, { cx, cy } }, 2), L.stone.edge)
  for y = cy - 3, cy + 6 do px(cx - 1 + floor((y - cy + 4) * .3), y + 1, moss.shade) end
  for y = cy, 196 do px(cx + floor((y - cy) * .1), y, ((y // 2) % 2 == 0) and Wt.hi or Wt.base) end
  local _, hx, hy = F.gnome(318, 218, { hat = L.awnA, coat = L.lav, arm = "out" })
  local pail = poly{ { hx + 1, hy - 7 }, { hx + 10, hy - 7 }, { hx + 9, hy + 3 }, { hx + 2, hy + 3 } }
  c:rim(pail, L.timber.edge) part(pail, L.board) F.planks(pail, L.board, 3, true, 31)
  hline(hx + 1, hx + 10, hy - 5, L.iron.shade) hline(hx + 2, hx + 9, hy + 1, L.iron.shade)
  hline(hx + 2, hx + 9, hy - 7, Wt.hi) px(hx + 5, hy - 8, GL) px(hx + 8, hy - 9, Wt.hi)
  c:ellipse(hx + 5, hy - 12, 5, 4):edge():each(function(x, y) if y < hy - 11 then px(x, y, L.iron.base) end end)
end
-- QUIRK: the frog in a red gnome hat on a lily pad in the basin, eyes shut, under the shower
do
  local pad = c:ellipse(408, 200, 10, 3):cut(poly{ { 408, 200 }, { 420, 197 }, { 420, 202 } })
  fill(pad, L.leaf.base) pad:edge():each(function(x, y) if y > 200 then px(x, y, L.leaf.deep) else px(x, y, L.leaf.hi) end end)
  F.sprite({
    "..........RR....",
    ".........RRr....",
    "........HRRr....",
    ".......HRRRr....",
    "......HRRRRr....",
    "......RRRRRRr...",
    ".....HRRRRRRr...",
    "...bbbbbbbbbbb..",
    "..GGgGGGGGGgGGG.",
    ".GGekeGGGGGekeG.",
    ".GgGGGGGGGGGGgGg",
    "gGGGGmmmmmmGGGGg",
    "gGGGGGmmmmGGGGgg",
    "gGGyyyyyyyyyGGgd",
    ".gGyyyyyyyyyGgdd",
    "GGgyyyyyyyyygdGG",
    "GGGgyyyyyyygdGGG",
    ".dd.ddd..ddd.dd.",
  }, 400, 181, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.awnB.base, G = L.leaf.base, g = L.leaf.shade,
    d = L.leaf.deep, e = L.leaf.deep, k = L.timber.edge, m = L.apple.shade, y = L.birchLeaf.hi })
  -- dark spots on its back
  px(405, 191, L.leaf.deep) px(411, 190, L.leaf.deep) px(410, 192, L.leaf.shade)
  for _, p in ipairs({ { 409, 176 }, { 405, 178 }, { 413, 177 }, { 402, 181 }, { 416, 182 }, { 411, 173 }, { 399, 186 }, { 418, 186 } }) do px(p[1], p[2], Wt.hi) end
  px(407, 175, GL) px(414, 175, GL)
end
-- the brook winding down-left under the road into the pond
local brook = HP.mask()
do
  local pts = { { 356, 208 }, { 340, 218 }, { 318, 226 }, { 296, 232 }, { 270, 238 }, { 240, 242 }, { 210, 244 }, { 180, 247 }, { 150, 250 } }
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local w = 12 + floor(i * 1.6)
    brook:add(line({ a, b }, w))
    brook:add(c:ellipse(b[1], b[2], w // 2, w // 2))
  end
  local pond = c:ellipse(84, 252, 76, 18):clip(rect(19, 230, 200, 269))
  brook:add(pond)
end
local onRoad = HP.mask()
brook:each(function(x, y) if F.roadM:has(x, y) then onRoad:set(x, y) end end)
brook:cut(onRoad)
do
  local bank = brook:grow(2):cut(brook):cut(F.roadM)
  bank:each(function(x, y) local v = hash(x, y, 51) px(x, y, v < .4 and L.stone.base or (v < .6 and L.stone.hi or (v < .85 and moss.base or moss.shade))) end)
  brook:edge():each(function(x, y) if hash(x, y, 52) < .3 then px(x, y, L.stone.hi) end end)
  F.water(brook, Wt, { step = 3 })
  -- dark reflections of the spruces on the pond's far edge
  for _, rx in ipairs({ 36, 56, 78, 126 }) do for k = 0, 6 do hline(rx - 4 + k // 2, rx + 4 - k // 2, 238 + k * 2, Wt.shade) end end
  brook:each(function(x, y)
    if y % 3 == 1 and hash(x // 5, y, 54) < .3 and brook:has(x - 2, y) and brook:has(x + 2, y) and brook:has(x, y + 2) then px(x, y, Wt.hi) end
    if hash(x, y, 55) < .012 and brook:has(x, y - 2) then px(x, y, GL) end
  end)
  -- mossy stones in the stream with a foam lip on the upstream side
  for _, s in ipairs({ { 334, 220 }, { 310, 228 }, { 290, 234 }, { 186, 247 }, { 270, 241 } }) do
    local m = c:ellipse(s[1], s[2], 3, 2) rimOf(m, L.stone) part(m, L.stone, { nopop = true }) px(s[1] - 1, s[2] - 1, L.stone.hi)
    px(s[1] - 2, s[2] - 2, moss.base) px(s[1] - 1, s[2] - 2, moss.hi) px(s[1], s[2] - 2, moss.base)
    for k = 0, 3 do px(s[1] + 3 + k, s[2] - 2 + (k % 2), GL) end hline(s[1] - 4, s[1] - 1, s[2] + 3, Wt.hi)
  end
  for y = 204, 212 do px(354 + (y - 204) // 3, y, Wt.hi) px(355 + (y - 204) // 3, y, Wt.base) px(356 + (y - 204) // 3, y, GL) end
end
-- stone bridge where the road crosses the brook
do
  local Y0, Y1 = 226, 258
  local par, cope = HP.mask(), HP.mask()
  for y = Y0, Y1 do
    local xl, xr = floor(F.xl(y)), floor(F.xr(y) + .99)
    par:add(rect(xl - 7, y - 10, xl + 1, y)):add(rect(xr - 1, y - 10, xr + 7, y))
  end
  par:clip(rect(0, Y0 - 10, 479, Y1))
  par:each(function(x, y) if not par:has(x, y - 2) then cope:set(x, y) end end)
  local wallL = poly{ { floor(F.xl(234)) - 22, 236 }, { floor(F.xl(234)) - 6, 230 }, { floor(F.xl(256)) - 6, 258 }, { floor(F.xl(256)) - 24, 258 } }
  local wallR = poly{ { floor(F.xr(226)) + 6, 224 }, { floor(F.xr(226)) + 22, 228 }, { floor(F.xr(244)) + 22, 248 }, { floor(F.xr(244)) + 6, 248 } }
  local walls = union(wallL, wallR)
  rimOf(union(par, walls), L.stone)
  part(walls, L.stone, { nopop = true }) F.courses(walls, 236, 4, 8, L.stone)
  F.moss(walls, .1, 60)
  for _, a in ipairs({ { floor(F.xl(244)) - 15, 251, wallL }, { floor(F.xr(236)) + 14, 242, wallR } }) do
    local arch = c:ellipse(a[1], a[2], 7, 9):clip(rect(a[1] - 7, a[2] - 9, a[1] + 7, a[2] + 4)):clip(a[3])
    fill(arch, Wt.edge)
    arch:each(function(x, y) if y > a[2] - 2 then px(x, y, (x + y) % 3 == 0 and Wt.shade or Wt.deep) end end)
    c:ellipse(a[1], a[2], 9, 11):cut(c:ellipse(a[1], a[2], 7, 9)):clip(rect(a[1] - 9, a[2] - 11, a[1] + 9, a[2])):clip(a[3]):each(function(x, y)
      px(x, y, (math.atan(y - a[2], x - a[1]) * 4 // 1) % 2 == 0 and L.stone.hi or L.stone.base) end)
    for k = 0, 4 do px(a[1] - 4 + k * 2, a[2] + 3, GL) end
    -- ferns dangling from the arch crown
    for k = -3, 3, 2 do local n = 2 + floor(hash(k, a[1], 61) * 3) for t = 0, n do px(a[1] + k, a[2] - 10 + t, t == n and L.fern.deep or L.fern.shade) end end
  end
  part(par, L.stone, { nopop = true })
  F.courses(par, Y0 - 10, 4, 7, L.stone)
  par:each(function(x, y) if hash(x, y, 57) < .07 then px(x, y, moss.base) end end)
  cope:each(function(x, y) px(x, y, cope:has(x, y - 1) and L.stone.base or (hash(x // 3, y, 58) < .3 and moss.hi or L.stone.hi)) end)
  for _, p in ipairs({ { floor(F.xl(254)) - 6, 254 }, { floor(F.xr(250)) + 4, 250 } }) do for k = -3, 3 do px(p[1] + k, p[2] - (k % 2), moss.base) px(p[1] + k, p[2] - 1 - (k % 2), moss.hi) end end
  for i = 0, 6 do local x, y = floor(F.xr(238)) + floor(hash(i, 1, 58) * 7), 232 + floor(hash(i, 2, 58) * 18) if par:has(x, y) then px(x, y, lichen[1]) end end
end

---------------------------------------------------------------- left: a log-crib well-head with a gnome winding the bucket
F.depth(3)
do
  local x0, x1, yb = 52, 104, 204
  local wall = rect(x0, yb - 18, x1, yb)
  local postL, postR = rect(x0 + 4, yb - 52, x0 + 7, yb - 18), rect(x1 - 7, yb - 52, x1 - 4, yb - 18)
  local roof = poly{ { x0 - 6, yb - 48 }, { (x0 + x1) // 2, yb - 66 }, { x1 + 6, yb - 48 } }:add(rect(x0 - 6, yb - 49, x1 + 6, yb - 46))
  local axle = rect(x0 + 4, yb - 36, x1 - 4, yb - 34)
  local crank = line({ { x1 - 2, yb - 35 }, { x1 + 4, yb - 35 }, { x1 + 4, yb - 29 } }, 2)
  F.shadow(x0 + 2, x1, yb, 12, 4)
  rimOf(union(wall, postL, postR, roof, axle, crank), L.timber)
  part(wall, L.timber) F.logs(wall, L.timber, yb - 18, 4)
  for y = yb - 16, yb - 2, 4 do F.logEnd(x0, y, 2) F.logEnd(x1, y, 2) end
  F.moss(wall, .08, 62)
  for x = x0, x1 do if hash(x, 7, 61) < .5 then px(x, yb, moss.base) px(x, yb - 1, moss.hi) end end
  part(postL, L.timber, { nopop = true }) part(postR, L.timber, { nopop = true })
  part(roof, L.roof, { sep = true }) F.courses(roof, yb - 66, 3, 5, L.roof) F.moss(roof, .16, 63)
  line({ { x0 - 6, yb - 48 }, { (x0 + x1) // 2, yb - 66 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  -- a pine cone and a little bough on the roof ridge
  F.sprite({ ".s.", "sSs", "SsS", ".S." }, (x0 + x1) // 2 - 1, yb - 70, { s = L.soil.shade, S = L.soil.base })
  part(axle, L.timber, { nopop = true, noshade = true })
  fill(rect((x0 + x1) // 2 - 4, yb - 37, (x0 + x1) // 2 + 4, yb - 33), L.board.base)
  for x = (x0 + x1) // 2 - 4, (x0 + x1) // 2 + 4, 2 do vline(x, yb - 37, yb - 33, L.board.shade) end
  part(crank, L.iron, { nopop = true, noshade = true })
  local bx = (x0 + x1) // 2
  vline(bx, yb - 32, yb - 26, L.board.deep)
  local bk = poly{ { bx - 5, yb - 25 }, { bx + 5, yb - 25 }, { bx + 4, yb - 17 }, { bx - 4, yb - 17 } }
  c:rim(bk, L.timber.edge) part(bk, L.board) hline(bx - 5, bx + 5, yb - 23, L.iron.shade) hline(bx - 4, bx + 4, yb - 25, Wt.hi)
  px(bx + 4, yb - 14, Wt.hi) px(bx - 3, yb - 12, Wt.base)
  local _, hx, hy = F.gnome(x1 + 14, yb + 4, { hat = L.awnA, coat = L.accent, arm = "up", flip = true })
  fill(line({ { hx, hy }, { x1 + 4, yb - 29 } }), L.skin.base)
end
-- ferns and a mushroom ring at the well's foot
for _, f in ipairs({ { 46, 206, 6 }, { 38, 200, 5 }, { 112, 214, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(44, 214, L.apple, true) F.mushroom(50, 216, L.apple) F.mushroom(40, 217, L.needle)

---------------------------------------------------------------- road: gnome with two pails on a yoke; the spring sign
F.depth(3)
do
  local x, yb = 262, 212
  F.gnome(x, yb, { hat = L.fern, coat = L.roof2, arm = "hold" })
  local yoke = line({ { x - 16, yb - 12 }, { x, yb - 14 }, { x + 16, yb - 12 } }, 2)
  c:rim(yoke, L.timber.edge) part(yoke, L.board, { nopop = true, noshade = true })
  for _, sx in ipairs({ -16, 16 }) do
    vline(x + sx, yb - 11, yb - 6, L.board.deep)
    local p = poly{ { x + sx - 5, yb - 6 }, { x + sx + 5, yb - 6 }, { x + sx + 4, yb + 2 }, { x + sx - 4, yb + 2 } }
    c:rim(p, L.timber.edge) part(p, L.board) hline(x + sx - 5, x + sx + 5, yb - 4, L.iron.shade) hline(x + sx - 4, x + sx + 4, yb - 6, Wt.hi)
    px(x + sx + 3, yb + 4, Wt.hi)
  end
  for i = 1, 4 do px(x - 2 + (i % 2) * 4, yb - 6 - i * 7, L.road.shade) end
end
do -- the spring sign: a blue drop on a board, a moss cap on top
  local post = rect(206, 168, 207, 196)
  local bd = rect(194, 156, 220, 170)
  rimOf(union(post, bd), L.timber) part(post, L.timber, { nopop = true }) part(bd, L.board, { nopop = true }) c:edgeIn(bd, L.board.deep)
  F.planks(bd:shrink(1), L.board, 5, false, 33)
  local drop = poly{ { 207, 158 }, { 211, 164 }, { 203, 164 } }:add(c:ellipse(207, 165, 4, 3))
  c:rim(drop, Wt.edge) fill(drop, Wt.base) px(205, 164, Wt.hi) px(205, 165, GL) hline(206, 209, 168, Wt.shade)
  for x = 194, 220 do if hash(x, 1, 34) < .5 then px(x, 155, moss.base) end end
end

---------------------------------------------------------------- a jug stall by the sign: clay jugs and birch-bark cups, a seller behind
F.depth(3)
do
  F.gnome(156, 188, { hat = L.lav, coat = L.awnB, arm = "out", noShadow = true })
  local top = rect(132, 186, 182, 189)
  local legs = rect(135, 190, 136, 200):add(rect(178, 190, 179, 200))
  local cloth = rect(132, 190, 182, 194)
  F.shadow(134, 182, 201, 8, 3)
  rimOf(union(top, legs, cloth), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true }) part(top, L.board, { nopop = true }) hline(132, 182, 186, L.board.hi)
  fill(cloth, L.awnB.base) cloth:each(function(x, y) if ((x - 132) // 4) % 2 == 0 then px(x, y, L.accent.base) end if y == 194 then px(x, y, L.accent.deep) end end)
  for i, jx in ipairs({ 137, 147, 165, 174 }) do
    local big = i % 2 == 1
    local jh = big and 10 or 7
    local jug = c:rrect(jx - 3, 185 - jh, jx + 3, 185, 2):add(rect(jx - 1, 183 - jh, jx + 1, 185 - jh))
    local hnd = c:ellipse(jx + 4, 180 - jh // 2, 2, 2):cut(c:ellipse(jx + 4, 180 - jh // 2, 1, 1))
    c:rim(union(jug, hnd), L.timber.edge) part(jug, L.roof2) fill(hnd, L.roof2.shade)
    hline(jx - 3, jx + 3, 182 - jh // 2, L.awnB.base) px(jx - 2, 184 - jh, L.roof2.hi)
  end
  for _, bx in ipairs({ 156, 160 }) do -- birch-bark cups
    local cup = rect(bx - 1, 182, bx + 1, 185) c:rim(cup, L.birch.edge) fill(cup, L.birch.base) px(bx - 1, 182, L.birch.hi) px(bx + 1, 184, L.birch.edge)
  end
end

---------------------------------------------------------------- mid: a log bench under the birches, a far gnome on the road, path stones
F.depth(2)
do
  local lg = rect(112, 158, 146, 162) rimOf(lg, L.timber) part(lg, L.timber, { nopop = true }) F.logs(lg, L.timber, 158, 5)
  F.logEnd(112, 160, 2)
  F.gnome(124, 160, { small = true, hat = L.roof2, coat = L.fern, arm = "out", noShadow = true })
  F.gnome(136, 160, { small = true, hat = L.accent, coat = L.awnA, flip = true, noShadow = true })
  F.gnome(238, 146, { small = true, hat = L.lav, coat = L.wall2, arm = "out" })
  px(248, 139, L.roof2.base) px(248, 140, L.roof2.shade)
end
F.depth(3)
for _, s in ipairs({ { 200, 206 }, { 186, 210 }, { 170, 212 }, { 150, 210 }, { 132, 208 } }) do
  local m = c:ellipse(s[1], s[2], 5, 2) rimOf(m, L.stone) part(m, L.stone, { nopop = true }) px(s[1] - 2, s[2] - 1, L.stone.hi) px(s[1] + 1, s[2] - 2, moss.base)
end

---------------------------------------------------------------- right of the road: a small gnome with a jug, a young spruce and a juniper
F.depth(2)
F.conifer(280, 152, 28, L.foliage2, 61) F.bush(300, 148, 9, 9, L.foliage, 62)
F.depth(3)
do
  local _, hx, hy = F.gnome(286, 192, { hat = L.awnA, coat = L.accent, arm = "hold" })
  local jug = c:rrect(hx - 2, hy - 6, hx + 3, hy + 1, 2) c:rim(jug, L.timber.edge) part(jug, L.roof2, { nopop = true }) px(hx - 1, hy - 5, L.roof2.hi)
end

---------------------------------------------------------------- the pond: lily pads, cattails, a gnome doing the washing
F.depth(3)
for _, p in ipairs({ { 60, 246 }, { 98, 258 }, { 124, 246 }, { 40, 260 }, { 150, 254 } }) do
  local pad = c:ellipse(p[1], p[2], 6, 2):cut(poly{ { p[1], p[2] }, { p[1] + 7, p[2] - 2 }, { p[1] + 7, p[2] + 1 } })
  fill(pad, L.leaf.base) px(p[1] - 4, p[2] - 1, L.leaf.hi) px(p[1] + 2, p[2] + 1, L.leaf.deep) px(p[1] - 1, p[2], L.leaf.shade)
end
for _, f in ipairs({ { 98, 256 }, { 40, 258 } }) do -- white water lilies
  fill(rect(f[1] - 1, f[2] - 3, f[1] + 1, f[2] - 2), L.awnB.hi) px(f[1], f[2] - 4, L.awnB.hi) px(f[1], f[2] - 2, L.gold.hi)
  px(f[1] - 2, f[2] - 2, L.petal.hi) px(f[1] + 2, f[2] - 2, L.petal.hi)
end
do -- cattails at the pond's left
  local m = HP.mask()
  for i = 0, 8 do
    local x = 22 + i * 3 + (i % 2)
    local h = 12 + floor(hash(i, 4, 3) * 12)
    m:add(line({ { x, 248 }, { x + (i % 3) - 1, 248 - h } }, 2))
  end
  c:rim(m, L.fern.edge)
  m:each(function(x, y) px(x, y, hash(x, y, 4) < .3 and L.fern.shade or (y < 236 and L.fern.hi or L.fern.base)) end)
  for i = 0, 8, 2 do
    local x = 22 + i * 3 + (i % 2) + (i % 3) - 1
    local h = 12 + floor(hash(i, 4, 3) * 12)
    local cm = rect(x, 248 - h - 6, x + 2, 248 - h - 1) c:rim(cm, L.timber.edge) fill(cm, L.soil.base) vline(x, 248 - h - 6, 248 - h - 2, L.soil.hi) vline(x + 2, 248 - h - 5, 248 - h - 1, L.soil.shade)
  end
end
do -- the washer gnome on a flat stone with a basket of laundry and a washboard
  local st = c:ellipse(170, 236, 12, 3) rimOf(st, L.stone) part(st, L.stone, { nopop = true }) F.moss(st, .2, 64)
  local _, hx, hy = F.gnome(168, 232, { hat = L.awnB, coat = L.fern, arm = "out", flip = true, noShadow = true })
  local wb = rect(hx - 6, hy - 6, hx, hy + 4) c:rim(wb, L.timber.edge) part(wb, L.board, { nopop = true })
  for y = hy - 4, hy + 3, 2 do hline(hx - 5, hx - 1, y, L.board.deep) end
  for k = 0, 2 do hline(hx - 12 - k * 2, hx - 6 + k * 2, hy + 7 + k * 2, Wt.hi) end
  local bsk = c:rrect(184, 222, 202, 234, 3) rimOf(bsk, L.board) part(bsk, L.needle)
  bsk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) elseif (x - y) % 4 == 0 then px(x, y, L.needle.hi) end end)
  fill(c:ellipse(189, 221, 4, 2), L.accent.base) fill(c:ellipse(196, 220, 4, 2), L.awnA.base) px(194, 219, L.awnA.hi) px(187, 220, L.accent.hi)
end
-- a mossy boulder on the pond's far bank
F.moss(F.rock(20, 232, 8, 7), .3, 76)

---------------------------------------------------------------- ferns, forget-me-nots and mushrooms round the rocks
F.depth(3)
for _, f in ipairs({ { 292, 214, 7 }, { 306, 222, 6 }, { 452, 214, 7 }, { 376, 222, 6 }, { 120, 208, 6 }, { 468, 220, 6 }, { 230, 214, 5 } }) do F.fern(f[1], f[2], f[3]) end
for i = 0, 9 do
  local x, y = 300 + floor(hash(i, 1, 71) * 160), 220 + floor(hash(i, 2, 71) * 9)
  if not F.roadM:has(x, y) and not brook:grow(3):has(x, y) then
    for k = -3, 3 do px(x + k, y + 1, L.fern.shade) if k % 2 == 0 then px(x + k, y, L.fern.base) end end
    for _, d in ipairs({ { -2, -1 }, { 1, -2 }, { 3, -1 } }) do
      local fx, fy = x + d[1], y + d[2]
      px(fx, fy, Wt.base) px(fx - 1, fy, Wt.shade) px(fx + 1, fy, Wt.shade) px(fx, fy - 1, Wt.hi) px(fx, fy + 1, Wt.shade)
      px(fx, fy, L.gold.hi)
    end
  end
end
F.mushroom(440, 226, L.apple, true) F.mushroom(446, 228, L.apple) F.mushroom(300, 230, L.needle, true)
for i, s in ipairs({ { 292, 206 }, { 306, 202 }, { 322, 204 } }) do
  local m = c:ellipse(s[1], s[2], 5, 2) rimOf(m, L.stone) part(m, L.stone, { nopop = true }) px(s[1] - 2, s[2] - 1, L.stone.hi) px(s[1] + 2, s[2] - 2, moss.base)
end
-- young spruces on the brook banks so the wood closes in
F.conifer(458, 228, 30, L.foliage, 42)

---------------------------------------------------------------- foreground life: brook reeds, a water cart, dragonflies
F.depth(3)
local function reeds(x, yb, n, hmax, seed)
  local m, heads = HP.mask(), {}
  for i = 1, n do
    local bx = x + floor((hash(i, 1, seed) - .5) * n * 1.4)
    local h = floor(hmax * (.55 + .45 * hash(i, 2, seed)))
    local lean = (hash(i, 3, seed) - .5) * 7
    m:add(line({ { bx, yb }, { bx + lean * .3, yb - h * .5 }, { bx + lean, yb - h } }, 2))
    if hash(i, 4, seed) < .4 then heads[#heads + 1] = { floor(bx + lean * .85), yb - h - 1 } end
  end
  c:rim(m, L.fern.edge)
  m:each(function(xx, yy)
    local t = (yb - yy) / hmax
    local col = t > .6 and L.fern.hi or (t > .25 and L.fern.base or L.fern.shade)
    if hash(xx, yy, seed) < .2 then col = L.fern.shade elseif hash(xx, yy, seed) > .92 then col = L.roof.base end
    if yy >= yb - 1 then col = L.fern.deep end
    px(xx, yy, col)
  end)
  for _, hd in ipairs(heads) do
    local hx, hy = hd[1], hd[2]
    local cm = rect(hx - 1, hy - 5, hx + 1, hy) c:rim(cm, L.timber.edge)
    fill(cm, L.soil.base) vline(hx - 1, hy - 5, hy - 1, L.soil.hi) vline(hx + 1, hy - 4, hy, L.soil.deep) px(hx, hy - 6, L.fern.shade)
  end
end
reeds(352, 236, 9, 18, 21) reeds(374, 262, 8, 20, 22) reeds(156, 268, 8, 16, 23)
-- a gnome hauling a little water cart: a barrel on two wheels, slopping over
do
  local x, yb = 322, 266
  local bar = c:rrect(330, 242, 354, 260, 5)
  local shaft = line({ { 332, 256 }, { 326, 258 } }, 2)
  local wh = c:ellipse(342, 262, 6, 6)
  F.shadowM(c:ellipse(346, 268, 16, 1))
  rimOf(union(bar, shaft, wh), L.timber)
  part(bar, L.timber) F.planks(bar, L.timber, 4, true, 12)
  for _, hy in ipairs({ 245, 256 }) do hline(330, 354, hy, L.iron.shade) hline(331, 353, hy - 1, L.iron.hi) end
  part(shaft, L.board, { nopop = true, noshade = true })
  part(wh, L.timber, { nopop = true }) fill(c:ellipse(342, 262, 3, 3), L.timber.shade)
  vline(342, 257, 267, L.timber.deep) hline(337, 347, 262, L.timber.deep) px(342, 262, L.iron.hi)
  fill(rect(339, 240, 345, 241), Wt.base) px(340, 240, Wt.hi)
  for _, p in ipairs({ { 348, 239 }, { 351, 238 }, { 355, 241 }, { 357, 245 }, { 336, 239 } }) do px(p[1], p[2], Wt.hi) end
  F.gnome(x, yb, { hat = L.roof2, coat = L.wall2, arm = "out" })
end
F.fern(306, 262, 7) F.fern(296, 266, 6) F.fern(364, 268, 6)
-- a dipper (the brook bird) bobbing on the bridge coping: dark brown, white bib
F.sprite({ "..kkk.....", ".kKKKk....", "bWKKKKKkt.", "bWWKKKKKkt", ".WcKKKKkt.", "..kKKKkk..", "...l.l...." }, floor(F.xr(230)) + 1, 209,
  { k = "#4e3c38", K = "#64504a", W = L.awnB.hi, c = "#8a5440", t = "#3a2c2c", l = L.timber.edge, b = L.timber.edge })
-- dragonflies over the water: blue, a red one and a green one
for i, d in ipairs({ { 296, 222 }, { 176, 238 }, { 120, 234 }, { 64, 226 }, { 360, 222 } }) do
  local x, y = d[1], d[2]
  local body = ({ L.accent, L.apple, L.fern, L.accent, L.lav })[i]
  hline(x - 3, x + 3, y, Wt.hi) px(x - 2, y - 1, GL) px(x + 2, y - 1, GL)
  vline(x, y - 1, y + 4, body.shade) px(x, y - 1, body.hi) px(x, y + 4, body.deep)
end

---------------------------------------------------------------- cool mist lying on the water (solid dithered streaks)
brook:each(function(x, y)
  local band = (y + floor(sin(x / 17) * 2)) % 9
  if band < 2 and hash(x // 11, y // 9, 90) < .55 and (band == 0 or (x + y) % 2 == 0) then
    local v = c:get(x, y)
    if v == Wt.hi or v == Wt.base or v == Wt.shade or v == F.mix(Wt.hi, Wt.base, .5) then px(x, y, band == 0 and L.mist2 or L.mist) end
  end
end)

F.depth(0)
F.birds({ { 330, 44, 2 }, { 340, 50, 1 }, { 168, 60, 2 }, { 186, 54, 2 }, { 236, 70, 1 } })
-- fix-up: detail on the bare needle ground between the road and the hamlet
F.depth(3)
F.fern(270, 160, 5) F.fern(294, 176, 4, L.needle) F.fern(262, 190, 5) F.fern(184, 196, 4) F.fern(176, 168, 4, L.needle) F.fern(300, 152, 4)
F.mushroom(280, 168, L.apple, true) F.mushroom(284, 170, L.apple) F.mushroom(190, 184, L.needle) F.mushroom(270, 182, L.needle, true)
for _, p in ipairs({ { 266, 172 }, { 288, 158 }, { 300, 186 }, { 178, 180 }, { 188, 160 }, { 274, 150 }, { 292, 194 } }) do
  px(p[1], p[2], L.soil.base) px(p[1] + 1, p[2], L.soil.shade) px(p[1], p[2] - 1, L.soil.hi) px(p[1] + 1, p[2] + 1, L.soil.deep)
end
for _, p in ipairs({ { 258, 164 }, { 282, 188 }, { 182, 190 } }) do
  fill(rect(p[1], p[2], p[1] + 3, p[2] + 1), L.stone.base) hline(p[1], p[1] + 3, p[2] - 1, L.stone.edge) px(p[1], p[2], L.stone.hi) hline(p[1] + 1, p[1] + 3, p[2] + 2, L.stone.shade)
end
F.finish()
