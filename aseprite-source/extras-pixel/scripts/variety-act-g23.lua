-- variety-act-g23.lua : Do-tab scenes for 15 rest-stop activities (wave 5 camp/spring + na_birch_planks) -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g23.lua   (params BEFORE --script)
-- Frame (5 grid px wooden frame) copied from the shipped act-hand.png; interior is x 5..68, y 5..49.
-- Frame (5 grid px wooden frame) is copied from the shipped act-hand.png; interior is x 5..68, y 5..49.
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

---------------------------------------------------------------- scenes
local S = {}

local function bubble(c, x0, y0, x1, y1, tx, ty)
  part(c, c:rrect(x0, y0, x1, y1, 3), "#f4eee0")
  c:fill(c:poly({ { tx, y1 + 1 }, { tx + 4, y1 + 1 }, { tx + 1, y1 + 5 } }), "#f4eee0")
end
local function rain(c, x0, x1, y0, y1, n, col, skip)
  for i = 1, n do
    local x, y = x0 + floor(rand() * (x1 - x0)), y0 + floor(rand() * (y1 - y0))
    if not (skip and skip(x, y)) then c:px(x, y, col); c:px(x - 1, y + 1, col); c:px(x - 1, y + 2, col); c:px(x - 2, y + 3, col) end
  end
end
local function stone(c, x, y, rx, ry, col) part(c, c:ellipse(x, y, rx, ry), col or "#9a9ea6", { shade = true }) end
-- little flame
local function flame(c, x, yb, h, w)
  part(c, c:poly({ { x, yb - h }, { x + w, yb - floor(h / 2) }, { x + w + 1, yb }, { x - w - 1, yb }, { x - w, yb - floor(h / 2) } }), "#e0501f")
  c:fill(c:poly({ { x, yb - floor(h * 0.65) }, { x + w - 1, yb - floor(h / 3) }, { x + w - 1, yb }, { x - w + 1, yb }, { x - w + 1, yb - floor(h / 3) } }), "#f08a24")
  c:fill(c:ellipse(x, yb - 2, math.max(1, floor(w / 2)), 2), "#ffd86a")
end
local function pinebg(c, x, yb, h, col) -- plain flat pine, no outline
  local m = c:mask()
  for i = 0, h - 1 do local hw = floor(i * 4 / h * 1.6 + 0.5); m:add(c:rect(x - hw, yb - h + i, x + hw, yb - h + i)) end
  m:add(c:rect(x, yb, x, yb + 1))
  c:fill(m, col)
end
local function tent(c, cx, top, bot, hw, col, door, pat)
  part(c, c:poly({ { cx, top }, { cx + hw, bot }, { cx - hw, bot } }), col)
  local dh = math.floor((bot - top) * 0.55)
  c:fill(c:poly({ { cx, bot - dh }, { cx + math.floor(hw / 3), bot }, { cx - math.floor(hw / 3), bot } }), door or "#4a2c1a")
end
local function note(c, x, y, col)
  fl(c, R(c, x + 2, y, x + 2, y + 5), col); fl(c, R(c, x, y + 5, x + 2, y + 6), col); fl(c, R(c, x + 3, y, x + 4, y + 1), col)
end

-- 1. spring_origins: pondering the warm spring; thought of a curled-up dragon
function S.w5_spring_origins()
  seed = 4
  local c = new()
  day(c, 32, { cloud = 50 })
  -- a rocky hump behind the pool
  part(c, c:ellipse(54, 46, 17, 6), "#8b8f96", { shade = true })
  c:fill(c:ellipse(54, 46, 14, 4), "#7cc9c8")
  c:fill(R(c, 46, 45, 51, 45), "#b8e8e0"); c:fill(R(c, 56, 47, 62, 47), "#b8e8e0")
  c:px(53, 46, "#ffe08a"); c:px(58, 45, "#ffe08a"); c:px(50, 47, "#ffe08a")
  stone(c, 38, 47, 3, 2, "#9a9ea6"); stone(c, 69, 44, 3, 3, "#8b8f96")
  local function puff(x, y, r) c:fill(c:ellipse(x, y, r, math.max(1, r - 1)), "#f4f8fa"); c:fill(R(c, x - r + 1, y + 1, x + r - 1, y + 1), "#cfdcdc") end
  puff(47, 40, 2); puff(49, 36, 3); puff(47, 31, 2); puff(54, 38, 2); puff(56, 33, 3); puff(55, 27, 2); puff(63, 40, 2); puff(62, 35, 2); puff(64, 31, 1)
  -- gnome pondering, hand at chin
  gnome(c, 22, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 4, 10 }, true), arm({ -4, 7 }, { -5, 3 }, false) } })
  -- thought bubble: sleeping dragon
  part(c, c:rrect(6, 6, 34, 21, 4), "#f4eee0")
  c:fill(c:poly({ { 27, 22 }, { 31, 22 }, { 29, 26 } }), "#f4eee0")
  c:px(27, 27, "#f4eee0"); c:px(28, 28, "#f4eee0")
  c:fill(c:ellipse(15, 16, 6, 3), "#4a8a3e")                     -- coiled body
  c:fill(c:ellipse(15, 17, 4, 1), "#8cc060")
  c:fill(c:ellipse(23, 15, 3, 3), "#4a8a3e")                     -- head
  c:fill(R(c, 25, 16, 27, 17), "#4a8a3e")
  c:px(23, 14, INK); c:px(24, 14, INK)
  c:px(21, 11, "#c0442e"); c:px(23, 11, "#c0442e")             -- horns
  c:px(28, 15, "#f0a030"); c:px(29, 14, "#f0a030")             -- sleepy smoke
  fl(c, R(c, 8, 17, 9, 18), "#4a8a3e"); fl(c, R(c, 7, 15, 7, 16), "#4a8a3e")  -- tail curl
  c:paint({ "###", "..#", ".#.", "###" }, 29, 7, { ["#"] = "#6a8ab0" })
  finish(c, "w5_spring_origins")
