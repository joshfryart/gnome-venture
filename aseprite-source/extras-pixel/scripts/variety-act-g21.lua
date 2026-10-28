-- variety-act-g21.lua : Do-tab scenes for 15 tower/spring rest-stop activities -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g21.lua   (params BEFORE --script)
-- Derived from variety-act-g5.lua (frame copied from the shipped act-hand.png; interior x 5..68, y 5..49).
local ROOT = "/home/user/gnome-venture/"
local GV = dofile(ROOT .. "aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or (ROOT .. "aseprite-source/extras-pixel/png/")
local ASE = ROOT .. "aseprite-source/extras-pixel/aseprite/"
local FRAME_SRC = ROOT .. "game/assets/img/acts/act-hand.png"
local only = app.params.only
local floor = math.floor
local function rnd(v) return floor(v + 0.5) end

local INK, UMB = "#2a1a10", "#4a2c1a"
local W, H = 72, 54

---------------------------------------------------------------- helpers
local function new() return GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 0, cres = 2, deep = 1 } end

-- flat (or shaded) outlined prop part
local function part(c, m, hex, o)
  o = o or {}
  local ov = {}
  if not o.shade then ov.rim = hex end
  local op = { flat = not o.shade, gloss = false, cres = o.cres or 2, deep = o.deep or 1, contact = false }
  if o.noline then op.outline = false; op.contour = false end
  return c:part(m, GV.ramp(hex, ov), op)
