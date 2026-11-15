-- shrine.lua : "Wayside shrine" stop look, Maplewold (480x270 gate view). Opus second pass.
-- Read: a red torii spanning the road, a flared-roof shrine hall on a stone terrace at the road's end, paired stone
-- lanterns receding along the road, a three-tier pagoda, a purification basin pavilion, a bell frame, the roped
-- sacred maple, an ema plaque rack and a raked gravel garden. Quirk: a real fox kit peeking beside the stone fox.
-- opus3 richness pass: depth planes, copper-tile roofs, plank grain, basin water with koi, incense smoke, crows,
-- three working gnomes (sweeping, ringing the bell, hanging an ema). The fox kit now wears the stone fox's red bib.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus3/"
local F = dofile(DIR .. "_frame.lua").build{ name = "shrine", out = DIR, farTrees = { 24, 150, 300, 318, 352, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local RED, GRN = L.awnA, L.accent

-- flared roof: eave from x0..x1 at y (bottom), ridge from rx0..rx1 at yt; tips curl up
local function flare(x0, x1, y, rx0, rx1, yt, r)
  local m = poly{ { x0 - 2, y - 3 }, { x0 + 4, y - 1 }, { rx0, yt }, { rx1, yt }, { x1 - 4, y - 1 }, { x1 + 2, y - 3 }, { x1 - 2, y + 2 }, { x0 + 2, y + 2 } }
  rimOf(m, r) part(m, r, { sep = true })
  m:each(function(x, yy)
    if yy < y then
      local k = x % 4
      if k == 0 then px(x, yy, r.deep) elseif k == 1 then px(x, yy, r.hi) elseif (yy - yt) % 5 == 4 then px(x, yy, r.shade) end
      if F.hash(x // 4, yy // 5, 81) < .08 then px(x, yy, L.leaf.base) end -- moss on old tiles
    end
  end)
  hline(rx0, rx1, yt, r.hi)
  hline(x0 + 2, x1 - 2, y + 2, r.deep) hline(x0 + 2, x1 - 2, y + 1, r.shade)
  return m
end

---------------------------------------------------------------- back-left: three-tier pagoda
local function pagoda(cx, yb)
  F.shadow(cx - 16, cx + 16, yb, 8, 3)
  local base = rect(cx - 18, yb - 4, cx + 18, yb)
  rimOf(base, L.stone) part(base, L.stone) F.courses(base, yb - 4, 5, 8, L.stone)
  local y = yb - 4
  for i = 0, 2 do
    local w = 13 - i * 3
    local body = rect(cx - w, y - 11, cx + w, y)
    rimOf(body, RED) part(body, RED)
    for x = cx - w + 3, cx + w - 2, 4 do vline(x, y - 9, y - 1, RED.deep) end
    hline(cx - w, cx + w, y - 11, L.plaster.base) hline(cx - w, cx + w, y - 10, L.plaster.shade)
    F.window(cx - 1, y - 8, cx + 1, y - 5, L.timber)
    y = y - 11
    flare(cx - w - 9, cx + w + 9, y, cx - w + 1, cx + w - 1, y - 7, GRN)
    y = y - 7
  end
  local spire = rect(cx - 1, y - 16, cx, y)
  rimOf(spire, L.roof) part(spire, L.roof, { nopop = true, noshade = true })
  for k = 0, 3 do hline(cx - 2, cx + 1, y - 4 - k * 3, L.roof.shade) end
  px(cx, y - 17, L.glow.hi)
end
F.depth(1)
F.tree(86, 124, 40, 4)
pagoda(48, 134)

---------------------------------------------------------------- the road's end: terrace, steps, shrine hall
F.depth(2)
local terr = poly{ { 188, 126 }, { 292, 126 }, { 288, 112 }, { 192, 112 } }
F.shadow(190, 292, 128, 8, 3)
rimOf(terr, L.stone) part(terr, L.stone) F.courses(terr, 112, 5, 12, L.stone)
-- steps up the middle
for k = 0, 4 do
  local y = 124 - k * 3
  local m = rect(228 + k, y, 252 - k, y + 2)
  fill(m, L.road.base) hline(228 + k, 252 - k, y, L.road.hi) hline(228 + k, 252 - k, y + 2, L.road.deep)
end
-- hall
local hall = rect(204, 92, 276, 112)
rimOf(hall, L.plaster) part(hall, L.plaster) F.planks(hall, L.plaster, 4, false, 21)
for _, x in ipairs({ 204, 216, 228, 252, 264, 274 }) do fill(rect(x, 92, x + 2, 112), RED.base) vline(x, 92, 112, RED.hi) vline(x + 2, 92, 112, RED.shade) end
-- latticed doors, open middle
for _, d in ipairs({ { 218, 226 }, { 254, 262 } }) do
  local m = rect(d[1], 96, d[2], 110) fill(m, L.board.base)
  m:each(function(x, y) if (x - d[1]) % 3 == 0 or (y - 96) % 3 == 0 then px(x, y, L.board.deep) end end)
end
fill(rect(231, 96, 249, 112), L.soil.deep)
fill(rect(236, 101, 244, 108), L.glow.shade) fill(rect(238, 102, 242, 106), L.glow.base) px(239, 102, L.glow.hi) -- altar glow
-- offering box
local box = rect(232, 106, 248, 112) rimOf(box, L.timber) part(box, L.timber) for x = 234, 246, 3 do px(x, 107, L.timber.deep) end
-- big flared roof + bell rope
flare(188, 292, 90, 214, 266, 66, GRN)
local ridge = rect(212, 62, 268, 66) rimOf(ridge, GRN) part(ridge, GRN, { nopop = true }) hline(212, 268, 62, GRN.hi)
fill(rect(208, 58, 214, 66), GRN.base) fill(rect(266, 58, 272, 66), GRN.base) px(208, 58, GRN.hi) px(266, 58, GRN.hi)
local gab = poly{ { 228, 88 }, { 240, 72 }, { 252, 88 } } fill(gab, RED.base) c:edgeIn(gab, RED.deep) fill(c:ellipse(240, 82, 2, 2), L.roof.base) px(239, 81, L.roof.hi)
vline(240, 91, 104, RED.base) vline(241, 91, 104, L.awnB.base)
local bell = c:ellipse(240, 93, 2, 2) fill(bell, L.roof.base) px(239, 92, L.roof.hi)
-- shimenawa rope across the front with paper zigzags
for x = 206, 274 do px(x, 94 + floor(2 * sin((x - 206) / 68 * pi)), L.roof.shade) px(x, 95 + floor(2 * sin((x - 206) / 68 * pi)), L.roof.base) end
for _, x in ipairs({ 214, 226, 254, 266 }) do
  local y = 97 + floor(2 * sin((x - 206) / 68 * pi))
  fill(line({ { x, y }, { x + 2, y + 2 }, { x, y + 4 }, { x + 2, y + 6 } }), L.awnB.hi)
end

---------------------------------------------------------------- right back: sacred maple + bell frame
local function sacredTree()
  local trunk = poly{ { 400, 160 }, { 404, 120 }, { 400, 96 }, { 416, 96 }, { 414, 120 }, { 420, 160 } }
  F.shadow(396, 430, 162, 10, 4)
  rimOf(trunk, L.timber) part(trunk, L.timber)
  trunk:each(function(x, y) if (x * 3 + y) % 11 == 0 then px(x, y, L.timber.deep) end end)
  local brs = line({ { 404, 104 }, { 386, 84 } }, 3):add(line({ { 412, 100 }, { 432, 82 } }, 3))
  rimOf(brs, L.timber) part(brs, L.timber, { nopop = true })
  F.crown(372, 70, 30, 20, L.foliage2, 31) F.crown(440, 66, 28, 20, L.foliage, 32) F.crown(408, 52, 34, 22, L.foliage2, 33)
  F.crown(436, 92, 24, 14, L.foliage2, 34) F.crown(376, 96, 22, 12, L.foliage, 35)
  -- roped trunk
  for x = 400, 420 do px(x, 128 + (x - 400) // 7, L.roof.shade) px(x, 129 + (x - 400) // 7, L.roof.base) px(x, 130 + (x - 400) // 7, L.roof.shade) end
  for _, x in ipairs({ 403, 409, 415 }) do local y = 131 + (x - 400) // 7 fill(line({ { x, y }, { x + 2, y + 2 }, { x, y + 4 }, { x + 2, y + 6 } }), L.awnB.hi) end
end
local function bellFrame(x0, yb)
  local posts = rect(x0, yb - 34, x0 + 2, yb):add(rect(x0 + 30, yb - 34, x0 + 32, yb))
  local roofm = poly{ { x0 - 8, yb - 34 }, { x0 + 4, yb - 44 }, { x0 + 28, yb - 44 }, { x0 + 40, yb - 34 }, { x0 + 38, yb - 31 }, { x0 - 6, yb - 31 } }
  local bm = poly{ { x0 + 11, yb - 28 }, { x0 + 21, yb - 28 }, { x0 + 23, yb - 12 }, { x0 + 9, yb - 12 } }:add(c:rrect(x0 + 11, yb - 31, x0 + 21, yb - 25, 3))
  F.shadow(x0, x0 + 34, yb, 8, 3)
  rimOf(union(posts, roofm, bm), L.timber)
  part(posts, L.timber, { nopop = true })
  part(roofm, GRN) hline(x0 - 6, x0 + 38, yb - 31, GRN.deep)
  part(bm, L.roof) -- bronze
  hline(x0 + 10, x0 + 22, yb - 20, L.roof.deep) hline(x0 + 9, x0 + 23, yb - 13, L.roof.deep)
  for y = yb - 27, yb - 22, 2 do for x = x0 + 13, x0 + 19, 2 do px(x, y, L.roof.hi) end end
  -- striker log on ropes
  local log = rect(x0 + 24, yb - 22, x0 + 38, yb - 19) rimOf(log, L.timber) part(log, L.board, { nopop = true })
  vline(x0 + 27, yb - 31, yb - 23, L.timber.edge) vline(x0 + 35, yb - 31, yb - 23, L.timber.edge)
end
sacredTree()
bellFrame(300, 140)
-- a gnome swinging the bell striker
local _, rx, ry = F.gnome(352, 142, { hat = L.lav, coat = L.roof, arm = "up", flip = true })
line({ { rx, ry }, { 337, 121 } }):each(function(x, y) px(x, y, L.timber.edge) end)

---------------------------------------------------------------- the torii over the road
local function torii()
  local postL, postR = rect(204, 122, 209, 198), rect(271, 122, 276, 198)
  local kasagi = poly{ { 184, 110 }, { 194, 114 }, { 286, 114 }, { 296, 110 }, { 294, 118 }, { 186, 118 } }
  local shimaki = rect(192, 119, 288, 122)
  local nuki = rect(198, 132, 282, 136)
  local plaque = rect(234, 122, 246, 131)
  local feet = rect(202, 196, 211, 199):add(rect(269, 196, 278, 199))
  F.shadow(204, 280, 199, 10, 4)
  local sil = union(postL, postR, kasagi, shimaki, nuki, plaque, feet)
  rimOf(sil, RED)
  part(postL, RED) part(postR, RED)
  vline(205, 124, 194, RED.hi) vline(272, 124, 194, RED.hi)
  part(nuki, RED, { nopop = true })
  part(shimaki, RED, { nopop = true })
  part(kasagi, L.timber, { nopop = true }) hline(194, 286, 114, L.timber.hi) hline(186, 294, 117, L.timber.deep)
  part(feet, L.stone, { nopop = true })
  part(plaque, L.timber) c:edgeIn(plaque, L.roof.base)
  px(239, 125, L.roof.hi) px(241, 127, L.roof.hi) px(239, 128, L.roof.base)
end

---------------------------------------------------------------- stone lantern (toro), scaled by depth
local function toro(x, yb, s)
  local function R(a, b, cc, d) return rect(floor(x + a * s), floor(yb + b * s), floor(x + cc * s), floor(yb + d * s)) end
  local base = R(-5, -3, 5, 0)
  local post = R(-2, -14, 2, -3)
  local fire = R(-5, -21, 5, -14)
  local cap = poly{ { x - 8 * s, yb - 21 * s }, { x - 3 * s, yb - 26 * s }, { x + 3 * s, yb - 26 * s }, { x + 8 * s, yb - 21 * s }, { x + 7 * s, yb - 20 * s }, { x - 7 * s, yb - 20 * s } }
  local knob = R(-1, -29, 1, -26)
  F.shadow(floor(x - 4 * s), floor(x + 5 * s), yb, floor(5 * s), floor(2 * s))
  rimOf(union(base, post, fire, cap, knob), L.stone)
  part(base, L.stone) part(post, L.stone, { nopop = true }) part(fire, L.stone, { sep = true })
  local win = R(-2, -19, 2, -16) fill(win, L.glow.base) px(floor(x - 2 * s), floor(yb - 19 * s), L.glow.hi)
  part(cap, L.stone, { sep = true }) part(knob, L.stone, { nopop = true })
  -- moss on the cap
  cap:each(function(xx, y) if hash(xx, y, 61) < .25 then px(xx, y, L.leaf.base) end end)
end

---------------------------------------------------------------- left hero: purification basin pavilion
local function chozuya()
  local x0, x1, yt, yb = 96, 184, 150, 214
  local posts = rect(x0 + 6, yt + 8, x0 + 9, yb):add(rect(x1 - 9, yt + 8, x1 - 6, yb))
  F.shadow(x0 + 6, x1, yb, 12, 5)
  rimOf(posts, L.timber) part(posts, L.timber, { nopop = true })
  flare(x0 - 6, x1 + 6, yt + 8, x0 + 16, x1 - 16, yt - 14, GRN)
  local rid = rect(x0 + 14, yt - 18, x1 - 14, yt - 14) rimOf(rid, GRN) part(rid, GRN, { nopop = true })
  local tri = poly{ { 128, yt + 4 }, { 140, yt - 10 }, { 152, yt + 4 } } fill(tri, RED.base) c:edgeIn(tri, RED.deep)
  -- stone basin
  local front = rect(112, 190, 168, 208)
  local topm = poly{ { 108, 190 }, { 172, 190 }, { 168, 182 }, { 112, 182 } }
  rimOf(union(front, topm), L.stone)
  part(front, L.stone) F.courses(front, 190, 9, 14, L.stone, 3)
  part(topm, L.stone, { sep = true })
  local wat = poly{ { 114, 188 }, { 166, 188 }, { 163, 184 }, { 117, 184 } } F.water(wat, L.water, { step = 2 })
  for _, k in ipairs({ { 124, 186 }, { 144, 185 } }) do px(k[1], k[2], L.produce.base) px(k[1] + 1, k[2], L.produce.hi) px(k[1] + 2, k[2], L.awnB.hi) px(k[1] - 1, k[2], L.produce.shade) end -- koi
  -- bamboo spout with a trickle
  local sp = rect(150, 168, 172, 170):add(rect(170, 168, 172, 190))
  rimOf(sp, L.leaf) part(sp, L.leaf, { nopop = true, noshade = true }) px(160, 168, L.leaf.deep) px(171, 178, L.leaf.deep)
  vline(150, 171, 184, L.water.hi) vline(151, 172, 184, L.water.base)
  -- ladles laid across
  for k = 0, 2 do
    local lx = 118 + k * 10
    fill(line({ { lx, 181 }, { lx + 10, 178 } }), L.board.base)
    local cup = rect(lx - 2, 180, lx + 1, 183) fill(cup, L.board.shade) px(lx - 2, 180, L.board.hi)
  end
end

---------------------------------------------------------------- right hero: ema rack + fox statue
local function emaRack()
  local x0, x1, yt, yb = 300, 384, 160, 214
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb))
  local roofm = poly{ { x0 - 6, yt }, { x0 + 4, yt - 8 }, { x1 - 4, yt - 8 }, { x1 + 6, yt }, { x1 + 4, yt + 3 }, { x0 - 4, yt + 3 } }
  local rails = rect(x0, 172, x1, 173):add(rect(x0, 190, x1, 191))
  F.shadow(x0, x1, yb, 12, 4)
  rimOf(union(posts, roofm, rails), L.timber)
  part(posts, L.timber, { nopop = true }) part(rails, L.timber, { nopop = true, noshade = true })
  part(roofm, GRN) roofm:each(function(x, y) if (x // 3) % 2 == 0 and y < yt then px(x, y, GRN.shade) end end) hline(x0 - 4, x1 + 4, yt + 3, GRN.deep)
  -- rows of little pentagon plaques with coloured scribbles
  local cols = { L.awnA, L.accent, L.produce, L.lav, L.leaf }
  for row = 0, 1 do
    local yy = row == 0 and 174 or 192
    for k = 0, 9 do
      local x = x0 + 5 + k * 8 + (row == 1 and 3 or 0)
      if x + 6 < x1 - 3 then
        local m = poly{ { x, yy + 2 }, { x + 3, yy }, { x + 6, yy + 2 }, { x + 6, yy + 9 }, { x, yy + 9 } }
        c:rim(m, L.board.edge) fill(m, L.board.hi) hline(x, x + 6, yy + 9, L.board.shade) vline(x + 6, yy + 2, yy + 9, L.board.base)
        local cr = cols[(k + row * 2) % 5 + 1]
        px(x + 2, yy + 4, cr.base) px(x + 3, yy + 4, cr.base) px(x + 3, yy + 5, cr.shade) px(x + 2, yy + 6, cr.base) px(x + 4, yy + 7, cr.shade)
        px(x + 3, yy + 1, RED.base)
      end
    end
  end
end
local function fox(x, yb, flip, real, bare)
  local s = flip and -1 or 1
  local r = real and L.produce or L.stone
  local body = poly{ { x - 4 * s, yb }, { x - 4 * s, yb - 10 }, { x - 2 * s, yb - 14 }, { x + 3 * s, yb - 14 }, { x + 4 * s, yb } }
  local head = poly{ { x - 3 * s, yb - 14 }, { x - 3 * s, yb - 20 }, { x - 1 * s, yb - 18 }, { x + 2 * s, yb - 18 }, { x + 3 * s, yb - 21 }, { x + 4 * s, yb - 16 }, { x + 7 * s, yb - 15 }, { x + 3 * s, yb - 13 } }
  local tail = line({ { x - 4 * s, yb - 2 }, { x - 8 * s, yb - 6 }, { x - 7 * s, yb - 12 } }, 3)
  local m = union(body, head, tail)
  rimOf(m, r) part(m, r)
  px(x + 1 * s, yb - 16, r.edge) px(x + 7 * s, yb - 15, L.timber.edge)
  if real then
    tail:each(function(xx, y) if y < yb - 9 then px(xx, y, L.awnB.base) end end)
    hline(x - 1, x + 2, yb - 12, L.awnB.base)
  elseif not bare then
    local bib = poly{ { x - 3 * s, yb - 13 }, { x + 3 * s, yb - 13 }, { x, yb - 8 } } fill(bib, RED.base) px(x, yb - 12, RED.hi)
  end
end
local function plinth(x, yb, w, h)
  local m = rect(x - w, yb - h, x + w, yb) rimOf(m, L.stone) part(m, L.stone) hline(x - w, x + w, yb - h, L.stone.hi)
end

---------------------------------------------------------------- raked gravel garden (bottom-left)
local function gravel()
  local g = poly{ { 20, 230 }, { 150, 226 }, { 162, 264 }, { 20, 266 } }
  local edge = g:grow(2):cut(g)
  fill(edge, L.timber.base)
  g:each(function(x, y) px(x, y, L.road.hi) end)
  local rocks = { { 56, 246, 10 }, { 120, 248, 8 } }
  g:each(function(x, y)
    local best = 1e9
    for _, r in ipairs(rocks) do best = math.min(best, math.sqrt(((x - r[1]) / 1.6) ^ 2 + ((y - r[2])) ^ 2) - r[3] * .55) end
    if best < 14 then if floor(best) % 3 == 0 then px(x, y, L.road.base) end
    elseif (y + floor(sin(x / 20) * 1.5)) % 3 == 0 then px(x, y, L.road.base) end
  end)
  F.rock(56, 250, 12, 12) F.rock(120, 251, 9, 9) F.rock(129, 252, 5, 5)
  for _, p in ipairs({ { 46, 250 }, { 60, 241 }, { 116, 246 } }) do px(p[1], p[2], L.leaf.base) px(p[1] + 1, p[2], L.leaf.hi) px(p[1], p[2] + 1, L.leaf.shade) end
end

---------------------------------------------------------------- compose
F.depth(3)
-- incense burner with a smoke curl (left middle)
do
  local legs = rect(54, 214, 55, 220):add(rect(66, 214, 67, 220))
  local bowl = c:rrect(50, 204, 71, 215, 4)
  local lid = poly{ { 53, 204 }, { 61, 196 }, { 68, 204 } }
  F.shadow(52, 70, 220, 6, 2)
  rimOf(union(legs, bowl, lid), L.timber)
  part(legs, L.roof, { nopop = true }) part(bowl, L.roof) part(lid, L.roof, { sep = true })
  hline(50, 71, 208, L.roof.deep) for x = 53, 68, 3 do px(x, 211, L.roof.hi) end
  F.smoke(61, 190, 7, -.3, 2)
end
chozuya()
emaRack()
local function lanterns()
for _, p in ipairs({ { 146, .5, 11 }, { 182, .7, 22 }, { 252, 1.3, 22 } }) do
  local y = p[1]
  toro(floor(F.xl(y)) - p[3], y, p[2])
  toro(floor(F.xr(y)) + p[3], y, p[2])
end
end
lanterns()
torii()
-- fox pair at the torii feet (stone), and the quirk: a real fox kit peeking out behind the right one
plinth(194, 214, 7, 6) fox(194, 208, false)
plinth(291, 214, 14, 6) fox(283, 208, true, false, true)
-- quirk: a real fox kit poses on the plinth beside the stone fox, wearing its red bib (the stone fox's neck is bare)
F.sprite({
  ".o....o........",
  ".oO..Oo........",
  ".OOOOOO........",
  "OOOOOOOO.......",
  "OeOOOeOO.......",
  "OOwwwOOO.......",
  ".wwnwwO........",
  "..wwwO.....OO..",
  "..RRRRR...OOOO.",
  ".RRrRRRR..OOOO.",
  "..RRRRR...OOO..",
  "..OwwOO...OO...",
  "..OwwwOO..OO...",
  "..OwwwOOOOOO...",
  "..OwwwOOOOWW...",
  "..OOOOOOOWWW...",
  "..kk..kk.......",
}, 291, 191, { o = L.timber.edge, O = L.produce.base, e = L.timber.edge, w = L.awnB.hi, n = L.timber.edge, R = RED.base, r = RED.hi, W = L.awnB.base, k = L.timber.deep })
gravel()
-- bamboo grove at the right edge
for i, x in ipairs({ 430, 438, 446, 455, 462 }) do
  local yb, h = 230, 70 + floor(hash(i, 3, 7) * 30)
  local m = rect(x, yb - h, x + 2, yb)
  rimOf(m, L.leaf) part(m, L.leaf, { nopop = true, noshade = true }) vline(x + 2, yb - h, yb, L.leaf.shade)
  for y = yb - h + 8, yb, 11 do hline(x, x + 2, y, L.leaf.deep) end
  for k = 0, 3 do
    local ly = yb - h + 6 + k * 14
    local d = (k % 2 == 0) and 1 or -1
    local lf = poly{ { x + 1, ly }, { x + 1 + d * 9, ly - 2 }, { x + 1 + d * 11, ly + 1 }, { x + 1 + d * 3, ly + 2 } }
    fill(lf, L.leaf.base) px(x + 1 + d * 5, ly, L.leaf.hi) px(x + 1 + d * 8, ly + 1, L.leaf.deep)
  end
end
-- moss patches and a gnome sweeping leaves by the right lanterns
F.bush(406, 232, 14, 10, L.leaf, 12) F.bush(332, 248, 16, 10, L.leaf, 13)
local _, bx, by = F.gnome(348, 238, { hat = RED, coat = L.awnB, flip = true, arm = "hold" })
fill(line({ { bx + 1, by - 6 }, { bx - 6, by + 6 } }, 1), L.timber.base) -- broom handle
local broom = poly{ { bx - 11, by + 6 }, { bx - 3, by + 6 }, { bx - 4, by + 10 }, { bx - 12, by + 10 } }
rimOf(broom, L.roof) part(broom, L.roof, { nopop = true }) for x = bx - 11, bx - 4, 2 do vline(x, by + 7, by + 10, L.roof.deep) end
-- the leaf pile he is sweeping up
for i = 0, 26 do local x, y = 316 + floor(hash(i, 1, 5) * 12), 240 + floor(hash(i, 2, 5) * 5) - (i % 3)
  local r = i % 2 == 0 and L.foliage or L.foliage2 px(x, y, r.base) px(x + 1, y, r.shade) end
-- a gnome hanging a new ema plaque on the rack
local _, ex, ey = F.gnome(392, 214, { hat = L.leaf, coat = L.lav, arm = "up", flip = true })
local em = poly{ { ex - 3, ey - 1 }, { ex, ey - 3 }, { ex + 3, ey - 1 }, { ex + 3, ey + 5 }, { ex - 3, ey + 5 } }
c:rim(em, L.board.edge) fill(em, L.board.hi) px(ex, ey + 1, RED.base) px(ex - 1, ey + 2, RED.base)
-- crows on the torii beam and birds over the hall
F.depth(0)
F.sprite({ ".kk.", "kkkk", "kkkkk", ".y.." }, 196, 106, { k = "#4a3a4a", y = L.roof.base })
F.sprite({ "..kk", "kkkk", "kkkkk", ".y.y" }, 276, 106, { k = "#4a3a4a", y = L.roof.base })
F.birds({ { 330, 38, 2 }, { 342, 44, 1 }, { 150, 52, 2 }, { 160, 46, 1 } })
F.depth(3)
-- fallen maple leaves everywhere
for i = 0, 70 do
  local x, y = 20 + floor(hash(i, 1, 77) * 440), 120 + floor(hash(i, 2, 77) * 140)
  if not (x > 378 and y > 228) then
    local r = (i % 3 == 0) and L.foliage or L.foliage2
    px(x, y, r.base) px(x + 1, y, r.shade) px(x, y - 1, r.hi)
  end
end
F.finish()
