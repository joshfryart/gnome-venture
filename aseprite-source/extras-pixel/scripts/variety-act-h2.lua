-- variety-act-h2.lua : regional rest-stop scenes -> act-<slug>.png (144x108 on a 72x54 grid, out=2). Params: out=<dir>/ only=<slug>
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


local function arm(a, b, front, nohand) return { a = a, b = b, front = front, nohand = nohand } end

---------------------------------------------------------------- extra helpers
local function spark(c, x, y, a, b)
  a = a or "#fff1c8"; b = b or "#f5cf6a"
  c:px(x, y, a); c:px(x - 1, y, b); c:px(x + 1, y, b); c:px(x, y - 1, b); c:px(x, y + 1, b)
end
local function puff(c, x, y, rx, col)
  c:fill(c:ellipse(x, y, rx or 2, 1), col or "#f4f8fa")
end
local function rain(c, n, y0, y1, col, sd)
  seed = sd or 5
  for i = 1, n do
    local x, y = 6 + floor(rand() * 62), y0 + floor(rand() * (y1 - y0))
    c:px(x, y, col or "#d4e6f0"); c:px(x - 1, y + 1, col or "#d4e6f0")
  end
end
local function cactus(c, x, yb, h, col, o)
  o = o or {}
  local w = o.w or 4
  local x0, x1 = x - floor(w / 2), x - floor(w / 2) + w - 1
  local m = c:mask()
  m:add(c:rect(x0, yb - h, x1, yb))
  if o.arms ~= false then
    local ay = yb - floor(h * 0.45)
    m:add(c:rect(x0 - 4, ay, x0, ay + 1)); m:add(c:rect(x0 - 4, ay - 4, x0 - 3, ay))
    local by = yb - floor(h * 0.62)
    m:add(c:rect(x1, by, x1 + 4, by + 1)); m:add(c:rect(x1 + 3, by - 4, x1 + 4, by))
  end
  part(c, m, col or "#4e8a5a")
  c:fill(c:rect(x0 + 1, yb - h + 1, x0 + 1, yb - 1), o.hi or "#6aa86e")
  if o.face then
    local ey = yb - h + 4
    c:px(x0 + 1, ey, INK); c:px(x1 - 1, ey, INK)
    c:px(x0 + 1, ey + 2, INK); c:px(x1 - 1, ey + 2, INK); c:px(x0 + 2, ey + 3, INK)
    if w >= 6 then c:px(x0 + 3, ey + 3, INK) end
    if o.face == "blush" then c:px(x0, ey + 1, "#e08a7a"); c:px(x1, ey + 1, "#e08a7a") end
  end
end
local function palm(c, x, yb, h, lean)
  lean = lean or 0
  local tx, ty = x + lean, yb - h
  part(c, c:line({ { x, yb }, { x + floor(lean / 2), yb - floor(h / 2) }, { tx, ty } }, 2), "#8a6a44", { noline = true })
  local lf = c:mask()
  for _, d in ipairs({ { -8, 2 }, { -6, -3 }, { 7, 2 }, { 5, -3 }, { 0, -5 } }) do
    lf:add(c:line({ { tx, ty }, { tx + floor(d[1] / 2), ty + d[2] - 3 }, { tx + d[1], ty + d[2] } }, 2))
  end
  part(c, lf, "#3f8a42")
end
local function bush(c, x, y, r, col) part(c, c:ellipse(x, y, r, floor(r * 0.8)), col or "#4e8a3c", { shade = true }) end
local function cloud(c, x, y) c:fill(c:ellipse(x, y, 8, 2), "#f4eee0"); c:fill(c:ellipse(x + 4, y - 2, 5, 2), "#f4eee0") end

---------------------------------------------------------------- scenes
local S = {}

-- na pond stone: ice slide, handled stone, ring far out, two sweepers
function S.r_na_pond_stone()
  seed = 3
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#aecbe0", "#bfd6e6", "#d0e2ec", "#e0ecf0" }, { dir = "v" })
  c:fill(c:ellipse(20, 31, 30, 7), "#d3e0ea"); c:fill(c:ellipse(60, 30, 26, 6), "#dae6ee")
  pine(c, 10, 31, 15, true); pine(c, 20, 30, 11, true); pine(c, 64, 30, 14, true)
  c:fill(R(c, 0, 30, W - 1, 33), "#f2f6f8")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#bfe0ec")
  for _, p in ipairs({ { 8, 38, 6 }, { 20, 41, 4 }, { 38, 36, 5 }, { 56, 36, 6 }, { 12, 49, 5 } }) do c:fill(R(c, p[1], p[2], p[1] + p[3], p[2]), "#e4f4f8") end
  -- little jetty at the left edge
  part(c, R(c, 5, 33, 15, 35), "#8a5a35"); part(c, R(c, 6, 35, 7, 38), "#6b4a2e", { noline = true })
  -- target ring far out
  c:fill(c:ellipse(60, 42, 8, 4), "#2f5fa8"); c:fill(c:ellipse(60, 42, 5, 3), "#f4f8fa"); c:fill(c:ellipse(60, 42, 2, 1), "#c0442e")
  c:outline(c:ellipse(60, 42, 8, 4))
  -- the stone with a handle, sliding, with a faint trail
  c:fill(R(c, 19, 46, 23, 46), "#e4f4f8")
  part(c, c:ellipse(27, 45, 4, 3), "#7a8088", { shade = true })
  part(c, R(c, 25, 40, 29, 41), "#c0442e"); fl(c, R(c, 26, 42, 28, 43), "#c0442e")
  c:px(25, 44, "#c8ccd2")
  -- sliding gnome, a long lunge
  gnome(c, 12, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 5 }, { 8, 3 }, true), arm({ -4, 6 }, { -6, 9 }, false) } })
  -- sweepers
  for k, sx in ipairs({ 38, 48 }) do
    local _, G = gnome(c, sx, 46 - (k - 1), { d = -1, s = 0.7, walk = (k == 1) and 1 or -1, eyes = "open", hat = (k == 1) and "#3f8fb0" or "#e8a317",
      arms = { arm({ -4, 7 }, { -9, 3 }, true) } })
    local hx, hy = G.P(-9, 3)
    c:fill(c:line({ { hx, hy }, { hx - 4, hy + 3 } }, 1), "#8a5a35")
    part(c, R(c, hx - 7, hy + 3, hx - 4, hy + 4), "#e8c24a")
  end
  seed = 9
  for i = 1, 14 do c:px(6 + floor(rand() * 62), 6 + floor(rand() * 40), "#fbfdfe") end
  finish(c, "r_na_pond_stone")
end

-- na sugar yarns: night, steaming sugar shack, bubbling pan, the storyteller
function S.r_na_sugar_yarns()
  seed = 5
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#232d52", "#2c3862", "#364570", "#41507a" }, { dir = "v" })
  for _, st in ipairs({ { 8, 8 }, { 20, 6 }, { 30, 12 }, { 44, 7 }, { 62, 10 }, { 12, 22 }, { 26, 26 }, { 66, 24 } }) do c:px(st[1], st[2], "#f4eee0") end
  c:fill(c:ellipse(60, 12, 3, 3), "#f5e6a8")
  c:fill(c:ellipse(18, 35, 34, 9), "#2a3a60")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#a9bbd4")
  c:fill(R(c, 0, 34, W - 1, 34), "#c4d2e4")
  for _, p in ipairs({ { 10, 44, 6 }, { 22, 49, 5 }, { 46, 48, 7 }, { 60, 45, 4 } }) do c:fill(R(c, p[1], p[2], p[1] + p[3], p[2]), "#c8d6e6") end
  -- shack
  part(c, R(c, 42, 22, 67, 44), "#7a4a2a")
  for x = 46, 66, 4 do fl(c, R(c, x, 23, x, 43), "#5e3a22") end
  part(c, c:poly({ { 54, 13 }, { 69, 23 }, { 40, 23 } }), "#8e5a3a")
  c:fill(c:poly({ { 54, 13 }, { 69, 23 }, { 66, 23 }, { 54, 16 }, { 43, 23 }, { 40, 23 } }), "#e8eef4")
  part(c, R(c, 51, 9, 56, 14), "#5e3a22")
  fl(c, R(c, 49, 8, 58, 8), "#3d2a1c")
  part(c, R(c, 46, 30, 54, 44), "#ffd86a", { shade = true, cres = 1 })
  fl(c, R(c, 47, 31, 53, 43), "#f5a830"); fl(c, R(c, 47, 36, 53, 36), "#c0442e")
  part(c, R(c, 59, 28, 64, 33), "#ffd86a"); fl(c, R(c, 61, 28, 61, 33), "#7a4a2a"); fl(c, R(c, 59, 30, 64, 30), "#7a4a2a")
  -- steam out of the vent and the pan
  for i = 0, 4 do puff(c, 54 + (i % 2) * 2 - 1, 6 - i * 0, 3 - (i > 2 and 1 or 0)) end
  fl(c, c:ellipse(53, 5, 3, 1), "#e8eef4"); fl(c, c:ellipse(57, 6, 2, 1), "#e8eef4")
  -- boiling pan on a stone fire
  part(c, R(c, 18, 43, 38, 47), "#8b8f96", { shade = true })
  fl(c, R(c, 22, 45, 34, 47), "#e0501f"); fl(c, R(c, 25, 46, 31, 47), "#ffd86a")
  part(c, R(c, 16, 38, 40, 42), "#3d3a40")
  fl(c, R(c, 17, 38, 39, 39), "#e8a317"); for x = 19, 37, 4 do c:px(x, 38, "#f5cf6a") end
  for i, x in ipairs({ 22, 28, 34 }) do
    puff(c, x, 33 - (i % 2) * 2, 2); puff(c, x + 1, 29 - (i % 2), 1); c:px(x, 26, "#dfe8f0")
  end
  -- storyteller
  gnome(c, 9, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -8, 14 }, false), arm({ 4, 8 }, { 8, 12 }, true) } })
  -- story bubble: red maple leaf
  part(c, c:rrect(6, 14, 16, 24, 2), "#f4eee0")
  c:fill(c:poly({ { 12, 24 }, { 14, 24 }, { 13, 27 } }), "#f4eee0")
  c:paint({ "..r..", ".rrrr", "rrrrr", ".rrr.", "..b.." }, 9, 16, { r = "#c8402a", b = "#6b3b2a" })
  finish(c, "r_na_sugar_yarns")
