-- variety-act-h11.lua : regional (MENA) rest-stop scenes -> act-<slug>.png (144x108, 72x54 grid at out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-h11.lua
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

---------------------------------------------------------------- shared desert helpers
local SAND, SAND2, SAND3 = "#e8cc92", "#f4deaa", "#d4ae74"
local MUD, MUD2 = "#d4a46a", "#e2bc86"
local TERRA = "#c4623a"

local function desert(c, g, o)
  o = o or {}
  c:bands(R(c, 0, 0, W - 1, g), o.sky or { "#9fd2de", "#bfe0dc", "#e0ecd2", "#f2eac4" }, { dir = "v" })
  if o.sun ~= false then c:fill(c:ellipse(o.sun or 58, 11, o.sunr or 4, o.sunr or 4), o.suncol or "#fff4c0") end
  c:fill(c:ellipse(16, g + 3, 36, 9), o.far or "#dcb97c"); c:fill(c:ellipse(60, g + 4, 30, 8), o.far2 or "#d2ac72")
  c:fill(R(c, 0, g, W - 1, H - 1), o.sand or SAND)
  c:fill(R(c, 0, g, W - 1, g), o.edge or SAND2)
  for i = 1, 12 do
    local x, y = floor(rand() * 62) + 4, g + 2 + floor(rand() * (H - g - 4))
    c:px(x, y, o.spk or SAND3); c:px(x + 1, y, o.spk or SAND3)
  end
end

local function palm(c, x, yb, h, dates)
  local top = yb - h
  part(c, c:line({ { x, yb }, { x + 1, yb - floor(h / 2) }, { x, top } }, 2), "#8a5a35", { noline = true })
  for yy = yb - 2, top + 2, 3 do fl(c, R(c, x - 1, yy, x + 1, yy), "#6b3b2a") end
  local m = c:mask()
  for _, f in ipairs({ { -9, 3 }, { -7, -2 }, { -3, -5 }, { 3, -5 }, { 7, -2 }, { 9, 3 } }) do
    m:add(c:line({ { x, top }, { x + floor(f[1] / 2), top + floor(f[2] / 2) - 2 }, { x + f[1], top + f[2] } }, 2))
  end
  part(c, m, "#3f8a42")
  c:px(x - 1, top + 2, "#c8802a"); c:px(x + 1, top + 2, "#c8802a"); c:px(x, top + 3, "#c8802a")
  if dates then c:px(x - 2, top + 3, "#e8a317"); c:px(x + 2, top + 3, "#e8a317") end
end

local function jar(c, cx, top, w, h, col, o)
  o = o or {}
  local hw = floor(w / 2)
  part(c, R(c, cx - 2, top, cx + 1, top + 2), col)
  part(c, c:ellipse(cx, top + 2 + floor(h / 2), hw, floor(h / 2)), col, { shade = true })
  fl(c, R(c, cx - 3, top, cx + 2, top), o.rim or "#8a4a2a")
  if o.band then fl(c, R(c, cx - hw + 1, top + 4, cx + hw - 1, top + 4), o.band) end
end

local function puffs(c, x, y, n, col)
  for i = 0, n - 1 do fl(c, R(c, x + (i % 2), y - i * 3, x + 1 + (i % 2), y - i * 3 + 1), col or "#f4f8fa") end
end

local function flame(c, x, yb, h)
  part(c, c:poly({ { x, yb - h }, { x + 3, yb - 3 }, { x + 4, yb }, { x - 4, yb }, { x - 3, yb - 3 } }), "#e0501f")
  c:fill(c:poly({ { x, yb - h + 3 }, { x + 2, yb - 3 }, { x + 2, yb }, { x - 2, yb }, { x - 2, yb - 3 } }), "#f08a24")
  c:fill(R(c, x - 1, yb - 2, x + 1, yb), "#ffd86a")
end

local function camel(c, x, yb, d, col)
  col = col or "#c89a5a"
  d = d or 1
  local function X(v) return x + d * v end
  part(c, R(c, X(-4) - (d < 0 and 1 or 0), yb - 8, X(-3) - (d < 0 and 1 or 0), yb), col, { noline = true })
  part(c, R(c, X(3) - (d < 0 and 1 or 0), yb - 8, X(4) - (d < 0 and 1 or 0), yb), col, { noline = true })
  local m = c:ellipse(x, yb - 11, 7, 4)
  m:add(c:ellipse(X(-1), yb - 15, 2, 2))
  m:add(c:line({ { X(6), yb - 12 }, { X(8), yb - 19 } }, 3))
  m:add(R(c, math.min(X(7), X(12)), yb - 22, math.max(X(7), X(12)), yb - 20))
  part(c, m, col, { shade = true })
  c:px(X(10), yb - 21, INK)
  fl(c, R(c, X(-7), yb - 12, X(-7), yb - 8), "#8a5a35")
end

local function sacks(c, x, yb, col, n) end

---------------------------------------------------------------- scenes
local S = {}

-- 1 terrace_turns: terraces with a shared channel; gnome holds up the turn slate
function S.r_mena_terrace_turns()
  seed = 11
  local c = new()
  desert(c, 33, { sky = { "#b4dce0", "#d4e8d8", "#eef0cc", "#f8f0cc" }, sun = 12, sunr = 6, suncol = "#fffbe0" })
  -- terraces climbing to the right
  local ts = { { 14, 40, 47 }, { 26, 32, 39 }, { 38, 24, 31 } }
  for i, t in ipairs(ts) do
    local x0 = t[1]
    part(c, R(c, x0, t[2] + 4, 68, t[3]), "#b8986a")
    fl(c, R(c, x0 + 1, t[2] + 4, 68, t[2] + 4), "#cfb27c")
    for x = x0 + 4, 66, 6 do fl(c, R(c, x, t[2] + 6, x + 2, t[2] + 6), "#8f7248") end
    fl(c, R(c, x0, t[2], 68, t[2] + 3), i == 2 and "#7ab55c" or "#5e9a48")
    for x = x0 + 3, 66, 4 do c:px(x, t[2] + 1, "#a8d078"); c:px(x + 1, t[2] + 2, "#a8d078") end
    fl(c, R(c, x0, t[2] + 3, 68, t[2] + 3), "#4a7a38")
    -- water channel along the lip
    fl(c, R(c, x0, t[2] + 3, x0 + 8, t[2] + 4), "#58b4c4")
    c:outline(R(c, x0, t[2], 68, t[3]))
  end
  -- trickles between terraces
  for _, t in ipairs({ { 22, 39, 40 }, { 34, 31, 32 }, { 46, 23, 24 } }) do fl(c, R(c, t[1], t[2], t[1] + 1, t[3] + 4), "#8fd4e0") end
  fl(c, R(c, 15, 43, 22, 44), "#58b4c4")
  -- sluice plank at the bottom channel
  part(c, R(c, 12, 38, 13, 44), "#8a5a35", { noline = true }); part(c, R(c, 10, 38, 15, 39), "#a8703e")
  -- gnome with the turn slate
  gnome(c, 30, 49, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 13 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  part(c, R(c, 36, 28, 45, 37), "#6b3b2a")
  fl(c, R(c, 37, 29, 44, 36), "#4a5a64")
  for i, y in ipairs({ 30, 32, 34 }) do fl(c, R(c, 38, y, 38 + (i == 2 and 5 or 3), y), "#f4eee0") end
  c:px(43, 34, "#f4eee0")
  -- heat shimmer
  for _, p in ipairs({ { 8, 22 }, { 14, 26 } }) do c:px(p[1], p[2], "#fff8d0"); c:px(p[1] + 1, p[2] + 1, "#fff8d0"); c:px(p[1], p[2] + 2, "#fff8d0") end
  finish(c, "r_mena_terrace_turns")
end

-- 2 chickpea_cumin: stall-cook stirring a big pot, the smell curling down the lane
function S.r_mena_chickpea_cumin()
  seed = 12
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#e6c48e")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 40), "#d4aa72") end
  part(c, c:ellipse(14, 24, 9, 9), "#7a5a3a"); fl(c, c:ellipse(14, 26, 7, 8):clip(R(c, 0, 20, 40, 40)), "#b89a6a")
  c:fill(c:ellipse(14, 26, 6, 7), "#5a8aa8")
  c:fill(R(c, 0, 41, W - 1, H - 1), "#c9a96e"); fl(c, R(c, 0, 41, W - 1, 41), "#d9bc84")
  -- awning
  local n = 0
  for x = 22, 66, 4 do
    local col = (n % 2 == 0) and "#c0442e" or "#f4eee0"
    fl(c, R(c, x, 5, x + 3, 12), col); fl(c, R(c, x + 1, 13, x + 2, 13), col); n = n + 1
  end
  -- hanging chilies
  for _, x in ipairs({ 26, 34, 58 }) do fl(c, R(c, x, 14, x, 22), "#c8a060"); c:px(x, 23, "#dd3a2a"); c:px(x, 24, "#dd3a2a"); c:px(x + 1, 22, "#dd3a2a") end
  -- stall counter + stove + big pot
  part(c, R(c, 24, 38, 68, 49), "#b07a45"); fl(c, R(c, 24, 38, 68, 39), "#d9a660")
  part(c, c:poly({ { 41, 38 }, { 49, 38 }, { 53, 33 }, { 37, 33 } }), "#3a3a3a", { noline = true })
  flame(c, 45, 38, 5)
  part(c, c:rrect(36, 22, 56, 34, 4), "#8b5a3a", { shade = true })
  fl(c, R(c, 36, 23, 56, 24), "#6b3b2a")
  c:fill(c:ellipse(46, 23, 9, 2), "#e0a040"); for _, x in ipairs({ 42, 46, 50, 44, 48 }) do c:px(x, 23, "#f0d070") end
  puffs(c, 44, 18, 4); puffs(c, 50, 17, 3)
  -- cumin and chickpea bowls on the counter
  part(c, c:ellipse(30, 38, 4, 2), "#e8a317"); c:fill(c:ellipse(30, 37, 2, 1), "#8a5a2a")
  part(c, c:ellipse(62, 38, 4, 2), "#e8c48a"); for _, x in ipairs({ 60, 62, 64 }) do c:px(x, 37, "#d9a660") end
  -- gnome with long spoon, nose up, scent curls
  gnome(c, 14, 49, { d = 1, eyes = "happy", arms = { arm({ 4, 7 }, { 10, 11 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  c:fill(c:line({ { 25, 28 }, { 42, 24 } }, 1), "#8a5a35")
  for i, p in ipairs({ { 22, 26 }, { 25, 22 }, { 21, 19 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#e8a317"); c:px(p[1] + 2, p[2] - 1, "#c8802a") end
  finish(c, "r_mena_chickpea_cumin")
end

-- 3 ember_sage: dune edge, seated gnome at a small blackened pot on embers, sage bundle
function S.r_mena_ember_sage()
  seed = 13
  local c = new()
  desert(c, 30, { sun = 60 })
  part(c, c:poly({ { 50, 18 }, { 62, 31 }, { 38, 31 } }), "#a8764a")
  c:fill(c:poly({ { 50, 24 }, { 54, 31 }, { 46, 31 } }), "#5e3f28")
  -- sage shrubs at the dune edge
  for _, p in ipairs({ { 9, 33 }, { 15, 31 }, { 66, 40 } }) do
    part(c, c:ellipse(p[1], p[2], 4, 3), "#8aa890", { shade = true }); c:px(p[1] - 1, p[2] - 1, "#b8ccb8"); c:px(p[1] + 2, p[2], "#b8ccb8")
  end
  -- embers
  c:fill(c:ellipse(40, 46, 9, 3), "#4a2c1a")
  for _, p in ipairs({ { 34, 46 }, { 37, 47 }, { 41, 45 }, { 44, 47 }, { 46, 46 } }) do c:px(p[1], p[2], "#e0501f"); c:px(p[1] + 1, p[2], "#f08a24") end
  fl(c, R(c, 38, 44, 42, 44), "#ffd86a")
  part(c, c:rrect(35, 36, 45, 44, 3), "#2a2420", { shade = true }); fl(c, R(c, 36, 36, 44, 36), "#4a4440")
  -- sprigs poking out, steam
  for _, p in ipairs({ { 37, 31, -1 }, { 40, 29, 0 }, { 43, 31, 1 } }) do c:fill(c:line({ { 40, 36 }, { p[1], p[2] } }, 1), "#8aa890") end
  c:px(37, 31, "#b8ccb8"); c:px(40, 29, "#b8ccb8"); c:px(43, 31, "#b8ccb8")
  puffs(c, 41, 27, 3, "#f4f8fa")
  -- gnome seated, holds a tied sage bundle
  gnome(c, 20, 42, { d = 1, sit = true, s = 1.15, eyes = "shut", arms = { arm({ 3, 8 }, { 8, 8 }, true) } })
  fl(c, R(c, 30, 32, 32, 38), "#7a9a82"); fl(c, R(c, 29, 30, 33, 32), "#9ab8a0"); c:px(30, 29, "#b8ccb8"); c:px(32, 29, "#b8ccb8"); fl(c, R(c, 30, 38, 32, 38), "#8a5a35")
  finish(c, "r_mena_ember_sage")
end

-- 4 sweating_jar: potter's wheel, a tall unglazed jar with beads of water on it
function S.r_mena_sweating_jar()
  seed = 14
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#e2bc86")
  for y = 4, 36, 8 do fl(c, R(c, 0, y, W - 1, y), "#cfa670") end
  c:fill(R(c, 0, 39, W - 1, H - 1), "#b8965c"); fl(c, R(c, 0, 39, W - 1, 39), "#d9bc84")
  -- shelf of finished jars
  part(c, R(c, 36, 17, 68, 19), "#8a5a35")
  for i, x in ipairs({ 42, 52, 62 }) do jar(c, x, 7, 8, 8, "#d9a070", { rim = "#a8703e" }) end
  fl(c, R(c, 37, 15, 38, 16), "#8a5a35")
  -- wheel: disc on a stand
  part(c, R(c, 30, 40, 34, 49), "#6b3b2a", { noline = true })
  part(c, c:ellipse(32, 42, 11, 3), "#8a5a35", { shade = true })
  part(c, c:rrect(22, 46, 42, 49, 1), "#8a5a35")
  -- the jar on the wheel, dripping
  jar(c, 32, 24, 14, 14, "#e0aa78", { rim = "#a8703e", band = "#c8825a" })
  for _, p in ipairs({ { 28, 32 }, { 36, 34 }, { 31, 36 }, { 34, 29 }, { 27, 37 } }) do c:px(p[1], p[2], "#8fd4e8"); c:px(p[1], p[2] + 1, "#58b4c4") end
  c:px(40, 26, "#8fd4e8"); c:px(41, 27, "#58b4c4")
  -- gnome seated at the wheel, hands on the jar
  gnome(c, 12, 43, { d = 1, sit = true, s = 1.15, eyes = "open", arms = { arm({ 4, 9 }, { 11, 9 }, true) } })
  -- a puddle & drip bowl
  c:fill(c:ellipse(50, 47, 6, 1), "#8fd4e8")
  finish(c, "r_mena_sweating_jar")
end

-- 5 sand_glass: glowing gob on a blowpipe drawn into a thread, furnace, pink sand and the harbour
function S.r_mena_sand_glass()
  seed = 15
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#a8d4e0", "#bfe0e4", "#d6ecea" }, { dir = "v" })
  c:fill(R(c, 0, 24, W - 1, 31), "#4a9ab4"); c:fill(R(c, 0, 24, W - 1, 24), "#7ccfd4")
  for _, x in ipairs({ 40, 52, 62 }) do c:fill(R(c, x, 28, x + 2, 28), "#8fd4e0") end
  -- jetty planks and a boat mast
  part(c, R(c, 38, 32, 68, 34), "#8a5a35"); for x = 38, 66, 6 do part(c, R(c, x, 34, x + 1, 38), "#5e3f28", { noline = true }) end
  fl(c, R(c, 60, 12, 60, 31), "#5e3f28"); fl(c, c:poly({ { 61, 13 }, { 67, 29 }, { 61, 29 } }), "#f4eee0")
  c:fill(R(c, 0, 32, W - 1, H - 1), "#e8b0a8"); c:fill(R(c, 0, 32, W - 1, 32), "#f0c4b8")
  c:fill(R(c, 0, 46, W - 1, H - 1), "#dca098")
  -- pile of pink sand
  part(c, c:poly({ { 56, 49 }, { 62, 40 }, { 68, 49 } }), "#f0b8b0"); fl(c, R(c, 61, 41, 62, 42), "#f8d4cc")
  -- furnace
  part(c, R(c, 6, 20, 22, 44), "#8a5a35", { shade = true })
  fl(c, R(c, 6, 20, 22, 21), "#6b3b2a")
  c:fill(c:rrect(10, 30, 18, 40, 3), "#2a1a10"); c:fill(c:rrect(11, 32, 17, 40, 2), "#e0501f"); c:fill(R(c, 13, 36, 15, 40), "#ffd86a")
  -- gnome with blowpipe, drawing the thread out to the right
  gnome(c, 30, 49, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 11 }, true), arm({ -4, 7 }, { 2, 10 }, false) } })
  c:fill(c:line({ { 31, 38 }, { 46, 31 } }, 1), "#6b6b6b")
  part(c, c:ellipse(48, 31, 3, 3), "#ff9a3a", { noline = true }); c:fill(c:ellipse(48, 31, 2, 2), "#ffd86a"); c:px(47, 30, "#fff8d0")
  c:fill(c:line({ { 51, 32 }, { 56, 36 }, { 60, 44 } }, 1), "#ffb050")
  c:px(61, 45, "#ffd86a")
  for _, p in ipairs({ { 52, 28 }, { 44, 27 } }) do c:px(p[1], p[2], "#ffd86a") end
  finish(c, "r_mena_sand_glass")
end

-- 6 high_pour: tea poured from arm's height into a small glass, froth crown
function S.r_mena_high_pour()
  seed = 16
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#e8d6a6")
  -- arch with tiles
  part(c, c:rrect(14, 8, 58, 46, 10), "#2f8fa0")
  c:fill(c:rrect(18, 12, 54, 46, 8), "#6a4a7a")
  for x = 20, 52, 8 do for y = 16, 40, 8 do c:px(x, y, "#f5cf6a"); c:px(x + 1, y + 1, "#f5cf6a") end end
  for x = 16, 56, 4 do c:px(x, 7, (x % 8 == 0) and "#f4eee0" or "#2f5fa0") end
  c:fill(R(c, 0, 41, W - 1, H - 1), "#a8483a"); fl(c, R(c, 0, 41, W - 1, 41), "#c8624a")
  for x = 4, 66, 8 do fl(c, R(c, x, 44, x + 3, 44), "#e8c48a"); fl(c, R(c, x + 2, 47, x + 5, 47), "#e8c48a") end
  -- low table with tray of glasses
  part(c, R(c, 38, 40, 62, 42), "#8a5a35"); part(c, R(c, 40, 42, 41, 49), "#5e3f28", { noline = true }); part(c, R(c, 59, 42, 60, 49), "#5e3f28", { noline = true })
  part(c, c:ellipse(50, 39, 10, 2), "#d4d8dc")
  for _, x in ipairs({ 44, 56 }) do part(c, R(c, x, 34, x + 3, 38), "#cfeee8"); fl(c, R(c, x, 36, x + 3, 38), "#c8802a") end
  -- the glass being filled
  part(c, R(c, 49, 34, 52, 38), "#cfeee8"); fl(c, R(c, 49, 35, 52, 38), "#c8802a"); fl(c, R(c, 49, 33, 52, 34), "#f4eee0"); c:px(50, 32, "#f4eee0")
  -- gnome with the pot raised high, stream falling
  gnome(c, 28, 49, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 28 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  part(c, c:rrect(35, 14, 45, 21, 2), "#c8ccd0", { shade = true })
  part(c, c:poly({ { 45, 15 }, { 50, 13 }, { 50, 15 }, { 45, 19 } }), "#c8ccd0")
  fl(c, R(c, 38, 12, 41, 13), "#8a5a35"); fl(c, R(c, 33, 15, 33, 19), "#8a5a35")
  fl(c, R(c, 50, 16, 50, 32), "#c8802a")
  c:px(55, 24, "#f5cf6a"); c:px(58, 30, "#f5cf6a")
  finish(c, "r_mena_high_pour")
end

-- 7 palm_mulch (heat): straw blanket on a date-palm basin
function S.r_mena_palm_mulch()
  seed = 17
  local c = new()
  desert(c, 31, { sky = { "#bfe0dc", "#e4eed0", "#f8f0c4", "#fff4cc" }, sun = 12, sunr = 6, suncol = "#fffbe0", far = "#e2c48a", far2 = "#dcb87c" })
  palm(c, 50, 36, 24, true)
  palm(c, 65, 34, 18, false)
  -- basin ring with straw going in
  part(c, c:ellipse(50, 41, 14, 5), "#a8703e", { shade = true })
  c:fill(c:ellipse(50, 41, 11, 3.5), "#5e3f28")
  c:fill(c:ellipse(50, 40, 9, 2), "#e8c860")
  for _, p in ipairs({ { 44, 40 }, { 48, 39 }, { 53, 41 }, { 56, 40 }, { 50, 42 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#f5dc80"); c:px(p[1] + 1, p[2] + 1, "#b89040") end
  -- straw heap
  part(c, c:ellipse(12, 45, 8, 4), "#e8c860", { shade = true })
  for _, p in ipairs({ { 6, 43 }, { 10, 42 }, { 14, 43 }, { 8, 46 }, { 13, 47 } }) do c:px(p[1], p[2], "#b89040"); c:px(p[1] + 1, p[2] - 1, "#f5dc80") end
  -- gnome forking a clump of straw towards the ring
  local _, G = gnome(c, 27, 48, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 10 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  c:fill(c:line({ { 26, 52 }, { 33, 41 }, { 40, 30 } }, 1), "#8a5a35")
  c:fill(c:line({ { 39, 31 }, { 42, 27 } }, 1), "#8a5a35")
  part(c, c:ellipse(41, 28, 5, 3), "#e8c860", { shade = true })
  for _, p in ipairs({ { 37, 27 }, { 40, 25 }, { 44, 27 }, { 42, 30 } }) do c:px(p[1], p[2], "#f5dc80"); c:px(p[1] + 1, p[2] + 1, "#b89040") end
  c:px(46, 24, "#f5dc80"); c:px(36, 22, "#f5dc80"); c:px(47, 31, "#b89040")
  finish(c, "r_mena_palm_mulch")
end

-- 8 wind_catcher: gnome on the inn roof trowelling a crack in the tall square chimney, swifts leaving
function S.r_mena_wind_catcher()
  seed = 18
  local c = new()
  desert(c, 36, { sun = 14 })
  -- inn wall and flat roof
  part(c, R(c, 5, 34, 68, 49), MUD, { shade = true })
  fl(c, R(c, 5, 34, 68, 36), MUD2)
  for _, x in ipairs({ 14, 30 }) do part(c, c:rrect(x, 40, x + 5, 48, 2), "#4a2c1a") end
  -- wind-catcher tower with louvre slots
  part(c, R(c, 44, 10, 58, 34), MUD, { shade = true })
  part(c, R(c, 42, 8, 60, 11), MUD2)
  for y = 14, 30, 4 do fl(c, R(c, 47, y, 55, y), "#6b3b2a"); fl(c, R(c, 47, y + 1, 55, y + 1), "#9a7a52") end
  -- the crack and two swifts
  fl(c, R(c, 56, 17, 56, 19), "#2a1a10"); fl(c, R(c, 55, 19, 55, 21), "#2a1a10"); fl(c, R(c, 56, 21, 56, 24), "#2a1a10")
  local function swift(x, y) fl(c, R(c, x, y, x + 3, y), "#3a3a48"); c:px(x - 1, y - 1, "#3a3a48"); c:px(x + 4, y - 1, "#3a3a48"); c:px(x + 1, y + 1, "#f4eee0") end
  swift(62, 14); swift(64, 22)
  -- breeze lines leaking out
  fl(c, R(c, 61, 26, 65, 26), "#f4f8fa"); fl(c, R(c, 62, 29, 67, 29), "#f4f8fa")
  -- gnome on the roof with trowel and mortar bucket
  gnome(c, 32, 34, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 11, 14 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  fl(c, R(c, 44, 13, 47, 13), "#aeb4bc"); fl(c, R(c, 40, 14, 43, 15), "#8a5a35")
  part(c, R(c, 14, 30, 19, 34), "#8a5a35"); fl(c, R(c, 14, 30, 19, 30), "#c8b080")
  finish(c, "r_mena_wind_catcher")
end

-- 9 groaning_wheel: greasing the hub of a big clay-bucket waterwheel that groans out of tune
function S.r_mena_groaning_wheel()
  seed = 19
  local c = new()
  desert(c, 28, { sun = 12 })
  -- river
  c:fill(R(c, 0, 34, W - 1, H - 1), "#4a9ab4"); c:fill(R(c, 0, 34, W - 1, 34), "#7ccfd4")
  for _, p in ipairs({ { 36, 40 }, { 52, 43 }, { 60, 38 }, { 44, 47 } }) do c:fill(R(c, p[1], p[2], p[1] + 3, p[2]), "#8fd4e0") end
  -- stone piers and wheel
  part(c, R(c, 28, 26, 32, 40), "#a8aeb4", { shade = true }); part(c, R(c, 60, 26, 64, 40), "#a8aeb4", { shade = true })
  local ring = c:ellipse(46, 28, 16, 16); ring:cut(c:ellipse(46, 28, 13, 13))
  local wheel = ring:copy()
  for _, e in ipairs({ { 30, 28, 62, 28 }, { 46, 12, 46, 44 }, { 35, 17, 57, 39 }, { 35, 39, 57, 17 } }) do wheel:add(c:line({ { e[1], e[2] } , { e[3], e[4] } }, 2)) end
  wheel:add(c:ellipse(46, 28, 3, 3))
  part(c, wheel, "#a8703e", { shade = true })
  fl(c, c:ellipse(46, 28, 1, 1), "#4a2c1a")
  for k = 0, 7 do
    local a = k * math.pi / 4 + 0.4
    local bx, by = rnd(46 + 16 * math.cos(a)), rnd(28 + 16 * math.sin(a))
    part(c, R(c, bx - 1, by - 1, bx + 1, by + 1), "#c4623a")
  end
  -- water in front of the lower wheel
  c:fill(R(c, 0, 38, W - 1, H - 1), "#4a9ab4"); c:fill(R(c, 0, 38, W - 1, 38), "#7ccfd4")
  for _, x in ipairs({ 40, 46, 52 }) do c:fill(R(c, x, 38, x + 2, 38), "#f4f8fa") end
  -- bank with the gnome, grease pot and brush
  c:fill(R(c, 0, 36, 22, H - 1), SAND); c:fill(R(c, 0, 36, 22, 36), SAND2)
  part(c, R(c, 20, 36, 24, 49), "#b89a6a", { noline = true })
  gnome(c, 14, 48, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 10, 11 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  fl(c, R(c, 24, 28, 28, 30), "#e0a030"); part(c, R(c, 23, 31, 27, 35), "#8a5a35"); fl(c, R(c, 24, 31, 26, 31), "#e0a030")
  fl(c, R(c, 28, 26, 28, 28), "#8a5a35")
  -- sour sound lines
  for _, p in ipairs({ { 25, 8 }, { 32, 6 }, { 38, 9 } }) do
    fl(c, R(c, p[1], p[2], p[1], p[2] + 3), "#4a2c1a"); fl(c, R(c, p[1] + 1, p[2], p[1] + 2, p[2] + 1), "#4a2c1a")
  end
  c:px(28, 13, "#4a2c1a"); c:px(35, 12, "#4a2c1a")
  finish(c, "r_mena_groaning_wheel")
end

-- 10 well_sand: gnome up to the chest in the sand-filled well lifting out a basket, camels queueing
function S.r_mena_well_sand()
  seed = 20
  local c = new()
  desert(c, 30, { sun = 14 })
  -- patient camels in line
  camel(c, 62, 41, -1, "#b88a50")
  camel(c, 48, 48, -1, "#c89a5a")
  -- well: back rim, gnome, front stones
  part(c, c:ellipse(24, 38, 15, 5), "#a8aeb4", { shade = true })
  c:fill(c:ellipse(24, 38, 12, 3.5), "#e8cc92")
  gnome(c, 24, 44, { upper = true, d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -8, 15 }, true, true), arm({ 4, 7 }, { 8, 15 }, true, true) } })
  part(c, c:rrect(9, 44, 39, 49, 1), "#a8aeb4")
  for _, x in ipairs({ 14, 20, 26, 32 }) do fl(c, R(c, x, 44, x, 48), "#7a8088") end
  fl(c, R(c, 10, 44, 38, 44), "#c9c5bc")
  -- basket of sand overhead
  part(c, c:rrect(17, 18, 31, 24, 2), "#a8703e", { shade = true })
  fl(c, R(c, 18, 21, 30, 21), "#8a5a35")
  part(c, c:poly({ { 18, 18 }, { 24, 12 }, { 30, 18 } }), "#e8cc92"); c:px(23, 14, SAND2)
  for _, p in ipairs({ { 36, 14 }, { 38, 18 }, { 12, 17 }, { 10, 21 } }) do c:px(p[1], p[2], SAND3); c:px(p[1], p[2] + 1, SAND) end
  -- wind-blown sand streaks
  for _, p in ipairs({ { 8, 28 }, { 40, 29 } }) do fl(c, R(c, p[1], p[2], p[1] + 6, p[2]), SAND2) end
  finish(c, "r_mena_well_sand")
end

-- 11 pit_pebbles: a carved board of pits, an old gnome who never loses, a scatter of pebbles
function S.r_mena_pit_pebbles()
  seed = 21
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 30), "#e2bc86")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 30), "#d4aa72") end
  part(c, c:rrect(22, 6, 50, 34, 10), "#4a2c1a"); c:fill(c:rrect(25, 10, 47, 34, 8), "#a8764a")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#a8483a"); fl(c, R(c, 0, 31, W - 1, 31), "#c8624a")
  for x = 4, 66, 8 do for y = 36, 48, 6 do fl(c, R(c, x + (y % 12 == 0 and 3 or 0), y, x + 3, y), "#e8c48a") end end
  -- board
  part(c, R(c, 20, 38, 52, 46), "#8a5a35")
  fl(c, R(c, 21, 38, 51, 39), "#a8703e")
  for i = 0, 5 do
    for _, y in ipairs({ 41, 44 }) do
      local x = 24 + i * 5
      c:fill(c:ellipse(x, y, 2, 1), "#3a2412")
      if (i + y) % 2 == 0 then c:px(x - 1, y, "#e8dcc0"); c:px(x, y, "#c8a070") else c:px(x, y, "#e8dcc0") end
    end
  end
  -- player's gnome scatters pebbles
  gnome(c, 10, 42, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 11, 10 }, true) } })
  for _, p in ipairs({ { 22, 33 }, { 25, 35 }, { 28, 32 } }) do part(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#e8dcc0", { noline = true }); c:px(p[1], p[2], "#c8b090") end
  -- the old gnome: long beard, calm
  gnome(c, 62, 42, { d = -1, sit = true, eyes = "shut", s = 1.1, arms = { arm({ -3, 8 }, { -5, 4 }, true) } })
  finish(c, "r_mena_pit_pebbles")
end

-- 12 dune_boards: sliding down the tallest dune on a waxed board, sand spraying
function S.r_mena_dune_boards()
  seed = 22
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#8fd0e4", "#a8dce8", "#c8ecee" }, { dir = "v" })
  c:fill(c:ellipse(60, 10, 4, 4), "#fff4c0")
  c:fill(c:poly({ { 5, 34 }, { 5, 18 }, { 14, 12 }, { 24, 16 }, { 34, 28 }, { 46, 40 }, { 68, 46 }, { 68, 34 }, { 40, 30 } }), "#dcb97c")
  -- the tall dune
  local dune = c:poly({ { 5, 49 }, { 5, 16 }, { 12, 9 }, { 20, 11 }, { 34, 26 }, { 50, 38 }, { 68, 44 }, { 68, 49 } })
  c:fill(dune, "#f2dca6")
  c:fill(c:poly({ { 12, 9 }, { 20, 11 }, { 34, 26 }, { 50, 38 }, { 68, 44 }, { 68, 49 }, { 40, 49 }, { 26, 36 }, { 14, 20 } }), "#d4ae74")
  -- camp tent on the crest and a spare board in the sand
  part(c, c:poly({ { 10, 7 }, { 16, 17 }, { 4, 17 } }), "#c0442e"); c:fill(c:poly({ { 10, 11 }, { 12, 17 }, { 8, 17 } }), "#6b3b2a")
  part(c, R(c, 18, 21, 19, 33), "#a8703e")
  -- the board and the gnome riding it, arms wide
  part(c, c:line({ { 38, 33 }, { 52, 39 } }, 2), "#d9a660")
  gnome(c, 45, 36, { d = 1, walk = 1, eyes = "happy", arms = { arm({ -4, 8 }, { -9, 13 }, false), arm({ 4, 8 }, { 10, 12 }, true) } })
  -- spray and a trail behind
  for _, p in ipairs({ { 34, 32 }, { 31, 31 }, { 36, 30 }, { 29, 27 }, { 40, 31 }, { 33, 35 } }) do c:px(p[1], p[2], "#fff4d0"); c:px(p[1] + 1, p[2], "#f2dca6") end
  finish(c, "r_mena_dune_boards")
end

-- 13 date_stones: flicking date stones towards a chalk line along the orchard wall
function S.r_mena_date_stones()
  seed = 23
  local c = new()
  desert(c, 26, { sun = 60, far = "#e2c48a" })
  palm(c, 14, 30, 22, true); palm(c, 40, 30, 18, true); palm(c, 62, 30, 24, true)
  part(c, R(c, 5, 28, 68, 33), MUD, { shade = true })
  for x = 10, 66, 8 do fl(c, R(c, x, 30, x + 3, 30), "#a8764a") end
  c:fill(R(c, 5, 34, 68, 49), "#d9b97e"); c:fill(R(c, 5, 34, 68, 34), "#e4c890")
  -- chalk line
  fl(c, R(c, 50, 35, 50, 49), "#f4f4ec"); c:px(51, 40, "#f4f4ec"); c:px(49, 45, "#f4f4ec")
  -- stones: already thrown, and one in flight
  local function stone(x, y) part(c, R(c, x, y, x + 1, y + 1), "#6b3b2a", { noline = true }); c:px(x, y, "#9a6a40") end
  for _, p in ipairs({ { 48, 38 }, { 53, 41 }, { 47, 46 }, { 54, 47 }, { 51, 36 } }) do stone(p[1], p[2]) end
  stone(33, 32)
  for _, p in ipairs({ { 24, 36 }, { 28, 33 }, { 38, 33 }, { 43, 36 } }) do c:px(p[1], p[2], "#6b3b2a") end
  -- basket of dates
  part(c, c:rrect(60, 41, 68, 48, 2), "#a8703e", { shade = true }); c:fill(R(c, 61, 39, 67, 41), "#a8501f"); for _, x in ipairs({ 62, 64, 66 }) do c:px(x, 39, "#e8a317") end
  -- gnome kneeling, finger flick
  gnome(c, 14, 43, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 9, 5 }, true) } })
  c:px(23, 41, "#6b3b2a"); c:px(24, 41, "#6b3b2a")
  finish(c, "r_mena_date_stones")
