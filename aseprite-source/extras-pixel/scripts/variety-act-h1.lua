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

local function snowfall(c, n, sd, y0, y1, diag)
  seed = sd
  for i = 1, n do
    local x, y = 6 + floor(rand() * 62), y0 + floor(rand() * (y1 - y0))
    c:px(x, y, "#fbfdfe")
    if diag then c:px(x + 1, y - 1, "#fbfdfe") end
  end
end
local function steam(c, x, y, n, col)
  for i = 0, n - 1 do fl(c, R(c, x + (i % 2), y - i * 3, x + (i % 2) + 1, y - i * 3 + 1), col or "#f4f8fa") end
end
local function rtree(c, x, yb, r, col)
  part(c, R(c, x - 1, yb - r - 1, x + 1, yb), "#6b4a2e", { noline = true })
  part(c, c:ellipse(x, yb - r - 2, r, r), col or "#3f8a42", { shade = true })
end
local function spark(c, x, y, a, b)
  c:px(x, y, a or "#fff1c8"); c:px(x - 1, y, b or "#f5cf6a"); c:px(x + 1, y, b or "#f5cf6a"); c:px(x, y - 1, b or "#f5cf6a"); c:px(x, y + 1, b or "#f5cf6a")
end
local function bale(c, x0, y0, x1, y1)
  part(c, R(c, x0, y0, x1, y1), "#e0b858")
  fl(c, R(c, x0, y0 + 1, x1, y0 + 1), "#f0d078")
  for _, x in ipairs({ x0 + 2, x1 - 2 }) do fl(c, R(c, x, y0, x, y1), "#8a5a35") end
  for x = x0 + 3, x1 - 3, 2 do c:px(x, (y0 + y1) // 2 + 1, "#c89a3c") end
end
local SNOW, SNOWD = "#eef3f6", "#d3e0ea"
local function winter(c, g)
  c:bands(R(c, 0, 0, W - 1, g), { "#aecbe0", "#bfd6e6", "#d0e2ec", "#e0ecf0" }, { dir = "v" })
  c:fill(c:ellipse(14, g + 1, 26, 7), SNOWD); c:fill(c:ellipse(60, g, 24, 6), "#dae4ee")
  c:fill(R(c, 0, g, W - 1, H - 1), SNOW)
end

local S = {}

-- 1 test_ice
function S.test_ice()
  local c = new()
  winter(c, 28)
  pine(c, 9, 31, 15, true); pine(c, 17, 30, 10, true); pine(c, 63, 31, 15, true)
  c:fill(R(c, 0, 29, W - 1, 33), SNOW)
  c:fill(R(c, 0, 34, W - 1, H - 1), "#a8d0e0")
  c:fill(R(c, 0, 34, W - 1, 34), "#d8eaf2")
  c:fill(R(c, 0, 36, W - 1, 36), "#bcdcea")
  for _, p in ipairs({ { 8, 40 }, { 40, 38 }, { 56, 45 }, { 12, 49 }, { 44, 48 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#d8f0f8") end
  for _, p in ipairs({ { 50, 40, 60, 43 }, { 6, 44, 16, 41 } }) do c:fill(c:line({ { p[1], p[2] }, { p[3], p[4] } }, 1), "#7fa8c0") end
  -- ferry frozen in
  part(c, c:poly({ { 44, 31 }, { 64, 31 }, { 60, 37 }, { 48, 37 } }), "#8a5a35")
  part(c, R(c, 50, 25, 58, 31), "#c9a96e"); fl(c, R(c, 52, 27, 55, 29), "#7fa8c0")
  fl(c, R(c, 54, 20, 54, 25), "#5e3f28"); fl(c, R(c, 55, 20, 57, 21), "#dd3a2a")
  fl(c, R(c, 45, 36, 62, 36), "#f4f8fa")
  -- hole + auger
  c:fill(c:ellipse(22, 46, 5, 2), "#f4f8fa"); c:fill(c:ellipse(22, 46, 3, 1), "#1f4a78")
  fl(c, R(c, 21, 46, 23, 46), "#2f6290")
  c:fill(c:line({ { 22, 33 }, { 22, 46 } }, 2), "#8b929c")
  part(c, R(c, 17, 31, 27, 32), "#8a5a35")
  for _, y in ipairs({ 38, 41, 44 }) do c:px(23, y, "#d4dae0") end
  gnome(c, 38, 48, { d = -1, eyes = "open", arms = { arm({ -4, 7 }, { -10, 13 }, false), arm({ 4, 7 }, { -8, 12 }, true) } })
  for _, p in ipairs({ { 17, 44 }, { 27, 45 }, { 14, 47 }, { 29, 43 } }) do c:px(p[1], p[2], "#fbfdfe"); c:px(p[1] + 1, p[2] - 1, "#fbfdfe") end
  snowfall(c, 10, 5, 6, 30)
  finish(c, "r_na_test_ice")
end

-- 2 moose_lane
function S.moose_lane()
  local c = new()
  day(c, 33, { cloud = false, sky = { "#b9d9d0", "#cfe2cc", "#dce8c8" }, hill = "#3f6a32", hill2 = "#4e7a3a" })
  pine(c, 8, 36, 20, false); pine(c, 17, 34, 13, false); pine(c, 62, 36, 21, false); pine(c, 53, 34, 12, false)
  c:fill(c:poly({ { 30, 33 }, { 42, 33 }, { 70, 54 }, { 6, 54 } }), "#c9a96e")
  c:fill(c:poly({ { 33, 34 }, { 40, 34 }, { 56, 52 }, { 20, 52 } }), "#d9bc84")
  -- moose
  local B, BD = "#5e3f28", "#4a2c1a"
  for _, x in ipairs({ 33, 36, 45, 48 }) do part(c, R(c, x, 36, x + 1, 47), BD, { noline = true }) end
  part(c, c:ellipse(41, 33, 10, 5), B, { shade = true })
  part(c, c:ellipse(35, 30, 4, 4), BD)
  part(c, c:ellipse(30, 29, 4, 3), "#8a6040")
  part(c, c:poly({ { 28, 29 }, { 27, 36 }, { 23, 38 }, { 22, 35 }, { 25, 29 } }), "#8a6040")
  c:px(28, 28, "#f4eee0"); c:px(23, 36, "#2a1a10")
  -- antlers
  for _, a in ipairs({ { 29, 28, 26, 26, 24, 25 }, { 32, 28, 35, 26, 36, 25 } }) do
    c:fill(c:line({ { a[1], a[2] }, { a[3], a[4] } }, 2), "#e8c88a")
    c:fill(c:ellipse(a[5], a[6], 4, 3), "#e8c88a")
    for k = -3, 3, 2 do c:px(a[5] + k, a[6] - 4, "#e8c88a") end
    c:fill(c:ellipse(a[5], a[6], 2, 1), "#c9a060")
  end
  -- willow in the mouth
  c:fill(c:line({ { 23, 37 }, { 15, 31 } }, 1), "#7a9a3c")
  for _, p in ipairs({ { 16, 33 }, { 18, 35 }, { 14, 30 }, { 20, 36 } }) do fl(c, R(c, p[1] - 1, p[2] - 1, p[1], p[2]), "#8fc462") end
  c:px(22, 38, "#8fc462")
  -- gnome on a stump waiting
  part(c, R(c, 55, 43, 64, 49), "#8a5a35"); c:fill(c:ellipse(59.5, 43, 5, 1), "#e8c48a")
  gnome(c, 59, 43, { d = -1, sit = true, eyes = "shut", arms = { arm({ -4, 7 }, { -6, 4 }, true) } })
  fl(c, R(c, 7, 44, 9, 45), "#e46a9b")
  finish(c, "r_na_moose_lane")
end

-- 3 trim_wick (dusk, inside the lamp room)
function S.trim_wick()
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#6c6a7c")
  for y = 8, 40, 8 do fl(c, R(c, 0, y, W - 1, y), "#565468") end
  for y = 0, 40, 8 do for x = (y % 16 == 0) and 4 or 10, W - 1, 12 do fl(c, R(c, x, y, x, y + 7), "#565468") end end
  c:fill(R(c, 0, 41, W - 1, H - 1), "#8a5a35")
  for y = 44, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  -- arched window onto the dusk sea
  local win = c:rrect(7, 7, 25, 33, 6)
  c:bands(win, { "#3b2f66", "#6a4a88", "#b45a7c", "#e8825e", "#f0a868" }, { dir = "v" })
  c:fill(R(c, 7, 27, 25, 33), "#4a4a7c"); fl(c, R(c, 8, 29, 24, 29), "#6a6aa0")
  fl(c, R(c, 15, 25, 15, 27), "#2a1a10"); fl(c, R(c, 16, 24, 18, 27), "#f4eee0"); fl(c, R(c, 13, 27, 18, 28), "#2a1a10")
  c:px(11, 11, "#f4eee0"); c:px(20, 14, "#f4eee0")
  c:outline(win); c:fill(R(c, 6, 33, 26, 34), "#4a4a56")
  -- the great lamp
  c:fill(c:ellipse(54, 27, 15, 13), "#6a5a60")
  part(c, R(c, 46, 38, 62, 41), "#c8802a")
  part(c, R(c, 49, 35, 59, 38), "#e8a317")
  part(c, c:ellipse(54, 26, 8, 10), "#ffe9a8", { shade = true })
  c:fill(c:ellipse(54, 26, 6, 8), "#fff4cc")
  part(c, R(c, 52, 13, 56, 16), "#aeb4bc")
  c:fill(c:poly({ { 54, 14 }, { 58, 24 }, { 56, 33 }, { 52, 33 }, { 50, 24 } }), "#f08a24")
  c:fill(c:poly({ { 54, 18 }, { 56, 25 }, { 55, 32 }, { 53, 32 }, { 52, 25 } }), "#ffd86a")
  part(c, R(c, 53, 31, 55, 36), "#2a1a10", { noline = true })
  for _, p in ipairs({ { 40, 12 }, { 68, 20 }, { 44, 38 } }) do c:px(p[1], p[2], "#ffe08a") end
  -- gnome reaches up with tiny scissors
  gnome(c, 33, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 9, 14 }, true) } })
  c:fill(c:line({ { 43, 31 }, { 47, 27 } }, 1), "#e8ecf0"); c:fill(c:line({ { 43, 27 }, { 47, 31 } }, 1), "#e8ecf0")
  c:px(42, 32, "#8b929c"); c:px(42, 26, "#8b929c")
  c:px(48, 25, "#2a1a10"); c:px(49, 24, "#2a1a10")
  finish(c, "r_na_trim_wick")
