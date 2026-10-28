-- variety-act-h8.lua : Do-tab scenes for 11 rest-stop activities -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- snow_soak egg_boil firewood campfire_story kettle frost_fair bench_rest trader_stall lantern_post wishing_well long_table
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-h8.lua   (params BEFORE --script)
-- Frame (5 grid px wooden frame) is copied from the shipped act-hand.png; interior is x 5..68, y 5..49.
local ROOT = "/home/user/gnome-venture/"
local GV = dofile(ROOT .. "aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or (ROOT .. "game/assets/img/acts/")
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
    c:px(x, y, opt.tuft or "#5e8a44"); c:px(x + 1, y - 1, opt.tuft or "#5e8a44")
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
---------------------------------------------------------------- h8 helpers
local S = {}
local function tree(c, x, yb, r, leaf, trunk, tw)
  tw = tw or 1
  part(c, R(c, x - tw, yb - r - 2, x + tw, yb), trunk or "#6b4a2e", { noline = true })
  part(c, c:ellipse(x, yb - r - 4, r, r - 1), leaf, { shade = true })
end
local function sea(c, y0, y1, a, b)
  c:bands(R(c, 0, y0, W - 1, y1), { a or "#4f9ac0", b or "#3f86b0", "#3a7aa6" }, { dir = "v" })
  for x = 3, 68, 9 do c:px(x, y0 + 3 + (x % 4), "#cfe8f0"); c:px(x + 1, y0 + 3 + (x % 4), "#cfe8f0") end
end
local function note(c, x, y, col)
  c:paint({ "..ggg", "..g.g", "..g..", "gg.g.", "ggg.." }, x, y, { g = col or "#f4eee0" })
end
local function drop(c, x, y, col) c:px(x, y, col); c:px(x, y + 1, col) end
local function wasp(c, x, y)
  c:px(x, y, "#f5cf6a"); c:px(x + 1, y, INK); c:px(x + 2, y, "#f5cf6a"); c:px(x + 1, y - 1, "#f4f8fa"); c:px(x + 2, y - 1, "#f4f8fa")
end
local function goat(c, x, y, d, col)
  col = col or "#f4eee0"
  part(c, R(c, x - 7, y - 9, x + 5, y - 3), col)
  for _, lx in ipairs({ x - 6, x - 4, x + 3, x + 5 }) do part(c, R(c, lx, y - 3, lx, y), "#8a7a68", { noline = true }) end
  local hx = x + d * 7
  part(c, R(c, hx - 2, y - 14, hx + 2, y - 8), col)
  part(c, R(c, hx + d * 2 - 1, y - 10, hx + d * 4, y - 8), "#d8d0c0")
  c:px(hx + d * 1, y - 12, INK); c:px(hx + d * 4, y - 9, INK)
  c:px(hx - d * 1, y - 15, "#8a7a68"); c:px(hx - d * 2, y - 16, "#8a7a68"); c:px(hx, y - 15, "#8a7a68")
  c:px(hx + d * 1, y - 7, "#c8c0b0"); c:px(hx + d * 1, y - 6, "#c8c0b0")
  fl(c, R(c, hx - 1, y - 8, hx, y - 7), "#e8a317")
  c:px(x - d * 7, y - 9, col); c:px(x - d * 8, y - 10, col)
end
local function lemon(c, x, y) c:fill(c:ellipse(x, y, 1, 1), "#f5cf6a"); c:px(x, y - 1, "#fff1a0") end
local function cloudy(c) end
local function husk(c, x, y, open)
  part(c, c:ellipse(x, y, 3, 3), "#6a8a34")
  for _, p in ipairs({ { -3, -1 }, { 3, -1 }, { 0, -3 }, { -2, 3 }, { 2, 3 }, { -3, 2 }, { 3, 2 }, { 0, 4 } }) do c:px(x + p[1], y + p[2], "#a8c04a") end
  if open then c:fill(c:ellipse(x, y, 2, 2), "#e8dca0"); c:fill(c:ellipse(x, y, 1, 1), "#7a3a1a"); c:px(x - 1, y - 1, "#c07a4a") end
end
local function nut(c, x, y) part(c, c:ellipse(x, y, 1, 1), "#8a4a22"); c:px(x, y - 1, "#c07a4a") end
local AUT = { sky = { "#e8d4a0", "#f0dcb0", "#f4e4c4" }, hill = "#a08a3a", hill2 = "#8a7430", grass = "#b8a058", edge = "#d0b870", tuft = "#8a7430" }

-- 1. chestnuts
function S.r_se_prickly_chestnuts()
  seed = 4
  local c = new()
  day(c, 33, { sky = AUT.sky, hill = AUT.hill, hill2 = AUT.hill2, grass = AUT.grass, edge = AUT.edge, tuft = AUT.tuft, cloud = 50 })
  tree(c, 10, 36, 8, "#c8741e", "#5e3f28", 1); tree(c, 63, 34, 7, "#d89a2a", "#5e3f28", 1)
  for _, p in ipairs({ { 8, 24 }, { 14, 20 }, { 61, 22 }, { 66, 26 } }) do c:px(p[1], p[2], "#8a3a14") end
  -- pile of husks at right
  husk(c, 55, 46, false); husk(c, 61, 45, true); husk(c, 58, 41, false); husk(c, 65, 41, true)
  nut(c, 52, 48); nut(c, 63, 48)
  -- sack of nuts at left
  part(c, c:poly({ { 7, 38 }, { 17, 38 }, { 19, 48 }, { 5, 48 } }), "#c9a96e", { shade = true })
  fl(c, R(c, 6, 37, 18, 38), "#8a5a35")
  for _, p in ipairs({ { 8, 36 }, { 11, 35 }, { 14, 36 }, { 16, 37 } }) do nut(c, p[1], p[2]) end
  nut(c, 20, 48); nut(c, 22, 47)
  -- gnome stepping on a husk, nut popping out
  husk(c, 40, 46, true)
  gnome(c, 31, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 7 }, { -7, 4 }, false), arm({ 4, 8 }, { 8, 14 }, true) } })
  nut(c, 43, 41); c:px(46, 38, "#f5cf6a"); c:px(42, 37, "#f5cf6a")
  nut(c, 38, 17); nut(c, 29, 14)
  finish(c, "r_se_prickly_chestnuts")
end

-- 2. frost braziers
local function brazier(c, x, y)
  part(c, c:poly({ { x - 4, y - 5 }, { x + 4, y - 5 }, { x + 2, y - 1 }, { x - 2, y - 1 } }), "#3d3a40")
  fl(c, R(c, x - 3, y - 1, x - 3, y + 2), "#3d3a40"); fl(c, R(c, x + 3, y - 1, x + 3, y + 2), "#3d3a40")
  c:fill(c:poly({ { x - 3, y - 5 }, { x, y - 11 }, { x + 3, y - 5 } }), "#e0501f")
  c:fill(c:poly({ { x - 2, y - 5 }, { x, y - 8 }, { x + 2, y - 5 } }), "#ffd86a")
end
function S.r_se_frost_braziers()
  seed = 8
  local c = new()
  day(c, 30, { sky = { "#a8c0dc", "#bcd0e4", "#d4e2ee" }, hill = "#8aaa98", hill2 = "#7c9c8c", grass = "#d0dfe0", edge = "#eef5f6", tuft = "#a8c0b8", cloud = false })
  c:fill(c:ellipse(60, 12, 3, 3), "#f5e6a8")
  for _, p in ipairs({ { 12, 34 }, { 33, 32 }, { 54, 34 }, { 68, 31 } }) do
    tree(c, p[1], p[2], 7, "#3f7a46", "#5e3f28", 1)
    c:fill(c:ellipse(p[1], p[2] - 12, 4, 1), "#dcecee")
    for _, q in ipairs({ { -4, -9 }, { 3, -8 }, { 0, -6 }, { -3, -4 }, { 4, -5 } }) do lemon(c, p[1] + q[1], p[2] + q[2]) end
  end
  brazier(c, 22, 44); brazier(c, 47, 45)
  for _, p in ipairs({ { 7, 41 }, { 30, 43 }, { 62, 42 }, { 40, 40 }, { 15, 47 }, { 56, 48 } }) do c:px(p[1], p[2], "#fbfdfe"); c:px(p[1] + 1, p[2], "#c8dce4") end
  gnome(c, 34, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 3 }, false), arm({ 4, 8 }, { 9, 11 }, true, true) } })
  c:fill(c:line({ { 43, 36 }, { 48, 33 } }, 1), "#6b3b2a")
  fl(c, R(c, 43, 35, 44, 36), "#f0c8a0")
  c:fill(c:poly({ { 48, 32 }, { 47, 29 }, { 49, 31 }, { 50, 28 }, { 51, 32 } }), "#f08a24"); c:px(49, 31, "#ffd86a")
  c:px(36, 24, "#fbfdfe"); c:px(38, 22, "#fbfdfe"); c:px(40, 24, "#dcecf0")
  finish(c, "r_se_frost_braziers")
end