end

-- 14 drum_duel (dusk): two gnomes with goblet drums, lanterns glowing in the courtyard
function S.r_mena_drum_duel()
  seed = 24
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#3b2f66", "#4e3a78", "#7a4a88", "#b45a7c", "#e8825e" }, { dir = "v" })
  for _, p in ipairs({ { 9, 8 }, { 24, 6 }, { 40, 9 }, { 55, 7 }, { 62, 16 } }) do c:px(p[1], p[2], "#f4eee0") end
  part(c, R(c, 5, 22, 68, 49), "#a8764a", { noline = true })
  c:fill(R(c, 5, 22, 68, 24), "#b8845a")
  c:fill(c:rrect(26, 14, 46, 36, 8), "#2a1a30"); c:fill(R(c, 26, 28, 46, 36), "#2a1a30")
  c:fill(R(c, 5, 38, 68, 49), "#8a5a3a"); fl(c, R(c, 5, 38, 68, 38), "#a8704a")
  -- lanterns on a line
  fl(c, c:line({ { 5, 14 }, { 36, 19 }, { 68, 14 } }, 1), "#3d2a1c")
  for _, p in ipairs({ { 14, 15 }, { 24, 17 }, { 36, 20 }, { 48, 17 }, { 58, 15 } }) do
    fl(c, R(c, p[1], p[2], p[1] + 2, p[2] + 3), "#ffd86a"); c:px(p[1] + 1, p[2] + 1, "#fff1c8"); c:px(p[1] + 1, p[2] - 1, "#3d2a1c")
    c:px(p[1] - 1, p[2] + 1, "#f8c070"); c:px(p[1] + 3, p[2] + 1, "#f8c070")
  end
  local function drum(x, yb)
    part(c, c:poly({ { x - 2, yb - 8 }, { x + 3, yb - 8 }, { x + 2, yb - 4 }, { x + 6, yb }, { x - 5, yb } }), "#c4623a")
    fl(c, R(c, x - 5, yb - 1, x + 6, yb), "#8e3e22")
    part(c, c:ellipse(x, yb - 9, 6, 2), "#f0e0b0")
    fl(c, R(c, x - 3, yb - 6, x + 4, yb - 6), "#f5cf6a")
  end
  gnome(c, 14, 43, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 12, 8 }, true) } })
  drum(27, 46)
  gnome(c, 58, 43, { d = -1, sit = true, eyes = "happy", arms = { arm({ -3, 8 }, { -12, 8 }, true) } })
  drum(45, 46)
  -- sound arcs
  for _, p in ipairs({ { 33, 32 }, { 38, 30 }, { 36, 28 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#ffd86a"); c:px(p[1] + 2, p[2] + 1, "#ffd86a") end
  finish(c, "r_mena_drum_duel")
end

-- 15 souk_spices: open sacks of red, gold and green, gnome sniffing a pinch
function S.r_mena_souk_spices()
  seed = 25
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#e6c48e")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 38), "#d4aa72") end
  local n = 0
  for x = 5, 68, 4 do
    local col = (n % 2 == 0) and "#3f8fb0" or "#f4eee0"
    fl(c, R(c, x, 5, x + 3, 11), col); fl(c, R(c, x + 1, 12, x + 2, 12), col); n = n + 1
  end
  -- shelf with jars
  part(c, R(c, 8, 26, 66, 27), "#8a5a35")
  for i, x in ipairs({ 14, 24, 34, 44, 54, 62 }) do part(c, R(c, x, 20, x + 3, 25), ({ "#c0442e", "#e8a317", "#6a9a3a", "#c4623a", "#e8a317", "#c0442e" })[i]) ; fl(c, R(c, x, 19, x + 3, 19), "#8a5a35") end
  for _, x in ipairs({ 16, 30, 42, 58 }) do fl(c, R(c, x, 12, x, 18), "#c8a060"); c:px(x, 19, "#dd3a2a") end
  c:fill(R(c, 0, 39, W - 1, H - 1), "#c9a96e"); fl(c, R(c, 0, 39, W - 1, 39), "#d9bc84")
  -- sacks with spice hills
  local function sack(x, col, hi)
    part(c, c:ellipse(x, 36, 8, 5), col, { noline = true })
    c:fill(c:poly({ { x - 7, 40 }, { x, 31 }, { x + 7, 40 } }), col)
    c:outline(c:poly({ { x - 7, 40 }, { x, 31 }, { x + 7, 40 } }))
    c:fill(R(c, x, 33, x + 1, 34), hi)
    part(c, R(c, x - 10, 40, x + 10, 48), "#b8965c")
    fl(c, R(c, x - 10, 40, x + 10, 41), "#d4b880")
    fl(c, R(c, x - 6, 44, x + 6, 44), "#8f7248")
  end
  sack(14, "#c0302a", "#e0705a"); sack(32, "#e8a317", "#f5dc80"); sack(50, "#5e9a3a", "#8fc462")
  -- gnome sniffing a pinch
  gnome(c, 61, 49, { d = -1, eyes = "shut", arms = { arm({ -4, 7 }, { -6, 12 }, true), arm({ 4, 6 }, { 5, 3 }, false) } })
  c:px(56, 33, "#c0302a"); c:px(55, 34, "#c0302a")
  c:px(60, 27, "#c0302a")
  finish(c, "r_mena_souk_spices")
end

-- 16 dune_shapes (dawn): the watch-gnome by the parapet, chalk slate of dune shapes, long shadows
function S.r_mena_dune_shapes()
  seed = 26
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#5a5a98", "#8a6aa4", "#c8708a", "#f0966a", "#f8c488" }, { dir = "v" })
  c:fill(c:ellipse(60, 30, 5, 5), "#fff0b0")
  for _, p in ipairs({ { 9, 8 }, { 20, 12 }, { 36, 7 } }) do c:px(p[1], p[2], "#e8dcd0") end
  -- layered dunes with long shadows
  c:fill(R(c, 0, 29, W - 1, H - 1), "#e8a878")
  local function dune(pts, lit, shade) c:fill(c:poly(pts), shade); end
  c:fill(c:poly({ { 5, 36 }, { 14, 22 }, { 30, 32 }, { 44, 24 }, { 58, 33 }, { 68, 30 }, { 68, 40 }, { 5, 40 } }), "#d4806a")
  c:fill(c:poly({ { 14, 22 }, { 30, 32 }, { 22, 36 }, { 16, 30 } }), "#b45a5a")
  c:fill(c:poly({ { 44, 24 }, { 58, 33 }, { 50, 36 }, { 44, 31 } }), "#b45a5a")
  c:fill(c:poly({ { 5, 44 }, { 24, 34 }, { 44, 42 }, { 68, 36 }, { 68, 49 }, { 5, 49 } }), "#f0c088")
  c:fill(c:poly({ { 24, 34 }, { 44, 42 }, { 30, 44 }, { 24, 40 } }), "#c8806a")
  -- parapet
  part(c, R(c, 5, 40, 68, 49), "#b0a090", { shade = true })
  for x = 6, 66, 10 do part(c, R(c, x, 36, x + 5, 40), "#b0a090") end
  for x = 10, 66, 10 do fl(c, R(c, x, 44, x + 4, 44), "#8a7a6a") end
  -- chalk slate with dune shapes
  part(c, R(c, 40, 30, 54, 39), "#6b3b2a"); fl(c, R(c, 41, 31, 53, 38), "#4a5a64")
  for _, p in ipairs({ { 42, 36 }, { 46, 36 }, { 50, 36 } }) do
    c:px(p[1], p[2], "#f4eee0"); c:px(p[1] + 1, p[2] - 1, "#f4eee0"); c:px(p[1] + 2, p[2], "#f4eee0"); c:px(p[1] + 1, p[2] - 2 + ((p[1] > 44) and 1 or 0), "#f4eee0")
  end
  -- watch-gnome pointing out over the dunes
  gnome(c, 22, 41, { upper = true, d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 11, 12 }, true) } })
  part(c, R(c, 5, 38, 38, 40), "#b0a090", { noline = true })
  fl(c, R(c, 5, 40, 68, 40), "#8a7a6a")
  finish(c, "r_mena_dune_shapes")
