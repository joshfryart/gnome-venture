-- variety-act-h20.lua : Do-tab scenes for 20 regional (Oceania) rest-stop activities -> act-<slug>.png (144x108 on a 72x54 grid, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-h20.lua   (params BEFORE --script)
-- Frame copied from the shipped act-hand.png.
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

---------------------------------------------------------------- extra helpers
local function seabands(c, y0, y1, cols) c:bands(R(c, 0, y0, W - 1, y1), cols or { "#6cc4d0", "#58b4c4", "#3f9fb8", "#3590aa" }, { dir = "v" }) end
local function foam(c, y, x0, x1, step, col)
  for x = x0, x1, step or 6 do c:fill(R(c, x, y, x + 2, y), col or "#e8f8f4"); c:px(x + 4, y + 1, col or "#e8f8f4") end
end
local function sandg(c, y0, col, edge)
  c:fill(R(c, 0, y0, W - 1, H - 1), col or "#e8d29a"); c:fill(R(c, 0, y0, W - 1, y0), edge or "#f4e4b0")
  for i = 1, 14 do
    local x, y = floor(rand() * 66) + 3, y0 + 2 + floor(rand() * (H - y0 - 4))
    c:px(x, y, "#d4b878"); c:px(x + 1, y, "#d4b878")
  end
end
local function daysky(c, hz, cloud)
  c:bands(R(c, 0, 0, W - 1, hz), { "#9ad4e6", "#b0e0ea", "#c8ecee" }, { dir = "v" })
  if cloud then c:fill(c:ellipse(cloud, 9, 8, 2), "#f8f4e8"); c:fill(c:ellipse(cloud + 4, 7, 5, 2), "#f8f4e8") end
end
local function palm(c, x, yb, lean, h, nut)
  local tx, ty = x + lean, yb - h
  local tr = c:mask(); tr:add(c:line({ { x, yb }, { x + floor(lean * 0.2), yb - floor(h * 0.5) }, { tx, ty } }, 2))
  part(c, tr, "#8a5a35", { noline = true })
  for i = 3, h - 2, 4 do c:fill(R(c, x + floor(lean * i / h) - 1, yb - i, x + floor(lean * i / h), yb - i), "#6b4226") end
  local fr = c:mask()
  for _, d in ipairs({ { -10, 4 }, { -6, 1 }, { 0, -3 }, { 6, 1 }, { 10, 4 } }) do
    fr:add(c:line({ { tx, ty }, { tx + floor(d[1] / 2), ty - 3 + floor(d[2] / 3) }, { tx + d[1], ty + d[2] } }, 2))
  end
  part(c, fr, "#3f8a42")
  for _, d in ipairs({ { -10, 3 }, { 10, 3 } }) do c:px(tx + d[1], ty + d[2] + 1, "#2f6a32") end
  c:fill(c:line({ { tx - 5, ty - 2 }, { tx - 2, ty - 3 } }, 1), "#6cb04e"); c:fill(c:line({ { tx + 2, ty - 3 }, { tx + 5, ty - 2 } }, 1), "#6cb04e")
  if nut then part(c, c:ellipse(tx - 1, ty + 2, 1, 1), "#5e3f28"); part(c, c:ellipse(tx + 2, ty + 2, 1, 1), "#5e3f28") end
end
local function coco(c, x, y, r, husk)
  part(c, c:ellipse(x, y, r, r), husk or "#8a5a35")
  c:px(x - 1, y - 1, "#b07a45"); c:px(x + 1, y + 1, "#6b3b2a")
end
local function spark(c, x, y, col)
  c:px(x, y, "#fff1c8"); c:px(x - 1, y, col or "#f5cf6a"); c:px(x + 1, y, col or "#f5cf6a"); c:px(x, y - 1, col or "#f5cf6a"); c:px(x, y + 1, col or "#f5cf6a")
end

---------------------------------------------------------------- scenes
-- 1 windpump: red-heart desert, tank, tower with a squealing wheel, gnome oiling the pivot
function S.windpump()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#e8b070", "#f0c488", "#f4d4a0", "#f6e2b8" }, { dir = "v" })
  c:fill(c:ellipse(12, 12, 3, 3), "#fff1c8")
  c:fill(c:poly({ { 0, 34 }, { 0, 30 }, { 8, 28 }, { 14, 26 }, { 34, 26 }, { 40, 30 }, { 48, 34 } }), "#c07a5a")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#c8642e"); c:fill(R(c, 0, 34, W - 1, 34), "#e08a52")
  for _, p in ipairs({ { 8, 44 }, { 20, 49 }, { 40, 48 }, { 64, 47 }, { 30, 40 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#a84a22") end
  -- tank on a stand
  part(c, R(c, 8, 41, 9, 47), "#5e4a3a", { noline = true }); part(c, R(c, 19, 41, 20, 47), "#5e4a3a", { noline = true })
  part(c, c:rrect(6, 31, 22, 41, 2), "#aeb4bc", { shade = true })
  fl(c, R(c, 7, 34, 21, 34), "#8b929c"); fl(c, R(c, 7, 38, 21, 38), "#8b929c")
  fl(c, R(c, 9, 32, 10, 33), "#e8ecf0")
  -- tower
  local tw = c:mask()
  for _, l in ipairs({ { { 46, 47 }, { 51, 22 } }, { { 60, 47 }, { 55, 22 } } }) do tw:add(c:line(l, 1)) end
  for y = 26, 44, 6 do tw:add(c:line({ { 47 + floor((47 - y) * 0.0), y }, { 59, y } }, 1)) end
  tw:add(c:line({ { 46, 44 }, { 58, 32 } }, 1)); tw:add(c:line({ { 60, 44 }, { 48, 32 } }, 1))
  fl(c, tw, "#4a3a2c")
  part(c, R(c, 52, 17, 54, 24), "#4a3a2c", { noline = true })
  -- the wheel and tail
  local wh = c:mask()
  for k = 0, 7 do
    local a = k * math.pi / 4
    wh:add(c:line({ { 53, 14 }, { 53 + rnd(8 * math.cos(a)), 14 + rnd(8 * math.sin(a)) } }, 2))
  end
  part(c, wh, "#c9ced6")
  fl(c, c:ellipse(53, 14, 2, 2), "#6e747c")
  for k = 0, 7 do
    local a = k * math.pi / 4 + 0.4
    c:px(53 + rnd(7 * math.cos(a)), 14 + rnd(7 * math.sin(a)), "#8b929c")
  end
  fl(c, c:line({ { 55, 14 }, { 62, 13 } }, 1), "#4a3a2c")
  part(c, c:poly({ { 60, 9 }, { 66, 9 }, { 65, 15 }, { 60, 14 } }), "#c0442e")
  -- squeal marks
  c:px(64, 20, "#8a4a1a"); c:px(65, 21, "#8a4a1a"); c:px(45, 8, "#8a4a1a"); c:px(44, 9, "#8a4a1a"); c:px(44, 12, "#8a4a1a"); c:px(43, 13, "#8a4a1a")
  -- gnome with an oil can
  local _, G = gnome(c, 34, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 7 }, { 8, 10 }, true, true) } })
  local ox_, oy_ = G.P(8, 10)
  part(c, R(c, ox_ - 1, oy_ - 3, ox_ + 3, oy_ + 2), "#e8c040")
  part(c, c:line({ { ox_ + 3, oy_ - 2 }, { ox_ + 7, oy_ - 5 } }, 1), "#e8c040", { noline = true })
  fl(c, R(c, ox_ - 1, oy_ - 4, ox_ + 1, oy_ - 4), "#8a4a1a")
  fl(c, R(c, ox_ - 2, oy_ - 1, ox_, oy_ + 1), "#f0c8a0")
  c:px(ox_ + 8, oy_ - 3, "#5a4a2a"); c:px(ox_ + 8, oy_ - 1, "#5a4a2a")
  finish(c, "r_oc_windpump")
end