end

-- 4 knock_rice (autumn marsh canoe)
function S.knock_rice()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#e8d8a8", "#f0e0b0", "#f4e8c0" }, { dir = "v" })
  c:fill(c:ellipse(16, 30, 30, 8), "#b8663a"); c:fill(c:ellipse(58, 30, 26, 7), "#c8802a")
  for _, p in ipairs({ { 10, 24 }, { 24, 25 }, { 50, 23 }, { 62, 25 } }) do c:fill(c:ellipse(p[1], p[2], 5, 5), (p[1] % 2 == 0) and "#d4742a" or "#c0442e") end
  c:fill(R(c, 0, 30, W - 1, H - 1), "#6aa0a0")
  c:fill(R(c, 0, 30, W - 1, 31), "#8fbcb0")
  for _, p in ipairs({ { 6, 36 }, { 20, 47 }, { 44, 48 }, { 60, 44 }, { 34, 34 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#8fc0bc") end
  -- reeds at the edges
  local function reed(x, y0, y1, col) c:fill(c:line({ { x, y1 }, { x + 1, y0 } }, 1), col); fl(c, R(c, x, y0, x + 1, y0 + 3), "#a8703e") end
  for _, x in ipairs({ 6, 9, 12, 63, 66 }) do reed(x, 22 + (x * 3) % 7, 38 + (x % 3), "#c9a850") end
  for _, x in ipairs({ 7, 10, 64, 67 }) do reed(x, 28 + x % 5, 49, "#b89840") end
  -- rear gnome poling
  gnome(c, 50, 43, { d = -1, upper = true, eyes = "open", arms = { arm({ -4, 7 }, { -6, 11 }, true), arm({ 4, 7 }, { 3, 4 }, true) } })
  c:fill(c:line({ { 44, 25 }, { 56, 52 } }, 1), "#8a5a35")
  -- front gnome knocking
  gnome(c, 28, 43, { d = 1, upper = true, hat = "#4f9a45", eyes = "happy", arms = { arm({ 4, 7 }, { 9, 5 }, true), arm({ -4, 7 }, { -7, 9 }, true) } })
  -- hull
  part(c, c:poly({ { 10, 37 }, { 18, 42 }, { 56, 42 }, { 62, 36 }, { 56, 46 }, { 16, 46 } }), "#b07a45", { shade = true })
  fl(c, R(c, 18, 42, 56, 42), "#d9a660")
  -- bent stalks and sticks
  c:fill(c:line({ { 38, 28 }, { 36, 34 }, { 34, 39 } }, 1), "#d9bc84"); c:fill(c:line({ { 40, 28 }, { 38, 34 }, { 37, 40 } }, 1), "#e0c88a")
  fl(c, R(c, 37, 26, 41, 30), "#a8703e")
  c:fill(c:line({ { 38, 36 }, { 33, 30 } }, 1), "#e8c48a")
  c:fill(c:line({ { 36, 33 }, { 40, 38 } }, 1), "#e8c48a")
  for _, p in ipairs({ { 30, 34 }, { 33, 37 }, { 41, 33 }, { 43, 36 }, { 35, 41 }, { 40, 41 } }) do c:px(p[1], p[2], "#f5cf6a") end
  finish(c, "r_na_knock_rice")
end

-- 5 dig_out
function S.dig_out()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 20), { "#b8c4d0", "#c8d2dc", "#d8e0e8" }, { dir = "v" })
  c:fill(R(c, 0, 21, W - 1, H - 1), "#e6edf3")
  -- inn wall
  part(c, R(c, 4, 12, 69, 42), "#a8703e")
  for x = 8, 66, 5 do fl(c, R(c, x, 14, x, 41), "#8a5a35") end
  part(c, R(c, 2, 6, 71, 13), "#7a4a2a")
  fl(c, R(c, 2, 4, 71, 8), "#f4f8fa"); fl(c, R(c, 6, 9, 66, 9), "#f4f8fa"); fl(c, R(c, 12, 10, 20, 10), "#f4f8fa")
  -- window
  part(c, R(c, 10, 19, 22, 30), "#8a5a35"); c:fill(R(c, 12, 21, 20, 28), "#ffd86a"); fl(c, R(c, 16, 21, 16, 28), "#8a5a35"); fl(c, R(c, 12, 25, 20, 25), "#8a5a35")
  fl(c, R(c, 9, 31, 23, 32), "#f4f8fa")
  -- door frame filled with a flat white wall
  part(c, R(c, 38, 15, 56, 44), "#5e3f28")
  c:fill(R(c, 40, 17, 54, 44), "#fbfdfe"); fl(c, R(c, 40, 17, 54, 18), "#e6edf3")
  fl(c, R(c, 41, 38, 53, 38), "#e6edf3"); fl(c, R(c, 43, 28, 44, 28), "#e6edf3")
  -- bewildered sparrow in the wall
  c:fill(c:ellipse(47, 28, 3, 2), "#8a5a35"); fl(c, R(c, 44, 27, 45, 27), "#b07a45"); c:px(49, 26, "#2a1a10"); c:px(50, 27, "#e8a317"); c:px(46, 25, "#6b3b2a")
  fl(c, R(c, 46, 30, 46, 31), "#6b3b2a"); fl(c, R(c, 48, 30, 48, 31), "#6b3b2a")
  -- front drift
  c:fill(c:ellipse(46, 45, 22, 6), "#fbfdfe"); c:fill(R(c, 24, 44, 70, 49), "#fbfdfe")
  fl(c, R(c, 34, 47, 56, 47), "#e6edf3")
  c:fill(c:ellipse(12, 46, 12, 4), "#fbfdfe")
  -- gnome with shovel, tossing a scoop
  gnome(c, 30, 49, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { 0, 12 }, false), arm({ 4, 7 }, { 7, 10 }, true) } })
  c:fill(c:line({ { 38, 40 }, { 36, 49 } }, 1), "#8a5a35")
  part(c, c:poly({ { 33, 47 }, { 39, 47 }, { 38, 51 }, { 34, 51 } }), "#aeb4bc")
  c:fill(c:ellipse(19, 36, 3, 2), "#fbfdfe"); c:px(15, 37, "#fbfdfe"); c:px(24, 35, "#fbfdfe"); c:px(17, 33, "#fbfdfe")
  snowfall(c, 26, 17, 6, 44, true)
  finish(c, "r_na_dig_out")
end