end
-- plain fill with no outline
local function fl(c, m, hex) c:fill(m, hex); return m end
local function R(c, x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end

local FRAME
local function frame(c)
  if not FRAME then FRAME = Image{ fromFile = FRAME_SRC } end
  for gy = 0, H - 1 do for gx = 0, W - 1 do
    if not (gx >= 5 and gx <= 68 and gy >= 5 and gy <= 49) then
      local v = FRAME:getPixel(gx * 2, gy * 2)
      if app.pixelColor.rgbaA(v) > 0 then
        c:px(gx, gy, string.format("#%02x%02x%02x", app.pixelColor.rgbaR(v), app.pixelColor.rgbaG(v), app.pixelColor.rgbaB(v)))
      end
    end
  end end
end

local function finish(c, slug)
  frame(c)
  local ase, png = ASE .. "variety-act-" .. slug .. ".aseprite", OUT .. "act-" .. slug .. ".png"
  local t = c:save(ase, png)
  print(slug, GV.report(t))
  assert(t.semi == 0 and t.bw == 0)
  -- the shipped frame has a 2x2 transparent notch at each corner: clear them, then rewrite both files
  local spr = app.open(ase)
  local img = spr.cels[1].image
  for _, p in ipairs({ { 0, 0 }, { 142, 0 }, { 0, 106 }, { 142, 106 } }) do
    for dx = 0, 1 do for dy = 0, 1 do img:putPixel(p[1] + dx, p[2] + dy, 0) end end
  end
  spr:saveAs(ase)
  spr:saveCopyAs(png)
  spr:close()
end

-- rng
local seed = 7
local function rand() seed = (seed * 1103515245 + 12345) % 2147483648; return seed / 2147483648 end

-- sky + hills + grass for a daylight meadow. g = grass line.
local function day(c, g, opt)
  opt = opt or {}
  local sky = opt.sky or { "#a8d4e0", "#bcdde4", "#cfe8e6" }
  c:bands(R(c, 0, 0, W - 1, g), sky, { dir = "v" })
  if opt.cloud ~= false then
    local cx = opt.cloud or 14
    c:fill(c:ellipse(cx, 10, 8, 2), "#f4eee0"); c:fill(c:ellipse(cx + 4, 8, 5, 2), "#f4eee0")
  end
  local hc = opt.hill or "#5e8a44"
  c:fill(c:ellipse(18, g + 2, 34, 11), hc)
  c:fill(c:ellipse(60, g + 3, 30, 9), opt.hill2 or "#4e8a3c")
  c:fill(R(c, 0, g, W - 1, H - 1), opt.grass or "#7ea85a")
  c:fill(R(c, 0, g, W - 1, g), opt.edge or "#9cc070")
  for i = 1, 14 do
    local x, y = floor(rand() * 66) + 3, g + 2 + floor(rand() * (H - g - 4))
    c:px(x, y, "#5e8a44"); c:px(x + 1, y - 1, "#5e8a44")
  end
end

-- a pine built of stacked row-triangles (snow caps optional)
local function pine(c, x, yb, h, snow)
  part(c, R(c, x - 1, yb - 3, x, yb), "#5e3f28", { noline = true })
  local tiers = 3
  local th = floor((h - 2) / 2)
  local m = c:mask()
  local caps = c:mask()
  for t = 0, tiers - 1 do
    local top = yb - 3 - h + 2 + t * floor((h - 4) / tiers)
    local hh = th
    local w = 2 + t * 2
    for i = 0, hh - 1 do
      local hw = floor(i * w / (hh - 1) + 0.5)
      m:add(c:rect(x - hw - 1, top + i, x + hw, top + i))
      if i <= 1 then caps:add(c:rect(x - hw - 1, top + i, x + hw, top + i)) end
    end
  end
  part(c, m, "#2f5a2a")
  if snow then c:fill(caps, "#f4f8fa") end
end

---------------------------------------------------------------- the gnome
-- Parametric by scale s (1 = the 10x18 gnome of the shipped cards). Base units: x cells from the centre, u rows up from the feet row.
-- o: d = facing (1 right, -1 left), s = scale, upper = no legs, sit = seated (hips at oy, legs forward), walk = 1/-1 stride,
--    eyes = "open"|"shut"|"happy", hat = hex, arms = { {a={dx,u}, b={dx,u}, front=bool, nohand=bool}, ... } (base units from feet-centre)
-- returns sil, G where G.P(dx,u) -> absolute x,y ; G.hat = hat mask ; G.tip = x,y of the hat tip
local function gnome(c, ox, oy, o)
  o = o or {}
  local d, s = o.d or 1, o.s or 1
  local BODY, BEARD, SKIN, BOOT = "#4a6e9a", "#f4eee0", "#f0c8a0", "#5a3a22"
  local hatc = o.hat or "#c0442e"
  local hatd = (o.hat and "#8a4a1a") or "#8e2e1e"
  local sil = c:mask()
  local function X(v) return ox + rnd(v * s) end
  local function Yp(u) return oy - rnd(u * s) end
  local function rx(x0, x1)
    if d < 0 then x0, x1 = -x1, -x0 end
    return ox + rnd(x0 * s), ox + math.max(rnd(x0 * s), rnd((x1 + 1) * s) - 1)
  end
  local function ry(u0, u1)
    local y0, y1 = oy + 1 - rnd((u1 + 1) * s), oy - rnd(u0 * s)
    if y0 > y1 then y0 = y1 end
    return y0, y1
  end
  local function rc(x0, u0, x1, u1) -- rect in base cell units (x mirrored by facing)
    local a, b = rx(x0, x1); local e, f = ry(u0, u1)
    return c:rect(a, e, b, f)
  end
  local function sym(x0, u0, x1, u1) -- symmetric rect (no mirroring)
    local a, b = ox + rnd(x0 * s), ox + math.max(rnd(x0 * s), rnd((x1 + 1) * s) - 1)
    local e, f = ry(u0, u1)
    return c:rect(a, e, b, f)
  end
  local function pp(m, hex)
    c:part(m, GV.ramp(hex, { rim = hex }), { flat = true, gloss = false, contact = false, outline = false, contour = false })
    sil:add(m)
  end
  local G = {}
  function G.P(dx, u) return X(dx), Yp(u) end
  G.sym = sym; G.ry = ry; G.ox = ox; G.oy = oy; G.s = s
  -- legs
  if not o.upper then
    if o.sit then
      pp(rc(2, 0, 7, 2), BODY)                  -- thigh forward
      pp(rc(6, -4, 7, 0), BODY)                 -- shin
      pp(rc(6, -6, 9, -5), BOOT)                -- boot
    else
      local bl, br = { -4, 0, -1, 1 }, { 1, 0, 4, 1 }
      if o.walk and o.walk > 0 then br = { 2, 1, 5, 2 } elseif o.walk and o.walk < 0 then bl = { -5, 1, -2, 2 } end
      pp(sym(bl[1], bl[2], bl[3], bl[4]), BOOT); pp(sym(br[1], br[2], br[3], br[4]), BOOT)
      pp(sym(bl[1] + 1, bl[2] + 2, bl[3] - 1, bl[2] + 3), BODY); pp(sym(br[1] + 1, br[2] + 2, br[3] - 1, br[2] + 3), BODY)
    end
  end
  pp(sym(-4, 2, 4, 8), BODY)
  local function arms(front)
    for _, a in ipairs(o.arms or {}) do
      if (a.front or false) == front then
        local t = math.max(2, rnd(2 * s))
        local ax, ay = X(a.a[1]), Yp(a.a[2])
        local bx, by = X(a.b[1]), Yp(a.b[2])
        pp(c:line({ { ax, ay }, { bx, by } }, t), a.sleeve or BODY)
        if not a.nohand then
          local hs = math.max(2, rnd(2 * s))
          pp(c:rect(bx - 0, by - 0, bx + hs - 1, by + hs - 1):shift(-floor(hs / 2) + 0, -floor(hs / 2)), SKIN)
        end
      end
    end
  end
  arms(false)
  local beard = sym(-3, 5, 3, 9); beard:add(sym(-3, 5, 3, 9)); beard:add(sym(-2, 2, 2, 5))
  local bb = c:rect(ox + rnd(-3 * s), select(1, ry(2, 9)), ox + rnd(4 * s) - 1, select(2, ry(2, 9)))
  -- round the beard bottom corners
  bb:del(ox + rnd(-3 * s), select(2, ry(2, 9))); bb:del(ox + rnd(4 * s) - 1, select(2, ry(2, 9)))
  pp(bb, BEARD)
  -- face
  pp(sym(-3, 10, 3, 11), SKIN)
  local fy0, fy1 = ry(10, 11)
  local ey = fy1
  local c1, c2 = (d > 0) and -1 or -2, (d > 0) and 2 or 1
  local e1a, e1b = ox + rnd(c1 * s), ox + rnd(c2 * s)
  local eh = math.max(1, rnd(s))
  local function eye(x, col) for k = 0, eh - 1 do c:px(x, ey - k, col) end end
  if o.eyes == "shut" then
    eye(e1a, "#8a4a34"); eye(e1b, "#8a4a34")
    c:px(e1a - 1, ey - eh + 1, "#8a4a34"); c:px(e1b + 1, ey - eh + 1, "#8a4a34")
  elseif o.eyes == "happy" then
    c:px(e1a, ey - eh, INK); c:px(e1b, ey - eh, INK)
    c:px(e1a - 1, ey - eh + 1, INK); c:px(e1a + 1, ey - eh + 1, INK); c:px(e1b - 1, ey - eh + 1, INK); c:px(e1b + 1, ey - eh + 1, INK)
    c:px(e1a, ey - eh + 1, "#f0c8a0"); c:px(e1b, ey - eh + 1, "#f0c8a0")
  else
    eye(e1a, INK); eye(e1b, INK)
  end
  local nx = ox + d * rnd(3 * s) + (d < 0 and 0 or 0)
  for yy = fy1 - math.max(0, rnd(s) - 1), fy1 do c:px(nx, yy, "#e08a7a") end
  arms(true)
  -- hat: cone with a bent tip, then the brim
  local hy0, _ = ry(13, 18)
  local _, hy1 = ry(13, 13)
  local hat = c:mask()
  local n = hy1 - hy0
  for yy = hy0, hy1 do
    local fr = (n == 0) and 1 or (yy - hy0) / n
    local hw = rnd(fr * 3.2 * s)
    local shift = (yy - hy0 <= math.max(1, rnd(s))) and -d or 0
    hat:add(c:rect(ox - hw + shift, yy, ox + hw + shift, yy))
  end
  local by0, by1 = ry(12, 12)
  local brim = c:rect(ox + rnd(-4 * s), by0, ox + rnd(5 * s) - 1, by1)
  hat:add(brim)
  pp(hat, hatc)
  pp(brim, hatd)
  G.hat = hat; G.tipx, G.tipy = ox - d, hy0
  if o.band then c:fill(c:rect(ox + rnd(-3 * s), hy1 - 1, ox + rnd(3 * s), hy1 - 1), o.band) end
  c:outline(sil, { ol = 1, olx = 0 })
  return sil, G
end

local function arm(a, b, front, nohand) return { a = a, b = b, front = front, nohand = nohand } end


---------------------------------------------------------------- scenes
local S = {}
local ORDER = {}
local function scene(name, f) S[name] = f; ORDER[#ORDER + 1] = name end

-- shared bits ------------------------------------------------------------
local function bricks(c, x0, y0, x1, y1, base, line, bw, bh)
  fl(c, R(c, x0, y0, x1, y1), base)
  local row = 0
  for y = y0 + bh - 1, y1, bh do
    fl(c, R(c, x0, y, x1, y), line)
    local off = (row % 2) * floor(bw / 2)
    for x = x0 + off, x1, bw do fl(c, R(c, x, y - bh + 1, x, y - 1), line) end
    row = row + 1
  end
end
-- crenellated wall: top row of merlons at y, wall body below down to y1
local function wall(c, x0, x1, y, y1, base, line, hi)
  base = base or "#8b8f96"; line = line or "#6f747c"; hi = hi or "#a8aeb4"
  bricks(c, x0, y + 4, x1, y1, base, line, 6, 3)
  for x = x0, x1, 8 do
    local xe = math.min(x + 4, x1)
    fl(c, R(c, x, y, xe, y + 3), base); fl(c, R(c, x, y, xe, y), hi)
    fl(c, R(c, x, y + 1, x, y + 3), hi)
  end
  fl(c, R(c, x0, y + 4, x1, y + 4), hi)
end
local function hills(c, g, c1, c2)
  c:fill(c:ellipse(16, g + 3, 30, 9), c1 or "#6a9a58"); c:fill(c:ellipse(58, g + 4, 28, 8), c2 or "#5e8a4c")
end
local function skyday(c, y1, cols)
  c:bands(R(c, 0, 0, W - 1, y1), cols or { "#a8d4e0", "#bcdde4", "#cfe8e6", "#dcefe6" }, { dir = "v" })
end
local function cloud(c, x, y, k, col)
  col = col or "#f4eee0"
  c:fill(c:ellipse(x, y, 7 * k, 2 * k), col); c:fill(c:ellipse(x + 3 * k, y - 2 * k, 4 * k, 2 * k), col)
  c:fill(c:ellipse(x - 3 * k, y - 1 * k, 3 * k, 2 * k), col)
end
local function planks(c, y0, y1, base, line)
  fl(c, R(c, 0, y0, W - 1, y1), base)
  for y = y0 + 3, y1, 4 do fl(c, R(c, 0, y, W - 1, y), line) end
  fl(c, R(c, 0, y0, W - 1, y0), "#d9a660")
end
local function spark(c, x, y, a, b)
  a = a or "#fff1c8"; b = b or "#f5cf6a"
  c:px(x, y, a); c:px(x - 1, y, b); c:px(x + 1, y, b); c:px(x, y - 1, b); c:px(x, y + 1, b)
end
local function flame(c, x, yb, k)
  part(c, c:poly({ { x, yb - 14 * k }, { x + 5 * k, yb - 5 * k }, { x + 4 * k, yb }, { x - 4 * k, yb }, { x - 5 * k, yb - 5 * k } }), "#e0501f")
  c:fill(c:poly({ { x, yb - 9 * k }, { x + 3 * k, yb - 3 * k }, { x + 2 * k, yb }, { x - 2 * k, yb }, { x - 3 * k, yb - 3 * k } }), "#f08a24")
  c:fill(c:ellipse(x, yb - 2 * k, 1, 2 * k), "#ffd86a")
end

-- 1. re-thatch the lookout roof ------------------------------------------
scene("w5_rethatch_lookout", function()
  seed = 61
  local c = new()
  skyday(c, 38); cloud(c, 14, 10, 1); hills(c, 33)
  fl(c, R(c, 0, 36, W - 1, 38), "#6a9a58")
  -- deck
  planks(c, 40, 49, "#b07a45", "#8a5a35")
  -- back parapet merlons at left
  wall(c, 5, 26, 34, 40)
  -- hut posts
  part(c, R(c, 38, 24, 39, 42), "#8a5a35", { noline = true }); part(c, R(c, 63, 24, 64, 42), "#8a5a35", { noline = true })
  part(c, R(c, 38, 36, 64, 37), "#a8703e")
  fl(c, R(c, 40, 39, 62, 41), "#7a4a2a")
  -- roof: left half thatched, right half bare rafters
  local roof = c:poly({ { 51, 10 }, { 69, 26 }, { 34, 26 } })
  local rr = c:mask(); rr:add(roof)
  part(c, c:poly({ { 51, 10 }, { 52, 26 }, { 34, 26 } }), "#d9b25a")
  local thatch = c:poly({ { 51, 10 }, { 52, 26 }, { 34, 26 } })
  for i = 0, 5 do fl(c, c:line({ { 40 + i * 2, 25 }, { 47 + i, 13 + i * 2 } }, 1):clip(thatch), "#b8903f") end
  for y = 14, 26, 4 do fl(c, R(c, 34, y, 52, y):clip(thatch), "#c9a24a") end
  -- bare rafters on right half
  for i = 0, 6 do
    local ex = 54 + i * 2
    c:fill(c:line({ { 51, 10 }, { ex, 26 } }, 1), "#6b3b2a")
  end
  c:fill(R(c, 52, 25, 69, 26), "#6b3b2a")
  c:fill(c:line({ { 51, 10 }, { 52, 14 } }, 2), "#6b3b2a")
  c:outline(roof)
  -- a few stray straws and sky showing between rafters is natural; bucket hat on the post
  part(c, c:ellipse(63, 33, 3, 1), "#9aa0a8"); c:fill(R(c, 61, 30, 64, 32), "#9aa0a8"); c:fill(R(c, 61, 30, 64, 30), "#b8bec6")
  c:outline(c:ellipse(63, 33, 3, 1))
  -- straw pile on the deck
  part(c, c:poly({ { 7, 48 }, { 12, 40 }, { 18, 41 }, { 22, 48 } }), "#d9b25a")
  for _, p in ipairs({ { 10, 46 }, { 14, 44 }, { 17, 46 }, { 13, 42 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#b8903f") end
  fl(c, R(c, 11, 44, 16, 44), "#6b3b2a")
  -- the gnome reaches a bundle up to the eave
  local _, G = gnome(c, 31, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 7, 17 }, true) } })
  local hx, hy = G.P(7, 17)
  part(c, c:poly({ { hx - 3, hy + 1 }, { hx + 1, hy - 8 }, { hx + 4, hy - 8 }, { hx + 7, hy + 1 } }), "#d9b25a")
  fl(c, R(c, hx - 1, hy - 3, hx + 4, hy - 3), "#6b3b2a")
  fl(c, R(c, hx, hy - 7, hx, hy - 2), "#b8903f"); fl(c, R(c, hx + 3, hy - 7, hx + 3, hy - 2), "#b8903f")
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  c:px(48, 28, "#d9b25a"); c:px(44, 31, "#d9b25a"); c:px(58, 30, "#d9b25a")
  finish(c, "w5_rethatch_lookout")
end)

-- 2. fit the new spyglass lens -------------------------------------------
scene("w5_spyglass_lens", function()
  seed = 62
  local c = new()
  skyday(c, 38); cloud(c, 54, 10, 1); hills(c, 33, "#8aa8a0", "#7a9a98")
  wall(c, 0, W - 1, 27, 41)
  planks(c, 42, 49, "#b07a45", "#8a5a35")
  -- tripod
  c:fill(c:line({ { 37, 31 }, { 30, 47 } }, 2), "#5e3f28"); c:fill(c:line({ { 41, 31 }, { 46, 47 } }, 2), "#5e3f28"); c:fill(c:line({ { 39, 31 }, { 39, 47 } }, 2), "#5e3f28")
  -- brass spyglass, big end (objective) at left, pointing up-left
  part(c, c:line({ { 24, 26 }, { 42, 31 } }, 7), "#c8902a")
  part(c, c:line({ { 40, 31 }, { 53, 35 } }, 5), "#b07a2a")
  part(c, c:line({ { 52, 35 }, { 58, 37 } }, 3), "#e0b04a")
  for _, p in ipairs({ { 35, 28, 36, 33 }, { 46, 32, 46, 36 } }) do fl(c, c:line({ { p[1], p[2] }, { p[3], p[4] } }, 1), "#8a5a1a") end
  -- empty ring at the objective end + the lens being fitted
  fl(c, c:ellipse(23, 26, 3, 5), "#6a4a1a")
  -- gnome holding the lens up with both hands
  local _, G = gnome(c, 11, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 14 }, true, true), arm({ -4, 8 }, { 5, 16 }, true, true) } })
  local lx, ly = 17, 24
  part(c, c:ellipse(lx, ly, 3, 3), "#b8e0e8"); c:fill(c:ellipse(lx, ly, 2, 2), "#d8f2f4"); c:px(lx - 1, ly - 1, "#f8fcfe"); c:px(lx - 2, ly - 1, "#f8fcfe")
  local ax, ay = G.P(8, 14); fl(c, R(c, ax - 1, ay - 1, ax + 1, ay + 1), "#f0c8a0")
  ax, ay = G.P(5, 16); fl(c, R(c, ax - 1, ay - 1, ax + 1, ay + 1), "#f0c8a0")
  spark(c, 12, 18); spark(c, 21, 19, "#f8fcfe", "#bfe8f0")
  -- six socks wrapping paper: striped socks heap
  local cols = { "#dd3a2a", "#3f8fb0", "#e8a317", "#7ab55c", "#e46a9b", "#8a6ac0" }
  for i = 0, 5 do
    local x, y = 52 + (i % 3) * 5, 44 - floor(i / 3) * 3
    part(c, R(c, x, y, x + 5, y + 2), cols[i + 1]); fl(c, R(c, x + 1, y, x + 1, y + 2), "#f4eee0"); fl(c, R(c, x + 3, y, x + 3, y + 2), "#f4eee0")
  end
  finish(c, "w5_spyglass_lens")