end

-- na lantern legends: the keeper holds up the empty lamp hook, points over the sea
function S.r_na_lantern_legends()
  seed = 8
  local c = new()
  day(c, 31, { cloud = 20, sky = { "#9fc8e0", "#b6d8e8", "#cfe8ee" }, hill = "#6f8a96", hill2 = "#7a96a2" })
  c:fill(R(c, 0, 31, W - 1, H - 1), "#3f8fb0")
  c:fill(R(c, 0, 31, W - 1, 31), "#8fcbd8")
  for _, p in ipairs({ { 8, 35 }, { 20, 38 }, { 10, 43 }, { 28, 46 }, { 52, 48 }, { 40, 40 } }) do c:fill(R(c, p[1], p[2], p[1] + 4, p[2]), "#a8dce4") end
  -- a far glint on the sea
  spark(c, 9, 30)
  -- rocks and the lighthouse
  part(c, c:ellipse(56, 46, 15, 6), "#7a8088", { shade = true })
  part(c, c:poly({ { 49, 44 }, { 52, 14 }, { 60, 14 }, { 63, 44 } }), "#f4eee0")
  for _, y in ipairs({ 18, 28, 38 }) do c:fill(c:poly({ { 52 - (y - 14) / 10, y }, { 60 + (y - 14) / 10, y }, { 60 + (y - 14) / 10 + 1, y + 3 }, { 52 - (y - 14) / 10 - 1, y + 3 } }), "#c0442e") end
  part(c, R(c, 50, 11, 62, 14), "#3d2a1c")
  part(c, R(c, 52, 6, 60, 11), "#7a98a8")
  fl(c, R(c, 53, 7, 59, 10), "#3a4a56")
  fl(c, R(c, 56, 7, 57, 8), "#aeb4bc"); c:px(57, 9, "#aeb4bc")     -- empty hook inside
  part(c, c:poly({ { 56, 3 }, { 62, 7 }, { 50, 7 } }), "#c0442e")
  -- keeper pointing out to sea, other hand holding the old hook high
  local _, G = gnome(c, 34, 47, { d = -1, eyes = "open", arms = { arm({ -4, 8 }, { -11, 12 }, false), arm({ 4, 8 }, { 7, 16 }, true) } })
  local hx, hy = G.P(7, 16)
  fl(c, R(c, hx, hy - 8, hx, hy), "#6a6e76")
  fl(c, R(c, hx - 3, hy - 9, hx + 1, hy - 9), "#6a6e76"); fl(c, R(c, hx - 3, hy - 8, hx - 3, hy - 6), "#6a6e76")
  part(c, R(c, hx - 4, hy - 6, hx - 2, hy - 4), "#aeb4bc")
  c:px(hx - 12, hy + 5, "#fff1c8")
  finish(c, "r_na_lantern_legends")
end

-- na woodstove mitts: damp mittens steaming on the rail, a gnome warming up on the bench
function S.r_na_woodstove_mitts()
  seed = 12
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 42), "#8a5a35")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 42), "#6b3b2a") end
  c:fill(R(c, 0, 43, W - 1, H - 1), "#5e3f28")
  for y = 46, 52, 3 do fl(c, R(c, 0, y, W - 1, y), "#4a2c1a") end
  -- frosty window
  part(c, R(c, 9, 12, 21, 26), "#6b3b2a"); fl(c, R(c, 10, 13, 20, 25), "#a8c8dc"); fl(c, R(c, 15, 13, 15, 25), "#6b3b2a"); fl(c, R(c, 10, 19, 20, 19), "#6b3b2a")
  for _, p in ipairs({ { 12, 15 }, { 18, 22 }, { 17, 16 }, { 12, 22 } }) do c:px(p[1], p[2], "#f4f8fa") end
  -- stove with a pipe
  part(c, R(c, 51, 8, 55, 26), "#4a4e58")
  part(c, R(c, 42, 27, 64, 42), "#33363e", { shade = true })
  part(c, R(c, 44, 33, 54, 40), "#ffd86a", { cres = 1 }); fl(c, R(c, 45, 34, 53, 39), "#e0501f"); fl(c, R(c, 47, 37, 51, 39), "#ffd86a")
  part(c, R(c, 40, 41, 41, 45), "#33363e", { noline = true }); part(c, R(c, 65, 41, 66, 45), "#33363e", { noline = true })
  fl(c, R(c, 43, 28, 63, 28), "#5a5e68")
  -- rail with mittens
  fl(c, R(c, 35, 17, 67, 17), "#2a2d34")
  fl(c, R(c, 35, 16, 35, 21), "#2a2d34"); fl(c, R(c, 67, 16, 67, 21), "#2a2d34")
  for i, col in ipairs({ "#c0442e", "#3f6fb0", "#e8a317", "#4f9a45", "#a84a8a" }) do
    local x = 38 + (i - 1) * 6
    part(c, R(c, x, 18, x + 3, 23), col); fl(c, R(c, x - 1, 20, x - 1, 21), col)
    fl(c, R(c, x, 18, x + 3, 19), "#f4eee0")
    c:px(x + 1, 25 + (i % 2), "#7ccfe0")
    fl(c, R(c, x + 1, 12 - (i % 2) * 2, x + 1, 15 - (i % 2) * 2), "#f4f8fa")
    c:px(x + 2, 10 - (i % 2) * 2, "#f4f8fa")
  end
  -- the bench, with one spot taken
  part(c, R(c, 6, 41, 34, 43), "#b07a45"); fl(c, R(c, 7, 41, 33, 41), "#d9a660")
  part(c, R(c, 8, 44, 9, 48), "#8a5a35", { noline = true }); part(c, R(c, 31, 44, 32, 48), "#8a5a35", { noline = true })
  gnome(c, 22, 41, { d = 1, sit = true, s = 1.1, eyes = "happy", arms = { arm({ 3, 8 }, { 9, 9 }, true) } })
  part(c, c:ellipse(11, 47, 3, 1), "#7ccfe0", { noline = true })
  finish(c, "r_na_woodstove_mitts")
end

