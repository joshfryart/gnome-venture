-- variety-act-g19.lua : Do-tab scenes for 15 orchard/ferry rest-stop activities -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g19.lua   (params BEFORE --script)
-- Gnome sprite + frame handling copied from variety-act-g5.lua.
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


---------------------------------------------------------------- shared props
local function barrel(c, cx, by, w, h, col, hoop)
  col = col or "#a8703e"; hoop = hoop or "#4a3020"
  local x0 = cx - floor(w / 2)
  part(c, c:rrect(x0, by - h + 1, x0 + w - 1, by, 3), col)
  fl(c, R(c, x0 + 1, by - h + 3, x0 + w - 2, by - h + 3), hoop)
  fl(c, R(c, x0 + 1, by - 3, x0 + w - 2, by - 3), hoop)
  fl(c, R(c, cx - 1, by - h + 5, cx - 1, by - 5), "#c08a52")
  fl(c, R(c, cx + 2, by - h + 5, cx + 2, by - 5), "#8a5a35")
end

-- water band with ripple glints. top y0..y1
local function river(c, y0, y1, cols, glint)
  c:bands(R(c, 0, y0, W - 1, y1), cols or { "#5aa0c0", "#4a90b4", "#3f80a8" }, { dir = "v" })
  seed = 99
  for i = 1, 14 do
    local x, y = floor(rand() * 62) + 4, y0 + 2 + floor(rand() * (y1 - y0 - 3))
    fl(c, R(c, x, y, x + 2 + floor(rand() * 3), y), glint or "#a8d4e4")
  end
end

-- a flat river boat seen from the side: deck line y, from x0 to x1
local function flatboat(c, x0, x1, y, tilt)
  tilt = tilt or 0
  local hull = c:poly({ { x0, y }, { x1, y + tilt }, { x1 - 3, y + tilt + 6 }, { x0 + 3, y + 6 } })
  part(c, hull, "#8a5a35")
  c:fill(c:poly({ { x0 + 1, y + 1 }, { x1 - 1, y + tilt + 1 }, { x1 - 1, y + tilt + 2 }, { x0 + 1, y + 2 } }), "#c08a52")
  for x = x0 + 6, x1 - 5, 7 do fl(c, R(c, x, y + 3, x, y + 5 + (tilt > 0 and 1 or 0)), "#5e3f28") end
end

local function tree(c, x, yb, h, rw, col)
  part(c, R(c, x - 1, yb - h, x + 1, yb), "#6b4a2e", { noline = true })
  part(c, c:ellipse(x, yb - h - 4, rw, floor(rw * 0.8)), col or "#3f8a42", { shade = true })
end

local function apple(c, x, y, col)
  part(c, c:ellipse(x, y, 1, 1), col or "#dd3a2a", { noline = true }); c:px(x, y - 1, "#ff8a7a")
end

---------------------------------------------------------------- scenes
local S = {}

-- 1. cider_barrel: three barrels in the cider shed, the middle one mid-roll
function S.w4_cider_barrel()
  seed = 2
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#b27a46")
  for x = 3, W - 1, 6 do fl(c, R(c, x, 0, x, 40), "#8f5e34") end
  fl(c, R(c, 0, 6, W - 1, 7), "#6b3b2a")
  -- window with an apple tree outside
  part(c, R(c, 52, 11, 65, 24), "#a8d4e0"); fl(c, R(c, 53, 12, 64, 16), "#bcdde4")
  fl(c, R(c, 58, 11, 59, 24), "#8a5a35"); fl(c, R(c, 52, 17, 65, 18), "#8a5a35")
  c:fill(c:ellipse(56, 22, 3, 2), "#4e8a3c"); apple(c, 55, 22, "#dd3a2a"); apple(c, 62, 21, "#dd3a2a")
  -- hanging cider cups on a shelf
  fl(c, R(c, 7, 17, 25, 17), "#6b3b2a")
  for i = 0, 3 do part(c, R(c, 9 + i * 4, 14, 11 + i * 4, 16), "#e8c48a", { noline = true }) end
  c:fill(R(c, 0, 41, W - 1, H - 1), "#7a4a2a")
  for y = 44, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#5e2f1e") end
  -- barrels: left, middle lifted and tilting in a roll, right
  barrel(c, 30, 46, 12, 14, "#a8703e")
  barrel(c, 62, 46, 12, 14, "#a8703e")
  -- middle barrel mid-air shuffle: lifted with dust + motion arcs
  barrel(c, 46, 42, 12, 14, "#c08a52")
  for _, d in ipairs({ { 38, 40 }, { 36, 43 }, { 55, 45 }, { 58, 43 } }) do fl(c, R(c, d[1], d[2], d[1] + 1, d[2]), "#e8d2a0") end
  -- swirl arrows over the middle barrel
  for _, q in ipairs({ { 38, 28, 38, 31 }, { 37, 32, 37, 34 }, { 55, 28, 55, 31 }, { 56, 32, 56, 34 } }) do fl(c, R(c, q[1], q[2], q[3], q[4]), "#f4eee0") end
  -- a drip of cider
  fl(c, R(c, 44, 45, 44, 46), "#e8a317"); fl(c, R(c, 47, 46, 47, 47), "#e8a317")
  -- gnome with finger up and a cup
  gnome(c, 14, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 13 }, true), arm({ -4, 6 }, { -6, 4 }, false) } })
  -- the clue mark above the real barrel: a gold ring
  c:px(46, 34, "#f5cf6a"); c:px(47, 34, "#f5cf6a")
  finish(c, "w4_cider_barrel")
end