-- 3. fig guard
function S.r_se_fig_guard()
  seed = 12
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#78bcd8", "#8cc8de", "#a8d8e4", "#c4e4e8" }, { dir = "v" })
  for i = 0, 7 do local a = i * 0.785; c:px(rnd(58 + math.cos(a) * 7), rnd(10 + math.sin(a) * 6), "#fff0a0") end
  c:fill(c:ellipse(58, 10, 4, 4), "#fff4b8")
  c:fill(R(c, 0, 20, W - 1, 28), "#e8e2d4")                 -- whitewashed parapet wall beyond
  fl(c, R(c, 0, 20, W - 1, 20), "#fbf8ee")
  fl(c, R(c, 0, 29, W - 1, 29), "#c8c0ae")
  c:fill(R(c, 0, 30, W - 1, H - 1), "#e2d8c0")                 -- flat roof
  for x = 4, 68, 9 do c:fill(R(c, x, 33 + (x % 3) * 6, x + 2, 33 + (x % 3) * 6), "#c8bca0") end
  -- reed mat with split figs
  part(c, c:poly({ { 26, 36 }, { 62, 36 }, { 66, 47 }, { 22, 47 } }), "#d9bc7a")
  for x = 24, 64, 4 do fl(c, R(c, x + (x < 44 and 0 or 1), 37, x + 1 + (x - 44) // 10, 47), "#c8a864") end
  seed = 3
  for _, p in ipairs({ { 30, 39 }, { 37, 40 }, { 45, 39 }, { 53, 40 }, { 58, 38 }, { 28, 44 }, { 35, 45 }, { 43, 44 }, { 50, 45 }, { 58, 44 } }) do
    part(c, c:ellipse(p[1], p[2], 2, 1), "#6a3a6a"); c:px(p[1], p[2], "#e47a8a")
  end
  -- goat leaning in from the right, mouth near a fig
  goat(c, 60, 34, -1)
  -- wasps
  wasp(c, 40, 32); wasp(c, 48, 28); wasp(c, 33, 34); wasp(c, 52, 33)
  -- gnome with a broom-shoo
  gnome(c, 12, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 14 }, true), arm({ -4, 7 }, { -5, 4 }, false) } })
  c:fill(c:line({ { 20, 33 }, { 25, 21 } }, 1), "#8a5a35")
  local bm = c:poly({ { 25, 21 }, { 22, 14 }, { 30, 14 } })
  part(c, bm, "#d9bc4a")
  fl(c, R(c, 26, 15, 26, 18), "#a88a2a"); fl(c, R(c, 24, 15, 24, 17), "#a88a2a"); fl(c, R(c, 25, 21, 25, 22), "#6b3b2a")
  c:px(33, 20, "#f4f8fa"); c:px(34, 22, "#f4f8fa"); c:px(32, 18, "#f4f8fa")
  finish(c, "r_se_fig_guard")
end

-- 4. hill cheese
function S.r_se_hill_cheese()
  seed = 6
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 42), "#cdb88a")
  for y = 12, 40, 7 do for x = (y // 7 % 2) * 4, 70, 8 do fl(c, R(c, x, y, x + 6, y), "#b8a074") end end
  c:fill(R(c, 0, 43, W - 1, H - 1), "#8a5a35")
  for y = 46, 52, 3 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  part(c, R(c, 0, 5, W - 1, 10), "#6b3b2a"); fl(c, R(c, 0, 5, W - 1, 5), "#8a5a35")
  -- window with hills and a belled goat
  part(c, R(c, 52, 15, 66, 31), "#8a5a35")
  c:bands(R(c, 54, 17, 64, 29), { "#a8d4e0", "#cfe8e6" }, { dir = "v" })
  c:fill(c:ellipse(59, 31, 9, 6):clip(R(c, 54, 17, 64, 29)), "#6a9a4a")
  fl(c, R(c, 59, 17, 59, 29), "#8a5a35")
  fl(c, R(c, 56, 24, 57, 26), "#f4eee0"); fl(c, R(c, 61, 24, 62, 27), "#f4eee0"); c:px(63, 23, "#f4eee0"); c:px(62, 28, "#e8a317")
  -- hanging cheese bag
  fl(c, R(c, 31, 11, 31, 17), "#d9bc84")
  part(c, c:poly({ { 28, 17 }, { 34, 17 }, { 36, 23 }, { 34, 28 }, { 28, 28 }, { 26, 23 } }), "#e8dcc0", { shade = true })
  fl(c, R(c, 29, 16, 33, 17), "#8a5a35")
  fl(c, R(c, 29, 21, 29, 25), "#d8d0bc")
  drop(c, 31, 30, "#fbfaf2"); drop(c, 31, 34, "#fbfaf2"); c:px(32, 30, "#fbfaf2"); c:px(32, 34, "#fbfaf2")
  -- table, bowl, salt pot
  part(c, R(c, 22, 40, 42, 42), "#b07a45"); fl(c, R(c, 22, 40, 42, 40), "#d9a660")
  part(c, R(c, 24, 42, 25, 47), "#8a5a35", { noline = true }); part(c, R(c, 39, 42, 40, 47), "#8a5a35", { noline = true })
  part(c, c:ellipse(31, 39, 4, 2), "#c4623a"); c:fill(c:ellipse(31, 38, 3, 1), "#fbfaf2")
  part(c, R(c, 37, 37, 40, 40), "#aeb4bc"); c:px(38, 35, "#f4f8fa"); c:px(39, 36, "#f4f8fa")
  -- copper pot with goat milk on floor
  part(c, R(c, 46, 41, 51, 47), "#b8662a"); fl(c, R(c, 47, 41, 50, 41), "#f4eee0")
  gnome(c, 14, 47, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 10, 19 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  fl(c, R(c, 23, 27, 24, 29), "#8a5a35")
  finish(c, "r_se_hill_cheese")
end

-- 5. sardine grill
function S.r_se_sardine_grill()
  seed = 16
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 20), { "#a8d4e0", "#bcdde4", "#d4eaea" }, { dir = "v" })
  c:fill(c:ellipse(14, 9, 7, 2), "#f4eee0")
  -- harbour houses
  for i, hx in ipairs({ 5, 13, 21, 55, 63 }) do
    local hh = 6 + (i % 2) * 3
    part(c, R(c, hx, 20 - hh, hx + 6, 20), "#f4eee0")
    c:fill(c:poly({ { hx - 1, 20 - hh }, { hx + 7, 20 - hh }, { hx + 3, 20 - hh - 3 } }), "#c4623a")
    fl(c, R(c, hx + 2, 18 - hh + 5, hx + 3, 19), "#3f6fb0")
  end
  sea(c, 21, 34)
  -- boat with sail
  part(c, c:poly({ { 36, 29 }, { 50, 29 }, { 47, 32 }, { 39, 32 } }), "#8a5a35")
  fl(c, R(c, 43, 18, 43, 29), "#5e3f28"); c:fill(c:poly({ { 44, 19 }, { 44, 28 }, { 50, 28 } }), "#f4eee0"); c:fill(c:poly({ { 42, 21 }, { 42, 28 }, { 37, 28 } }), "#e8d2a0")
  -- quay
  c:fill(R(c, 0, 35, W - 1, H - 1), "#aaa69c"); fl(c, R(c, 0, 35, W - 1, 36), "#c8c4b8")
  for x = 2, 68, 8 do fl(c, R(c, x, 40, x + 5, 40), "#8a867c"); fl(c, R(c, x + 3, 45, x + 8, 45), "#8a867c") end
  -- cart-wheel grill
  for _, x in ipairs({ 40, 52 }) do part(c, R(c, x, 40, x + 1, 47), "#3d3a40", { noline = true }) end
  c:fill(c:ellipse(46, 45, 7, 1), "#e0501f"); c:px(43, 45, "#ffd86a"); c:px(48, 45, "#ffd86a")
  part(c, c:ellipse(46, 40, 11, 4), "#4a4a52")
  c:fill(c:ellipse(46, 40, 9, 3), "#6a6a74")
  for i = 0, 5 do local a = i * 1.047; c:fill(c:line({ { 46, 40 }, { rnd(46 + math.cos(a) * 9), rnd(40 + math.sin(a) * 3) } }, 1), "#3d3a40") end
  c:fill(c:ellipse(46, 40, 1, 1), "#3d3a40")
  for _, p in ipairs({ { 41, 40 }, { 47, 38 }, { 51, 41 } }) do
    part(c, c:ellipse(p[1], p[2], 3, 1), "#c8d4dc"); c:px(p[1] + 3, p[2] - 1, "#c8d4dc"); c:px(p[1] + 4, p[2] - 1, "#c8d4dc"); c:px(p[1] - 1, p[2], INK); c:px(p[1], p[2] - 1, "#8aa4b8")
  end
  for i, y in ipairs({ 33, 29, 25 }) do fl(c, R(c, 47 + (i % 2) * 2, y, 48 + (i % 2) * 2, y + 2), "#d8e0e4") end
  gnome(c, 24, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 15 }, true, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local lx, ly = 33, 32
  part(c, c:ellipse(lx, ly, 3, 2), "#f5cf6a"); c:fill(c:ellipse(lx, ly, 1, 1), "#fff4b0")
  fl(c, R(c, lx - 2, ly + 2, lx - 1, ly + 3), "#f0c8a0")
  c:px(lx + 1, ly + 3, "#f5cf6a"); c:px(lx + 3, ly + 5, "#f5cf6a")
  -- bucket of sardines
  part(c, R(c, 60, 41, 66, 47), "#8a5a35"); fl(c, R(c, 60, 43, 66, 43), "#5e3f28"); fl(c, R(c, 61, 40, 65, 40), "#c8d4dc"); c:px(63, 39, "#c8d4dc")
  finish(c, "r_se_sardine_grill")
end