-- ca smoke reading: a rabbit-shaped plume over the volcano
function S.r_ca_smoke_reading()
  seed = 15
  local c = new()
  day(c, 38, { sky = { "#c8dce4", "#d8e6e6", "#e8eee2" }, cloud = false, hill = "#4e8a3c", hill2 = "#3f7a38" })
  part(c, c:poly({ { 28, 40 }, { 42, 30 }, { 56, 30 }, { 72, 40 } }), "#7a6a60")
  c:fill(c:poly({ { 42, 30 }, { 49, 30 }, { 44, 40 }, { 38, 40 } }), "#6a5a52")
  fl(c, R(c, 43, 30, 55, 31), "#c8502a")
  -- rabbit plume
  local g1, g2 = "#e4e8ec", "#b8bec8"
  for _, p in ipairs({ { 48, 28, 2 }, { 49, 25, 3 } }) do part(c, c:ellipse(p[1], p[2], p[3], 2), g1, { noline = true }) end
  part(c, c:ellipse(50, 20, 8, 5), g1); c:fill(c:ellipse(50, 22, 6, 2), g2)
  part(c, c:ellipse(58, 15, 4, 3), g1)
  part(c, c:rect(56, 8, 57, 12), g1); part(c, c:rect(60, 8, 61, 12), g1)
  part(c, c:ellipse(41, 19, 2, 2), g1, { noline = true })
  c:px(60, 15, INK)
  -- palm and tent, the watcher shading his eyes
  palm(c, 8, 40, 20, 3)
  part(c, c:poly({ { 26, 28 }, { 33, 41 }, { 19, 41 } }), "#e8d2a0"); c:fill(c:poly({ { 26, 33 }, { 29, 41 }, { 23, 41 } }), "#6b3b2a")
  gnome(c, 20, 47, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 7, 15 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  finish(c, "r_ca_smoke_reading")
end

-- ca cistern share: heat, almost-dry cistern, a thirsty cup and a wilted bean plant
function S.r_ca_cistern_share()
  seed = 20
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#f2d9a0", "#f5e2b0", "#f8ecc4", "#fbf2d4" }, { dir = "v" })
  c:fill(c:ellipse(60, 12, 5, 5), "#fff1c8"); c:fill(c:ellipse(60, 12, 4, 4), "#f8d860")
  for _, p in ipairs({ { 60, 5 }, { 60, 19 }, { 53, 12 }, { 67, 12 }, { 55, 7 }, { 65, 17 } }) do c:px(p[1], p[2], "#f5cf6a") end
  c:fill(c:ellipse(16, 34, 30, 7), "#d9b070"); c:fill(c:ellipse(60, 35, 24, 6), "#c9a060")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#d9b878")
  c:fill(R(c, 0, 34, W - 1, 34), "#e8cc90")
  for _, p in ipairs({ { 8, 42 }, { 28, 47 }, { 56, 49 }, { 66, 42 }, { 14, 49 } }) do c:fill(R(c, p[1], p[2], p[1] + 3, p[2]), "#b8965c"); c:px(p[1] + 1, p[2] + 1, "#b8965c") end
  -- cistern
  part(c, R(c, 38, 32, 64, 47), "#a8aeb4", { shade = true })
  for _, y in ipairs({ 36, 41 }) do fl(c, R(c, 39, y, 63, y), "#7a8088") end
  for _, p in ipairs({ { 44, 33 }, { 52, 37 }, { 58, 33 }, { 46, 42 }, { 56, 42 } }) do fl(c, R(c, p[1], p[2], p[1], p[2] + 3), "#7a8088") end
  part(c, c:ellipse(51, 32, 13, 4), "#c9c5bc")
  c:fill(c:ellipse(51, 32, 10, 3), "#5a8a46"); c:fill(c:ellipse(51, 33, 7, 2), "#3a6a30"); c:fill(c:ellipse(51, 33, 4, 1), "#4f9ac0")
  c:px(50, 33, "#8fcbd8")
  -- spigot on the front with a drip
  part(c, R(c, 36, 40, 40, 42), "#8b929c"); c:px(36, 43, "#4f9ac0"); c:px(36, 45, "#4f9ac0")
  -- heat shimmer
  for _, p in ipairs({ { 14, 30 }, { 28, 28 }, { 10, 24 } }) do for i = 0, 5 do c:px(p[1] + i, p[2] + (i % 2), "#fff6d8") end end
  -- gnome with a cup, a withered bean plant in a pot
  gnome(c, 22, 47, { d = 1, eyes = "shut", arms = { arm({ 4, 7 }, { 9, 9 }, true, true), arm({ -4, 5 }, { -5, 2 }, false) } })
  local cx, cy = 30, 36
  part(c, R(c, cx, cy, cx + 4, cy + 4), "#aeb4bc"); fl(c, R(c, cx + 1, cy, cx + 3, cy), "#3a3a40")
  fl(c, R(c, cx + 5, cy + 1, cx + 6, cy + 3), "#8b929c")
  fl(c, R(c, cx - 1, cy + 2, cx, cy + 4), "#f0c8a0")
  part(c, R(c, 6, 41, 12, 47), "#c4623a"); fl(c, R(c, 6, 41, 12, 42), "#d9784a")
  fl(c, R(c, 9, 33, 9, 40), "#8a8a3a")
  part(c, c:poly({ { 9, 35 }, { 4, 37 }, { 5, 40 }, { 9, 38 } }), "#b8a84a", { noline = true })
  part(c, c:poly({ { 9, 34 }, { 14, 37 }, { 13, 40 }, { 9, 37 } }), "#a89a40", { noline = true })
  finish(c, "r_ca_cistern_share")
end

-- ca seedling rescue: downpour, a gnome runs with a tray of seedlings
function S.r_ca_seedling_rescue()
  seed = 24
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#4e5a6a", "#5a6676", "#687484", "#788494" }, { dir = "v" })
  part(c, c:poly({ { 44, 6 }, { 38, 14 }, { 43, 14 }, { 36, 24 }, { 47, 13 }, { 42, 13 } }), "#f5e46a", { noline = true })
  c:fill(c:ellipse(16, 35, 30, 7), "#3a5a42"); c:fill(c:ellipse(58, 35, 26, 6), "#325038")
  c:fill(R(c, 0, 35, W - 1, H - 1), "#5a7048")
  c:fill(R(c, 0, 35, W - 1, 35), "#6a8454")
  -- big drooping leaves at the corners
  part(c, c:ellipse(10, 14, 8, 4), "#3f8a42", { shade = true }); fl(c, R(c, 5, 14, 15, 14), "#2f6a32")
  part(c, c:ellipse(64, 16, 7, 3), "#3f8a42", { shade = true })
  -- flooding puddle with seedling trays going under
  c:fill(c:ellipse(52, 44, 15, 5), "#6a98b0"); c:fill(c:ellipse(52, 44, 12, 3), "#7ab0c8")
  for _, p in ipairs({ { 46, 43 }, { 54, 45 }, { 58, 42 } }) do c:fill(R(c, p[1], p[2], p[1] + 3, p[2]), "#a8d0e0") end
  part(c, R(c, 46, 39, 58, 44), "#8a5a35"); fl(c, R(c, 47, 40, 57, 40), "#5e2f1e")
  for x = 48, 56, 3 do fl(c, R(c, x, 36, x, 39), "#4f9a45"); fl(c, R(c, x - 1, 36, x + 1, 36), "#7ab55c") end
  -- the runner with a tray held out in front
  local _, G = gnome(c, 24, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 6 }, { 5, 9 }, false), arm({ 4, 8 }, { 9, 9 }, true) } })
  local tx, ty = G.P(2, 9)
  part(c, R(c, tx, ty, tx + 14, ty + 2), "#8a5a35")
  for x = tx + 2, tx + 12, 4 do fl(c, R(c, x, ty - 3, x, ty - 1), "#4f9a45"); fl(c, R(c, x - 1, ty - 4, x + 1, ty - 3), "#7ab55c") end
  rain(c, 60, 5, 48, "#cfe0ea", 31)
  for _, p in ipairs({ { 12, 46 }, { 34, 49 }, { 44, 48 } }) do c:px(p[1], p[2], "#d4e6f0"); c:px(p[1] + 2, p[2], "#d4e6f0") end
  finish(c, "r_ca_seedling_rescue")
end

-- ca howler dawn: roaring monkeys in the canopy, the angler tallies on the jetty
function S.r_ca_howler_dawn()
  seed = 28
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#4a3a6a", "#7a4a7a", "#b85a7a", "#e8825e", "#f5b070", "#f8d090" }, { dir = "v" })
  c:fill(c:ellipse(40, 33, 9, 8), "#fff0b0"); c:fill(c:ellipse(40, 33, 6, 5), "#fffae0")
  c:fill(R(c, 0, 29, W - 1, 33), "#2a3a42")
  c:fill(R(c, 0, 33, W - 1, H - 1), "#4a7a88")
  c:fill(R(c, 0, 33, W - 1, 35), "#d8906a")
  for _, p in ipairs({ { 10, 38, 8 }, { 26, 40, 6 }, { 48, 37, 9 }, { 8, 45, 6 }, { 30, 47, 8 } }) do c:fill(R(c, p[1], p[2], p[1] + p[3], p[2]), "#7ab0b8") end
  -- canopy and a branch with howlers
  for _, p in ipairs({ { 8, 24, 9, 7 }, { 22, 20, 8, 8 }, { 40, 26, 10, 6 }, { 58, 22, 9, 8 }, { 66, 28, 6, 5 } }) do c:fill(c:ellipse(p[1], p[2], p[3], p[4]), "#2a3a42") end
  c:fill(c:line({ { 5, 15 }, { 18, 14 }, { 30, 17 }, { 44, 15 } }, 2), "#3a2a22")
  local function mk(x, y, flip)
    part(c, c:ellipse(x, y, 3, 3), "#4a3022", { noline = true })
    part(c, c:ellipse(x + flip * 3, y - 3, 2, 2), "#5a3a2a", { noline = true })
    c:px(x + flip * 4, y - 3, "#e8d8b0"); c:px(x + flip * 5, y - 3, "#2a1a10")
    fl(c, c:line({ { x - flip * 3, y + 1 }, { x - flip * 5, y + 4 }, { x - flip * 3, y + 6 } }, 1), "#4a3022")
  end
  mk(12, 11, 1); mk(25, 11, -1); mk(38, 11, 1)
  for _, x in ipairs({ 16, 29, 42 }) do
    local dir = (x == 29) and -1 or 1
    for k = 1, 2 do c:fill(c:line({ { x + dir * k * 2 + 1, 7 }, { x + dir * (k * 2 + 2), 9 }, { x + dir * k * 2 + 1, 11 } }, 1), "#fff1c8") end
  end
  -- jetty and the tally keeper
  part(c, R(c, 34, 42, 66, 44), "#8a5a35")
  for _, x in ipairs({ 38, 50, 62 }) do part(c, R(c, x, 44, x + 1, 49), "#5e3f28", { noline = true }) end
  local _, G = gnome(c, 54, 42, { d = -1, sit = true, eyes = "open", arms = { arm({ -3, 8 }, { -8, 14 }, true, true) } })
  local bx, by = G.P(-8, 14)
  part(c, R(c, bx - 3, by - 4, bx + 3, by + 3), "#f4eee0")
  for _, x in ipairs({ bx - 2, bx - 1, bx, bx + 1 }) do fl(c, R(c, x, by - 3, x, by), "#2a1a10") end
  fl(c, R(c, bx - 2, by + 1, bx + 2, by + 1), "#2a1a10")
  fl(c, R(c, bx - 4, by + 2, bx - 3, by + 3), "#f0c8a0")
  finish(c, "r_ca_howler_dawn")
end