end

-- 2. rainy_fire: gnome holds a coat over a sputtering fire in the downpour
function S.w5_rainy_fire()
  seed = 8
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#5c6b7c", "#6a7a8a", "#788898", "#8898a6" }, { dir = "v" })
  c:fill(c:ellipse(16, 36, 32, 9), "#46604a"); c:fill(c:ellipse(60, 37, 28, 8), "#3f5a44")
  c:fill(R(c, 0, 35, W - 1, H - 1), "#4a6a48"); c:fill(R(c, 0, 35, W - 1, 35), "#5e7e58")
  for _, p in ipairs({ { 10, 44, 6 }, { 24, 50, 5 }, { 62, 48, 6 } }) do c:fill(c:ellipse(p[1], p[2], p[3], 1), "#6f8da0") end
  -- fire ring + sulky fire
  for _, p in ipairs({ { 40, 45 }, { 46, 47 }, { 52, 47 }, { 58, 45 } }) do stone(c, p[1], p[2], 3, 2, "#7c828a") end
  part(c, c:line({ { 42, 45 }, { 56, 43 } }, 2), "#5a3a22")
  flame(c, 49, 43, 6, 2)
  -- gnome
  gnome(c, 28, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 18 }, true) } })
  -- the coat: held at the hand and draped as a canopy over the fire
  local coat = c:poly({ { 35, 27 }, { 40, 24 }, { 52, 24 }, { 58, 27 }, { 63, 36 }, { 59, 36 }, { 58, 31 }, { 56, 33 }, { 40, 33 }, { 37, 31 }, { 36, 35 }, { 33, 35 } })
  part(c, coat, "#a8582f")
  fl(c, R(c, 40, 25, 52, 25), "#c4703c")
  for _, y in ipairs({ 27, 29, 31 }) do c:px(48, y, "#f5cf6a") end
  fl(c, R(c, 47, 25, 47, 33), "#7a3a1e")
  fl(c, R(c, 33, 27, 36, 28), "#f0c8a0")
  local function under(x, y) return x >= 33 and x <= 63 and y >= 23 and y <= 47 end
  seed = 31
  rain(c, 6, 67, 6, 48, 90, "#c4d6e4", function(x, y) return under(x, y) or (x >= 18 and x <= 36 and y >= 26) end)
  for _, p in ipairs({ { 12, 47 }, { 22, 49 }, { 62, 46 } }) do c:px(p[1], p[2], "#c4d6e4"); c:px(p[1] + 1, p[2], "#c4d6e4") end
  finish(c, "w5_rainy_fire")
end

-- 3. toast_stick: seated gnome toasting a slice of bread on a long stick over a small fire
function S.w5_toast_stick()
  seed = 12
  local c = new()
  day(c, 31, { cloud = 20, sky = { "#c8e0e8", "#d8e8e4", "#e4ece0" } })
  pinebg(c, 64, 33, 13, "#3f6a32"); pinebg(c, 40, 33, 9, "#4e7a3a")
  -- log seat + fire
  part(c, R(c, 4, 40, 24, 45), "#8a5a35")
  fl(c, R(c, 5, 40, 23, 40), "#a8703e"); c:fill(c:ellipse(5, 42, 2, 2), "#e8c48a")
  for _, p in ipairs({ { 50, 48 }, { 55, 49 }, { 60, 49 }, { 65, 48 } }) do stone(c, p[1], p[2], 2, 1, "#8b8f96") end
  part(c, c:line({ { 51, 47 }, { 64, 45 } }, 2), "#6b3b2a"); part(c, c:line({ { 52, 45 }, { 63, 47 } }, 2), "#8a5a35")
  flame(c, 57, 45, 8, 3)
  -- gnome seated, arm out holding the stick
  local _, G = gnome(c, 15, 42, { s = 1.25, d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 8, 9 }, true) } })
  local hx, hy = G.P(8, 9)
  c:fill(c:line({ { hx, hy }, { 56, 38 } }, 1), "#8a5a35")
  c:fill(c:line({ { hx, hy - 1 }, { 56, 37 } }, 1), "#a8703e")
  -- bread slice on the tip
  part(c, c:poly({ { 52, 33 }, { 54, 31 }, { 58, 31 }, { 60, 33 }, { 59, 34 }, { 59, 39 }, { 53, 39 }, { 53, 34 } }), "#8a5a35")
  c:fill(R(c, 54, 33, 58, 38), "#f0c070"); c:fill(R(c, 54, 32, 58, 32), "#f0c070"); c:fill(R(c, 54, 33, 55, 34), "#fbe4a0")
  c:px(57, 37, "#d08a30"); c:px(56, 36, "#d08a30"); c:px(57, 35, "#d08a30")
  -- loaf on the grass
  part(c, c:ellipse(37, 47, 5, 2), "#d9a660"); fl(c, R(c, 33, 46, 41, 46), "#e8c48a")
  c:px(35, 47, "#a8703e"); c:px(38, 47, "#a8703e")
  -- a little smoke
  fl(c, R(c, 60, 27, 61, 28), "#f4f8fa"); fl(c, R(c, 62, 24, 63, 25), "#f4f8fa")
  finish(c, "w5_toast_stick")
end