-- 6 owl_hoot
function S.owl_hoot()
  local c = new()
  day(c, 37, { cloud = false, sky = { "#b9d9d0", "#cfe2cc", "#dce8c8" }, hill = "#3f6a32", hill2 = "#4e7a3a" })
  pine(c, 10, 40, 24, false); pine(c, 20, 38, 14, false); pine(c, 62, 40, 26, false)
  -- hollow log den
  part(c, R(c, 36, 40, 52, 48), "#6b4a2e")
  c:fill(c:ellipse(37, 44, 3, 4), "#2a1a10"); fl(c, R(c, 40, 41, 50, 41), "#8a5a35")
  -- branch and owl
  part(c, R(c, 52, 22, 69, 24), "#6b4a2e")
  part(c, c:ellipse(60, 15, 5, 8), "#f4eee0", { shade = true })
  c:fill(c:ellipse(60, 8 + 5, 4, 4), "#fbfdfe")
  for _, p in ipairs({ { 58, 17 }, { 62, 18 }, { 60, 21 }, { 57, 14 }, { 63, 15 } }) do c:px(p[1], p[2], "#8b8f96") end
  fl(c, R(c, 57, 11, 58, 12), "#ffd86a"); fl(c, R(c, 61, 11, 62, 12), "#ffd86a"); c:px(58, 12, INK); c:px(62, 12, INK); c:px(60, 13, "#2a1a10")
  fl(c, R(c, 56, 21, 58, 22), "#e8a317"); fl(c, R(c, 61, 21, 63, 22), "#e8a317")
  -- gnome calling, hands cupped
  gnome(c, 25, 48, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { 3, 11 }, true), arm({ 4, 7 }, { 4, 11 }, true) } })
  for i = 0, 2 do
    local x, h = 34 + i * 4, 2 + i
    for dy = -h, h do c:px(x - (dy * dy) // h, 33 + dy, "#fbfdfe") end
  end
  c:px(46, 16, "#fbfdfe"); c:px(7, 28, "#e8a317")
  finish(c, "r_na_owl_hoot")
end

-- 7 sky_read
function S.sky_read()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#5a7ea8", "#7aa0c4", "#9cc0d8", "#bcd8e0", "#d8e6dc" }, { dir = "v" })
  -- far storm
  local function cloud(x, y, rx, ry, col) c:fill(c:ellipse(x, y, rx, ry), col) end
  cloud(54, 20, 14, 7, "#4a5470"); cloud(60, 15, 9, 6, "#5a6482"); cloud(46, 24, 8, 4, "#3a4260"); cloud(64, 24, 8, 5, "#3a4260")
  for _, x in ipairs({ 46, 52, 58, 64 }) do fl(c, R(c, x, 28, x, 33), "#7a8aa8"); fl(c, R(c, x - 1, 33, x - 1, 36), "#7a8aa8") end
  c:px(57, 21, "#f5e6a8"); c:px(58, 22, "#f5e6a8"); c:px(57, 23, "#f5e6a8")
  cloud(14, 10, 10, 2, "#f4eee0"); cloud(20, 9, 6, 2, "#f4eee0"); cloud(30, 17, 8, 2, "#e8eee8")
  c:fill(R(c, 0, 39, W - 1, H - 1), "#d4b060")
  c:fill(R(c, 0, 39, W - 1, 39), "#e8c878")
  for _, p in ipairs({ { 6, 44 }, { 18, 48 }, { 40, 47 }, { 55, 45 }, { 64, 49 }, { 30, 51 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#b8963c"); c:px(p[1] + 1, p[2] - 1, "#b8963c") end
  -- barn and hay in the middle distance
  part(c, R(c, 38, 31, 50, 39), "#a8452e")
  part(c, c:poly({ { 36, 32 }, { 44, 26 }, { 52, 32 } }), "#7a3322")
  fl(c, R(c, 42, 34, 46, 39), "#f4eee0")
  bale(c, 54, 34, 59, 39)
  part(c, c:ellipse(30, 38, 3, 3), "#e0b858")
  -- gnome shading eyes
  gnome(c, 18, 48, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -4, 4 }, false), arm({ 4, 8 }, { 6, 14 }, true) } })
  fl(c, R(c, 25, 33, 27, 33), "#f0c8a0")
  for _, y in ipairs({ 44, 47 }) do fl(c, R(c, 4, y, 8, y), "#f4eee0"); fl(c, R(c, 10, y, 11, y), "#f4eee0") end
  fl(c, R(c, 40, 15, 44, 15), "#f4eee0")
  finish(c, "r_na_sky_read")
end

-- 8 stump_rings
function S.stump_rings()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#9cc0a8", "#b0cfb0", "#c4dcb8" }, { dir = "v" })
  for _, x in ipairs({ 6, 14, 58, 66 }) do part(c, R(c, x, 4, x + 3, 36), "#6b4a2e", { noline = true }) end
  fl(c, R(c, 0, 4, W - 1, 8), "#4e8a3c"); c:fill(c:ellipse(36, 5, 30, 4), "#3f6a32")
  c:fill(R(c, 0, 30, W - 1, H - 1), "#7ea85a")
  -- trunk side with bark + roots
  part(c, R(c, 7, 31, 65, 44), "#6b4a2e")
  part(c, c:ellipse(36, 44, 29, 6), "#6b4a2e")
  for x = 10, 62, 4 do fl(c, R(c, x, 33, x, 40 + (x % 3)), "#4a2c1a") end
  part(c, c:poly({ { 8, 42 }, { 2, 48 }, { 12, 47 }, { 14, 44 } }), "#6b4a2e", { noline = true })
  part(c, c:poly({ { 64, 42 }, { 70, 49 }, { 60, 47 }, { 58, 44 } }), "#6b4a2e", { noline = true })
  -- top face with rings
  local top = c:ellipse(36, 31, 29, 9)
  part(c, top, "#e8c48a")
  for i = 1, 6 do c:fill(c:ellipse(36, 31, 29 - i * 4.2, 9 - i * 1.4):clip(top), (i % 2 == 1) and "#c08a52" or "#e8c48a") end
  fl(c, R(c, 35, 31, 37, 31), "#8a5a35")
  -- gnome pointing out a ring
  gnome(c, 24, 34, { s = 0.9, d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 4 }, false), arm({ 4, 7 }, { 8, 5 }, true) } })
  for i = 0, 3 do fl(c, R(c, 11 + i * 2, 38, 11 + i * 2, 41), "#f4eee0") end
  c:fill(c:line({ { 11, 41 }, { 17, 38 } }, 1), "#f4eee0")
  finish(c, "r_na_stump_rings")
end

local function fid(c, x, y) -- fiddlehead curl, 4x4
  c:paint({ ".gg.", "g..g", "g.gg", ".g.." }, x, y, { g = "#5aa83c" })
  c:px(x + 1, y + 1, "#8fc462")
end

-- 9 fiddlehead_fry (spring)
function S.fiddlehead_fry()
  local c = new()
  day(c, 30, { cloud = 14, hill = "#6aa050", hill2 = "#5a9a48", grass = "#8cb860", edge = "#a8d078" })
  -- blossom tree and creek
  part(c, R(c, 56, 12, 58, 30), "#6b4a2e", { noline = true })
  part(c, c:ellipse(57, 10, 10, 7), "#f0a8c0", { shade = true }); c:fill(c:ellipse(54, 8, 3, 2), "#f8d0de")
  c:fill(c:poly({ { 0, 33 }, { 36, 31 }, { 72, 33 }, { 72, 36 }, { 0, 37 } }), "#7cc9c8")
  fl(c, R(c, 8, 34, 14, 34), "#b8e8e0"); fl(c, R(c, 44, 35, 52, 35), "#b8e8e0")
  -- basket of curled fronds
  part(c, c:rrect(6, 40, 22, 48, 3), "#c8802a", { shade = true })
  for x = 8, 20, 3 do fl(c, R(c, x, 42, x, 47), "#8a5a35") end
  fid(c, 7, 35); fid(c, 12, 33); fid(c, 17, 35); fid(c, 10, 37); fid(c, 15, 38)
  for _, p in ipairs({ { 26, 48 }, { 28, 46 }, { 3, 49 } }) do c:px(p[1], p[2], "#8a5a35"); c:px(p[1] + 1, p[2], "#b07a45") end
  -- fire with pan on a tripod
  for _, p in ipairs({ { 44, 48 }, { 50, 49 }, { 56, 49 }, { 62, 48 } }) do part(c, c:ellipse(p[1], p[2], 3, 2), "#8b8f96", { shade = true }) end
  part(c, c:poly({ { 53, 40 }, { 56, 44 }, { 58, 48 }, { 48, 48 }, { 50, 44 } }), "#e0501f")
  c:fill(c:poly({ { 53, 43 }, { 55, 46 }, { 56, 48 }, { 50, 48 }, { 51, 46 } }), "#ffd86a")
  part(c, c:ellipse(53, 38, 10, 3), "#3a3a42")
  c:fill(c:ellipse(53, 37, 8, 2), "#4a4a54")
  part(c, R(c, 62, 36, 69, 37), "#5e3f28", { noline = true })
  for _, p in ipairs({ { 48, 36 }, { 53, 35 }, { 57, 36 } }) do fid(c, p[1], p[2] - 1) end
  steam(c, 52, 31, 3)
  gnome(c, 34, 48, { d = 1, eyes = "happy", arms = { arm({ -4, 7 }, { -5, 3 }, false), arm({ 4, 7 }, { 9, 9 }, true) } })
  c:fill(c:line({ { 43, 39 }, { 49, 37 } }, 1), "#8a5a35")
  finish(c, "r_na_fiddlehead_fry")