end

-- 17 tile_patterns: a wall of sample tile panels, gnome points at one he had never noticed
function S.r_mena_tile_patterns()
  seed = 27
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 42), "#e8d6a6")
  for y = 6, 40, 6 do fl(c, R(c, 0, y, W - 1, y), "#dcc690") end
  local function panel(x0, y0, x1, y1, base)
    part(c, R(c, x0, y0, x1, y1), "#8a5a35")
    fl(c, R(c, x0 + 1, y0 + 1, x1 - 1, y1 - 1), base)
  end
  local function diamond(cx, cy, r, col) fl(c, c:poly({ { cx, cy - r }, { cx + r, cy }, { cx, cy + r }, { cx - r, cy } }), col) end
  -- small panels
  panel(6, 7, 20, 19, "#2f5fa0")
  for _, p in ipairs({ { 10, 11 }, { 16, 11 }, { 10, 16 }, { 16, 16 }, { 13, 13 } }) do diamond(p[1], p[2], 2, "#f4eee0") end
  panel(23, 7, 37, 19, "#2f8fa0")
  for _, p in ipairs({ { 27, 11 }, { 33, 11 }, { 27, 16 }, { 33, 16 } }) do c:paint({ ".g.", "ggg", ".g." }, p[1] - 1, p[2] - 1, { g = "#f5cf6a" }) end
  panel(6, 22, 20, 34, "#c4623a")
  for _, p in ipairs({ { 10, 26 }, { 16, 26 }, { 10, 31 }, { 16, 31 } }) do fl(c, R(c, p[1] - 1, p[2] - 1, p[1] + 1, p[2] + 1), "#2f5fa0"); c:px(p[1], p[2], "#f4eee0") end
  panel(23, 22, 37, 34, "#4f8a52")
  for x = 25, 35, 3 do for y = 24, 32, 3 do c:px(x, y, "#f4eee0"); c:px(x + 1, y + 1, "#e8a317") end end
  -- the big new panel: an eight-point star
  panel(42, 7, 66, 33, "#2f5fa0")
  fl(c, R(c, 47, 12, 61, 26), "#f4eee0"); diamond(54, 19, 10, "#f4eee0")
  fl(c, R(c, 50, 15, 58, 23), "#c4623a"); diamond(54, 19, 7, "#f5cf6a"); fl(c, R(c, 52, 17, 56, 21), "#2f8fa0"); c:px(54, 19, "#f4eee0")
  -- sparkle at the find
  for _, p in ipairs({ { 69, 8 }, { 40, 5 } }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] - 1, p[2], "#f5cf6a"); c:px(p[1] + 1, p[2], "#f5cf6a"); c:px(p[1], p[2] - 1, "#f5cf6a") end
  -- floor and work bench with tiles and a chisel
  c:fill(R(c, 0, 43, W - 1, H - 1), "#b8965c"); fl(c, R(c, 0, 43, W - 1, 43), "#d9bc84")
  for _, p in ipairs({ { 8, 45 }, { 11, 47 }, { 14, 45 } }) do part(c, R(c, p[1], p[2], p[1] + 3, p[2] + 2), ({ "#2f5fa0", "#f5cf6a", "#2f8fa0" })[(p[1] % 3) + 1]) end
  part(c, R(c, 52, 44, 66, 46), "#6b3b2a"); fl(c, R(c, 55, 43, 60, 43), "#aeb4bc"); fl(c, R(c, 53, 42, 54, 43), "#8a5a35")
  gnome(c, 31, 49, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 11, 16 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  finish(c, "r_mena_tile_patterns")
end

-- 18 thump_melons: melon boat at the steps, gnome knocks one with an ear to it
function S.r_mena_thump_melons()
  seed = 28
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#a8d4e0", "#bfe0e0", "#d8ecd8" }, { dir = "v" })
  c:fill(R(c, 0, 22, W - 1, 34), "#4a9ab4"); c:fill(R(c, 0, 22, W - 1, 22), "#7ccfd4")
  for _, p in ipairs({ { 10, 32 }, { 36, 30 }, { 50, 26 } }) do c:fill(R(c, p[1], p[2], p[1] + 3, p[2]), "#8fd4e0") end
  local function melon(x, y, r)
    part(c, c:ellipse(x, y, r, r - 1), "#4e9a48", { shade = true })
    for dx = -r + 2, r - 2, 2 do fl(c, R(c, x + dx, y - r + 2, x + dx, y + r - 3), "#2f6a32") end
  end
  -- melon boat on the river
  part(c, c:poly({ { 6, 24 }, { 30, 24 }, { 27, 31 }, { 9, 31 } }), "#8a5a35")
  fl(c, R(c, 7, 25, 29, 25), "#a8703e")
  melon(12, 21, 4); melon(19, 20, 4); melon(26, 21, 4); melon(16, 16, 4); melon(23, 15, 4)
  -- stone ferry steps
  c:fill(R(c, 0, 35, W - 1, H - 1), "#d8c8a0"); fl(c, R(c, 0, 35, W - 1, 35), "#e8dab4")
  fl(c, R(c, 0, 40, W - 1, 40), "#b8a880"); fl(c, R(c, 0, 45, W - 1, 45), "#b8a880")
  -- mountain of melons
  for _, m in ipairs({ { 50, 46, 5 }, { 59, 46, 5 }, { 67, 46, 4 }, { 54, 39, 5 }, { 63, 39, 5 }, { 58, 32, 5 }, { 42, 47, 4 } }) do melon(m[1], m[2], m[3]) end
  -- gnome knocks the melon: knuckle on the rind, listening
  gnome(c, 24, 48, { d = 1, eyes = "shut", arms = { arm({ 4, 7 }, { 9, 9 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  melon(36, 43, 5)
  fl(c, R(c, 37, 36, 38, 37), "#f5cf6a"); c:px(39, 38, "#f5cf6a"); c:px(35, 37, "#f5cf6a")
  finish(c, "r_mena_thump_melons")
end

-- 19 coolest_jar: three sweating jars in a shady archway, one beaded with cold
function S.r_mena_coolest_jar()
  seed = 29
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#d4a46a")
  for y = 8, 44, 7 do for x = 6 + (y % 14 == 8 and 0 or 5), 68, 10 do fl(c, R(c, x, y, x + 5, y), "#c0925a") end end
  part(c, c:rrect(8, 9, 66, 60, 14), "#8a6a46")
  c:fill(c:rrect(10, 11, 64, 60, 12), "#7a8ca8")
  c:fill(c:rrect(14, 15, 60, 60, 9), "#8a9cb4")
  c:fill(R(c, 5, 44, W - 1, H - 1), "#9a9488"); fl(c, R(c, 10, 44, 64, 44), "#b4aea0")
  for x = 12, 62, 10 do fl(c, R(c, x, 47, x + 4, 47), "#7a7468") end
  -- jars hung by ropes, dripping
  fl(c, R(c, 31, 15, 31, 19), "#c8a060"); fl(c, R(c, 44, 15, 44, 19), "#c8a060"); fl(c, R(c, 57, 15, 57, 19), "#c8a060")
  jar(c, 31, 19, 11, 12, "#c4783a", { rim = "#8a4a2a" })
  jar(c, 44, 19, 11, 12, "#a8c8d4", { rim = "#6a8a98" })
  jar(c, 57, 19, 11, 12, "#c4783a", { rim = "#8a4a2a" })
  for _, p in ipairs({ { 29, 28 }, { 33, 30 }, { 56, 29 }, { 59, 27 } }) do c:px(p[1], p[2], "#8fd4e8") end
  for _, p in ipairs({ { 42, 27 }, { 46, 29 }, { 43, 31 }, { 47, 26 }, { 41, 24 } }) do c:px(p[1], p[2], "#e8f8fc"); c:px(p[1], p[2] + 1, "#8fd4e8") end
  c:px(44, 36, "#8fd4e8"); c:px(44, 38, "#58b4c4"); c:px(31, 36, "#8fd4e8"); c:px(57, 37, "#8fd4e8")
  -- cold sparkles round the best jar
  for _, p in ipairs({ { 38, 20 }, { 51, 33 } }) do c:px(p[1], p[2], "#e8f8fc"); c:px(p[1] - 1, p[2], "#8fd4e8"); c:px(p[1] + 1, p[2], "#8fd4e8"); c:px(p[1], p[2] - 1, "#8fd4e8"); c:px(p[1], p[2] + 1, "#8fd4e8") end
  -- gnome with a hand on the jar, delighted
  gnome(c, 18, 48, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 10, 12 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  finish(c, "r_mena_coolest_jar")
end

-- 20 scarab_dune: a beetle's ball peeking round a dune, gnome shading his eyes to find it
function S.r_mena_scarab_dune()
  seed = 30
  local c = new()
  desert(c, 28, { sun = 20 })
  -- the old tomb on the horizon
  part(c, c:poly({ { 58, 17 }, { 68, 30 }, { 48, 30 } }), "#c8a064"); c:fill(c:poly({ { 58, 17 }, { 68, 30 }, { 60, 30 } }), "#a8804a")
  part(c, R(c, 56, 25, 60, 30), "#3a2a1c", { noline = true })
  -- beetle and ball behind the far dune
  part(c, c:ellipse(52, 40, 4, 4), "#6b4a2a", { shade = true })
  part(c, c:ellipse(58, 42, 2, 1), "#1a3a4a"); c:px(57, 41, "#4a9ab4")
  fl(c, R(c, 57, 43, 57, 44), "#1a1a1a"); fl(c, R(c, 59, 43, 59, 44), "#1a1a1a")
  -- dunes in front
  part(c, c:ellipse(46, 50, 17, 8), "#f0d8a0"); c:fill(c:ellipse(52, 52, 12, 5), "#e0c088")
  part(c, c:ellipse(18, 52, 16, 9), "#f0d8a0"); c:fill(c:ellipse(24, 53, 11, 6), "#e0c088")
  part(c, c:ellipse(64, 51, 10, 6), "#f0d8a0")
  -- tracks in the sand leading round
  for _, p in ipairs({ { 36, 44 }, { 40, 43 }, { 44, 42 }, { 38, 46 }, { 42, 45 } }) do c:px(p[1], p[2], "#c8a064") end
  -- gnome on the near dune, hand shading his eyes
  gnome(c, 20, 44, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 15 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  fl(c, R(c, 27, 24, 28, 25), "#f5cf6a"); c:px(30, 23, "#f5cf6a")
  finish(c, "r_mena_scarab_dune")
end

-- 21 shaduf_swing: long pole, stone counterweight, leather bucket dipping in the river
function S.r_mena_shaduf_swing()
  seed = 31
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#a8d4e0", "#bfe0e0", "#d8ecd0" }, { dir = "v" })
  c:fill(c:ellipse(60, 10, 4, 4), "#fff4c0")
  c:fill(c:ellipse(52, 32, 30, 7), "#6a9a48")
  -- fig trees on the far bank
  for _, p in ipairs({ { 50, 30 }, { 60, 31 }, { 68, 30 } }) do
    part(c, R(c, p[1] - 1, p[2] - 2, p[1], p[2] + 4), "#6b3b2a", { noline = true })
    part(c, c:ellipse(p[1], p[2] - 4, 5, 4), "#4e8a3c", { shade = true })
    c:px(p[1] - 2, p[2] - 3, "#a82a5a"); c:px(p[1] + 2, p[2] - 5, "#a82a5a")
  end
  -- river and banks
  c:fill(R(c, 5, 36, 26, H - 1), "#4a9ab4"); c:fill(R(c, 5, 36, 26, 36), "#7ccfd4")
  c:fill(R(c, 5, 37, 8, H - 1), SAND); c:fill(R(c, 5, 36, 8, 36), SAND2)
  for _, p in ipairs({ { 12, 42 }, { 18, 45 }, { 10, 47 } }) do c:fill(R(c, p[1], p[2], p[1] + 3, p[2]), "#8fd4e0") end
  c:fill(R(c, 27, 38, W - 1, H - 1), SAND); c:fill(R(c, 27, 38, W - 1, 38), SAND2)
  -- irrigation channel receiving a splash
  c:fill(R(c, 44, 44, 68, 46), "#58b4c4"); c:fill(R(c, 44, 44, 68, 44), "#8fd4e0")
  -- shaduf: posts, pole, bucket and stone
  part(c, R(c, 32, 22, 33, 40), "#6b3b2a", { noline = true }); part(c, R(c, 38, 22, 39, 40), "#6b3b2a", { noline = true })
  part(c, c:line({ { 12, 33 }, { 36, 24 }, { 54, 17 } }, 2), "#a8703e")
  part(c, c:ellipse(54, 20, 3, 3), "#8b8f96", { shade = true })
  fl(c, R(c, 12, 34, 12, 38), "#c8a060")
  part(c, R(c, 9, 38, 15, 42), "#8a5a35"); fl(c, R(c, 9, 38, 15, 38), "#4a9ab4")
  -- rope from the stone end, gnome pulling
  fl(c, R(c, 54, 23, 54, 36), "#c8a060")
  gnome(c, 50, 47, { d = -1, eyes = "open", arms = { arm({ -4, 8 }, { -3, 14 }, true), arm({ 4, 8 }, { 4, 12 }, false) } })
  for _, p in ipairs({ { 14, 31 }, { 17, 34 }, { 20, 35 }, { 23, 38 } }) do c:px(p[1], p[2], "#8fd4e8") end
  finish(c, "r_mena_shaduf_swing")
end

-- 22 oven_slap: slapping a round of dough onto the wall of the clay oven
function S.r_mena_oven_slap()
  seed = 32
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 42), "#e2bc86")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 42), "#d4aa72") end
  part(c, c:rrect(8, 8, 20, 22, 4), "#4a6a82"); c:fill(c:rrect(10, 10, 18, 22, 3), "#a8d4e0")
  c:fill(R(c, 0, 43, W - 1, H - 1), "#b8965c"); fl(c, R(c, 0, 43, W - 1, 43), "#d9bc84")
  -- baked flatbreads on a cloth shelf
  part(c, R(c, 50, 12, 66, 13), "#8a5a35")
  for i, x in ipairs({ 52, 56, 60, 64 }) do part(c, c:ellipse(x, 9, 2, 3), "#e8b868"); c:px(x, 8, "#c88a3a") end
  -- the oven: fat clay pot with fire glow and rim
  part(c, R(c, 36, 36, 64, 49), "#c4783a", { shade = true })
  part(c, c:ellipse(50, 36, 14, 4), "#a8602e")
  c:fill(c:ellipse(50, 36, 11, 3), "#2a1a10"); c:fill(c:ellipse(50, 37, 8, 2), "#e0501f"); c:fill(c:ellipse(50, 37, 4, 1), "#ffd86a")
  c:fill(c:rrect(46, 43, 54, 49, 3), "#2a1a10"); c:fill(R(c, 48, 46, 52, 49), "#f08a24")
  for _, x in ipairs({ 40, 60 }) do fl(c, R(c, x, 40, x, 46), "#a8602e") end
  for _, p in ipairs({ { 44, 29 }, { 52, 27 }, { 58, 30 } }) do c:px(p[1], p[2], "#ffb050"); c:px(p[1] + 1, p[2] - 1, "#f08a24") end
  -- gnome with dough on a cushion pad, reaching in
  gnome(c, 22, 49, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 11, 14 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  part(c, c:ellipse(34, 36, 5, 3), "#f0e0b0"); c:px(33, 35, "#fff8e0"); fl(c, R(c, 30, 38, 38, 38), "#a8483a")
  c:px(41, 33, "#f4f8fa"); c:px(40, 31, "#f4f8fa")
  -- flour sack
  part(c, R(c, 6, 40, 12, 48), "#e8dcc0", { shade = true }); fl(c, R(c, 6, 40, 12, 41), "#cfc09a")
  finish(c, "r_mena_oven_slap")
end

-- 23 dune_whispers (night): low fire, the gnome listens, the cooling sand hums
function S.r_mena_dune_whispers()
  seed = 33
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#1e2848", "#2a3558", "#34426a", "#3f5078" }, { dir = "v" })
  for _, p in ipairs({ { 8, 8 }, { 20, 18 }, { 34, 7 }, { 48, 11 }, { 54, 22 }, { 12, 26 }, { 40, 22 }, { 65, 17 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:px(30, 12, "#f4eee0"); c:px(31, 13, "#f4eee0"); c:px(29, 13, "#f4eee0"); c:px(30, 14, "#f4eee0")
  c:fill(c:ellipse(60, 10, 4, 4), "#f5e6a8"); c:fill(c:ellipse(62, 9, 3, 3), "#2a3558")
  -- moonlit dunes
  c:fill(c:ellipse(18, 38, 32, 11), "#4a5a82"); c:fill(c:ellipse(58, 40, 30, 10), "#56668e")
  c:fill(R(c, 0, 38, W - 1, H - 1), "#5a6a92"); c:fill(R(c, 0, 38, W - 1, 38), "#7a8ab0")
  c:fill(c:poly({ { 5, 49 }, { 5, 44 }, { 30, 40 }, { 68, 43 }, { 68, 49 } }), "#4a5880")
  for x = 8, 66, 9 do fl(c, R(c, x, 46 + (x % 2), x + 4, 46 + (x % 2)), "#6a7aa0") end
  -- singing sand: wavy lines rising from the crest
  for i, x in ipairs({ 38, 47, 56, 64 }) do
    for k = 0, 3 do
      local y = 34 - k * 4 - (i % 2) * 3
      local o = (k % 2 == 0) and 0 or 1
      fl(c, R(c, x + o, y, x + o + 1, y + 1), "#8fd4d8")
    end
  end
  -- small fire
  part(c, c:line({ { 38, 48 }, { 52, 46 } }, 2), "#4a2c1a"); part(c, c:line({ { 38, 46 }, { 52, 48 } }, 2), "#6b3b2a")
  flame(c, 45, 46, 7)
  -- gnome seated, cupped hand to the ear
  gnome(c, 22, 44, { d = 1, sit = true, eyes = "shut", arms = { arm({ 3, 9 }, { 1, 13 }, true) } })
  c:fill(c:ellipse(34, 47, 6, 1), "#d08a4a")
  finish(c, "r_mena_dune_whispers")
end

-- 24 cedar_snow (winter): flat-crowned cedars under snow, the keeper warms her hands
function S.r_mena_cedar_snow()
  seed = 34
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#aebfd4", "#bccbdc", "#cad7e4", "#dce6ee" }, { dir = "v" })
  c:fill(c:ellipse(18, 33, 30, 8), "#d3deea"); c:fill(c:ellipse(60, 34, 28, 7), "#dae4ee")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#eef3f6"); c:fill(R(c, 0, 44, W - 1, H - 1), "#e0e9f0")
  -- small sanctuary with an arched door
  part(c, R(c, 28, 22, 44, 36), "#a8a094", { shade = true })
  part(c, R(c, 26, 19, 46, 23), "#8a7a6a"); fl(c, R(c, 27, 17, 45, 19), "#f4f8fa")
  c:fill(c:rrect(34, 27, 38, 36, 2), "#2a1a10"); fl(c, R(c, 35, 31, 37, 33), "#f5cf6a")
  local function cedar(x, yb, sc)
    part(c, R(c, x - 1, yb - 10, x + 1, yb), "#5e3f28", { noline = true })
    for t = 0, 2 do
      local y = yb - 6 - t * 6
      local w = floor((14 - t * 3) * sc)
      part(c, c:ellipse(x, y, w, 3), "#2f5a2a")
      fl(c, c:ellipse(x, y - 1, w - 2, 2), "#f4f8fa")
      for dx = -w + 3, w - 3, 4 do c:px(x + dx, y + 2, "#3f7a3a") end
    end
  end
  cedar(15, 40, 1); cedar(60, 40, 1)
  -- brazier and the gnome warming her hands, scarf on
  gnome(c, 38, 48, { d = 1, eyes = "happy", arms = { arm({ 4, 7 }, { 8, 5 }, true), arm({ -4, 6 }, { 4, 4 }, false) } })
  fl(c, R(c, 34, 38, 41, 38), "#3f8a5a"); fl(c, R(c, 34, 39, 41, 39), "#f4eee0"); fl(c, R(c, 41, 39, 42, 43), "#3f8a5a")
  part(c, R(c, 46, 44, 52, 46), "#3d2a1c"); part(c, R(c, 47, 46, 51, 48), "#3d2a1c", { noline = true })
  fl(c, R(c, 47, 43, 51, 44), "#e0501f"); fl(c, R(c, 48, 42, 50, 43), "#ffd86a"); c:px(49, 41, "#ffd86a")
  puffs(c, 49, 38, 3, "#f4f8fa")
  seed = 41
  for i = 1, 26 do c:px(6 + floor(rand() * 62), 6 + floor(rand() * 40), "#fbfdfe") end
  finish(c, "r_mena_cedar_snow")
end

local order = {}
for l in io.lines("/tmp/claude-0/-home-user-gnome-venture/1b9189c1-3b2f-55fd-a82b-d2ac35c1c228/scratchpad/lists/h11.txt") do if l ~= "" then order[#order + 1] = l end end
for _, s2 in ipairs(order) do
  if S[s2] and (not only or only == s2) then seed = 7; S[s2]() end
end