-- ca nopal spines: gloved gnome scraping a prickly pad at a market stall
function S.r_ca_nopal_spines()
  seed = 30
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 33), "#e8c48a")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 14, x, 33), "#d9b070") end
  c:fill(R(c, 0, 34, W - 1, H - 1), "#c9a96e")
  fl(c, R(c, 0, 34, W - 1, 34), "#d9bc84")
  for _, p in ipairs({ { 6, 44 }, { 30, 48 }, { 52, 46 }, { 64, 42 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#b8965c") end
  -- striped awning
  local n = 0
  for x = 4, 68, 4 do
    local col = (n % 2 == 0) and "#c0442e" or "#f4eee0"
    fl(c, R(c, x, 5, x + 3, 11), col); fl(c, R(c, x + 1, 12, x + 2, 12), col); n = n + 1
  end
  part(c, R(c, 6, 13, 7, 34), "#8a5a35", { noline = true }); part(c, R(c, 66, 13, 67, 34), "#8a5a35", { noline = true })
  -- hanging pads on a cord
  fl(c, R(c, 8, 14, 65, 14), "#5e3f28")
  for _, x in ipairs({ 14, 24, 56 }) do part(c, c:ellipse(x, 19, 2, 3), "#4e8a5a", { noline = true }); fl(c, R(c, x, 15, x, 16), "#5e3f28") end
  -- table with a pad on a board
  part(c, R(c, 30, 38, 66, 41), "#b07a45"); fl(c, R(c, 31, 38, 65, 38), "#d9a660")
  for _, x in ipairs({ 32, 63 }) do part(c, R(c, x, 41, x + 1, 48), "#8a5a35", { noline = true }) end
  part(c, R(c, 38, 36, 60, 37), "#e8c48a")
  part(c, c:ellipse(49, 33, 8, 4), "#4e8a5a")
  c:fill(c:ellipse(49, 33, 5, 2), "#6aa86e")
  for _, p in ipairs({ { 44, 32 }, { 47, 35 }, { 51, 31 }, { 54, 34 }, { 56, 32 }, { 42, 34 } }) do c:px(p[1], p[2], "#e8ecb0") end
  -- basket of pads at the right
  part(c, c:ellipse(61, 30, 4, 3), "#4e8a5a", { noline = true }); part(c, c:ellipse(58, 32, 3, 3), "#5a9a62", { noline = true })
  -- gnome with a blunt knife and gloves with holes
  local _, G = gnome(c, 20, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 6 }, true, true), arm({ -4, 6 }, { 2, 6 }, false, true) } })
  local kx, ky = G.P(9, 6)
  fl(c, R(c, kx - 1, ky - 1, kx + 3, ky + 2), "#7a4a2a")
  c:px(kx + 1, ky, "#f0c8a0"); c:px(kx + 2, ky + 1, "#f0c8a0")
  c:fill(c:line({ { kx + 3, ky + 1 }, { kx + 9, ky + 2 } }, 1), "#aeb4bc")
  local gx, gy = G.P(2, 6)
  fl(c, R(c, gx - 1, gy - 1, gx + 2, gy + 2), "#7a4a2a"); c:px(gx + 1, gy, "#f0c8a0")
  -- flying spines
  for _, p in ipairs({ { 40, 28 }, { 44, 26 }, { 52, 27 }, { 58, 36 } }) do c:px(p[1], p[2], "#fff6d8"); c:px(p[1] + 1, p[2] - 1, "#fff6d8") end
  finish(c, "r_ca_nopal_spines")
end

-- ca vanilla bloom: dawn, a toothpick to a one-morning orchid on the vine
function S.r_ca_vanilla_bloom()
  seed = 33
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#e8a8b8", "#f0b8b0", "#f6c8a8", "#f8dcb0", "#fbe8c0" }, { dir = "v" })
  c:fill(c:ellipse(18, 37, 8, 7), "#fff0b0")
  c:fill(c:ellipse(12, 36, 36, 9), "#6f9a52"); c:fill(c:ellipse(60, 38, 30, 8), "#5e8a44")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#7ea85a"); c:fill(R(c, 0, 36, W - 1, 36), "#9cc070")
  for _, p in ipairs({ { 8, 44 }, { 30, 48 }, { 52, 47 }, { 62, 44 } }) do c:px(p[1], p[2], "#5e8a44"); c:px(p[1] + 1, p[2] - 1, "#5e8a44") end
  -- support tree and the vine
  part(c, R(c, 52, 8, 58, 46), "#7a4a2a"); fl(c, R(c, 54, 10, 54, 44), "#5e2f1e")
  part(c, c:ellipse(55, 8, 13, 5), "#3f8a42", { shade = true })
  local vine = c:line({ { 51, 40 }, { 47, 32 }, { 51, 24 }, { 46, 16 }, { 50, 9 } }, 1)
  c:fill(vine, "#4f9a45")
  for _, p in ipairs({ { 46, 36 }, { 48, 20 }, { 50, 28 }, { 46, 12 } }) do
    part(c, c:ellipse(p[1], p[2], 3, 1), "#3f8a42", { noline = true })
  end
  local function orchid(x, y)
    for _, d in ipairs({ { -2, 0 }, { 2, 0 }, { 0, -2 }, { 0, 2 } }) do c:fill(c:ellipse(x + d[1], y + d[2], 1, 1), "#f4eeb8") end
    c:px(x, y, "#e8a317")
  end
  orchid(43, 20); orchid(47, 27); orchid(44, 33); orchid(48, 14)
  -- gnome, big, reaching with a toothpick
  local _, G = gnome(c, 22, 47, { d = 1, s = 1.25, eyes = "open", arms = { arm({ 4, 9 }, { 9, 14 }, true, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  local hx, hy = G.P(9, 14)
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  c:fill(c:line({ { hx + 1, hy - 1 }, { 41, 20 } }, 1), "#e8c48a")
  spark(c, 40, 17)
  finish(c, "r_ca_vanilla_bloom")
end

-- ca dugout pole: poling a log canoe through the mangroves, herons glaring
function S.r_ca_dugout_pole()
  seed = 36
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#b8d8c0", "#a8cdb0", "#8fbf9a", "#6aa57a" }, { dir = "v" })
  c:fill(R(c, 0, 31, W - 1, H - 1), "#4a9a8a"); c:fill(R(c, 0, 31, W - 1, 33), "#6ab5a0")
  for _, p in ipairs({ { 8, 36, 8 }, { 24, 40, 6 }, { 50, 38, 8 }, { 12, 46, 8 }, { 44, 47, 8 } }) do c:fill(R(c, p[1], p[2], p[1] + p[3], p[2]), "#8fd0bc") end
  -- canopy
  for _, p in ipairs({ { 6, 8, 10, 6 }, { 22, 6, 9, 5 }, { 40, 7, 10, 5 }, { 58, 8, 10, 6 }, { 68, 14, 5, 6 } }) do c:fill(c:ellipse(p[1], p[2], p[3], p[4]), "#2f6a3a") end
  c:fill(c:ellipse(30, 10, 6, 3), "#3f8a42")
  -- mangrove arch roots
  local roots = c:mask()
  roots:add(c:line({ { 5, 14 }, { 9, 24 }, { 6, 36 } }, 2)); roots:add(c:line({ { 11, 14 }, { 14, 26 }, { 14, 37 } }, 1))
  roots:add(c:line({ { 66, 14 }, { 61, 24 }, { 64, 37 } }, 2)); roots:add(c:line({ { 58, 14 }, { 56, 28 }, { 54, 36 } }, 1))
  part(c, roots, "#7a4a2a", { noline = true })
  -- herons on the roots
  local function heron(x, y, d)
    part(c, c:ellipse(x, y, 3, 2), "#dfe6ea", { noline = true })
    fl(c, R(c, x + d * 2, y - 6, x + d * 2, y - 1), "#dfe6ea"); fl(c, R(c, x + d * 2 + d, y - 8, x + d * 2 + d, y - 6), "#dfe6ea")
    fl(c, R(c, x + d * 3, y - 8, x + d * 5, y - 8), "#e8a317")
    c:px(x + d * 2, y - 8, "#c0442e")
    fl(c, R(c, x, y + 1, x, y + 4), "#6a6e76"); fl(c, R(c, x + 1, y + 1, x + 1, y + 4), "#6a6e76")
  end
  heron(12, 21, 1); heron(58, 23, -1)
  -- canoe
  part(c, c:poly({ { 15, 41 }, { 56, 41 }, { 52, 46 }, { 19, 46 } }), "#8a5a35")
  c:fill(c:poly({ { 17, 43 }, { 54, 43 }, { 53, 44 }, { 18, 44 } }), "#a8703e")
  fl(c, R(c, 15, 40, 56, 41), "#b07a45"); fl(c, R(c, 15, 41, 17, 41), "#c08a52")
  fl(c, R(c, 20, 47, 52, 47), "#8fd0bc")
  local _, G = gnome(c, 34, 42, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 10 }, true), arm({ -4, 7 }, { 5, 5 }, false) } })
  local hx, hy = G.P(8, 10)
  c:fill(c:line({ { hx - 1, hy - 5 }, { hx + 6, 49 } }, 1), "#5e3f28")
  fl(c, R(c, hx + 4, 46, hx + 10, 46), "#d4f0e8")
  finish(c, "r_ca_dugout_pole")
end