end

-- 10 cattail_fritters (front-on, marsh)
function S.cattail_fritters()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#c4d8c0", "#d4e4c4", "#e0ecc8" }, { dir = "v" })
  c:fill(R(c, 0, 24, W - 1, 38), "#7cb0a0"); fl(c, R(c, 0, 24, W - 1, 24), "#9cc8b8")
  for _, p in ipairs({ { 12, 30 }, { 30, 33 }, { 48, 28 }, { 60, 35 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#a8d4c4") end
  -- goose in the water, hissing
  part(c, c:ellipse(44, 31, 5, 3), "#f4eee0"); part(c, R(c, 48, 25, 49, 30), "#f4eee0", { noline = true })
  fl(c, R(c, 48, 24, 51, 25), "#f4eee0"); fl(c, R(c, 50, 25, 52, 25), "#e8a317"); c:px(49, 24, "#2a1a10")
  -- cattails
  for _, x in ipairs({ 8, 12, 17, 55, 60, 65 }) do
    c:fill(c:line({ { x, 38 }, { x + 1, 12 + (x * 5) % 7 } }, 1), "#5e8a44")
    part(c, R(c, x - 0, 10 + (x * 5) % 7, x + 1, 17 + (x * 5) % 7), "#6b3b2a", { noline = true })
  end
  c:fill(R(c, 0, 39, W - 1, H - 1), "#7ea85a"); fl(c, R(c, 0, 39, W - 1, 39), "#9cc070")
  -- fire & pan at right
  part(c, c:poly({ { 59, 40 }, { 62, 44 }, { 64, 49 }, { 54, 49 }, { 56, 44 } }), "#e0501f")
  c:fill(c:poly({ { 59, 44 }, { 61, 47 }, { 62, 49 }, { 56, 49 }, { 57, 47 } }), "#ffd86a")
  part(c, c:ellipse(59, 41, 10, 3), "#3a3a42"); c:fill(c:ellipse(59, 40, 8, 2), "#4a4a54")
  for _, x in ipairs({ 54, 59, 63 }) do part(c, c:ellipse(x, 40, 2, 1), "#e8a317", { noline = true }) end
  steam(c, 57, 33, 3); steam(c, 62, 31, 3)
  -- stump table, bowl, roots
  part(c, R(c, 8, 38, 40, 49), "#8a5a35"); fl(c, R(c, 8, 38, 40, 39), "#b07a45")
  for _, x in ipairs({ 14, 24, 34 }) do fl(c, R(c, x, 41, x, 48), "#6b3b2a") end
  part(c, c:ellipse(30, 38, 6, 3), "#b8b0a0", { shade = true }); c:fill(c:ellipse(30, 37, 4, 1), "#e8d8a8")
  part(c, R(c, 12, 35, 20, 36), "#f0e4c4"); part(c, R(c, 14, 33, 21, 34), "#e8d8a8")
  -- gnome pounding with a pestle
  gnome(c, 38, 44, { d = 1, upper = true, eyes = "open", arms = { arm({ 4, 7 }, { 4, 15 }, true), arm({ -4, 7 }, { -6, 4 }, true) } })
  part(c, R(c, 42, 25, 43, 33), "#c9a96e", { noline = true }); fl(c, R(c, 41, 23, 44, 25), "#c9a96e")
  finish(c, "r_na_cattail_fritters")
end

-- 11 crowberry_cordial (hot pool, snow)
function S.crowberry_cordial()
  local c = new()
  winter(c, 26)
  pine(c, 9, 30, 15, true); pine(c, 18, 28, 10, true); pine(c, 63, 30, 16, true)
  c:fill(R(c, 0, 27, W - 1, 31), SNOW)
  -- pool
  part(c, c:ellipse(40, 43, 26, 9), "#8b8f96", { shade = true })
  c:fill(c:ellipse(40, 43, 22, 6), "#58b4c4")
  fl(c, R(c, 28, 43, 36, 43), "#8fd8dc"); fl(c, R(c, 44, 45, 54, 45), "#8fd8dc")
  -- pot in the pool
  part(c, c:rrect(33, 31, 49, 44, 3), "#c0642e", { shade = true })
  c:fill(c:ellipse(41, 33, 8, 2), "#5a1a40"); c:fill(c:ellipse(41, 33, 6, 1), "#7a2a60")
  for _, p in ipairs({ { 38, 33 }, { 42, 32 }, { 44, 33 } }) do c:px(p[1], p[2], "#a04a88") end
  c:fill(c:ellipse(41, 44, 12, 1), "#58b4c4")
  steam(c, 38, 28, 4); steam(c, 44, 27, 5); steam(c, 14, 40, 4); steam(c, 66, 40, 4)
  -- keeper stirring from the rim
  gnome(c, 18, 49, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 3 }, false), arm({ 4, 7 }, { 10, 11 }, true) } })
  c:fill(c:line({ { 28, 37 }, { 38, 32 } }, 1), "#8a5a35")
  part(c, c:ellipse(38, 32, 2, 1), "#8a5a35", { noline = true })
  -- bottles and berries on the snow
  for i, x in ipairs({ 62, 66 }) do part(c, R(c, x, 36, x + 2, 42), "#7a2a60"); fl(c, R(c, x, 34, x + 2, 35), "#6b3b2a") end
  part(c, c:ellipse(62, 49, 5, 2), "#a8703e"); for _, x in ipairs({ 59, 61, 63, 65 }) do c:px(x, 48, "#3a1a50") end
  for _, p in ipairs({ { 8, 47 }, { 10, 49 }, { 26, 51 }, { 30, 50 }, { 6, 44 } }) do c:px(p[1], p[2], "#3a1a50"); c:px(p[1] + 1, p[2], "#5a2a70") end
  snowfall(c, 10, 9, 6, 24)
  finish(c, "r_na_crowberry_cordial")
end

-- 12 bog_jam
function S.bog_jam()
  local c = new()
  day(c, 31, { cloud = 50 })
  -- orchard row
  for _, x in ipairs({ 10, 34 }) do rtree(c, x, 36, 6, "#4e9a48"); c:px(x - 2, 25, "#dd3a2a"); c:px(x + 3, 27, "#dd3a2a") end
  -- market table with jars
  part(c, R(c, 52, 33, 69, 36), "#b07a45"); fl(c, R(c, 53, 33, 68, 33), "#d9a660")
  part(c, R(c, 54, 36, 55, 46), "#8a5a35", { noline = true }); part(c, R(c, 66, 36, 67, 46), "#8a5a35", { noline = true })
  for i, col in ipairs({ "#4a3a98", "#c0442e", "#4a3a98" }) do
    part(c, R(c, 53 + (i - 1) * 5, 27, 56 + (i - 1) * 5, 32), col); fl(c, R(c, 53 + (i - 1) * 5, 25, 56 + (i - 1) * 5, 26), "#f4eee0")
  end
  -- fire + pot
  part(c, c:poly({ { 36, 42 }, { 40, 46 }, { 44, 49 }, { 28, 49 }, { 32, 46 } }), "#e0501f")
  c:fill(c:poly({ { 36, 45 }, { 38, 47 }, { 40, 49 }, { 32, 49 }, { 34, 47 } }), "#ffd86a")
  part(c, c:rrect(26, 34, 46, 46, 4), "#aeb4bc", { shade = true })
  c:fill(c:ellipse(36, 35, 9, 2), "#4a3a98")
  c:fill(R(c, 31, 34, 36, 35), "#c0442e"); fl(c, R(c, 36, 36, 40, 36), "#c0442e"); fl(c, R(c, 29, 36, 33, 36), "#4a3a98")
  c:fill(c:line({ { 36, 20 }, { 36, 36 } }, 1), "#c9a96e"); part(c, R(c, 35, 17, 37, 20), "#c9a96e", { noline = true })
  c:px(36, 32, "#c0442e"); c:px(35, 28, "#4a3a98")
  -- baskets
  part(c, c:rrect(2, 41, 14, 48, 2), "#c8802a"); for _, x in ipairs({ 4, 6, 8, 10, 12 }) do c:fill(c:ellipse(x, 41, 1, 1), "#3f5ab0") end
  part(c, c:rrect(14, 44, 24, 49, 2), "#c8802a"); for _, x in ipairs({ 16, 18, 20, 22 }) do c:fill(c:ellipse(x, 44, 1, 1), "#dd3a2a") end
  -- gnome stirring, steady
  gnome(c, 56, 49, { d = -1, eyes = "shut", arms = { arm({ -4, 7 }, { -10, 13 }, true), arm({ 4, 7 }, { 4, 4 }, false) } })
  steam(c, 31, 28, 3, "#f4f8fa")
  finish(c, "r_na_bog_jam")