-- 4. trail_signs: gnome follows crossed sticks and stacked pebbles up a woodland path to a small gift on a stump
function S.w5_trail_signs()
  seed = 16
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#b9d9d0", "#cfe2cc", "#dce8c8" }, { dir = "v" })
  for _, p in ipairs({ { 8, 28, 16 }, { 18, 29, 12 }, { 30, 28, 17 }, { 45, 29, 13 }, { 55, 28, 17 }, { 66, 29, 14 } }) do pinebg(c, p[1], p[2], p[3], "#3f6a32") end
  for _, p in ipairs({ { 12, 30, 12 }, { 24, 30, 9 }, { 38, 30, 11 }, { 50, 30, 9 }, { 62, 30, 11 } }) do pinebg(c, p[1], p[2], p[3], "#4e8a3c") end
  c:fill(R(c, 0, 30, W - 1, H - 1), "#6a9a48"); c:fill(R(c, 0, 30, W - 1, 30), "#8ab868")
  -- winding path
  for _, p in ipairs({ { 24, 50, 18, 3 }, { 34, 45, 13, 3 }, { 44, 40, 10, 2 }, { 52, 36, 8, 2 }, { 58, 33, 6, 1 } }) do c:fill(c:ellipse(p[1], p[2], p[3], p[4]), "#d9b57a") end
  for _, p in ipairs({ { 20, 49 }, { 30, 45 }, { 42, 41 } }) do c:px(p[1], p[2], "#b8965c"); c:px(p[1] + 1, p[2], "#b8965c") end
  -- stump with a wrapped surprise
  part(c, R(c, 59, 28, 66, 33), "#8a5a35"); c:fill(c:ellipse(62, 28, 4, 1), "#c08a52")
  part(c, R(c, 60, 23, 65, 27), "#c0442e"); fl(c, R(c, 62, 23, 63, 27), "#f5cf6a"); fl(c, R(c, 60, 25, 65, 25), "#f5cf6a")
  c:px(61, 22, "#f5cf6a"); c:px(64, 22, "#f5cf6a")
  c:px(58, 20, "#ffe08a"); c:px(66, 21, "#ffe08a")
  -- crossed-stick sign on the left
  fl(c, R(c, 14, 36, 15, 46), "#6b3b2a")
  part(c, c:line({ { 8, 36 }, { 21, 43 } }, 2), "#8a5a35")
  part(c, c:line({ { 21, 35 }, { 8, 43 } }, 2), "#a8703e")
  -- pebble stack
  stone(c, 32, 49, 4, 2, "#9a9ea6"); stone(c, 32, 46, 3, 2, "#b8bcc2"); stone(c, 32, 43, 2, 2, "#8b8f96")
  -- gnome walking to the right
  gnome(c, 47, 49, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 11 }, true) } })
  finish(c, "w5_trail_signs")
end

-- 5. snoring_tent: night; the tent shakes with snores while a gnome hums a lullaby
function S.w5_snoring_tent()
  seed = 20
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#1c2448", "#26305a", "#303c68", "#3a4a76" }, { dir = "v" })
  for _, st in ipairs({ { 8, 9 }, { 20, 7 }, { 12, 22 }, { 26, 27 }, { 40, 8 }, { 66, 22 }, { 56, 26 }, { 34, 9 } }) do c:px(st[1], st[2], "#f4eee0") end
  c:fill(c:ellipse(12, 12, 4, 4), "#f5e6a8"); c:fill(c:ellipse(14, 11, 3, 3), "#26305a")
  c:fill(c:ellipse(18, 35, 30, 9), "#1f3a40"); c:fill(c:ellipse(62, 36, 24, 8), "#22404a")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#2f4f3a"); c:fill(R(c, 0, 34, W - 1, 34), "#3f6048")
  -- tent
  tent(c, 49, 22, 47, 17, "#d9b57a", "#2a1a2a")
  fl(c, R(c, 49, 22, 49, 30), "#b8965c")
  c:fill(c:poly({ { 49, 40 }, { 52, 47 }, { 46, 47 } }), "#2a1a2a")
  -- patched sides of the tent
  fl(c, R(c, 42, 38, 44, 40), "#c0442e"); fl(c, R(c, 55, 36, 57, 38), "#4a6e9a")
  -- shake marks and guy ropes
  for _, y in ipairs({ 30, 36 }) do
    c:paint({ ".#", "#.", "#.", ".#" }, 29, y, { ["#"] = "#d9e0f0" })
    c:paint({ "#.", ".#", ".#", "#." }, 68, y, { ["#"] = "#d9e0f0" })
  end
  c:fill(c:line({ { 36, 30 }, { 27, 46 } }, 1), "#f4eee0"); c:fill(c:line({ { 62, 30 }, { 69, 46 } }, 1), "#f4eee0")
  -- the Zs
  c:paint({ "######", ".....#", "....#.", "...#..", "..#...", ".#....", "######" }, 56, 5, { ["#"] = "#f4eee0" })
  c:paint({ "#####", "....#", "...#.", "..#..", ".#...", "#####" }, 51, 12, { ["#"] = "#cfd8f0" })
  c:paint({ "####", "...#", "..#.", ".#..", "####" }, 49, 19, { ["#"] = "#aab8e0" })
  -- gnome humming a lullaby
  gnome(c, 17, 47, { d = 1, eyes = "shut", arms = { arm({ 4, 7 }, { 4, 11 }, true) } })
  note(c, 26, 28, "#f5cf6a"); note(c, 32, 19, "#f5cf6a")
  finish(c, "w5_snoring_tent")
end


local function pinecone(c, x, y)
  part(c, c:ellipse(x, y, 2, 3), "#8a5a35")
  c:px(x - 1, y - 1, "#b07a45"); c:px(x + 1, y - 1, "#b07a45"); c:px(x, y, "#b07a45"); c:px(x - 1, y + 1, "#b07a45"); c:px(x + 1, y + 1, "#b07a45")