-- ca flats kites: a paper kite taller than the mill, three gnomes hauling
function S.r_ca_flats_kites()
  seed = 39
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#a8c4e0", "#b8d0e6", "#cadcea", "#dce6ee" }, { dir = "v" })
  for _, p in ipairs({ { 8, 18 }, { 12, 31 }, { 58, 16 }, { 62, 28 } }) do for i = 0, 6 do c:px(p[1] + i, p[2] - ((i > 4) and 1 or 0), "#f4f8fa") end end
  c:fill(c:ellipse(16, 38, 32, 7), "#b8a860"); c:fill(R(c, 0, 38, W - 1, H - 1), "#c8a850")
  for x = 0, W - 1, 5 do fl(c, R(c, x, 40, x, 49), "#e0c060"); fl(c, R(c, x + 2, 42, x + 2, 49), "#a88a38") end
  c:fill(R(c, 0, 38, W - 1, 38), "#e0c868")
  -- mill
  part(c, c:poly({ { 56, 40 }, { 58, 24 }, { 66, 24 }, { 68, 40 } }), "#e8dcc0")
  part(c, c:poly({ { 57, 24 }, { 62, 19 }, { 67, 24 } }), "#8a5a35")
  fl(c, R(c, 61, 36, 63, 40), "#6b3b2a")
  part(c, c:line({ { 62, 24 }, { 53, 15 } }, 1), "#f4eee0", { noline = true }); part(c, c:line({ { 62, 24 }, { 71, 33 } }, 1), "#f4eee0", { noline = true })
  part(c, c:line({ { 62, 24 }, { 71, 15 } }, 1), "#f4eee0", { noline = true }); part(c, c:line({ { 62, 24 }, { 53, 33 } }, 1), "#f4eee0", { noline = true })
  -- the giant kite
  local k = c:poly({ { 30, 5 }, { 41, 16 }, { 30, 31 }, { 19, 16 } })
  part(c, k, "#e8a317")
  c:fill(c:poly({ { 30, 5 }, { 41, 16 }, { 30, 16 } }), "#c0442e"); c:fill(c:poly({ { 30, 31 }, { 19, 16 }, { 30, 16 } }), "#c0442e")
  fl(c, R(c, 30, 6, 30, 30), "#5e2f1e"); fl(c, R(c, 20, 16, 40, 16), "#5e2f1e")
  -- tail
  c:fill(c:line({ { 30, 31 }, { 27, 35 }, { 31, 38 }, { 26, 42 } }, 1), "#8a5a35")
  for _, p in ipairs({ { 27, 35, "#c0442e" }, { 31, 38, "#3f8fb0" } }) do fl(c, R(c, p[1] - 1, p[2], p[1] + 1, p[2] + 1), p[3]) end
  -- haulers
  gnome(c, 14, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { 0, 16 }, true), arm({ 4, 7 }, { 7, 12 }, true) } })
  local _, G = gnome(c, 36, 48, { d = -1, s = 0.75, eyes = "open", hat = "#3f8fb0", arms = { arm({ -4, 7 }, { -8, 12 }, true) } })
  c:fill(c:line({ { 30, 31 }, { 22, 36 }, { 20, 34 }, { 17, 40 } }, 1), "#e8dcc0")
  c:fill(c:line({ { 22, 36 }, { 31, 44 }, { 32, 42 } }, 1), "#e8dcc0")
  finish(c, "r_ca_flats_kites")
end

-- ca three sisters: corn, beans and squash growing behind, going into one pot
function S.r_ca_three_sisters()
  seed = 42
  local c = new()
  day(c, 32, { cloud = 14, hill = "#5e8a44", hill2 = "#4e8a3c" })
  -- the field: cornstalks with bean vines, squash at the foot
  for _, x in ipairs({ 44, 52, 60 }) do
    part(c, R(c, x, 14, x + 1, 36), "#4f9a45", { noline = true })
    part(c, c:poly({ { x, 22 }, { x - 5, 18 }, { x - 4, 21 } }), "#5aa850", { noline = true })
    part(c, c:poly({ { x + 1, 27 }, { x + 6, 23 }, { x + 5, 26 } }), "#5aa850", { noline = true })
    part(c, R(c, x - 1, 18, x + 2, 24), "#f5cf6a", { noline = true }); fl(c, R(c, x - 1, 18, x + 2, 19), "#e8e8b0")
    c:fill(c:line({ { x - 2, 34 }, { x + 3, 29 }, { x - 2, 25 }, { x + 3, 21 } }, 1), "#7ab55c")
    c:px(x + 3, 29, "#e8f0c0")
  end
  fl(c, R(c, 40, 36, 68, 36), "#8a6a44")
  for _, x in ipairs({ 47, 56, 64 }) do part(c, c:ellipse(x, 36, 3, 2), "#e8a030", { shade = true }); fl(c, R(c, x - 1, 33, x, 34), "#4f9a45") end
  -- the pot on its fire
  part(c, c:line({ { 12, 47 }, { 31, 43 } }, 2), "#6b3b2a"); part(c, c:line({ { 12, 43 }, { 31, 47 } }, 2), "#8a5a35")
  fl(c, R(c, 16, 43, 27, 47), "#e0501f"); fl(c, R(c, 18, 44, 25, 47), "#f08a24"); fl(c, R(c, 20, 45, 23, 47), "#ffd86a")
  part(c, c:ellipse(21, 38, 10, 7), "#3d3a40")
  fl(c, R(c, 10, 31, 32, 33), "#3d3a40")
  c:fill(c:ellipse(21, 32, 10, 2), "#e8a030")
  -- stew bits sticking out
  part(c, c:ellipse(17, 31, 3, 2), "#f5cf6a", { noline = true }); part(c, c:ellipse(24, 30, 2, 2), "#e8a030", { noline = true })
  fl(c, R(c, 20, 29, 22, 30), "#4f9a45"); fl(c, R(c, 25, 31, 27, 31), "#4f9a45")
  for i, x in ipairs({ 17, 21, 25 }) do puff(c, x, 24 - (i % 2) * 2, 2); puff(c, x + 1, 20 - (i % 2), 1) end
  -- the cook stirring
  local _, G = gnome(c, 37, 47, { d = -1, eyes = "happy", arms = { arm({ -4, 8 }, { -8, 10 }, true), arm({ 4, 6 }, { 5, 3 }, false) } })
  local hx, hy = G.P(-8, 10)
  c:fill(c:line({ { hx, hy }, { 24, 31 } }, 1), "#8a5a35")
  finish(c, "r_ca_three_sisters")
end

-- ca fruit bowl: scratch a mamey to see the pink, papaya on the board
function S.r_ca_fruit_bowl()
  seed = 45
  local c = new()
  day(c, 30, { cloud = 50, sky = { "#b8dcd8", "#cce6dc", "#dcecd8" }, hill = "#4e8a3c", hill2 = "#3f7a38" })
  for _, x in ipairs({ 12, 56 }) do
    part(c, R(c, x - 1, 16, x + 1, 31), "#6b4a2e", { noline = true })
    part(c, c:ellipse(x, 14, 10, 7), "#3f8a42", { shade = true })
    for _, d in ipairs({ { -5, 15 }, { 4, 17 }, { 1, 12 } }) do part(c, c:ellipse(x + d[1], d[2], 2, 2), "#e8a030", { noline = true }) end
  end
  c:fill(R(c, 0, 31, W - 1, H - 1), "#7ea85a"); fl(c, R(c, 0, 31, W - 1, 31), "#9cc070")
  -- stall table in front
  part(c, R(c, 6, 40, 66, 44), "#b07a45"); fl(c, R(c, 7, 40, 65, 40), "#d9a660")
  part(c, R(c, 10, 45, 12, 49), "#8a5a35", { noline = true }); part(c, R(c, 60, 45, 62, 49), "#8a5a35", { noline = true })
  -- papaya halves with seeds, and a bowl of slices
  for _, x in ipairs({ 13, 24 }) do
    part(c, c:ellipse(x, 37, 5, 3), "#f08a2a"); c:fill(c:ellipse(x, 37, 2, 1), "#2a1a10"); c:px(x - 3, 36, "#f5a040")
  end
  part(c, c:rrect(48, 36, 62, 41, 2), "#f4eee0"); fl(c, R(c, 49, 36, 61, 36), "#d8c8a8")
  for i, x in ipairs({ 50, 54, 58 }) do part(c, c:ellipse(x, 35, 2, 2), (i % 2 == 0) and "#f08a2a" or "#f08a6a", { noline = true }) end
  -- the picker, behind the table, scratching a mamey
  local _, G = gnome(c, 38, 44, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ -5, 6 }, { -9, 13 }, true, true), arm({ 5, 6 }, { 8, 12 }, true, true) } })
  local mx, my = G.P(-11, 15)
  part(c, c:ellipse(mx, my, 4, 3), "#8a5a38")
  c:fill(c:ellipse(mx + 1, my, 2, 2), "#e8907a"); c:px(mx + 1, my, "#f4a890")
  c:px(mx - 2, my - 1, "#6a4026"); c:px(mx - 1, my + 2, "#6a4026")
  fl(c, R(c, mx + 3, my + 1, mx + 5, my + 3), "#f0c8a0")
  spark(c, mx - 4, my - 4)
  local kx, ky = G.P(8, 12)
  fl(c, R(c, kx - 1, ky - 1, kx + 1, ky + 1), "#f0c8a0")
  c:fill(c:line({ { kx + 1, ky - 1 }, { kx - 3, ky - 6 } }, 1), "#aeb4bc")
  finish(c, "r_ca_fruit_bowl")
end