end

-- 13 rail_fence
function S.rail_fence()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#7aa8d0", "#9cc4de", "#bcd8e4", "#d8e6dc" }, { dir = "v" })
  c:fill(c:ellipse(20, 11, 12, 3), "#f4eee0"); c:fill(c:ellipse(52, 8, 9, 2), "#f4eee0")
  c:fill(c:ellipse(18, 36, 34, 7), "#b8a850"); c:fill(R(c, 0, 34, W - 1, H - 1), "#c8b45c")
  fl(c, R(c, 0, 34, W - 1, 34), "#d8c874")
  for _, p in ipairs({ { 8, 46 }, { 22, 50 }, { 52, 49 }, { 66, 46 }, { 40, 51 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#a89840"); c:px(p[1] + 1, p[2] - 1, "#a89840") end
  -- zigzag fence panels left and right of a gap
  local function panel(x0, n)
    for lv = 0, 2 do
      local y = 47 - lv * 7
      for k = 0, n - 1 do
        local xa = x0 + k * 13
        local up = (k + lv) % 2 == 0
        c:fill(c:line({ { xa, up and y or y - 6 }, { xa + 13, up and y - 6 or y } }, 2), (lv % 2 == 0) and "#a8703e" or "#7a4a2a")
      end
    end
  end
  panel(4, 2); panel(48, 2)
  for _, p in ipairs({ { 33, 47 }, { 38, 50 }, { 43, 46 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#8a7a30") end
  -- the rail being carried to the gap
  c:fill(c:line({ { 25, 46 }, { 52, 32 } }, 2), "#c08a52"); fl(c, R(c, 24, 46, 26, 47), "#e8c48a")
  gnome(c, 38, 50, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 11 }, false), arm({ 4, 7 }, { 3, 13 }, true) } })
  finish(c, "r_na_rail_fence")
end

-- 14 hop_bines
function S.hop_bines()
  local c = new()
  day(c, 38, { cloud = 56, hill = "#5e8a44", hill2 = "#4e8a3c" })
  part(c, R(c, 7, 8, 9, 46), "#6b4a2e", { noline = true }); part(c, R(c, 63, 8, 65, 46), "#6b4a2e", { noline = true })
  fl(c, R(c, 7, 9, 65, 10), "#3d2a1c")
  for _, x in ipairs({ 18, 36, 54 }) do fl(c, R(c, x, 11, x, 46), "#e8d8a8") end
  local offs = { 0, 1, 1, 0, -1, -1 }
  local function bine(x, y0, y1)
    for y = y1, y0, -1 do
      local dx = offs[(y % 6) + 1]
      fl(c, R(c, x + dx - 1, y, x + dx, y), "#4e9a48")
    end
    for y = y1 - 3, y0 + 2, -7 do
      local side = ((y // 7) % 2 == 0) and 1 or -1
      c:fill(c:ellipse(x + side * 4, y, 2, 1), "#6ab45a")
      local cx = x - side * 3
      part(c, R(c, cx, y + 2, cx + 1, y + 5), "#b8d868", { noline = true }); c:px(cx, y + 3, "#d8ec98")
    end
  end
  bine(18, 12, 46)
  bine(36, 31, 46)
  -- the stray bine on the right string, drooping off sideways
  bine(54, 38, 46)
  c:fill(c:line({ { 54, 38 }, { 59, 41 }, { 62, 46 } }, 1), "#4e9a48")
  c:fill(c:ellipse(60, 41, 2, 1), "#6ab45a")
  -- gnome winds the bine tip the right way round
  gnome(c, 28, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 3 }, false), arm({ 4, 8 }, { 8, 16 }, true) } })
  c:fill(c:line({ { 36, 32 }, { 33, 28 }, { 36, 25 } }, 1), "#4e9a48"); c:px(37, 24, "#6ab45a"); c:px(38, 23, "#6ab45a")
  -- sun with a clockwise arrow
  c:fill(c:ellipse(59, 20, 3, 3), "#f5cf6a")
  for _, p in ipairs({ { 52, 14 }, { 54, 12 }, { 57, 12 } }) do c:px(p[1], p[2], "#e8a317") end
  c:px(58, 13, "#e8a317"); c:px(58, 11, "#e8a317"); c:px(57, 14, "#e8a317")
  finish(c, "r_na_hop_bines")
end

-- 15 root_cellar
function S.root_cellar()
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#5a3a28")
  seed = 61
  for i = 1, 40 do c:px(6 + floor(rand() * 62), 6 + floor(rand() * 42), (i % 2 == 0) and "#4a2c1a" or "#6b4a2e") end
  c:fill(R(c, 0, 45, W - 1, H - 1), "#7a5030"); fl(c, R(c, 0, 45, W - 1, 45), "#9a6a3c")
  -- daylight at the stairs, top left
  c:fill(c:poly({ { 0, 0 }, { 20, 0 }, { 20, 8 }, { 8, 8 }, { 0, 14 } }), "#cfe8e6")
  for i = 0, 3 do part(c, R(c, 4 + i * 4, 9 + i * 4, 24 + i * 0, 11 + i * 4), "#a8703e") end
  c:fill(R(c, 0, 12, 4, 49), "#4a2c1a")
  -- posts and shelf
  part(c, R(c, 28, 8, 30, 45), "#8a5a35", { noline = true }); part(c, R(c, 66, 8, 68, 45), "#8a5a35", { noline = true })
  part(c, R(c, 29, 24, 68, 25), "#b07a45"); part(c, R(c, 29, 35, 68, 36), "#b07a45")
  for i = 0, 7 do
    local x = 33 + i * 4
    part(c, c:ellipse(x, 22, 2, 2), "#dd3a2a", { noline = true }); c:px(x, 21, "#ff8a6a"); c:px(x, 19, "#4e8a3c")
  end
  for i = 0, 3 do part(c, R(c, 33 + i * 9, 28, 38 + i * 9, 34), (i % 2 == 0) and "#4a3a98" or "#c8802a"); fl(c, R(c, 33 + i * 9, 27, 38 + i * 9, 27), "#f4eee0") end
  -- sacks of beans and pumpkins on straw (floor)
  part(c, R(c, 8, 38, 16, 46), "#d9bc84"); fl(c, R(c, 9, 38, 15, 39), "#e8d8a8"); fl(c, R(c, 8, 40, 16, 40), "#8a5a35")
  part(c, R(c, 17, 40, 24, 46), "#e0c88a"); fl(c, R(c, 18, 40, 23, 40), "#8a5a35")
  c:fill(c:ellipse(52, 46, 14, 2), "#e0b858")
  for i = 0, 6 do c:px(40 + i * 4, 44 + (i % 2), "#c89a3c") end
  for _, p in ipairs({ { 47, 42 }, { 56, 42 } }) do
    part(c, c:ellipse(p[1], p[2], 5, 4), "#e8821e", { shade = true }); fl(c, R(c, p[1], p[2] - 4, p[1], p[2] + 3), "#c0641a"); fl(c, R(c, p[1] - 1, p[2] - 6, p[1] + 1, p[2] - 5), "#4e8a3c")
  end
  -- lantern
  fl(c, R(c, 44, 5, 44, 8), "#2a1a10"); part(c, R(c, 42, 9, 46, 14), "#ffd86a", { cres = 1 }); fl(c, R(c, 43, 10, 45, 12), "#fff1c8")
  c:px(40, 12, "#f8c070"); c:px(48, 12, "#f8c070")
  -- gnome carries a pumpkin to the straw
  gnome(c, 38, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 7 }, { 7, 8 }, true, true) } })
  part(c, c:ellipse(46, 36, 5, 4), "#e8821e", { shade = true }); fl(c, R(c, 46, 32, 46, 39), "#c0641a"); fl(c, R(c, 45, 30, 47, 31), "#4e8a3c")
  fl(c, R(c, 41, 38, 43, 40), "#f0c8a0"); fl(c, R(c, 49, 38, 50, 40), "#f0c8a0")
  finish(c, "r_na_root_cellar")