-- 6. fig tart
function S.r_se_fig_tart()
  seed = 22
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#e6d6aa")
  fl(c, R(c, 0, 26, W - 1, 38), "#d8c692")
  for x = 2, 70, 6 do fl(c, R(c, x, 27, x, 38), "#c8b47c") end
  fl(c, R(c, 0, 26, W - 1, 26), "#b8a068")
  c:fill(R(c, 0, 39, W - 1, H - 1), "#b8643a")
  for y = 42, 52, 5 do fl(c, R(c, 0, y, W - 1, y), "#8a4a2a") end
  for x = 4, 70, 9 do fl(c, R(c, x, 39, x, H - 1), "#a05630") end
  -- shelf with jars + hanging pans
  part(c, R(c, 6, 14, 28, 15), "#8a5a35")
  part(c, R(c, 8, 8, 12, 13), "#c4623a"); part(c, R(c, 15, 9, 18, 13), "#3f8fb0"); part(c, R(c, 21, 7, 26, 13), "#e8a317")
  for _, x in ipairs({ 36, 42 }) do fl(c, R(c, x, 5, x, 10), "#5e3f28"); part(c, c:ellipse(x, 13, 3, 3), "#8b929c"); end
  -- clay oven at right with fire
  part(c, c:ellipse(60, 40, 14, 14):clip(R(c, 40, 24, 70, 44)), "#c4623a", { shade = true })
  part(c, R(c, 46, 38, 74, 46), "#a8502a")
  for _, p in ipairs({ { 50, 30 }, { 58, 27 }, { 66, 30 }, { 52, 36 }, { 64, 36 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#8a4a2a") end
  part(c, c:rrect(53, 33, 67, 44, 3), "#2a1a10")
  c:fill(c:poly({ { 54, 44 }, { 57, 37 }, { 60, 41 }, { 63, 36 }, { 66, 44 } }), "#e0501f")
  c:fill(c:poly({ { 56, 44 }, { 60, 40 }, { 64, 44 } }), "#ffd86a")
  -- gnome sliding the peel out
  gnome(c, 15, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 8 }, true), arm({ -4, 7 }, { 3, 6 }, false, true) } })
  fl(c, R(c, 23, 36, 40, 36), "#b07a45"); c:fill(R(c, 23, 37, 40, 37), "#8a5a35")
  part(c, c:ellipse(41, 35, 8, 3), "#d9a660")
  c:fill(c:ellipse(41, 35, 6, 2), "#f4eee0")
  for _, p in ipairs({ { 38, 34 }, { 42, 33 }, { 45, 35 }, { 39, 36 }, { 43, 36 } }) do c:fill(c:ellipse(p[1], p[2], 1, 1), "#6a3a6a"); c:px(p[1], p[2], "#e47a8a") end
  c:px(40, 29, "#f4f8fa"); c:px(43, 27, "#f4f8fa"); c:px(41, 31, "#f4f8fa")
  finish(c, "r_se_fig_tart")
end

-- 7. cork planter
function S.r_se_cork_planter()
  seed = 28
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 42), "#b8a078")
  for x = 3, 70, 7 do fl(c, R(c, x, 0, x, 42), "#a08a62") end
  c:fill(R(c, 0, 43, W - 1, H - 1), "#7a5a3a"); fl(c, R(c, 0, 43, W - 1, 43), "#5e3f28")
  part(c, R(c, 0, 5, W - 1, 8), "#6b3b2a")
  -- finished planter hanging from the beam
  fl(c, R(c, 17, 9, 17, 17), "#e8d2a0"); fl(c, R(c, 29, 9, 29, 17), "#e8d2a0")
  part(c, R(c, 13, 18, 33, 29), "#b8743a", { shade = true })
  for _, p in ipairs({ { 16, 21 }, { 22, 24 }, { 28, 20 }, { 19, 27 }, { 30, 26 }, { 24, 19 } }) do c:px(p[1], p[2], "#6b3b2a"); c:px(p[1] + 1, p[2], "#6b3b2a") end
  for y = 19, 27, 4 do fl(c, R(c, 13, y, 33, y), "#d8a060"); fl(c, R(c, 13, y + 1, 33, y + 1), "#9a5a2a") end
  for _, p in ipairs({ { 17, 12 }, { 21, 9 }, { 25, 11 }, { 29, 13 }, { 19, 16 }, { 27, 15 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#4e9a48") end
  fl(c, R(c, 14, 30, 14, 36), "#4e9a48"); fl(c, R(c, 15, 36, 15, 39), "#4e9a48"); fl(c, R(c, 31, 30, 31, 34), "#4e9a48")
  -- bark slabs leaning on the wall
  part(c, c:poly({ { 60, 16 }, { 67, 16 }, { 67, 43 }, { 62, 43 } }), "#c8803a")
  part(c, c:poly({ { 54, 22 }, { 60, 22 }, { 62, 43 }, { 56, 43 } }), "#b8743a")
  for _, p in ipairs({ { 62, 20 }, { 64, 28 }, { 63, 36 }, { 57, 28 }, { 58, 36 } }) do c:px(p[1], p[2], "#6b3b2a"); c:px(p[1] + 1, p[2] + 1, "#6b3b2a") end
  -- bench with a half-laced bark tube
  part(c, R(c, 28, 41, 52, 43), "#b07a45"); fl(c, R(c, 28, 41, 52, 41), "#d9a660")
  part(c, R(c, 30, 43, 31, 48), "#8a5a35", { noline = true }); part(c, R(c, 49, 43, 50, 48), "#8a5a35", { noline = true })
  part(c, R(c, 36, 33, 46, 41), "#b8743a", { shade = true })
  fl(c, R(c, 36, 33, 36, 41), "#6b3b2a"); fl(c, R(c, 41, 34, 41, 34), "#6b3b2a"); fl(c, R(c, 43, 38, 44, 38), "#6b3b2a")
  for y = 34, 40, 2 do fl(c, R(c, 39, y, 41, y + (y % 4 == 0 and 1 or 0)), "#f4eee0") end
  part(c, c:ellipse(37, 33, 1, 2), "#e8c48a")
  part(c, c:ellipse(48, 40, 2, 2), "#e8d2a0"); c:fill(c:ellipse(48, 40, 1, 1), "#a8703e")
  gnome(c, 22, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 10, 8 }, true), arm({ -4, 7 }, { 0, 6 }, false, true) } })
  finish(c, "r_se_cork_planter")
end

-- 8. cinder grit
function S.r_se_cinder_grit()
  seed = 32
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#9ac0d4", "#b4d0dc", "#cde0e4" }, { dir = "v" })
  part(c, c:poly({ { 20, 36 }, { 36, 10 }, { 40, 10 }, { 58, 36 } }), "#4a4448")
  c:fill(c:poly({ { 36, 10 }, { 40, 10 }, { 38, 14 } }), "#e0501f"); c:px(38, 11, "#ffd86a")
  fl(c, R(c, 28, 24, 29, 31), "#5e5458"); fl(c, R(c, 49, 24, 50, 33), "#5e5458")
  for i, p in ipairs({ { 42, 7 }, { 46, 4 }, { 51, 6 }, { 56, 3 } }) do c:fill(c:ellipse(p[1], p[2], 3 - (i % 2), 1), "#c8c4c4") end
  c:fill(R(c, 0, 35, W - 1, H - 1), "#5a5258"); fl(c, R(c, 0, 35, W - 1, 35), "#6e666a")
  for _, p in ipairs({ { 6, 42 }, { 14, 46 }, { 56, 44 }, { 64, 47 }, { 44, 48 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#3a3438") end
  -- vine row at left
  for x = 4, 18, 5 do part(c, R(c, x, 28, x, 36), "#5e3f28", { noline = true }); c:fill(c:ellipse(x, 28, 3, 3), "#5e9a48"); c:px(x - 1, 29, "#6a3a6a"); c:px(x + 1, 30, "#6a3a6a") end
  fl(c, R(c, 2, 31, 21, 31), "#8a5a35")
  -- sacks right
  part(c, c:poly({ { 56, 37 }, { 65, 37 }, { 67, 47 }, { 54, 47 } }), "#c9a96e", { shade = true })
  fl(c, R(c, 56, 36, 65, 37), "#8a5a35"); fl(c, R(c, 57, 36, 64, 36), "#2a2428")
  part(c, c:ellipse(66, 44, 3, 2), "#b8b0a8")
  -- heap of fine dark grit under the sieve
  c:fill(c:poly({ { 31, 47 }, { 39, 40 }, { 47, 47 } }), "#2a2428"); c:fill(c:poly({ { 34, 47 }, { 39, 43 }, { 44, 47 } }), "#3a3438")
  gnome(c, 24, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 11 }, true, true), arm({ -4, 7 }, { 2, 9 }, false, true) } })
  for _, x in ipairs({ 36, 38, 40, 42 }) do c:px(x, 38 + (x % 3), "#2a2428") end
  fl(c, R(c, 38, 38, 38, 40), "#2a2428"); fl(c, R(c, 41, 39, 41, 41), "#2a2428")
  part(c, c:ellipse(37, 36, 7, 3), "#8a5a35")
  c:fill(c:ellipse(37, 36, 5, 2), "#5a5258")
  for x = 34, 40, 2 do c:px(x, 36, "#2a2428") end
  fl(c, R(c, 31, 37, 32, 38), "#f0c8a0"); fl(c, R(c, 43, 36, 44, 37), "#f0c8a0")
  finish(c, "r_se_cinder_grit")