-- 2. top_apple: a pole with a hook reaching the single topmost apple, a short ladder beside
function S.w4_top_apple()
  seed = 6
  local c = new()
  day(c, 41, { cloud = 14, hill = "#5e8a44", hill2 = "#4e8a3c", sky = { "#a8d4e0", "#bcdde4", "#cfe8e6" } })
  -- tall tree, canopy near the top frame
  part(c, R(c, 51, 20, 55, 46), "#7a4a2a", { noline = true })
  fl(c, R(c, 53, 24, 53, 44), "#5e2f1e")
  part(c, c:ellipse(53, 17, 15, 10), "#3f8a42", { shade = true })
  c:fill(c:ellipse(49, 13, 5, 2), "#5aaa50"); c:fill(c:ellipse(60, 18, 4, 2), "#4e9a48")
  for _, p in ipairs({ { 44, 18 }, { 50, 22 }, { 58, 22 }, { 63, 15 }, { 56, 12 }, { 66, 20 } }) do apple(c, p[1], p[2], "#e04a3a") end
  -- the topmost apple on a twig above the canopy, bigger and golden-red
  part(c, c:line({ { 49, 12 }, { 47, 9 } }, 2), "#6b4a2e", { noline = true })
  part(c, c:ellipse(46, 9, 2, 2), "#e8352a", { noline = true }); c:px(45, 8, "#ff9a8a"); fl(c, R(c, 47, 6, 48, 7), "#4e8a3c")
  -- the short ladder
  c:fill(c:line({ { 42, 46 }, { 46, 28 } }, 2), "#b07a45"); c:fill(c:line({ { 47, 46 }, { 50, 28 } }, 2), "#b07a45")
  for i = 0, 3 do fl(c, R(c, 43 + (i < 2 and 0 or 0), 43 - i * 5, 48, 43 - i * 5), "#8a5a35") end
  -- gnome reaching with a long hooked pole
  local _, G = gnome(c, 22, 47, { d = 1, eyes = "open", arms = { arm({ 4, 11 }, { 8, 17 }, true, true), arm({ -4, 9 }, { 2, 14 }, false, true) } })
  c:fill(c:line({ { 25, 33 }, { 43, 11 } }, 2), "#b07a45")
  c:fill(c:line({ { 43, 11 }, { 44, 8 } }, 2), "#b07a45"); c:fill(R(c, 44, 7, 46, 8), "#8b929c"); c:px(46, 9, "#8b929c")
  fl(c, R(c, 25, 32, 27, 34), "#f0c8a0"); fl(c, R(c, 28, 29, 29, 30), "#f0c8a0")
  -- hat left on grass for catching
  part(c, c:ellipse(10, 48, 4, 1), "#c0442e", { noline = true })
  for _, p in ipairs({ { 30, 48 }, { 36, 47 }, { 62, 48 } }) do apple(c, p[1], p[2], "#9ab04a") end
  c:px(44, 3, "#f5cf6a")
  finish(c, "w4_top_apple")
end

-- 3. oldest_tree: dusk, a vast crooked tree with a hollow, one pear branch, the grafter seated against it
function S.w4_oldest_tree()
  seed = 15
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#5a4a8a", "#8a5a8e", "#c0668a", "#e8845e", "#f0a868" }, { dir = "v" })
  c:fill(c:ellipse(10, 38, 30, 9), "#4a3a68"); c:fill(c:ellipse(62, 38, 30, 8), "#54406c")
  c:fill(R(c, 0, 37, W - 1, H - 1), "#5a7a3e")
  fl(c, R(c, 0, 37, W - 1, 37), "#7a9a50")
  -- orchard rows (small dark trees) in the distance
  for x = 8, 66, 12 do part(c, c:ellipse(x, 35, 4, 4), "#3a4a4a", { noline = true }); fl(c, R(c, x, 36, x, 38), "#2a2a30") end
  -- long shadows
  c:fill(c:ellipse(30, 46, 24, 2), "#476634"); c:fill(c:ellipse(30, 43, 20, 1), "#476634")
  -- the vast crooked trunk
  local trunk = c:poly({ { 46, 46 }, { 56, 46 }, { 58, 34 }, { 62, 24 }, { 56, 12 }, { 46, 12 }, { 48, 24 }, { 44, 34 } })
  part(c, trunk, "#6b4a2e")
  fl(c, R(c, 50, 22, 50, 44), "#4e3220"); fl(c, R(c, 55, 28, 55, 44), "#4e3220")
  -- hollow
  c:fill(c:ellipse(52, 33, 3, 4), "#2a1a10"); c:fill(c:ellipse(52, 31, 2, 2), "#3d2a1c")
  -- canopy and the pear branch
  part(c, c:ellipse(50, 10, 17, 8), "#46823c", { shade = true })
  part(c, c:ellipse(66, 14, 5, 5), "#3a7a3a", { shade = true })
  part(c, c:line({ { 46, 15 }, { 34, 15 }, { 29, 17 } }, 2), "#6b4a2e", { noline = true })
  part(c, c:ellipse(30, 13, 4, 2), "#4e9a48", { noline = true })
  for _, p in ipairs({ { 33, 19 }, { 38, 19 }, { 42, 19 } }) do
    part(c, c:ellipse(p[1], p[2], 1, 2), "#c8d048", { noline = true }); c:px(p[1], p[2] + 1, "#a8b838"); c:px(p[1], p[2] - 1, "#e8ec8a")
  end
  for _, p in ipairs({ { 54, 8 }, { 60, 12 }, { 46, 9 } }) do apple(c, p[1], p[2], "#e0503a") end
  -- the grafter on the root, listening gnome tiny to the left
  part(c, R(c, 30, 45, 39, 47), "#4a6e9a", { noline = true }); part(c, R(c, 27, 44, 30, 47), "#5a3a22", { noline = true })
  gnome(c, 40, 46, { d = -1, upper = true, eyes = "open", arms = { arm({ -4, 7 }, { -8, 11 }, true) } })
  for _, p in ipairs({ { 12, 44 }, { 18, 47 }, { 6, 47 } }) do c:px(p[1], p[2], "#e46a9b") end
  c:px(10, 10, "#f4eee0"); c:px(36, 8, "#f4eee0"); c:px(24, 6, "#f4eee0")
  finish(c, "w4_oldest_tree")
end

