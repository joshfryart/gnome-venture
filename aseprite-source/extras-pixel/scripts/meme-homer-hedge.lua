-- puzzles/homer-hedge.gif redraw (pass 4): a bald felt-puppet dad backs slowly into a leafy felt hedge.
-- Leaf clumps grow over him from his back and the shirt hem inwards; the face shrinks last as a ring
-- of leaves closing on his big eyes (graded, no jump), then only the eyes peek over the leaves, blink,
-- slip down, then only hedge. Loop seam: the leaves rustle and he steps back out in two quick frames.
-- Pass 4: big protruding cartoon eyes, collar + placket seam, edge stitch on shirt and head, varied
-- hedge (big stitched clumps, leaf ticks), denser sink near the end. 320x240, 24 frames, loops forever.
-- Drawn on a 160x120 half grid (scene mode), written at 2x nearest. No dither: every leaf is a whole clump.
-- HOMER_OUT=<dir> writes the three outputs into <dir> instead (for test renders).
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "extras-pixel/puzzles-gif/"
local G = "/home/user/gnome-venture/game/assets/img/puzzles/"
local TEST = os.getenv("HOMER_OUT")
if TEST and TEST ~= "" then O = TEST .. "/"; G = TEST .. "/" end
local W, H = 160, 120

-- timing (source: 29 x 120 ms). A still hold, the slow sink (denser towards the end, where the face
-- closes up), the eye beat, the empty hedge, a rustle, and two quick frames of him stepping back out.
local PS = os.getenv("HOMER_PS")          -- test hook: a comma list of sink p values
local SINKP = { 0.07, 0.15, 0.23, 0.31, 0.39, 0.47, 0.55, 0.62, 0.67, 0.71, 0.75, 0.78, 0.81, 0.84 }
if PS and PS ~= "" then SINKP = {} for v in PS:gmatch("[^,]+") do SINKP[#SINKP+1] = tonumber(v) end end
local FR = { { p = 0, ms = 800 } }
for i, p in ipairs(SINKP) do FR[#FR+1] = { p = p, ms = i == #SINKP and 160 or 120 } end
for _, e in ipairs({ { 0, 380 }, { 0, 110, true }, { 2, 160 }, { 5, 130 } }) do
  FR[#FR+1] = { p = 1, eye = e[1], ms = e[2], blink = e[3] }
end
FR[#FR+1] = { p = 2, ms = 650 }
FR[#FR+1] = { p = 2, rus = 1, ms = 110 }
FR[#FR+1] = { p = 2, rus = 2, ms = 110 }
FR[#FR+1] = { p = 0.42, ms = 90 }
FR[#FR+1] = { p = 0.12, ms = 90 }
assert(#FR <= 24 or PS, "too many frames: " .. #FR)

local leaf, moss, wood = GV.R.leaf, GV.R.moss, GV.R.wood
local dark = GV.ramp("#3f7a3a", { gloss = "#a4b86a", dot = "#c8d77a", rim = "#7ab55c", shade = "#2f5a2a", deep = "#1f3f3a", bounce = "#4a8a3e" }) -- leaf family, shaded clumps
local yel = GV.ramp("#f2c32e")             -- gold family, cartoon yellow skin
local muz = GV.ramp("#c9a96e")             -- soil family stubble
local shirt = GV.ramp("#f1ece0")           -- soil cream, pale
local shorts = GV.ramp("#4a62b8")          -- water family blue
local GAP = leaf.deep                      -- shadow between the leaf clumps
local OL2, OL3 = "#4a2c1a", "#2a1a10"
local CREAM, CREAMS = GV.C.halo, "#d8c49a"

local rng = 11
local function R(n) rng = (rng * 1103515245 + 12345) % 2147483648 return (rng // 65536) % n end

-- one felt leaf clump: rim upper-left, shade crescent and deep edge lower-right, a gloss tick, a vein
-- deco 0 = gloss tick, 1 = leaf vein, 2 = plain; big clumps get a thread-gold edge stitch on the lit side
local function clump(c, cx, cy, r, ramp, deco, big)
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
  if big and r >= 7 then
    -- edge stitch 2 px inside, lit half only, every third diagonal
    local inner = m:shrink(2)
    inner:cut(inner:shrink(1))
    inner:each(function(x, y)
      if (x + y) % 3 == 0 and (x - cx) + (y - cy) <= 0 then c:px(x, y, GV.C.gold) end
    end)
    local gx, gy = math.floor(cx - r * 0.2 + 0.5), math.floor(cy - ry * 0.2 + 0.5)
    c:px(gx, gy, ramp.gloss); c:px(gx + 1, gy, ramp.gloss); c:px(gx + 2, gy + 1, ramp.gloss)
  elseif r >= 4.5 and deco == 0 then
    local gx, gy = math.floor(cx - r * 0.45 + 0.5), math.floor(cy - ry * 0.45 + 0.5)
    c:px(gx, gy, ramp.gloss); c:px(gx + 1, gy, ramp.gloss)
  elseif r >= 4.5 and deco == 1 then
    c:paint({ "s...s", ".s.s.", "..s.." }, math.floor(cx) - 1, math.floor(cy) - 1, { s = ramp.shade })
  end
end

-- big cartoon eye: 9x9 cream disc with an umber ring, shaded lower-right, 3x3 pupil with a glint
local EYE_TL = { { 76, 17 }, { 67, 16 } }   -- back (right) eye first, then the front eye overlaps it
local function bigEye(c, x0, y0)
  local m = c:rrect(x0, y0, x0 + 8, y0 + 8, 3)
  c:fill(m:grow(1), OL2)
  m:each(function(x, y) c:px(x, y, (m:has(x + 2, y + 2) and m:has(x + 1, y + 1)) and CREAM or CREAMS) end)
  c:fill(c:rect(x0 + 3, y0 + 3, x0 + 5, y0 + 5), OL3)
  c:px(x0 + 3, y0 + 3, CREAM)
  c:px(x0 + 2, y0 + 1, "#fff3c8"); c:px(x0 + 1, y0 + 2, "#fff3c8")
  return m:grow(1)
end

-- the dad, drawn whole once on his own canvas; frames copy only the pixels the hedge has not taken
local EYEBOX
local function drawDad()
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
  c:part(c:rect(62, 106, 112, H + 2), shorts, { cres = 3, gloss = false })
  local body = c:ellipse(86, 88, 25, 34):clip(c:rect(0, 50, W, 109))
  c:part(body, shirt, { cres = 6, pale = true, gloss = { 70, 66 }, stitch = { side = "lit" } })
  c:part(c:rrect(103, 64, 111, 104, 3), yel, { cres = 3, gloss = false })     -- arm
  c:part(c:rrect(80, 44, 96, 54, 3), yel, { cres = 2, gloss = false })        -- neck
  -- collar flaps
  c:part(c:poly({ {76, 51}, {87, 61}, {87, 55}, {81, 51} }), shirt, { cres = 2, pale = true, gloss = false })
  c:part(c:poly({ {87, 55}, {87, 61}, {98, 51}, {93, 51} }), shirt, { cres = 2, pale = true, gloss = false })
  c:part(c:rrect(77, 12, 99, 46, 9), yel, { cres = 4, gloss = { 88, 16 }, stitch = { side = "lit" } }) -- head
  c:part(c:ellipse(86, 41, 10, 6.5), muz, { cres = 2, gloss = false })        -- stubble muzzle
  c:part(c:ellipse(96, 31, 2.5, 3.5), yel, { flat = true })                   -- ear
  c:part(c:rrect(68, 27, 79, 33, 3), yel, { cres = 2, gloss = { 70, 28 } })   -- nose
  EYEBOX = c:mask()
  for _, e in ipairs(EYE_TL) do EYEBOX:add(bigEye(c, e[1], e[2])) end
  local det = c:mask()
  det:add(c:line({ {87, 12}, {89, 9}, {92, 11} }, 1)):add(c:line({ {91, 13}, {94, 10}, {96, 13} }, 1)) -- hair
  det:add(c:line({ {93, 25}, {94, 23}, {95, 25}, {96, 23}, {97, 25} }, 1))   -- the M by the ear
  det:add(c:line({ {80, 44}, {85, 45}, {89, 43} }, 1))                        -- mouth
  c:fill(det, OL2)
  c:seam({ {87, 66}, {87, 104} })                                             -- placket
  c:button(85, 61)
  local m = c:mask()
  for k in pairs(c.pix) do local x, y = c:xy(k) if c:inside(x, y) then m:set(x, y) end end
  return c, m
end
local dadC, dadM = drawDad()
local EYES = dadM:copy():clip(EYEBOX)
local EX, EY = 76, 21                      -- between the eyes: the last thing the leaves reach

-- the hedge: felt leaf clumps in tiers, top to bottom, so each row overlaps the one above.
-- A few big stitched clumps break up the grid. Clumps that overlap the dad are his "front" clumps:
-- they grow over him, back and hem first, eyes last.
local HEDGE = {}
local row = 0
local NROW = 0
for y = 12, H + 6, 7 do NROW = NROW + 1 end
for y = 12, H + 6, 7 do
  local off = (row % 2) * 6
  for x = -6 + off, W + 8, 11 do
    local k = R(12)
    local ramp
    if row <= 1 then ramp = k < 6 and dark or leaf
    elseif row >= NROW - 2 then ramp = k < 5 and dark or (k < 7 and moss or leaf)
    else ramp = k < 3 and moss or (k < 4 and dark or leaf) end
    HEDGE[#HEDGE+1] = { x + R(5) - 2, y + R(3) - 1, 5.5 + R(3) * 0.5, ramp, deco = R(3) }
    -- now and then a big clump sits on top of this row (kept off the dad's face)
    if R(9) == 0 and row >= 1 and row <= NROW - 2 then
      local bx, by = x + 3 + R(4), y + 2
      if math.abs(bx - EX) > 26 or by > 60 then
        HEDGE[#HEDGE+1] = { bx, by, 8 + R(2), R(2) == 0 and moss or leaf, deco = 2, big = true }
      end
    end
  end
  row = row + 1
end
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
for _, h in ipairs(FRONT) do h.t = math.max(0, 0.80 * (1 - h.d / smax) + (R(7) - 3) * 0.01) end
-- each dad pixel leaves once the clumps around it have grown in (fills the gaps between clumps)
local GONE = {}
dadM:each(function(x, y) GONE[y * W + x] = 0.98 end)
for _, h in ipairs(FRONT) do
  local m = GV.canvas{ w = W, h = H, mode = "scene" }:ellipse(h[1], h[2], h[3] + 2, (h[3] + 2) * 0.82)
  m:each(function(x, y) local k = y * W + x if GONE[k] then GONE[k] = math.min(GONE[k], h.t + 0.13) end end)
end
-- the face closes in as a ring around the eyes: head pixels leave by distance from the eyes, so the
-- last frames go head -> face -> nose and brow -> just the eyes, with no jump
local HR = 24
dadM:each(function(x, y)
  if y <= 56 then
    local d = math.sqrt((x - EX) ^ 2 + ((y - EY) * 1.15) ^ 2)
    local k = y * W + x
    GONE[k] = math.min(GONE[k], 0.62 + 0.36 * math.max(0, 1 - d / HR))
  end
end)
EYES:each(function(x, y) GONE[y * W + x] = 1.5 end)
local EYEBOT = select(4, EYEBOX:bbox())

local GROW = 0.16
local function size(h, p)
  if not h.front then return h[3] end
  local g = math.min(1, math.max(0, (p - h.t) / GROW))
  return h[3] * g * g * (3 - 2 * g)
end

-- rustle: the clumps around where he went in nudge 1 px, alternating
local function nudge(h, i, rus)
  if not rus or not h.front then return 0, 0 end
  local s = ((i + rus) % 2 == 0) and 1 or -1
  return s, (rus == 2 and (i % 3 == 0) and -1 or 0)
end

local function drawFrame(fr)
  local p, eye, rus = fr.p, fr.eye, fr.rus
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
  c:fill(c:rect(0, 0, W - 1, H - 1), GAP)
  -- fence boards along the top, behind the hedge
  c:part(c:rect(-3, -3, W + 2, 12), wood, { cres = 3, gloss = false, outline = false })
  for x = 14, W, 26 do c:fill(c:rect(x, 0, x, 12), wood.deep); c:fill(c:rect(x + 1, 0, x + 1, 12), wood.rim) end
  c:seam({ {0, 3}, {W - 1, 3} })
  for i, h in ipairs(HEDGE) do
    local dx, dy = nudge(h, i, rus)
    clump(c, h[1] + dx, h[2] + dy, h[3], h[4], h.deco, h.big)  -- whole hedge behind him
  end
  local cover = c:mask()
  for _, h in ipairs(FRONT) do
    local r = size(h, p)
    if r >= 2.5 then cover:add(c:ellipse(h[1], h[2], r, r * 0.82)) end
  end
  -- the dad: whatever the hedge has not taken yet, without 1 px slivers
  local vis = c:mask()
  dadM:each(function(x, y) if GONE[y * W + x] > p and not cover:has(x, y) then vis:set(x, y) end end)
  vis = vis:shrink(1):grow(1):clip(vis)
  local seen = {}                                   -- and no loose crumbs: drop bits under 80 px
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
    local eyeish = false
    for _, q in ipairs(comp) do if EYEBOX:has(q[1], q[2]) then eyeish = true break end end
    if #comp < 80 and not eyeish then for _, q in ipairs(comp) do vis:del(q[1], q[2]) end end
  end)
  vis:each(function(x, y) c:px(x, y, dadC:get(x, y)) end)
  for _, h in ipairs(FRONT) do
    local r = size(h, p)
    if r >= 2.5 then clump(c, h[1], h[2], r, h[4], h.deco, h.big) end
  end
  -- the eyes sit on top of the leaves; in the eye beat they blink, then slip down behind the leaf line
  if eye then
    local em = EYES:shift(0, eye):clip(EYEBOX)
    em:each(function(x, y) c:px(x, y, dadC:get(x, y - eye)) end)
    if fr.blink then
      -- yellow lids down to the pupils' middle, umber lid line
      for _, e in ipairs(EYE_TL) do
        local lid = c:rrect(e[1], e[2], e[1] + 8, e[2] + 8, 3):clip(c:rect(0, 0, W, e[2] + 4))
        c:fill(lid, yel.base)
        c:fill(c:rect(e[1], e[2] + 5, e[1] + 8, e[2] + 5):clip(c:rrect(e[1], e[2], e[1] + 8, e[2] + 8, 3)), OL2)
        c:fill(lid:clip(c:rect(0, 0, W, e[2] + 1)), yel.rim)
      end
    end
    local ring = em:grow(1):cut(em)
    ring:each(function(x, y) if y <= EYEBOT then c:px(x, y, OL3) end end)
  elseif p <= 1 then
    EYES:each(function(x, y) if not vis:has(x, y) then c:px(x, y, dadC:get(x, y)); vis:set(x, y) end end)
  end
  -- clean edge where the leaves overlap him: 1 px dark rim on the leaf side
  if not eye and vis:count() > 0 then
    local ring = vis:grow(1):cut(vis)
    ring:each(function(x, y) if dadM:has(x, y) or EYEBOX:grow(1):has(x, y) then c:px(x, y, OL3) end end)
  end
  return c:image()
end

local spr = Sprite(W * 2, H * 2, ColorMode.RGB)
local layer = spr.layers[1]
layer.name = "homer-hedge"
for f, fr in ipairs(FR) do
  if f > 1 then spr:newEmptyFrame(f) end
  local img = drawFrame(fr)
  if f == 1 then spr.cels[1].image = img; img:saveAs(G .. "homer-hedge-still.png") else spr:newCel(layer, f, img) end
  spr.frames[f].duration = fr.ms / 1000
  local t = GV.check(img)
  assert(t.semi == 0 and t.bw <= 8, "frame " .. f .. ": " .. GV.report(t))
end
pcall(function() app.fs.makeAllDirectories(O) end)
spr:saveAs(O .. "homer-hedge.aseprite")
spr:saveCopyAs(G .. "homer-hedge.gif")
spr:close()
print("saved " .. #FR .. " frames")