end
local function acorn(c, x, y)
  part(c, c:poly({ { x - 2, y - 1 }, { x + 3, y - 1 }, { x + 1, y + 3 }, { x, y + 3 } }), "#c08a52")
  part(c, R(c, x - 2, y - 2, x + 2, y - 1), "#6b3b2a"); c:px(x, y - 3, "#6b3b2a")
end

-- 6. whittle_stick: big gnome by a birch grove peels a walking stick with a knife; shavings curl down
function S.w5_whittle_stick()
  seed = 24
  local c = new()
  day(c, 33, { cloud = 44, sky = { "#c0dce4", "#d4e6e4", "#e2ece0" } })
  -- birch trunks
  for _, bx in ipairs({ 52, 63 }) do
    part(c, R(c, bx, 6, bx + 3, 46), "#f0ece0", { noline = true })
    fl(c, R(c, bx, 6, bx, 46), "#c8c4b8")
    for _, dy in ipairs({ 12, 19, 25, 31, 38, 43 }) do fl(c, R(c, bx + (dy % 3 == 0 and 1 or 0), dy, bx + 2, dy), "#2a2a2a") end
  end
  c:fill(c:ellipse(53, 8, 9, 5), "#8ab84a"); c:fill(c:ellipse(63, 6, 8, 4), "#a8c850")
  c:fill(c:ellipse(52, 7, 4, 2), "#a8c850")
  -- log seat
  part(c, R(c, 0, 41, 30, 47), "#8a5a35")
  fl(c, R(c, 0, 41, 30, 41), "#a8703e")
  local _, G = gnome(c, 14, 41, { s = 1.5, d = 1, sit = true, eyes = "open", arms = { arm({ 3, 6 }, { 6, 8 }, true, true) } })
  -- stick + knife in his hands
  local ax, ay = G.P(2, 3); local bx, by = G.P(15, 12)
  part(c, c:line({ { ax, ay }, { bx, by } }, 2), "#e8c48a")
  fl(c, c:line({ { ax + 3, ay - 1 }, { bx - 2, by + 2 } }, 1), "#8a5a35")
  local kx, ky = G.P(9, 8)
  part(c, c:line({ { kx, ky }, { kx + 7, ky - 3 } }, 1), "#aeb4bc", { noline = true })
  fl(c, R(c, kx - 2, ky, kx + 1, ky + 1), "#6b3b2a")
  fl(c, R(c, kx - 2, ky - 2, kx + 1, ky - 1), "#f0c8a0"); fl(c, R(c, kx + 3, ky + 1, kx + 5, ky + 2), "#f0c8a0")
  -- curls of shaving
  for _, p in ipairs({ { 31, 33 }, { 34, 37 }, { 30, 41 }, { 36, 43 }, { 40, 46 }, { 33, 47 } }) do
    fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#f6e2b0"); c:px(p[1] + 3, p[2] + 1, "#f6e2b0"); c:px(p[1] + 2, p[2] + 1, "#d8b678")
  end
  c:px(bx + 1, by + 2, "#f6e2b0")
  finish(c, "w5_whittle_stick")
end

-- 7. three_sisters: autumn; stirring the big stew pot with corn, beans and pumpkin beside it
function S.w5_three_sisters()
  seed = 28
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#e8c890", "#eed29c", "#f2dcaa", "#f4e4b8" }, { dir = "v" })
  for _, t in ipairs({ { 8, 36, "#d9822a" }, { 20, 35, "#c0442e" }, { 60, 36, "#e8a317" }, { 68, 34, "#d9822a" } }) do
    part(c, R(c, t[1] - 1, t[2] - 10, t[1] + 1, t[2]), "#6b4a2e", { noline = true })
    part(c, c:ellipse(t[1], t[2] - 14, 7, 6), t[3], { shade = true })
  end
  c:fill(R(c, 0, 34, W - 1, H - 1), "#a89050"); c:fill(R(c, 0, 34, W - 1, 34), "#c0a860")
  for _, p in ipairs({ { 5, 40 }, { 24, 44 }, { 52, 40 }, { 20, 49 } }) do c:px(p[1], p[2], "#d9822a"); c:px(p[1] + 1, p[2] + 1, "#c0442e") end
  -- coals and fire under the pot
  for _, p in ipairs({ { 30, 47 }, { 35, 48 }, { 41, 48 }, { 46, 47 } }) do stone(c, p[1], p[2], 3, 2, "#7c828a") end
  part(c, c:line({ { 30, 43 }, { 33, 47 } }, 1), "#4a2c1a", { noline = true }); part(c, c:line({ { 46, 43 }, { 43, 47 } }, 1), "#4a2c1a", { noline = true })
  flame(c, 38, 47, 5, 2)
  -- iron pot
  part(c, c:rrect(29, 33, 47, 44, 4), "#3a3c44", { shade = true })
  part(c, c:ellipse(38, 33, 9, 2), "#4a4c54")
  c:fill(c:ellipse(38, 33, 7, 1), "#e8a317"); c:fill(R(c, 34, 33, 36, 33), "#f5cf6a"); c:px(41, 33, "#c0442e"); c:px(39, 33, "#7ac05a")
  fl(c, R(c, 31, 36, 32, 41), "#5a5c66")
  c:fill(c:line({ { 28, 35 }, { 38, 26 }, { 48, 35 } }, 1), "#2a1a10")
  for _, p in ipairs({ { 36, 24 }, { 41, 22 } }) do c:fill(c:ellipse(p[1], p[2] - 2, 2, 1), "#f4f8fa") end
  c:fill(c:ellipse(37, 15, 2, 1), "#f4f8fa"); c:fill(c:ellipse(41, 11, 2, 1), "#f4f8fa")
  -- gnome stirring with a long spoon
  local _, G = gnome(c, 13, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 10 }, true) } })
  local hx, hy = G.P(8, 10)
  c:fill(c:line({ { hx, hy }, { 36, 30 } }, 1), "#8a5a35")
  part(c, c:ellipse(36, 32, 2, 2), "#a8703e")
  -- the three sisters: pumpkin, corn, beans
  part(c, c:ellipse(57, 45, 5, 4), "#e07a1f"); fl(c, R(c, 57, 42, 57, 48), "#b8561a"); fl(c, R(c, 55, 43, 55, 47), "#b8561a"); fl(c, R(c, 59, 43, 59, 47), "#b8561a")
  fl(c, R(c, 57, 40, 58, 41), "#4a8a3e")
  part(c, c:rrect(63, 38, 66, 47, 1), "#f0c040"); fl(c, R(c, 64, 39, 64, 43), "#fbe4a0")
  fl(c, R(c, 62, 42, 62, 47), "#4a8a3e"); fl(c, R(c, 67, 42, 67, 47), "#4a8a3e")
  part(c, c:line({ { 48, 45 }, { 52, 45 } }, 2), "#4a9a3a"); part(c, c:line({ { 49, 48 }, { 53, 47 } }, 2), "#6ab050")
  c:px(50, 45, "#7ac05a"); c:px(51, 47, "#8cd060")
  finish(c, "w5_three_sisters")
