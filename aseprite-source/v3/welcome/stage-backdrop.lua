-- stage-backdrop PASS B (final). Pass A = stage-backdrop.pA.lua. Draw 190x115, save x2 = 380x230.
-- Welcome step 1: meadow + red-spotted fairy ring as a stage behind the live 160x200 gnome
-- (gnome zone at native x 55-135, y 10-115: only flat sky bands, low-contrast hills, the pale lawn
-- "stage floor" and small muted back-row toadstools live there).
-- The ring sits on a darker band of grass (a real fairy-ring cue) so it reads even with the gnome in front;
-- it opens toward the viewer (no toadstools front-centre = the stage entrance), with two crook lanterns
-- as stage lights.
-- Planes: sky (4 bands, sun, puffs at the edges, geese) / far hills + tree lines (no ink) / mid meadow +
-- ring (deep-tone edges, size grows toward the viewer) / near: toadstool cluster bottom-left, foxgloves +
-- mossy stone bottom-right, grass blades (ink edges on the near objects).
-- quirk: a little frog sits on the biggest toadstool, front-row audience, looking at the stage.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "stage-backdrop"
local SUF = app.params.suf or ""
local c = HP.canvas{ w = 190, h = 115, scale = 2, name = NAME }
local sin, cos, abs, floor, pi, min, max = math.sin, math.cos, math.abs, math.floor, math.pi, math.min, math.max
local INK = P.ink
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry or rx) end
local function R(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local function px(x, y, h) c:px(x, y, h) end
local function hash(a, b) return ((a * 73856093) ~ (b * 19349663) ~ (a * b * 83492791)) % 1000 end
local function centre(x) return x >= 50 and x <= 140 end

-- form painter: base, lit crescent upper-left (offset l), shade crescent lower-right (offset s)
local function form(m, Rp, o)
  o = o or {}
  c:fillMask(m, Rp.base)
  local s, l = o.s or 2, o.l
  local sh, lt = {}, {}
  m:each(function(x, y)
    if l and not m:has(x - l, y - l) then lt[#lt + 1] = { x, y } end
    if s > 0 and not m:has(x + s, y + s) then sh[#sh + 1] = { x, y } end
  end)
  for _, p in ipairs(lt) do px(p[1], p[2], Rp.hi) end
  for _, p in ipairs(sh) do px(p[1], p[2], Rp.shade) end
  return m
end

local GRASS = { hi = "#a6d86a", base = P.moss.base, shade = "#5aa856", deep = P.moss.shade }
local RINGG = "#6db553"      -- fairy-ring grass band (a touch darker than the meadow)
local LAWN = "#86c862"       -- inner lawn (stage floor), low contrast vs meadow
local MUTED = { hi = "#efb0a2", base = "#de9590", shade = "#c97c86", deep = "#a56676" } -- far toadstools
local CAPR = { hi = P.ember.hi, base = P.ember.base, shade = P.ember.shade, deep = P.ember.deep }
local STEM = { hi = P.cream, base = "#f6e6c4", shade = "#dcc39c", deep = "#a88a6e" }

------------------------------------------------------------ SKY
c:stripes(0, 60, { P.sky.shade, P.sky.base, "#cdebf8", P.sky.hi }, { 3, 4, 4, 3 })
c:fillMask(E(172, 13, 8), P.gold.hi)
c:fillMask(E(172, 13, 7), P.gold.base) c:fillMask(E(171, 12, 5), P.gold.hi) R(169, 9, 170, 9, P.cream)
c:cloud(-3, 26, 32, P.cream, P.sky.hi)
c:cloud(24, 13, 17, P.cream, P.sky.hi)
c:cloud(144, 34, 28, P.cream, P.sky.hi)
c:cloud(176, 44, 16, P.cream, P.sky.hi)
for _, g in ipairs{ {40, 9}, {46, 12}, {35, 13} } do px(g[1], g[2], P.stone.shade) px(g[1] - 1, g[2] - 1, P.stone.shade) px(g[1] + 1, g[2] - 1, P.stone.shade) end

------------------------------------------------------------ FAR hills (no ink, low contrast)
c:terrain(function(x) return 46 + 6 * sin(x / 27 + .5) + 2 * sin(x / 10) end, "#a8dccd")
local function farTree(x, y, r, col, lit) c:fillMask(E(x, y, r, r + 1), col) px(x - 1, y - r, lit) px(x - 2, y - r + 1, lit) end
for _, t in ipairs{ {4, 47, 4}, {11, 44, 5}, {19, 46, 4}, {26, 48, 3}, {163, 48, 3}, {170, 45, 5}, {179, 43, 5}, {187, 46, 4} } do
  farTree(t[1], t[2], t[3], "#86c7a8", "#bfe6d6")
end
c:terrain(function(x) return 56 + 4 * sin(x / 22 + 2) + 1.5 * sin(x / 7) end, P.moss.hi)
-- second tree line on the near hill, edges only (one step stronger)
for _, t in ipairs{ {2, 58, 4}, {9, 56, 3}, {182, 57, 4}, {188, 59, 3} } do farTree(t[1], t[2], t[3], "#8fc96a", P.moss.hi) end

------------------------------------------------------------ MID meadow
c:terrain(function(x) return 64 + 1.5 * sin(x / 30 + 1) end, GRASS.base)
c:terrain(function(x) return 99 + 2 * sin(x / 18) end, "#72bd56")
-- mown stripes in the far meadow (low contrast)
for y = 66, 74, 4 do for x = 0, 189 do if not centre(x) and (x // 6) % 2 == 0 then px(x, y, "#86c95e") end end end

-- the ring
local RCX, RCY, RX, RY = 95, 88, 70, 17
local band = E(RCX, RCY, RX + 4, RY + 3):cut(E(RCX, RCY, RX - 5, RY - 4))
c:fillMask(band, RINGG)
c:fillMask(E(RCX, RCY, RX - 5, RY - 4), LAWN)
c:fillMask(E(RCX, RCY + 2, 32, 6), "#8fcc66")       -- worn spot where the gnome stands
-- clover dots on the lawn edges (calm)
for i = 0, 30 do
  local a = hash(i, 21) / 1000 * 2 * pi
  local x, y = floor(RCX + cos(a) * (RX - 12) + .5), floor(RCY + sin(a) * (RY - 7) + .5)
  if not centre(x) then px(x, y, GRASS.base) px(x + 1, y, GRASS.base) px(x, y - 1, GRASS.hi) end
end

-- grass tufts: dense at the edges, sparse + low-contrast in the centre
for i = 0, 300 do
  local x, y = hash(i, 3) % 190, 66 + hash(i, 7) % 48
  local inLawn = ((x - RCX) / (RX - 5)) ^ 2 + ((y - RCY) / (RY - 4)) ^ 2 < 1
  if not inLawn then
    if centre(x) then
      if i % 4 == 0 then px(x, y, "#68b350") px(x + 1, y - 1, "#68b350") end
    else
      local col = y > 99 and GRASS.deep or GRASS.shade
      px(x, y, col) px(x + 1, y - 1, col) px(x - 1, y - 1, GRASS.hi)
    end
  end
end
-- meadow flowers, edges only
local FC = { P.petal, P.gold, P.dusk, P.sea, P.petal }
for i = 0, 44 do
  local x, y = hash(i, 11) % 190, 67 + hash(i, 13) % 36
  local inLawn = ((x - RCX) / (RX + 4)) ^ 2 + ((y - RCY) / (RY + 3)) ^ 2 < 1
  if not centre(x) and not inLawn then
    local col = FC[1 + i % 5]
    px(x, y + 1, GRASS.deep)
    if i % 3 == 0 then px(x, y, P.cream) px(x - 1, y, P.cream) px(x + 1, y, P.cream) px(x, y - 1, P.cream) px(x, y, P.gold.base)
    else px(x, y, col.hi) px(x - 1, y, col.base) px(x + 1, y, col.base) px(x, y - 1, col.base) px(x, y, P.gold.hi) end
  end
end

------------------------------------------------------------ toadstools
-- toad(x, ybase, w, capH, stemH, kind, edge)
local function toad(x, yb, w, ch, sh, kind, edge)
  local cr = (kind == "far") and MUTED or CAPR
  local hw = floor(w / 2)
  local sw = max(1, floor(w / 6 + .5))
  local capY = yb - sh                        -- bottom row of cap
  local stem = c:rect(x - sw, capY, x + sw, yb):add(c:rect(x - sw - 1, yb - 1, x + sw + 1, yb)) -- foot flares
  if w < 8 then stem = c:rect(x - sw + (w < 6 and 1 or 0), capY, x + sw, yb) end
  local cap = E(x, capY, hw, ch):clip(c:rect(x - hw, capY - ch, x + hw, capY))
  local all = stem:copy():add(cap)
  -- ground contact shadow (2 tones for the bigger ones)
  c:fillMask(c:rect(x - hw + 1, yb + 1, x + hw, yb + 1), (kind == "far") and "#7cc05a" or GRASS.shade)
  if w >= 12 then c:fillMask(c:rect(x - sw, yb + 1, x + hw - 2, yb + 1), GRASS.deep) end
  if edge then c:rim(all, edge) end
  form(stem, STEM, { s = 1 })
  if w >= 8 then R(x - sw, capY + 1, x + sw, capY + 1, STEM.shade) end -- shadow under the cap
  form(cap, cr, { s = w >= 9 and 2 or 1, l = w >= 9 and 1 or nil })
  -- lip: deep underside row with gill ticks
  for xx = x - hw, x + hw do if cap:has(xx, capY) then px(xx, capY, cr.deep) end end
  if w >= 12 then for xx = x - hw + 2, x + hw - 2, 2 do px(xx, capY, STEM.shade) end end
  -- spots (lit spots cream, shade-side spots warmer)
  local spot = (kind == "far") and "#f9e0d4" or P.cream
  local spot2 = (kind == "far") and "#f0c8bc" or "#f6d2b0"
  if w >= 20 then
    c:fillMask(E(x - floor(hw * .45), capY - floor(ch * .6), 2, 1), spot)
    c:fillMask(E(x + floor(hw * .25), capY - floor(ch * .75), 1, 1), spot)
    c:fillMask(c:rect(x + floor(hw * .55), capY - floor(ch * .4), x + floor(hw * .55) + 1, capY - floor(ch * .4) + 1), spot2)
    px(x - hw + 3, capY - 3, spot) px(x - hw + 4, capY - 3, spot) px(x + 1, capY - 3, spot2) px(x - 2, capY - ch + 2, spot)
  elseif w >= 11 then
    R(x - floor(hw * .5) - 1, capY - floor(ch * .6), x - floor(hw * .5), capY - floor(ch * .6) + 1, spot)
    px(x + 2, capY - ch + 2, spot) px(x + floor(hw * .6), capY - 2, spot2) px(x - hw + 2, capY - 2, spot)
  elseif w >= 7 then
    px(x - 2, capY - ch + 2, spot) px(x - 1, capY - ch + 2, spot) px(x + 1, capY - 2, spot2)
  else
    px(x - 1, capY - 1, spot)
  end
  return all, capY - ch
end

-- ring positions, back to front; front-centre left open as the stage entrance
local N = 24
local list = {}
for i = 0, N - 1 do
  local a = (i + .5) / N * 2 * pi
  local x, y = floor(RCX + cos(a) * RX + .5), floor(RCY + sin(a) * RY + .5)
  local front = y > RCY
  if not (front and abs(x - RCX) < 47) then list[#list + 1] = { x = x, y = y, i = i, t = (y - (RCY - RY)) / (2 * RY) } end
end
table.sort(list, function(p, q) return p.y < q.y end)
for _, t in ipairs(list) do
  if t.y < RCY - 8 and centre(t.x) then
    toad(t.x, t.y, 5, 3, 2, "far", nil)
  elseif centre(t.x) then
    toad(t.x, t.y, 7, 4, 3, "far", MUTED.deep)
  else
    local w = floor(6 + t.t * 6 + (t.i % 3 == 0 and 1 or 0))
    toad(t.x, t.y, w, floor(w / 2) + 1, floor(w / 3) + 1, "mid", P.ember.deep)
  end
end

------------------------------------------------------------ NEAR: crook lanterns (stage lights, ink edge)
local function lantern(x, ytop, yb, dir)
  local post = c:rect(x, ytop + 2, x + 1, yb)
  local hook = HP.mask()
  for _, p in ipairs{ {0, 1}, {0, 0}, {1, -1}, {2, -1}, {3, -1}, {4, 0}, {4, 1} } do hook:set(x + dir * p[1] + (dir < 0 and 1 or 0), ytop + p[2]) end
  local lx = x + dir * 4 + (dir < 0 and -1 or 0)
  local lamp = c:rrect(lx - 2, ytop + 3, lx + 2, ytop + 8, 1)
  local all = post:copy():add(hook):add(lamp)
  -- glow: two hard rings of warm light on the grass/sky
  c:fillMask(E(lx, ytop + 5, 6, 6):cut(all), "#e8f2b8")
  c:fillMask(E(lx, ytop + 5, 4, 4):cut(all), "#fff3b8")
  c:rim(all, INK)
  c:fillMask(post, P.wood.base) R(x + 1, ytop + 2, x + 1, yb, P.wood.shade)
  c:fillMask(hook, P.wood.base)
  px(lx, ytop + 2, INK)
  c:fillMask(lamp, P.gold.base)
  R(lx - 1, ytop + 4, lx, ytop + 6, P.gold.hi) px(lx - 1, ytop + 4, P.cream)
  R(lx - 2, ytop + 8, lx + 2, ytop + 8, P.wood.deep)
  R(lx - 2, ytop + 3, lx + 2, ytop + 3, P.wood.shade)
  px(lx + 2, ytop + 6, P.gold.shade) px(lx + 2, ytop + 7, P.gold.shade)
  -- tuft at the foot of the post
  px(x - 1, yb, GRASS.deep) px(x + 2, yb, GRASS.deep) px(x - 1, yb - 1, GRASS.shade) px(x + 3, yb - 1, GRASS.shade)
end
lantern(40, 62, 95, 1)
lantern(148, 63, 96, -1)

------------------------------------------------------------ NEAR: grass blades (behind the near objects)
local function blade(x, yb, h, lean, col)
  for k = 0, h do px(x + floor(lean * k / h + .5), yb - k, col) end
end
for i = 0, 24 do
  local x = (i < 12) and (i * 4 + 1) or (138 + (i - 12) * 4)
  blade(x, 114, 3 + hash(i, 5) % 6, (i % 2 == 0) and -2 or 2, (i % 3 == 0) and GRASS.deep or GRASS.shade)
end

------------------------------------------------------------ NEAR: mossy stone bottom-right
do
  local st = E(160, 111, 9, 5):clip(c:rect(0, 0, 189, 114))
  c:rim(st, INK)
  form(st, P.stone, { s = 2, l = 1 })
  c:fillMask(E(158, 107, 6, 2):clip(st), P.moss.base)
  px(155, 106, P.moss.hi) px(156, 106, P.moss.hi) px(163, 108, P.moss.shade)
end

------------------------------------------------------------ NEAR: foxgloves bottom-right
local function foxglove(x, yb, h)
  local stem = c:rect(x, yb - h, x, yb)
  local bells = HP.mask()
  local list = {}
  local nb = floor((h - 4) / 3)
  for k = 0, nb - 1 do
    local yy = yb - h + 3 + k * 3
    local side = (k % 2 == 0) and -1 or 1
    local size = (k < 2) and 1 or 2
    local bx0 = (side < 0) and x - size - 1 or x + 1
    local bell = c:rect(bx0, yy, bx0 + size, yy + 2)
    bells:add(bell)
    list[#list + 1] = { bell = bell, side = side, x0 = bx0, x1 = bx0 + size, y = yy }
  end
  local leaf = c:poly{ {x - 4, yb}, {x - 1, yb - 4}, {x, yb}, {x + 1, yb - 3}, {x + 4, yb} }
  local all = stem:copy():add(bells):add(leaf)
  c:rim(all, INK)
  c:fillMask(stem, P.moss.shade)
  c:fillMask(leaf, P.moss.base) px(x - 1, yb - 2, P.moss.hi)
  px(x, yb - h, P.moss.base) -- bud
  for _, b in ipairs(list) do
    c:fillMask(b.bell, P.petal.base)
    for xx = b.x0, b.x1 do px(xx, b.y, P.petal.hi) px(xx, b.y + 2, P.petal.shade) end
    px((b.side < 0) and b.x0 or b.x1, b.y + 2, P.petal.deep)  -- open mouth
  end
end
foxglove(178, 113, 30)
foxglove(186, 113, 22)
foxglove(171, 113, 17)

------------------------------------------------------------ NEAR: toadstool cluster bottom-left + frog
toad(6, 106, 10, 5, 4, "near", INK)
local _, bigTop = toad(20, 114, 30, 14, 8, "near", INK)
toad(41, 114, 13, 7, 5, "near", INK)
-- frog quirk: side-on, sitting on the big cap, facing right toward the stage
do
  local fx, fy = 7, bigTop - 6
  c:paint({
    "........kkkk..",
    ".......keeeIk.",
    "......kkleIIk.",
    "...kkkllgggkk.",
    ".kkllgggggggk.",
    "klggggggggggkk",
    "kgsgggggkkkkk.",
    "kssgsgkwwwwk..",
    ".kkkkkkkkkk...",
  }, fx, fy, { k = INK, l = "#d4ee84", g = "#9cd24c", s = "#5e9a3c", w = "#eef0b0", e = P.cream, I = INK })
  c:cheek(fx + 9, fy + 5)
end
-- butterflies, edges
local function fly(x, y, col)
  px(x, y, INK) px(x - 1, y - 1, col.base) px(x - 2, y - 1, col.hi) px(x - 1, y, col.shade)
  px(x + 1, y - 1, col.base) px(x + 2, y - 1, col.hi) px(x + 1, y, col.shade)
end
fly(160, 76, P.dusk) fly(28, 70, P.gold)

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. SUF .. ".aseprite", png = out .. NAME .. SUF .. ".png", scale = 2 }