end
local function olive(c, x, yb)
  part(c, c:poly({ { x - 4, yb }, { x - 2, yb - 8 }, { x - 5, yb - 14 }, { x - 2, yb - 14 }, { x, yb - 10 }, { x + 3, yb - 15 }, { x + 5, yb - 14 }, { x + 2, yb - 8 }, { x + 4, yb } }), "#7a6a58")
  fl(c, R(c, x - 1, yb - 7, x - 1, yb - 2), "#5e5040")
  part(c, c:ellipse(x - 8, yb - 17, 8, 5), "#8fa878", { shade = true })
  part(c, c:ellipse(x + 8, yb - 18, 8, 5), "#a0b888", { shade = true })
  part(c, c:ellipse(x, yb - 22, 10, 5), "#7a9468", { shade = true })
  for _, p in ipairs({ { -9, -19 }, { 6, -20 }, { -2, -24 }, { 10, -17 }, { -13, -16 } }) do c:px(x + p[1], yb + p[2], "#c8d8b0"); c:px(x + p[1] + 1, yb + p[2], "#c8d8b0") end
end

-- 9. caprifig strings
function S.r_se_caprifig_strings()
  seed = 9
  local c = new()
  day(c, 36, { cloud = 14, hill = "#6a9a48", hill2 = "#5a8a3c", grass = "#8ab060", edge = "#a8cc78" })
  part(c, R(c, 50, 20, 55, 40), "#8a7a68", { noline = true }); fl(c, R(c, 52, 24, 52, 38), "#6a5a48")
  part(c, c:ellipse(50, 14, 19, 10), "#4e9a48", { shade = true })
  for _, p in ipairs({ { 40, 10 }, { 52, 8 }, { 60, 13 }, { 46, 16 }, { 56, 17 } }) do c:fill(c:ellipse(p[1], p[2], 3, 1), "#6ab35a") end
  for _, sx in ipairs({ 42, 49, 58, 63 }) do
    fl(c, R(c, sx, 20, sx, 30), "#d9bc84")
    for y = 22, 29, 3 do c:fill(c:ellipse(sx, y, 1, 1), "#6a3a6a"); c:px(sx, y, "#c06a8a") end
  end
  wasp(c, 38, 18); wasp(c, 63, 24); wasp(c, 47, 32)
  -- basket of figs and a rush spool
  part(c, R(c, 60, 41, 67, 47), "#c9a96e"); fl(c, R(c, 60, 43, 67, 43), "#a8803a"); fl(c, R(c, 60, 45, 67, 45), "#a8803a")
  for _, x in ipairs({ 61, 64, 66 }) do part(c, c:ellipse(x, 40, 2, 2), "#6a3a6a"); c:px(x, 39, "#c06a8a") end
  part(c, c:ellipse(12, 46, 3, 2), "#d9bc84"); c:fill(c:ellipse(12, 46, 1, 1), "#a8803a")
  gnome(c, 27, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 19 }, true), arm({ -4, 7 }, { -5, 4 }, false) } })
  -- the string being draped over a branch
  c:fill(c:line({ { 38, 28 }, { 41, 21 }, { 43, 21 } }, 1), "#d9bc84")
  for _, p in ipairs({ { 38, 29 }, { 39, 26 }, { 40, 23 } }) do c:fill(c:ellipse(p[1], p[2], 1, 1), "#6a3a6a"); c:px(p[1], p[2], "#c06a8a") end
  finish(c, "r_se_caprifig_strings")
end

-- 10. whitewash the harbour light
function S.r_se_whitewash_light()
  seed = 10
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 22), { "#98cce0", "#acd8e6", "#c4e4ea" }, { dir = "v" })
  c:fill(c:ellipse(12, 9, 7, 2), "#f4eee0")
  sea(c, 23, 37)
  c:fill(R(c, 0, 38, W - 1, H - 1), "#7ea85a"); fl(c, R(c, 0, 38, W - 1, 38), "#9cc070")
  -- blossom tree left
  part(c, R(c, 8, 26, 10, 42), "#6b4a2e", { noline = true })
  part(c, c:ellipse(9, 22, 9, 7), "#f0a8c0", { shade = true })
  for _, p in ipairs({ { 5, 20 }, { 12, 19 }, { 9, 24 }, { 14, 23 }, { 4, 25 } }) do c:px(p[1], p[2], "#fbd8e4") end
  for _, p in ipairs({ { 18, 44 }, { 4, 46 }, { 24, 48 }, { 14, 48 } }) do c:px(p[1], p[2], "#f4eee0"); c:px(p[1], p[2] - 1, "#f0a8c0") end
  -- lighthouse
  part(c, R(c, 40, 46, 62, 48), "#8a867c")
  part(c, c:poly({ { 43, 46 }, { 47, 15 }, { 56, 15 }, { 60, 46 } }), "#9a968c")
  c:fill(c:poly({ { 46, 32 }, { 47, 15 }, { 56, 15 }, { 57, 32 } }), "#fbf8ee")
  c:fill(R(c, 47, 15, 49, 32), "#f4eee0")
  fl(c, R(c, 46, 33, 57, 33), "#d8d4c8"); fl(c, R(c, 45, 34, 58, 34), "#fbf8ee"); c:px(48, 35, "#fbf8ee"); c:px(54, 35, "#fbf8ee"); c:px(51, 36, "#fbf8ee")
  for y = 38, 46, 4 do fl(c, R(c, 44 + (y - 38) // 4, y, 59 - (y - 38) // 4, y), "#807c72") end
  part(c, R(c, 45, 13, 58, 15), "#3d3a40")
  part(c, R(c, 48, 6, 55, 12), "#ffd86a", { shade = true, cres = 1 }); fl(c, R(c, 50, 8, 53, 10), "#fff1c8")
  part(c, c:poly({ { 51, 2 }, { 57, 6 }, { 46, 6 } }), "#c0442e")
  fl(c, R(c, 51, 21, 52, 24), "#3f6fb0")
  -- gnome with a long brush, bucket
  part(c, R(c, 15, 43, 21, 48), "#8a5a35"); fl(c, R(c, 16, 43, 20, 43), "#fbf8ee"); fl(c, R(c, 15, 45, 21, 45), "#5e3f28")
  gnome(c, 31, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 13 }, true, true), arm({ -4, 7 }, { 3, 10 }, false, true) } })
  c:fill(c:line({ { 34, 42 }, { 44, 28 } }, 1), "#8a5a35")
  part(c, R(c, 43, 24, 47, 30), "#fbf8ee"); fl(c, R(c, 44, 23, 46, 24), "#c9a96e")
  fl(c, R(c, 36, 36, 37, 37), "#f0c8a0")
  for _, p in ipairs({ { 38, 12 }, { 30, 16 } }) do c:px(p[0 + 1], p[2], "#f4eee0"); c:px(p[1] + 1, p[2] - 1, "#f4eee0"); c:px(p[1] + 2, p[2], "#f4eee0") end
  c:px(30, 38, "#fbf8ee"); c:px(33, 40, "#fbf8ee")
  finish(c, "r_se_whitewash_light")
end