-- 2 turtle_nests: summer beach, a turtle shuffling to the sea, gnome ringing a nest with sticks
function S.turtle_nests()
  local c = new()
  daysky(c, 24)
  c:fill(c:ellipse(60, 11, 4, 4), "#fff1c8")
  seabands(c, 24, 31)
  foam(c, 27, 4, 64, 9); foam(c, 31, 1, 60, 7, "#f4fcf8")
  sandg(c, 32)
  c:fill(c:ellipse(14, 46, 22, 5), "#d9bc84")
  -- the nest and its stick fence
  c:fill(c:ellipse(22, 43, 10, 4), "#c8a468")
  c:fill(c:ellipse(22, 43, 6, 2), "#a8844e")
  for _, e in ipairs({ { 20, 43 }, { 23, 42 }, { 24, 44 } }) do c:fill(c:ellipse(e[1], e[2], 1, 1), "#f8f4e8") end
  local ring = { { 12, 43 }, { 14, 40 }, { 18, 38 }, { 24, 38 }, { 29, 40 }, { 32, 43 }, { 30, 47 }, { 24, 48 }, { 17, 48 }, { 13, 46 } }
  for i, p in ipairs(ring) do
    if i ~= 7 then part(c, R(c, p[1], p[2] - 4, p[1], p[2]), "#8a5a35", { noline = true }); c:px(p[1], p[2] - 4, "#c08a52") end
  end
  c:fill(c:line({ { 12, 40 }, { 18, 35 }, { 24, 35 }, { 29, 37 }, { 32, 40 } }, 1), "#a8703e")
  -- gnome planting the last stick
  local _, G = gnome(c, 38, 48, { d = -1, eyes = "open", arms = { arm({ 4, 6 }, { 5, 3 }, false), arm({ -4, 7 }, { -9, 6 }, true) } })
  local sx, sy = G.P(-9, 6)
  part(c, R(c, sx - 1, sy - 5, sx, sy + 3), "#8a5a35", { noline = true })
  -- the turtle, heading back down to the surf
  c:fill(c:line({ { 60, 36 }, { 53, 38 }, { 47, 38 } }, 1), "#d4b878")
  part(c, c:ellipse(55, 40, 8, 5), "#4e7a3a", { shade = true })
  fl(c, c:ellipse(55, 40, 5, 3), "#6a9a4a")
  fl(c, R(c, 50, 40, 60, 40), "#3f6a32"); fl(c, R(c, 55, 37, 55, 43), "#3f6a32")
  part(c, c:ellipse(65, 38, 3, 2), "#8aaa5a")
  c:px(66, 37, INK)
  part(c, c:ellipse(49, 45, 3, 2), "#8aaa5a"); part(c, c:ellipse(61, 45, 3, 2), "#8aaa5a"); part(c, c:ellipse(49, 35, 2, 1), "#8aaa5a"); part(c, c:ellipse(61, 35, 2, 1), "#8aaa5a")
  finish(c, "r_oc_turtle_nests")
end

-- 3 outrigger_lashing: canoe on the sand, float on booms, gnome tying a red lashing
function S.outrigger_lashing()
  local c = new()
  daysky(c, 24, 50)
  seabands(c, 24, 30)
  foam(c, 27, 6, 66, 10)
  c:fill(c:poly({ { 54, 25 }, { 60, 18 }, { 66, 24 }, { 68, 25 } }), "#4e8a5a")
  sandg(c, 31)
  palm(c, 63, 36, -4, 24, true)
  -- hull
  part(c, c:poly({ { 5, 30 }, { 10, 36 }, { 36, 36 }, { 41, 30 }, { 38, 40 }, { 32, 42 }, { 14, 42 }, { 8, 40 } }), "#a8703e")
  fl(c, R(c, 11, 37, 35, 37), "#d9a660")
  fl(c, R(c, 10, 40, 36, 40), "#8a5a35")
  for x = 14, 32, 6 do c:fill(R(c, x, 36, x, 41), "#6b3b2a") end
  -- float and booms
  for _, bx in ipairs({ 14, 30 }) do part(c, R(c, bx, 41, bx + 1, 46), "#6b4226", { noline = true }) end
  part(c, c:poly({ { 4, 47 }, { 10, 45 }, { 34, 45 }, { 42, 47 }, { 34, 49 }, { 10, 49 } }), "#8a5a35")
  fl(c, R(c, 10, 46, 34, 46), "#b07a45")
  -- lashings
  for _, bx in ipairs({ 14, 30 }) do
    fl(c, R(c, bx - 1, 44, bx + 2, 46), "#e8c48a")
    c:px(bx - 1, 44, "#dd3a2a"); c:px(bx + 1, 45, "#dd3a2a"); c:px(bx, 46, "#dd3a2a"); c:px(bx + 2, 44, "#dd3a2a")
  end
  for _, x in ipairs({ 19, 22, 25 }) do c:px(x, 45, "#6b3b2a") end
  -- loose old lashing hanging off the left boom
  c:fill(c:line({ { 14, 46 }, { 12, 49 }, { 11, 52 } }, 1), "#e8c48a")
  -- gnome pulling the cord tight
  local _, G = gnome(c, 52, 48, { d = -1, eyes = "open", arms = { arm({ 4, 7 }, { 6, 4 }, false), arm({ -4, 6 }, { -9, 3 }, true) } })
  local hx, hy = G.P(-9, 3)
  c:fill(c:line({ { hx, hy }, { 36, 45 }, { 31, 45 } }, 1), "#dd3a2a")
  part(c, c:ellipse(62, 47, 3, 2), "#e8c48a"); c:fill(c:ellipse(62, 47, 1, 1), "#a8703e")
  finish(c, "r_oc_outrigger_lashing")
end

-- 4 taro_pond: flooded patch of heart leaves, gnome with a hoe clearing a muddy channel, frog
function S.taro_pond()
  local c = new()
  daysky(c, 20, 58)
  c:fill(c:ellipse(12, 22, 20, 7), "#4e8a3c"); c:fill(c:ellipse(60, 22, 20, 6), "#5e9a46")
  c:fill(R(c, 0, 21, W - 1, H - 1), "#8a6a46")
  -- orchard trees
  for _, t in ipairs({ { 8, 22 }, { 64, 21 } }) do
    part(c, R(c, t[1] - 1, t[2] - 8, t[1], t[2]), "#6b4a2e", { noline = true })
    part(c, c:ellipse(t[1], t[2] - 11, 6, 5), "#3f8a42", { shade = true })
    c:px(t[1] - 2, t[2] - 10, "#f0c040"); c:px(t[1] + 3, t[2] - 12, "#f0c040")
  end
  -- pond with channel from the mill stream (top-left)
  c:fill(R(c, 0, 23, 9, 26), "#58b4c4"); c:fill(R(c, 0, 23, 9, 23), "#8fd8e0")
  c:fill(c:line({ { 9, 25 }, { 21, 25 }, { 21, 33 } }, 2), "#58b4c4")
  part(c, c:rrect(21, 29, 68, 49, 3), "#6b4a2e")
  c:fill(c:rrect(23, 31, 66, 47, 2), "#58b4c4")
  c:fill(R(c, 25, 33, 30, 33), "#8fd8e0"); c:fill(R(c, 52, 46, 60, 46), "#8fd8e0")
  -- heart-shaped taro leaves
  local function leaf(x, y)
    c:fill(R(c, x, y + 3, x, y + 5), "#3f6a32")
    part(c, c:ellipse(x - 2, y, 2, 2), "#3f8a42"); part(c, c:ellipse(x + 2, y, 2, 2), "#3f8a42")
    c:fill(c:poly({ { x - 4, y }, { x + 4, y }, { x, y + 5 } }), "#4e9a48"); c:px(x, y - 1, "#8fc462")
  end
  for _, p in ipairs({ { 29, 37 }, { 37, 36 }, { 45, 37 }, { 53, 36 }, { 61, 37 }, { 31, 44 }, { 46, 44 } }) do leaf(p[1], p[2]) end
  -- frog on a leaf
  c:fill(c:ellipse(58, 44, 2, 1), "#6cb04e"); c:px(57, 43, "#fbfdfe"); c:px(59, 43, "#fbfdfe"); c:px(57, 44, INK); c:px(59, 44, INK)
  -- gnome with hoe, dragging mud from the channel mouth
  local _, G = gnome(c, 12, 48, { d = 1, eyes = "open", arms = { arm({ 3, 7 }, { 7, 5 }, true), arm({ -3, 7 }, { 4, 9 }, false, true) } })
  c:fill(c:line({ { 17, 36 }, { 16, 43 }, { 19, 48 } }, 1), "#8a5a35")
  part(c, R(c, 19, 47, 22, 49), "#8b929c")
  c:px(22, 46, "#6b4a2e"); c:px(5, 47, "#6b4a2e")
  finish(c, "r_oc_taro_pond")
end