end

-- 16 toboggan
function S.toboggan()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#aecbe0", "#bfd6e6", "#d0e2ec", "#e0ecf0" }, { dir = "v" })
  c:fill(c:ellipse(60, 30, 24, 7), "#d3e0ea")
  pine(c, 64, 33, 16, true); pine(c, 56, 31, 11, true)
  c:fill(R(c, 0, 40, W - 1, H - 1), "#dae4ee")
  c:fill(c:poly({ { 0, 24 }, { 5, 24 }, { 72, 44 }, { 72, 54 }, { 0, 54 } }), "#fbfdfe")
  c:fill(c:line({ { 5, 28 }, { 72, 48 } }, 1), "#e6edf3")
  -- watchtower at the top
  part(c, R(c, 8, 14, 9, 25), "#6b4a2e", { noline = true }); part(c, R(c, 15, 14, 16, 25), "#6b4a2e", { noline = true })
  part(c, R(c, 6, 9, 18, 14), "#a8703e"); fl(c, R(c, 8, 11, 16, 11), "#6b3b2a")
  part(c, c:poly({ { 12, 2 }, { 20, 9 }, { 4, 9 } }), "#c0442e")
  fl(c, R(c, 12, 0, 12, 2), "#5e3f28")
  local function racer(x, hat, pose)
    local oy = 24 + floor((x - 5) * 0.29) - 1
    -- sled
    part(c, R(c, x - 5, oy + 1, x + 9, oy + 2), "#8a5a35")
    fl(c, R(c, x + 9, oy - 1, x + 10, oy + 1), "#8a5a35")
    local arms = (pose == "tuck") and { arm({ 2, 5 }, { 6, 4 }, true) } or { arm({ 2, 6 }, { 6, 9 }, true) }
    gnome(c, x, oy, { s = 0.8, d = 1, sit = true, hat = hat, eyes = "open", arms = arms })
    if pose == "drag" then fl(c, R(c, x + 4, oy + 2, x + 7, oy + 3), "#5a3a22"); fl(c, R(c, x + 1, oy + 3, x + 4, oy + 4), "#d3e0ea") end
    for i = 1, 3 do fl(c, R(c, x - 9 - i * 3, oy - 3 + i * 2, x - 8 - i * 3, oy - 3 + i * 2), "#aac4d8") end
  end
  racer(20, "#3f6fb0", "tuck")
  racer(37, nil, "drag")
  racer(54, "#e8a317", "lean")
  -- finish flag
  fl(c, R(c, 66, 38, 66, 48), "#5e3f28")
  for i = 0, 3 do for j = 0, 1 do fl(c, R(c, 67 + i, 38 + j * 2, 67 + i, 39 + j * 2), ((i + j) % 2 == 0) and "#2a1a10" or "#f4eee0") end end
  snowfall(c, 8, 33, 6, 24)
  finish(c, "r_na_toboggan")
end

-- 17 ring_board
function S.ring_board()
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 44), "#8a5a35")
  for x = 3, W - 1, 8 do fl(c, R(c, x, 0, x, 44), "#6b3b2a") end
  c:fill(R(c, 0, 45, W - 1, H - 1), "#6b3b2a")
  -- hearth at right
  part(c, R(c, 52, 12, 68, 36), "#8b8f96"); fl(c, R(c, 52, 20, 68, 20), "#6a6e76"); fl(c, R(c, 60, 12, 60, 20), "#6a6e76")
  c:fill(R(c, 55, 26, 65, 36), "#2a1a10")
  c:fill(c:poly({ { 60, 28 }, { 63, 36 }, { 57, 36 } }), "#e0501f"); c:fill(c:poly({ { 60, 31 }, { 62, 36 }, { 58, 36 } }), "#ffd86a")
  -- table
  part(c, c:poly({ { 16, 44 }, { 23, 32 }, { 70, 32 }, { 70, 44 } }), "#b07a45")
  part(c, R(c, 16, 44, 70, 46), "#8a5a35")
  part(c, R(c, 20, 46, 22, 50), "#6b3b2a", { noline = true }); part(c, R(c, 66, 46, 68, 50), "#6b3b2a", { noline = true })
  -- the board
  part(c, c:ellipse(44, 38, 18, 6), "#e8c48a", { shade = true })
  c:fill(c:ellipse(44, 38, 16, 5), "#7a4a2a")
  c:fill(c:ellipse(44, 38, 3, 1), "#2a1a10")
  for i = 0, 7 do
    local a = i * math.pi / 4
    local px, py = 44 + rnd(math.cos(a) * 11), 38 + rnd(math.sin(a) * 3.2)
    fl(c, R(c, px, py - 1, px, py), "#f0d49e")
  end
  
  -- the flicked disc and its trail
  part(c, c:ellipse(32, 39, 2, 1), "#f4eee0", { noline = true })
  for i = 1, 3 do fl(c, R(c, 26 - i * 2, 39, 27 - i * 2, 39), "#e8c48a") end
  -- mug and candle
  part(c, R(c, 61, 30, 65, 34), "#aeb4bc"); fl(c, R(c, 66, 31, 67, 33), "#8b929c")
  gnome(c, 11, 49, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 11, 9 }, true), arm({ -4, 7 }, { -5, 3 }, false) } })
  fl(c, R(c, 23, 40, 25, 41), "#f0c8a0")
  spark(c, 32, 30, "#fff1c8", "#f5cf6a")
  finish(c, "r_na_ring_board")
end