-- 11. olive nets
function S.r_se_olive_nets()
  seed = 11
  local c = new()
  day(c, 31, { sky = AUT.sky, hill = AUT.hill, hill2 = AUT.hill2, grass = "#c8b068", edge = "#e0c880", tuft = "#a89048", cloud = 54 })
  olive(c, 24, 42)
  -- the net spread on the ground
  local net = c:ellipse(30, 44, 22, 4)
  part(c, net, "#d8c898")
  for x = 12, 48, 4 do c:fill(c:line({ { x, 41 }, { x + 2, 47 } }, 1):clip(net), "#a89868") end
  for y = 42, 46, 2 do c:fill(R(c, 8, y, 52, y):clip(net), "#a89868") end
  for _, p in ipairs({ { 22, 45 }, { 28, 44 }, { 34, 46 }, { 40, 44 }, { 18, 44 }, { 46, 45 }, { 31, 46 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#4a3a5a"); c:px(p[1], p[2], "#6a5a7a") end
  for _, p in ipairs({ { 18, 46 }, { 26, 47 }, { 38, 46 }, { 44, 44 } }) do c:px(p[1], p[2], "#5a7a34"); c:px(p[1] + 1, p[2], "#5a7a34") end
  -- falling olives
  for _, p in ipairs({ { 36, 22 }, { 33, 28 }, { 40, 34 }, { 28, 33 }, { 37, 38 }, { 42, 27 } }) do c:px(p[1], p[2], "#4a5a2a"); c:px(p[1], p[2] + 1, "#4a5a2a") end
  -- a second tree edge at right and gnome combing
  part(c, R(c, 66, 28, 67, 40), "#7a6a58", { noline = true }); part(c, c:ellipse(66, 24, 6, 6), "#8fa878", { shade = true })
  gnome(c, 56, 47, { d = -1, walk = -1, eyes = "open", arms = { arm({ -4, 8 }, { -8, 15 }, true), arm({ 4, 7 }, { 0, 12 }, false, true) } })
  c:fill(c:line({ { 48, 32 }, { 38, 20 } }, 1), "#8a5a35")
  part(c, R(c, 33, 18, 39, 19), "#8a5a35"); for x = 33, 39, 2 do fl(c, R(c, x, 20, x, 22), "#5e3f28") end
  finish(c, "r_se_olive_nets")
end

-- 12. lemon channel
function S.r_se_lemon_channel()
  seed = 12
  local c = new()
  day(c, 28, { cloud = 52, hill = "#6a9a48", hill2 = "#5a8a3c", grass = "#7ea85a" })
  for _, p in ipairs({ { 12, 34 }, { 30, 32 }, { 48, 34 }, { 64, 32 } }) do
    tree(c, p[1], p[2], 6, "#3f8a42", "#5e3f28", 1)
    for _, q in ipairs({ { -3, -7 }, { 3, -6 }, { 0, -9 }, { 4, -10 } }) do lemon(c, p[1] + q[1], p[2] + q[2]) end
  end
  -- stone rock spring top-left with trickle
  gnome(c, 20, 39, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 10, 9 }, true, true), arm({ -4, 7 }, { 3, 8 }, false, true) } })
  -- channel in front (back rim, water, front rim)
  part(c, R(c, 0, 38, W - 1, 40), "#b8b4aa")
  c:fill(R(c, 0, 41, W - 1, 45), "#58b4c4")
  for x = 2, 30, 6 do c:fill(R(c, x, 42, x + 2, 42), "#a8e6e6"); c:fill(R(c, x + 3, 44, x + 5, 44), "#8ad4dc") end
  c:fill(R(c, 50, 41, W - 1, 45), "#c8b888")
  for x = 52, 66, 7 do c:px(x, 43, "#58b4c4"); c:px(x + 2, 44, "#58b4c4") end
  part(c, R(c, 0, 46, W - 1, 49), "#9a968c")
  for x = 6, 70, 12 do fl(c, R(c, x, 46, x, 49), "#7a766c") end
  -- the leaf jam and the toad
  part(c, c:ellipse(38, 42, 9, 4), "#a8602a")
  for _, p in ipairs({ { 33, 42 }, { 36, 40 }, { 41, 41 }, { 44, 43 }, { 38, 44 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#c8802a") end
  for _, p in ipairs({ { 34, 43 }, { 40, 43 }, { 39, 40 } }) do c:fill(R(c, p[1], p[2], p[1] + 1, p[2]), "#6a8a34") end
  part(c, c:ellipse(39, 38, 4, 3), "#6a9a3a")
  c:fill(c:ellipse(39, 39, 2, 1), "#b8d070"); c:px(37, 35, "#6a9a3a"); c:px(41, 35, "#6a9a3a"); c:px(37, 36, "#f5cf6a"); c:px(41, 36, "#f5cf6a")
  c:fill(c:line({ { 31, 33 }, { 36, 39 } }, 1), "#8a5a35")
  c:px(33, 47, "#f4f8fa"); c:px(20, 44, "#f4f8fa")
  finish(c, "r_se_lemon_channel")
end

-- 13. piazza bowls
local function bowl(c, x, y, col)
  part(c, c:ellipse(x, y, 2, 2), col); c:px(x - 1, y - 1, "#e8c48a")
end
function S.r_se_piazza_bowls()
  seed = 13
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 8), { "#a8d4e0", "#bcdde4" }, { dir = "v" })
  c:fill(R(c, 0, 8, W - 1, 33), "#ecd8a8")
  fl(c, R(c, 0, 8, W - 1, 9), "#c4623a")
  for _, x in ipairs({ 13, 33, 53 }) do
    c:fill(c:rrect(x, 15, x + 10, 33, 4), "#8a6a46"); c:fill(c:rrect(x + 1, 16, x + 9, 33, 3), "#ecd8a8")
    fl(c, R(c, x + 1, 20, x + 9, 20), "#d8c690")
  end
  for _, x in ipairs({ 4, 24, 44, 64 }) do part(c, R(c, x, 12, x + 3, 24), "#3f8a5a") ; fl(c, R(c, x + 1, 13, x + 1, 23), "#2f6a46") end
  c:fill(R(c, 0, 34, W - 1, H - 1), "#d4b87c"); fl(c, R(c, 0, 34, W - 1, 34), "#e4cc94")
  seed = 77
  for i = 1, 16 do local x, y = floor(rand() * 64) + 4, 37 + floor(rand() * 11); c:px(x, y, "#b8a068"); c:px(x + 1, y, "#b8a068") end
  -- plane trees at the sides
  for _, p in ipairs({ { 6, 38 }, { 66, 36 } }) do
    part(c, R(c, p[1] - 1, p[2] - 18, p[1] + 1, p[2]), "#c8b89a", { noline = true })
    c:px(p[1], p[2] - 12, "#8a7a62"); c:px(p[1] - 1, p[2] - 6, "#8a7a62")
    part(c, c:ellipse(p[1], p[2] - 22, 7, 6), "#6a9a48", { shade = true })
  end
  -- bench with the old gnome cheering
  part(c, R(c, 40, 36, 62, 38), "#a8703e"); fl(c, R(c, 41, 36, 61, 36), "#c8905a")
  part(c, R(c, 42, 38, 43, 41), "#6b3b2a", { noline = true }); part(c, R(c, 59, 38, 60, 41), "#6b3b2a", { noline = true })
  gnome(c, 51, 36, { d = -1, sit = true, hat = "#4f9a45", eyes = "happy", arms = { arm({ -3, 8 }, { -6, 14 }, true) } })
  -- the throw
  gnome(c, 17, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 6 }, { 9, 2 }, true), arm({ -4, 7 }, { -6, 9 }, false) } })
  bowl(c, 29, 46, "#8a4f2a")
  c:fill(R(c, 22, 47, 26, 47), "#e4cc94"); c:px(20, 46, "#e4cc94")
  part(c, c:ellipse(57, 45, 1, 1), "#f5cf6a", { noline = true }); c:px(57, 45, "#fff1a0")
  bowl(c, 52, 44, "#3f6fb0"); bowl(c, 62, 46, "#c0442e")
  finish(c, "r_se_piazza_bowls")
end

-- 14. whistle duel
function S.r_se_whistle_duel()
  seed = 14
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#9ac8e0", "#b4d6e6", "#cfe4ec" }, { dir = "v" })
  c:fill(c:ellipse(30, 22, 36, 14), "#a8bccc"); c:fill(c:ellipse(66, 20, 22, 16), "#98aec0")
  c:fill(c:ellipse(10, 34, 30, 12), "#7aa070"); c:fill(c:ellipse(52, 36, 26, 11), "#6a9460")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#7ea85a")
  c:fill(c:ellipse(60, 35, 16, 5), "#6e9a50"); fl(c, R(c, 46, 31, 74, 33), "#6e9a50")
  c:fill(c:ellipse(18, 52, 40, 9), "#6a9a48"); c:fill(c:ellipse(18, 46, 24, 4), "#8ab060")
  -- the far goatherd on a high hill with a goat
  gnome(c, 61, 35, { d = -1, s = 0.75, hat = "#8a5a35", eyes = "open", arms = { arm({ -3, 9 }, { -4, 11 }, true) } })
  part(c, R(c, 49, 29, 54, 33), "#f4eee0"); fl(c, R(c, 49, 33, 49, 35), "#8a7a68"); fl(c, R(c, 53, 33, 53, 35), "#8a7a68")
  part(c, R(c, 47, 26, 49, 30), "#f4eee0"); c:px(46, 25, "#8a7a68"); c:px(48, 25, "#8a7a68"); c:px(50, 32, "#e8a317")
  fl(c, R(c, 65, 28, 65, 35), "#8a5a35"); c:px(66, 28, "#8a5a35")
  -- our gnome, fingers in mouth
  gnome(c, 20, 47, { d = 1, s = 1.2, eyes = "shut", arms = { arm({ 4, 8 }, { 3, 11 }, true), arm({ -4, 9 }, { -9, 14 }, false) } })
  -- sound: notes and rings flying across
  note(c, 30, 16, "#f4eee0"); note(c, 38, 21, "#f5cf6a"); note(c, 45, 14, "#f4eee0")
  c:fill(c:line({ { 32, 30 }, { 36, 28 }, { 41, 29 }, { 44, 31 } }, 1), "#f4eee0")
  c:fill(c:line({ { 31, 34 }, { 37, 31 }, { 42, 32 }, { 46, 35 } }, 1), "#d8ecf0")
  c:px(52, 22, "#f5cf6a"); c:px(54, 20, "#f5cf6a"); c:px(56, 22, "#f5cf6a")
  finish(c, "r_se_whistle_duel")
end

-- 15. grape-treading race
local function tub(c, x, y)
  part(c, R(c, x - 10, y, x + 10, y + 11), "#b07a45")
  for xx = x - 7, x + 7, 7 do fl(c, R(c, xx, y + 1, xx, y + 10), "#8a5a35") end
  fl(c, R(c, x - 10, y + 3, x + 10, y + 3), "#4a3a2a"); fl(c, R(c, x - 10, y + 8, x + 10, y + 8), "#4a3a2a")
  part(c, c:ellipse(x, y, 10, 3), "#6a2f6a")
  c:fill(c:ellipse(x, y, 8, 2), "#8a3a7a")
  for dx = -6, 6, 3 do c:px(x + dx, y, "#b06aa0") end
  c:px(x - 3, y + 1, "#4a1f4a"); c:px(x + 4, y - 1, "#4a1f4a")