end)

-- 3. swifts-and-gnats hand game in the wind ------------------------------
scene("w5_swift_gnat", function()
  seed = 63
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#98b4c8", "#a8c0d0", "#b8ccd8", "#c8d8e0" }, { dir = "v" })
  cloud(c, 18, 12, 1, "#e8eef0"); cloud(c, 56, 9, 1, "#dfe8ec")
  c:fill(c:ellipse(40, 38, 34, 6), "#7a9a88")
  wall(c, 0, W - 1, 31, 49)
  -- flag streaming straight out
  part(c, R(c, 8, 8, 9, 33), "#5e3f28", { noline = true })
  part(c, c:poly({ { 9, 9 }, { 17, 10 }, { 16, 14 }, { 17, 17 }, { 9, 17 } }), "#dd3a2a")
  -- wind streaks
  for _, s in ipairs({ { 22, 22, 9 }, { 21, 26, 6 }, { 44, 17, 8 }, { 50, 27, 7 }, { 26, 15, 6 }, { 31, 11, 7 } }) do
    fl(c, R(c, s[1], s[2], s[1] + s[3], s[2]), "#eef4f6"); fl(c, R(c, s[1] + s[3], s[2] - 1, s[1] + s[3] + 1, s[2]), "#eef4f6")
  end
  -- two players, hands thrown out; leaves blowing
  local _, A = gnome(c, 17, 49, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 14 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  local _, B = gnome(c, 48, 49, { d = -1, hat = "#4f9a45", eyes = "happy", arms = { arm({ 4, 8 }, { 8, 12 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  -- swift above the left hand
  local sx, sy = A.P(8, 20)
  c:paint({ "..ss.....", "ssssss..s", ".sssssss.", "..ss.ss.." }, sx - 3, sy - 3, { s = "#2a3a58" })
  c:px(sx + 5, sy - 2, "#e8a317")
  -- gnat above the right hand
  local gx, gy = B.P(9, 16)
  c:paint({ "w.w", ".gg", "w.w" }, gx - 1, gy - 2, { w = "#5a6a88", g = INK })
  -- gust spiral in the middle
  c:fill(c:line({ { 31, 23 }, { 35, 21 }, { 40, 23 }, { 40, 27 }, { 37, 28 }, { 35, 26 } }, 1), "#f4f8fa")
  fl(c, R(c, 28, 24, 31, 24), "#f4f8fa"); fl(c, R(c, 41, 20, 44, 20), "#f4f8fa")
  -- blowing leaves
  for _, p in ipairs({ { 28, 9 }, { 40, 14 }, { 12, 24 }, { 58, 22 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#c8802a"); c:px(p[1] + 2, p[2] - 1, "#c8802a") end
  finish(c, "w5_swift_gnat")
end)

-- 4. shadow puppets by the beacon ----------------------------------------
scene("w5_beacon_shadows", function()
  seed = 64
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 41), { "#1c2448", "#222c54", "#2a3560", "#323e6a" }, { dir = "v" })
  for _, p in ipairs({ { 8, 7 }, { 30, 6 }, { 49, 9 }, { 62, 6 }, { 66, 14 }, { 7, 22 }, { 60, 25 } }) do c:px(p[1], p[2], "#f4eee0") end
  -- big cloud screen lit from the right by the beacon
  c:fill(c:ellipse(30, 20, 26, 14), "#d89a78"); c:fill(c:ellipse(18, 22, 16, 10), "#c88a74"); c:fill(c:ellipse(40, 14, 14, 8), "#e8b08a")
  c:fill(c:ellipse(30, 24, 24, 8), "#e8b08a")
  c:fill(c:ellipse(8, 20, 5, 6), "#a87288")
  -- huge fox-head shadow
  local fox = c:poly({ { 12, 21 }, { 14, 9 }, { 20, 15 }, { 26, 15 }, { 32, 9 }, { 33, 21 }, { 42, 25 }, { 33, 29 }, { 27, 33 }, { 18, 33 } })
  c:fill(fox, "#3a2c58")
  c:px(19, 21, "#e8b08a"); c:px(27, 21, "#e8b08a"); c:px(20, 21, "#e8b08a"); c:px(28, 21, "#e8b08a")
  c:px(41, 25, "#3a2c58")
  wall(c, 0, W - 1, 38, 49, "#58607a", "#454c64", "#7a82a0")
  -- brazier
  part(c, R(c, 56, 41, 57, 48), "#3d2a1c", { noline = true })
  part(c, c:poly({ { 49, 33 }, { 63, 33 }, { 60, 39 }, { 52, 39 } }), "#3d2a1c")
  flame(c, 56, 34, 1.4)
  c:px(48, 24, "#ffd86a"); c:px(62, 22, "#f08a24"); c:px(53, 18, "#ffd86a"); c:px(65, 28, "#f08a24")
  -- gnome in the firelight, hand raised making the fox
  local _, G = gnome(c, 36, 49, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 15 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  local hx, hy = G.P(8, 15)
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0"); fl(c, R(c, hx - 1, hy - 4, hx - 1, hy - 2), "#f0c8a0"); fl(c, R(c, hx + 1, hy - 4, hx + 1, hy - 2), "#f0c8a0")
  finish(c, "w5_beacon_shadows")
end)

-- 5. things seen from the top ---------------------------------------------
scene("w5_seen_from_top", function()
  seed = 65
  local c = new()
  skyday(c, 22, { "#9ccce0", "#b4d8e4", "#cce8e8", "#e0f0e4" })
  cloud(c, 54, 9, 1)
  -- far hills and a rainbow's foot
  c:fill(c:ellipse(14, 24, 22, 6), "#8aa8a8"); c:fill(c:ellipse(52, 25, 24, 5), "#7a9a9a")
  c:fill(c:line({ { 62, 6 }, { 66, 11 }, { 67, 20 } }, 1), "#dd5a42"); c:fill(c:line({ { 61, 7 }, { 65, 11 }, { 66, 20 } }, 1), "#f5cf6a")
  c:fill(c:line({ { 60, 8 }, { 64, 12 }, { 65, 20 } }, 1), "#7ab55c")
  -- patchwork fields
  local fc = { "#7ea85a", "#c8b45a", "#6a9a4e", "#a8b85e", "#8cb060", "#d0b860" }
  local rows = { { 22, 28 }, { 29, 35 }, { 36, 42 } }
  for r, rw in ipairs(rows) do
    local x = 5 - (r * 3)
    local n = 0
    while x < 70 do
      local w = 9 + ((n + r) % 3) * 3
      fl(c, R(c, x, rw[1], x + w - 2, rw[2]), fc[(n + r * 2) % #fc + 1])
      fl(c, R(c, x + w - 1, rw[1], x + w - 1, rw[2]), "#5e8a44")
      x = x + w; n = n + 1
    end
    fl(c, R(c, 0, rw[2], W - 1, rw[2]), "#5e8a44")
  end
  fl(c, R(c, 0, 28, W - 1, 28), "#5e8a44")
  for y = 23, 27, 2 do for x = 9, 66, 7 do fl(c, R(c, x, y, x, y), "#5e8a44") end end
  fl(c, R(c, 0, 43, W - 1, 46), "#5e8a44")
  -- little river
  c:fill(c:line({ { 24, 22 }, { 28, 28 }, { 25, 35 }, { 30, 42 } }, 2), "#78bcd0")
  -- far village roof and smoke
  part(c, c:poly({ { 12, 24 }, { 15, 21 }, { 18, 24 } }), "#c0442e"); c:px(13, 19, "#e8eef0"); c:px(14, 17, "#e8eef0")
  -- goat running (white body, horns), wagon stuck in a ditch, kite with no flyer
  part(c, R(c, 36, 30, 40, 32), "#f4eee0"); c:px(41, 30, "#f4eee0"); c:px(42, 29, "#5e3f28"); fl(c, R(c, 37, 33, 37, 34), "#5e3f28"); fl(c, R(c, 40, 33, 40, 34), "#5e3f28")
  part(c, R(c, 50, 36, 56, 38), "#a8703e"); fl(c, c:ellipse(51, 39, 1, 1), "#3d2a1c"); fl(c, c:ellipse(56, 38, 1, 1), "#3d2a1c"); fl(c, R(c, 52, 34, 54, 35), "#d9b25a")
  part(c, c:poly({ { 30, 8 }, { 34, 12 }, { 30, 17 }, { 26, 12 } }), "#e46a9b"); fl(c, R(c, 30, 8, 30, 17), "#f8d0e0")
  c:fill(c:line({ { 30, 17 }, { 28, 20 }, { 31, 23 }, { 29, 26 } }, 1), "#8a5a35")
  c:px(28, 22, "#dd3a2a"); c:px(30, 25, "#3f8fb0")
  -- parapet in the foreground, the watcher behind it with a long list and a quill
  wall(c, 0, W - 1, 42, 49)
  local _, G = gnome(c, 20, 50, { d = 1, upper = true, eyes = "open", arms = { arm({ -4, 10 }, { -5, 7 }, false), arm({ 4, 9 }, { 10, 14 }, true) } })
  -- scroll list held in the near hand
  local px, py = G.P(-5, 10)
  part(c, R(c, px - 4, py - 8, px, py + 1), "#f4eee0"); fl(c, R(c, px - 4, py + 1, px, py + 1), "#e0c88a")
  for yy = py - 6, py, 2 do fl(c, R(c, px - 3, yy, px - 1, yy), "#6a8ab0") end
  fl(c, R(c, px - 3, py - 8, px - 1, py - 8), "#e0c88a")
  local qx, qy = G.P(10, 14)
  fl(c, c:line({ { qx, qy }, { qx + 4, qy - 5 } }, 1), "#f4eee0"); c:px(qx + 4, qy - 6, "#dd3a2a")
  fl(c, R(c, qx - 1, qy - 1, qx + 1, qy + 1), "#f0c8a0")
  spark(c, 35, 26)
  finish(c, "w5_seen_from_top")
end)

-- 6. name that cloud --------------------------------------------------------
scene("w5_cloud_names", function()
  seed = 66
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 44), { "#7fb0d4", "#92bedc", "#a8cce4", "#bcd8ea", "#d0e4ee" }, { dir = "v" })
  -- cumulus
  c:fill(c:ellipse(18, 22, 12, 5), "#f4f8fa"); c:fill(c:ellipse(14, 17, 6, 5), "#f4f8fa"); c:fill(c:ellipse(22, 16, 7, 6), "#f4f8fa")
  c:fill(R(c, 6, 25, 30, 26), "#c8d8e4")
  -- anvil cloud
  c:fill(c:ellipse(52, 24, 4, 8), "#dfe8f0"); c:fill(c:ellipse(52, 12, 14, 4), "#f4f8fa"); c:fill(c:ellipse(52, 15, 7, 3), "#e8eff6")
  c:fill(R(c, 49, 14, 55, 28), "#dfe8f0"); c:fill(R(c, 55, 14, 56, 28), "#b8c8d8")
  c:fill(c:ellipse(52, 12, 14, 2):clip(R(c, 0, 12, W, 14)), "#f8fcfe")
  -- cirrus wisps
  for i = 0, 2 do
    c:fill(c:line({ { 34 + i * 3, 7 + i * 3 }, { 40 + i * 3, 6 + i * 3 }, { 46 + i * 3, 9 + i * 3 } }, 1), "#eef4f8")
  end
  -- lens cloud
  c:fill(c:ellipse(36, 27, 7, 2), "#f4f8fa"); c:fill(c:ellipse(36, 29, 5, 1), "#c8d8e4")
  -- hills and the tower deck
  c:fill(c:ellipse(40, 44, 34, 6), "#6a9a58")
  wall(c, 0, W - 1, 40, 49)
  -- easel with the chart: cloud icons in blue ink
  part(c, R(c, 52, 28, 53, 41), "#8a5a35", { noline = true }); part(c, R(c, 62, 28, 63, 41), "#8a5a35", { noline = true })
  part(c, R(c, 49, 22, 65, 38), "#f4eee0")
  for _, p in ipairs({ { 51, 24 }, { 58, 29 }, { 52, 33 } }) do
    fl(c, R(c, p[1] + 1, p[2], p[1] + 2, p[2]), "#4a74a8"); fl(c, R(c, p[1] + 3, p[2] + 1, p[1] + 4, p[2] + 1), "#4a74a8")
    fl(c, R(c, p[1], p[2] + 2, p[1] + 6, p[2] + 3), "#4a74a8")
  end
  -- the cartographer painting, brush up at the sky
  local _, G = gnome(c, 33, 50, { d = 1, upper = true, eyes = "open", arms = { arm({ 4, 9 }, { 9, 14 }, true), arm({ -4, 9 }, { -6, 12 }, false) } })
  local bx, by = G.P(9, 14)
  fl(c, c:line({ { bx, by }, { bx + 3, by - 5 } }, 1), "#8a5a35"); c:fill(R(c, bx + 3, by - 7, bx + 4, by - 6), "#4a74a8")
  fl(c, R(c, bx - 1, by - 1, bx + 1, by + 1), "#f0c8a0")
  finish(c, "w5_cloud_names")
end)

-- 7. which spyglass is focused? ---------------------------------------------
scene("w5_focused_spyglass", function()
  seed = 67
  local c = new()
  skyday(c, 40, { "#8ec4e0", "#a4d0e4", "#bcdcea", "#d0e8ec" })
  cloud(c, 58, 9, 1)
  c:fill(c:ellipse(16, 36, 24, 6), "#8aa8a8"); c:fill(c:ellipse(60, 37, 22, 5), "#7a9a9a")
  wall(c, 0, W - 1, 36, 49)
  -- three spyglasses leaning on the parapet, fanned out; the middle one is in focus
  local function tube(x, y, ang, col, col2)
    local dx, dy = floor(14 * math.cos(ang) + 0.5), -floor(14 * math.sin(ang) + 0.5)
    local ex, ey = x + dx + floor(dx * 0.45), y + dy + floor(dy * 0.45)
    part(c, c:line({ { x, y }, { x + dx, y + dy } }, 4), col)
    part(c, c:line({ { x + floor(dx * 0.7), y + floor(dy * 0.7) }, { ex, ey } }, 2), col2)
    c:fill(c:ellipse(ex, ey, 1, 1), "#bfe8f0"); c:px(ex, ey, "#f8fcfe")
    return ex, ey
  end
  local ex1, ey1 = tube(28, 38, 2.05, "#8aa0b8", "#aab8c8")
  local ex2, ey2 = tube(41, 38, 1.55, "#c8902a", "#e0b04a")
  local ex3, ey3 = tube(52, 38, 1.1, "#b8602e", "#d8884a")
  for _, x in ipairs({ 28, 41, 52 }) do part(c, R(c, x - 2, 37, x + 2, 40), "#5e3f28", { noline = true }) end
  spark(c, ex2 + 2, ey2 - 2, "#f8fcfe", "#fff1c8"); spark(c, ex2 - 3, ey2 + 3, "#f8fcfe", "#fff1c8")
  for _, e in ipairs({ { ex1, ey1 }, { ex3, ey3 } }) do
    fl(c, R(c, e[1] - 1, e[2] - 4, e[1], e[2] - 4), "#9ab8cc"); fl(c, R(c, e[1] + 2, e[2] - 4, e[1] + 3, e[2] - 4), "#9ab8cc")
    fl(c, R(c, e[1] - 2, e[2] - 6, e[1] + 4, e[2] - 6), "#bcd4e0")
  end
  -- the watcher steps up, pointing at the middle one
  local _, G = gnome(c, 14, 50, { d = 1, upper = true, eyes = "open", arms = { arm({ 4, 9 }, { 9, 15 }, true), arm({ -4, 9 }, { -6, 12 }, false) } })
  local hx, hy = G.P(9, 15)
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0"); fl(c, R(c, hx + 1, hy - 3, hx + 1, hy - 2), "#f0c8a0")
  finish(c, "w5_focused_spyglass")
end)

-- 8. hunt the map drawer ----------------------------------------------------
scene("w5_map_drawer", function()
  seed = 68
  local c = new()
  bricks(c, 0, 0, W - 1, 49, "#8b8f96", "#6f747c", 8, 4)
  -- arched window
  part(c, R(c, 6, 10, 18, 26), "#a8d4e0"); c:fill(c:ellipse(12, 10, 6, 3), "#a8d4e0")
  fl(c, R(c, 12, 7, 12, 26), "#6f747c"); fl(c, R(c, 6, 17, 18, 17), "#6f747c")
  c:fill(R(c, 7, 11, 11, 15), "#cfe8e6")
  local wm = c:rect(5, 10, 19, 27); wm:add(c:ellipse(12, 10, 7, 4)); c:outline(wm)
  planks(c, 42, 49, "#8a5a35", "#6b3b2a")
  -- chest of five drawers
  part(c, R(c, 36, 14, 62, 45), "#a8703e")
  fl(c, R(c, 37, 15, 61, 15), "#d9a660")
  for i = 0, 4 do
    local y0 = 17 + i * 5
    if i ~= 2 then
      fl(c, R(c, 38, y0, 60, y0 + 3), "#b07a45"); fl(c, R(c, 38, y0, 60, y0), "#c8904f"); fl(c, R(c, 38, y0 + 3, 60, y0 + 3), "#8a4f2a")
      fl(c, R(c, 48, y0 + 1, 50, y0 + 2), "#e8a317")
    end
  end
  -- drawer 3 pulled out
  fl(c, R(c, 38, 27, 60, 27), "#5e2f1e")
  part(c, R(c, 32, 26, 55, 32), "#c8904f"); fl(c, R(c, 33, 26, 54, 26), "#e0a860"); fl(c, R(c, 32, 31, 55, 32), "#8a4f2a")
  fl(c, R(c, 41, 28, 44, 29), "#e8a317")
  -- rolled maps and a ball of string poking out
  part(c, R(c, 44, 22, 52, 25), "#f4eee0"); fl(c, R(c, 44, 22, 44, 25), "#d8c49a"); fl(c, R(c, 52, 22, 52, 25), "#d8c49a"); fl(c, R(c, 46, 22, 46, 25), "#dd3a2a")
  part(c, R(c, 36, 23, 42, 25), "#e8d2a0"); fl(c, R(c, 36, 23, 36, 25), "#c0a060")
  part(c, c:ellipse(52, 33, 2, 2), "#4f9a45"); c:px(52, 33, "#8fc462")
  -- crumbs on the floor
  for _, p in ipairs({ { 36, 44 }, { 40, 46 }, { 44, 44 }, { 38, 47 } }) do c:px(p[1], p[2], "#e8c48a") end
  -- gnome tugging the drawer
  gnome(c, 22, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 6 }, true), arm({ -4, 7 }, { 3, 5 }, true) } })
  fl(c, R(c, 31, 28, 33, 30), "#f0c8a0")
  finish(c, "w5_map_drawer")
end)

-- 9. wind the tower clock -------------------------------------------------------
scene("w5_tower_clock", function()
  seed = 69
  local c = new()
  skyday(c, 49, { "#a8d4e0", "#bcdde4", "#cfe8e6" })
  c:fill(c:ellipse(56, 52, 30, 7), "#7ea85a")
  for _, h in ipairs({ { 52, 46 }, { 61, 44 }, { 66, 47 } }) do
    part(c, R(c, h[1], h[2], h[1] + 3, h[2] + 2), "#e8d2a0"); fl(c, R(c, h[1] - 1, h[2] - 1, h[1] + 4, h[2] - 1), "#c0442e")
    c:px(h[1] + 1, h[2] - 3, "#f4f8fa"); c:px(h[1] + 2, h[2] - 5, "#f4f8fa")
  end
  -- tower wall with the clock face
  bricks(c, 5, 0, 34, 49, "#9a9ea6", "#787c84", 7, 4)
  fl(c, R(c, 34, 0, 34, 49), "#6f747c"); fl(c, R(c, 35, 0, 35, 49), "#5e626a")
  part(c, c:ellipse(20, 17, 14, 14), "#6b3b2a")
  c:fill(c:ellipse(20, 17, 11, 11), "#f4eee0"); c:fill(c:ellipse(20, 17, 11, 11):clip(R(c, 20, 0, 60, 60)), "#eee4cc")
  c:outline(c:ellipse(20, 17, 14, 14))
  for i = 0, 11 do
    local a = i * math.pi / 6
    local x, y = 20 + floor(9 * math.sin(a) + 0.5), 17 - floor(9 * math.cos(a) + 0.5)
    fl(c, R(c, x, y, x + ((i % 3 == 0) and 1 or 0), y + ((i % 3 == 0) and 1 or 0)), "#2a1a10")
  end
  fl(c, c:line({ { 20, 17 }, { 20, 10 } }, 1), "#2a1a10"); fl(c, c:line({ { 20, 17 }, { 25, 20 } }, 1), "#2a1a10")
  fl(c, R(c, 19, 16, 21, 18), "#c8902a")
  -- keyhole plate, key shaft with teeth, and the big ring bow outside the wall
  part(c, R(c, 8, 36, 24, 44), "#b8bec6"); c:fill(c:ellipse(16, 40, 2, 2), "#2a1a10")
  part(c, R(c, 16, 39, 38, 41), "#8b7a3a")
  fl(c, R(c, 16, 39, 38, 39), "#c8a84a"); fl(c, R(c, 28, 42, 28, 43), "#c8a84a"); fl(c, R(c, 32, 42, 32, 44), "#c8a84a")
  part(c, c:ellipse(42, 40, 5, 5), "#c8a84a"); c:fill(c:ellipse(42, 40, 2, 2), "#bcdde4"); c:fill(c:ellipse(42, 40, 2, 2), "#a8d4e0")
  -- gnome hauling on the key bow, leaning back
  local _, G = gnome(c, 58, 49, { d = -1, walk = -1, eyes = "shut", arms = { arm({ -4, 8 }, { -10, 10 }, true, true), arm({ 4, 7 }, { -10, 6 }, true, true) } })
  fl(c, R(c, 46, 38, 49, 40), "#f0c8a0"); fl(c, R(c, 46, 42, 49, 44), "#f0c8a0")
  fl(c, R(c, 62, 32, 65, 32), "#f4f8fa"); fl(c, R(c, 63, 35, 67, 35), "#f4f8fa")
  spark(c, 8, 8, "#fff1c8", "#f5cf6a")
  finish(c, "w5_tower_clock")
end)

-- 10. watcher's night tales -----------------------------------------------------
scene("w5_watcher_night", function()
  seed = 70
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 41), { "#141c3c", "#1a2448", "#222c54", "#2a3560" }, { dir = "v" })
  for i = 1, 26 do c:px(6 + floor(rand() * 62), 6 + floor(rand() * 30), (i % 3 == 0) and "#f5e6a8" or "#c8d4e8") end
  -- one extra, brighter star with a halo (the firefly on the glass)
  spark(c, 47, 14, "#fff8e0", "#f5cf6a"); c:px(47, 12, "#f5cf6a"); c:px(47, 16, "#f5cf6a")
  -- crescent
  c:fill(c:ellipse(15, 13, 4, 4), "#f5e6a8"); c:fill(c:ellipse(17, 12, 3, 3), "#1e2850")
  c:fill(c:ellipse(40, 41, 40, 6), "#1c2a4a")
  wall(c, 0, W - 1, 36, 49, "#58607a", "#454c64", "#7a82a0")
  -- beacon brazier at the right, glowing
  part(c, R(c, 60, 40, 61, 48), "#3d2a1c", { noline = true })
  part(c, c:poly({ { 54, 31 }, { 67, 31 }, { 64, 37 }, { 57, 37 } }), "#3d2a1c")
  flame(c, 60, 32, 1.0)
  c:fill(c:ellipse(60, 45, 10, 3), "#4a4a66")
  -- two sleeping pigeons on the wall top
  for _, x in ipairs({ 41, 48 }) do
    part(c, c:ellipse(x, 35, 2, 2), "#a0a8be"); fl(c, R(c, x - 2, 36, x - 1, 36), "#6a7290")
    fl(c, R(c, x + 1, 31, x + 2, 32), "#a0a8be"); c:px(x + 3, 32, "#e8a317"); c:px(x + 2, 32, "#2a1a10")
  end
  -- the watcher sits by the fire, talking low, finger on lips
  local _, G = gnome(c, 18, 48, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 6, 12 }, true), arm({ -3, 7 }, { 0, 4 }, false) } })
  local lx, ly = G.P(5, 12); fl(c, R(c, lx - 1, ly - 1, lx + 1, ly + 1), "#f0c8a0")
  -- a small listener in a green hat
  gnome(c, 33, 48, { d = -1, hat = "#4f9a45", sit = true, s = 0.8, eyes = "happy", arms = { arm({ -3, 6 }, { -5, 3 }, true) } })
  c:px(56, 24, "#ffd86a"); c:px(64, 22, "#f08a24"); c:px(58, 18, "#f08a24")
  finish(c, "w5_watcher_night")