-- 5 husking_race: two gnomes, two stakes with coconuts, husk flying
function S.husking_race()
  local c = new()
  daysky(c, 30)
  palm(c, 8, 33, 5, 18, true); palm(c, 63, 33, -5, 17, true)
  sandg(c, 31, "#e0c888", "#f0dca0")
  -- bunting
  c:fill(c:line({ { 5, 8 }, { 36, 13 }, { 68, 8 } }, 1), "#5e3f28")
  for i, f in ipairs({ { 11, 10 }, { 19, 11 }, { 27, 12 }, { 35, 13 }, { 43, 12 }, { 51, 11 }, { 59, 10 } }) do
    fl(c, c:poly({ { f[1], f[2] + 1 }, { f[1] + 4, f[2] + 1 }, { f[1] + 2, f[2] + 5 } }), ({ "#dd3a2a", "#f5cf6a", "#3f8fb0" })[(i - 1) % 3 + 1])
  end
  -- stakes
  part(c, R(c, 29, 37, 30, 48), "#8a5a35", { noline = true }); part(c, R(c, 41, 37, 42, 48), "#8a5a35", { noline = true })
  c:fill(c:line({ { 29, 37 }, { 29, 33 } }, 1), "#d9a660"); c:fill(c:line({ { 42, 37 }, { 42, 33 } }, 1), "#d9a660")
  -- left nut half peeled, right one barely started
  coco(c, 30, 31, 4, "#8a5a35")
  c:fill(c:ellipse(30, 30, 2, 3), "#f4eee0"); c:px(29, 29, "#fbfdfe"); c:fill(R(c, 26, 33, 27, 35), "#8a5a35")
  coco(c, 41, 31, 4, "#8a5a35")
  c:fill(c:line({ { 38, 28 }, { 36, 25 } }, 1), "#a8703e")
  -- flying husk
  for _, p in ipairs({ { 24, 27 }, { 22, 31 }, { 36, 22 }, { 47, 26 }, { 49, 31 } }) do c:fill(R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#8a5a35"); c:px(p[1] + 1, p[2], "#b07a45") end
  for _, p in ipairs({ { 22, 47 }, { 25, 48 }, { 47, 48 }, { 50, 47 }, { 36, 49 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#8a5a35") end
  gnome(c, 15, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 7 }, { 9, 12 }, true) } })
  gnome(c, 56, 47, { d = -1, hat = "#3f8a8a", eyes = "open", arms = { arm({ 4, 6 }, { 6, 3 }, false), arm({ -4, 6 }, { -10, 8 }, true) } })
  finish(c, "r_oc_husking_race")
end

-- 6 cowrie_knucklebones: verandah, two seated gnomes, five shells in the air
function S.cowrie_knucklebones()
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#c9a96e")
  for x = 3, W - 1, 6 do fl(c, R(c, x, 5, x, 38), "#b8965c") end
  -- thatch eave
  c:fill(R(c, 0, 0, W - 1, 11), "#c8a050")
  for x = 0, W - 1, 3 do c:fill(R(c, x, 11, x + 1, 13 + (x % 2) * 2), "#c8a050"); c:fill(R(c, x, 5, x, 10), "#a8803a") end
  -- doorway and lamp
  part(c, R(c, 28, 16, 44, 38), "#4a2c1a")
  c:fill(R(c, 30, 18, 42, 38), "#3f7a42")
  for x = 31, 41, 3 do fl(c, R(c, x, 18, x, 38), "#2f5a2a") end
  part(c, R(c, 8, 17, 14, 24), "#ffd86a"); c:fill(R(c, 10, 19, 12, 22), "#fff1c8")
  part(c, R(c, 58, 17, 64, 24), "#ffd86a"); c:fill(R(c, 60, 19, 62, 22), "#fff1c8")
  -- verandah floor and steps
  c:fill(R(c, 0, 39, W - 1, 49), "#a8703e")
  for y = 42, 48, 3 do fl(c, R(c, 0, y, W - 1, y), "#8a5a35") end
  fl(c, R(c, 0, 39, W - 1, 39), "#d9a660")
  -- gnomes
  gnome(c, 17, 45, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 7 }, { 8, 10 }, true), arm({ -3, 6 }, { -5, 3 }, false) } })
  gnome(c, 55, 45, { d = -1, sit = true, hat = "#8a4aa0", eyes = "happy", arms = { arm({ -3, 7 }, { -8, 9 }, true), arm({ 3, 6 }, { 5, 3 }, false) } })
  -- the five cowries
  local function cowrie(x, y)
    c:fill(c:ellipse(x, y, 2, 1), "#f8f0dc"); c:px(x, y, "#b88a52"); c:px(x - 2, y, "#d8c8a8"); c:px(x + 2, y, "#d8c8a8")
  end
  for _, p in ipairs({ { 27, 33 }, { 31, 28 }, { 36, 25 }, { 41, 28 }, { 45, 33 } }) do cowrie(p[1], p[2]) end
  cowrie(32, 46); cowrie(39, 47)
  for _, p in ipairs({ { 36, 21 }, { 30, 24 }, { 42, 24 } }) do c:px(p[1], p[2], "#fff1c8") end
  finish(c, "r_oc_cowrie_knucklebones")
end