-- 4. cider_shed_tales: night, lantern on a barrel, a humming barrel with notes, crickets
function S.w4_cider_shed_tales()
  seed = 23
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#1e2848", "#27345a", "#2f3e68" }, { dir = "v" })
  for _, p in ipairs({ { 9, 8 }, { 24, 6 }, { 38, 9 }, { 50, 7 }, { 64, 10 }, { 14, 18 }, { 58, 18 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(11, 12, 3, 3), "#f5e6a8"); c:fill(c:ellipse(13, 11, 2, 2), "#27345a")
  c:fill(R(c, 0, 38, W - 1, H - 1), "#2a4a38")
  fl(c, R(c, 0, 38, W - 1, 38), "#3a5a44")
  -- the shed: dark plank wall, roof, open door with warm light
  part(c, R(c, 28, 17, 68, 42), "#4a3a34")
  for x = 31, 66, 5 do fl(c, R(c, x, 20, x, 41), "#38281f") end
  part(c, c:poly({ { 48, 8 }, { 69, 18 }, { 27, 18 } }), "#5e3a2e")
  fl(c, R(c, 29, 18, 68, 18), "#3a2820")
  part(c, R(c, 52, 24, 64, 42), "#e8a850")
  fl(c, R(c, 53, 25, 63, 41), "#f5cf6a")
  part(c, R(c, 55, 32, 61, 41), "#8a5a35"); fl(c, R(c, 55, 35, 61, 35), "#4a3020")
  c:fill(c:ellipse(46, 46, 20, 2), "#34523c")
  -- the humming barrel with notes
  barrel(c, 44, 46, 12, 14, "#8a5a35")
  fl(c, R(c, 40, 36, 40, 36), "#f5cf6a")
  local function note(x, y) fl(c, R(c, x, y, x + 1, y + 1), "#f5cf6a"); fl(c, R(c, x + 1, y - 4, x + 1, y), "#f5cf6a"); c:px(x + 2, y - 4, "#f5cf6a") end
  note(40, 31); note(46, 26); note(51, 30)
  -- lantern on a barrel
  barrel(c, 30, 46, 11, 10, "#a8703e")
  part(c, R(c, 28, 33, 32, 37), "#ffd86a"); fl(c, R(c, 29, 34, 31, 36), "#fff1c8"); fl(c, R(c, 28, 32, 32, 32), "#3d2a1c")
  c:px(30, 31, "#3d2a1c")
  for _, p in ipairs({ { 25, 33 }, { 35, 33 }, { 24, 38 }, { 36, 37 } }) do c:px(p[1], p[2], "#8a6a40") end
  -- gnome seated on a crate, talking, hands up
  part(c, R(c, 8, 41, 22, 48), "#8a5a35"); fl(c, R(c, 9, 41, 21, 41), "#a8703e")
  gnome(c, 13, 41, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 8, 14 }, true), arm({ -3, 6 }, { -5, 4 }, false) } })
  -- crickets in the grass
  local function cricket(x, y) fl(c, R(c, x, y, x + 2, y), "#7ab55c"); c:px(x + 3, y - 1, "#7ab55c"); c:px(x - 1, y - 1, "#7ab55c"); c:px(x + 1, y - 1, "#7ab55c") end
  cricket(60, 47); cricket(5, 48); cricket(22, 49)
  c:px(63, 44, "#f4eee0"); c:px(66, 43, "#f4eee0"); c:px(7, 45, "#f4eee0")
  finish(c, "w4_cider_shed_tales")
end