end)

-- 11. corners of the old maps ---------------------------------------------------
scene("w5_map_corners", function()
  seed = 71
  local c = new()
  fl(c, R(c, 0, 0, W - 1, 49), "#5a4a68")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 30), "#4e405c") end
  fl(c, R(c, 0, 31, W - 1, 31), "#8a5a35")
  fl(c, R(c, 0, 32, W - 1, 49), "#6b3b2a")
  -- shelf of scrolls and a hanging lantern
  part(c, R(c, 36, 17, 66, 18), "#8a5a35")
  local sc = { "#e8d2a0", "#d8c08a", "#c9a96e", "#e8d2a0", "#d9bc84", "#c8d8e0", "#e8d2a0" }
  for i = 0, 6 do part(c, R(c, 38 + i * 4, 9 + (i % 3), 40 + i * 4, 16), sc[i + 1]); fl(c, R(c, 38 + i * 4, 11 + (i % 3), 40 + i * 4, 11 + (i % 3)), (i % 2 == 0) and "#dd3a2a" or "#4a74a8") end
  fl(c, R(c, 30, 5, 30, 8), "#3d2a1c"); part(c, R(c, 28, 9, 32, 14), "#ffd86a"); fl(c, R(c, 29, 10, 31, 13), "#fff1c8"); fl(c, R(c, 28, 8, 32, 8), "#3d2a1c")
  for _, p in ipairs({ { 25, 10 }, { 35, 12 }, { 26, 15 } }) do c:px(p[1], p[2], "#f8c070") end
  -- the long table and the unrolled map, seen from above-front
  part(c, R(c, 4, 36, 68, 49), "#a8703e")
  fl(c, R(c, 4, 36, 68, 36), "#d9a660")
  part(c, c:poly({ { 20, 28 }, { 64, 28 }, { 68, 42 }, { 16, 42 } }), "#e8d2a0")
  c:fill(c:poly({ { 22, 30 }, { 62, 30 }, { 65, 40 }, { 19, 40 } }), "#efdcaa")
  -- rolled ends
  part(c, R(c, 15, 28, 19, 42), "#d8c08a"); part(c, R(c, 64, 28, 68, 42), "#d8c08a")
  -- map corner doodles: island, grumbly mountain, compass star, winding road
  fl(c, c:ellipse(26, 33, 3, 2), "#7ab55c"); fl(c, c:ellipse(26, 33, 1, 1), "#5e8a44"); fl(c, R(c, 22, 36, 25, 36), "#78bcd0"); fl(c, R(c, 28, 35, 31, 35), "#78bcd0")
  fl(c, c:poly({ { 58, 29 }, { 61, 33 }, { 55, 33 } }), "#8a6a56"); c:px(58, 31, "#2a1a10"); c:px(59, 32, "#2a1a10")
  c:paint({ "..r..", ".rrr.", "rrrrr", ".rrr.", "..r.." }, 55, 34, { r = "#b83a2e" })
  fl(c, c:line({ { 24, 38 }, { 32, 37 }, { 38, 39 }, { 46, 36 } }, 1), "#c8802a")
  -- the cartographer behind the table pointing at a corner with a pencil
  local _, G = gnome(c, 14, 36, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ 4, 6 }, { 10, 9 }, true) } })
  local qx, qy = G.P(10, 9)
  fl(c, c:line({ { qx, qy }, { qx + 6, qy + 1 } }, 1), "#f5cf6a"); c:px(qx + 7, qy + 1, "#2a1a10")
  fl(c, R(c, qx - 1, qy - 1, qx + 1, qy + 1), "#f0c8a0")
  finish(c, "w5_map_corners")