-- 18 loon_calls (dawn)
function S.loon_calls()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#3b4a7a", "#6a5a8c", "#a8688a", "#e08a78", "#f0b080", "#f8d098" }, { dir = "v" })
  c:fill(c:ellipse(50, 31, 7, 7):clip(R(c, 0, 0, W - 1, 30)), "#fff0c0")
  c:fill(c:poly({ { 0, 30 }, { 0, 20 }, { 12, 24 }, { 24, 17 }, { 38, 26 }, { 72, 30 } }), "#5a5a88")
  for _, p in ipairs({ { 8, 33, 17 }, { 16, 32, 12 }, { 64, 33, 18 }, { 56, 32, 11 } }) do
    local x, yb, h = p[1], p[2], p[3]
    c:fill(c:poly({ { x, yb - h }, { x + 4, yb }, { x - 4, yb } }), "#2f3a58")
  end
  c:bands(R(c, 0, 31, W - 1, H - 1), { "#f0b080", "#d8908a", "#a8688a", "#6a5a8c", "#4a5a8a" }, { dir = "v" })
  for _, p in ipairs({ { 44, 32, 12 }, { 20, 36, 8 }, { 8, 45, 10 } }) do fl(c, R(c, p[1], p[2], p[1] + p[3], p[2]), "#f8d098") end
  for _, p in ipairs({ { 6, 33, 10 }, { 40, 34, 12 }, { 56, 35, 8 } }) do fl(c, R(c, p[1], p[2], p[1] + p[3], p[2]), "#fbe8d0") end
  -- jetty
  part(c, R(c, 4, 41, 34, 43), "#8a5a35")
  for _, x in ipairs({ 8, 18, 30 }) do part(c, R(c, x, 43, x + 1, 50), "#6b3b2a", { noline = true }) end
  gnome(c, 11, 41, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 3 }, false), arm({ 4, 8 }, { 3, 11 }, true) } })
  gnome(c, 25, 41, { d = 1, hat = "#4f9a45", eyes = "open", arms = { arm({ -4, 7 }, { -5, 3 }, false), arm({ 4, 8 }, { 3, 11 }, true) } })
  -- the loon, listening
  c:fill(c:ellipse(53, 41, 7, 3), "#2a2a34")
  c:fill(R(c, 58, 33, 59, 40), "#2a2a34"); c:fill(c:ellipse(58, 32, 2, 2), "#2a2a34")
  fl(c, R(c, 60, 32, 63, 32), "#2a2a34"); c:px(58, 31, "#dd3a2a")
  fl(c, R(c, 57, 36, 59, 36), "#f4eee0"); fl(c, R(c, 57, 38, 59, 38), "#f4eee0")
  for _, p in ipairs({ { 50, 40 }, { 53, 39 }, { 48, 41 }, { 55, 41 } }) do c:px(p[1], p[2], "#f4eee0") end
  fl(c, R(c, 44, 44, 62, 44), "#fbe8d0"); fl(c, R(c, 40, 46, 66, 46), "#c88090")
  for i = 0, 2 do
    local x, h = 34 + i * 3, 2 + i
    for dy = -h, h do c:px(x - (dy * dy) // h, 33 + dy, "#fff0c0") end
  end
  finish(c, "r_na_loon_calls")
end

-- 19 quilt_blocks
function S.quilt_blocks()
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 44), "#a8703e")
  for x = 3, W - 1, 8 do fl(c, R(c, x, 0, x, 44), "#8a5a35") end
  c:fill(R(c, 0, 45, W - 1, H - 1), "#6b3b2a")
  fl(c, R(c, 0, 45, W - 1, 45), "#8a5a35")
  -- frosty window
  part(c, R(c, 44, 8, 62, 26), "#6b3b2a"); c:fill(R(c, 46, 10, 60, 24), "#bcd6e6"); fl(c, R(c, 53, 10, 53, 24), "#6b3b2a"); fl(c, R(c, 46, 17, 60, 17), "#6b3b2a")
  for _, p in ipairs({ { 48, 12 }, { 56, 20 }, { 49, 21 }, { 58, 13 } }) do c:px(p[1], p[2], "#fbfdfe") end
  -- stove
  part(c, R(c, 11, 8, 12, 28), "#3a3a42", { noline = true })
  part(c, c:ellipse(12, 37, 8, 8), "#4a4a54", { shade = true })
  part(c, R(c, 6, 44, 18, 47), "#3a3a42")
  part(c, R(c, 9, 33, 15, 40), "#ffd86a"); fl(c, R(c, 11, 35, 13, 38), "#e0501f")
  c:fill(c:ellipse(12, 29, 4, 2), "#3a3a42")
  steam(c, 20, 40, 3, "#d9a660")
  -- chair and the seated quilter
  part(c, R(c, 56, 28, 58, 47), "#6b3b2a", { noline = true }); part(c, R(c, 52, 42, 60, 44), "#8a5a35")
  gnome(c, 50, 43, { d = -1, sit = true, eyes = "open", arms = { arm({ -4, 7 }, { -8, 5 }, true) } })
  -- the patchwork over the knees, with block patterns
  local cols = { "#c0442e", "#f4eee0", "#3f6fb0", "#e8a317", "#4f9a45", "#e46a9b" }
  for gy = 0, 2 do for gx = 0, 4 do
    local x0, y0 = 22 + gx * 6, 39 + gy * 4
    local k = (gx * 2 + gy * 3) % 6
    part(c, R(c, x0, y0, x0 + 5, y0 + 3), cols[k + 1])
    fl(c, R(c, x0 + 2, y0 + 1, x0 + 3, y0 + 2), cols[(k + 2) % 6 + 1])
  end end
  fl(c, R(c, 36, 41, 40, 41), "#f4eee0")
  -- needle and thread
  fl(c, R(c, 40, 34, 40, 37), "#e8ecf0"); c:px(41, 33, "#e8ecf0"); c:px(42, 32, "#dd3a2a"); c:px(43, 33, "#dd3a2a")
  -- sewing basket
  part(c, c:rrect(2, 47, 10, 52, 1), "#c8802a"); fl(c, R(c, 3, 45, 4, 46), "#dd3a2a"); fl(c, R(c, 6, 45, 7, 46), "#3f6fb0")
  finish(c, "r_na_quilt_blocks")
end

-- 20 shallows_pools (fog)
function S.shallows_pools()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 26), { "#b8c8d0", "#c4d0d6", "#d0dade", "#dce4e6" }, { dir = "v" })
  -- faint lighthouse in the fog
  c:fill(c:poly({ { 54, 8 }, { 58, 8 }, { 60, 26 }, { 52, 26 } }), "#c0ccd2"); fl(c, R(c, 53, 6, 59, 8), "#b0bec6")
  fl(c, R(c, 55, 3, 57, 5), "#ccd6da")
  c:fill(R(c, 0, 24, W - 1, 28), "#a8bcc6"); fl(c, R(c, 0, 24, W - 1, 24), "#c8d6dc")
  c:fill(R(c, 0, 29, W - 1, H - 1), "#b8a888")
  for _, p in ipairs({ { 6, 30 }, { 20, 33 }, { 60, 31 }, { 66, 36 } }) do
    part(c, c:ellipse(p[1], p[2], 6, 3), "#6a6a72", { shade = true })
  end
  -- the pool
  part(c, c:ellipse(47, 42, 20, 8), "#6a6a72", { shade = true })
  c:fill(c:ellipse(47, 42, 17, 6), "#7aa8b8"); c:fill(c:ellipse(47, 41, 13, 3), "#9cc8d4")
  fl(c, R(c, 40, 40, 46, 40), "#c8e4ea")
  -- things that move
  c:paint({ "..o..", "..o..", "ooooo", ".o.o.", "o...o" }, 36, 41, { o = "#e8821e" }); c:px(38, 43, "#f5cf6a")
  part(c, c:ellipse(53, 43, 3, 2), "#dd3a2a", { noline = true })
  fl(c, R(c, 50, 40, 50, 41), "#dd3a2a"); fl(c, R(c, 56, 40, 56, 41), "#dd3a2a"); c:px(52, 41, "#2a1a10"); c:px(54, 41, "#2a1a10")
  c:fill(c:ellipse(45, 46, 3, 1), "#c06a9a"); for x = 43, 47, 2 do c:px(x, 45, "#e08ab8") end
  part(c, c:ellipse(60, 38, 2, 1), "#c8a878", { noline = true })
  -- gnome peering in
  gnome(c, 18, 49, { d = 1, sit = true, eyes = "open", arms = { arm({ 4, 7 }, { 9, 4 }, true) } })
  c:px(27, 38, "#f4f8fa"); c:px(30, 36, "#f4f8fa")
  finish(c, "r_na_shallows_pools")
end

-- 21 trail_tracks
function S.trail_tracks()
  local c = new()
  winter(c, 28)
  pine(c, 9, 32, 17, true); pine(c, 18, 30, 11, true); pine(c, 60, 31, 15, true); pine(c, 68, 32, 12, true)
  c:fill(R(c, 0, 29, W - 1, 33), SNOW)
  c:fill(c:poly({ { 34, 33 }, { 52, 33 }, { 72, 54 }, { 12, 54 } }), "#dfe8f0")
  -- tracks wander off to the pines
  local P = { { 26, 50 }, { 31, 47 }, { 36, 44 }, { 40, 41 }, { 43, 39 }, { 46, 37 }, { 48, 36 }, { 50, 35 } }
  for i, p in ipairs(P) do
    local x, y = p[1] + ((i % 2 == 0) and 3 or 0), p[2]
    if i <= 5 then
      fl(c, R(c, x, y, x + 2, y + 1), "#5a7898")
      for _, dx in ipairs({ -1, 0, 2, 3 }) do c:px(x + dx, y - 2, "#5a7898") end
    else
      fl(c, R(c, x, y, x + 1, y), "#5a7898"); c:px(x, y - 1, "#5a7898"); c:px(x + 1, y - 1, "#5a7898")
    end
  end
  -- small bird tracks
  for _, p in ipairs({ { 60, 40 }, { 63, 42 }, { 66, 44 } }) do c:px(p[1], p[2], "#5a7898"); c:px(p[1] - 1, p[2] + 1, "#5a7898"); c:px(p[1] + 1, p[2] + 1, "#5a7898") end
  -- scout with a notebook
  local _, G = gnome(c, 18, 49, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 3 }, false), arm({ 4, 7 }, { 8, 12 }, true, true) } })
  part(c, R(c, 23, 33, 31, 41), "#f4eee0")
  fl(c, R(c, 23, 33, 23, 41), "#8a5a35")
  for _, p in ipairs({ { 25, 35 }, { 28, 37 }, { 26, 39 }, { 29, 35 } }) do c:px(p[1], p[2], "#6a5a4a"); c:px(p[1] + 1, p[2], "#6a5a4a") end
  fl(c, R(c, 22, 40, 24, 42), "#f0c8a0")
  snowfall(c, 8, 41, 6, 28)
  finish(c, "r_na_trail_tracks")