end

-- 8. fire_pit_ring: carrying a stone to complete the ring around the fire
function S.w5_fire_pit_ring()
  seed = 32
  local c = new()
  day(c, 30, { cloud = 14, sky = { "#c0dce4", "#d4e6e4", "#e2ece0" } })
  pinebg(c, 62, 31, 14, "#3f6a32"); pinebg(c, 50, 31, 10, "#4e7a3a")
  c:fill(c:ellipse(48, 42, 22, 8), "#8a6a44"); c:fill(c:ellipse(48, 42, 19, 6), "#6a4a30")
  local cx, cy, rx, ry = 48, 42, 15, 5
  local back, front = {}, {}
  for k = 0, 11 do
    local a = k * math.pi / 6
    local px, py = cx + rnd(math.cos(a) * rx), cy + rnd(math.sin(a) * ry)
    if k == 4 or k == 5 then -- gap on the near left
    elseif math.sin(a) >= 0.01 then front[#front + 1] = { px, py } else back[#back + 1] = { px, py } end
  end
  for _, p in ipairs(back) do stone(c, p[1], p[2], 3, 2, "#9a9ea6") end
  part(c, c:line({ { 42, 42 }, { 55, 40 } }, 2), "#5a3a22"); part(c, c:line({ { 43, 40 }, { 54, 42 } }, 2), "#8a5a35")
  flame(c, 48, 41, 11, 4)
  for _, p in ipairs(front) do stone(c, p[1], p[2], 3, 2, "#aeb2ba") end
  c:px(46, 25, "#ffd86a"); c:px(52, 29, "#f08a24")
  -- pile of loose stones (left foreground)
  stone(c, 7, 48, 4, 2, "#8b8f96"); stone(c, 12, 49, 3, 2, "#9a9ea6"); stone(c, 9, 45, 3, 2, "#aeb2ba")
  -- gnome with a stone
  local _, G = gnome(c, 24, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ -3, 6 }, { 7, 6 }, false, true), arm({ 4, 6 }, { 8, 6 }, true, true) } })
  local sx, sy = G.P(9, 7)
  stone(c, sx + 1, sy - 1, 4, 3, "#aeb2ba"); c:px(sx, sy - 2, "#d4d8de")
  fl(c, R(c, sx - 3, sy, sx - 2, sy + 1), "#f0c8a0"); fl(c, R(c, sx + 4, sy, sx + 5, sy + 1), "#f0c8a0")
  finish(c, "w5_fire_pit_ring")
end

-- 9. patch_tent: a patchwork tent, a moth flying out of the newest hole, gnome with needle and a new patch
function S.w5_patch_tent()
  seed = 36
  local c = new()
  day(c, 34, { cloud = 14, sky = { "#c0dce4", "#d4e6e4", "#e2ece0" } })
  local cx, top, bot, hw = 46, 9, 47, 23
  local tm = c:poly({ { cx, top }, { cx + hw, bot + 1 }, { cx - hw, bot + 1 } })
  part(c, tm, "#d9b57a")
  local function patch(x0, y0, x1, y1, col, st)
    local m = R(c, x0, y0, x1, y1):clip(tm)
    c:fill(m, col)
    if st then for x = x0, x1, 2 do c:px(x, y0, st); c:px(x, y1, st) end end
  end
  patch(36, 24, 44, 30, "#c0442e", "#f4eee0"); patch(46, 30, 54, 38, "#4a8a9a", "#f4eee0"); patch(33, 36, 41, 44, "#e8c04a", "#8a5a35")
  patch(50, 18, 56, 24, "#4f9a45", "#f4eee0"); patch(54, 40, 64, 47, "#8a5a9a", "#f4eee0"); patch(42, 14, 48, 20, "#e07a1f", "#f4eee0")
  patch(59, 28, 65, 34, "#c0442e", "#f4eee0")
  -- door
  c:fill(c:poly({ { cx, 33 }, { cx + 4, bot + 1 }, { cx - 4, bot + 1 } }):clip(tm), "#4a2c1a")
  c:fill(R(c, 43, 36, 47, 37), "#4a2c1a")
  -- the hole
  c:fill(c:ellipse(38, 30, 3, 2), "#4a2c1a"); c:px(35, 29, "#4a2c1a"); c:px(41, 31, "#4a2c1a")
  -- moths
  for _, p in ipairs({ { 32, 22 }, { 25, 16 }, { 37, 14 } }) do
    fl(c, R(c, p[1] - 2, p[2], p[1] - 1, p[2] + 1), "#f4eee0"); fl(c, R(c, p[1] + 1, p[2], p[1] + 2, p[2] + 1), "#f4eee0"); c:px(p[1], p[2], "#6b4a2e"); c:px(p[1], p[2] + 1, "#6b4a2e")
  end
  -- guy ropes
  c:fill(c:line({ { 24, 46 }, { 16, 49 } }, 1), "#f4eee0")
  -- gnome with needle and a patch
  local _, G = gnome(c, 14, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 7, 12 }, true) } })
  local px, py = G.P(7, 12)
  part(c, R(c, px + 1, py - 4, px + 6, py + 1), "#4a6ec0")
  for x = px + 1, px + 6, 2 do c:px(x, py - 4, "#f4eee0"); c:px(x, py + 1, "#f4eee0") end
  c:px(px + 3, py - 2, "#f5cf6a"); c:px(px + 4, py - 1, "#f5cf6a")  -- a little fish
  c:fill(c:line({ { px + 7, py - 5 }, { px + 12, py - 10 } }, 1), "#aeb4bc")
  finish(c, "w5_patch_tent")