-- 5. cow_aboard: dawn landing, a cow sitting on the last plank, gnome offering a turnip
function S.w4_cow_aboard()
  seed = 31
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#f0b8a0", "#f4cdb0", "#f6dcb8", "#f6e8c8" }, { dir = "v" })
  c:fill(c:ellipse(52, 28, 6, 6), "#fff0a0")
  c:fill(c:ellipse(16, 31, 30, 8), "#7a8a6a")
  river(c, 31, 49, { "#e0a898", "#c8a0a0", "#90a8b8", "#7098b0" }, "#f6e0c0")
  -- shore with plank walkway
  part(c, R(c, 0, 36, 32, 49), "#7ea85a", { noline = true })
  fl(c, R(c, 0, 36, 32, 36), "#9cc070")
  part(c, R(c, 20, 40, 54, 43), "#b07a45")
  for x = 24, 52, 6 do fl(c, R(c, x, 41, x, 42), "#8a5a35") end
  -- flat boat waiting
  flatboat(c, 53, 72, 38, 0)
  part(c, R(c, 61, 31, 62, 38), "#6b4a2e", { noline = true }); fl(c, R(c, 60, 30, 63, 30), "#c0442e")
  -- the cow, sitting down and refusing
  part(c, c:rrect(28, 28, 44, 40, 5), "#f4eee0")
  part(c, c:ellipse(34, 33, 3, 3), "#4a3a30", { noline = true }); part(c, c:ellipse(40, 36, 3, 2), "#4a3a30", { noline = true })
  part(c, c:rrect(43, 26, 50, 34, 3), "#f4eee0")
  fl(c, R(c, 47, 31, 50, 33), "#e8a0a0")
  c:px(45, 29, INK); c:px(44, 25, "#6b4a2e"); c:px(48, 25, "#6b4a2e"); fl(c, R(c, 42, 24, 42, 25), "#e8d2a0"); fl(c, R(c, 50, 24, 50, 25), "#e8d2a0")
  fl(c, R(c, 29, 39, 42, 40), "#d8c8b0"); fl(c, R(c, 26, 31, 27, 36), "#4a3a30")
  -- gnome waving a turnip
  gnome(c, 13, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 12 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  part(c, c:ellipse(25, 33, 2, 2), "#f4eee0", { noline = true }); fl(c, R(c, 24, 34, 26, 35), "#a050a0"); fl(c, R(c, 25, 29, 26, 31), "#4e8a3c")
  finish(c, "w4_cow_aboard")
end

-- 6. fog_reading: standing at the bow in thick fog, pointing the way across; a faint heron on the far side
function S.w4_fog_reading()
  seed = 41
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#c4ced2", "#cdd6d8", "#d6dede", "#dfe5e4" }, { dir = "v" })
  c:bands(R(c, 0, 34, W - 1, H - 1), { "#b4c2c6", "#a6b6bc", "#98aab2", "#8aa0a8" }, { dir = "v" })
  -- ghostly heron and reeds, barely there
  local hc = "#a8b6bc"
  hc = "#8c9ca6"
  part(c, c:ellipse(33, 31, 3, 2), hc, { noline = true }); fl(c, R(c, 35, 24, 35, 29), hc); fl(c, R(c, 34, 23, 36, 24), hc); fl(c, R(c, 37, 24, 39, 24), "#bcae9a")
  fl(c, R(c, 32, 33, 32, 38), hc); fl(c, R(c, 29, 30, 30, 31), hc)
  for _, x in ipairs({ 62, 64, 66, 40, 42 }) do fl(c, R(c, x, 31 - (x % 3), x, 37), "#9caaa8") end
  -- fog banks
  fl(c, R(c, 0, 25, W - 1, 28), "#e4e9e8"); fl(c, R(c, 8, 29, 60, 30), "#e4e9e8")
  fl(c, R(c, 0, 36, 40, 37), "#d6dede"); fl(c, R(c, 30, 40, W - 1, 41), "#cdd6d8")
  fl(c, R(c, 0, 46, 50, 47), "#c0ccd0")
  -- the boat's bow
  flatboat(c, 4, 70, 40, 0)
  part(c, R(c, 60, 28, 61, 40), "#6b4a2e", { noline = true })
  part(c, R(c, 58, 22, 63, 27), "#ffd86a"); fl(c, R(c, 59, 23, 62, 26), "#fff1c8"); fl(c, R(c, 58, 21, 63, 21), "#3d2a1c")
  -- lantern halo rays
  for _, p in ipairs({ { 56, 24 }, { 65, 24 }, { 60, 19 } }) do c:px(p[1], p[2], "#f4eee0") end
  -- a pole man behind, only a hat showing above the rail
  gnome(c, 18, 40, { d = 1, hat = "#4f9a45", upper = false, s = 1, eyes = "open", arms = { arm({ 3, 8 }, { 3, 18 }, true, true) } })
  c:fill(R(c, 21, 20, 22, 44), "#8a5a35")
  -- our gnome points across
  gnome(c, 44, 40, { d = 1, eyes = "open", arms = { arm({ 4, 11 }, { 12, 12 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  finish(c, "w4_fog_reading")
end

-- 7. mooring_line: the boat comes in, the porter flings a rope, gnome catches it one-handed
function S.w4_mooring_line()
  seed = 52
  local c = new()
  day(c, 33, { cloud = 40, hill = "#5e8a44", hill2 = "#4e8a3c" })
  river(c, 33, 49)
  -- dock at left
  part(c, R(c, 5, 38, 30, 41), "#b07a45")
  for x = 9, 28, 6 do fl(c, R(c, x, 39, x, 40), "#8a5a35") end
  for _, x in ipairs({ 8, 18, 28 }) do part(c, R(c, x, 41, x + 1, 49), "#5e3f28", { noline = true }) end
  part(c, R(c, 28, 31, 30, 38), "#6b4a2e"); fl(c, R(c, 28, 31, 30, 31), "#8a5a35")
  -- boat coming in fast, bow wave
  flatboat(c, 38, 74, 37, 0)
  fl(c, R(c, 34, 43, 38, 43), "#f4f8fa"); fl(c, R(c, 32, 45, 36, 45), "#f4f8fa"); fl(c, R(c, 37, 47, 41, 47), "#f4f8fa")
  fl(c, R(c, 60, 31, 61, 37), "#6b4a2e")
  -- porter throwing, arm swung forward
  gnome(c, 56, 37, { d = -1, hat = "#4f9a45", eyes = "open", arms = { arm({ -4, 9 }, { -8, 14 }, true), arm({ 4, 6 }, { 6, 4 }, false) } })
  -- the rope in an arc between the two hands
  local x0, y0, x1, y1 = 45, 24, 24, 24
  for i = 0, 22 do
    local t = i / 22
    local x = rnd(x0 + (x1 - x0) * t)
    local y = rnd(y0 + (y1 - y0) * t - 7 * 4 * t * (1 - t))
    fl(c, R(c, x, y, x, y), "#f0d890")
    if i % 3 == 0 then c:px(x, y + 1, "#b8965c") end
  end
  -- coil trailing on the boat
  part(c, c:ellipse(52, 35, 3, 2), "#e0c88a", { noline = true }); c:fill(c:ellipse(52, 35, 1, 1), "#a8703e")
  -- gnome, one hand up to catch
  gnome(c, 15, 38, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 8, 18 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  finish(c, "w4_mooring_line")
end

-- 8. trim_cargo: the flat boat lists to one end under turnips, a harp and three hens; the gnome shoves a barrel back
function S.w4_trim_cargo()
  seed = 63
  local c = new()
  day(c, 30, { cloud = 14, hill = "#5e8a44", hill2 = "#4e8a3c" })
  river(c, 30, 49)
  -- tilted hull: high at left, low at right
  local hull = c:poly({ { 3, 33 }, { 64, 43 }, { 60, 50 }, { 8, 41 } })
  part(c, hull, "#8a5a35")
  c:fill(c:poly({ { 4, 34 }, { 64, 43 }, { 64, 44 }, { 4, 35 } }), "#c08a52")
  for x = 12, 58, 9 do fl(c, R(c, x, 38 + floor((x - 10) * 0.16), x, 41 + floor((x - 10) * 0.16)), "#5e3f28") end
  -- cargo piled at the low end: turnips, harp, hens
  local function dk(x) return 34 + floor((x - 3) * 9 / 61) end
  local function turnip(x, y) part(c, c:ellipse(x, y, 2, 2), "#f4eee0", { noline = true }); fl(c, R(c, x - 1, y - 1, x + 1, y - 1), "#a050a0"); fl(c, R(c, x, y - 4, x, y - 3), "#4e8a3c") end
  turnip(35, dk(35) - 2); turnip(39, dk(39) - 2); turnip(37, dk(37) - 5)
  part(c, c:line({ { 44, dk(44) } , { 44, dk(44) - 10 } }, 2), "#e8a317", { noline = true })
  part(c, c:line({ { 44, dk(44) - 10 }, { 49, dk(44) - 12 }, { 49, dk(49) } }, 2), "#e8a317", { noline = true })
  for x = 46, 48 do fl(c, R(c, x, dk(44) - 10 - floor((x - 45) * 0.5), x, dk(49) - 2), "#f4eee0") end
  local function hen(x, y, col)
    part(c, c:ellipse(x, y, 3, 2), col); c:px(x + 2, y - 3, "#dd3a2a"); c:px(x + 3, y - 3, "#dd3a2a")
    fl(c, R(c, x + 2, y - 2, x + 3, y - 1), col); c:px(x + 4, y - 2, "#e8a317"); c:px(x + 3, y - 2, INK)
  end
  hen(53, dk(53) - 2, "#c08a52"); hen(59, dk(59) - 2, "#f4eee0"); hen(56, dk(56) - 6, "#4a3a30")
  -- gnome hauling a barrel back up toward the middle
  gnome(c, 16, 35, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 9 }, true) } })
  barrel(c, 26, dk(26) + 1, 9, 10, "#a8703e")
  -- sloshing
  fl(c, R(c, 54, 47, 60, 47), "#a8d4e4"); fl(c, R(c, 63, 46, 67, 46), "#a8d4e4"); fl(c, R(c, 66, 41, 68, 41), "#a8d4e4")
  finish(c, "w4_trim_cargo")
end

-- 9. toll_count: dusk in the toll-house, the day's tin tipped out, gnome tallying in tens
function S.w4_toll_count()
  seed = 71
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#8f6e4a")
  for x = 2, W - 1, 6 do fl(c, R(c, x, 0, x, 40), "#6f5238") end
  c:fill(R(c, 0, 41, W - 1, H - 1), "#5e3f28")
  for y = 45, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#4a2f1e") end
  -- window onto the dusk river
  part(c, R(c, 7, 9, 22, 25), "#e8845e")
  c:bands(R(c, 8, 10, 21, 24), { "#6a4a8a", "#b45a7c", "#e8845e", "#f0a868" }, { dir = "v" })
  c:fill(c:ellipse(15, 24, 4, 3):clip(R(c, 8, 10, 21, 24)), "#ffd86a")
  fl(c, R(c, 14, 9, 15, 25), "#6b3b2a"); fl(c, R(c, 7, 17, 22, 18), "#6b3b2a")
  -- chalk slate with tally marks
  part(c, R(c, 26, 9, 48, 23), "#3a4a4a")
  fl(c, R(c, 25, 9, 49, 9), "#8a5a35")
  for g = 0, 1 do
    for k = 0, 3 do fl(c, R(c, 30 + g * 9 + k * 2, 12, 30 + g * 9 + k * 2, 17), "#f4eee0") end
    fl(c, R(c, 29 + g * 9, 16, 37 + g * 9, 13), "#f4eee0")
  end
  for k = 0, 2 do fl(c, R(c, 31 + k * 2, 19, 31 + k * 2, 21), "#f4eee0") end
  -- hanging lantern
  fl(c, R(c, 57, 5, 57, 12), "#3d2a1c"); part(c, R(c, 54, 12, 60, 19), "#ffd86a"); fl(c, R(c, 55, 13, 59, 18), "#fff1c8"); fl(c, R(c, 54, 11, 60, 11), "#3d2a1c")
  for _, p in ipairs({ { 52, 15 }, { 62, 15 }, { 57, 21 } }) do c:px(p[1], p[2], "#f8c070") end
  -- table
  part(c, R(c, 22, 31, 68, 38), "#b07a45")
  fl(c, R(c, 23, 31, 67, 31), "#d9a660")
  part(c, R(c, 22, 39, 68, 42), "#8a5a35")
  part(c, R(c, 24, 43, 26, 49), "#6b3b2a", { noline = true }); part(c, R(c, 62, 43, 64, 49), "#6b3b2a", { noline = true })
  -- the tin, tipped on its side with the spill
  part(c, R(c, 60, 26, 67, 31), "#aeb4bc"); fl(c, R(c, 60, 27, 61, 30), "#4a3a30"); fl(c, R(c, 62, 27, 62, 30), "#d8dce0"); fl(c, R(c, 58, 30, 59, 30), "#e46a9b"); fl(c, R(c, 57, 31, 58, 31), "#8a4f2a")
  -- tens of petals (pink), acorns (brown), the button, the poem
  for k = 0, 9 do fl(c, R(c, 26 + k * 2 + (k >= 5 and 2 or 0), 33, 26 + k * 2 + (k >= 5 and 2 or 0), 33), "#e46a9b") end
  for k = 0, 9 do
    local x = 25 + k * 3 + (k >= 5 and 2 or 0)
    fl(c, R(c, x, 36, x + 1, 37), "#8a4f2a"); c:px(x, 35, "#5e2f1e"); c:px(x + 1, 35, "#5e2f1e")
  end
  part(c, c:ellipse(54, 35, 2, 2), "#3f8fb0", { noline = true }); c:px(53, 35, "#d6ecf4"); c:px(55, 35, "#d6ecf4"); c:px(54, 34, "#d6ecf4")
  part(c, R(c, 62, 34, 66, 37), "#f4eee0", { noline = true }); fl(c, R(c, 64, 34, 64, 37), "#dd3a2a")
  -- the gnome counting with one finger
  gnome(c, 13, 47, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 9, 13 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  finish(c, "w4_toll_count")
end

-- 10. mussel_broth: stirring a pot on the little landing stove; a bucket of mussels, a row of mugs
function S.w4_mussel_broth()
  seed = 82
  local c = new()
  day(c, 25, { cloud = 14, hill = "#5e8a44", hill2 = "#4e8a3c" })
  river(c, 26, 38)
  flatboat(c, 40, 74, 30, 0)
  c:fill(R(c, 0, 39, W - 1, H - 1), "#b8965c")
  fl(c, R(c, 0, 39, W - 1, 39), "#d9bc84")
  for y = 43, 53, 5 do fl(c, R(c, 0, y, W - 1, y), "#8a6a40") end
  -- iron stove with a pipe and pot
  fl(c, R(c, 46, 8, 47, 30), "#4a4c56"); fl(c, R(c, 45, 7, 48, 8), "#3d3f48")
  part(c, R(c, 35, 33, 51, 46), "#4a4c56")
  fl(c, R(c, 36, 34, 50, 34), "#6a6c76")
  part(c, R(c, 39, 38, 46, 43), "#f08a24"); fl(c, R(c, 40, 40, 45, 42), "#ffd86a")
  fl(c, R(c, 36, 46, 37, 48), "#3d3f48"); fl(c, R(c, 49, 46, 50, 48), "#3d3f48")
  part(c, R(c, 38, 24, 48, 33), "#7a7e8a"); fl(c, R(c, 37, 24, 49, 24), "#9a9ea6")
  fl(c, R(c, 39, 25, 47, 25), "#e8d2a0")
  fl(c, R(c, 36, 27, 37, 29), "#3d3f48"); fl(c, R(c, 49, 27, 50, 29), "#3d3f48")
  -- steam
  for _, p in ipairs({ { 41, 20 }, { 44, 16 }, { 40, 13 }, { 43, 10 } }) do fl(c, c:ellipse(p[1], p[2], 2, 1), "#f4f8fa") end
  -- gnome stirring with a long ladle
  gnome(c, 24, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 12 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  c:fill(c:line({ { 33, 35 }, { 41, 25 } }, 2), "#b07a45")
  part(c, c:ellipse(42, 26, 2, 1), "#aeb4bc", { noline = true })
  -- bucket of blue mussels at left
  part(c, R(c, 4, 40, 13, 47), "#8a5a35"); fl(c, R(c, 4, 42, 13, 42), "#6b3b2a"); fl(c, R(c, 4, 45, 13, 45), "#6b3b2a")
  for _, p in ipairs({ { 5, 38 }, { 8, 37 }, { 11, 38 }, { 7, 35 }, { 10, 35 } }) do part(c, c:ellipse(p[1], p[2], 2, 1), "#3a4a7a", { noline = true }); c:px(p[1] - 1, p[2] - 1, "#7a8aba") end
  for _, p in ipairs({ { 16, 48 }, { 19, 49 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#3a4a7a", { noline = true }) end
  -- the porters' mugs on a crate
  part(c, R(c, 56, 41, 68, 48), "#8a5a35"); fl(c, R(c, 57, 41, 67, 41), "#b07a45")
  for k = 0, 2 do
    part(c, R(c, 57 + k * 4, 36, 60 + k * 4, 40), "#aeb4bc"); fl(c, R(c, 58 + k * 4, 37, 59 + k * 4, 37), "#e8d2a0")
  end
  fl(c, R(c, 58, 31, 58, 33), "#f4f8fa"); fl(c, R(c, 62, 29, 62, 31), "#f4f8fa")
  finish(c, "w4_mussel_broth")
end

-- 11. smoke_trout: inside the toll-house chimney, three trout hanging golden; gnome checks his pocket watch
function S.w4_smoke_trout()
  seed = 93
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 42), "#a8703e")
  for x = 3, W - 1, 6 do fl(c, R(c, x, 0, x, 42), "#8a5a35") end
  c:fill(R(c, 0, 43, W - 1, H - 1), "#6b3b2a")
  for y = 46, 53, 4 do fl(c, R(c, 0, y, W - 1, y), "#4a2f1e") end
  -- big stone chimney breast
  part(c, R(c, 36, 5, 66, 46), "#9a9ea6")
  for y = 9, 44, 5 do fl(c, R(c, 37, y, 65, y), "#7a8088") end
  for y = 7, 42, 5 do for x = 40 + ((y / 5) % 2) * 5, 64, 10 do fl(c, R(c, x, y, x, y + 2), "#7a8088") end end
  -- the dark flue cutaway with a hook rail and trout
  part(c, R(c, 41, 8, 61, 30), "#2a1a10")
  fl(c, R(c, 41, 10, 61, 10), "#4a3a34")
  fl(c, R(c, 42, 11, 60, 11), "#6a6a70")
  for _, x in ipairs({ 46, 51, 56 }) do
    fl(c, R(c, x, 12, x, 14), "#aeb4bc")
    part(c, c:ellipse(x, 19, 2, 5), "#d9902a", { noline = true })
    fl(c, R(c, x, 14, x, 15), "#e8a317"); c:px(x - 1, 17, "#ffd86a"); c:px(x, 24, "#b86a20"); c:px(x - 1, 25, "#b86a20"); c:px(x + 1, 25, "#b86a20")
    c:px(x - 1, 16, INK)
  end
  -- smoke wisps in the flue
  for _, p in ipairs({ { 44, 27 }, { 50, 28 }, { 55, 27 }, { 59, 28 } }) do fl(c, c:ellipse(p[1], p[2], 2, 1), "#8a8a90") end
  -- the hearth below with a low smoulder
  part(c, R(c, 41, 34, 61, 46), "#2a1a10")
  fl(c, R(c, 44, 43, 58, 44), "#6b3b2a"); fl(c, R(c, 46, 41, 56, 42), "#e0501f"); fl(c, R(c, 49, 40, 53, 40), "#f08a24")
  c:px(48, 36, "#8a8a90"); c:px(52, 35, "#8a8a90"); c:px(55, 37, "#8a8a90")
  -- gnome with pocket watch held up
  gnome(c, 20, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 10, 14 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  fl(c, R(c, 29, 28, 29, 31), "#e8a317")
  part(c, c:ellipse(29, 33, 2, 2), "#f5cf6a", { noline = true }); c:px(29, 33, "#2a1a10"); c:px(29, 32, "#2a1a10"); c:px(30, 33, "#2a1a10"); c:px(28, 32, "#fff8e0")
  -- plate and dock leaf ready
  part(c, c:ellipse(30, 45, 3, 1), "#4e8a3c", { noline = true })
  finish(c, "w4_smoke_trout")
end

-- 12. caulk_seams: the ferry hauled out on blocks; gnome packs a seam and dabs pitch, pitch pot on a small fire
function S.w4_caulk_seams()
  seed = 14
  local c = new()
  day(c, 33, { cloud = 14, hill = "#5e8a44", hill2 = "#4e8a3c" })
  fl(c, R(c, 0, 34, W - 1, H - 1), "#b8a070")
  fl(c, R(c, 0, 34, W - 1, 34), "#d0bc88")
  for _, p in ipairs({ { 8, 46 }, { 20, 49 }, { 34, 48 }, { 60, 49 }, { 66, 46 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#9a8456") end
  -- blocks and the hull
  part(c, R(c, 34, 42, 40, 47), "#8a5a35"); part(c, R(c, 58, 42, 64, 47), "#8a5a35")
  local hull = c:poly({ { 22, 16 }, { 26, 21 }, { 70, 21 }, { 70, 42 }, { 38, 43 }, { 30, 37 }, { 25, 28 } })
  part(c, hull, "#8a5a35")
  for _, y in ipairs({ 26, 31, 36, 40 }) do fl(c, R(c, 28 + floor((y - 26) * 1.2), y, 69, y), "#4a2f1e") end
  fl(c, R(c, 26, 22, 69, 22), "#b07a45"); fl(c, R(c, 23, 17, 25, 20), "#b07a45")
  fl(c, R(c, 60, 14, 61, 20), "#6b4a2e"); fl(c, R(c, 59, 13, 62, 13), "#c0442e")
  -- finished seams in glossy pitch (lower rows), fibre hanging from the open one
  for _, y in ipairs({ 36, 40 }) do fl(c, R(c, 36 + (y - 36), y, 69, y), "#1a1210") end
  for k = 0, 4 do fl(c, R(c, 44 + k * 2, 31, 44 + k * 2, 32 + (k % 2)), "#e0c88a") end
  -- a leak: drip and puddle
  fl(c, R(c, 50, 36, 50, 38), "#5aa0c0"); fl(c, R(c, 56, 40, 56, 41), "#5aa0c0")
  c:fill(c:ellipse(52, 49, 6, 1), "#5aa0c0")
  -- pitch pot over embers
  part(c, R(c, 5, 38, 13, 44), "#2a2a30"); fl(c, R(c, 4, 38, 14, 38), "#4a4a52"); fl(c, R(c, 6, 39, 12, 39), "#6a6a72")
  part(c, c:poly({ { 6, 44 }, { 12, 44 }, { 11, 48 }, { 7, 48 } }), "#e0501f"); fl(c, R(c, 8, 45, 10, 47), "#ffd86a")
  fl(c, R(c, 8, 33, 8, 36), "#8a8a90"); fl(c, R(c, 10, 30, 10, 32), "#8a8a90")
  -- gnome with a mallet and iron
  gnome(c, 22, 47, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 9, 14 }, true, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  c:fill(c:line({ { 30, 33 }, { 32, 27 } }, 2), "#b07a45")
  part(c, R(c, 31, 24, 35, 27), "#6a6c76")
  fl(c, R(c, 29, 32, 31, 34), "#f0c8a0")
  fl(c, R(c, 34, 29, 35, 29), "#e8a317")
  finish(c, "w4_caulk_seams")
end

-- 13. ferry_pup: the pup on the dock barks at a cloud; gnome holds up a biscuit
function S.w4_ferry_pup()
  seed = 24
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:fill(c:ellipse(18, 14, 11, 4), "#f4eee0"); c:fill(c:ellipse(24, 11, 6, 3), "#f4eee0"); c:fill(R(c, 8, 17, 28, 17), "#d8dede")
  c:fill(c:ellipse(60, 12, 5, 2), "#f4eee0")
  river(c, 28, 39)
  c:fill(c:ellipse(10, 30, 22, 5), "#5e8a44")
  part(c, R(c, 0, 39, W - 1, H - 1), "#b07a45", { noline = true })
  fl(c, R(c, 0, 39, W - 1, 40), "#d9a660")
  for x = 8, W - 1, 12 do fl(c, R(c, x, 41, x, H - 1), "#8a5a35") end
  for y = 46, 52, 6 do fl(c, R(c, 0, y, W - 1, y), "#8a5a35") end
  part(c, R(c, 62, 32, 64, 39), "#6b4a2e")
  -- the pup, sitting, head up, barking at the cloud
  part(c, c:rrect(30, 33, 44, 47, 4), "#c8924e")              -- body
  fl(c, R(c, 32, 40, 42, 47), "#e8c48a")                      -- chest/belly
  part(c, c:rrect(26, 24, 36, 34, 3), "#c8924e")              -- head
  part(c, c:rrect(20, 25, 27, 30, 2), "#e8c48a")              -- muzzle, open towards the cloud
  fl(c, R(c, 21, 28, 26, 29), "#8a2e2e")                      -- open mouth
  c:px(22, 25, INK); c:px(21, 25, INK)
  c:px(30, 27, INK)
  part(c, c:rrect(32, 22, 36, 30, 2), "#6b3b2a", { noline = true })   -- floppy ear
  fl(c, R(c, 28, 34, 36, 35), "#dd3a2a"); c:px(32, 36, "#f5cf6a")      -- collar and bell
  part(c, R(c, 44, 40, 49, 42), "#c8924e", { noline = true }); fl(c, R(c, 47, 38, 48, 40), "#c8924e")   -- tail up
  fl(c, R(c, 50, 38, 51, 39), "#f4eee0"); fl(c, R(c, 51, 41, 52, 41), "#f4eee0")
  part(c, R(c, 32, 46, 35, 48), "#d8a860", { noline = true })
  -- bark marks
  for _, q in ipairs({ { 16, 24, 17, 24 }, { 14, 28, 17, 28 }, { 15, 32, 17, 31 } }) do fl(c, R(c, q[1], q[2], q[3], q[4]), "#5e3f28") end
  -- gnome with a biscuit held up
  gnome(c, 58, 47, { d = -1, eyes = "happy", arms = { arm({ -4, 9 }, { -9, 13 }, true), arm({ 4, 6 }, { 6, 3 }, false) } })
  part(c, c:ellipse(48, 35, 1, 1), "#e8c48a", { noline = true })
  finish(c, "w4_ferry_pup")
end

-- 14. rope_tug: gnome and a green-hatted porter heave on opposite ends, a red rag marks the middle over the mud
function S.w4_rope_tug()
  seed = 34
  local c = new()
  day(c, 31, { cloud = 46, hill = "#5e8a44", hill2 = "#4e8a3c" })
  river(c, 31, 36)
  c:fill(R(c, 0, 37, W - 1, H - 1), "#a8885a")
  fl(c, R(c, 0, 37, W - 1, 37), "#c0a070")
  -- mud patch with glints
  c:fill(c:ellipse(36, 46, 11, 3), "#5e3f28"); c:fill(c:ellipse(36, 46, 8, 2), "#4a2f1e")
  fl(c, R(c, 31, 45, 33, 45), "#7a5a3a"); fl(c, R(c, 38, 47, 41, 47), "#7a5a3a")
  -- mooring posts at each end
  part(c, R(c, 4, 28, 6, 38), "#6b4a2e", { noline = true }); part(c, R(c, 66, 28, 68, 38), "#6b4a2e", { noline = true })
  -- rope
  for x = 18, 54 do fl(c, R(c, x, 33 + ((x == 36 or x == 35 or x == 37) and 1 or 0), x, 33 + ((x == 36 or x == 35 or x == 37) and 1 or 0)), "#e0c88a") end
  for x = 19, 53, 2 do c:px(x, 34, "#a8703e") end
  part(c, R(c, 35, 33, 37, 38), "#dd3a2a", { noline = true })
  -- the two heavers, hands on the rope
  gnome(c, 14, 47, { d = 1, eyes = "shut", arms = { arm({ 4, 9 }, { 8, 14 }, true), arm({ -3, 8 }, { 8, 13 }, false) } })
  gnome(c, 58, 47, { d = -1, s = 1.25, hat = "#4f9a45", eyes = "shut", arms = { arm({ -4, 9 }, { -9, 14 }, true), arm({ 3, 8 }, { -8, 13 }, false) } })
  -- dust kicked up behind each heel, sweat drops
  for _, p in ipairs({ { 5, 47 }, { 8, 48 }, { 67, 47 }, { 64, 49 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#d0bc88") end
  c:px(9, 28, "#a8d4e4"); c:px(62, 26, "#a8d4e4")
  finish(c, "w4_rope_tug")
end

-- 15. toll_goose: a snooty goose blocks the striped gate, nose in the air; gnome offers a crumb
function S.w4_toll_goose()
  seed = 44
  local c = new()
  day(c, 33, { cloud = 20, hill = "#5e8a44", hill2 = "#4e8a3c" })
  c:fill(R(c, 0, 34, W - 1, H - 1), "#a8885a")
  fl(c, R(c, 0, 34, W - 1, 34), "#c0a070")
  for _, p in ipairs({ { 6, 46 }, { 28, 49 }, { 64, 47 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#8a6a40") end
  -- gate post, striped bar, toll dish
  part(c, R(c, 62, 13, 67, 40), "#8a5a35")
  fl(c, R(c, 64, 15, 64, 38), "#6b3b2a")
  fl(c, R(c, 62, 13, 67, 14), "#b07a45")
  part(c, R(c, 22, 14, 25, 38), "#8a5a35"); fl(c, R(c, 22, 14, 25, 15), "#b07a45")
  local x = 26
  for k = 0, 8 do
    fl(c, R(c, x + k * 4, 17, x + k * 4 + 3, 20), (k % 2 == 0) and "#dd3a2a" or "#f4eee0")
  end
  c:outline(R(c, 26, 17, 61, 20))
  part(c, R(c, 57, 31, 61, 34), "#f5cf6a", { noline = true }); fl(c, R(c, 56, 30, 62, 30), "#8a5a35")
  -- the goose: big white body, long neck, beak high, one eye half shut
  part(c, c:ellipse(46, 41, 9, 6), "#f4eee0")
  fl(c, R(c, 42, 44, 50, 45), "#d8dede")
  part(c, c:poly({ { 38, 40 }, { 36, 33 }, { 38, 28 }, { 41, 28 }, { 41, 36 }, { 42, 40 } }), "#f4eee0", { noline = true })
  part(c, c:rrect(33, 24, 41, 30, 2), "#f4eee0")
  part(c, c:poly({ { 33, 26 }, { 28, 25 }, { 33, 29 } }), "#e8841a", { noline = true })
  fl(c, R(c, 36, 26, 38, 26), INK); fl(c, R(c, 36, 25, 38, 25), "#f4eee0")
  fl(c, R(c, 54, 38, 58, 40), "#d8dede")
  fl(c, R(c, 43, 47, 43, 49), "#e8841a"); fl(c, R(c, 49, 47, 49, 49), "#e8841a"); fl(c, R(c, 42, 49, 44, 49), "#e8841a"); fl(c, R(c, 48, 49, 50, 49), "#e8841a")
  -- gnome offering a crumb, brave
  gnome(c, 14, 47, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 11, 11 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  c:fill(R(c, 26, 36, 27, 37), "#e8c48a"); c:px(28, 35, "#e8c48a")
  finish(c, "w4_toll_goose")
end

local order = { "w4_cider_barrel", "w4_top_apple", "w4_oldest_tree", "w4_cider_shed_tales", "w4_cow_aboard", "w4_fog_reading", "w4_mooring_line", "w4_trim_cargo", "w4_toll_count", "w4_mussel_broth", "w4_smoke_trout", "w4_caulk_seams", "w4_ferry_pup", "w4_rope_tug", "w4_toll_goose" }
for _, s2 in ipairs(order) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