-- ca bean pot: coil a clay pot from long snakes, gourd smoother
function S.r_ca_bean_pot()
  seed = 48
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#e8d2a0")
  for x = 3, W, 9 do fl(c, R(c, x, 0, x, 38), "#d9bc84") end
  c:fill(R(c, 0, 39, W - 1, H - 1), "#b8844a"); fl(c, R(c, 0, 39, W - 1, 39), "#d9a660")
  for _, p in ipairs({ { 6, 44 }, { 20, 49 }, { 56, 46 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#9a6a38") end
  -- shelf of finished pots
  part(c, R(c, 5, 22, 36, 23), "#8a5a35")
  for i, x in ipairs({ 9, 18, 28 }) do
    part(c, c:ellipse(x, 18, 4, 3), (i % 2 == 0) and "#c4623a" or "#d9784a"); fl(c, R(c, x - 2, 14, x + 2, 15), "#a8502a")
    fl(c, R(c, x - 1, 17, x + 1, 17), "#f4eee0")
  end
  -- unfinished pot of coils on a stand
  part(c, R(c, 44, 44, 62, 47), "#8a5a35")
  local bands = { { 43, 8, 5 }, { 40, 10, 6 }, { 37, 10, 6 }, { 34, 9, 5 }, { 31, 8, 4 }, { 28, 7, 4 } }
  local m = c:mask()
  for _, b in ipairs(bands) do m:add(c:rect(53 - b[2], b[1] - 2, 53 + b[2], b[1])) end
  part(c, m, "#c4623a")
  for i, b in ipairs(bands) do
    c:fill(c:rect(53 - b[2] + 1, b[1] - 2, 53 + b[2] - 1, b[1] - 2), (i % 2 == 0) and "#d9784a" or "#e08a5a")
    fl(c, R(c, 53 - b[2] + 1, b[1], 53 + b[2] - 1, b[1]), "#a8502a")
  end
  c:fill(c:ellipse(53, 25, 7, 2), "#8a4a28")
  -- the potter, rolling a snake of clay
  local _, G = gnome(c, 26, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 8 }, true), arm({ -4, 6 }, { 1, 8 }, true) } })
  local hx, hy = G.P(1, 8)
  c:fill(c:line({ { hx, hy }, { 36, 33 }, { 44, 26 }, { 50, 25 } }, 2), "#d9784a")
  fl(c, R(c, 38, 31, 40, 32), "#e8906a")
  local gx, gy = G.P(9, 8)
  part(c, c:ellipse(gx + 2, gy, 2, 2), "#e8c24a", { noline = true })
  finish(c, "r_ca_bean_pot")
end

-- ca vanilla tapers: dipping candles in warm wax with vanilla pods, rack of tapers
function S.r_ca_vanilla_tapers()
  seed = 51
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 42), "#6a5a68")
  for y = 5, 40, 7 do fl(c, R(c, 0, y, W - 1, y), "#584a58") end
  for y = 8, 40, 14 do for x = 5, W, 12 do fl(c, R(c, x, y, x, y + 6), "#584a58") end end
  for y = 1, 40, 14 do for x = 11, W, 12 do fl(c, R(c, x, y + 7, x, y + 13), "#584a58") end end
  c:fill(R(c, 0, 43, W - 1, H - 1), "#7a5a3a"); for y = 46, 52, 3 do fl(c, R(c, 0, y, W - 1, y), "#5e3f28") end
  -- drying rack with finished tapers
  fl(c, R(c, 8, 10, 30, 10), "#5e3f28"); fl(c, R(c, 8, 9, 8, 14), "#5e3f28"); fl(c, R(c, 30, 9, 30, 14), "#5e3f28")
  for i, x in ipairs({ 10, 14, 18, 22, 26 }) do
    fl(c, R(c, x, 10, x, 11), "#2a1a10")
    part(c, R(c, x - 1, 12, x + 1, 20 + (i % 2) * 3), "#f4e4b0", { noline = true })
    fl(c, R(c, x - 1, 12, x - 1, 19), "#fff6d8")
  end
  -- shrine candle lit on the shelf, glowing
  part(c, R(c, 40, 15, 62, 16), "#8a5a35")
  part(c, R(c, 50, 9, 52, 15), "#f4e4b0"); c:px(51, 8, "#ffd86a"); c:px(51, 7, "#f08a24")
  for _, p in ipairs({ { 49, 7 }, { 53, 7 }, { 51, 5 } }) do c:px(p[1], p[2], "#f8e8a0") end
  -- brazier with wax pot
  part(c, R(c, 46, 43, 64, 47), "#4a4e58")
  fl(c, R(c, 48, 44, 62, 46), "#e0501f"); fl(c, R(c, 52, 45, 58, 46), "#ffd86a")
  part(c, R(c, 47, 32, 63, 42), "#b8742f", { shade = true })
  fl(c, R(c, 48, 32, 62, 33), "#f4e4b0")
  -- vanilla pods standing in the wax, aroma curling up
  for _, p in ipairs({ { 52, 28 }, { 55, 27 }, { 58, 29 } }) do fl(c, R(c, p[1], p[2], p[1], 33), "#3a2418") end
  for i, x in ipairs({ 51, 56, 60 }) do
    for k = 0, 3 do c:px(x + ((k % 2 == 0) and 0 or 1), 26 - k * 3 - (i % 2), "#f8e8a0") end
  end
  -- the chandler dips a taper
  local _, G = gnome(c, 34, 47, { d = 1, eyes = "shut", arms = { arm({ 4, 8 }, { 9, 12 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local hx, hy = G.P(9, 12)
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  part(c, R(c, hx, hy + 1, hx + 1, 33), "#f4e4b0", { noline = true })
  fl(c, R(c, hx, hy + 2, hx, 31), "#fff6d8")
  finish(c, "r_ca_vanilla_tapers")
end

-- ca terrace stones: restacking slumped dry-stone terrace walls on the volcano slope
function S.r_ca_terrace_stones()
  seed = 54
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 18), { "#b8d8e4", "#c8e0e6", "#d8ebe8" }, { dir = "v" })
  part(c, c:poly({ { 20, 20 }, { 34, 7 }, { 44, 7 }, { 58, 20 } }), "#7a6a60")
  fl(c, R(c, 34, 7, 44, 8), "#9a8a80")
  local function wall(y0, y1)
    part(c, R(c, 4, y0, 69, y1), "#a8aeb4")
    for y = y0 + 2, y1, 3 do fl(c, R(c, 4, y, 69, y), "#7a8088") end
    local off = 0
    for y = y0, y1 - 1, 3 do
      for x = 6 + off, 68, 8 do fl(c, R(c, x, y, x, y + 2), "#7a8088") end
      off = 4 - off
    end
  end
  local function field(y0, y1, col)
    c:fill(R(c, 4, y0, 69, y1), col)
    for x = 6, 66, 6 do fl(c, R(c, x, y0 + 1, x + 2, y0 + 1), "#4f9a45"); c:px(x + 1, y0, "#4f9a45") end
  end
  field(19, 22, "#7ea85a"); wall(23, 28)
  field(29, 32, "#8fb860"); wall(33, 38)
  c:fill(R(c, 4, 39, 69, 49), "#7ea85a")
  for x = 6, 66, 6 do fl(c, R(c, x, 41, x + 2, 41), "#4f9a45"); fl(c, R(c, x + 3, 45, x + 5, 45), "#4f9a45") end
  -- the slump: soil and stones tumbled through a gap in the lower wall
  c:fill(c:poly({ { 36, 33 }, { 52, 33 }, { 58, 40 }, { 30, 40 } }), "#8a6a44")
  c:fill(c:poly({ { 38, 33 }, { 50, 33 }, { 54, 38 }, { 34, 38 } }), "#9a7a54")
  for _, p in ipairs({ { 33, 41 }, { 40, 40 }, { 47, 41 }, { 54, 40 }, { 44, 43 } }) do part(c, c:ellipse(p[1], p[2], 3, 2), "#a8aeb4", { shade = true }) end
  -- the gnome lugging a stone to the gap
  local _, G = gnome(c, 20, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 6 }, { 9, 8 }, true, true), arm({ -4, 6 }, { 5, 11 }, false, true) } })
  local sx, sy = G.P(7, 10)
  part(c, c:ellipse(sx, sy, 5, 3), "#9a9ea6", { shade = true })
  fl(c, R(c, sx - 5, sy + 2, sx - 4, sy + 3), "#f0c8a0"); fl(c, R(c, sx + 4, sy + 2, sx + 5, sy + 3), "#f0c8a0")
  c:px(sx - 4, sy - 1, "#fff6d8")
  finish(c, "r_ca_terrace_stones")
end