end)

-- spring helpers ------------------------------------------------------------------
local function steam(c, x, y0, n, col)
  col = col or "#f4f8fa"
  for i = 0, n do
    local sx = x + ((i % 2 == 0) and 0 or 1)
    fl(c, R(c, sx, y0 - i * 2, sx + 1, y0 - i * 2 + 1), col)
  end
end
local function springback(c, g)
  day(c, g, { cloud = 52, hill = "#5e8a44", hill2 = "#4e8a3c" })
  -- bamboo fence + small bathhouse roof far away
  for x = 6, 30, 4 do part(c, R(c, x, g - 6, x + 1, g + 1), "#c8b060", { noline = true }) end
  fl(c, R(c, 5, g - 3, 31, g - 3), "#8a7a38")
end
local function pool(c, cx, cy, rx, ry, water, rim)
  part(c, c:ellipse(cx, cy, rx + 3, ry + 2), rim or "#8b8f96", { shade = true })
  c:fill(c:ellipse(cx, cy, rx, ry), water or "#58b4c4")
  c:fill(c:ellipse(cx, cy + 1, rx - 2, ry - 2):clip(R(c, 0, cy, W, 60)), "#4aa4b6")
end

-- 12. test the water with an elbow --------------------------------------------------
scene("w5_elbow_test", function()
  seed = 72
  local c = new()
  springback(c, 30)
  pool(c, 51, 42, 17, 6, "#7cc9c8")
  fl(c, R(c, 46, 39, 52, 39), "#b8e8e0"); fl(c, R(c, 58, 43, 63, 43), "#b8e8e0")
  for _, b in ipairs({ { 56, 40 }, { 60, 41 }, { 48, 44 } }) do c:px(b[1], b[2], "#e8f8f4"); c:px(b[1] + 1, b[2], "#e8f8f4") end
  steam(c, 54, 35, 4); steam(c, 62, 35, 3)
  -- flat rock the gnome sits on, towel hung on the fence
  part(c, c:ellipse(21, 46, 12, 3), "#9a9ea6", { shade = true })
  part(c, R(c, 8, 26, 11, 32), "#f4eee0"); fl(c, R(c, 8, 28, 11, 28), "#4a74a8"); fl(c, R(c, 8, 30, 11, 30), "#4a74a8")
  -- gnome seated, eyes screwed shut; one arm bent so the elbow dips into the water
  local _, G = gnome(c, 23, 44, { d = 1, sit = true, eyes = "shut", arms = { arm({ -3, 7 }, { -5, 4 }, false) } })
  local sx, sy = G.P(4, 8)
  fl(c, c:line({ { sx, sy }, { sx + 7, sy + 5 } }, 2), "#4a6e9a")
  fl(c, c:line({ { sx + 7, sy + 5 }, { sx + 8, sy - 4 } }, 2), "#4a6e9a")
  fl(c, R(c, sx + 7, sy - 7, sx + 9, sy - 5), "#f0c8a0")
  fl(c, R(c, sx + 3, sy + 8, sx + 12, sy + 8), "#b8e8e0"); fl(c, R(c, sx + 1, sy + 10, sx + 14, sy + 10), "#a0d8d8")
  fl(c, R(c, sx + 5, sy + 6, sx + 6, sy + 6), "#b8e8e0")
  finish(c, "w5_elbow_test")
end)