end

-- 10. pinecone_game: a big gnome and a tiny scout reveal pinecone vs acorn; the rule chain above
function S.w5_pinecone_game()
  seed = 40
  local c = new()
  day(c, 31, { cloud = 52, sky = { "#c0dce4", "#d4e6e4", "#e2ece0" } })
  pinebg(c, 8, 32, 14, "#3f6a32"); pinebg(c, 64, 32, 12, "#3f6a32")
  tent(c, 37, 23, 31, 8, "#d9b57a", "#4a2c1a")
  -- rule banner: pinecone > twig > acorn > pinecone
  part(c, c:rrect(14, 6, 58, 16, 3), "#f4eee0")
  pinecone(c, 21, 11)
  fl(c, R(c, 25, 11, 28, 11), "#6b3b2a"); c:px(28, 10, "#6b3b2a"); c:px(28, 12, "#6b3b2a")
  part(c, c:line({ { 31, 13 }, { 38, 9 } }, 1), "#8a5a35", { noline = true }); fl(c, R(c, 35, 8, 36, 9), "#8a5a35"); c:px(34, 12, "#8a5a35")
  fl(c, R(c, 40, 11, 43, 11), "#6b3b2a"); c:px(43, 10, "#6b3b2a"); c:px(43, 12, "#6b3b2a")
  acorn(c, 49, 11)
  -- the two players
  gnome(c, 16, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 9 }, true) } })
  gnome(c, 56, 47, { s = 0.8, d = -1, hat = "#4f9a45", eyes = "happy", arms = { arm({ 4, 6 }, { 8, 8 }, true) } })
  pinecone(c, 29, 38); acorn(c, 45, 39)
  c:px(37, 34, "#ffd86a"); c:px(38, 33, "#ffd86a"); c:px(39, 34, "#ffd86a"); c:px(38, 35, "#ffd86a")
  c:px(37, 38, "#ffd86a"); c:px(38, 39, "#ffd86a"); c:px(36, 40, "#ffd86a")
  finish(c, "w5_pinecone_game")
end


-- 11. scout_badges: a gnome proudly shows a new cloth badge beside a banner full of them
function S.w5_scout_badges()
  seed = 44
  local c = new()
  day(c, 33, { cloud = 14, sky = { "#c0dce4", "#d4e6e4", "#e2ece0" } })
  pinebg(c, 6, 34, 12, "#3f6a32")
  -- banner hung between two poles
  part(c, R(c, 26, 7, 27, 40), "#6b3b2a", { noline = true }); part(c, R(c, 66, 7, 67, 40), "#6b3b2a", { noline = true })
  part(c, R(c, 25, 8, 68, 9), "#8a5a35")
  part(c, R(c, 28, 10, 65, 38), "#4f8a5a")
  local tail = c:poly({ { 28, 38 }, { 46, 43 }, { 65, 38 } })
  c:fill(tail, "#4f8a5a"); c:outline(tail)
  fl(c, R(c, 28, 10, 65, 10), "#6fae78")
  for x = 30, 63, 3 do c:px(x, 12, "#f5cf6a") end
  local function disc(x, y, col, ico, icol)
    part(c, c:ellipse(x, y, 4, 4), col)
    c:fill(c:ellipse(x, y, 3, 3), col)
    c:paint(ico, x - 2, y - 2, { ["#"] = icol })
  end
  disc(34, 19, "#4a6ec0", { ".#.", "###", ".#." }, "#f5cf6a")
  disc(46, 19, "#c0442e", { ".#.", "###", "###" }, "#ffd86a")
  disc(58, 19, "#8a5a9a", { "#.#", ".#.", "#.#" }, "#f4eee0")
  disc(34, 30, "#e8a317", { "###", "#.#", "###" }, "#6b3b2a")
  disc(46, 30, "#4a9a9a", { "..#", ".#.", "#.." }, "#f4eee0")
  -- the empty spot waiting
  c:fill(c:ellipse(58, 30, 3, 3), "#3f7a4a"); for _, p in ipairs({ { 56, 27 }, { 60, 27 }, { 56, 33 }, { 60, 33 }, { 55, 30 }, { 61, 30 } }) do c:px(p[1], p[2], "#a8d4a0") end
  -- gnome holding up the new badge
  local _, G = gnome(c, 14, 47, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 8, 15 }, true, true) } })
  local bx, by = G.P(8, 15)
  part(c, c:ellipse(bx, by - 3, 4, 4), "#e8c040"); c:fill(c:ellipse(bx, by - 3, 3, 3), "#e8c040")
  c:paint({ ".#.", "###", ".#." }, bx - 1, by - 4, { ["#"] = "#c0442e" })
  fl(c, R(c, bx - 1, by, bx + 1, by + 1), "#f0c8a0")
  c:px(bx + 5, by - 7, "#ffd86a"); c:px(bx - 5, by - 6, "#ffd86a"); c:px(bx + 6, by - 3, "#ffd86a")
  finish(c, "w5_scout_badges")