-- ca cacao shade: pruning the over-keen banana and palm canopy above the cacao
function S.r_ca_cacao_shade()
  seed = 57
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#7ea85a")
  c:bands(R(c, 0, 0, W - 1, 30), { "#a8cc8a", "#9cc47e", "#8ebc72" }, { dir = "v" })
  c:fill(R(c, 0, 31, W - 1, H - 1), "#6a9a4a")
  -- dappled light patches on the ground
  for _, p in ipairs({ { 14, 44, 4 }, { 34, 40, 3 }, { 48, 47, 4 }, { 62, 42, 3 }, { 24, 48, 3 } }) do c:fill(c:ellipse(p[1], p[2], p[3], 1), "#b8d878") end
  for _, p in ipairs({ { 8, 38 }, { 28, 36 }, { 56, 38 }, { 40, 46 } }) do c:px(p[1], p[2], "#5e8a44"); c:px(p[1] + 1, p[2] - 1, "#5e8a44") end
  -- cacao tree with pods on the right
  part(c, R(c, 50, 22, 56, 47), "#6b4a2e"); fl(c, R(c, 52, 24, 52, 45), "#4a2c1a")
  part(c, c:ellipse(53, 20, 9, 5), "#3f8a42", { shade = true })
  for _, p in ipairs({ { 49, 30 }, { 57, 34 }, { 49, 38 } }) do
    part(c, c:ellipse(p[1], p[2], 2, 3), "#e8a030"); fl(c, R(c, p[1], p[2] - 2, p[1], p[2] + 2), "#c47a20")
  end
  -- heavy canopy overhead: banana and palm leaves
  for _, p in ipairs({ { 8, 9, 11, 7 }, { 26, 8, 10, 6 }, { 44, 9, 9, 7 }, { 63, 10, 10, 7 }, { 36, 14, 7, 3 } }) do
    part(c, c:ellipse(p[1], p[2], p[3], p[4]), "#2f6a32", { noline = true })
    fl(c, R(c, p[1] - p[3] + 2, p[2], p[1] + p[3] - 2, p[2]), "#245a2a")
  end
  part(c, c:ellipse(30, 14, 7, 3), "#3f8a42", { shade = true }); fl(c, R(c, 24, 14, 36, 14), "#2f6a32")
  -- gnome with the long-handled pruning hook, reaching up
  local _, G = gnome(c, 18, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 7, 14 }, true), arm({ -4, 8 }, { 3, 10 }, true) } })
  c:fill(c:line({ { 20, 44 }, { 25, 30 }, { 29, 17 } }, 1), "#8a5a35")
  c:fill(c:line({ { 29, 17 }, { 32, 15 }, { 32, 13 } }, 1), "#aeb4bc")
  -- a leaf just cut, falling
  part(c, c:poly({ { 37, 19 }, { 45, 22 }, { 41, 27 }, { 36, 24 } }), "#4f9a45", { noline = true })
  fl(c, c:line({ { 37, 20 }, { 43, 25 } }, 1), "#2f6a32")
  spark(c, 31, 11, "#fffbe0", "#e8e8a0")
  finish(c, "r_ca_cacao_shade")
end

-- ca palm rethatch: rain through a gap in the palm roof, the toll-keeper catches it in her hat
function S.r_ca_palm_rethatch()
  seed = 60
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#56626e", "#627080", "#6f7d8d", "#7e8c9a" }, { dir = "v" })
  c:fill(R(c, 0, 31, W - 1, H - 1), "#4a6a74")
  c:fill(R(c, 0, 31, W - 1, 31), "#6a8c96")
  for _, p in ipairs({ { 7, 36 }, { 60, 38 }, { 8, 44 }, { 58, 46 } }) do c:fill(R(c, p[1], p[2], p[1] + 5, p[2]), "#7aa0aa") end
  -- jetty deck and posts
  part(c, R(c, 10, 44, 62, 47), "#8a5a35")
  for _, x in ipairs({ 13, 33, 58 }) do part(c, R(c, x, 47, x + 1, 49), "#5e3f28", { noline = true }) end
  part(c, R(c, 14, 20, 15, 44), "#6b4a2e", { noline = true }); part(c, R(c, 57, 20, 58, 44), "#6b4a2e", { noline = true })
  -- palm thatch roof with a gap
  part(c, c:poly({ { 36, 7 }, { 66, 22 }, { 6, 22 } }), "#c4a85a")
  for i = 0, 3 do
    for x = 8 + i * 2, 64 - i * 2, 4 do fl(c, R(c, x, 22 - i * 3 - 1, x + 1, 22 - i * 3 + 1), "#a88a3a") end
  end
  for x = 6, 66, 4 do fl(c, R(c, x, 22, x + 2, 23), "#a88a3a"); fl(c, R(c, x + 1, 24, x + 1, 24), "#a88a3a") end
  fl(c, R(c, 26, 15, 33, 19), "#6f7d8d")   -- gap showing storm sky
  c:outline(R(c, 26, 15, 33, 19), { ol = 1, olx = 0 })
  -- drips falling through the gap into the hat
  for _, x in ipairs({ 28, 31 }) do for y = 24, 36, 4 do c:px(x, y, "#a8d8ec"); c:px(x, y + 1, "#a8d8ec") end end
  -- the toll-keeper holding a straw hat up
  local _, G = gnome(c, 30, 45, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -5, 15 }, false, true), arm({ 4, 8 }, { 7, 15 }, true, true) } })
  local hx, hy = G.P(1, 15)
  part(c, c:ellipse(hx - 5, hy - 3, 5, 2), "#d9b84a", { noline = true })
  fl(c, R(c, hx - 8, hy - 4, hx - 2, hy - 4), "#4f9ac0")
  fl(c, R(c, hx - 5, hy - 2, hx - 1, hy - 2), "#c09a30")
  fl(c, R(c, hx - 10, hy - 3, hx - 9, hy - 2), "#f0c8a0"); fl(c, R(c, hx, hy - 3, hx + 1, hy - 2), "#f0c8a0")
  -- new fronds waiting on the deck
  part(c, c:poly({ { 44, 44 }, { 62, 44 }, { 60, 41 }, { 46, 41 } }), "#4f9a45")
  fl(c, R(c, 46, 42, 60, 42), "#7ab55c")
  rain(c, 36, 6, 46, "#c8dce8", 19)
  finish(c, "r_ca_palm_rethatch")
end