-- 13. fish out the lost sandal --------------------------------------------------------
scene("w5_lost_sandal", function()
  seed = 73
  local c = new()
  springback(c, 28)
  pool(c, 42, 40, 25, 8, "#6cc0c4")
  for _, p in ipairs({ { 28, 44 }, { 34, 46 }, { 50, 46 }, { 38, 44 } }) do fl(c, c:ellipse(p[1], p[2], 1, 1), "#8ab4b4") end
  -- a soaker with arms up, neck-deep, cheering
  gnome(c, 56, 44, { d = -1, hat = "#3f8fb0", eyes = "happy", arms = { arm({ -4, 8 }, { -7, 15 }, true), arm({ 4, 8 }, { 7, 15 }, true) } })
  local wm = c:ellipse(42, 40, 25, 8):clip(R(c, 48, 38, 66, 60))
  c:fill(wm, "#6cc0c4"); c:fill(wm:copy():clip(R(c, 0, 41, W, 60)), "#4aa4b6"); for x = 48, 66 do if x % 3 ~= 0 then c:px(x, 38, "#b8e8e0") end end
  fl(c, R(c, 50, 42, 58, 42), "#58b4c4"); fl(c, R(c, 52, 44, 62, 44), "#58b4c4")
  -- gnome on the rim with a long stick, hooking the dripping sandal
  part(c, c:ellipse(14, 47, 12, 3), "#9a9ea6", { shade = true })
  local _, G = gnome(c, 14, 46, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 4 }, false), arm({ 4, 8 }, { 8, 12 }, true, true) } })
  local hx, hy = G.P(8, 12)
  local sx, sy = 38, 25
  fl(c, c:line({ { hx - 2, hy + 4 }, { hx + 6, hy - 4 }, { sx, sy - 5 } }, 1), "#8a5a35")
  fl(c, c:line({ { sx, sy - 5 }, { sx, sy - 3 } }, 1), "#8a5a35")
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  -- the sandal: sole and a red strap arch, dripping
  part(c, c:ellipse(sx, sy + 3, 5, 2), "#e0b070"); fl(c, R(c, sx - 3, sy + 4, sx + 3, sy + 4), "#a8703e")
  fl(c, c:line({ { sx - 3, sy + 2 }, { sx - 1, sy - 1 }, { sx + 1, sy - 1 }, { sx + 3, sy + 2 } }, 2), "#dd3a2a")
  for _, p in ipairs({ { sx - 3, sy + 7 }, { sx + 2, sy + 9 }, { sx, sy + 12 } }) do c:px(p[1], p[2], "#a8e6e6"); c:px(p[1], p[2] + 1, "#a8e6e6") end
  fl(c, R(c, sx - 4, sy + 15, sx + 4, sy + 15), "#b8e8e0"); fl(c, R(c, sx - 6, sy + 17, sx + 6, sy + 17), "#a0d8d8")
  finish(c, "w5_lost_sandal")