end

-- 22 beaver_tunnels (cutaway under the dam)
function S.beaver_tunnels()
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 11), "#7ea85a"); fl(c, R(c, 0, 11, W - 1, 11), "#9cc070")
  c:fill(R(c, 0, 12, W - 1, H - 1), "#6b4a2e")
  seed = 71
  for i = 1, 50 do c:px(6 + floor(rand() * 62), 13 + floor(rand() * 36), (i % 2 == 0) and "#5a3a28" or "#7a5636") end
  local DK = "#2a1a10"
  -- tunnels
  c:fill(c:line({ { 20, 34 }, { 14, 22 } }, 4), DK)
  c:fill(c:line({ { 36, 34 }, { 36, 18 } }, 4), DK)
  c:fill(c:line({ { 52, 34 }, { 58, 22 } }, 4), DK)
  -- chamber
  c:fill(c:rrect(8, 30, 64, 49, 4), DK)
  c:fill(R(c, 9, 47, 63, 49), "#7a5a38")
  -- ends: pond, daylight, lodge
  c:fill(c:ellipse(13, 19, 6, 4), DK); c:fill(c:ellipse(13, 20, 5, 3), "#58b4c4"); fl(c, R(c, 10, 19, 13, 19), "#a8e6e6")
  c:fill(c:ellipse(36, 14, 4, 3), "#e8f0d0"); c:px(36, 12, "#f5cf6a"); c:px(35, 14, "#f5cf6a"); c:px(37, 14, "#f5cf6a")
  c:fill(c:ellipse(60, 19, 7, 5), "#8a6a42")
  for x = 55, 65, 2 do fl(c, R(c, x, 15, x, 23), "#5e3f28") end
  fl(c, R(c, 54, 19, 66, 19), "#5e3f28"); fl(c, R(c, 56, 21, 64, 21), "#b08a52")
  -- gnome points; beaver pup looks up hopefully
  gnome(c, 22, 48, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 3 }, false), arm({ 4, 8 }, { 9, 16 }, true) } })
  part(c, c:ellipse(46, 44, 5, 4), "#8a5a35", { shade = true })
  part(c, c:ellipse(43, 38, 4, 3), "#a8703e")
  fl(c, R(c, 41, 38, 41, 39), "#2a1a10"); c:px(41, 36, "#2a1a10"); fl(c, R(c, 40, 40, 41, 41), "#f4eee0"); c:px(39, 38, "#2a1a10")
  part(c, R(c, 40, 34, 41, 35), "#6b4a2e", { noline = true }); part(c, R(c, 45, 34, 46, 35), "#6b4a2e", { noline = true })
  part(c, c:poly({ { 50, 45 }, { 58, 47 }, { 58, 49 }, { 50, 48 } }), "#4a2c1a")
  for _, p in ipairs({ { 52, 46 }, { 55, 47 } }) do c:px(p[1], p[2], "#6b4a2e") end
  finish(c, "r_na_beaver_tunnels")
end

-- 23 gopher_holes
function S.gopher_holes()
  local c = new()
  day(c, 30, { cloud = 20, sky = { "#9cc4de", "#b4d4e4", "#cce2e8" }, hill = "#a8b858", hill2 = "#98a850", grass = "#b4bc5c", edge = "#ccd478" })
  c:fill(c:ellipse(52, 12, 8, 2), "#f4eee0"); c:fill(c:ellipse(58, 10, 5, 2), "#f4eee0")
  for _, p in ipairs({ { 8, 36 }, { 64, 34 }, { 40, 33 }, { 20, 50 }, { 60, 50 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#8a983e"); c:px(p[1] + 1, p[2] - 1, "#8a983e") end
  local hx = { 24, 33, 42, 51, 60 }
  for i, x in ipairs(hx) do
    part(c, c:ellipse(x, 41, 4, 2), "#8a6a42", { shade = true })
    c:fill(c:ellipse(x, 40, 3, 1), "#2a1a10")
  end
  -- ground squirrel popping from the middle hole
  part(c, c:ellipse(42, 37, 3, 4), "#b88a52")
  c:fill(R(c, 41, 38, 43, 40), "#e8d0a0")
  part(c, c:ellipse(42, 32, 3, 3), "#b88a52")
  fl(c, R(c, 39, 29, 40, 30), "#b88a52"); fl(c, R(c, 44, 29, 45, 30), "#b88a52")
  c:px(41, 32, "#2a1a10"); c:px(44, 32, "#2a1a10"); fl(c, R(c, 42, 34, 43, 34), "#e08a7a")
  fl(c, R(c, 40, 39, 40, 40), "#8a6a42"); fl(c, R(c, 44, 39, 44, 40), "#8a6a42")
  -- gnome points at the next hole
  gnome(c, 12, 49, { s = 1.2, d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 3 }, false), arm({ 4, 8 }, { 12, 11 }, true) } })
  c:px(51, 33, "#e8a317"); c:px(51, 35, "#e8a317"); c:px(52, 34, "#e8a317"); c:px(50, 34, "#e8a317")
  finish(c, "r_na_gopher_holes")
end

-- 24 bale_toss
function S.bale_toss()
  local c = new()
  day(c, 36, { cloud = 56, sky = { "#9cc4de", "#b4d4e4", "#cce2e8" }, hill = "#a8b858", hill2 = "#98a850", grass = "#b4bc5c", edge = "#ccd478" })
  -- bar on two uprights
  part(c, R(c, 40, 14, 41, 40), "#6b4a2e", { noline = true }); part(c, R(c, 56, 14, 57, 40), "#6b4a2e", { noline = true })
  part(c, R(c, 38, 14, 59, 15), "#dd3a2a")
  fl(c, R(c, 42, 14, 44, 15), "#f4eee0"); fl(c, R(c, 48, 14, 50, 15), "#f4eee0"); fl(c, R(c, 54, 14, 56, 15), "#f4eee0")
  -- duck pond
  part(c, c:ellipse(56, 46, 14, 4), "#8b8f96", { shade = true })
  c:fill(c:ellipse(56, 46, 12, 3), "#58b4c4"); fl(c, R(c, 50, 46, 55, 46), "#a8e6e6")
  for _, p in ipairs({ { 52, 45 }, { 61, 47 } }) do
    part(c, c:ellipse(p[1], p[2], 2, 1), "#f4eee0", { noline = true }); fl(c, R(c, p[1] + 2, p[2] - 2, p[1] + 3, p[2] - 1), "#f4eee0"); c:px(p[1] + 4, p[2] - 1, "#e8a317")
  end
  -- haystack
  part(c, c:ellipse(66, 36, 6, 7), "#e0b858", { shade = true }); fl(c, R(c, 64, 33, 64, 38), "#c89a3c")
  -- gnome with a pitchfork, bale in flight
  c:fill(c:line({ { 12, 47 }, { 26, 25 } }, 1), "#8a5a35")
  for _, dx in ipairs({ -2, 0, 2 }) do c:fill(c:line({ { 26 + dx, 25 }, { 29 + dx, 20 } }, 1), "#aeb4bc") end
  fl(c, R(c, 26, 25, 29, 25), "#aeb4bc")
  gnome(c, 14, 49, { s = 1.2, d = 1, eyes = "open", arms = { arm({ -4, 8 }, { 2, 12 }, false), arm({ 4, 8 }, { 8, 13 }, true) } })
  bale(c, 28, 10, 37, 16)
  for _, p in ipairs({ { 30, 22 }, { 33, 19 }, { 36, 18 }, { 24, 28 } }) do c:px(p[1], p[2], "#e0b858") end
  fl(c, R(c, 40, 8, 41, 8), "#e0b858")
  finish(c, "r_na_bale_toss")
end

local order = {}
for line in io.lines("/tmp/claude-0/-home-user-gnome-venture/1b9189c1-3b2f-55fd-a82b-d2ac35c1c228/scratchpad/lists/h1.txt") do
  local s2 = line:match("^%s*r_na_(%S+)")
  if s2 then order[#order + 1] = s2 end
end
for _, s2 in ipairs(order) do
  if (not only or only == "r_na_" .. s2) and S[s2] then seed = 7; S[s2]() end
end