end

-- 12. tent_hide_seek: seeker counts behind covered eyes; a giggling scout hides among five tents
function S.w5_tent_hide_seek()
  seed = 48
  local c = new()
  day(c, 29, { cloud = 52, sky = { "#c0dce4", "#d4e6e4", "#e2ece0" } })
  -- the hidden scout, giggling behind the middle back tent
  gnome(c, 38, 35, { s = 0.7, d = 1, upper = true, hat = "#4f9a45", eyes = "happy" })
  for _, p in ipairs({ { 28, 22 }, { 29, 20 }, { 46, 21 }, { 47, 23 } }) do c:px(p[1], p[2], "#e8a317") end
  -- back row
  tent(c, 13, 24, 37, 9, "#c0442e"); tent(c, 29, 24, 37, 9, "#4a6ec0"); tent(c, 47, 24, 37, 9, "#e8c04a"); tent(c, 62, 24, 37, 9, "#8a5a9a")
  fl(c, R(c, 13, 24, 13, 28), "#f4eee0")
  -- front tent, flap open
  tent(c, 55, 28, 48, 13, "#4f9a45", "#2a1a2a")
  c:fill(R(c, 55, 28, 55, 34), "#2f6a2f")
  c:fill(c:ellipse(55, 45, 1, 1), "#f4eee0")
  -- seeker with hands over eyes
  gnome(c, 20, 48, { d = 1, eyes = "shut", arms = { arm({ 4, 6 }, { 3, 10 }, true) } })
  fl(c, R(c, 18, 37, 23, 38), "#f0c8a0"); fl(c, R(c, 24, 38, 25, 43), "#4a6e9a"); fl(c, R(c, 23, 37, 25, 38), "#f0c8a0")
  for _, p in ipairs({ { 8, 38 }, { 4, 42 } }) do c:px(p[1], p[2], "#6a9a48") end
  finish(c, "w5_tent_hide_seek")
end

