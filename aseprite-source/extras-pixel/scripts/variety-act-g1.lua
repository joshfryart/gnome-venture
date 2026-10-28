-- variety-act-g1.lua : first-pass Do-tab scene cards for 11 rest-stop activities (group g1).
-- chores snack seedswap gossip shells ringtoss haggle notice_riddle porter grind mill_swap
-- Each card is the 63x45 scene window of the 144x108 act cards, drawn on a 63x45 grid at out=2 (126x90).
-- The wooden card frame is added afterwards by variety-act-frame.py (copies the frame of act-hand.png).
-- Params: --script-param root=<repo> out=<dir> only=<slug>
local P = app.params
local ROOT = P.root or "/home/user/gnome-venture"
local OUT = P.out or (ROOT .. "/aseprite-source/extras-pixel/aseprite/")
local PNG = P.png or (ROOT .. "/aseprite-source/extras-pixel/aseprite/png/")
local ONLY = P.only
local GV = dofile(ROOT .. "/aseprite-source/gvlib/gvlib.lua")
local W, H = 63, 45
local min = math.min
local GROUND = 36 -- light grass line row; feet of a standing gnome on row 37

---------------------------------------------------------------- helpers
local function canvas() return GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 0, cres = 2, deep = 0 } end

local ramps = {}
local function R(hex) if not ramps[hex] then ramps[hex] = GV.ramp(hex) end return ramps[hex] end
-- shaded prop part (shade crescent + bounce + rim, no gloss, 1 px outline)
local function part(c, m, hex, o)
  o = o or {}
  if o.gloss == nil then o.gloss = false end
  if o.contact == nil then o.contact = false end
  if o.rim == nil and R(hex).pale then o.rim = false end
  return c:part(m, R(hex), o)
end
-- flat part: base colour + lit rim only
local function flat(c, m, hex, o)
  o = o or {}
  o.flat = true
  if o.contact == nil then o.contact = false end
  if o.rim == nil and R(hex).pale then o.rim = false end
  return c:part(m, R(hex), o)
end
-- unoutlined, unshaded fill
local function box(c, x0, y0, x1, y1, hex) c:fill(c:rect(x0, y0, x1, y1), hex) end
local function pix(c, x, y, hex) c:px(x, y, hex) end
local function dots(c, list, hex) for _, p in ipairs(list) do c:px(p[1], p[2], hex) end end

local SKIN = "#f0c8a0"
local function limb(c, pts, w) -- skin arm with 1 px outline
  return c:part(c:line(pts, w or 2), R(SKIN), { flat = true, rim = false, contact = false })
end