-- 7 leaf_kites: windy hill, two leaf kites with crossing lines
function S.leaf_kites()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#7cc4e0", "#98d4e6", "#b4e0ea", "#ccecee" }, { dir = "v" })
  c:fill(c:ellipse(60, 20, 8, 2), "#f8f4e8"); c:fill(c:ellipse(10, 16, 7, 2), "#f8f4e8")
  c:fill(c:ellipse(20, 40, 34, 10), "#5e8a44"); c:fill(c:ellipse(62, 42, 26, 8), "#4e8a3c")
  c:fill(R(c, 0, 37, W - 1, H - 1), "#7ea85a"); c:fill(R(c, 0, 37, W - 1, 37), "#9cc070")
  -- breadfruit tree bending in the wind
  part(c, c:line({ { 7, 47 }, { 8, 38 }, { 11, 30 } }, 2), "#6b4a2e", { noline = true })
  part(c, c:ellipse(13, 26, 8, 4), "#3f8a42", { shade = true }); part(c, c:ellipse(8, 29, 5, 3), "#4e9a48", { shade = true })
  c:px(17, 29, "#8fc462")
  -- kite 1 (green leaf) and kite 2 (dried leaf)
  local function kite(x, y, col, vein, tail)
    local k = c:poly({ { x, y - 6 }, { x + 4, y }, { x, y + 6 }, { x - 4, y } })
    part(c, k, col)
    c:fill(R(c, x, y - 5, x, y + 5), vein); c:fill(R(c, x - 3, y, x + 3, y), vein)
    local t = c:line(tail, 1); c:fill(t, vein)
  end
  -- lines first
  c:fill(c:line({ { 29, 33 }, { 40, 22 }, { 50, 12 } }, 1), "#f4eee0")
  c:fill(c:line({ { 61, 37 }, { 46, 22 }, { 30, 11 } }, 1), "#f4eee0")
  kite(50, 11, "#4e8a3c", "#2f5a2a", { { 50, 17 }, { 52, 20 }, { 49, 23 }, { 52, 26 } })
  kite(30, 10, "#c8802a", "#8a4a1a", { { 30, 16 }, { 28, 19 }, { 31, 22 }, { 28, 25 } })
  for _, p in ipairs({ { 52, 20 }, { 49, 23 }, { 28, 19 }, { 31, 22 } }) do fl(c, R(c, p[1] - 1, p[2], p[1] + 1, p[2] + 1), "#dd3a2a") end
  -- gnomes
  gnome(c, 23, 48, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 12 }, true), arm({ -4, 7 }, { 4, 14 }, false) } })
  gnome(c, 58, 48, { d = -1, s = 1, hat = "#3f6fb0", eyes = "open", arms = { arm({ -4, 7 }, { -8, 11 }, true), arm({ 4, 6 }, { 6, 4 }, false) } })
  -- wind streaks and a whirling leaf
  for _, p in ipairs({ { 8, 10 }, { 40, 6 }, { 58, 28 }, { 36, 33 }, { 6, 22 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#fbfdfe") end
  c:px(40, 36, "#4e8a3c"); c:px(41, 35, "#4e8a3c"); c:px(14, 32, "#c8802a")
  finish(c, "r_oc_leaf_kites")
end

-- 8 laugh_off: dawn camp, gnome roaring with laughter at a kookaburra on a gum branch
function S.laugh_off()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#6a5a9a", "#8a6aa4", "#b87ca4", "#e89a8a", "#f4b878", "#f8d890" }, { dir = "v" })
  c:fill(c:ellipse(30, 34, 8, 8), "#fff1c8"); c:fill(c:ellipse(30, 34, 5, 5), "#fff8e0")
  for _, p in ipairs({ { 9, 8 }, { 20, 6 }, { 46, 9 } }) do c:px(p[1], p[2], "#e8e0f0") end
  c:fill(c:ellipse(14, 37, 28, 8), "#5a6a8a"); c:fill(c:ellipse(60, 38, 26, 8), "#4e6a80")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#6a9a52"); c:fill(R(c, 0, 34, W - 1, 34), "#a8c470")
  c:fill(R(c, 0, 40, W - 1, H - 1), "#5e8a44")
  for _, p in ipairs({ { 6, 44 }, { 22, 48 }, { 36, 44 }, { 48, 49 } }) do c:px(p[1], p[2], "#8fc462"); c:px(p[1] + 1, p[2] - 1, "#8fc462") end
  -- tent
  part(c, c:poly({ { 12, 24 }, { 20, 40 }, { 6, 40 } }), "#e8d2a0")
  c:fill(c:poly({ { 12, 30 }, { 15, 40 }, { 9, 40 } }), "#5e3a2a")
  c:fill(R(c, 12, 24, 12, 27), "#c0442e")
  -- gum tree with a pale trunk and the bird
  part(c, R(c, 60, 20, 63, 49), "#e0d8c4")
  fl(c, R(c, 61, 24, 61, 32), "#b8b098"); fl(c, R(c, 62, 38, 62, 44), "#b8b098")
  part(c, c:line({ { 60, 28 }, { 52, 26 }, { 44, 26 } }, 2), "#e0d8c4")
  part(c, c:ellipse(60, 17, 8, 4), "#7a9a6a", { shade = true }); part(c, c:ellipse(66, 22, 4, 3), "#6a8a5a", { shade = true })
  c:px(50, 23, "#7a9a6a"); c:px(49, 22, "#7a9a6a")
  -- kookaburra
  part(c, c:ellipse(49, 21, 4, 5), "#8a5a35")
  c:fill(c:ellipse(49, 22, 2, 3), "#f4eee0")
  part(c, c:ellipse(46, 16, 4, 3), "#f4eee0")
  c:fill(R(c, 43, 15, 45, 15), "#5e3a22"); c:px(46, 15, INK)
  part(c, c:poly({ { 42, 16 }, { 38, 17 }, { 42, 18 } }), "#2a1a10")
  c:fill(c:line({ { 38, 15 }, { 42, 14 } }, 1), "#2a1a10")
  part(c, c:line({ { 53, 24 }, { 56, 29 } }, 2), "#6b4a2e")
  for _, p in ipairs({ { 36, 11 }, { 35, 15 }, { 38, 19 } }) do c:fill(R(c, p[1], p[2], p[1] + 1, p[2]), "#6a3a2a") end
  
  -- gnome laughing it off
  gnome(c, 27, 48, { d = 1, eyes = "happy", arms = { arm({ -4, 6 }, { -7, 11 }, false), arm({ 4, 7 }, { 7, 11 }, true) } })
  c:fill(R(c, 31, 38, 33, 39), "#6a2a2a"); c:px(32, 38, "#f4eee0")
  for _, p in ipairs({ { 36, 33 }, { 37, 37 }, { 17, 30 }, { 19, 34 } }) do c:px(p[1], p[2], "#6a3a2a"); c:px(p[1] + 1, p[2] + 1, "#6a3a2a") end
  finish(c, "r_oc_laugh_off")
end

-- 9 string_figures: seated gnome holds up a diamond of cord, a young one watches
function S.string_figures()
  local c = new()
  daysky(c, 26, 48)
  seabands(c, 26, 31)
  foam(c, 29, 2, 66, 9)
  fl(c, c:poly({ { 56, 24 }, { 62, 24 }, { 59, 15 } }), "#f4eee0"); fl(c, R(c, 55, 25, 63, 26), "#8a5a35")
  sandg(c, 33, "#e8d29a")
  -- little hut on the left
  part(c, R(c, 7, 25, 19, 33), "#b07a45")
  part(c, c:poly({ { 13, 17 }, { 22, 26 }, { 4, 26 } }), "#c8a050")
  c:fill(R(c, 11, 28, 15, 33), "#4a2c1a")
  local _, G = gnome(c, 32, 47, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 9, 7 }, true), arm({ 3, 9 }, { 9, 15 }, true) } })
  local ax, ay = G.P(9, 7); local bx, by = G.P(9, 15)
  ax, ay, bx, by = ax + 1, ay + 1, bx + 1, by + 1
  -- the figure: a diamond of red cord between the two hands
  local mx, my = ax + 8, floor((ay + by) / 2)
  c:fill(c:line({ { ax, ay }, { bx, by } }, 1), "#dd3a2a")
  c:fill(c:line({ { ax, ay }, { mx, my }, { bx, by } }, 1), "#dd3a2a")
  c:fill(c:line({ { ax, ay }, { ax + 4, my }, { bx, by } }, 1), "#dd3a2a")
  c:fill(c:line({ { ax + 4, my - 3 }, { mx - 1, my + 2 } }, 1), "#dd3a2a")
  fl(c, R(c, ax - 1, ay - 1, ax + 1, ay + 1), "#f0c8a0"); fl(c, R(c, bx - 1, by - 1, bx + 1, by + 1), "#f0c8a0")
  -- the young watcher
  gnome(c, 61, 47, { d = -1, sit = true, s = 0.8, hat = "#e8a317", eyes = "happy", arms = { arm({ -3, 6 }, { -5, 11 }, true) } })
  spark(c, mx + 3, my - 7); spark(c, 54, 30, "#fff1c8"); spark(c, 24, 38)
  finish(c, "r_oc_string_figures")
end

-- 10 lagoon_swimmers: gnome floating face-down with a reed snorkel, fish and turtle beneath
function S.lagoon_swimmers()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 22), { "#9ad4e6", "#b0e0ea", "#c8ecee" }, { dir = "v" })
  c:fill(c:ellipse(30, 9, 7, 2), "#f8f4e8")
  c:bands(R(c, 0, 23, W - 1, H - 1), { "#7ad8dc", "#58c4d0", "#3fb0c4", "#2f98b4", "#2a84a4" }, { dir = "v" })
  c:fill(R(c, 0, 23, W - 1, 23), "#d8fafa")
  for x = 14, 66, 9 do c:fill(R(c, x, 23, x + 3, 23), "#fbfdfe") end
  -- sea floor and coral
  c:fill(c:ellipse(30, 53, 34, 5), "#d9bc84"); c:fill(c:ellipse(62, 53, 24, 5), "#c8a468")
  part(c, c:ellipse(22, 47, 3, 3), "#e0627a"); c:fill(c:line({ { 22, 45 }, { 20, 41 } }, 1), "#e0627a"); c:fill(c:line({ { 23, 45 }, { 25, 40 } }, 1), "#e0627a")
  c:fill(c:line({ { 64, 49 }, { 62, 43 } }, 1), "#e89a3a"); c:fill(c:line({ { 62, 49 }, { 58, 45 } }, 1), "#e89a3a"); c:fill(c:line({ { 66, 49 }, { 67, 44 } }, 1), "#e89a3a")
  -- jetty post with the lagoon chart
  part(c, R(c, 6, 6, 9, 49), "#6b4226", { noline = true })
  part(c, R(c, 5, 14, 15, 16), "#a8703e")
  part(c, R(c, 10, 6, 16, 12), "#f4eee0")
  for y = 7, 11, 2 do c:fill(R(c, 11, y, 15, y), "#8fbcc8") end
  c:px(12, 8, "#e87a2a")
  -- gnome floating face down: boots up at the back, blue back at the surface, hat dangling
  part(c, R(c, 20, 20, 21, 24), "#5a3a22"); part(c, R(c, 24, 20, 25, 24), "#5a3a22")
  part(c, c:ellipse(34, 26, 11, 3), "#4a6e9a")
  part(c, c:ellipse(46, 27, 3, 3), "#f0c8a0")
  part(c, c:poly({ { 44, 29 }, { 49, 29 }, { 46, 37 } }), "#c0442e")
  c:fill(c:ellipse(39, 30, 5, 2), "#f4eee0")
  c:fill(c:line({ { 48, 25 }, { 50, 19 }, { 52, 14 } }, 1), "#8a9a5a")
  c:px(46, 27, INK)
  fl(c, R(c, 28, 23, 34, 23), "#fbfdfe"); fl(c, R(c, 40, 23, 45, 23), "#fbfdfe")
  -- fish: clownfish, parrotfish, moorish idol, turtle
  local function fish(x, y, col, st, d)
    part(c, c:ellipse(x, y, 4, 2), col)
    c:fill(c:poly({ { x - 4 * d, y }, { x - 7 * d, y - 2 }, { x - 7 * d, y + 2 } }), col)
    if st then c:fill(R(c, x + d, y - 1, x + d, y + 1), st) end
    c:px(x + 2 * d, y - 1, INK)
  end
  fish(56, 40, "#f07a1a", "#f8f4e8", 1)
  fish(30, 44, "#3fb0a0", "#e8e040", -1)
  fish(64, 31, "#f5e8a0", "#2a1a10", -1)
  part(c, c:ellipse(18, 36, 5, 3), "#4e7a3a"); part(c, c:ellipse(24, 36, 2, 1), "#8aaa5a"); fl(c, R(c, 13, 38, 15, 39), "#8aaa5a")
  c:px(25, 35, INK)
  for _, p in ipairs({ { 36, 36 }, { 52, 47 }, { 44, 45 }, { 14, 30 }, { 60, 36 } }) do c:px(p[1], p[2], "#e8fcfc") end
  finish(c, "r_oc_lagoon_swimmers")