end
function S.r_se_grape_stomp()
  seed = 15
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#a8d4e0", "#bcdde4", "#d0e8e4" }, { dir = "v" })
  c:fill(c:ellipse(40, 30, 40, 9), "#6a9a48")
  c:fill(R(c, 0, 30, W - 1, H - 1), "#8a9a5a"); fl(c, R(c, 0, 30, W - 1, 30), "#a8b870")
  -- trellis rows with grape clusters
  for x = 6, 68, 12 do
    fl(c, R(c, x, 18, x, 32), "#6b4a2e"); fl(c, R(c, x - 5, 20, x + 5, 20), "#6b4a2e")
    c:fill(c:ellipse(x, 22, 5, 2), "#4e8a3c")
    for _, dx in ipairs({ -3, 0, 3 }) do part(c, c:ellipse(x + dx, 25, 1, 2), "#6a3a7a", { noline = true }) end
  end
  -- bunting
  c:fill(c:line({ { 5, 6 }, { 24, 10 }, { 46, 10 }, { 68, 6 } }, 1), "#5e3f28")
  local cols = { "#dd3a2a", "#f5cf6a", "#3f8fb0", "#7ab55c" }
  for i, f in ipairs({ { 8, 7 }, { 14, 8 }, { 20, 9 }, { 27, 10 }, { 33, 10 }, { 39, 10 }, { 46, 10 }, { 52, 9 }, { 58, 8 }, { 64, 7 } }) do
    fl(c, c:poly({ { f[1], f[2] + 1 }, { f[1] + 4, f[2] + 1 }, { f[1] + 2, f[2] + 5 } }), cols[(i - 1) % 4 + 1])
  end
  -- spectator in the middle
  gnome(c, 36, 46, { d = 1, upper = true, s = 0.8, hat = "#3f6fb0", eyes = "happy", arms = { arm({ -3, 9 }, { -5, 14 }, true), arm({ 3, 9 }, { 5, 14 }, true) } })
  -- racers
  gnome(c, 21, 43, { d = 1, upper = true, s = 1.15, eyes = "open", arms = { arm({ -4, 8 }, { -8, 15 }, true), arm({ 4, 8 }, { 8, 14 }, true) } })
  gnome(c, 54, 43, { d = -1, upper = true, s = 1.15, hat = "#e8a317", eyes = "shut", arms = { arm({ -4, 8 }, { -8, 12 }, true), arm({ 4, 8 }, { 8, 15 }, true) } })
  tub(c, 21, 39); tub(c, 54, 39)
  for _, p in ipairs({ { 8, 36 }, { 12, 33 }, { 30, 35 }, { 34, 38 }, { 43, 35 }, { 67, 34 }, { 40, 33 } }) do c:px(p[1], p[2], "#8a3a7a"); c:px(p[1], p[2] + 1, "#8a3a7a") end
  finish(c, "r_se_grape_stomp")
end

-- 16. cicada chorus
local function cicada(c, x, y, d)
  c:fill(R(c, x, y, x + 2, y + 1), "#5a4a22"); c:px(x + (d > 0 and 3 or -1), y, "#5a4a22")
  c:px(x + 1, y - 1, "#d8ecec"); c:px(x + 2, y - 1, "#d8ecec"); c:px(x, y - 1, "#d8ecec")
  c:px(x + 1, y + 2, "#3a2a14")
end
function S.r_se_cicada_chorus()
  seed = 16
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#c8e4ea", "#dcecea", "#f0f0dc", "#faf2c8" }, { dir = "v" })
  c:fill(c:ellipse(56, 9, 5, 5), "#fff8c0"); c:fill(c:ellipse(56, 9, 3, 3), "#ffffe0")
  for i = 0, 7 do local a = i * 0.785; c:px(rnd(56 + math.cos(a) * 9), rnd(9 + math.sin(a) * 9), "#fff4a8") end
  c:fill(c:ellipse(66, 34, 20, 6), "#c8b45a")
  c:fill(R(c, 0, 33, W - 1, H - 1), "#c8b45a"); fl(c, R(c, 0, 33, W - 1, 33), "#e0cc74")
  seed = 55
  for i = 1, 14 do local x, y = floor(rand() * 64) + 4, 36 + floor(rand() * 11); c:px(x, y, "#a8923a"); c:px(x + 1, y - 1, "#a8923a") end
  olive(c, 24, 44)
  for _, p in ipairs({ { 21, 36, 1 }, { 26, 30, -1 }, { 18, 22, 1 }, { 33, 20, -1 }, { 10, 26, -1 }, { 28, 14, 1 } }) do cicada(c, p[1], p[2], p[3]) end
  note(c, 38, 24, "#6a8a34"); note(c, 44, 17, "#c8802a"); note(c, 8, 12, "#6a8a34")
  c:fill(c:line({ { 38, 36 }, { 42, 33 }, { 43, 29 } }, 1), "#f5cf6a")
  gnome(c, 54, 47, { d = -1, eyes = "shut", arms = { arm({ -4, 9 }, { -10, 14 }, true), arm({ 4, 9 }, { 10, 12 }, false) } })
  c:px(49, 36, "#a85a4a"); c:px(50, 36, "#a85a4a")
  c:px(60, 25, "#f4eee0"); c:px(61, 24, "#f4eee0"); c:px(65, 28, "#f4eee0")
  finish(c, "r_se_cicada_chorus")
end
-- 17. maquis flowers
local function bush(c, x, y, r, fl1, fl2)
  part(c, c:ellipse(x, y, r, r - 2), "#4a7a3a", { shade = true })
  for i = 0, r * 3 do
    local dx = ((i * 5 + x) % (2 * r - 1)) - r + 1
    local dy = -((i * 7 + y) % (r - 1)) + 1
    c:px(x + dx, y + dy, (i % 3 == 0) and fl2 or fl1)
    if i % 2 == 0 then c:px(x + dx, y + dy + 1, fl1) end
  end
end
function S.r_se_maquis_flowers()
  seed = 17
  local c = new()
  day(c, 32, { sky = { "#a8d4e0", "#bcdde4", "#d4eae4" }, hill = "#a8a058", hill2 = "#98944c", grass = "#b8a868", edge = "#d0c080", tuft = "#98944c", cloud = 22 })
  -- far watchtower
  part(c, R(c, 56, 16, 62, 30), "#c8b89a"); part(c, R(c, 55, 13, 63, 16), "#a8987a")
  for x = 55, 63, 3 do c:px(x, 12, "#a8987a") end
  fl(c, R(c, 58, 20, 59, 22), "#4a3a2a")
  bush(c, 10, 42, 7, "#a855c8", "#d8a0e8")
  bush(c, 21, 36, 6, "#f4eee0", "#fff1a0")
  bush(c, 66, 38, 6, "#f5cf6a", "#fff1a0")
  bush(c, 55, 45, 9, "#e8609a", "#f6b8cf")
  c:fill(c:line({ { 28, 33 }, { 28, 29 } }, 1), "#6a8a4a")
  gnome(c, 33, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 8 }, true, true), arm({ -4, 7 }, { -5, 4 }, false) } })
  -- magnifier
  c:fill(c:line({ { 41, 38 }, { 45, 34 } }, 1), "#8a5a35")
  part(c, c:ellipse(48, 31, 5, 5), "#8a5a35")
  c:fill(c:ellipse(48, 31, 4, 4), "#cfe8f0")
  c:fill(c:ellipse(48, 31, 2, 2), "#e8609a"); c:px(48, 31, "#fff1a0"); c:px(46, 29, "#fbfdfe"); c:px(47, 28, "#fbfdfe")
  fl(c, R(c, 40, 38, 41, 39), "#f0c8a0")
  finish(c, "r_se_maquis_flowers")
end