end)

-- 14. fold the towel mountain (dusk) ----------------------------------------------------
scene("w5_towel_mountain", function()
  seed = 74
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#3b2f66", "#4e3a78", "#7a4a88", "#b45a7c", "#e8825e", "#f0a868" }, { dir = "v" })
  for _, p in ipairs({ { 9, 8 }, { 24, 6 }, { 58, 9 }, { 66, 14 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(10, 36, 28, 9), "#2f2a58"); c:fill(c:ellipse(62, 35, 28, 8), "#352c5c")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#3a5a42")
  planks(c, 44, 49, "#6b4a30", "#4a3220")
  -- lanterns either side
  for _, x in ipairs({ 9, 63 }) do
    part(c, R(c, x, 24, x + 1, 46), "#3d2a1c", { noline = true })
    part(c, R(c, x - 2, 18, x + 3, 24), "#ffd86a"); fl(c, R(c, x, 19, x + 1, 22), "#fff1c8")
    fl(c, R(c, x - 3, 17, x + 4, 17), "#3d2a1c")
  end
  -- the mountain of towels: rounded stacks, each row narrower
  local tcol = { "#f4eee0", "#e8e0cc", "#cfe0ee", "#f4eee0", "#f0d8d0", "#e8e0cc" }
  local rows = { { 42 }, { 36 }, { 30 }, { 24 } }
  local y = 44
  for i = 1, 4 do
    local w, rh = rows[i][1], 6
    local x0 = 36 - floor(w / 2)
    part(c, c:rrect(x0, y - rh, x0 + w, y, 2), tcol[i])
    fl(c, R(c, x0 + 2, y - 3, x0 + w - 2, y - 3), (i % 2 == 0) and "#4a74a8" or "#dd5a42")
    fl(c, R(c, x0 + 2, y - 2, x0 + w - 2, y - 2), (i % 2 == 0) and "#4a74a8" or "#dd5a42")
    y = y - rh + 1
  end
  -- little climber at the summit, flying a lone sock like a flag
  local top = y
  local _, G = gnome(c, 33, top + 1, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 7, 17 }, true, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  local hx, hy = G.P(7, 17)
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  part(c, R(c, hx, hy - 8, hx + 3, hy - 3), "#e46a9b"); part(c, R(c, hx - 2, hy - 8, hx + 3, hy - 6), "#e46a9b")
  fl(c, R(c, hx, hy - 5, hx + 3, hy - 5), "#f4eee0")
  steam(c, 16, 44, 3, "#e8d0d8"); steam(c, 56, 44, 4, "#e8d0d8")
  finish(c, "w5_towel_mountain")
end)

-- 15. mineral mud masks -------------------------------------------------------------------
scene("w5_mud_masks", function()
  seed = 75
  local c = new()
  springback(c, 28)
  -- grey mud pool bubbling at the right
  pool(c, 54, 38, 14, 5, "#8a8f86", "#8b8f96")
  c:fill(c:ellipse(54, 39, 11, 3), "#7a8078")
  for _, b in ipairs({ { 50, 37 }, { 56, 38 }, { 59, 36 } }) do fl(c, c:ellipse(b[1], b[2], 1, 1), "#a8aea4"); c:px(b[1] - 1, b[2] - 1, "#c8cec4") end
  steam(c, 52, 32, 4); steam(c, 60, 31, 4)
  -- wooden spa shelf with a bowl of mud and a brush
  part(c, R(c, 4, 38, 14, 48), "#a8703e"); fl(c, R(c, 4, 38, 14, 38), "#d9a660"); fl(c, R(c, 4, 43, 14, 43), "#8a4f2a")
  part(c, R(c, 6, 33, 12, 37), "#c9c5bc"); fl(c, R(c, 6, 33, 12, 34), "#8a8f86")
  -- big gnome portrait, face and beard pasted with grey mud
  local _, G = gnome(c, 34, 52, { d = 1, upper = true, s = 1.6, eyes = "open", arms = { arm({ -4, 9 }, { -5, 12 }, false, true), arm({ 4, 9 }, { 5, 14 }, true, true) } })
  local mud = G.sym(-3, 10, 3, 11)
  local a, b, d, e = mud:bbox()
  local fx0, fx1 = a, d
  local beardm = c:rect(G.ox + floor(-3 * G.s + 0.5), select(1, G.ry(2, 9)), G.ox + floor(4 * G.s + 0.5) - 1, select(2, G.ry(2, 9)))
  c:fill(mud, "#8e948a"); c:fill(beardm, "#8e948a")
  -- mud cracks, flecks and the face holes
  local bx0, by0, bx1, by1 = beardm:bbox()
  for i = 1, 14 do
    local x, y = bx0 + 1 + floor(rand() * (bx1 - bx0 - 1)), by0 + floor(rand() * (by1 - by0))
    c:px(x, y, "#6e756c")
  end
  fl(c, R(c, fx0, b + 3, fx1, b + 3), "#6e756c")
  -- eyes peering out
  local ey = b + 1
  local ex1, ex2 = G.ox + floor(-1 * G.s + 0.5), G.ox + floor(2 * G.s + 0.5)
  for _, ex in ipairs({ ex1, ex2 }) do fl(c, R(c, ex, ey, ex + 1, ey + 1), "#f4eee0"); c:px(ex + 1, ey + 1, INK) end
  -- a happy mouth
  fl(c, R(c, G.ox - 1, by0 + 2, G.ox + 2, by0 + 2), "#f4eee0")
  -- hand lifts a glob of mud
  local gx, gy = G.P(5, 14)
  fl(c, R(c, gx - 1, gy - 1, gx + 2, gy + 2), "#f0c8a0"); fl(c, c:ellipse(gx + 1, gy - 2, 1, 1), "#8e948a")
  finish(c, "w5_mud_masks")
end)

for _, s2 in ipairs(ORDER) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
