-- puzzles/homer-hedge.gif redraw (pass 2): a bald felt-puppet dad backs slowly into a leafy felt hedge.
-- Leaf clumps grow over him from his back and the shirt hem inwards, his eyes go last, then only hedge.
-- 320x240 (source aspect), 22 frames, per-frame ms (hold, sink, empty), loops forever, solid background.
-- Drawn on a 160x120 half grid (scene mode), written at 2x nearest. No dither: every leaf is a whole clump.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "extras-pixel/"
local G = "/home/user/gnome-venture/game/assets/img/puzzles/"
local W, H = 160, 120

-- timing from the source (29 x 120 ms): a still hold, the slow sink, then the empty hedge
local SINK = 20
local FR = { { p = 0, ms = 800 } }
for i = 1, SINK do FR[#FR+1] = { p = i / SINK, ms = 130 } end
FR[#FR+1] = { p = 2, ms = 700 }

local leaf, moss, wood = GV.R.leaf, GV.R.moss, GV.R.wood
local yel = GV.ramp("#f2c32e")             -- gold family, cartoon yellow skin
local muz = GV.ramp("#c9a96e")             -- soil family stubble
local shirt = GV.ramp("#f1ece0")           -- soil cream, pale
local shorts = GV.ramp("#4a62b8")          -- water family blue
local GAP = leaf.deep                      -- shadow between the leaf clumps
local OL3 = "#2a1a10"

local rng = 11
local function R(n) rng = (rng * 1103515245 + 12345) % 2147483648 return (rng // 65536) % n end

-- one felt leaf clump: rim upper-left, shade crescent and deep edge lower-right, a gloss tick, a vein
local function clump(c, cx, cy, r, ramp, cover, deco)
  local ry = r * 0.82
  local m = c:ellipse(cx, cy, r, ry)
  m:each(function(x, y)
    local col = ramp.base
    if not m:has(x + 2, y + 2) then col = ramp.shade end
    local e = not m:has(x + 1, y) or not m:has(x, y + 1)
    if e and (x - cx) + (y - cy) > -1 then col = ramp.deep
    elseif not m:has(x - 1, y) or not m:has(x, y - 1) then col = ramp.rim end
    c:px(x, y, col)
  end)
  if r >= 4.5 and deco == 0 then
    local gx, gy = math.floor(cx - r * 0.45 + 0.5), math.floor(cy - ry * 0.45 + 0.5)
    c:px(gx, gy, ramp.gloss); c:px(gx + 1, gy, ramp.gloss)
  elseif r >= 4.5 and deco == 1 then
    c:paint({ "s...s", ".s.s.", "..s.." }, math.floor(cx) - 1, math.floor(cy) - 1, { s = ramp.shade })
  end
  if cover then cover:add(m) end
end

-- the dad, drawn whole once on his own canvas; frames copy only the pixels the hedge has not taken
local function drawDad()
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
  c:part(c:rect(62, 106, 112, H + 2), shorts, { cres = 3, gloss = false })
  c:part(c:ellipse(86, 88, 25, 34):clip(c:rect(0, 50, W, 109)), shirt, { cres = 6, pale = true, gloss = { 70, 62 } })
  c:part(c:rrect(103, 64, 111, 104, 3), yel, { cres = 3, gloss = false })     -- arm
  c:part(c:rrect(80, 44, 96, 54, 3), yel, { cres = 2, gloss = false })        -- neck
  c:part(c:rrect(77, 12, 99, 46, 9), yel, { cres = 4, gloss = { 85, 16 } })   -- head
  c:part(c:ellipse(86, 41, 10, 6.5), muz, { cres = 2, gloss = false })        -- stubble muzzle
  c:part(c:ellipse(96, 30, 2.5, 3.5), yel, { flat = true })                   -- ear
  c:part(c:rrect(70, 29, 80, 35, 2), yel, { cres = 2, gloss = false })        -- nose
  -- big round eyes: an umber ring so the cream reads on yellow, then the locked eye
  for _, e in ipairs({ { 73, 20 }, { 80, 21 } }) do
    c:fill(c:rrect(e[1] - 1, e[2] - 1, e[1] + 5, e[2] + 5, 2), "#4a2c1a")
  end
  c:eye(73, 20); c:eye(80, 21)
  local det = c:mask()
  det:add(c:line({ {86, 13}, {88, 10}, {91, 12} }, 1)):add(c:line({ {90, 14}, {93, 11}, {95, 14} }, 1))
  det:add(c:line({ {79, 44}, {85, 45}, {90, 43} }, 1))                        -- mouth
  c:fill(det, "#4a2c1a")
  c:seam({ {75, 55}, {86, 60}, {97, 55} })
  c:button(84, 60)
  local m = c:mask()
  for k in pairs(c.pix) do local x, y = c:xy(k) if c:inside(x, y) then m:set(x, y) end end
  return c, m
end
local dadC, dadM = drawDad()

-- the hedge: felt leaf clumps in tiers, top to bottom, so each row overlaps the one above.
-- Clumps that overlap the dad are his "front" clumps: they grow over him, back and hem first, eyes last.
local HEDGE = {}
local row = 0
for y = 12, H + 6, 7 do
  local off = (row % 2) * 6
  for x = -6 + off, W + 8, 11 do
    local k = R(12)
    HEDGE[#HEDGE+1] = { x + R(5) - 2, y + R(3) - 1, 5.5 + R(3) * 0.5, k < 2 and moss or leaf, deco = R(3) }
  end
  row = row + 1
end
local EX, EY = 80, 24
local smax, FRONT = 0, {}
for _, h in ipairs(HEDGE) do
  local m = GV.canvas{ w = W, h = H, mode = "scene" }:ellipse(h[1], h[2], h[3], h[3] * 0.82)
  local hit = false
  m:each(function(x, y) if dadM:has(x, y) then hit = true end end)
  if hit then
    h.front = true
    h.d = math.sqrt((h[1] - EX) ^ 2 + ((h[2] - EY) * 0.9) ^ 2) + 0.45 * (h[1] - EX)
    smax = math.max(smax, h.d)
    FRONT[#FRONT+1] = h
  end
end
for _, h in ipairs(FRONT) do h.t = math.max(0, 0.82 * (1 - h.d / smax) + (R(7) - 3) * 0.01) end
-- each dad pixel leaves once the clumps around it have grown in (fills the gaps between clumps)
local GONE = {}
dadM:each(function(x, y) GONE[y * W + x] = 0.98 end)
for _, h in ipairs(FRONT) do
  local m = GV.canvas{ w = W, h = H, mode = "scene" }:ellipse(h[1], h[2], h[3] + 2, (h[3] + 2) * 0.82)
  m:each(function(x, y) local k = y * W + x if GONE[k] then GONE[k] = math.min(GONE[k], h.t + 0.13) end end)
end

local GROW = 0.16
local function size(h, p)
  if not h.front then return h[3] end
  local g = math.min(1, math.max(0, (p - h.t) / GROW))
  return h[3] * g * g * (3 - 2 * g)
end

local function drawFrame(p)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
  c:fill(c:rect(0, 0, W - 1, H - 1), GAP)
  -- fence boards along the top, behind the hedge
  c:part(c:rect(-3, -3, W + 2, 12), wood, { cres = 3, gloss = false, outline = false })
  for x = 14, W, 26 do c:fill(c:rect(x, 0, x, 12), wood.deep); c:fill(c:rect(x + 1, 0, x + 1, 12), wood.rim) end
  c:seam({ {0, 3}, {W - 1, 3} })
  for _, h in ipairs(HEDGE) do clump(c, h[1], h[2], h[3], h[4], nil, h.deco) end -- whole hedge behind him
  local cover = c:mask()
  for _, h in ipairs(FRONT) do
    local r = size(h, p)
    if r >= 2.5 then cover:add(c:ellipse(h[1], h[2], r, r * 0.82)) end
  end
  -- the dad: whatever the hedge has not taken yet, without 1 px slivers
  local vis = c:mask()
  dadM:each(function(x, y) if GONE[y * W + x] > p and not cover:has(x, y) then vis:set(x, y) end end)
  vis = vis:shrink(1):grow(1):clip(vis)
  local seen = {}                                   -- and no loose crumbs: drop bits under 24 px
  vis:each(function(x, y)
    local k0 = y * W + x
    if seen[k0] then return end
    local st, comp = { { x, y } }, {}
    seen[k0] = true
    while #st > 0 do
      local q = table.remove(st)
      comp[#comp+1] = q
      for _, d in ipairs({ {1,0},{-1,0},{0,1},{0,-1} }) do
        local nx, ny = q[1] + d[1], q[2] + d[2]
        if vis:has(nx, ny) and c:inside(nx, ny) and not seen[ny * W + nx] then seen[ny * W + nx] = true; st[#st+1] = { nx, ny } end
      end
    end
    if #comp < 24 then for _, q in ipairs(comp) do vis:del(q[1], q[2]) end end
  end)
  vis:each(function(x, y) c:px(x, y, dadC:get(x, y)) end)
  for _, h in ipairs(FRONT) do
    local r = size(h, p)
    if r >= 2.5 then clump(c, h[1], h[2], r, h[4], nil, h.deco) end
  end
  -- clean edge where the leaves overlap him: 1 px dark rim on the leaf side
  if vis:count() > 0 then
    local ring = vis:grow(1):cut(vis)
    ring:each(function(x, y) if dadM:has(x, y) then c:px(x, y, OL3) end end)
  end
  return c:image()
end

local spr = Sprite(W * 2, H * 2, ColorMode.RGB)
local layer = spr.layers[1]
layer.name = "homer-hedge"
for f, fr in ipairs(FR) do
  if f > 1 then spr:newEmptyFrame(f) end
  local img = drawFrame(fr.p)
  if f == 1 then spr.cels[1].image = img; img:saveAs(G .. "homer-hedge-still.png") else spr:newCel(layer, f, img) end
  spr.frames[f].duration = fr.ms / 1000
  local t = GV.check(img)
  assert(t.semi == 0 and t.bw <= 8, "frame " .. f .. ": " .. GV.report(t))
end
pcall(function() app.fs.makeAllDirectories(O .. "puzzles-gif") end)
spr:saveAs(O .. "puzzles-gif/homer-hedge.aseprite")
spr:saveCopyAs(G .. "homer-hedge.gif")
spr:close()
print("saved " .. #FR .. " frames")