end

-- 11 night_voices: dusk gully, gnome with ear cupped and a list, owl, glowing eyes, lamp
function S.night_voices()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#1c2a44", "#24365a", "#2c4468", "#365474", "#44687e" }, { dir = "v" })
  for _, p in ipairs({ { 10, 8 }, { 24, 6 }, { 50, 9 }, { 40, 14 }, { 62, 20 }, { 30, 20 } }) do c:px(p[1], p[2], "#e8e4f0") end
  c:fill(c:ellipse(40, 11, 4, 4), "#f5e6a8"); c:fill(c:ellipse(42, 10, 3, 3), "#2c4468")
  c:fill(c:ellipse(16, 36, 30, 9), "#1e3a40"); c:fill(c:ellipse(60, 36, 28, 9), "#1a343c")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#2a5a44"); c:fill(R(c, 0, 34, W - 1, 34), "#3a6a50")
  c:fill(R(c, 0, 44, W - 1, H - 1), "#244e3c")
  -- tree ferns
  local function fern(x, yb, h)
    part(c, R(c, x - 1, yb - h, x, yb), "#4a3a2a", { noline = true })
    local fr = c:mask()
    for _, d in ipairs({ { -9, 3 }, { -5, 0 }, { 0, -3 }, { 5, 0 }, { 9, 3 } }) do
      fr:add(c:line({ { x, yb - h }, { x + floor(d[1] / 2), yb - h - 3 + floor(d[2] / 3) }, { x + d[1], yb - h + d[2] } }, 2))
    end
    part(c, fr, "#2f7a4a")
    c:px(x, yb - h - 2, "#6ab070")
  end
  fern(9, 40, 16); fern(66, 40, 12)
  -- owl on a branch (top right)
  part(c, c:line({ { 68, 20 }, { 58, 20 }, { 52, 22 } }, 2), "#4a3a2a")
  part(c, c:ellipse(56, 16, 3, 4), "#8a6a4a")
  c:fill(c:ellipse(56, 17, 2, 2), "#d8c8a0")
  fl(c, R(c, 54, 14, 54, 15), "#fff1a8"); fl(c, R(c, 58, 14, 58, 15), "#fff1a8"); c:px(54, 15, INK); c:px(58, 15, INK)
  c:px(54, 12, "#8a6a4a"); c:px(58, 12, "#8a6a4a")
  -- mist
  for _, m in ipairs({ { 6, 37, 20 }, { 40, 39, 22 }, { 22, 45, 18 }, { 50, 47, 16 } }) do c:fill(c:ellipse(m[1] + m[3] // 2, m[2], m[3] // 2, 1), "#6a8a8e") end
  -- lamp post and its glow
  c:fill(c:ellipse(20, 47, 14, 3), "#3f7a52")
  c:fill(c:ellipse(20, 46, 8, 2), "#5a9a62")
  part(c, R(c, 19, 31, 20, 47), "#3d2a1c", { noline = true })
  part(c, R(c, 17, 24, 22, 31), "#ffd86a", { shade = true, cres = 1 }); c:fill(R(c, 18, 26, 21, 29), "#fff1c8")
  part(c, c:poly({ { 19, 21 }, { 24, 24 }, { 15, 24 } }), "#3d2a1c")
  for _, p in ipairs({ { 14, 27 }, { 25, 27 }, { 13, 33 }, { 26, 33 } }) do c:px(p[1], p[2], "#d8a850") end
  -- gnome on a log, listening, list in hand
  part(c, R(c, 34, 44, 54, 47), "#8a5a35"); fl(c, R(c, 35, 44, 53, 44), "#a8703e")
  local _, G = gnome(c, 44, 43, { d = 1, sit = true, eyes = "open", arms = { arm({ -3, 8 }, { -6, 13 }, false), arm({ 3, 6 }, { 6, 7 }, true) } })
  part(c, R(c, 49, 31, 54, 38), "#f4eee0")
  for y = 33, 37, 2 do fl(c, R(c, 50, y, 53, y), "#8fa4b8") end
  fl(c, R(c, 49, 38, 50, 39), "#f0c8a0")
  -- sound marks by the ear
  c:px(36, 28, "#e8e4f0"); c:px(35, 30, "#e8e4f0"); c:px(37, 31, "#e8e4f0")
  -- glowing eyes in the ferns, fireflies
  for _, p in ipairs({ { 8, 33 }, { 64, 36 } }) do c:px(p[1], p[2], "#fff1a8"); c:px(p[1] + 2, p[2], "#fff1a8") end
  for _, p in ipairs({ { 30, 30 }, { 38, 38 }, { 62, 28 }, { 12, 22 }, { 28, 40 } }) do c:px(p[1], p[2], "#d8f08a") end
  finish(c, "r_oc_night_voices")
end

-- 12 sloshing_coconut: gnome shakes a green coconut at his ear at a market stall
function S.sloshing_coconut()
  local c = new()
  daysky(c, 36, 12)
  c:fill(c:ellipse(14, 38, 26, 7), "#5e8a44"); c:fill(R(c, 0, 36, W - 1, H - 1), "#e0c888"); c:fill(R(c, 0, 36, W - 1, 36), "#f0dca0")
  -- stall: posts, awning, counter
  part(c, R(c, 31, 14, 32, 46), "#8a5a35", { noline = true }); part(c, R(c, 66, 14, 67, 46), "#8a5a35", { noline = true })
  local n = 0
  for x = 28, 67, 4 do
    local col = (n % 2 == 0) and "#d8a82a" or "#f4eee0"
    fl(c, R(c, x, 8, x + 3, 13), col); fl(c, R(c, x, 14, x + 3, 14), col); fl(c, R(c, x + 1, 15, x + 2, 15), col)
    n = n + 1
  end
  c:outline(R(c, 28, 8, 67, 15))
  part(c, R(c, 29, 38, 68, 48), "#b07a45")
  fl(c, R(c, 29, 38, 68, 39), "#d9a660")
  for _, x in ipairs({ 40, 52, 62 }) do fl(c, R(c, x, 41, x, 47), "#8a4f2a") end
  -- stallholder behind, grinning
  gnome(c, 58, 38, { d = -1, upper = true, hat = "#8a4aa0", eyes = "happy", arms = { arm({ -4, 5 }, { -8, 4 }, true) } })
  -- hanging bananas
  fl(c, R(c, 36, 15, 36, 18), "#6b4a2e")
  for i = 0, 3 do part(c, c:ellipse(35 + i, 21 + (i % 2), 1, 2), "#f0d040", { noline = true }) end
  c:fill(c:poly({ { 33, 18 }, { 39, 18 }, { 38, 22 }, { 34, 22 } }), "#f0d040")
  -- the other three green coconuts on the counter
  local function gc(x, y) part(c, c:ellipse(x, y, 3, 3), "#6cb04e", { shade = true }); c:px(x - 1, y - 1, "#a8d878"); c:px(x, y - 3, "#4e8a3c") end
  gc(38, 36); gc(46, 37); gc(53, 37)
  -- customer shaking one by his ear
  local _, G = gnome(c, 18, 47, { d = 1, eyes = "shut", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 8, 14 }, true, true) } })
  local hx, hy = G.P(8, 14)
  gc(hx + 1, hy - 1)
  fl(c, R(c, hx - 1, hy, hx + 1, hy + 2), "#f0c8a0")
  -- sloshing motion and drops
  fl(c, R(c, hx + 5, hy - 3, hx + 5, hy + 1), "#fbfdfe"); fl(c, R(c, hx + 7, hy - 4, hx + 7, hy), "#fbfdfe"); fl(c, R(c, hx + 9, hy - 3, hx + 9, hy + 1), "#fbfdfe")
  c:px(hx - 3, hy - 4, "#a8e6f0"); c:px(hx + 4, hy - 7, "#a8e6f0"); c:px(hx, hy + 5, "#a8e6f0")
  finish(c, "r_oc_sloshing_coconut")
