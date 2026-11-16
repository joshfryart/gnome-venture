-- spring.lua : "Spring" stop look, Maplewold (480x270 gate view). Opus second pass (art-2701 batch 4).
-- Builds on ../haiku/spring.lua. Shared frame: ../../../art-2701-batch3/stops/opus3/_frame.lua (read-only).
-- Read: the right is a big mossy rock outcrop with a dressed-stone face and a carved stone gnome head; spring water
-- arcs from its mouth into a wide stone basin and a second trickle runs from a crack into a gnome's pail. The basin
-- overflows into a brook that winds down-left, under a little stone bridge on the road, into a lily pond in the
-- bottom-left corner. Left: a roofed well-head with a gnome winding the bucket up, birches, a far cottage. A gnome
-- carries two pails on a yoke down the road, another does the washing at the pond. Road's end: a hazed hamlet.
-- Quirk: a big green frog in a red gnome hat sits on a lily pad in the basin, eyes shut, taking a shower under the spout.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch4/stops/opus2/"
local F = dofile("/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus3/_frame.lua")
  .build{ name = "spring", out = DIR, farTrees = { 22, 60, 104, 150, 330, 372, 452 },
    clouds = { { 130, 42, 40 }, { 280, 30, 46 }, { 400, 58, 34 }, { 54, 78, 24 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix = F.mix
local Wt = L.water
local birch = F.rp("#fff2dc #ece0cc #c8b8a8 #8e7c78 #5a4a50")
local moss = F.rp("#d4e080 #a4c05a #78983e #56743a #36502c")
local rock = F.rp("#f2e4cc #cdbda6 #a7958a #7c6b70 #4e4054") -- warm grey field stone
local sand = F.rp("#fff0d0 #ead2a8 #c9aa84 #9a7c6a #64505a") -- dressed sandstone

---------------------------------------------------------------- back row: a hamlet at the road's end
F.depth(1)
F.building{ x0 = 196, x1 = 228, yb = 126, wh = 13, rh = 10, wall = L.plaster, roof = L.roof2, noFrame = true, noAttic = true, chimney = true }
F.window(204, 117, 208, 120, L.timber)
F.smoke(219, 98, 4, .5, 2)
do -- a little chapel with a spire right of the road
  local wall = rect(254, 112, 278, 126)
  local roof = poly{ { 251, 113 }, { 266, 103 }, { 281, 113 } }
  local tower = rect(256, 96, 263, 112)
  local spire = poly{ { 255, 97 }, { 259, 82 }, { 264, 97 } }
  rimOf(union(wall, roof, tower, spire), L.stone)
  part(wall, L.stone) F.courses(wall, 112, 3, 6, L.stone) part(tower, L.stone, { nopop = true })
  part(roof, L.roof2, { nopop = true }) part(spire, L.roof2, { nopop = true })
  fill(c:rrect(258, 99, 261, 104, 1), L.glow.shade) px(259, 81, L.glow.base)
  F.window(270, 116, 273, 120, L.stone, true)
end
F.tree(300, 128, 26, 3)
F.fenceP(120, 132, 190, 127, 6)

---------------------------------------------------------------- mid left: far cottage, birches
F.depth(2)
F.building{ x0 = 24, x1 = 70, yb = 136, wh = 20, rh = 16, wall = L.wall2, roof = L.roof, chimney = true, noAttic = true }
F.window(30, 122, 35, 127, L.timber) F.door(50, 124, 57, 135, L.timber)
F.smoke(61, 88, 6, .5, 2)
local function birchTree(x, yb, h, seed)
  local tr = rect(x - 1, yb - h, x + 1, yb):add(line({ { x, yb - h * .55 }, { x - 7, yb - h * .8 } })):add(line({ { x, yb - h * .45 }, { x + 6, yb - h * .7 } }))
  rimOf(tr, birch) part(tr, birch, { nopop = true })
  for y = yb - h, yb, 3 do if hash(x, y, seed) < .6 then px(x - 1 + floor(hash(y, x, seed) * 3), y, birch.edge) end end
  F.crown(x - 6, yb - h * .82, 9, 7, L.foliage, seed)
  F.crown(x + 5, yb - h * .95, 10, 8, L.foliage, seed + 1)
  F.crown(x + 6, yb - h * .7, 7, 6, L.foliage, seed + 2)
end
birchTree(92, 150, 56, 31)
birchTree(160, 140, 44, 34)
F.tree(124, 146, 40, 6)

---------------------------------------------------------------- right hero: the rock outcrop
F.depth(2)
F.tree(446, 128, 70, 8) -- maple behind the rocks
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
local face = rect(352, 132, 420, 196) -- dressed stone face set into the rock
local mass = poly{ { 294, 212 }, { 298, 172 }, { 312, 132 }, { 346, 106 }, { 388, 96 }, { 432, 98 }, { 466, 110 }, { 470, 212 } }
rockM:add(face):add(mass)
F.shadowM(c:ellipse(380, 214, 92, 5))
rimOf(rockM, rock)
mass:each(function(x, y)
  local v = hash(x, y, 77)
  local h = (hash(x // 5, y // 4, 78) < .5) and rock.shade or rock.deep
  if v < .06 then h = rock.base elseif v > .96 then h = rock.edge end
  px(x, y, h)
end)
for _, b in ipairs(boulders) do
  -- faceted boulder: 7 flat facets around a lit crown, each facet one tone, lit from the upper left
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
    px(x, y, h)
  end)
  c:edgeIn(b.m, rock.edge)
  -- a thick moss cushion on the top, with a ragged hanging lower edge
  b.m:each(function(x, y)
    local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
    local cap = -.45 + .25 * sin(x * .9 + b[5]) + .15 * hash(x, 3, b[5])
    if ny < cap and nx < .7 then
      local v = hash(x, y, 9)
      local edge = not b.m:has(x, y - 1)
      local lt = -(nx * .6 + ny * .8)
      local h = lt > .75 and moss.hi or (lt > .35 and moss.base or moss.shade)
      if v < .12 then h = moss.hi end
      if edge then h = moss.edge end
      px(x, y, h)
      if not (ny + 0.06 < cap) then px(x, y + 1, moss.deep) end
    end
  end)
end
-- the dressed face: ashlar courses, an arched niche
part(face, sand, { inner = false })
F.courses(face, 132, 7, 14, sand)
c:edgeIn(face, sand.edge)
local niche = c:rrect(362, 136, 410, 186, 20):clip(rect(362, 136, 410, 186))
fill(niche, rock.deep) c:edgeIn(niche, sand.edge)
niche:each(function(x, y) if (x - 386) + (y - 160) < -14 then px(x, y, rock.shade) end if hash(x, y, 5) < .04 then px(x, y, rock.edge) end end)
-- voussoir ring round the niche
c:rrect(360, 134, 412, 188, 22):clip(rect(360, 134, 412, 186)):cut(c:rrect(362, 136, 410, 188, 20)):each(function(x, y) px(x, y, ((x + y) % 5 == 0) and sand.deep or sand.hi) end)
-- moss and a fern hanging over the face
for x = 352, 420 do if hash(x, 2, 8) < .6 then local n = 1 + floor(hash(x, 3, 8) * 4) for k = 0, n do px(x, 132 + k, k == 0 and moss.hi or moss.base) end end end
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
  -- carved closed eyes, a big round nose, an O mouth with a bronze pipe
  for _, ex in ipairs({ hx - 6, hx + 6 }) do px(ex - 2, hy - 4, sand.edge) px(ex - 1, hy - 3, sand.edge) px(ex, hy - 3, sand.edge) px(ex + 1, hy - 3, sand.edge) px(ex + 2, hy - 4, sand.edge) end
  local nose = c:ellipse(hx, hy - 1, 4, 3) c:rim(nose, sand.deep) part(nose, sand, { nopop = true }) px(hx - 2, hy - 3, sand.hi) px(hx - 1, hy - 3, sand.hi)
  px(hx - 9, hy - 1, sand.shade) px(hx + 9, hy - 1, sand.shade)
  local pipe = rect(hx - 2, hy + 4, hx + 4, hy + 7) c:rim(pipe, L.timber.edge) fill(pipe, L.glow.shade) hline(hx - 2, hx + 4, hy + 4, L.glow.base) fill(rect(hx + 3, hy + 5, hx + 4, hy + 6), Wt.deep)
  -- moss on the hat and a few drips
  for x = hx - 4, hx + 8 do px(x, hy - 21 + floor(abs(x - hx - 2) * .6), moss.base) px(x, hy - 22 + floor(abs(x - hx - 2) * .6), moss.hi) end
end
-- the jet: an arc from the mouth down into the basin, splash at the bottom
local JX0, JY0 = 391, 164
local function jetY(x) local t = (x - JX0) / 18 return JY0 + floor(t * t * 22 + t * 2) end
for x = JX0, JX0 + 17 do
  local y0, y1 = jetY(x), jetY(x + 1)
  for y = y0, math.max(y0 + 3, y1 + 1) do px(x, y, Wt.base) px(x + 1, y, Wt.base) px(x + 2, y, Wt.shade) end
  px(x, y0, Wt.hi) px(x, y0 - 1, Wt.edge)
  if x % 3 == 0 then px(x + 1, y0 + 1, "#fff0d0") end
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
  -- moss creeping up the basin wall
  for x = BX - 40, BX + 40 do if hash(x, 4, 12) < .45 then local n = floor(hash(x, 5, 12) * 4) for k = 0, n do px(x, BY + 8 - k, k == n and moss.hi or moss.base) end end end
end
-- the trickle from a crack in the rock into a gnome's pail (left of the face)
do
  local cx, cy = 334, 168
  fill(line({ { cx - 3, cy - 4 }, { cx, cy } }, 2), L.stone.edge)
  for y = cy, 196 do px(cx + floor((y - cy) * .1), y, ((y // 2) % 2 == 0) and Wt.hi or Wt.base) end
  local _, hx, hy = F.gnome(318, 218, { hat = L.awnA, coat = L.lav, arm = "out" })
  local pail = poly{ { hx + 1, hy - 7 }, { hx + 10, hy - 7 }, { hx + 9, hy + 3 }, { hx + 2, hy + 3 } }
  c:rim(pail, L.timber.edge) part(pail, L.board) hline(hx + 1, hx + 10, hy - 5, L.iron.shade) hline(hx + 2, hx + 9, hy + 1, L.iron.shade)
  hline(hx + 2, hx + 9, hy - 7, Wt.hi) px(hx + 5, hy - 8, "#fff0d0") px(hx + 8, hy - 9, Wt.hi)
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
  }, 400, 181, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.roof.hi, G = L.leaf.base, g = L.leaf.shade,
    d = L.leaf.deep, e = L.leaf.deep, k = L.timber.edge, m = L.apple.shade, y = L.roof.hi })
  -- splash on the hat
  for _, p in ipairs({ { 409, 176 }, { 405, 178 }, { 413, 177 }, { 402, 181 }, { 416, 182 }, { 411, 173 } }) do px(p[1], p[2], Wt.hi) end
  px(407, 175, "#fff0d0") px(414, 175, "#fff0d0")
end
-- overflow notch and the brook winding down-left under the road into the pond
local brook = HP.mask()
do
  local pts = { { 356, 208 }, { 330, 216 }, { 300, 224 }, { 268, 232 }, { 236, 238 }, { 200, 242 }, { 168, 246 }, { 140, 248 } }
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local w = 6 + floor(i * 1.2)
    brook:add(line({ a, b }, w))
  end
  local pond = c:ellipse(84, 252, 76, 18):clip(rect(19, 230, 200, 269))
  brook:add(pond)
end
local onRoad = HP.mask()
brook:each(function(x, y) if F.roadM:has(x, y) then onRoad:set(x, y) end end)
brook:cut(onRoad)
do
  local bank = brook:grow(2):cut(brook):cut(F.roadM)
  bank:each(function(x, y) px(x, y, hash(x, y, 51) < .5 and L.stone.base or moss.base) end)
  brook:edge():each(function(x, y) if hash(x, y, 52) < .3 then px(x, y, L.stone.hi) end end)
  F.water(brook, Wt, { step = 3 })
  -- spill over the basin lip
  for y = 204, 210 do px(354 + (y - 204) // 3, y, Wt.hi) px(355 + (y - 204) // 3, y, Wt.base) end
end
-- the little bridge: stone parapets along both road edges over the brook
do
  local par = HP.mask()
  for y = 228, 252 do
    local xl, xr = floor(F.xl(y)), floor(F.xr(y) + .99)
    par:add(rect(xl - 5, y - 8, xl + 1, y)):add(rect(xr - 1, y - 8, xr + 5, y))
  end
  par:clip(rect(0, 222, 479, 252))
  rimOf(par, L.stone) part(par, L.stone, { nopop = true })
  F.courses(par, 220, 4, 6, L.stone)
  par:each(function(x, y) if not par:has(x, y - 1) then px(x, y, L.stone.hi) end end)
  -- dark arch mouths where the brook passes under
  for _, a in ipairs({ { floor(F.xl(246)) - 4, 250 }, { floor(F.xr(238)) + 2, 242 } }) do
    local arch = c:ellipse(a[1], a[2], 4, 4):clip(rect(a[1] - 4, a[2] - 4, a[1] + 4, a[2]))
    fill(arch, Wt.deep) arch:edge():each(function(x, y) if y < a[2] then px(x, y, L.stone.deep) end end)
  end
end

---------------------------------------------------------------- left: well-head with a gnome winding the bucket
F.depth(3)
do
  local x0, x1, yb = 52, 104, 204
  local wall = c:rrect(x0, yb - 18, x1, yb, 3)
  local postL, postR = rect(x0 + 4, yb - 52, x0 + 7, yb - 18), rect(x1 - 7, yb - 52, x1 - 4, yb - 18)
  local roof = poly{ { x0 - 6, yb - 48 }, { (x0 + x1) // 2, yb - 66 }, { x1 + 6, yb - 48 } }:add(rect(x0 - 6, yb - 49, x1 + 6, yb - 46))
  local axle = rect(x0 + 4, yb - 36, x1 - 4, yb - 34)
  local crank = line({ { x1 - 2, yb - 35 }, { x1 + 4, yb - 35 }, { x1 + 4, yb - 29 } }, 2)
  F.shadow(x0 + 2, x1, yb, 12, 4)
  rimOf(union(wall, postL, postR, roof, axle, crank), L.timber)
  part(wall, L.stone) F.courses(wall, yb - 18, 5, 9, L.stone)
  hline(x0 + 2, x1 - 2, yb - 18, L.stone.hi)
  for x = x0, x1 do if hash(x, 7, 61) < .4 then px(x, yb, moss.base) px(x, yb - 1, moss.hi) end end
  part(postL, L.timber, { nopop = true }) part(postR, L.timber, { nopop = true })
  part(roof, L.roof2, { sep = true }) F.courses(roof, yb - 66, 3, 5, L.roof2)
  line({ { x0 - 6, yb - 48 }, { (x0 + x1) // 2, yb - 66 } }):each(function(x, y) px(x, y, L.roof2.hi) end)
  part(axle, L.timber, { nopop = true, noshade = true })
  fill(rect((x0 + x1) // 2 - 4, yb - 37, (x0 + x1) // 2 + 4, yb - 33), L.board.base) -- rope wound on the axle
  for x = (x0 + x1) // 2 - 4, (x0 + x1) // 2 + 4, 2 do vline(x, yb - 37, yb - 33, L.board.shade) end
  part(crank, L.iron, { nopop = true, noshade = true })
  -- rope down to the bucket coming up, dripping
  local bx = (x0 + x1) // 2
  vline(bx, yb - 32, yb - 26, L.board.deep)
  local bk = poly{ { bx - 5, yb - 25 }, { bx + 5, yb - 25 }, { bx + 4, yb - 17 }, { bx - 4, yb - 17 } }
  c:rim(bk, L.timber.edge) part(bk, L.board) hline(bx - 5, bx + 5, yb - 23, L.iron.shade) hline(bx - 4, bx + 4, yb - 25, Wt.hi)
  px(bx + 4, yb - 14, Wt.hi) px(bx - 3, yb - 12, Wt.base)
  local _, hx, hy = F.gnome(x1 + 14, yb + 4, { hat = L.roof, coat = L.accent, arm = "up", flip = true })
  fill(line({ { hx, hy }, { x1 + 4, yb - 29 } }), L.skin.base)
end

---------------------------------------------------------------- road: gnome with two pails on a yoke; a spring sign
F.depth(3)
do
  local x, yb = 262, 212
  local _, hx, hy = F.gnome(x, yb, { hat = L.leaf, coat = L.roof2, arm = "hold" })
  local yoke = line({ { x - 16, yb - 12 }, { x, yb - 14 }, { x + 16, yb - 12 } }, 2)
  c:rim(yoke, L.timber.edge) part(yoke, L.board, { nopop = true, noshade = true })
  for _, sx in ipairs({ -16, 16 }) do
    vline(x + sx, yb - 11, yb - 6, L.board.deep)
    local p = poly{ { x + sx - 5, yb - 6 }, { x + sx + 5, yb - 6 }, { x + sx + 4, yb + 2 }, { x + sx - 4, yb + 2 } }
    c:rim(p, L.timber.edge) part(p, L.board) hline(x + sx - 5, x + sx + 5, yb - 4, L.iron.shade) hline(x + sx - 4, x + sx + 4, yb - 6, Wt.hi)
    px(x + sx + 3, yb + 4, Wt.hi)
  end
  -- wet footprints behind
  for i = 1, 4 do px(x - 2 + (i % 2) * 4, yb - 6 - i * 7, L.road.shade) end
end
do -- the spring sign: a blue drop on a board
  local post = rect(206, 168, 207, 196)
  local bd = rect(194, 156, 220, 170)
  rimOf(union(post, bd), L.timber) part(post, L.timber, { nopop = true }) part(bd, L.board, { nopop = true }) c:edgeIn(bd, L.board.deep)
  local drop = poly{ { 207, 158 }, { 211, 164 }, { 203, 164 } }:add(c:ellipse(207, 165, 4, 3))
  c:rim(drop, Wt.edge) fill(drop, Wt.base) px(205, 164, Wt.hi) px(205, 165, "#fff0d0") hline(206, 209, 168, Wt.shade)
end

---------------------------------------------------------------- a jug stall by the sign: clay jugs of spring water, a seller behind
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
  -- a cup of water held out
end

---------------------------------------------------------------- mid: a log bench under the birches, a far gnome on the road, path stones
F.depth(2)
do
  local lg = rect(112, 158, 146, 162) rimOf(lg, L.timber) part(lg, L.timber, { nopop = true })
  for x = 114, 144, 6 do px(x, 160, L.timber.deep) end fill(c:ellipse(112, 160, 2, 2), L.board.base) px(112, 160, L.board.shade)
  F.gnome(124, 160, { small = true, hat = L.roof2, coat = L.leaf, arm = "out", noShadow = true })
  F.gnome(136, 160, { small = true, hat = L.accent, coat = L.awnA, flip = true, noShadow = true })
  F.gnome(238, 146, { small = true, hat = L.lav, coat = L.roof, arm = "out" })
  px(248, 139, L.roof2.base) px(248, 140, L.roof2.shade)
end
F.depth(3)
for _, s in ipairs({ { 200, 206 }, { 186, 210 }, { 170, 212 }, { 150, 210 }, { 132, 208 } }) do
  local m = c:ellipse(s[1], s[2], 5, 2) rimOf(m, L.stone) part(m, L.stone, { nopop = true }) px(s[1] - 2, s[2] - 1, L.stone.hi)
end

---------------------------------------------------------------- right of the road: a small gnome with a jug, hazel bushes
F.depth(2)
F.bush(278, 150, 14, 12, L.leaf, 61) F.bush(298, 146, 10, 10, L.foliage, 62)
F.depth(3)
do
  local _, hx, hy = F.gnome(286, 192, { hat = L.awnA, coat = L.accent, arm = "hold" })
  local jug = c:rrect(hx - 2, hy - 6, hx + 3, hy + 1, 2) c:rim(jug, L.timber.edge) part(jug, L.roof2, { nopop = true }) px(hx - 1, hy - 5, L.roof2.hi)
end

---------------------------------------------------------------- the pond: lily pads, reeds, a gnome doing the washing
F.depth(3)
for _, p in ipairs({ { 60, 246 }, { 98, 258 }, { 124, 246 }, { 40, 260 }, { 150, 254 } }) do
  local pad = c:ellipse(p[1], p[2], 6, 2):cut(poly{ { p[1], p[2] }, { p[1] + 7, p[2] - 2 }, { p[1] + 7, p[2] + 1 } })
  fill(pad, L.leaf.base) px(p[1] - 4, p[2] - 1, L.leaf.hi) px(p[1] + 2, p[2] + 1, L.leaf.deep)
end
for _, f in ipairs({ { 98, 256 }, { 40, 258 } }) do
  fill(rect(f[1] - 1, f[2] - 3, f[1] + 1, f[2] - 2), L.awnA.hi) px(f[1], f[2] - 4, "#fff0d0") px(f[1] - 2, f[2] - 2, L.awnA.base) px(f[1] + 2, f[2] - 2, L.awnA.base)
end
do -- cattails at the pond's left
  local m = HP.mask()
  for i = 0, 8 do
    local x = 22 + i * 3 + (i % 2)
    local h = 12 + floor(hash(i, 4, 3) * 12)
    m:add(line({ { x, 248 }, { x + (i % 3) - 1, 248 - h } }, 2))
  end
  c:rim(m, L.leaf.edge)
  m:each(function(x, y) px(x, y, hash(x, y, 4) < .3 and L.leaf.shade or (y < 236 and L.leaf.hi or L.leaf.base)) end)
  for i = 0, 8, 2 do
    local x = 22 + i * 3 + (i % 2) + (i % 3) - 1
    local h = 12 + floor(hash(i, 4, 3) * 12)
    local cm = rect(x, 248 - h - 6, x + 2, 248 - h - 1) c:rim(cm, L.timber.edge) fill(cm, L.timber.base) vline(x, 248 - h - 6, 248 - h - 2, L.timber.hi)
  end
end
do -- the washer gnome on a flat stone with a basket of laundry and a washboard
  local st = c:ellipse(170, 236, 12, 3) rimOf(st, L.stone) part(st, L.stone, { nopop = true })
  local _, hx, hy = F.gnome(168, 232, { hat = L.awnB, coat = L.leaf, arm = "out", flip = true, noShadow = true })
  local wb = rect(hx - 6, hy - 6, hx, hy + 4) c:rim(wb, L.timber.edge) part(wb, L.board, { nopop = true })
  for y = hy - 4, hy + 3, 2 do hline(hx - 5, hx - 1, y, L.board.deep) end
  for k = 0, 2 do hline(hx - 12 - k * 2, hx - 6 + k * 2, hy + 7 + k * 2, Wt.hi) end
  local bsk = c:rrect(184, 222, 202, 234, 3) rimOf(bsk, L.board) part(bsk, L.roof)
  bsk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.roof.shade) end end)
  fill(c:ellipse(189, 221, 4, 2), L.accent.base) fill(c:ellipse(196, 220, 4, 2), L.awnA.base) px(194, 219, L.awnA.hi) px(187, 220, L.accent.hi)
end

---------------------------------------------------------------- ferns, forget-me-nots and mushrooms round the rocks
F.depth(3)
local function fern(x, yb, s, seed)
  for k = -2, 2 do
    local a = k * .45 - pi / 2
    local len = s - abs(k) * 2
    local px0, py0 = x, yb
    for t = 0, len do
      local fx = floor(px0 + cos(a + t * .04 * k) * t + .5)
      local fy = floor(py0 + sin(a) * t + t * t * .02 * abs(k) + .5)
      px(fx, fy, t < 2 and L.leaf.deep or L.leaf.base)
      if t % 2 == 0 and t > 1 then px(fx - 1, fy + 1, L.leaf.shade) px(fx + 1, fy + 1, (t > len - 3) and L.leaf.hi or L.leaf.shade) end
    end
  end
end
fern(292, 214, 12, 1) fern(306, 222, 10, 2) fern(452, 214, 12, 3) fern(346, 220, 9, 4) fern(120, 208, 10, 5)
-- forget-me-not clumps: leaves then blue five-dot flowers
for i = 0, 9 do
  local x, y = 300 + floor(hash(i, 1, 71) * 160), 220 + floor(hash(i, 2, 71) * 12)
  if not F.roadM:has(x, y) then
    for k = -3, 3 do px(x + k, y + 1, L.leaf.shade) if k % 2 == 0 then px(x + k, y, L.leaf.base) end end
    for _, d in ipairs({ { -2, -1 }, { 1, -2 }, { 3, -1 } }) do
      local fx, fy = x + d[1], y + d[2]
      px(fx, fy, Wt.base) px(fx - 1, fy, Wt.shade) px(fx + 1, fy, Wt.shade) px(fx, fy - 1, Wt.hi) px(fx, fy + 1, Wt.shade)
      px(fx, fy, L.roof.hi)
    end
  end
end
for _, m in ipairs({ { 440, 226 }, { 446, 228 }, { 300, 230 } }) do
  local cap = c:ellipse(m[1], m[2] - 4, 3, 2) local stem = rect(m[1] - 1, m[2] - 2, m[1], m[2])
  c:rim(union(cap, stem), L.timber.edge) fill(stem, L.awnB.base) part(cap, L.apple, { nopop = true }) px(m[1] - 1, m[2] - 5, L.awnB.hi) px(m[1] + 1, m[2] - 4, L.awnB.hi)
end
-- a fallen-leaf path of stepping stones from the road to the basin
for i, s in ipairs({ { 292, 206 }, { 306, 202 }, { 322, 204 } }) do
  local m = c:ellipse(s[1], s[2], 5, 2) rimOf(m, L.stone) part(m, L.stone, { nopop = true }) px(s[1] - 2, s[2] - 1, L.stone.hi)
end

F.depth(0)
F.birds({ { 330, 44, 2 }, { 340, 50, 1 }, { 168, 60, 2 }, { 186, 54, 2, L.awnB.hi } })
F.finish()