-- 18. sunny-wall critters
function S.r_se_sunwall_critters()
  seed = 18
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 36), "#d8b878")
  for y = 5, 33, 7 do
    for x = ((y - 5) // 7 % 2) * 5 - 5, 70, 10 do fl(c, R(c, x, y, x + 8, y), "#b89858"); fl(c, R(c, x + 8, y, x + 8, y + 5), "#b89858") end
  end
  c:fill(c:ellipse(46, 18, 22, 12), "#e4c488")
  for y = 5, 25, 7 do for x = ((y - 5) // 7 % 2) * 5 - 5, 70, 10 do fl(c, R(c, x, y, x + 8, y), "#c4a468") end end
  part(c, R(c, 0, 33, W - 1, 36), "#c8a868"); fl(c, R(c, 0, 33, W - 1, 33), "#ecd098")
  c:fill(R(c, 0, 37, W - 1, H - 1), "#c8b078"); fl(c, R(c, 0, 37, W - 1, 37), "#e0c890")
  for _, p in ipairs({ { 6, 41 }, { 64, 45 }, { 36, 48 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#a89458") end
  -- caper vine hanging
  for _, p in ipairs({ { 8, 5 }, { 10, 8 }, { 13, 6 }, { 9, 11 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#5a8a44") end
  c:px(10, 13, "#fbfdfe"); c:px(7, 9, "#fbfdfe")
  -- gecko
  part(c, c:ellipse(46, 19, 4, 2), "#8aa860"); part(c, R(c, 49, 18, 52, 20), "#8aa860"); c:px(51, 18, INK)
  c:fill(c:line({ { 42, 20 }, { 39, 23 }, { 38, 26 } }, 1), "#8aa860")
  for _, p in ipairs({ { 45, 21 }, { 48, 21 }, { 44, 17 }, { 47, 17 } }) do c:px(p[1], p[2], "#8aa860") end
  c:px(45, 19, "#d0e080"); c:px(47, 19, "#d0e080")
  -- lizard on the ledge
  part(c, R(c, 22, 29, 30, 32), "#6a8a3a"); part(c, R(c, 30, 30, 33, 32), "#6a8a3a"); c:px(32, 30, INK)
  c:fill(c:line({ { 21, 31 }, { 17, 32 }, { 14, 30 } }, 1), "#6a8a3a"); c:px(25, 31, "#a8c860"); c:px(27, 31, "#a8c860")
  -- swallowtail
  part(c, c:ellipse(52, 11, 3, 2), "#f5cf6a"); part(c, c:ellipse(57, 12, 3, 2), "#f5cf6a"); c:px(54, 11, INK); c:px(54, 12, INK); c:px(50, 13, INK); c:px(58, 14, INK)
  -- tortoise
  part(c, c:ellipse(57, 45, 6, 4), "#7a6a3a"); c:fill(c:ellipse(57, 44, 4, 2), "#8a7a4a")
  fl(c, R(c, 54, 44, 60, 44), "#5a4a2a"); fl(c, R(c, 57, 42, 57, 47), "#5a4a2a")
  part(c, R(c, 62, 44, 64, 46), "#a8b880"); c:px(63, 44, INK)
  fl(c, R(c, 53, 47, 55, 48), "#a8b880"); fl(c, R(c, 59, 47, 61, 48), "#a8b880")
  gnome(c, 14, 47, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 6, 16 }, true), arm({ -4, 7 }, { -3, 9 }, false) } })
  part(c, R(c, 4, 38, 8, 42), "#3f6fb0"); fl(c, R(c, 5, 39, 7, 39), "#f4eee0")
  finish(c, "r_se_sunwall_critters")
end

-- 19. olives of the piazza
function S.r_se_olive_kinds()
  seed = 19
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 14), "#a8d4e0")
  c:fill(R(c, 0, 14, W - 1, 38), "#e4d4a8")
  for y = 20, 38, 6 do fl(c, R(c, 0, y, W - 1, y), "#d0be8c") end
  c:fill(R(c, 0, 39, W - 1, H - 1), "#b8a888")
  -- awning, blue and white
  local n = 0
  for x = 4, 68, 5 do
    local col = (n % 2 == 0) and "#3f6fb0" or "#f4eee0"
    fl(c, R(c, x, 5, x + 4, 11), col); fl(c, R(c, x, 12, x + 4, 12), col); fl(c, R(c, x + 1, 13, x + 3, 13), col); n = n + 1
  end
  c:outline(R(c, 4, 5, 68, 13))
  -- shelf of jars
  part(c, R(c, 6, 24, 66, 25), "#8a5a35")
  for i, x in ipairs({ 9, 20, 31, 42, 53, 61 }) do part(c, R(c, x, 17, x + 4, 23), (i % 3 == 0) and "#8aa860" or (i % 3 == 1) and "#a8d0b0" or "#c8c0a0"); fl(c, R(c, x + 1, 15, x + 3, 16), "#8a5a35"); c:px(x + 1, 19, "#e8f0e0") end
  -- counter with five bowls
  part(c, R(c, 2, 36, 70, 44), "#b07a45"); fl(c, R(c, 2, 36, 70, 37), "#d9a660")
  local cols = { { "#2a2a30", "#4a4a58" }, { "#7ab55c", "#a8d880" }, { "#6a3a6a", "#9a6a9a" }, { "#5a4a22", "#8a7a4a" }, { "#8aa83c", "#d8e080" } }
  for i, cc in ipairs(cols) do
    local bx = 6 + (i - 1) * 14
    part(c, c:ellipse(bx + 5, 39, 6, 3), "#c4623a")
    c:fill(c:ellipse(bx + 5, 38, 5, 2), cc[1])
    for k = 0, 3 do c:px(bx + 2 + k * 2, 38 - (k % 2), cc[2]) end
  end
  fl(c, R(c, 8, 41, 8, 44), "#8a4f2a"); fl(c, R(c, 34, 41, 34, 44), "#8a4f2a"); fl(c, R(c, 60, 41, 60, 44), "#8a4f2a")
  -- gnome tasting, olive on a pick
  gnome(c, 38, 36, { d = 1, upper = true, s = 1.25, eyes = "happy", arms = { arm({ 5, 7 }, { 9, 14 }, true) } })
  c:fill(c:line({ { 48, 28 }, { 50, 23 } }, 1), "#d9bc84")
  part(c, c:ellipse(50, 22, 2, 2), "#7ab55c", { noline = false }); c:px(50, 22, "#e8609a"); c:px(49, 21, "#c8e0a0")
  c:fill(R(c, 23, 25, 24, 25), "#f5cf6a"); c:px(55, 28, "#f5cf6a")
  finish(c, "r_se_olive_kinds")
end

-- 20. ripe fig
function S.r_se_ripe_fig()
  seed = 20
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#cfd8a0", "#dce0a8", "#e8e4b0" }, { dir = "v" })
  for _, p in ipairs({ { 10, 30 }, { 58, 36 }, { 36, 40 }, { 64, 22 } }) do c:fill(c:ellipse(p[1], p[2], 5, 5), "#b8c888") end
  -- branch across the top with big leaves
  part(c, c:line({ { 4, 11 }, { 20, 9 }, { 40, 11 }, { 68, 8 } }, 3), "#7a6a58", { noline = true })
  c:fill(c:line({ { 4, 10 }, { 20, 8 }, { 40, 10 }, { 68, 7 } }, 1), "#9a8a72")
  for _, p in ipairs({ { 10, 8 }, { 26, 6 }, { 44, 7 }, { 62, 5 } }) do
    part(c, c:ellipse(p[1], p[2], 6, 4), "#4e9a48", { shade = true }); c:px(p[1] - 3, p[2] + 1, "#6ab35a"); c:fill(R(c, p[1] - 2, p[2], p[1] + 2, p[2]), "#3f7a3a")
  end
  -- four figs, three hard and green, one drooping and ripe
  for i, x in ipairs({ 14, 29, 44, 59 }) do
    fl(c, R(c, x, 12, x, 14), "#7a6a58")
    if i == 3 then
      part(c, c:poly({ { x - 1, 14 }, { x + 1, 14 }, { x + 5, 22 }, { x + 3, 29 }, { x - 3, 29 }, { x - 5, 22 } }), "#6a3a6a", { shade = true })
      c:fill(R(c, x - 1, 24, x + 1, 29), "#e47a8a"); c:fill(R(c, x, 26, x, 28), "#fbd8e4")
      fl(c, R(c, x + 6, 20, x + 6, 21), "#f5cf6a")
      drop(c, x + 1, 31, "#e8a317"); drop(c, x + 1, 35, "#e8a317")
    else
      part(c, c:ellipse(x, 19, 3, 4), "#6a9a3a", { shade = true }); c:px(x - 1, 17, "#a8d070"); fl(c, R(c, x, 14, x, 15), "#7a6a58")
    end
  end
  gnome(c, 30, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 17 }, true), arm({ -4, 7 }, { -5, 4 }, false) } })
  fl(c, R(c, 39, 31, 39, 32), "#f0c8a0")
  fl(c, R(c, 40, 29, 40, 31), "#f0c8a0")
  finish(c, "r_se_ripe_fig")
end

-- 21. gull hoard
function S.r_se_gull_hoard()
  seed = 21
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 12), { "#98cce0", "#b0dae6" }, { dir = "v" })
  part(c, c:poly({ { 0, 12 }, { 72, 12 }, { 72, 36 }, { 0, 36 } }), "#c8b89a")
  for _, p in ipairs({ { 0, 10, 14, 16 }, { 20, 9, 14, 17 }, { 50, 10, 14, 17 } }) do end
  c:fill(c:poly({ { 0, 12 }, { 10, 8 }, { 24, 12 } }), "#c8b89a"); c:fill(c:poly({ { 40, 12 }, { 52, 7 }, { 72, 12 } }), "#c8b89a")
  for y = 16, 34, 6 do fl(c, R(c, 0, y, W - 1, y), "#b0a082") end
  c:fill(R(c, 0, 14, W - 1, 14), "#6a9a48")
  -- three grottoes
  local gx = { 14, 36, 58 }
  for i, x in ipairs(gx) do
    part(c, c:rrect(x - 7, 20, x + 7, 40, 6), "#3a342e")
    c:fill(R(c, x - 7, 30, x + 7, 40), "#3a342e")
    c:fill(c:rrect(x - 5, 23, x + 5, 38, 4), "#241e1a")
  end
  -- glittering hoard in the right-hand grotto
  for _, p in ipairs({ { 55, 34 }, { 58, 33 }, { 61, 35 } }) do c:px(p[1], p[2], "#f5cf6a"); c:px(p[1] + 1, p[2], "#fff1a0") end
  c:px(57, 36, "#c8d4dc"); c:px(60, 31, "#fff1c8"); c:px(56, 30, "#fff1c8")
  sea(c, 41, 49, "#4a9ac0", "#3a86b0")
  -- gull near the middle (wrong) cave
  part(c, c:ellipse(36, 17, 4, 3), "#f4f8fa"); part(c, R(c, 38, 13, 41, 16), "#f4f8fa"); c:px(41, 14, "#e8a317"); c:px(42, 14, "#e8a317"); c:px(40, 14, INK)
  fl(c, R(c, 31, 17, 33, 18), "#9aa4b0"); c:px(36, 21, "#e8a317"); c:px(35, 21, "#e8a317")
  fl(c, R(c, 38, 11, 44, 11), "#e8a317"); c:px(45, 10, "#f4f8fa")
  -- second gull flying
  c:px(14, 8, "#f4f8fa"); c:px(15, 7, "#f4f8fa"); c:px(16, 8, "#f4f8fa"); c:px(17, 7, "#f4f8fa"); c:px(18, 8, "#f4f8fa")
  -- gnome in a rowboat
  part(c, c:poly({ { 12, 41 }, { 40, 41 }, { 36, 47 }, { 17, 47 } }), "#8a5a35")
  fl(c, R(c, 14, 42, 38, 42), "#b07a45")
  gnome(c, 26, 43, { d = 1, sit = true, s = 0.9, eyes = "open", arms = { arm({ 3, 8 }, { 8, 15 }, true), arm({ -4, 6 }, { -6, 3 }, false, true) } })
  c:fill(c:line({ { 18, 44 }, { 12, 48 } }, 1), "#e8c48a")
  finish(c, "r_se_gull_hoard")