-- ca top spinning: chalk ring, spinning tops, the plaza children flinging strings
function S.r_ca_top_spinning()
  seed = 63
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  for i, p in ipairs({ { 5, 14, 14, "#e8907a" }, { 18, 10, 13, "#f5cf6a" }, { 32, 14, 12, "#8fc4d8" }, { 45, 11, 12, "#e8907a" }, { 58, 14, 11, "#b8d890" } }) do
    part(c, R(c, p[1], p[2], p[1] + p[3] - 1, 30), p[4])
    fl(c, R(c, p[1] + 3, 22, p[1] + 5, 30), "#6b3b2a")
    fl(c, R(c, p[1] + p[3] - 4, 17, p[1] + p[3] - 3, 19), "#4a6e9a")
    fl(c, R(c, p[1], p[2], p[1] + p[3] - 1, p[2]), "#c0442e")
  end
  c:fill(R(c, 0, 31, W - 1, H - 1), "#d9bc84"); fl(c, R(c, 0, 31, W - 1, 31), "#e8cc94")
  for _, p in ipairs({ { 6, 36 }, { 56, 34 }, { 64, 45 }, { 10, 48 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#b8965c") end
  -- the chalk ring
  c:fill(c:ellipse(36, 42, 20, 7), "#f4f0e0")
  c:fill(c:ellipse(36, 42, 18, 5), "#d9bc84")
  -- a little bump stone
  part(c, c:ellipse(42, 44, 2, 1), "#9a9ea6", { noline = true })
  -- tops: spinning red, spinning blue knocked sideways
  local function top(x, y, col)
    part(c, c:poly({ { x - 3, y - 4 }, { x + 3, y - 4 }, { x, y + 1 } }), col, { noline = false })
    fl(c, R(c, x - 3, y - 4, x + 3, y - 4), "#f5cf6a"); fl(c, R(c, x, y - 7, x, y - 5), "#5e3f28")
    c:px(x, y + 2, "#5e3f28")
  end
  top(30, 43, "#c0442e"); top(41, 41, "#3f6fb0")
  for _, p in ipairs({ { 24, 38 }, { 27, 36 }, { 46, 36 }, { 49, 38 } }) do c:px(p[1], p[2], "#fff6d8"); c:px(p[1] + 1, p[2], "#fff6d8") end
  fl(c, R(c, 27, 33, 33, 33), "#fff6d8"); fl(c, R(c, 38, 31, 44, 31), "#fff6d8")
  -- two flingers with strings
  local _, G = gnome(c, 12, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 4 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local hx, hy = G.P(9, 4)
  c:fill(c:line({ { hx, hy }, { hx - 3, hy - 3 }, { hx - 7, hy - 1 } }, 1), "#e8d8b0")
  gnome(c, 61, 46, { d = -1, s = 0.8, hat = "#3f8fb0", eyes = "open", arms = { arm({ -4, 7 }, { -8, 4 }, true) } })
  finish(c, "r_ca_top_spinning")
end

-- ca hawk lizard cactus: the hand game, two gnomes with pictogram bubbles
function S.r_ca_hawk_lizard()
  seed = 66
  local c = new()
  day(c, 38, { cloud = 30, sky = { "#a8d0e8", "#c0dcec", "#dcecee" }, hill = "#c9a060", hill2 = "#b88a50", grass = "#d9bc84", edge = "#e8cc94", tuft = "#b8965c" })
  cactus(c, 33, 38, 15, "#4e8a5a")
  cactus(c, 66, 38, 10, "#4e8a5a")
  -- flat rock with a lizard
  part(c, c:ellipse(36, 46, 6, 2), "#8b8f96", { shade = true })
  part(c, c:ellipse(36, 43, 4, 1), "#4f9a45", { noline = true })
  fl(c, R(c, 39, 43, 42, 43), "#4f9a45"); fl(c, R(c, 32, 44, 33, 44), "#4f9a45"); c:px(40, 42, INK)
  fl(c, R(c, 34, 42, 35, 42), "#7ab55c")
  -- the two players
  gnome(c, 14, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 12 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  gnome(c, 57, 47, { d = -1, hat = "#3f8fb0", eyes = "open", arms = { arm({ -4, 8 }, { -8, 11 }, true), arm({ 4, 6 }, { 5, 3 }, false) } })
  -- bubbles: hawk (left), cactus (right)
  part(c, c:rrect(10, 5, 22, 16, 2), "#f4eee0")
  c:fill(c:poly({ { 15, 16 }, { 17, 16 }, { 16, 19 } }), "#f4eee0")
  c:paint({ "b.....b", "bb...bb", ".bbbbb.", "..bbb..", "...y..."}, 12, 8, { b = "#7a4a2a", y = "#e8a317" })
  part(c, c:rrect(48, 5, 60, 16, 2), "#f4eee0")
  c:fill(c:poly({ { 54, 16 }, { 56, 16 }, { 56, 19 } }), "#f4eee0")
  c:paint({ "...g...", ".g.g.g.", ".g.g.g.", ".ggggg.", "...g...", "...g..." }, 50, 7, { g = "#3f8a52" })
  finish(c, "r_ca_hawk_lizard")
end

-- ca drum off: ferry crew drumming at each other across the dock, sound rings
function S.r_ca_drum_off()
  seed = 69
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:fill(R(c, 0, 24, W - 1, 36), "#4f9ac0"); fl(c, R(c, 0, 24, W - 1, 25), "#8fcbd8")
  for _, p in ipairs({ { 6, 29 }, { 40, 32 }, { 58, 28 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#a8dce4") end
  -- the ferry in the back
  part(c, c:poly({ { 10, 20 }, { 38, 20 }, { 35, 27 }, { 14, 27 } }), "#8a5a35")
  part(c, R(c, 16, 14, 22, 19), "#b07a45"); part(c, R(c, 24, 15, 29, 19), "#a8703e")
  fl(c, R(c, 16, 16, 22, 16), "#8a5a35")
  part(c, R(c, 35, 8, 36, 20), "#5e3f28", { noline = true })
  part(c, c:poly({ { 37, 9 }, { 50, 18 }, { 37, 18 } }), "#f4eee0")
  -- dock planks
  c:fill(R(c, 0, 37, W - 1, H - 1), "#b07a45")
  for y = 40, 49, 4 do fl(c, R(c, 0, y, W - 1, y), "#8a5a35") end
  fl(c, R(c, 0, 37, W - 1, 37), "#d9a660")
  for _, p in ipairs({ { 8, 40 }, { 30, 44 }, { 44, 41 }, { 64, 44 } }) do fl(c, R(c, p[1], p[2], p[1], p[2] + 3), "#8a5a35") end
  -- left drummer with a big barrel drum
  local function drum(x, y, w, h)
    part(c, R(c, x, y, x + w, y + h), "#8a5a35")
    fl(c, R(c, x + 1, y + 1, x + w - 1, y + 1), "#f4eee0")
    for i = 0, w - 2, 2 do fl(c, R(c, x + 1 + i, y + 2, x + 1 + i, y + h - 1), "#c0442e") end
    fl(c, R(c, x, y + 1, x + w, y + 1), "#e8d8b0")
  end
  drum(25, 37, 8, 8)
  drum(42, 40, 5, 6)
  local _, G1 = gnome(c, 14, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 10, 6 }, true), arm({ -4, 8 }, { 6, 10 }, true) } })
  local _, G2 = gnome(c, 56, 47, { d = -1, hat = "#3f8fb0", eyes = "open", arms = { arm({ -4, 8 }, { -9, 6 }, true), arm({ 4, 8 }, { -6, 12 }, true) } })
  for _, G in ipairs({ G1, G2 }) do
    local x, y = G.P(G == G1 and 10 or -9, 6)
    fl(c, R(c, x - 1, y - 1, x + 1, y + 1), "#f0c8a0")
  end
  -- sticks
  c:fill(c:line({ { 25, 33 }, { 21, 37 } }, 1), "#e8c48a"); c:fill(c:line({ { 37, 36 }, { 34, 40 } }, 1), "#e8c48a")
  -- sound rings: a big boom and a small tap
  local function ring(x, y, r)
    c:fill(c:line({ { x - r, y - r }, { x - r - 1, y }, { x - r, y + r } }, 1), "#fff1c8")
    c:fill(c:line({ { x + r, y - r }, { x + r + 1, y }, { x + r, y + r } }, 1), "#fff1c8")
  end
  ring(29, 33, 5); ring(29, 33, 8); ring(44, 36, 3)
  c:px(36, 30, "#f5cf6a"); c:px(37, 29, "#f5cf6a"); c:px(37, 30, "#f5cf6a")
  finish(c, "r_ca_drum_off")
end

-- ca chili stalls: strings of chilies from every awning, a gnome finds a new one
function S.r_ca_chili_stalls()
  seed = 72
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#e8c48a")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 12, x, 40), "#d9b070") end
  c:fill(R(c, 0, 41, W - 1, H - 1), "#c9a96e"); fl(c, R(c, 0, 41, W - 1, 41), "#d9bc84")
  local n = 0
  for x = 4, 68, 4 do
    local col = (n % 2 == 0) and "#4e8a3c" or "#f4eee0"
    fl(c, R(c, x, 5, x + 3, 10), col); fl(c, R(c, x + 1, 11, x + 2, 11), col); n = n + 1
  end
  -- ristras: strings of red, green, orange chilies
  local cols = { "#dd3a2a", "#4f9a45", "#e8a317", "#dd3a2a", "#3f8a42", "#c0442e", "#e8a317", "#dd3a2a" }
  for i, x in ipairs({ 9, 17, 25, 47, 55, 63 }) do
    local len = 18 + (i % 3) * 3
    fl(c, R(c, x, 12, x, 12 + len), "#8a5a35")
    for y = 13, 12 + len, 3 do
      local cc = cols[(i + floor(y / 3)) % #cols + 1]
      fl(c, R(c, x - 2, y, x - 1, y + 2), cc); fl(c, R(c, x + 1, y + 1, x + 2, y + 3), cc)
    end
  end
  -- baskets of chilies in front
  for _, b in ipairs({ { 12, "#dd3a2a" }, { 60, "#4f9a45" } }) do
    part(c, R(c, b[1] - 6, 42, b[1] + 6, 48), "#b07a45")
    for x = b[1] - 5, b[1] + 5, 2 do fl(c, R(c, x, 40 + (x % 3), x + 1, 43), b[2]) end
    fl(c, R(c, b[1] - 6, 44, b[1] + 6, 44), "#8a5a35")
  end
  -- the shopper holds up a strange new chili
  local _, G = gnome(c, 36, 47, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 6, 15 }, true, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local hx, hy = G.P(6, 15)
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  c:fill(c:line({ { hx, hy - 1 }, { hx + 1, hy - 4 }, { hx + 4, hy - 6 } }, 2), "#a84ab8")
  fl(c, R(c, hx - 1, hy - 2, hx, hy - 2), "#4f9a45")
  spark(c, hx - 4, hy - 6); spark(c, hx + 7, hy - 3)
  finish(c, "r_ca_chili_stalls")
end

-- ca barrens cacti: the scout sketches cacti, each drawn with a little face
function S.r_ca_barrens_cacti()
  seed = 75
  local c = new()
  day(c, 36, { cloud = 52, sky = { "#a8d0e8", "#c0dcec", "#dcecee" }, hill = "#c9a060", hill2 = "#b88a50", grass = "#d9bc84", edge = "#e8cc94", tuft = "#b8965c" })
  part(c, R(c, 55, 20, 60, 36), "#8a5a35"); part(c, R(c, 53, 17, 62, 20), "#b07a45"); fl(c, R(c, 56, 24, 58, 28), "#6b3b2a")
  -- cacti with faces
  cactus(c, 34, 44, 20, "#4e8a5a", { w = 6, face = "blush" })
  cactus(c, 49, 44, 12, "#5a9a62", { w = 6, face = true, arms = false })
  part(c, c:ellipse(63, 41, 4, 4), "#4e8a5a")
  for _, p in ipairs({ { 61, 40 }, { 64, 40 } }) do c:px(p[1], p[2], INK) end
  c:px(62, 43, INK); c:px(63, 43, INK)
  -- flowers on the barrel cactus
  c:px(63, 37, "#e46a9b"); c:px(62, 37, "#f6b8cf"); c:px(64, 37, "#f6b8cf")
  -- scout seated, sketchbook on knee, pencil in hand
  local _, G = gnome(c, 14, 45, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 9, 5 }, true, true) } })
  local bx, by = G.P(8, 6)
  part(c, R(c, bx, by - 3, bx + 5, by + 2), "#f4eee0"); fl(c, R(c, bx, by - 3, bx, by + 2), "#6b3b2a")
  fl(c, R(c, bx + 2, by - 1, bx + 3, by + 1), "#4e8a5a"); c:px(bx + 2, by - 2, "#4e8a5a")
  fl(c, R(c, bx - 1, by, bx, by + 1), "#f0c8a0")
  fl(c, R(c, bx + 6, by - 3, bx + 6, by - 1), "#e8a317")
  finish(c, "r_ca_barrens_cacti")
end

local order = {}
for l in io.lines("/tmp/claude-0/-home-user-gnome-venture/1b9189c1-3b2f-55fd-a82b-d2ac35c1c228/scratchpad/lists/h2.txt") do if #l > 0 then order[#order + 1] = l end end
for _, s2 in ipairs(order) do
  if (not only or only == s2) and S[s2] then seed = 7; S[s2]() end
end