-- 13. puff_embers: dawn; gnome puffs on the grey embers, sparks and ash fly, the kettle waits
function S.w5_puff_embers()
  seed = 52
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#4a5a8a", "#7a6a9a", "#b08aa4", "#e0a0a0", "#f4c490", "#f8dca0" }, { dir = "v" })
  c:fill(c:ellipse(46, 33, 8, 7), "#fbe8a8"); c:fill(c:ellipse(46, 33, 5, 4), "#fff4c8")
  for _, p in ipairs({ { 10, 8 }, { 24, 12 }, { 60, 9 } }) do c:px(p[1], p[2], "#e8e4f0") end
  c:fill(c:ellipse(14, 35, 28, 8), "#4a6a58"); c:fill(c:ellipse(60, 36, 26, 7), "#456450")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#5a8060"); c:fill(R(c, 0, 34, W - 1, 34), "#78a078")
  -- ember heap in a small ring
  for _, p in ipairs({ { 38, 45 }, { 44, 47 }, { 52, 47 }, { 58, 45 }, { 63, 43 } }) do stone(c, p[1], p[2], 3, 2, "#8b8f96") end
  c:fill(c:ellipse(50, 44, 11, 4), "#8a8e96"); c:fill(c:ellipse(50, 43, 8, 3), "#a8acb4")
  for _, p in ipairs({ { 46, 43 }, { 49, 42 }, { 52, 44 }, { 55, 43 }, { 50, 44 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#e0501f") end
  c:px(50, 43, "#ffd86a"); c:px(51, 43, "#ffd86a"); c:px(48, 43, "#f08a24")
  -- first flame tongue + sparks and ash
  flame(c, 50, 42, 5, 2)
  for _, p in ipairs({ { 44, 34 }, { 47, 30 }, { 55, 33 }, { 58, 28 }, { 51, 26 }, { 42, 38 } }) do c:px(p[1], p[2], "#ffd86a"); c:px(p[1] + 1, p[2] + 1, "#f08a24") end
  for _, p in ipairs({ { 45, 38 }, { 56, 38 }, { 53, 31 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#c8ccd4") end
  -- kettle hanging ready on a tripod
  part(c, c:rrect(60, 41, 67, 47, 2), "#aeb4bc", { shade = true }); part(c, R(c, 61, 39, 66, 41), "#8b929c")
  part(c, c:poly({ { 59, 42 }, { 56, 40 }, { 56, 42 }, { 59, 45 } }), "#aeb4bc"); fl(c, R(c, 62, 38, 64, 38), "#6b3b2a")
  -- gnome puffing from the left, eyes shut, wind lines
  gnome(c, 15, 42, { s = 1.25, d = 1, sit = true, eyes = "shut" })
  for _, p in ipairs({ { 25, 33 }, { 28, 36 }, { 25, 39 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#fbeedc"); c:px(p[1] + 6, p[2] - 1, "#fbeedc") end
  finish(c, "w5_puff_embers")
end

-- 14. never_out_fire: snowy dusk; the old story of a snail carrying a coal over three valleys
function S.w5_never_out_fire()
  seed = 56
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#6a7aa4", "#8a88ac", "#b498b0", "#d8aaa8", "#f0c4a8" }, { dir = "v" })
  c:fill(c:ellipse(14, 34, 30, 9), "#cdd9e8"); c:fill(c:ellipse(60, 35, 28, 8), "#d3deea")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#e6edf3"); c:fill(R(c, 0, 46, W - 1, H - 1), "#dbe5ee")
  pine(c, 64, 36, 16, true); pine(c, 5, 36, 14, true)
  -- the fire, big, in a ring of snowy stones
  for _, p in ipairs({ { 30, 46 }, { 36, 48 }, { 43, 48 }, { 49, 46 } }) do stone(c, p[1], p[2], 3, 2, "#9a9ea6") end
  part(c, c:line({ { 32, 46 }, { 48, 43 } }, 2), "#5a3a22"); part(c, c:line({ { 32, 43 }, { 48, 46 } }, 2), "#8a5a35")
  flame(c, 40, 44, 14, 5)
  c:px(36, 28, "#f08a24"); c:px(45, 31, "#ffd86a"); c:px(41, 25, "#ffd86a")
  -- listeners on a log in blankets
  part(c, R(c, 52, 44, 68, 47), "#8a5a35"); fl(c, R(c, 53, 44, 67, 44), "#c8d4e0")
  gnome(c, 58, 43, { d = -1, sit = true, hat = "#4f9a45", eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, true) } })
  -- the teller
  gnome(c, 17, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -8, 14 }, false), arm({ 4, 8 }, { 8, 14 }, true) } })
  -- bubble: snail with a glowing coal on its shell
  part(c, c:rrect(6, 6, 32, 20, 3), "#f4eee0")
  c:fill(c:poly({ { 20, 21 }, { 24, 21 }, { 21, 25 } }), "#f4eee0")
  fl(c, R(c, 9, 17, 25, 18), "#d9b57a")
  fl(c, R(c, 25, 15, 27, 18), "#d9b57a"); c:px(26, 13, "#8a5a35"); c:px(28, 13, "#8a5a35"); c:px(26, 14, "#d9b57a"); c:px(28, 14, "#d9b57a")
  part(c, c:ellipse(16, 14, 4, 4), "#8a5a35"); c:fill(c:ellipse(16, 14, 2, 2), "#b07a45"); c:px(16, 14, "#8a5a35")
  c:fill(c:poly({ { 16, 7 }, { 18, 10 }, { 14, 10 } }), "#e0501f"); c:px(16, 9, "#ffd86a")
  seed = 61
  for i = 1, 32 do
    local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * 43)
    if not (x >= 6 and x <= 32 and y <= 25) then c:px(x, y, "#fbfdfe") end
    if i % 6 == 0 then c:px(x + 1, y, "#fbfdfe") end
  end
  finish(c, "w5_never_out_fire")
end

-- 15. na_birch_planks: tapping a froe with a mallet to split a birch log; planks stacked ready
function S.na_birch_planks()
  seed = 60
  local c = new()
  day(c, 33, { cloud = 50, sky = { "#c0dce4", "#d4e6e4", "#e2ece0" } })
  for _, bx in ipairs({ 56, 65 }) do
    part(c, R(c, bx, 8, bx + 2, 33), "#f0ece0", { noline = true })
    for _, dy in ipairs({ 13, 19, 25, 30 }) do fl(c, R(c, bx, dy, bx + 1, dy), "#2a2a2a") end
  end
  c:fill(c:ellipse(58, 9, 8, 5), "#8ab84a"); c:fill(c:ellipse(66, 8, 6, 4), "#a8c850")
  c:fill(R(c, 0, 34, W - 1, 34), "#9cc070")
  -- trestles and the birch log
  part(c, R(c, 31, 43, 33, 49), "#6b3b2a", { noline = true }); part(c, R(c, 56, 43, 58, 49), "#6b3b2a", { noline = true })
  part(c, R(c, 29, 36, 61, 44), "#f0ece0")
  for _, p in ipairs({ { 36, 38 }, { 44, 41 }, { 52, 38 }, { 58, 42 }, { 40, 43 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#3a3a3a") end
  fl(c, R(c, 29, 36, 61, 36), "#d8d4c8")
  part(c, c:ellipse(29, 40, 3, 4), "#e8c48a"); c:fill(c:ellipse(29, 40, 1, 2), "#c08a52")
  -- the split starting, froe blade in, handle up
  fl(c, R(c, 30, 40, 40, 40), "#4a2c1a")
  part(c, R(c, 29, 39, 38, 41), "#aeb4bc")
  part(c, R(c, 36, 29, 38, 39), "#6b3b2a")
  -- gnome with raised mallet
  local _, G = gnome(c, 18, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 7, 16 }, true, true) } })
  local mx, my = G.P(7, 17)
  part(c, R(c, mx - 1, my - 3, mx + 5, my + 1), "#a8703e"); part(c, R(c, mx + 1, my + 1, mx + 2, my + 5), "#6b3b2a", { noline = true })
  fl(c, R(c, mx - 1, my + 2, mx + 1, my + 4), "#f0c8a0")
  c:px(mx + 7, my - 3, "#ffd86a"); c:px(mx + 8, my - 1, "#ffd86a")
  -- finished planks
  part(c, R(c, 49, 47, 67, 49), "#e8c48a"); part(c, R(c, 50, 44, 66, 46), "#f0d29a"); part(c, R(c, 52, 41, 64, 43), "#e8c48a")
  fl(c, R(c, 50, 48, 66, 48), "#c08a52")
  -- chips
  for _, p in ipairs({ { 6, 49 }, { 11, 48 }, { 27, 48 }, { 44, 49 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#f0d29a") end
  finish(c, "na_birch_planks")
end

local order = { "w5_spring_origins", "w5_rainy_fire", "w5_toast_stick", "w5_trail_signs", "w5_snoring_tent", "w5_whittle_stick", "w5_three_sisters", "w5_fire_pit_ring", "w5_patch_tent", "w5_pinecone_game", "w5_scout_badges", "w5_tent_hide_seek", "w5_puff_embers", "w5_never_out_fire", "na_birch_planks" }
for _, s2 in ipairs(order) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
