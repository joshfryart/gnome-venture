-- tower.lua : "Watchtower" stop look, Maplewold (480x270 gate view). Opus second pass.
-- Read: a tall round stone watchtower at the road's end with crenels, a lit beacon and a flag, a crenellated
-- wall running off along the horizon, banners lining the road, a guardhouse with a spear and shield rack,
-- an alarm bell frame, a telescope on a tripod, beacon wood bundles and an archery range.
-- Quirk: a carrier pigeon with a tiny scroll landing on the dovecote.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus2/"
local F = dofile(DIR .. "_frame.lua").build{ name = "tower", out = DIR, farTrees = { 24, 52, 100, 380, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local S, IR, G = L.stone, L.iron, L.glow

---------------------------------------------------------------- curtain wall along the horizon
local function wall(x0, x1, yb, h)
  local m = rect(x0, yb - h, x1, yb)
  for x = x0, x1 - 4, 8 do m:add(rect(x, yb - h - 4, x + 4, yb - h)) end
  F.shadow(x0, x1, yb, 4, 2)
  rimOf(m, S) part(m, S) F.courses(rect(x0, yb - h, x1, yb), yb - h, 4, 8, S)
  hline(x0, x1, yb - h, S.hi)
  for x = x0 + 6, x1 - 6, 24 do fill(rect(x, yb - h + 4, x + 1, yb - h + 8), S.edge) end
end
wall(118, 216, 126, 12)
wall(264, 372, 126, 12)
-- ivy on the walls
for i = 0, 30 do local x, y = 120 + floor(hash(i, 1, 4) * 250), 116 + floor(hash(i, 2, 4) * 10)
  if x < 214 or x > 266 then px(x, y, L.leaf.base) px(x + 1, y, L.leaf.shade) px(x, y - 1, L.leaf.hi) end end

---------------------------------------------------------------- the tower
local function tower()
  local x0, x1, yb, yt = 214, 266, 128, 46
  local body = poly{ { x0, yb }, { x1, yb }, { x1 - 6, yt }, { x0 + 6, yt } }
  local cor = rect(x0 - 2, yt - 8, x1 + 2, yt)
  local cren = HP.mask()
  for x = x0 - 2, x1 - 2, 8 do cren:add(rect(x, yt - 16, x + 4, yt - 8)) end
  local roofm = poly{ { x0 + 10, yt - 16 }, { 240, yt - 30 }, { x1 - 10, yt - 16 } }
  F.shadow(x0, x1, yb + 1, 12, 4)
  rimOf(union(body, cor, cren), S)
  part(body, S)
  -- rounded courses: row curve suggests a cylinder
  body:each(function(x, y)
    local t = (x - 240) / 26
    local yy = y - floor(3 * (1 - t * t))
    local row = (yy - yt) // 7
    local bw = 9
    local off = (row % 2) * 4
    if (yy - yt) % 7 == 0 then px(x, y, S.deep)
    elseif (x + off) % bw == 0 then px(x, y, S.shade) end
    if t > .55 and (x + y) % 2 == 0 then px(x, y, S.shade) end
    if t < -.6 and (yy - yt) % 7 == 1 then px(x, y, S.hi) end
  end)
  part(cor, S, { sep = true })
  for x = x0, x1, 5 do fill(rect(x, yt, x + 2, yt + 3), S.shade) px(x, yt, S.deep) end
  part(cren, S, { sep = true, nopop = true })
  -- beacon brazier and fire behind the crenels
  local braz = rect(232, yt - 22, 248, yt - 16) rimOf(braz, IR) part(braz, IR)
  local fire = poly{ { 232, yt - 22 }, { 235, yt - 32 }, { 238, yt - 26 }, { 240, yt - 38 }, { 243, yt - 27 }, { 246, yt - 33 }, { 248, yt - 22 } }
  fill(fire, G.shade) fill(poly{ { 235, yt - 22 }, { 240, yt - 33 }, { 245, yt - 22 } }, G.base) fill(poly{ { 238, yt - 22 }, { 240, yt - 28 }, { 242, yt - 22 } }, G.hi)
  for i = 0, 5 do px(232 + floor(hash(i, 1, 2) * 18), yt - 36 - floor(hash(i, 2, 2) * 8), G.hi) end
  -- flag pole + pennant
  local pole = rect(258, yt - 32, 259, yt - 8) rimOf(pole, L.timber) part(pole, L.timber, { nopop = true, noshade = true })
  local flag = poly{ { 260, yt - 31 }, { 280, yt - 27 }, { 274, yt - 24 }, { 280, yt - 20 }, { 260, yt - 20 } }
  rimOf(flag, L.awnA) part(flag, L.awnA) fill(rect(264, yt - 28, 267, yt - 24), L.roof.base) px(264, yt - 28, L.roof.hi)
  -- windows (arrow slits + one lit window), door with steps
  for _, w in ipairs({ { 240, 60 }, { 228, 84 }, { 252, 84 } }) do fill(rect(w[1] - 1, w[2], w[1], w[2] + 8), S.edge) px(w[1] - 1, w[2], S.deep) end
  F.window(237, 98, 243, 104, L.timber, true)
  F.door(233, 112, 247, 127, L.timber, true)
  for k = 0, 1 do hline(230 - k * 2, 250 + k * 2, 126 + k, S.hi) end
  -- ivy up the left side
  for i = 0, 40 do
    local y = 128 - floor(hash(i, 3, 5) * 60)
    local x = x0 + 1 + floor(hash(i, 4, 5) * 8) + floor((128 - y) * 6 / 82)
    if body:has(x, y) then px(x, y, L.leaf.base) px(x + 1, y, L.leaf.shade) px(x, y - 1, L.leaf.hi) end
  end
  -- banner hanging from the corbel
  local ban = poly{ { 222, yt + 3 }, { 230, yt + 3 }, { 230, yt + 24 }, { 226, yt + 20 }, { 222, yt + 24 } }
  rimOf(ban, L.accent) part(ban, L.accent) fill(c:ellipse(226, yt + 11, 2, 2), L.roof.base)
end
tower()

---------------------------------------------------------------- banners lining the road
local function banner(x, yb, s, r)
  local h = floor(30 * s)
  local pole = rect(x, yb - h, x + math.max(1, floor(s)), yb)
  local fl = poly{ { x + 1, yb - h + 1 }, { x + 1 + floor(9 * s), yb - h + 1 }, { x + 1 + floor(9 * s), yb - h + floor(16 * s) }, { x + 1 + floor(4.5 * s), yb - h + floor(12 * s) }, { x + 1, yb - h + floor(16 * s) } }
  F.shadow(x, x + 2, yb, floor(4 * s), 2)
  rimOf(union(pole, fl), L.timber)
  part(pole, L.timber, { nopop = true, noshade = true }) part(fl, r, { nopop = s < 1 })
  px(x, yb - h - 1, L.roof.base)
end
for _, p in ipairs({ { 140, .55 }, { 166, .8 }, { 206, 1.2 } }) do
  local y, s = p[1], p[2]
  banner(floor(F.xl(y)) - floor(14 * s) - 4, y, s, L.awnA)
  banner(floor(F.xr(y)) + floor(6 * s), y, s, L.accent)
end

---------------------------------------------------------------- left: guardhouse + weapons rack + training dummy
F.tree(30, 140, 40, 3)
local gt = F.building{ x0 = 54, x1 = 150, yb = 168, wh = 40, rh = 26, wall = L.plaster, roof = L.roof2, shingle = true, chimney = true }
F.door(94, 142, 108, 167, L.timber, true)
F.window(66, 140, 74, 147, L.timber) F.window(126, 140, 134, 147, L.timber)
-- shield over the door
local sh = poly{ { 95, 128 }, { 107, 128 }, { 107, 134 }, { 101, 139 }, { 95, 134 } }
rimOf(sh, L.awnA) part(sh, L.awnA) fill(rect(100, 129, 102, 137), L.roof.base) fill(rect(96, 131, 106, 132), L.roof.base)
local function rack(x0, yb)
  local posts = rect(x0, yb - 26, x0 + 2, yb):add(rect(x0 + 40, yb - 26, x0 + 42, yb))
  local rails = rect(x0, yb - 24, x0 + 42, yb - 23):add(rect(x0, yb - 8, x0 + 42, yb - 7))
  F.shadow(x0, x0 + 42, yb, 8, 3)
  rimOf(union(posts, rails), L.timber)
  -- spears
  for k = 0, 4 do
    local x = x0 + 6 + k * 7
    vline(x, yb - 34, yb - 1, L.board.base) vline(x + 1, yb - 34, yb - 1, L.board.shade)
    local tip = poly{ { x - 1, yb - 34 }, { x + 1, yb - 40 }, { x + 3, yb - 34 } } fill(tip, IR.hi) px(x + 2, yb - 34, IR.shade)
  end
  part(posts, L.timber, { nopop = true, noshade = true }) part(rails, L.timber, { nopop = true, noshade = true })
  -- round shields leaning
  for k, r in ipairs({ L.awnA, L.accent }) do
    local x = x0 + 50 + k * 13
    local m = c:ellipse(x, yb - 8, 7, 8)
    rimOf(m, r) part(m, r) c:ellipse(x, yb - 8, 4, 5):edge():each(function(xx, yy) px(xx, yy, L.roof.base) end) fill(c:ellipse(x, yb - 8, 1, 1), IR.hi)
  end
end
rack(60, 200)
local function dummy(x, yb)
  local post = rect(x - 1, yb - 30, x + 1, yb):add(rect(x - 12, yb - 22, x + 12, yb - 20))
  local sack = c:rrect(x - 7, yb - 26, x + 7, yb - 10, 4)
  local head = c:ellipse(x, yb - 32, 5, 5)
  F.shadow(x - 6, x + 8, yb, 6, 2)
  rimOf(union(post, sack, head), L.timber)
  part(post, L.timber, { nopop = true, noshade = true })
  part(sack, L.roof) sack:each(function(xx, y) if (xx + y) % 4 == 0 then px(xx, y, L.roof.shade) end end)
  part(head, L.roof) for k = -1, 1 do px(x + k * 3, yb - 37, L.roof.hi) px(x + k * 3, yb - 38, L.roof.base) end
  fill(rect(x - 2, yb - 33, x - 1, yb - 32), L.timber.edge) fill(rect(x + 2, yb - 33, x + 3, yb - 32), L.timber.edge)
  hline(x - 3, x + 3, yb - 29, L.roof.deep)
  -- dented pot helmet
  local hel = c:ellipse(x, yb - 37, 6, 3):clip(rect(x - 7, yb - 41, x + 7, yb - 36)) fill(hel, IR.base) hline(x - 6, x + 6, yb - 36, IR.deep) px(x - 3, yb - 39, IR.hi)
end
dummy(178, 208)

---------------------------------------------------------------- archery range, bottom-left
local function target(x, yb, s)
  local legs = line({ { x - 6 * s, yb }, { x, yb - 22 * s } }, 2):add(line({ { x + 6 * s, yb }, { x, yb - 22 * s } }, 2))
  local face = c:ellipse(x, yb - 16 * s, 10 * s, 10 * s)
  F.shadow(floor(x - 6 * s), floor(x + 8 * s), yb, 6, 2)
  rimOf(union(legs, face), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true })
  fill(face, L.roof.base)
  face:each(function(xx, y) if (xx + y) % 3 == 0 then px(xx, y, L.roof.shade) end end)
  local cols = { L.awnB.base, L.awnA.base, L.awnB.base, L.awnA.base, L.roof.base }
  for k = 1, 4 do local r = 8 - k * 2 if r > 0 then fill(c:ellipse(x, yb - 16 * s, r * s, r * s), cols[k + 1]) end end
  fill(c:ellipse(x, yb - 16 * s, 7 * s, 7 * s):cut(c:ellipse(x, yb - 16 * s, 6 * s, 6 * s)), L.awnA.base)
  -- arrows stuck in
  for k = 0, 1 do local ax, ay = floor(x - 2 + k * 5), floor(yb - 16 * s - 2 + k * 4) fill(line({ { ax, ay }, { ax - 6, ay + 3 } }), L.board.deep) px(ax - 6, ay + 3, L.awnB.hi) px(ax - 7, ay + 3, L.awnB.hi) end
end
target(40, 252, 1.2) target(82, 244, .9)
F.gnome(150, 254, { hat = L.leaf, coat = L.accent, arm = "out", flip = true })
fill(c:ellipse(141, 245, 2, 7):cut(c:ellipse(142, 245, 1, 6)), L.timber.base) vline(141, 238, 252, L.awnB.shade)

---------------------------------------------------------------- right: alarm bell, dovecote, telescope, beacon wood
local function bell(x0, yb)
  local posts = rect(x0, yb - 40, x0 + 3, yb):add(rect(x0 + 34, yb - 40, x0 + 37, yb))
  local beam = rect(x0 - 4, yb - 44, x0 + 41, yb - 40)
  local b = poly{ { x0 + 13, yb - 34 }, { x0 + 24, yb - 34 }, { x0 + 27, yb - 18 }, { x0 + 10, yb - 18 } }:add(c:rrect(x0 + 13, yb - 38, x0 + 24, yb - 31, 3))
  F.shadow(x0, x0 + 40, yb, 8, 3)
  rimOf(union(posts, beam, b), L.timber)
  part(posts, L.timber, { nopop = true }) part(beam, L.timber) hline(x0 - 4, x0 + 41, yb - 44, L.timber.hi)
  part(b, L.roof) hline(x0 + 10, x0 + 27, yb - 19, L.roof.deep) hline(x0 + 12, x0 + 25, yb - 26, L.roof.shade)
  vline(x0 + 18, yb - 40, yb - 38, L.timber.edge)
  fill(rect(x0 + 18, yb - 18, x0 + 19, yb - 15), IR.base)
  vline(x0 + 26, yb - 18, yb - 4, L.board.deep) -- pull rope
end
F.building{ x0 = 352, x1 = 420, yb = 164, wh = 28, rh = 20, wall = L.stone, roof = L.roof2, shingle = true, noFrame = true }
F.courses(rect(352, 136, 420, 164), 136, 5, 10, S)
F.door(378, 146, 390, 163, L.timber, true) F.window(402, 146, 408, 152, L.timber)
bell(300, 196)
local function dovecote(x, yb)
  local post = rect(x - 1, yb - 40, x + 1, yb)
  local box = rect(x - 12, yb - 58, x + 12, yb - 40)
  local roofm = poly{ { x - 15, yb - 58 }, { x, yb - 68 }, { x + 15, yb - 58 } }
  F.shadow(x - 2, x + 4, yb, 6, 2)
  rimOf(union(post, box, roofm), L.timber)
  part(post, L.timber, { nopop = true, noshade = true }) part(box, L.awnB) part(roofm, L.roof2, { sep = true })
  for k = 0, 2 do local hx = x - 9 + k * 7 fill(c:rrect(hx, yb - 54, hx + 4, yb - 48, 2), L.timber.edge) hline(hx - 1, hx + 5, yb - 47, L.timber.base) end
  hline(x - 12, x + 12, yb - 45, L.awnB.shade)
  -- pigeons on the roof + the quirk pigeon with a scroll landing
  for _, p in ipairs({ { x - 6, yb - 63 }, { x + 7, yb - 61 } }) do local m = c:ellipse(p[1], p[2], 3, 2) fill(m, S.base) px(p[1] - 2, p[2] - 2, S.hi) px(p[1] - 3, p[2] - 1, L.roof.base) end
  local q = x - 24
  local pg = c:ellipse(q, yb - 70, 3, 2):add(poly{ { q + 2, yb - 71 }, { q - 4, yb - 79 }, { q - 3, yb - 71 } }):add(poly{ { q - 1, yb - 70 }, { q - 8, yb - 76 }, { q - 6, yb - 69 } })
  rimOf(pg, S) part(pg, S, { nopop = true }) px(q + 3, yb - 71, L.roof.base) px(q + 4, yb - 71, L.roof.shade) px(q + 2, yb - 72, L.timber.edge)
  fill(rect(q - 2, yb - 67, q + 1, yb - 66), L.awnB.hi) px(q - 1, yb - 66, L.awnA.base)
end
dovecote(440, 196)
-- telescope on a tripod with a gnome lookout
local tri = line({ { 362, 214 }, { 370, 196 } }):add(line({ { 378, 214 }, { 370, 196 } })):add(line({ { 370, 214 }, { 370, 196 } }))
local tube = line({ { 362, 198 }, { 384, 186 } }, 3)
rimOf(union(tri, tube), L.timber) fill(tri, L.timber.base) part(tube, L.roof) fill(rect(382, 184, 386, 188), L.roof.shade) px(362, 198, L.water.hi)
F.gnome(354, 214, { hat = L.lav, coat = L.awnA, arm = "out" })
-- beacon wood bundles and supply crates
for k = 0, 2 do
  local x = 300 + k * 18
  local m = rect(x, 228, x + 14, 236) rimOf(m, L.timber) part(m, L.timber, { nopop = true })
  for y = 229, 235, 2 do hline(x + 1, x + 13, y, L.timber.deep) end
  fill(rect(x + 6, 228, x + 7, 236), L.board.base)
  local e = c:ellipse(x + 14, 232, 2, 4) fill(e, L.board.hi) px(x + 14, 232, L.board.shade)
end
F.crate(300, 254, 18, 12) F.crate(320, 256, 18, 12) F.crate(310, 242, 18, 10)
F.barrel(346, 258, L.timber, 12)
-- guard with a spear on the road
F.gnome(258, 236, { hat = L.iron, coat = L.awnA })
fill(rect(266, 206, 266, 236), L.board.shade) fill(poly{ { 265, 206 }, { 266, 200 }, { 268, 206 } }, IR.hi)
F.finish()