end

-- 22. labyrinth turn
function S.r_se_labyrinth_turn()
  seed = 22
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 14), { "#98cce0", "#b0dae6", "#cde6ea" }, { dir = "v" })
  -- distant hedge top and fountain
  c:fill(R(c, 0, 14, W - 1, 22), "#3f8a42")
  c:fill(R(c, 0, 14, W - 1, 14), "#5ab35a")
  part(c, R(c, 31, 12, 41, 22), "#cfd4d8"); c:fill(R(c, 32, 13, 40, 14), "#9ad8e8")
  fl(c, R(c, 35, 5, 37, 12), "#b8e8f4"); c:px(34, 6, "#b8e8f4"); c:px(38, 6, "#b8e8f4"); c:px(33, 8, "#b8e8f4"); c:px(39, 8, "#b8e8f4"); c:px(36, 3, "#fbfdfe")
  -- near hedge walls
  c:fill(R(c, 5, 22, 30, 49), "#2f7a3a"); c:fill(R(c, 42, 22, 68, 49), "#2f7a3a")
  c:fill(R(c, 5, 22, 30, 24), "#4aa44a"); c:fill(R(c, 42, 22, 68, 24), "#4aa44a")
  for i = 0, 40 do local x, y = 6 + (i * 7) % 24, 25 + (i * 5) % 22; c:px(x, y, "#4aa44a"); if i % 2 == 0 then c:px(x + 37, y, "#4aa44a") end end
  for i = 0, 24 do local x, y = 6 + (i * 11) % 24, 26 + (i * 3) % 22; c:px(x, y, "#1f5a2a"); c:px(x + 38, y, "#1f5a2a") end
  -- stone path widening toward us, three ways at the fork
  c:fill(c:poly({ { 30, 22 }, { 42, 22 }, { 52, 49 }, { 20, 49 } }), "#e8e4d8")
  c:fill(c:poly({ { 33, 22 }, { 39, 22 }, { 44, 36 }, { 28, 36 } }), "#f4f0e6")
  for y = 26, 46, 5 do fl(c, R(c, 31 - (y - 22) // 3, y, 41 + (y - 22) // 3, y), "#c8c4b8") end
  -- hedge stub splitting the fork (middle path stays open)
  part(c, R(c, 15, 38, 24, 46), "#2f7a3a"); part(c, R(c, 48, 38, 57, 46), "#2f7a3a")
  c:fill(R(c, 15, 38, 24, 39), "#4aa44a"); c:fill(R(c, 48, 38, 57, 39), "#4aa44a")
  -- the gnome, hand on chin, with a leaf
  gnome(c, 36, 48, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 4, 11 }, true), arm({ -4, 7 }, { -7, 9 }, false) } })
  part(c, c:ellipse(25, 41, 2, 1), "#6ab35a", { noline = true }); c:px(23, 41, "#4aa44a")
  c:px(33, 24, "#f5cf6a"); c:px(40, 30, "#f5cf6a")
  finish(c, "r_se_labyrinth_turn")
end

-- 23. olive press crank
function S.r_se_olive_press()
  seed = 23
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#b8a078")
  for x = 5, 70, 8 do fl(c, R(c, x, 0, x, 38), "#a08a62") end
  part(c, R(c, 0, 4, W - 1, 8), "#6b3b2a")
  c:fill(R(c, 0, 39, W - 1, H - 1), "#8a7a66")
  for y = 42, 50, 4 do fl(c, R(c, 0, y, W - 1, y), "#6a5a46") end
  -- stone trough
  part(c, c:ellipse(44, 44, 22, 5), "#9a968c")
  c:fill(c:ellipse(44, 43, 19, 3), "#5a4a3a")
  -- the great millstone on its side, axle and post
  part(c, R(c, 43, 13, 45, 40), "#6b4a2e", { noline = true })
  part(c, c:ellipse(44, 34, 11, 11), "#aeb0b0", { shade = true })
  c:fill(c:ellipse(44, 34, 8, 8), "#b8bab8")
  c:fill(c:ellipse(44, 34, 2, 2), "#5e5a56")
  for i = 0, 5 do local a = i * 1.047; c:fill(c:line({ { 44, 34 }, { rnd(44 + math.cos(a) * 8), rnd(34 + math.sin(a) * 8) } }, 1), "#9a9c9c") end
  c:px(38, 29, "#d8dada"); c:px(39, 28, "#d8dada")
  -- long crank beam to the gnome
  part(c, c:line({ { 44, 36 }, { 24, 36 } }, 2), "#8a5a35", { noline = true })
  gnome(c, 14, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 8 }, { 10, 11 }, true, true), arm({ -4, 7 }, { 5, 10 }, false, true) } })
  fl(c, R(c, 23, 35, 25, 37), "#f0c8a0")
  -- oil jars at right, spout
  fl(c, R(c, 63, 38, 66, 40), "#8a5a35")
  part(c, R(c, 60, 40, 66, 48), "#c4623a"); fl(c, R(c, 61, 40, 65, 41), "#e8a317")
  c:px(67, 33, "#f5cf6a")
  c:fill(R(c, 64, 40, 64, 40), "#e8a317")
  part(c, R(c, 5, 42, 9, 48), "#c4623a")
  c:fill(c:line({ { 55, 45 }, { 62, 41 } }, 1), "#e8a317")
  for i, y in ipairs({ 12, 18 }) do c:px(60 + i, y, "#6b3b2a") end
  finish(c, "r_se_olive_press")
end

-- 24. forge bellows
function S.r_se_forge_bellows()
  seed = 24
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 42), "#4a3e42")
  for y = 6, 38, 8 do for x = ((y - 6) // 8 % 2) * 6 - 6, 72, 12 do fl(c, R(c, x, y, x + 10, y), "#3a3034"); fl(c, R(c, x + 10, y, x + 10, y + 7), "#3a3034") end end
  c:fill(c:ellipse(56, 30, 24, 16), "#6a4040")
  c:fill(R(c, 0, 43, W - 1, H - 1), "#2f2a2e"); fl(c, R(c, 0, 43, W - 1, 43), "#4a4448")
  -- hearth with roaring white coals
  part(c, R(c, 48, 22, 70, 46), "#5e5458")
  fl(c, R(c, 48, 22, 70, 24), "#7a6e72")
  c:fill(c:rrect(51, 30, 68, 46, 3), "#1a1214")
  c:fill(c:poly({ { 52, 46 }, { 54, 36 }, { 58, 41 }, { 61, 32 }, { 64, 40 }, { 67, 46 } }), "#e0501f")
  c:fill(c:poly({ { 54, 46 }, { 58, 40 }, { 61, 35 }, { 64, 42 }, { 66, 46 } }), "#f0a030")
  c:fill(c:poly({ { 56, 46 }, { 60, 40 }, { 62, 38 }, { 64, 46 } }), "#fff1c8")
  for _, p in ipairs({ { 50, 28 }, { 56, 24 }, { 66, 26 }, { 69, 30 }, { 60, 21 } }) do c:px(p[1], p[2], "#ffd86a") end
  -- little wyrm head carved over the hearth
  part(c, R(c, 56, 14, 62, 20), "#4a4448"); c:px(57, 16, "#e0501f"); c:px(61, 16, "#e0501f"); c:px(55, 14, "#4a4448"); c:px(63, 14, "#4a4448")
  -- huge goatskin bellows: two boards with folded leather between, nozzle to the hearth
  part(c, c:poly({ { 12, 26 }, { 40, 32 }, { 40, 37 }, { 12, 42 } }), "#8a5a35", { shade = true })
  for i, x in ipairs({ 17, 23, 29, 35 }) do
    local t = 26 + (x - 12) * 6 // 28; local bt = 42 - (x - 12) * 5 // 28
    fl(c, R(c, x, t, x, bt), "#5e3f28"); fl(c, R(c, x + 1, t, x + 1, bt), "#b07a45")
  end
  part(c, c:poly({ { 10, 21 }, { 41, 29 }, { 41, 32 }, { 10, 26 } }), "#d9a660")
  part(c, c:poly({ { 10, 42 }, { 41, 37 }, { 41, 40 }, { 10, 47 } }), "#d9a660")
  part(c, R(c, 41, 33, 45, 36), "#8b929c"); part(c, c:line({ { 45, 35 }, { 52, 38 } }, 2), "#8b929c", { noline = true })
  part(c, R(c, 5, 8, 8, 46), "#6b4a2e")
  -- gnome hanging off the pump handle
  part(c, c:line({ { 9, 22 }, { 9, 10 } }, 2), "#8a5a35", { noline = true })
  gnome(c, 22, 47, { d = -1, eyes = "shut", arms = { arm({ -4, 8 }, { -12, 14 }, true), arm({ 4, 8 }, { -9, 17 }, true) } })
  c:px(44, 31, "#ffd86a"); c:px(46, 33, "#ffd86a")
  finish(c, "r_se_forge_bellows")
end
local order = {}
for k in pairs(S) do order[#order + 1] = k end
table.sort(order)
for _, s2 in ipairs(order) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
