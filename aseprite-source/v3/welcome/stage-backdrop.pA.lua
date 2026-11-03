-- stage-backdrop PASS A (form). Draw 190x115, save x2 = 380x230. Welcome step 1: meadow + fairy ring as a stage.
-- The live 160x200 gnome stands centre (x 55-135, y 10-115 at native): that zone holds only flat sky bands,
-- low-contrast hills, a pale worn lawn "stage floor" and small muted back-row toadstools.
-- The ring opens toward the viewer (no toadstools front-centre = the stage entrance).
-- Planes: sky (4 bands, sun, puffs at the edges) / far hills + tree line (no ink) / mid meadow + ring
-- (deep-tone edges) / near: big toadstool cluster bottom-left, lantern posts as stage lights, foxgloves
-- bottom-right (ink edges).
-- quirk: a little frog sits on the biggest toadstool, front-row audience for the show.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "stage-backdrop"
local SUF = app.params.suf or ".pA"
local c = HP.canvas{ w = 190, h = 115, scale = 2, name = NAME }
local sin, cos, abs, floor, pi, min, max = math.sin, math.cos, math.abs, math.floor, math.pi, math.min, math.max
local INK = P.ink
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry or rx) end
local function R(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local function px(x, y, h) c:px(x, y, h) end
local function hash(a, b) return ((a * 73856093) ~ (b * 19349663) ~ (a * b * 83492791)) % 1000 end
local function centre(x) return x >= 52 and x <= 138 end

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
local LAWN = "#88c962"       -- inner ring lawn (stage floor), low contrast vs meadow
local MUTED = { hi = "#eea79a", base = "#dc8a86", shade = "#c27280", deep = "#9a5a6e" } -- far toadstools
local CAPR = { hi = P.ember.hi, base = P.ember.base, shade = P.ember.shade, deep = P.ember.deep }
local STEM = { hi = P.cream, base = "#f6e6c4", shade = "#dcc39c", deep = "#a88a6e" }

------------------------------------------------------------ SKY
c:stripes(0, 60, { P.sky.shade, P.sky.base, "#cdebf8", P.sky.hi }, { 3, 4, 4, 3 })
c:fillMask(E(171, 12, 7), P.gold.base) c:fillMask(E(170, 11, 5), P.gold.hi)
c:cloud(2, 24, 30, P.cream, P.sky.hi)
c:cloud(26, 12, 16, P.cream, P.sky.hi)
c:cloud(146, 32, 26, P.cream, P.sky.hi)
-- two geese far left
for _, g in ipairs{ {40, 8}, {46, 11} } do px(g[1], g[2], P.stone.deep) px(g[1] - 1, g[2] - 1, P.stone.deep) px(g[1] + 1, g[2] - 1, P.stone.deep) end

------------------------------------------------------------ FAR hills (2 tones, no ink)
c:terrain(function(x) return 46 + 6 * sin(x / 27 + .5) + 2 * sin(x / 10) end, "#a8dccd")
-- tree line on the far hill, edges only
local function farTree(x, y, r) c:fillMask(E(x, y, r, r + 1), "#86c7a8") px(x - 1, y - r, "#bfe6d6") end
for _, t in ipairs{ {6, 46, 4}, {13, 44, 5}, {21, 47, 3}, {168, 46, 4}, {176, 43, 5}, {185, 46, 4} } do farTree(t[1], t[2], t[3]) end
c:terrain(function(x) return 56 + 4 * sin(x / 22 + 2) + 1.5 * sin(x / 7) end, P.moss.hi)

------------------------------------------------------------ MID meadow
c:terrain(function(x) return 64 + 1.5 * sin(x / 30 + 1) end, GRASS.base)
c:terrain(function(x) return 96 + 2 * sin(x / 18) end, "#72bd56")

-- the ring: inner lawn oval (stage floor), very gentle
local RCX, RCY, RX, RY = 95, 89, 68, 15
c:fillMask(E(RCX, RCY + 1, RX - 8, RY - 5), LAWN)
c:fillMask(E(RCX, RCY + 3, 30, 5), "#93d06a")      -- worn spot where the gnome stands

-- grass tufts: dense at edges, sparse + low-contrast in the centre
for i = 0, 260 do
  local x, y = hash(i, 3) % 190, 66 + hash(i, 7) % 48
  local inLawn = ((x - RCX) / (RX - 8)) ^ 2 + ((y - RCY - 1) / (RY - 5)) ^ 2 < 1
  if not inLawn then
    if centre(x) then
      if i % 3 == 0 then px(x, y, "#6cb552") end
    else
      local col = y > 96 and GRASS.deep or GRASS.shade
      px(x, y, col) px(x + 1, y - 1, col) px(x - 1, y - 1, GRASS.hi)
    end
  end
end

------------------------------------------------------------ toadstools
-- toad(x, ybase, w, capH, stemH, kind, edge)
local function toad(x, yb, w, ch, sh, kind, edge)
  local cr = (kind == "far") and MUTED or CAPR
  local hw = floor(w / 2)
  local sw = max(1, floor(w / 5))
  local capY = yb - sh                        -- bottom row of cap
  local stem = c:rect(x - sw, capY, x + sw, yb)
  local cap = E(x, capY, hw, ch):clip(c:rect(x - hw, capY - ch, x + hw, capY))
  local all = stem:copy():add(cap)
  -- ground contact shadow
  c:fillMask(E(x + 1, yb + 1, hw - 1, 1):clip(c:rect(0, yb + 1, 189, yb + 1)), GRASS.shade)
  if edge then c:rim(all, edge) end
  form(stem, STEM, { s = 1 })
  form(cap, cr, { s = w >= 9 and 2 or 1, l = w >= 9 and 1 or nil })
  -- lip: deep underside row
  for xx = x - hw, x + hw do if cap:has(xx, capY) then px(xx, capY, cr.deep) end end
  if w >= 12 then for xx = x - hw + 2, x + hw - 2, 2 do px(xx, capY, STEM.shade) end end
  -- spots
  local spot = (kind == "far") and "#f7d6c8" or P.cream
  if w >= 14 then
    c:fillMask(E(x - floor(hw * .45), capY - floor(ch * .55), 2, 1), spot)
    c:fillMask(E(x + floor(hw * .35), capY - floor(ch * .35), 1, 1), spot)
    px(x - 1, capY - ch + 1, spot) px(x + floor(hw * .7), capY - 2, spot) px(x - hw + 2, capY - 2, spot)
  elseif w >= 7 then
    px(x - 2, capY - ch + 1, spot) px(x + 1, capY - 2, spot) px(x - 1, capY - ch + 1, spot)
  else
    px(x, capY - 1, spot)
  end
  return all
end

-- ring positions, back to front
local N = 22
local list = {}
for i = 0, N - 1 do
  local a = (i + .5) / N * 2 * pi
  local x, y = floor(RCX + cos(a) * RX + .5), floor(RCY + sin(a) * RY + .5)
  local front = y > RCY
  if not (front and abs(x - RCX) < 40) then list[#list + 1] = { x = x, y = y, i = i } end
end
table.sort(list, function(p, q) return p.y < q.y end)
for _, t in ipairs(list) do
  local back = t.y < RCY
  if back and centre(t.x) then
    toad(t.x, t.y, 5, 3, 2, "far", nil)
  elseif back then
    toad(t.x, t.y, 8 + t.i % 2, 4, 3, "mid", P.ember.deep)
  else
    toad(t.x, t.y, 11 + t.i % 3, 6, 4, "mid", P.ember.deep)
  end
end

------------------------------------------------------------ NEAR: stage lanterns (ink edge)
local function lantern(x, ytop, yb)
  local post = c:rect(x, ytop, x + 1, yb)
  local arm = c:rect(x, ytop, x + 4, ytop)
  local lamp = c:rrect(x + 3, ytop + 2, x + 7, ytop + 7, 1)
  local all = post:copy():add(arm):add(lamp)
  c:rim(all, INK)
  c:fillMask(post, P.wood.base) c:fillMask(c:rect(x + 1, ytop, x + 1, yb), P.wood.shade)
  c:fillMask(arm, P.wood.base)
  px(x + 5, ytop + 1, INK)
  c:fillMask(lamp, P.gold.base)
  c:fillMask(c:rect(x + 4, ytop + 3, x + 5, ytop + 5), P.gold.hi)
  px(x + 4, ytop + 3, P.cream)
  c:fillMask(c:rect(x + 3, ytop + 7, x + 7, ytop + 7), P.wood.deep)
  c:fillMask(c:rect(x + 3, ytop + 2, x + 7, ytop + 2), P.wood.shade)
end
lantern(36, 60, 92)
lantern(150, 62, 94)

------------------------------------------------------------ NEAR: big toadstool cluster bottom-left
toad(5, 104, 9, 5, 4, "near", INK)
local big = toad(18, 114, 28, 13, 8, "near", INK)
toad(39, 114, 12, 6, 5, "near", INK)
-- frog quirk on the big cap (cap top at y ~ 112-9-13 = 90)
do
  local fx, fy = 14, 86
  c:paint({
    ".ooo.ooo.",
    "oeeGoeeGo",
    "oeGGoeGGo",
    "ollgggggo",
    "olgggggso",
    "ogpgggsso",
    ".oossgoo.",
    "..o..o...",
  }, fx, fy, { o = INK, e = P.cream, G = INK, g = P.moss.base, l = P.moss.hi, s = P.moss.shade, p = P.petal.base })
end

------------------------------------------------------------ NEAR: foxgloves + fern bottom-right
local function foxglove(x, yb, h)
  local stem = c:rect(x, yb - h, x, yb)
  c:rim(stem, INK)
  c:fillMask(stem, P.moss.shade)
  for k = 0, floor(h / 3) - 1 do
    local yy = yb - h + 1 + k * 3
    local side = (k % 2 == 0) and -1 or 1
    local bell = c:rect(min(x + side, x + side * 2), yy, max(x + side, x + side * 2), yy + 1)
    if k > floor(h / 3) - 3 then bell = c:rect(x - 2, yy, x + 2, yy + 1) end
    c:rim(bell, INK)
    c:fillMask(bell, P.petal.base)
    px(x + side * 2, yy + 1, P.petal.shade)
    px(x + side, yy, P.petal.hi)
  end
end
foxglove(176, 113, 26)
foxglove(184, 113, 20)
foxglove(168, 113, 15)
-- fern blades along the bottom edge (both corners)
local function blade(x, yb, h, lean, col)
  for k = 0, h do px(x + floor(lean * k / h + .5), yb - k, col) end
end
for i = 0, 22 do
  local x = (i < 11) and (i * 5 - 2) or (130 + (i - 11) * 5)
  if not centre(x) or x < 58 or x > 132 then
    blade(x, 114, 3 + hash(i, 5) % 5, (i % 2 == 0) and -2 or 2, (i % 3 == 0) and GRASS.deep or GRASS.shade)
  end
end
-- flowers in the meadow, edges
local FC = { P.petal, P.gold, P.dusk, P.sea, P.cream }
for i = 0, 40 do
  local x, y = hash(i, 11) % 190, 68 + hash(i, 13) % 34
  if not centre(x) then
    local col = FC[1 + i % 5]
    local base = type(col) == "table" and col.base or col
    px(x, y + 1, GRASS.shade)
    px(x, y, P.gold.hi) px(x - 1, y, base) px(x + 1, y, base) px(x, y - 1, base)
  end
end
-- butterfly over the right meadow
px(158, 74, P.dusk.base) px(157, 73, P.dusk.hi) px(160, 74, P.dusk.base) px(161, 73, P.dusk.hi) px(159, 74, INK)

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. SUF .. ".aseprite", png = out .. NAME .. SUF .. ".png", scale = 2 }