end

-- 13 crab_holes: gnome points, row of burrows, one crab at home
function S.crab_holes()
  local c = new()
  daysky(c, 22, 20)
  seabands(c, 22, 28)
  foam(c, 25, 4, 64, 9); foam(c, 28, 1, 60, 7, "#f4fcf8")
  sandg(c, 29)
  c:fill(c:ellipse(40, 47, 34, 4), "#d9bc84")
  palm(c, 63, 34, -3, 20, true)
  -- row of ghost-crab burrows
  local function hole(x, y)
    c:fill(c:ellipse(x, y, 5, 2), "#c8a468")
    part(c, c:ellipse(x, y, 3, 1), "#3a2418", { noline = true })
    c:fill(R(c, x - 3, y + 1, x + 3, y + 1), "#b8965c")
  end
  local hs = { { 22, 42 }, { 32, 45 }, { 42, 42 }, { 52, 45 }, { 61, 42 } }
  for _, h in ipairs(hs) do hole(h[1], h[2]) end
  -- the crab at home (4th burrow)
  c:fill(R(c, 51, 41, 51, 43), "#f0d0a0"); c:fill(R(c, 54, 41, 54, 43), "#f0d0a0")
  c:px(51, 40, INK); c:px(54, 40, INK)
  part(c, c:ellipse(52, 44, 3, 1), "#f0c090", { noline = true })
  c:fill(R(c, 48, 42, 49, 44), "#e08a52"); c:fill(R(c, 56, 42, 57, 44), "#e08a52"); c:px(48, 41, "#e08a52"); c:px(57, 41, "#e08a52")
  -- shell stakes pile
  for _, p in ipairs({ { 8, 47 }, { 11, 48 }, { 14, 47 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#f8f0dc", { noline = true }); c:px(p[1], p[2], "#e8a8b0") end
  gnome(c, 14, 40, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 10, 4 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  c:fill(R(c, 27, 36, 28, 37), "#f0c8a0")
  for _, p in ipairs({ { 54, 35 }, { 24, 36 } }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] - 1, p[2], "#f5cf6a"); c:px(p[1] + 1, p[2], "#f5cf6a") end
  finish(c, "r_oc_crab_holes")
end

-- 14 thorny_devil: red desert, spinifex, a well-camouflaged spiky lizard
function S.thorny_devil()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#f0b878", "#f4c890", "#f6d8a8", "#f8e6c0" }, { dir = "v" })
  c:fill(c:ellipse(60, 11, 4, 4), "#fff1c8")
  c:fill(c:poly({ { 0, 31 }, { 0, 26 }, { 10, 22 }, { 24, 22 }, { 32, 26 }, { 38, 31 } }), "#b86a4a")
  c:fill(c:poly({ { 40, 31 }, { 50, 28 }, { 62, 27 }, { 72, 29 }, { 72, 31 } }), "#c07a52")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#cc6a30"); c:fill(R(c, 0, 31, W - 1, 31), "#e08a52")
  for _, p in ipairs({ { 6, 44 }, { 30, 49 }, { 62, 49 }, { 44, 36 }, { 14, 36 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#a84a22") end
  -- tent at the left
  part(c, c:poly({ { 14, 26 }, { 22, 38 }, { 7, 38 } }), "#e8d2a0"); c:fill(c:poly({ { 14, 31 }, { 17, 38 }, { 11, 38 } }), "#5e3a2a")
  -- spinifex tussocks
  local function tussock(x, y, r)
    local m = c:mask()
    for k = -r, r, 1 do
      m:add(c:line({ { x, y }, { x + k, y - r + math.abs(k) // 2 } }, 1))
    end
    fl(c, m, "#c8b45a")
    c:fill(c:ellipse(x, y, r, 1), "#a89a44")
    c:px(x, y - r, "#e8d888"); c:px(x - r, y - r // 2, "#e8d888")
  end
  tussock(62, 42, 5); tussock(32, 38, 4); tussock(66, 48, 4); tussock(52, 36, 4); tussock(36, 47, 4)
  -- the thorny devil, sitting still on the sand beside the front tussock
  part(c, c:ellipse(50, 44, 7, 3), "#d9a050")
  c:fill(c:ellipse(49, 45, 5, 1), "#f0c080")
  for _, x in ipairs({ 45, 48, 51, 54 }) do c:px(x, 41, "#8a4a2a"); c:px(x, 40, "#8a4a2a"); c:px(x + 1, 41, "#8a4a2a") end
  for _, x in ipairs({ 46, 49, 52 }) do c:px(x, 43, "#8a4a2a") end
  part(c, c:ellipse(57, 43, 3, 2), "#d9a050"); c:px(58, 42, INK); c:px(56, 40, "#8a4a2a"); c:px(58, 40, "#8a4a2a"); c:px(56, 41, "#8a4a2a"); c:px(58, 41, "#8a4a2a")
  for _, x in ipairs({ 46, 49, 53, 56 }) do c:fill(R(c, x, 46, x, 47), "#b86a30") end
  c:fill(c:line({ { 43, 44 }, { 39, 46 }, { 37, 45 } }, 1), "#c07a3a")
  tussock(46, 49, 4)
  -- gnome peering, hand up to shade the eyes
  gnome(c, 24, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 9, 6 }, true) } })
  c:fill(c:line({ { 33, 41 }, { 38, 42 } }, 1), "#f0c8a0")
  c:px(52, 33, "#fff1c8")
  finish(c, "r_oc_thorny_devil")
end

-- 15 macadamia_crack: workshop wall of tools, gnome lifting a stone over a nut in a stump hollow
function S.macadamia_crack()
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#a8703e")
  for x = 3, W - 1, 8 do fl(c, R(c, x, 5, x, 38), "#8a5a35") end
  fl(c, R(c, 0, 10, W - 1, 10), "#8a5a35")
  c:fill(R(c, 0, 39, W - 1, H - 1), "#c9a96e"); fl(c, R(c, 0, 39, W - 1, 39), "#8a5a35")
  for _, p in ipairs({ { 6, 44 }, { 20, 48 }, { 52, 46 }, { 64, 48 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#b8965c") end
  -- tools on the wall: saw, hammer, pliers, rope coil
  c:fill(c:poly({ { 10, 14 }, { 24, 17 }, { 24, 20 }, { 10, 17 } }), "#aeb4bc"); c:outline(c:poly({ { 10, 14 }, { 24, 17 }, { 24, 20 }, { 10, 17 } }))
  part(c, R(c, 24, 15, 28, 20), "#6b3b2a")
  part(c, R(c, 40, 14, 41, 24), "#6b3b2a"); part(c, R(c, 38, 13, 44, 16), "#8b929c")
  part(c, c:ellipse(56, 18, 4, 4), "#e0c88a"); c:fill(c:ellipse(56, 18, 2, 2), "#a8703e")
  part(c, c:line({ { 8, 25 }, { 12, 31 } }, 1), "#8b929c"); part(c, c:line({ { 14, 25 }, { 10, 31 } }, 1), "#8b929c")
  -- stump anvil with hollow and nut
  part(c, R(c, 8, 40, 26, 48), "#8a5a35")
  fl(c, R(c, 12, 42, 12, 47), "#5e2f1e"); fl(c, R(c, 20, 42, 20, 47), "#5e2f1e")
  part(c, c:ellipse(17, 40, 9, 3), "#d9a660")
  c:fill(c:ellipse(17, 40, 3, 1), "#4a2c1a")
  part(c, c:ellipse(17, 38, 2, 2), "#d9b078"); c:px(16, 37, "#f4e0b0")
  -- gnome with raised stone
  local _, G = gnome(c, 38, 47, { d = -1, eyes = "open", arms = { arm({ 4, 6 }, { 5, 3 }, false), arm({ -4, 8 }, { -9, 15 }, true, true) } })
  local sx, sy = G.P(-9, 15)
  part(c, c:ellipse(sx - 1, sy - 2, 4, 3), "#8b8f96", { shade = true })
  fl(c, R(c, sx - 1, sy, sx + 1, sy + 2), "#f0c8a0")
  -- impact lines
  for _, p in ipairs({ { 12, 33 }, { 22, 33 }, { 17, 31 } }) do c:px(p[1], p[2], "#fff1c8") end
  -- sack of nuts and loose shells
  part(c, c:rrect(52, 38, 62, 48, 3), "#d8c090"); fl(c, R(c, 55, 38, 59, 39), "#8a5a35")
  for _, p in ipairs({ { 57, 42 }, { 55, 45 }, { 59, 45 } }) do c:fill(c:ellipse(p[1], p[2], 1, 1), "#8a5a35") end
  part(c, c:ellipse(65, 47, 2, 2), "#d9b078"); part(c, c:ellipse(30, 48, 1, 1), "#d9b078")
  finish(c, "r_oc_macadamia_crack")
end

-- 16 reef_gap: gnome paddles the outrigger toward the one gap in the surf
function S.reef_gap()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 21), { "#7cc0dc", "#90cce4", "#a8d8e8", "#b8e0ec" }, { dir = "v" })
  c:fill(c:ellipse(14, 8, 8, 2), "#f8f4e8")
  seabands(c, 22, 49, { "#3590aa", "#3f9fb8", "#58b4c4", "#6cc4d0", "#58b4c4", "#3f9fb8" })
  -- reef walls of surf left and right, open water in the gap
  c:fill(R(c, 0, 22, W - 1, 22), "#2a86a8")
  local function surf(x0, x1)
    for x = x0, x1, 5 do part(c, c:ellipse(x + 1, 21, 3, 2), "#5a7a80", { noline = true }) end
    local n = 0
    for x = x0, x1, 4 do
      local h = 3 + ((n * 7) % 3)
      c:fill(c:ellipse(x, 25 - h // 2, 4, h - 1), "#e8f8f4"); n = n + 1
    end
    c:fill(R(c, x0 - 2, 25, x1 + 2, 27), "#e8f8f4")
    c:fill(R(c, x0, 28, x1, 28), "#9ad8e6")
    for x = x0 + 2, x1 - 2, 6 do c:px(x, 18, "#e8f8f4"); c:px(x + 1, 19, "#e8f8f4"); c:px(x - 1, 19, "#e8f8f4") end
  end
  surf(6, 29); surf(49, 66)
  for _, w in ipairs({ { 6, 32, 28 }, { 9, 35, 25 }, { 50, 32, 66 }, { 54, 35, 64 } }) do
    c:fill(R(c, w[1], w[2], w[3], w[2]), "#e8f8f4"); c:fill(R(c, w[1] + 2, w[2] + 1, w[3] - 3, w[2] + 1), "#9ad8e6")
  end
  for _, p2 in ipairs({ { 36, 24 }, { 40, 26 }, { 34, 29 }, { 42, 30 }, { 38, 33 } }) do c:fill(R(c, p2[1], p2[2], p2[1] + 2, p2[2]), "#8fd0e0") end
  -- outrigger canoe with a paddling gnome, heading for the gap
  part(c, R(c, 11, 42, 12, 47), "#6b4226", { noline = true }); part(c, R(c, 21, 42, 22, 47), "#6b4226", { noline = true })
  part(c, c:poly({ { 6, 48 }, { 10, 46 }, { 24, 46 }, { 28, 48 }, { 24, 50 }, { 10, 50 } }), "#8a5a35")
  local _, G = gnome(c, 21, 42, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 7 }, { 8, 5 }, true), arm({ -3, 7 }, { -5, 3 }, false) } })
  c:fill(c:line({ { 31, 36 }, { 28, 42 }, { 26, 49 } }, 2), "#a8703e")
  part(c, c:ellipse(26, 50, 2, 3), "#a8703e")
  part(c, c:poly({ { 12, 41 }, { 17, 46 }, { 33, 46 }, { 39, 42 }, { 42, 38 }, { 38, 42 }, { 17, 42 } }), "#a8703e")
  c:fill(R(c, 18, 42, 36, 42), "#d9a660")
  c:fill(R(c, 18, 47, 36, 47), "#e8f8f4"); c:fill(R(c, 22, 48, 34, 48), "#9ad8e6")
  for _, p in ipairs({ { 38, 46 }, { 44, 44 }, { 5, 44 }, { 38, 49 } }) do c:px(p[1], p[2], "#e8f8f4"); c:px(p[1] + 1, p[2], "#e8f8f4") end
  finish(c, "r_oc_reef_gap")
end

-- 17 watcher_tales: the great stone heads on a sunny hill, gnome leaning on the slope telling stories
function S.watcher_tales()
  local c = new()
  daysky(c, 30, 14)
  c:fill(c:ellipse(18, 38, 40, 12), "#6a9a4a")
  c:fill(c:ellipse(56, 36, 36, 12), "#5e8a44")
  c:fill(R(c, 0, 40, W - 1, H - 1), "#7ea85a"); c:fill(R(c, 0, 40, W - 1, 40), "#9cc070")
  for _, p in ipairs({ { 8, 44 }, { 30, 48 }, { 52, 47 }, { 64, 44 } }) do c:px(p[1], p[2], "#5e8a44"); c:px(p[1] + 1, p[2] - 1, "#5e8a44") end
  -- the stone heads
  local function head(x, yb, w, h, face)
    local t = yb - h
    part(c, R(c, x - w // 2, t, x + w // 2, yb), "#8b8f96", { shade = true })
    fl(c, R(c, x - w // 2 + 1, t + 1, x - w // 2 + 1, yb - 2), "#a8aeb4")
    if face then
      local b = t + h * 3 // 10
      fl(c, R(c, x - w // 2, b, x + w // 2, b), "#b8bec6")
      fl(c, R(c, x - w // 2, b + 1, x + w // 2, b + 2), "#363a42")
      fl(c, R(c, x, b + 1, x, b + h * 3 // 10), "#b8bec6"); fl(c, R(c, x - 1, b + 3, x + 1, b + h * 3 // 10), "#a8aeb4"); fl(c, R(c, x + 1, b + 3, x + 1, b + h * 3 // 10), "#5a5e66")
      fl(c, R(c, x - w // 2 + 2, b + h * 6 // 10, x + w // 2 - 2, b + h * 6 // 10), "#363a42")
    end
  end
    head(31, 42, 8, 22, true); head(46, 42, 8, 17, true); head(59, 42, 5, 9, false)
  -- the gull nesting on the little one
  part(c, R(c, 56, 29, 61, 31), "#c8a050")
  part(c, c:ellipse(59, 28, 3, 2), "#f4eee0"); c:px(61, 27, "#f0a020"); c:px(58, 27, INK)
  -- storyteller sprawled against the slope
  c:fill(c:ellipse(12, 44, 12, 5), "#5e8a44"); c:fill(c:ellipse(12, 43, 8, 3), "#6a9a4a")
  gnome(c, 16, 47, { d = 1, sit = true, eyes = "happy", arms = { arm({ 3, 8 }, { 9, 14 }, true), arm({ -3, 7 }, { -5, 4 }, false) } })
  for _, p in ipairs({ { 28, 24 }, { 38, 20 }, { 52, 22 } }) do c:px(p[1], p[2], "#fff1c8") end
  finish(c, "r_oc_watcher_tales")
end

-- 18 jelly_queen: storm over the bay, gnome tips his hat from the jetty to the crowned jelly
function S.jelly_queen()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#2e3848", "#3a4658", "#4a566a", "#5e6c80" }, { dir = "v" })
  c:fill(c:ellipse(18, 9, 14, 4), "#3a4658"); c:fill(c:ellipse(50, 7, 16, 4), "#2e3848"); c:fill(c:ellipse(66, 12, 10, 3), "#4a566a")
  c:bands(R(c, 0, 29, W - 1, H - 1), { "#2f5a6e", "#2a4e66", "#24405a", "#1e3450" }, { dir = "v" })
  c:fill(R(c, 0, 29, W - 1, 29), "#6a8aa0")
  foam(c, 31, 30, 66, 7, "#8aaabc")
  -- lightning
  c:fill(c:line({ { 62, 12 }, { 58, 19 }, { 61, 19 }, { 56, 27 } }, 1), "#f5e6a8")
  -- jetty
  part(c, R(c, 0, 33, 30, 35), "#8a5a35"); fl(c, R(c, 0, 33, 30, 33), "#a8703e")
  for _, x in ipairs({ 4, 14, 26 }) do part(c, R(c, x, 35, x + 1, 49), "#5e3a22", { noline = true }) end
  -- vinegar bottle on a nail
  fl(c, R(c, 26, 36, 27, 36), "#aeb4bc")
  part(c, R(c, 26, 37, 28, 41), "#3f8a52", { noline = true }); fl(c, R(c, 27, 36, 27, 37), "#6b4a2e")
  -- the Queen, glowing, with a gold crown and trailing veils
  for _, x in ipairs({ 44, 47, 50, 53, 56, 59 }) do c:fill(c:line({ { x, 41 }, { x - 1, 44 }, { x + 1, 47 }, { x, 50 } }, 1), "#a8d8e8") end
  c:fill(c:ellipse(51, 36, 11, 8), "#7ac8d8")
  part(c, c:ellipse(51, 36, 9, 6):clip(R(c, 0, 0, W, 40)), "#c8f0f0")
  c:fill(c:ellipse(51, 37, 5, 3), "#f0b0d0")
  c:fill(c:ellipse(48, 34, 2, 1), "#fbfdfe")
  c:px(48, 37, INK); c:px(53, 37, INK)
  part(c, c:poly({ { 46, 30 }, { 56, 30 }, { 56, 26 }, { 54, 28 }, { 51, 25 }, { 48, 28 }, { 46, 26 } }), "#f5cf6a")
  c:px(51, 29, "#dd3a2a")
  -- courtiers
  for _, p in ipairs({ { 36, 44, 3 }, { 66, 43, 3 }, { 40, 38, 2 } }) do
    c:fill(c:ellipse(p[1], p[2], p[3], p[3] - 1), "#7ac8d8"); c:px(p[1] - 1, p[2] - 1, "#c8f0f0")
    c:fill(R(c, p[1] - 1, p[2] + 2, p[1] - 1, p[2] + 4), "#a8d8e8"); c:fill(R(c, p[1] + 1, p[2] + 2, p[1] + 1, p[2] + 4), "#a8d8e8")
  end
  -- gnome tipping his hat
  gnome(c, 18, 33, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 5, 16 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  -- rain
  seed = 77
  for i = 1, 34 do
    local x, y = 6 + floor(rand() * 62), 5 + floor(rand() * 44)
    c:px(x, y, "#a8bcd0"); c:px(x - 1, y + 1, "#a8bcd0")
  end
  finish(c, "r_oc_jelly_queen")
end

-- 19 red_rock_tales: sunset on the great red rock, two gnomes by a small fire, one telling
function S.red_rock_tales()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#4a3a78", "#6a3f82", "#9a4a84", "#c8587a", "#e8784e", "#f4a050" }, { dir = "v" })
  for _, p in ipairs({ { 8, 7 }, { 20, 10 }, { 54, 8 }, { 64, 14 }, { 38, 6 } }) do c:px(p[1], p[2], "#e8d8f0") end
  -- the rock
  local rock = c:poly({ { 4, 36 }, { 8, 28 }, { 18, 23 }, { 34, 21 }, { 50, 22 }, { 62, 26 }, { 68, 33 }, { 68, 37 }, { 4, 37 } })
  c:fill(rock, "#c8402a")
  c:fill(rock:clip(R(c, 0, 0, W, 25)), "#e86030")
  c:fill(c:line({ { 10, 28 }, { 20, 24 }, { 34, 22 } }, 1), "#f89a3a")
  for _, x in ipairs({ 16, 24, 33, 44, 54 }) do c:fill(R(c, x, 28, x, 36), "#9a2a22") end
  c:fill(R(c, 4, 34, 68, 37), "#8a2a24")
  c:fill(R(c, 0, 37, W - 1, H - 1), "#6a3040"); c:fill(R(c, 0, 37, W - 1, 37), "#8a4048")
  c:fill(R(c, 0, 44, W - 1, H - 1), "#5a2a3a")
  for _, p in ipairs({ { 10, 42 }, { 58, 41 }, { 30, 49 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#8a4a52") end
  -- fire between them
  part(c, c:line({ { 32, 47 }, { 42, 45 } }, 2), "#5e3a2a"); part(c, c:line({ { 32, 45 }, { 42, 47 } }, 2), "#7a4a2a")
  part(c, c:poly({ { 37, 35 }, { 41, 42 }, { 42, 46 }, { 32, 46 }, { 33, 42 } }), "#e0501f")
  c:fill(c:poly({ { 37, 39 }, { 39, 43 }, { 40, 46 }, { 34, 46 }, { 35, 43 } }), "#ffd86a")
  c:px(33, 33, "#f08a24"); c:px(41, 32, "#ffd86a")
  -- telling gnome, arms wide; listener on the other side
  gnome(c, 17, 47, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 9, 15 }, true), arm({ -3, 8 }, { -8, 14 }, false) } })
  gnome(c, 57, 47, { d = -1, sit = true, hat = "#3f6fb0", eyes = "open", arms = { arm({ -3, 6 }, { -6, 3 }, true) } })
  finish(c, "r_oc_red_rock_tales")
end

-- 20 palm_hammock: gnome asleep in a hammock slung between two leaning palms
function S.palm_hammock()
  local c = new()
  daysky(c, 24, 54)
  c:fill(c:ellipse(14, 9, 4, 4), "#fff1c8")
  seabands(c, 24, 30)
  foam(c, 27, 4, 64, 9)
  sandg(c, 31)
  c:fill(c:ellipse(40, 47, 34, 4), "#d9bc84")
  palm(c, 11, 48, 6, 36, true); palm(c, 62, 48, -6, 36, true)
  -- hammock cords and sag
  c:fill(c:line({ { 17, 18 }, { 20, 30 }, { 26, 36 } }, 1), "#e8c48a")
  c:fill(c:line({ { 56, 18 }, { 53, 30 }, { 47, 36 } }, 1), "#e8c48a")
  c:fill(c:line({ { 14, 22 }, { 22, 36 } }, 1), "#e8c48a"); c:fill(c:line({ { 58, 22 }, { 50, 36 } }, 1), "#e8c48a")
  local hm = c:mask()
  hm:add(c:line({ { 21, 35 }, { 27, 41 }, { 36, 43 }, { 45, 41 }, { 51, 35 } }, 3))
  part(c, hm, "#e0a24a")
  fl(c, c:line({ { 22, 35 }, { 28, 40 }, { 36, 42 }, { 44, 40 }, { 50, 35 } }, 1), "#f0c070")
  -- gnome lying in it: boots, body, beard on the chest, face, hat tip trailing
  part(c, c:ellipse(39, 37, 8, 3), "#4a6e9a")
  part(c, R(c, 46, 33, 50, 38), "#5a3a22")
  part(c, c:ellipse(34, 38, 4, 2), "#f4eee0")
  part(c, c:ellipse(29, 36, 3, 3), "#f0c8a0")
  c:px(29, 36, "#8a4a34"); c:px(30, 36, "#8a4a34")
  part(c, c:poly({ { 27, 32 }, { 27, 38 }, { 15, 40 } }), "#c0442e")
  fl(c, R(c, 27, 32, 27, 38), "#8e2e1e")
  fl(c, R(c, 27, 27, 29, 27), "#fbfdfe"); c:px(28, 28, "#fbfdfe"); fl(c, R(c, 27, 29, 29, 29), "#fbfdfe")
  fl(c, R(c, 32, 22, 33, 22), "#fbfdfe"); c:px(32, 23, "#fbfdfe"); fl(c, R(c, 32, 24, 33, 24), "#fbfdfe")
  part(c, c:ellipse(40, 47, 3, 2), "#6cb04e"); fl(c, R(c, 42, 41, 42, 46), "#dd3a2a")
  finish(c, "r_oc_palm_hammock")
end

local order = {
  "r_oc_windpump", "r_oc_turtle_nests", "r_oc_outrigger_lashing", "r_oc_taro_pond", "r_oc_husking_race", "r_oc_cowrie_knucklebones",
  "r_oc_leaf_kites", "r_oc_laugh_off", "r_oc_string_figures", "r_oc_lagoon_swimmers", "r_oc_night_voices", "r_oc_sloshing_coconut",
  "r_oc_crab_holes", "r_oc_thorny_devil", "r_oc_macadamia_crack", "r_oc_reef_gap", "r_oc_watcher_tales", "r_oc_jelly_queen",
  "r_oc_red_rock_tales", "r_oc_palm_hammock",
}
for i, s2 in ipairs(order) do
  local fn = S[s2:gsub("^r_oc_", "")]
  if (not only or only == s2) and fn then seed = 7 + i * 13; fn() end
end