-- background: sky bands, a cloud, rolling hills, grass line, ground and tufts.
-- o: warm (peach sky), hills = {ys per 7-col chunk}, far = far hill chunks, cloud = {x,y}
local function hillsMask(c, top)
  local m = c:mask()
  for x = 0, W - 1 do for y = top[(x // 7) + 1] or top[#top], GROUND - 1 do m:set(x, y) end end
  return m
end
local function bg(c, o)
  o = o or {}
  local s1, s2 = "#a8d4e0", "#cfe8e6"
  if o.warm then s1, s2 = "#e8a87a", "#f4cf98" end
  box(c, 0, 0, W - 1, 12, s1); box(c, 0, 13, W - 1, 20, s2)
  box(c, 0, 21, W - 1, GROUND - 1, "#5e8a44")
  if o.cloud then
    local cx, cy = o.cloud[1], o.cloud[2]
    c:fill(c:rect(cx, cy + 1, cx + 12, cy + 3), "#f4eee0")
    c:fill(c:rect(cx + 3, cy, cx + 10, cy), "#f4eee0")
    c:fill(c:rect(cx + 2, cy + 4, cx + 8, cy + 4), "#f4eee0")
  end
  if o.far then -- paler far hills
    c:fill(hillsMask(c, o.far), "#6f9c52")
  end
  local top = o.hills or { 24, 23, 22, 23, 24, 25, 24, 23, 22 }
  c:fill(hillsMask(c, top), "#5e8a44")
  box(c, 0, GROUND, W - 1, GROUND, "#9cc070")
  box(c, 0, GROUND + 1, W - 1, H - 1, "#7ea85a")
  -- tufts (two stepped dark pixels)
  for _, t in ipairs(o.tufts or { { 3, 41 }, { 9, 43 }, { 27, 42 }, { 50, 41 }, { 58, 43 }, { 41, 44 } }) do
    pix(c, t[1], t[2], "#5e8a44"); pix(c, t[1], t[2] + 1, "#5e8a44"); pix(c, t[1] + 1, t[2], "#5e8a44")
  end
end

-- the gnome sprite (same figure as act-hand), 11 wide x 19 tall, origin top-left. '.' = clear.
local GN = {
  "......b....",
  "....bbcd...",
  "...beeed...",
  "...beeecd..",
  "..beeeeed..",
  "..beeeeecf.",
  ".beeeeeeef.",
  ".beeeeeeecf",
  "bcccccccccf",
  ".bhhhhfhhf.",
  ".biiiiijkb.",
  "bliiiiikld.",
  "blliiiikld.",
  "blliiiikld.",
  "bllkikkklof",
  "dllllklllof",
  "dppppoppppf",
  "dppppfppppf",
  ".dfff.ffff.",
}
local LEG = { b = "#74462a", c = "#8e2e1e", d = "#4a2c1a", e = "#c0442e", f = "#2a1a10", h = SKIN, i = "#f4eee0",
  j = "#e08a7a", k = "#cfc6b0", l = "#4a6e9a", m = "#d4a27a", o = "#34507a", p = "#5a3a22" }
local function mirror(rows)
  local o = {}
  for i, r in ipairs(rows) do o[i] = r:reverse() end
  return o
end
-- c, x0, y0 (top-left), flip (facing left), legend overrides (recolour)
local function gnome(c, x0, y0, flip, ov)
  local leg = LEG
  if ov then leg = {}; for k, v in pairs(LEG) do leg[k] = v end; for k, v in pairs(ov) do leg[k] = v end end
  c:paint(flip and mirror(GN) or GN, x0, y0, leg)
end

local function save(c, slug)
  local t = c:save(OUT .. "variety-act-" .. slug .. ".aseprite", PNG .. "act-" .. slug .. "-scene.png")
  print(slug, GV.report(t))
  assert(t.semi == 0, slug .. " semi-transparent pixels")
end

---------------------------------------------------------------- scenes
local S = {}

-- chores: a gnome hammers a loose picket back onto a fence; stacked logs and a bucket nearby
function S.chores()
  local c = canvas()
  bg(c, { cloud = { 40, 3 }, hills = { 25, 24, 23, 22, 22, 23, 24, 25, 25 } })
  -- log pile (left)
  local logs = { { 8, 33 }, { 15, 33 }, { 11.5, 28 } }
  for _, l in ipairs(logs) do
    part(c, c:rrect(l[1] - 6, l[2] - 3, l[1] + 4, l[2] + 3, 2), "#b07a45")
  end
  for _, l in ipairs(logs) do
    c:fill(c:ellipse(l[1] + 3, l[2], 1.5, 2), "#e6c48a"); pix(c, l[1] + 3, l[2], "#b07a45")
  end
  -- fence: rails, posts, pickets, one loose
  box(c, 34, 29, 62, 30, "#8a4f2a"); box(c, 34, 34, 62, 35, "#8a4f2a")
  for _, px in ipairs({ 37, 45, 53, 61 }) do
    part(c, c:rect(px - 1, 25, px + 1, 38), "#a8703c")
  end
  for _, px in ipairs({ 41, 49, 57 }) do
    part(c, c:poly({ { px - 1, 25 }, { px, 23 }, { px + 2, 25 }, { px + 2, 36 }, { px - 1, 36 } }), "#d9a660")
  end
  -- gnome facing right, hammer raised
  gnome(c, 20, 19, false)
  limb(c, { { 29, 31 }, { 33, 27 }, { 34, 24 } }, 2)
  part(c, c:rect(34, 18, 35, 25), "#8a4f2a", { flat = true })
  part(c, c:rect(31, 16, 38, 20), "#8b8f96")
  -- planks lying on the ground, nails and a chip
  part(c, c:rect(2, 38, 13, 39), "#d9a660", { flat = true })
  dots(c, { { 31, 22 }, { 40, 17 } }, "#fff3c8")
  -- bucket
  part(c, c:poly({ { 15, 33 }, { 22, 33 }, { 21, 38 }, { 16, 38 } }), "#b8a07a", { cres = 2 })
  save(c, "chores")
end

-- snack: a bake stall with a striped awning, a gnome munching a hand pie
function S.snack()
  local c = canvas()
  bg(c, { cloud = { 3, 4 }, hills = { 26, 25, 24, 24, 25, 26, 26, 25, 24 } })
  -- stall: posts, striped awning with scallops
  part(c, c:rect(28, 14, 30, 37), "#a8703c")
  part(c, c:rect(59, 14, 61, 37), "#a8703c")
  local aw = c:rect(27, 7, 62, 14)
  for x = 27, 59, 4 do aw:add(c:ellipse(x + 2, 15, 2, 1.5)) end
  part(c, aw, "#c0442e", { cres = 2 })
  for x = 31, 62, 8 do
    aw:copy():clip(c:rect(x, 0, x + 3, 40)):each(function(px, py)
      local v = c:get(px, py)
      local f, t = R("#c0442e"), R("#f4eee0")
      if v == f.base then c:px(px, py, t.base) elseif v == f.shade then c:px(px, py, t.shade) elseif v == f.rim then c:px(px, py, t.base)
      elseif v == f.bounce then c:px(px, py, t.bounce) end
    end)
  end
  -- counter with checked cloth
  part(c, c:rect(27, 30, 62, 37), "#f4eee0")
  for x = 27, 62, 3 do for y = 31, 37, 3 do
    if ((x - 27) // 3 + (y - 31) // 3) % 2 == 0 then box(c, x, y, min(62, x + 2), min(37, y + 2), "#d86a4a") end
  end end
  part(c, c:rect(27, 29, 62, 31), "#e8d6b0", { flat = true })
  -- baked goods on the counter: pie, loaf, bun
  part(c, c:ellipse(37, 27, 5, 3), "#d9a660"); box(c, 35, 26, 39, 26, "#b8661a"); pix(c, 37, 25, "#b8661a")
  part(c, c:rrect(44, 24, 54, 28, 2), "#c98a4a")
  for x = 46, 52, 3 do pix(c, x, 25, "#e8b870") end
  part(c, c:ellipse(58, 27, 2, 2), "#d9a660", { flat = true })
  -- steam over the pie
  dots(c, { { 36, 22 }, { 37, 20 }, { 36, 18 }, { 38, 21 }, { 39, 19 } }, "#f4eee0")
  -- gnome faces right, a hand pie held up to the beard
  gnome(c, 12, 19, false)
  limb(c, { { 21, 31 }, { 24, 29 }, { 24, 27 } }, 2)
  part(c, c:ellipse(25.5, 25.5, 3, 2.5), "#d9a660")
  box(c, 25, 25, 26, 25, "#b8661a")
  dots(c, { { 5, 28 }, { 7, 25 } }, "#f4eee0")
  save(c, "snack")
end

-- seedswap: two gardeners swap seed packets over a garden bed
function S.seedswap()
  local c = canvas()
  bg(c, { cloud = { 44, 5 }, hills = { 23, 22, 22, 23, 24, 24, 23, 22, 22 } })
  -- trellis with beans, left backdrop
  for _, x in ipairs({ 3, 12 }) do part(c, c:rect(x, 16, x + 1, 36), "#a8703c", { flat = true }) end
  box(c, 3, 21, 13, 21, "#a8703c"); box(c, 3, 27, 13, 27, "#a8703c")
  for _, p in ipairs({ { 5, 18 }, { 7, 24 }, { 9, 19 }, { 11, 25 }, { 6, 30 }, { 10, 31 } }) do
    part(c, c:ellipse(p[1], p[2], 1.5, 2), "#4f9a45", { flat = true })
  end
  -- seed bed front: tilled rows with sprouts
  part(c, c:rect(0, 38, 62, 44), "#9a6b3f", { cres = 3, outline = false })
  for x = 1, 62, 6 do box(c, x, 41, x + 3, 41, "#7a4a1f") end
  for _, x in ipairs({ 5, 17, 29, 47, 57 }) do
    part(c, c:ellipse(x, 38, 2, 1.5), "#7ab55c", { flat = true })
    pix(c, x, 39, "#4f9a45")
  end
  -- player gnome (left) holding out a packet
  gnome(c, 12, 19, false)
  limb(c, { { 21, 31 }, { 25, 30 }, { 27, 29 } }, 2)
  part(c, c:rect(26, 22, 31, 29), "#f4eee0", { flat = true })
  box(c, 27, 25, 30, 25, "#c0442e"); pix(c, 28, 23, "#7ab55c"); pix(c, 29, 24, "#7ab55c"); pix(c, 28, 27, "#d9a660"); pix(c, 29, 27, "#d9a660")
  -- old gardener (right): straw hat, white beard, green tunic, holding out seeds
  local ov = { e = "#d9b060", c = "#8a6a30", b = "#a8803c", d = "#6a4a20", l = "#6a9a4e", o = "#4a7a38", k = "#b8c8a8" }
  gnome(c, 38, 19, true, ov)
  -- wide brim
  box(c, 36, 27, 49, 27, "#c9a040"); box(c, 37, 28, 48, 28, "#8a6a30")
  limb(c, { { 38, 31 }, { 34, 30 }, { 32, 28 } }, 2)
  part(c, c:ellipse(32, 26, 2.5, 2.5), "#7a4a1f", { flat = true })
  pix(c, 31, 25, "#c98a4a"); pix(c, 33, 27, "#c98a4a")
  -- watering can and a flower pot
  part(c, c:rect(54, 32, 59, 37), "#8b8f96")
  part(c, c:rect(60, 29, 61, 32), "#8b8f96", { flat = true })
  part(c, c:poly({ { 50, 34 }, { 54, 34 }, { 53, 37 }, { 51, 37 } }), "#c0442e", { cres = 1 })
  part(c, c:ellipse(52, 31, 2, 3), "#e46a9b", { flat = true })
  pix(c, 52, 33, "#4f9a45")
  -- little glints between the hands
  dots(c, { { 31, 18 }, { 30, 16 }, { 33, 17 } }, "#fff3c8")
  save(c, "seedswap")
end

-- gossip: two gnomes share a bench; the old-timer talks, the gnome leans in with a hand to the ear
function S.gossip()
  local c = canvas()
  bg(c, { cloud = { 24, 3 }, hills = { 27, 26, 25, 25, 26, 27, 27, 26, 26 } })
  -- inn wall segment with a lit window
  part(c, c:rect(0, 12, 17, 36), "#c9a96e", { cres = 3 })
  for y = 14, 35, 4 do box(c, 1, y, 16, y, "#a8803c") end
  part(c, c:rect(4, 17, 12, 26), "#5e2f1e", { flat = true })
  box(c, 5, 18, 11, 25, "#f5cf6a"); box(c, 8, 18, 8, 25, "#5e2f1e"); box(c, 5, 21, 11, 21, "#5e2f1e")
  box(c, 5, 24, 11, 25, "#e8a317")
  part(c, c:rect(0, 9, 19, 13), "#8e3a2a", { cres = 2 })
  -- bench legs, then the two gnomes, then the seat plank over their laps
  part(c, c:rect(19, 33, 21, 39), "#8a4f2a", { flat = true })
  part(c, c:rect(49, 33, 51, 39), "#8a4f2a", { flat = true })
  -- the old-timer (right, facing left): purple hat, grey beard, a raised finger
  local ov = { e = "#7b66b4", c = "#5a4a90", b = "#9a88cc", d = "#3a2c66", l = "#8a7a52", o = "#6a5c3a", k = "#c8c4cc", i = "#e8e4ec" }
  gnome(c, 36, 18, true, ov)
  limb(c, { { 44, 31 }, { 47, 28 }, { 47, 25 } }, 2)
  -- player gnome (left, facing right), hand cupped to the ear
  gnome(c, 23, 18, false)
  limb(c, { { 24, 31 }, { 21, 29 }, { 21, 26 } }, 2)
  part(c, c:rect(18, 32, 52, 33), "#b07a45")
  -- speech bubble with three dots and a tail
  part(c, c:ellipse(46.5, 8, 9, 5), "#f4eee0", { flat = true, rim = false })
  part(c, c:poly({ { 42, 12 }, { 46, 12 }, { 41, 17 } }), "#f4eee0", { flat = true, rim = false, outline = false })
  box(c, 42, 12, 46, 12, "#f4eee0")
  box(c, 41, 8, 42, 9, "#4a2c1a"); box(c, 46, 8, 47, 9, "#4a2c1a"); box(c, 51, 8, 52, 9, "#4a2c1a")
  save(c, "gossip")
end

-- shells: three walnut shells on a table, one lifted to show the acorn
function S.shells()
  local c = canvas()
  bg(c, { cloud = { 24, 2 }, hills = { 24, 23, 24, 25, 24, 23, 24, 25, 24 } })
  -- bunting line across the top
  local cols = { "#c0442e", "#f5cf6a", "#3f8fb0", "#e46a9b", "#7ab55c" }
  local n = 0
  for x = 0, 62, 5 do
    local sag = math.floor(3 * math.sin((x / 62) * math.pi) + 0.5)
    local y = 4 + sag
    box(c, x, y, x + 1, y, "#4a2c1a")
    n = n + 1
    flat(c, c:poly({ { x, y + 1 }, { x + 4, y + 1 }, { x + 2, y + 5 } }), cols[n % 5 + 1], { outline = false })
  end
  -- table: light plank top, dark legs
  part(c, c:rect(24, 30, 62, 33), "#e0b878")
  part(c, c:rect(27, 34, 29, 40), "#8a4f2a", { flat = true })
  part(c, c:rect(58, 34, 60, 40), "#8a4f2a", { flat = true })
  local function dome(cx, dy)
    part(c, c:poly({ { cx - 6, 30 + dy }, { cx - 5, 26 + dy }, { cx - 3, 24 + dy }, { cx + 3, 24 + dy }, { cx + 5, 26 + dy }, { cx + 6, 30 + dy } }), "#7a4a24", { cres = 2 })
    box(c, cx, 25 + dy, cx, 29 + dy, "#4e2a14")
    box(c, cx - 3, 26 + dy, cx - 3, 27 + dy, "#a8703c")
  end
  dome(31, 0); dome(58, 0)
  -- the acorn under the lifted middle shell
  part(c, c:ellipse(44, 27.5, 3, 2.5), "#c98a4a")
  part(c, c:rect(41, 24, 47, 25), "#8a4f2a", { flat = true })
  pix(c, 44, 23, "#5a3a22")
  dome(44, -10)
  -- gnome pointing at the lifted shell
  gnome(c, 7, 19, false)
  limb(c, { { 16, 31 }, { 22, 26 }, { 27, 22 } }, 2)
  dots(c, { { 38, 12 }, { 50, 12 }, { 52, 15 }, { 36, 15 } }, "#fff3c8")
  save(c, "shells")
end

-- ringtoss: gnome has just lobbed a willow ring at a board of pegs
function S.ringtoss()
  local c = canvas()
  bg(c, { cloud = { 6, 3 }, hills = { 22, 22, 23, 24, 25, 25, 24, 23, 22 }, far = { 20, 19, 19, 20, 21, 21, 20, 19, 19 } })
  -- apple tree at the far right
  part(c, c:rect(57, 21, 59, 36), "#8a4f2a", { flat = true })
  part(c, c:ellipse(58, 15, 8, 7), "#4f9a45", { cres = 3 })
  dots(c, { { 54, 13 }, { 60, 16 }, { 57, 18 } }, "#c0442e")
  -- ring-toss stand: striped front, three pegs
  local stand = c:rect(27, 33, 55, 38)
  part(c, stand, "#c0442e")
  for x = 31, 55, 8 do
    stand:copy():clip(c:rect(x, 0, x + 3, 50)):each(function(px, py)
      local v = c:get(px, py)
      local f, t = R("#c0442e"), R("#f4eee0")
      if v == f.base or v == f.rim then c:px(px, py, t.base) elseif v == f.shade then c:px(px, py, t.shade) elseif v == f.bounce then c:px(px, py, t.bounce) end
    end)
  end
  part(c, c:rect(26, 31, 56, 33), "#d9a660", { flat = true })
  local ringm = c:ellipse(41, 28, 5, 2.5):cut(c:ellipse(41, 28, 3, 1.2))
  flat(c, ringm, "#e8a317", { outline = false })
  for _, px in ipairs({ 32, 41, 50 }) do
    part(c, c:rect(px - 1, 22, px, 31), "#8a4f2a", { flat = true })
  end
  -- front half of the landed ring drawn over its peg
  ringm:copy():clip(c:rect(0, 29, 70, 40)):each(function(x, y) c:px(x, y, "#e8a317") end)
  -- ring in flight with a dotted arc
  flat(c, c:ellipse(30.5, 8.5, 4, 3):cut(c:ellipse(30.5, 8.5, 2, 1)), "#e8a317")
  dots(c, { { 24, 13 }, { 22, 17 }, { 20, 21 }, { 18, 25 }, { 27, 11 } }, "#fff3c8")
  -- gnome in a follow-through, arm up
  gnome(c, 6, 19, false)
  limb(c, { { 15, 30 }, { 18, 27 }, { 19, 23 } }, 2)
  box(c, 22, 40, 25, 40, "#f4eee0")
  save(c, "ringtoss")
end

-- haggle: gnome raises a coin to a fruit stall; the sign shows a coin cut in half
function S.haggle()
  local c = canvas()
  bg(c, { cloud = { 46, 4 }, hills = { 25, 24, 24, 25, 26, 26, 25, 24, 24 } })
  -- tent: striped canopy, two posts
  part(c, c:rect(3, 14, 5, 37), "#a8703c", { flat = true })
  part(c, c:rect(34, 14, 36, 37), "#a8703c", { flat = true })
  local aw = c:rect(2, 6, 37, 13)
  for x = 2, 34, 4 do aw:add(c:ellipse(x + 2, 14, 2, 1.5)) end
  part(c, aw, "#3f8fb0", { cres = 2 })
  for x = 6, 37, 8 do
    aw:copy():clip(c:rect(x, 0, x + 3, 40)):each(function(px, py)
      local v = c:get(px, py)
      local f, t = R("#3f8fb0"), R("#f4eee0")
      if v == f.base or v == f.rim then c:px(px, py, t.base) elseif v == f.shade then c:px(px, py, t.shade) elseif v == f.bounce then c:px(px, py, t.bounce) end
    end)
  end
  -- hanging price board: a coin and a half-coin
  part(c, c:rect(10, 16, 28, 24), "#f4eee0", { flat = true })
  part(c, c:ellipse(15, 20, 3, 3), "#e8a317", { flat = true, outline = false })
  box(c, 14, 19, 15, 20, "#f5cf6a")
  part(c, c:ellipse(23, 20, 3, 3), "#e8a317", { flat = true, outline = false })
  box(c, 23, 17, 26, 23, "#f4eee0"); box(c, 22, 17, 22, 23, "#e8a317")
  box(c, 18, 20, 19, 20, "#4a2c1a")
  -- counter with fruit
  part(c, c:rect(2, 31, 37, 37), "#b07a45")
  box(c, 2, 33, 37, 33, "#8a4f2a")
  for _, x in ipairs({ 6, 12, 18 }) do part(c, c:ellipse(x, 29, 2.5, 2.5), "#c0442e", { flat = true }) end
  for _, x in ipairs({ 26, 31 }) do part(c, c:ellipse(x, 29, 2.5, 2.5), "#7ab55c", { flat = true }) end
  -- gnome faces left, a coin held up between finger and thumb
  gnome(c, 44, 19, true)
  limb(c, { { 44, 31 }, { 41, 28 }, { 41, 24 } }, 2)
  part(c, c:ellipse(41, 21.5, 2.5, 2.5), "#e8a317", { flat = true })
  pix(c, 40, 20, "#fff1c8")
  dots(c, { { 37, 19 }, { 45, 17 }, { 37, 24 } }, "#fff3c8")
  save(c, "haggle")
end

-- notice_riddle: a notice post with a pinned riddle (a big question mark), a jar of petals at its foot
function S.notice_riddle()
  local c = canvas()
  bg(c, { cloud = { 2, 2 }, hills = { 24, 23, 23, 24, 25, 24, 23, 23, 24 } })
  -- post and board
  part(c, c:rect(46, 21, 48, 37), "#8a4f2a", { flat = true })
  part(c, c:rect(32, 6, 62, 22), "#b07a45")
  box(c, 33, 7, 61, 7, "#d9a660")
  -- pinned parchment
  part(c, c:rect(37, 9, 51, 20), "#f4eee0", { flat = true })
  c:paint({
    "..uuuu..",
    ".uu..uu.",
    ".....uu.",
    "....uu..",
    "...uu...",
    "...uu...",
    "........",
    "...uu...",
  }, 40, 10, { u = "#4a2c1a" })
  pix(c, 38, 10, "#c0442e"); pix(c, 50, 10, "#c0442e")
  -- second smaller note
  part(c, c:rect(54, 10, 60, 17), "#f5cf6a", { flat = true })
  box(c, 55, 12, 59, 12, "#b8661a"); box(c, 55, 14, 58, 14, "#b8661a")
  -- jar of petals at the foot
  part(c, c:rect(52, 30, 59, 37), "#c8ecdc", { flat = true })
  part(c, c:rect(52, 28, 59, 29), "#a8703c", { flat = true })
  box(c, 53, 32, 58, 36, "#e46a9b"); box(c, 55, 34, 56, 35, "#f6b8cf"); pix(c, 54, 33, "#f6b8cf")
  -- gnome with a hand on the chin, looking up
  gnome(c, 22, 19, false)
  limb(c, { { 30, 32 }, { 31, 31 }, { 30, 30 } }, 2)
  dots(c, { { 34, 25 }, { 35, 23 } }, "#f4eee0")
  save(c, "notice_riddle")
end

-- porter: a gnome totes a sack from the cart to the shed
function S.porter()
  local c = canvas()
  bg(c, { cloud = { 24, 3 }, hills = { 26, 25, 24, 24, 25, 26, 26, 27, 27 } })
  -- worn path
  box(c, 0, 39, 62, 41, "#c9a96e"); dots(c, { { 5, 40 }, { 20, 40 }, { 36, 40 }, { 50, 40 } }, "#a8803c")
  -- shed (right): planks, roof, open door with a sack inside
  part(c, c:rect(46, 22, 62, 37), "#b07a45")
  for x = 49, 61, 4 do box(c, x, 23, x, 36, "#8a4f2a") end
  part(c, c:poly({ { 43, 23 }, { 54, 13 }, { 62, 13 }, { 62, 23 } }), "#c0442e", { cres = 3 })
  part(c, c:rect(51, 28, 59, 37), "#4a2c1a", { flat = true, outline = false })
  part(c, c:rrect(53, 31, 58, 37, 2), "#f4eee0")
  box(c, 54, 30, 56, 30, "#cfc6b0")
  -- cart (left), heaped with sacks
  part(c, c:rect(0, 30, 13, 35), "#a8703c")
  box(c, 0, 32, 13, 32, "#8a4f2a")
  part(c, c:rrect(1, 23, 6, 30, 2), "#f4eee0"); part(c, c:rrect(7, 25, 12, 30, 2), "#e6dcc4")
  part(c, c:ellipse(6.5, 37, 3.5, 3.5), "#5a3a22"); pix(c, 6, 37, "#c9a96e")
  -- sack on the gnome's back, tied at the top, one hand steadying it
  part(c, c:poly({ { 22, 34 }, { 21, 27 }, { 24, 21 }, { 29, 21 }, { 32, 27 }, { 32, 35 } }), "#e8dcc0", { rim = false })
  box(c, 24, 21, 28, 22, "#cfc6b0"); box(c, 23, 23, 29, 23, "#e8a317")
  gnome(c, 30, 19, false)
  limb(c, { { 30, 34 }, { 27, 35 }, { 24, 33 } }, 2)
  dots(c, { { 19, 40 }, { 24, 41 } }, "#a8803c")
  save(c, "porter")
end

-- grind: inside the mill, a gnome leans on the sweep to turn the millstone; flour pours out
function S.grind()
  local c = canvas()
  bg(c, { hills = { 24, 24, 24, 24, 24, 24, 24, 24, 24 } })
  -- mill wall of planks over the whole backdrop
  box(c, 0, 0, W - 1, GROUND - 1, "#c9a96e")
  for x = 3, W - 1, 8 do box(c, x, 0, x, GROUND - 1, "#a8803c") end
  box(c, 0, 0, W - 1, 1, "#8a4f2a")
  -- window with daylight
  part(c, c:rect(19, 5, 29, 15), "#8a4f2a", { flat = true })
  box(c, 20, 6, 28, 14, "#a8d4e0"); box(c, 24, 6, 24, 14, "#8a4f2a"); box(c, 20, 10, 28, 10, "#8a4f2a")
  -- hanging sack on a rope
  box(c, 56, 2, 56, 8, "#8a4f2a")
  part(c, c:rrect(53, 9, 59, 17, 2), "#e8dcc0", { rim = false }); box(c, 55, 8, 57, 8, "#cfc6b0")
  -- floor boards
  box(c, 0, GROUND, W - 1, H - 1, "#a8703c")
  box(c, 0, GROUND, W - 1, GROUND, "#d9a660")
  for x = 4, W - 1, 12 do box(c, x, 38, x, H - 1, "#8a4f2a") end
  box(c, 0, 42, W - 1, 42, "#8a4f2a")
  -- the millstone: stone drum, lighter top with a groove, wooden shaft
  local drum = c:rect(17, 31, 51, 34); drum:add(c:ellipse(34, 34, 17, 4))
  part(c, drum, "#8b8f96", { cres = 3 })
  part(c, c:ellipse(34, 31, 17, 4), "#c9c5bc", { cres = 3 })
  c:fill(c:ellipse(34, 31, 11, 2.5):edge(), "#a8a69e")
  part(c, c:rect(33, 16, 35, 30), "#8a4f2a", { flat = true })
  -- the sweep: one long pole through the shaft, handle toward the gnome
  part(c, c:line({ { 46, 22 }, { 13, 31 } }, 2), "#d9a660", { flat = true })
  part(c, c:rect(33, 20, 35, 24), "#8a4f2a", { flat = true })
  -- gnome pushes the sweep
  gnome(c, 2, 19, false)
  limb(c, { { 11, 32 }, { 13, 31 }, { 15, 31 } }, 2)
  -- flour spout, falling flour and a sack on the right
  part(c, c:poly({ { 52, 28 }, { 58, 28 }, { 58, 31 }, { 54, 31 } }), "#a8703c", { flat = true })
  box(c, 56, 31, 57, 34, "#f4eee0")
  part(c, c:rrect(52, 34, 60, 40, 2), "#e8dcc0", { rim = false })
  box(c, 54, 33, 58, 34, "#f4eee0")
  dots(c, { { 51, 36 }, { 61, 32 }, { 50, 33 } }, "#f4eee0")
  save(c, "grind")
end

-- mill_swap: a gnome tips a bucket of kitchen scraps into a compost bin; a tied bag of compost waits
function S.mill_swap()
  local c = canvas()
  bg(c, { cloud = { 4, 3 }, hills = { 24, 23, 22, 23, 24, 25, 24, 23, 22 } })
  -- apple tree behind the bin
  part(c, c:rect(54, 17, 57, 36), "#8a4f2a", { flat = true })
  part(c, c:ellipse(55, 11, 9, 7), "#4f9a45", { cres = 3 })
  dots(c, { { 51, 9 }, { 59, 12 }, { 55, 14 } }, "#c0442e")
  -- slatted compost bin
  part(c, c:rect(37, 27, 53, 37), "#8a4f2a")
  for x = 39, 52, 4 do box(c, x, 27, x, 36, "#5e2f1e") end
  box(c, 37, 31, 53, 31, "#5e2f1e")
  part(c, c:ellipse(45, 27, 8, 2), "#4a3a2a", { flat = true })
  dots(c, { { 42, 26 }, { 46, 25 }, { 49, 26 } }, "#7ab55c")
  -- falling scraps: apple core, peel, leaf, crust
  part(c, c:rect(33, 20, 35, 24), "#f4eee0", { flat = true }); box(c, 33, 21, 35, 21, "#c0442e"); box(c, 33, 23, 35, 23, "#c0442e")
  part(c, c:rect(37, 15, 40, 17), "#f5cf6a", { flat = true })
  part(c, c:rect(41, 19, 44, 21), "#7ab55c", { flat = true })
  part(c, c:rect(30, 13, 32, 15), "#d9a660", { flat = true })
  -- gnome tipping a bucket, facing right
  gnome(c, 15, 19, false)
  limb(c, { { 24, 31 }, { 27, 29 }, { 28, 26 } }, 2)
  part(c, c:poly({ { 26, 24 }, { 33, 27 }, { 32, 31 }, { 27, 28 } }), "#8b8f96", { flat = true })
  box(c, 27, 25, 29, 25, "#4a3a2a")
  -- the finished compost bag with a sprout, left
  part(c, c:poly({ { 1, 37 }, { 0, 31 }, { 3, 27 }, { 9, 27 }, { 12, 31 }, { 11, 37 } }), "#7a4a1f")
  box(c, 3, 27, 8, 28, "#e8a317"); pix(c, 5, 25, "#4f9a45"); pix(c, 6, 24, "#7ab55c"); pix(c, 4, 25, "#7ab55c"); pix(c, 5, 26, "#4f9a45")
  box(c, 3, 33, 9, 33, "#9a6b3f")
  save(c, "mill_swap")
end

local ORDER = { "chores", "snack", "seedswap", "gossip", "shells", "ringtoss", "haggle", "notice_riddle", "porter", "grind", "mill_swap" }
for _, slug in ipairs(ORDER) do
  if not ONLY or ONLY == "" or ONLY == slug then S[slug]() end
end
