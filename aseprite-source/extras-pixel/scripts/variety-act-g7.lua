-- variety-act-g7.lua : Do-tab scenes for rest-stop activities (group g7) -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g7.lua   (params BEFORE --script)
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

-- shared scene bits
local function rain(c, sd, n, col, x0, y0, x1, y1)
  seed = sd
  for i = 1, n do
    local x, y = (x0 or 6) + floor(rand() * ((x1 or 67) - (x0 or 6))), (y0 or 6) + floor(rand() * ((y1 or 46) - (y0 or 6)))
    c:px(x, y, col or "#d4e8f0"); c:px(x - 1, y + 1, col or "#d4e8f0")
  end
end
local function steam(c, x, y0, n, col)
  for i = 0, n do
    local sx = x + ((i % 2 == 0) and 0 or 1)
    fl(c, R(c, sx, y0 - i * 2, sx + 1, y0 - i * 2 + 1), col or "#f4f8fa")
  end
end
local function bubble(c, x0, y0, x1, y1, tx, ty)
  part(c, c:rrect(x0, y0, x1, y1, 3), "#f8f2e4")
  local t = c:poly({ { tx - 2, y1 }, { tx + 2, y1 }, { tx + (tx > (x0 + x1) / 2 and 3 or -3), ty } })
  c:fill(t, "#f8f2e4"); c:outline(t)
  c:fill(R(c, tx - 1, y1, tx + 1, y1), "#f8f2e4")
end
local function spark(c, x, y, a, b)
  c:px(x, y, a or "#fff1c8"); c:px(x - 1, y, b or "#f5cf6a"); c:px(x + 1, y, b or "#f5cf6a"); c:px(x, y - 1, b or "#f5cf6a"); c:px(x, y + 1, b or "#f5cf6a")
end
local function sack(c, x, y, w, h, col)
  -- body rect rounded with tied neck; x,y = top-left of body
  part(c, c:rrect(x, y, x + w - 1, y + h - 1, 3), col, { shade = false })
  part(c, R(c, x + floor(w / 2) - 2, y - 3, x + floor(w / 2) + 1, y), col)
  fl(c, R(c, x + floor(w / 2) - 2, y - 1, x + floor(w / 2) + 1, y - 1), "#8a5a35")
  fl(c, R(c, x + 2, y + 5, x + w - 3, y + 5), "#b89a5a")
end
local function plank_wall(c, x0, y0, x1, y1, base, line, pw)
  c:fill(R(c, x0, y0, x1, y1), base)
  for x = x0, x1, pw or 6 do fl(c, R(c, x, y0, x, y1), line) end
end

-- 1. forge_tales: night, banked forge glowing low, gnome on a stump telling a tale (bubble: a whistling kettle), cat listening
function S.w1_forge_tales()
  seed = 4
  local c = new()
  plank_wall(c, 0, 0, W - 1, 38, "#322840", "#2a2036", 6)
  fl(c, R(c, 0, 14, W - 1, 14), "#4a3a52")
  for _, st in ipairs({ { 8, 7 }, { 36, 9 }, { 64, 6 } }) do c:px(st[1], st[2], "#f4eee0") end
  c:fill(R(c, 0, 39, W - 1, H - 1), "#4a3a3a")
  for y = 43, 51, 4 do fl(c, R(c, 0, y, W - 1, y), "#3a2c2c") end
  c:fill(c:ellipse(52, 46, 22, 5), "#6a4a3a"); c:fill(c:ellipse(52, 46, 14, 3), "#8a5a3a")
  -- forge: stone hearth with chimney, low coals
  part(c, R(c, 53, 6, 59, 26), "#6a707c")
  part(c, R(c, 44, 24, 66, 44), "#7a808c")
  for _, y in ipairs({ 29, 34, 39 }) do fl(c, R(c, 45, y, 65, y), "#5b6470") end
  for _, p in ipairs({ { 50, 25 }, { 58, 30 }, { 48, 35 }, { 62, 35 }, { 53, 40 } }) do fl(c, R(c, p[1], p[2], p[1], p[2] + 4), "#5b6470") end
  part(c, c:rrect(48, 31, 62, 44, 3), "#1a1010")
  c:fill(c:ellipse(55, 42, 6, 2), "#e0501f"); c:fill(c:ellipse(55, 42, 3, 1), "#ffd86a")
  c:fill(c:poly({ { 55, 36 }, { 58, 42 }, { 52, 42 } }), "#e0501f"); c:fill(c:poly({ { 55, 39 }, { 57, 42 }, { 53, 42 } }), "#f08a24")
  fl(c, c:ellipse(56, 3, 2, 1), "#8a8f9c"); fl(c, c:ellipse(58, 0, 2, 1), "#6a707c")
  -- hanging tools on the wall
  fl(c, R(c, 9, 20, 9, 30), "#1a1010"); part(c, R(c, 6, 18, 12, 21), "#8b929c")
  fl(c, R(c, 36, 17, 38, 22), "#5e3f28"); part(c, c:ellipse(37, 25, 4, 3), "#aeb4bc")
  -- cat on the floor, listening
  part(c, c:ellipse(41, 46, 3, 2), "#c8a070"); part(c, c:ellipse(41, 42, 2, 2), "#c8a070")
  c:px(39, 39, "#c8a070"); c:px(43, 39, "#c8a070"); c:px(40, 42, INK); c:px(42, 42, INK)
  fl(c, R(c, 44, 47, 47, 47), "#c8a070")
  -- the teller on a stump
  gnome(c, 22, 41, { d = 1, sit = true, s = 1.0, eyes = "happy", arms = { arm({ -4, 7 }, { -8, 12 }, false), arm({ 4, 7 }, { 8, 12 }, true) } })
  part(c, R(c, 15, 41, 29, 47), "#8a5a35"); fl(c, R(c, 16, 41, 28, 41), "#c08a52"); fl(c, R(c, 19, 43, 19, 47), "#5e2f1e")
  -- tale bubble: a kettle whistling a tune
  bubble(c, 8, 4, 36, 20, 20, 26)
  part(c, c:rrect(12, 11, 22, 17, 2), "#aeb4bc")
  part(c, c:poly({ { 22, 12 }, { 27, 8 }, { 28, 10 }, { 22, 15 } }), "#aeb4bc")
  fl(c, R(c, 14, 9, 20, 10), "#6b3b2a"); fl(c, R(c, 16, 8, 18, 8), "#6b3b2a")
  for _, p in ipairs({ { 30, 14 }, { 33, 9 }, { 28, 6 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#c0442e"); fl(c, R(c, p[1] + 1, p[2] - 3, p[1] + 1, p[2]), "#c0442e") end
  finish(c, "w1_forge_tales")
end

-- 2. egg_pick: four baskets bobbing in a hot pool, each holding an egg; gnome points at one
function S.w1_egg_pick()
  seed = 9
  local c = new()
  day(c, 30, { cloud = 50, sky = { "#b8dcdc", "#cde6e0", "#e0eed8" } })
  part(c, c:ellipse(43, 40, 27, 9), "#8b8f96", { shade = true })
  c:fill(c:ellipse(43, 40, 24, 7), "#6cc4c8")
  for _, p in ipairs({ { 24, 36 }, { 40, 34 }, { 55, 36 }, { 30, 45 }, { 52, 45 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#a8e6e6") end
  local eggs = { "#f4eee0", "#f2e2c0", "#e8d8b8", "#f8f0e0" }
  for i, x in ipairs({ 27, 37, 47, 57 }) do
    local y = 41 + ((i % 2 == 0) and -1 or 1)
    fl(c, R(c, x - 4, y + 2, x + 4, y + 2), "#a8e6e6")
    part(c, c:ellipse(x, y - 4, 3, 3), eggs[i])
    c:px(x - 1, y - 5, "#fcfcf6")
    part(c, c:rrect(x - 4, y - 1, x + 4, y + 2, 2), "#c08a52")
    fl(c, R(c, x - 3, y, x + 3, y), "#e0b070"); fl(c, R(c, x - 3, y + 1, x + 3, y + 1), "#a06a3a")
  end
  steam(c, 31, 28, 4); steam(c, 53, 28, 5); steam(c, 42, 26, 3)
  gnome(c, 11, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 10, 12 }, true) } })
  spark(c, 47, 31); c:px(45, 29, "#f5cf6a")
  finish(c, "w1_egg_pick")
end

-- 3. spring_pickle: gnome at a bench lowering a spring egg into a big brine jar with a stern label
function S.w1_spring_pickle()
  seed = 12
  local c = new()
  day(c, 30, { cloud = 14, sky = { "#b8dcdc", "#cde6e0", "#e0eed8" } })
  c:fill(c:ellipse(52, 33, 22, 4), "#6cc4c8"); steam(c, 60, 28, 3); steam(c, 44, 27, 2)
  fl(c, R(c, 0, 31, W - 1, 33), "#7ea85a")
  part(c, R(c, 2, 38, 69, 43), "#b07a45")
  fl(c, R(c, 3, 38, 68, 38), "#d9a660")
  part(c, R(c, 5, 44, 8, 52), "#8a5a35", { noline = true }); part(c, R(c, 63, 44, 66, 52), "#8a5a35", { noline = true })
  local _, G = gnome(c, 19, 44, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ 5, 6 }, { 9, 14 }, true, true), arm({ -5, 6 }, { -7, 4 }, false) } })
  local hx, hy = G.P(9, 14)
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  part(c, c:ellipse(hx + 1, hy + 3, 2, 2), "#f4eee0")
  -- the big jar
  part(c, R(c, 34, 23, 46, 37), "#cfe6ea")
  fl(c, R(c, 35, 26, 45, 36), "#e8d890")
  for _, p in ipairs({ { 38, 33 }, { 42, 32 }, { 40, 29 }, { 37, 29 }, { 44, 35 } }) do part(c, c:ellipse(p[1], p[2], 2, 2), "#f4eee0", { noline = true }) end
  part(c, R(c, 33, 20, 47, 23), "#8a5a35")
  fl(c, R(c, 34, 20, 46, 20), "#b07a45")
  part(c, R(c, 36, 29, 44, 35), "#f8f2e4")
  fl(c, R(c, 37, 31, 38, 31), INK); fl(c, R(c, 42, 31, 43, 31), INK); c:px(37, 30, INK); c:px(43, 30, INK)
  fl(c, R(c, 39, 34, 41, 34), INK); c:px(38, 35, INK); c:px(42, 35, INK)
  -- small jars and salt sack
  for _, x in ipairs({ 52, 59 }) do
    part(c, R(c, x, 30, x + 5, 37), "#cfe6ea"); fl(c, R(c, x + 1, 32, x + 4, 36), "#e8d890"); fl(c, R(c, x + 1, 33, x + 2, 34), "#f4eee0")
    part(c, R(c, x, 28, x + 5, 29), "#8a5a35")
  end
  sack(c, 63, 31, 6, 7, "#e8e0d0"); c:px(65, 34, "#8b929c"); c:px(66, 35, "#8b929c")
  finish(c, "w1_spring_pickle")
end

-- 4. scrub_stones: a big mossy stone, half scrubbed shiny, gnome with a brush and suds
function S.w1_scrub_stones()
  seed = 15
  local c = new()
  day(c, 28, { cloud = 46, sky = { "#b8dcdc", "#cde6e0", "#e0eed8" } })
  c:fill(c:ellipse(52, 31, 20, 4), "#6cc4c8")
  for _, p in ipairs({ { 48, 31 }, { 58, 32 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#a8e6e6") end
  -- green stones around the pool edge
  for _, p in ipairs({ { 36, 29 }, { 66, 30 }, { 40, 34 } }) do part(c, c:ellipse(p[1], p[2], 4, 3), "#5a9a4a", { shade = true }) end
  -- bucket
  part(c, c:rrect(5, 30, 12, 39, 1), "#8a5a35"); fl(c, R(c, 5, 33, 12, 33), "#5e3f28"); fl(c, R(c, 5, 37, 12, 37), "#5e3f28")
  fl(c, R(c, 6, 30, 11, 31), "#7cc9c8")
  -- the boulder: left half scrubbed, right half green
  part(c, c:ellipse(46, 40, 16, 9), "#9a9ea6", { shade = true })
  local green = c:ellipse(46, 40, 16, 9):clip(R(c, 47, 0, 70, 60))
  c:fill(green, "#5a9a4a")
  for _, p in ipairs({ { 50, 36 }, { 55, 40 }, { 58, 36 }, { 52, 44 }, { 57, 45 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2] + 1), "#3f7a38") end
  for _, p in ipairs({ { 36, 33 }, { 40, 38 }, { 33, 42 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#c9ccd2") end
  for _, p in ipairs({ { 45, 33 }, { 44, 39 }, { 46, 44 }, { 42, 47 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2] + 1), "#5a9a4a") end
  spark(c, 38, 36, "#fcfcf6", "#d8f0f8")
  -- gnome scrubbing with a brush, foam on the stone
  gnome(c, 18, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 7 }, { 12, 6 }, true) } })
  part(c, R(c, 29, 40, 32, 45), "#8a5a35")
  fl(c, R(c, 29, 44, 32, 45), "#e8c48a")
  fl(c, R(c, 25, 41, 28, 42), "#f0c8a0")
  for _, p in ipairs({ { 33, 41 }, { 35, 44 }, { 32, 47 }, { 36, 40 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#fcfcf6", { noline = true }) end
  c:px(31, 36, "#d8f0f8"); c:px(34, 35, "#d8f0f8")
  finish(c, "w1_scrub_stones")
end

-- 5. splash_duel: two soakers waist-deep in a pool, a big splash arcing between them
function S.w1_splash_duel()
  seed = 18
  local c = new()
  day(c, 26, { cloud = 24, sky = { "#b8dcdc", "#cde6e0", "#e0eed8" } })
  -- towel line
  fl(c, R(c, 8, 12, 8, 26), "#5e3f28"); fl(c, R(c, 63, 12, 63, 26), "#5e3f28"); fl(c, R(c, 8, 13, 63, 13), "#5e3f28")
  part(c, R(c, 13, 14, 19, 22), "#dd3a2a"); fl(c, R(c, 13, 17, 19, 17), "#f4eee0")
  part(c, R(c, 52, 14, 58, 21), "#3f8fb0"); fl(c, R(c, 52, 17, 58, 17), "#f4eee0")
  c:fill(R(c, 0, 29, W - 1, H - 1), "#6cc4c8")
  for y = 31, 47, 4 do for x = 2 + (y % 8), 70, 9 do fl(c, R(c, x, y, x + 3, y), "#8fdadc") end end
  gnome(c, 12, 47, { d = 1, upper = true, eyes = "open", arms = { arm({ 4, 7 }, { 10, 13 }, true), arm({ -4, 7 }, { -7, 4 }, false) } })
  gnome(c, 60, 47, { d = -1, upper = true, hat = "#4f9a45", eyes = "shut", arms = { arm({ -4, 8 }, { -7, 15 }, true), arm({ 4, 7 }, { 7, 4 }, false) } })
  -- water over the lower bodies
  c:fill(R(c, 0, 41, W - 1, H - 1), "#6cc4c8")
  for x = 2, 70 do if x % 3 ~= 0 then c:px(x, 41, "#a8e6e6") end end
  for y = 44, 49, 3 do for x = 3 + y % 5, 70, 10 do fl(c, R(c, x, y, x + 4, y), "#8fdadc") end end
  -- the splash: a thick arc of water from the left soaker, bursting on the right one
  for x = 22, 50, 3 do
    local y = rnd(18 + ((x - 34) * (x - 34)) / 28)
    local r = (x > 44) and 2 or 1
    part(c, c:ellipse(x, y, r + 1, r), "#cfeaf2", { noline = (x < 26) })
  end
  local burst = c:ellipse(52, 32, 5, 4)
  part(c, burst, "#cfeaf2")
  fl(c, R(c, 50, 29, 52, 30), "#fcfcf6")
  for _, p in ipairs({ { 47, 24 }, { 56, 24 }, { 58, 30 }, { 45, 33 }, { 40, 20 }, { 27, 29 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#cfeaf2") end
  for _, p in ipairs({ { 33, 12 }, { 38, 16 } }) do c:px(p[1], p[2], "#fcfcf6") end
  finish(c, "w1_splash_duel")
end

-- 6. star_float: night, gnome floating on his back in a warm pool, a shooting star overhead
function S.w1_star_float()
  seed = 21
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#1c2448", "#243058", "#2e3c68", "#3a4a78", "#4a5a86" }, { dir = "v" })
  seed = 6
  for i = 1, 22 do c:px(6 + floor(rand() * 62), 6 + floor(rand() * 26), (i % 3 == 0) and "#f4eee0" or "#aab4d8") end
  spark(c, 14, 11, "#fff1c8", "#aab4d8")
  -- shooting star with a tail
  c:fill(c:line({ { 40, 9 }, { 58, 17 } }, 1), "#d8d8e8")
  fl(c, R(c, 50, 12, 55, 13), "#aab4d8")
  part(c, c:ellipse(60, 18, 2, 2), "#fff1c8", { noline = true }); spark(c, 60, 18)
  c:fill(c:ellipse(18, 35, 34, 9), "#1e2a4c"); c:fill(c:ellipse(60, 36, 30, 8), "#222e52")
  c:fill(R(c, 0, 35, W - 1, H - 1), "#26482e")
  fl(c, R(c, 0, 35, W - 1, 35), "#386a44")
  part(c, c:ellipse(36, 42, 31, 9), "#9a9ea8", { shade = true })
  c:fill(c:ellipse(36, 42, 28, 7), "#58b4c4")
  for _, p in ipairs({ { 12, 46 }, { 20, 48 }, { 50, 48 }, { 58, 46 }, { 34, 48 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#8fdadc") end
  -- the floater: hat in the water on the left, face up, beard, belly, two boots up
  part(c, c:poly({ { 21, 36 }, { 21, 43 }, { 8, 43 } }), "#c0442e")
  fl(c, R(c, 21, 35, 22, 44), "#8e2e1e"); c:px(7, 42, "#c0442e")
  part(c, c:ellipse(27, 40, 4, 3), "#f0c8a0")
  fl(c, R(c, 25, 39, 26, 39), "#5a3a2a"); fl(c, R(c, 28, 39, 29, 39), "#5a3a2a"); c:px(27, 41, "#e08a7a")
  part(c, c:ellipse(35, 40, 4, 3), "#f4eee0"); fl(c, R(c, 33, 37, 34, 38), "#f4eee0"); c:px(35, 36, "#f4eee0")
  part(c, c:ellipse(43, 40, 5, 3), "#4a6e9a")
  part(c, R(c, 48, 40, 51, 42), "#4a6e9a")
  part(c, R(c, 51, 35, 54, 41), "#7a5030"); part(c, R(c, 56, 36, 59, 42), "#7a5030")
  fl(c, R(c, 51, 36, 52, 36), "#a8703e"); fl(c, R(c, 56, 37, 57, 37), "#a8703e")
  fl(c, R(c, 38, 38, 40, 39), "#f0c8a0")
  for x = 8, 62 do if x % 3 ~= 0 then c:px(x, 43, "#a8e6e6") end end
  steam(c, 14, 38, 5, "#d8e6f0"); steam(c, 64, 38, 5, "#d8e6f0"); steam(c, 22, 33, 3, "#d8e6f0")
  finish(c, "w1_star_float")
end

-- 7. toe_dip: boots off, bare toes in a warm trickle running over the rocks
function S.w1_toe_dip()
  seed = 25
  local c = new()
  day(c, 30, { cloud = 20, sky = { "#b8dcdc", "#cde6e0", "#e0eed8" } })
  -- rock face at right with a trickle
  part(c, c:poly({ { 40, 17 }, { 45, 12 }, { 52, 10 }, { 58, 13 }, { 68, 9 }, { 68, 38 }, { 36, 38 }, { 38, 26 } }), "#8b8f96", { shade = true })
  fl(c, R(c, 43, 13, 47, 14), "#5e8a44"); fl(c, R(c, 56, 11, 60, 12), "#5e8a44")
  for _, p in ipairs({ { 44, 18 }, { 56, 14 }, { 60, 26 }, { 46, 30 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#6a707c") end
  fl(c, R(c, 47, 12, 49, 33), "#8fdadc"); fl(c, R(c, 48, 12, 48, 33), "#cfeff0")
  fl(c, R(c, 54, 18, 55, 33), "#8fdadc")
  part(c, c:ellipse(48, 44, 17, 5), "#8b8f96", { shade = true })
  c:fill(c:ellipse(48, 44, 14, 3.5), "#6cc4c8")
  fl(c, R(c, 38, 44, 42, 44), "#a8e6e6"); fl(c, R(c, 54, 45, 58, 45), "#a8e6e6")
  -- seat stone and boots
  part(c, c:ellipse(26, 46, 10, 5), "#9a9ea6", { shade = true })
  local _, G = gnome(c, 27, 40, { d = 1, sit = true, s = 1.0, eyes = "shut", arms = { arm({ -3, 7 }, { 0, 3 }, true, true) } })
  -- bare feet: skin over the boots, toes
  local x0, y0 = G.P(6, -4); local x1, y1 = G.P(10, -7)
  local xa, xb, ya, yb = math.min(x0, x1), math.max(x0, x1), math.min(y0, y1), math.max(y0, y1)
  fl(c, R(c, xa, ya, xb, yb), "#f0c8a0")
  for x = xa + 1, xb, 2 do c:px(x, yb, "#d8a880") end
  part(c, R(c, 7, 44, 11, 47), "#5a3a22"); part(c, R(c, 12, 43, 16, 46), "#5a3a22")
  fl(c, R(c, 8, 44, 10, 44), "#7a5a3a")
  steam(c, 44, 40, 3); steam(c, 55, 40, 4)
  finish(c, "w1_toe_dip")
end

-- 8. guess_weight: a dog-sized marrow on the weigher's scale, gnome pondering, jar of petals as the prize
function S.w1_guess_weight()
  seed = 28
  local c = new()
  day(c, 34, { cloud = 14, hill = "#5e8a44", hill2 = "#4e8a3c" })
  -- bunting
  c:fill(c:line({ { 5, 8 }, { 20, 12 }, { 36, 10 }, { 52, 13 }, { 68, 9 } }, 1), "#5e3f28")
  local cols = { "#dd3a2a", "#f5cf6a", "#3f8fb0", "#7ab55c" }
  for i, f in ipairs({ { 9, 9 }, { 15, 11 }, { 22, 12 }, { 29, 11 }, { 36, 10 }, { 43, 11 }, { 50, 12 }, { 57, 12 }, { 63, 10 } }) do
    fl(c, c:poly({ { f[1], f[2] + 1 }, { f[1] + 4, f[2] + 1 }, { f[1] + 2, f[2] + 4 } }), cols[(i - 1) % 4 + 1])
  end
  c:fill(R(c, 0, 36, W - 1, H - 1), "#c9a96e"); fl(c, R(c, 0, 36, W - 1, 36), "#d9bc84")
  -- weighing scale: base, platform, dial on a post
  part(c, R(c, 30, 42, 58, 47), "#6b4a2e")
  part(c, R(c, 26, 38, 62, 41), "#a8703e")
  fl(c, R(c, 27, 38, 61, 38), "#d9a660")
  part(c, R(c, 62, 23, 65, 42), "#8b929c")
  part(c, c:ellipse(63.5, 20, 5, 5), "#f4eee0")
  fl(c, R(c, 60, 20, 61, 20), "#b8b0a0"); fl(c, R(c, 66, 20, 67, 20), "#b8b0a0"); fl(c, R(c, 63, 16, 64, 16), "#b8b0a0")
  c:fill(c:line({ { 63, 20 }, { 66, 17 } }, 1), "#c0442e")
  c:px(63, 20, INK)
  -- the marrow
  part(c, c:ellipse(43, 31, 16, 7), "#5a9a4a", { shade = true })
  for _, x in ipairs({ 34, 39, 44, 49, 53 }) do c:fill(R(c, x, 26, x, 36):clip(c:ellipse(43, 31, 15, 6)), "#3f7a38") end
  part(c, R(c, 25, 28, 27, 30), "#6a8a38")
  c:fill(c:ellipse(37, 28, 4, 1), "#8cc468")
  -- prize jar of petals
  part(c, R(c, 6, 28, 12, 36), "#cfe6ea")
  fl(c, R(c, 7, 30, 11, 35), "#e46a9b"); fl(c, R(c, 8, 31, 9, 32), "#f6b8cf"); fl(c, R(c, 10, 33, 10, 34), "#f6b8cf")
  part(c, R(c, 6, 26, 12, 27), "#8a5a35")
  part(c, R(c, 5, 37, 14, 41), "#a8703e")
  -- gnome, thoughtful
  gnome(c, 19, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 3, 10 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  finish(c, "w1_guess_weight")
end

-- 9. bread_shapes: a baker's rack of odd-shaped loaves, gnome about to bite a ring loaf
function S.w1_bread_shapes()
  seed = 31
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#d9c08a")
  for y = 0, 40, 5 do fl(c, R(c, 0, y, W - 1, y), "#cfb47c") end
  c:fill(R(c, 0, 41, W - 1, H - 1), "#a8703e"); fl(c, R(c, 0, 41, W - 1, 41), "#c08a52")
  for x = 4, 70, 14 do fl(c, R(c, x, 42, x, 52), "#8a5a35") end
  -- shelves
  for _, y in ipairs({ 21, 32 }) do part(c, R(c, 22, y, 68, y + 2), "#8a5a35"); fl(c, R(c, 23, y, 67, y), "#b07a45") end
  local CR, CD = "#d9a660", "#a8641f"
  -- top shelf: plait, cob, baguette, knot
  part(c, R(c, 24, 15, 35, 20), CR)
  for x = 26, 34, 3 do fl(c, c:line({ { x, 15 }, { x + 2, 20 } }, 1), CD) end
  part(c, c:ellipse(43, 16, 5, 4), CR); fl(c, R(c, 41, 13, 41, 17), CD); fl(c, R(c, 44, 13, 44, 17), CD)
  part(c, c:line({ { 50, 20 }, { 60, 14 } }, 3), CR)
  for _, x in ipairs({ 52, 55, 58 }) do c:px(x, 17 - floor((x - 52) / 2), CD) end
  part(c, c:ellipse(65, 17, 2, 3), CR); fl(c, R(c, 63, 17, 67, 17), CD)
  -- middle shelf: ring, twist, bap, bloomer, crown
  part(c, c:ellipse(27, 28, 4, 3), CR); fl(c, R(c, 26, 27, 28, 29), "#d9c08a")
  part(c, c:rrect(34, 24, 42, 31, 3), CR); c:fill(c:line({ { 36, 25 }, { 40, 30 } }, 1), CD); c:fill(c:line({ { 40, 25 }, { 36, 30 } }, 1), CD)
  part(c, c:ellipse(48, 29, 4, 2), CR); fl(c, R(c, 46, 28, 50, 28), "#e8c48a")
  part(c, c:ellipse(57, 27, 5, 3), CR); fl(c, R(c, 54, 25, 55, 28), CD); fl(c, R(c, 58, 25, 59, 28), CD)
  part(c, c:ellipse(65, 28, 2, 3), CR); fl(c, R(c, 64, 26, 66, 26), CD)
  -- lower shelf: hedgehog roll and flatbread
  part(c, c:ellipse(30, 38, 5, 3), CR); for x = 27, 33, 2 do c:px(x, 35, CD) end
  part(c, c:ellipse(46, 39, 6, 2), "#e8c48a"); fl(c, R(c, 43, 39, 49, 39), "#c8964a")
  -- gnome with a pretzel-ish ring loaf with a bite
  local _, G = gnome(c, 12, 47, { d = 1, eyes = "happy", arms = { arm({ 4, 7 }, { 7, 12 }, true, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local hx, hy = G.P(8, 12)
  part(c, c:ellipse(hx + 1, hy - 3, 4, 3), CR); fl(c, R(c, hx, hy - 4, hx + 2, hy - 2), "#d9c08a")
  fl(c, R(c, hx + 3, hy - 5, hx + 4, hy - 4), "#d9c08a")
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy), "#f0c8a0")
  spark(c, 31, 10, "#fff1c8", "#f5cf6a")
  finish(c, "w1_bread_shapes")
end

-- 10. stall_shout: gnome on a crate, hands cupped, bellowing; sound bursts; two gnomes in the crowd, turnip stall behind
function S.w1_stall_shout()
  seed = 34
  local c = new()
  day(c, 34, { cloud = 56, hill = "#5e8a44", hill2 = "#4e8a3c" })
  c:fill(R(c, 0, 36, W - 1, H - 1), "#c9a96e"); fl(c, R(c, 0, 36, W - 1, 36), "#d9bc84")
  -- stall behind, left
  part(c, R(c, 5, 16, 6, 36), "#8a5a35", { noline = true }); part(c, R(c, 25, 16, 26, 36), "#8a5a35", { noline = true })
  local n = 0
  for x = 4, 27, 4 do fl(c, R(c, x, 12, x + 3, 17), (n % 2 == 0) and "#3f6fb0" or "#f4eee0"); n = n + 1 end
  c:outline(R(c, 4, 12, 27, 17))
  part(c, R(c, 5, 30, 26, 37), "#b07a45")
  for i = 0, 3 do
    part(c, c:ellipse(9 + i * 5, 28, 2, 2), "#e8e0f0"); fl(c, R(c, 8 + i * 5, 25, 9 + i * 5, 26), "#b45a9c")
  end
  -- the stand crate
  part(c, R(c, 31, 41, 49, 49), "#b07a45")
  fl(c, R(c, 32, 41, 48, 41), "#d9a660"); fl(c, R(c, 31, 45, 49, 45), "#8a5a35"); fl(c, R(c, 40, 42, 40, 48), "#8a5a35")
  local _, G = gnome(c, 40, 41, { d = 1, eyes = "shut", arms = { arm({ -4, 7 }, { -3, 10 }, true), arm({ 4, 7 }, { 3, 10 }, true) } })
  -- open mouth in the beard top
  local mx, my = G.P(0, 9)
  fl(c, R(c, mx - 1, my, mx + 1, my + 1), "#7a2018"); fl(c, R(c, mx, my + 1, mx, my + 1), "#e08a7a")
  -- shout bursts
  for _, sd in ipairs({ -1, 1 }) do
    local bx = 40 + sd * 12
    for k = -1, 1 do c:fill(c:line({ { bx, 24 + k * 6 }, { bx + sd * (5 + (1 - math.abs(k)) * 3), 24 + k * 8 } }, 1), "#f5cf6a") end
  end
  -- crowd
  gnome(c, 10, 53, { d = 1, upper = true, s = 0.8, hat = "#e8a317", eyes = "open" })
  gnome(c, 62, 53, { d = -1, upper = true, s = 0.8, hat = "#4f9a45", eyes = "open" })
  finish(c, "w1_stall_shout")
end

-- 11. awning_mend: rainy market, gnome on a crate pressing a patch on a leaky awning; drips fall on the bread and the cheese bucket
function S.w1_awning_mend()
  seed = 37
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#7e8ea0", "#8a9aaa", "#96a6b4", "#a4b2be" }, { dir = "v" })
  c:fill(c:ellipse(18, 36, 34, 9), "#4e6a58"); c:fill(c:ellipse(60, 37, 30, 8), "#56725e")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#6a8a68")
  c:fill(c:ellipse(40, 48, 22, 2), "#7ea0b0")
  -- stall: posts, awning with a hole, counter
  part(c, R(c, 8, 17, 9, 42), "#6b4a2e", { noline = true }); part(c, R(c, 63, 17, 64, 42), "#6b4a2e", { noline = true })
  local n = 0
  for x = 6, 65, 4 do
    local col = (n % 2 == 0) and "#c0442e" or "#e8e0d0"
    fl(c, R(c, x, 11, x + 3, 17), col); fl(c, R(c, x, 18, x + 3, 18), col); fl(c, R(c, x + 1, 19, x + 2, 19), col)
    n = n + 1
  end
  c:outline(R(c, 6, 11, 69, 19))
  fl(c, R(c, 44, 13, 48, 16), "#4a3a46")
  part(c, R(c, 8, 36, 64, 44), "#a8703e"); fl(c, R(c, 9, 36, 63, 36), "#c08a52"); fl(c, R(c, 8, 40, 64, 40), "#8a5a35")
  -- bread on the counter, cheese wheel and bucket
  part(c, c:ellipse(15, 34, 4, 2), "#d9a660"); part(c, c:ellipse(23, 34, 4, 2), "#d9a660")
  part(c, c:rrect(52, 29, 61, 36, 1), "#8a5a35"); fl(c, R(c, 53, 29, 60, 30), "#7cc9c8")
  part(c, c:ellipse(46, 33, 5, 3), "#f5cf6a"); fl(c, R(c, 44, 33, 48, 33), "#e8a317"); c:px(42, 33, "#e8a317")
  -- drips from the hole
  for _, p in ipairs({ { 46, 21 }, { 47, 26 }, { 46, 30 } }) do c:px(p[1], p[2], "#a8d4f0"); c:px(p[1], p[2] + 1, "#a8d4f0") end
  c:px(44, 20, "#a8d4f0")
  -- gnome on a crate, patching
  part(c, R(c, 28, 41, 40, 47), "#8a5a35"); fl(c, R(c, 29, 41, 39, 41), "#b07a45")
  local _, G = gnome(c, 34, 41, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 18 }, true), arm({ -4, 7 }, { -8, 13 }, false) } })
  local px_, py_ = G.P(8, 18)
  part(c, R(c, px_ + 1, py_ - 7, px_ + 7, py_ - 2), "#3f8fb0")
  fl(c, R(c, px_ + 1, py_ - 7, px_ + 7, py_ - 7), "#7ac4de")
  fl(c, R(c, px_ + 3, py_ - 5, px_ + 4, py_ - 5), "#2c6a8a"); fl(c, R(c, px_ + 5, py_ - 4, px_ + 6, py_ - 4), "#2c6a8a")
  -- needle and thread in the other hand
  local nx, ny = G.P(-8, 13)
  c:fill(c:line({ { nx, ny - 1 }, { nx - 5, ny - 7 } }, 1), "#aeb4bc")
  c:fill(c:line({ { nx - 5, ny - 7 }, { nx - 3, ny - 2 } }, 1), "#f5cf6a")
  rain(c, 61, 46, "#cfe2ee", 6, 6, 67, 48)
  finish(c, "w1_awning_mend")
end

-- 12. griddle_cakes: hot stone beside a brick oven, gnome flips a pancake mid-air; a stack waits on a plate
function S.w1_griddle_cakes()
  seed = 41
  local c = new()
  plank_wall(c, 0, 0, W - 1, 38, "#d9c08a", "#cfb47c", 7)
  c:fill(R(c, 0, 39, W - 1, H - 1), "#8a5a35")
  for y = 44, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  -- brick oven at the back right
  part(c, R(c, 44, 4, 68, 38), "#b4573a")
  for y = 8, 36, 4 do fl(c, R(c, 45, y, 67, y), "#8e3e28") end
  for y = 6, 34, 8 do for x = 48, 66, 8 do fl(c, R(c, x, y, x, y + 3), "#8e3e28") end end
  for y = 10, 34, 8 do for x = 52, 66, 8 do fl(c, R(c, x, y, x, y + 3), "#8e3e28") end end
  part(c, c:rrect(48, 20, 64, 38, 6), "#1a1010")
  c:fill(c:poly({ { 56, 25 }, { 62, 38 }, { 50, 38 } }), "#e0501f"); c:fill(c:poly({ { 56, 30 }, { 60, 38 }, { 52, 38 } }), "#f08a24"); c:fill(c:ellipse(56, 37, 3, 2), "#ffd86a")
  -- griddle stone on a block
  part(c, R(c, 27, 38, 47, 47), "#8b8f96")
  for _, p in ipairs({ { 30, 42 }, { 38, 41 }, { 43, 44 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#6a707c") end
  part(c, R(c, 25, 35, 49, 38), "#3d3a44")
  fl(c, R(c, 26, 35, 48, 35), "#5a5666")
  for _, x in ipairs({ 31, 40 }) do part(c, c:ellipse(x, 34, 4, 2), "#e8a840"); fl(c, R(c, x - 2, 34, x + 2, 34), "#c8802a") end
  steam(c, 44, 31, 2, "#f4f8fa")
  -- plate with a stack and butter
  part(c, R(c, 3, 41, 18, 47), "#a8703e"); fl(c, R(c, 4, 41, 17, 41), "#c08a52")
  part(c, c:ellipse(10, 40, 6, 1), "#f4eee0")
  for i = 0, 3 do part(c, c:ellipse(10, 38 - i * 2, 5, 2), (i % 2 == 0) and "#e8a840" or "#d9923a") end
  part(c, R(c, 9, 29, 11, 31), "#f5cf6a")
  fl(c, R(c, 12, 33, 13, 35), "#c4623a")
  -- gnome flipping
  local _, G = gnome(c, 22, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 5 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local sx, sy = G.P(8, 5)
  c:fill(c:line({ { sx, sy }, { sx + 5, sy - 2 } }, 1), "#8a5a35")
  part(c, R(c, sx + 5, sy - 4, sx + 11, sy - 1), "#aeb4bc")
  -- airborne cake and motion arc
  part(c, c:ellipse(38, 21, 6, 2.2), "#e8a840"); fl(c, R(c, 34, 20, 41, 20), "#f4c868")
  for _, p in ipairs({ { 36, 26 }, { 35, 29 }, { 36, 32 }, { 34, 35 } }) do c:px(p[1], p[2], "#8a5a35") end
  c:px(30, 18, "#f5cf6a"); c:px(44, 16, "#f5cf6a"); c:px(41, 13, "#ffd86a")
  finish(c, "w1_griddle_cakes")
end

-- 13. sweep_loft: dawn light through a round window in a flour-dusted loft, gnome sweeping, a floury ghost-cat watching
function S.w1_sweep_loft()
  seed = 44
  local c = new()
  plank_wall(c, 0, 0, W - 1, 40, "#8a6a4a", "#6b4e34", 6)
  -- roof beams
  c:fill(c:line({ { 5, 14 }, { 36, 5 }, { 68, 14 } }, 2), "#4a2f1e")
  fl(c, R(c, 5, 15, 68, 16), "#4a2f1e")
  c:fill(c:line({ { 20, 15 }, { 36, 7 }, { 52, 15 } }, 1), "#4a2f1e")
  c:fill(R(c, 0, 41, W - 1, H - 1), "#a07a52")
  for y = 44, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#7a5a3a") end
  -- flour drifts on the floor
  for _, p in ipairs({ { 8, 47, 6 }, { 22, 50, 8 }, { 40, 46, 5 }, { 52, 51, 7 }, { 62, 45, 4 } }) do c:fill(c:ellipse(p[1], p[2], p[3], 1), "#ece6d8") end
  -- round window with dawn glow
  part(c, c:ellipse(52, 24, 6, 6), "#f0a868")
  c:fill(c:ellipse(52, 24, 4, 4), "#f8d088"); c:fill(c:ellipse(52, 25, 4, 2), "#f0a070")
  fl(c, R(c, 52, 18, 52, 30), "#6b4e34"); fl(c, R(c, 46, 24, 58, 24), "#6b4e34")
  -- sunbeam
  c:fill(c:poly({ { 49, 29 }, { 36, 44 }, { 56, 44 }, { 55, 29 } }), "#e8c488")
  c:fill(c:poly({ { 50, 31 }, { 42, 44 }, { 54, 44 }, { 54, 31 } }), "#f2d8a0")
  -- sacks stacked at the back
  sack(c, 6, 28, 9, 11, "#d9c48a")
  sack(c, 15, 32, 9, 8, "#cdb87e")
  -- flour dust drifting
  for i = 1, 28 do
    local x, y = 8 + floor(rand() * 58), 8 + floor(rand() * 36)
    c:px(x, y, "#f4f0e4")
  end
  -- gnome sweeping a cloud of flour
  local _, G = gnome(c, 22, 47, { d = 1, walk = 1, eyes = "shut", arms = { arm({ 4, 7 }, { 9, 5 }, true, true), arm({ 4, 6 }, { 7, 8 }, true, false) } })
  local bx, by = G.P(11, 0)
  c:fill(c:line({ { bx - 3, by - 14 }, { bx + 2, by } }, 1), "#a8703e")
  part(c, c:poly({ { bx - 1, by - 2 }, { bx + 6, by - 2 }, { bx + 7, by + 1 }, { bx - 2, by + 1 } }), "#d9c08a")
  for _, p in ipairs({ { bx + 7, by - 4 }, { bx + 9, by - 7 }, { bx + 5, by - 7 }, { bx + 11, by - 3 }, { bx + 8, by - 10 } }) do part(c, c:ellipse(p[1], p[2], 2, 1), "#f4f0e4", { noline = true }) end
  -- the floury cat: a startled grey ghost
  part(c, c:ellipse(63, 45, 5, 4), "#e4e0d6")
  part(c, c:ellipse(63, 39, 4, 3), "#e4e0d6")
  c:px(60, 35, INK); c:px(66, 35, INK); fl(c, R(c, 60, 36, 60, 37), "#e4e0d6"); fl(c, R(c, 66, 36, 66, 37), "#e4e0d6")
  fl(c, R(c, 61, 38, 62, 39), "#fcfcf6"); fl(c, R(c, 65, 38, 66, 39), "#fcfcf6"); c:px(62, 39, INK); c:px(65, 39, INK)
  fl(c, R(c, 63, 41, 64, 41), "#e8a8a0")
  fl(c, R(c, 67, 47, 68, 47), "#e4e0d6")
  finish(c, "w1_sweep_loft")
end

-- 14. cat_sack: three sacks in a row, the middle one wriggling with a bump and an ear; gnome puzzling
function S.w1_cat_sack()
  seed = 47
  local c = new()
  plank_wall(c, 0, 0, W - 1, 38, "#b8946a", "#a07e56", 7)
  fl(c, R(c, 0, 6, W - 1, 8), "#6b4e34")
  c:fill(R(c, 0, 39, W - 1, H - 1), "#8a5a35")
  for y = 43, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  -- three sacks
  local function bigsack(x, y, col, wig)
    part(c, c:ellipse(x, y + 5, 8, 8), col, { shade = false })
    part(c, R(c, x - 3, y - 6, x + 2, y - 2), col)
    fl(c, R(c, x - 3, y - 4, x + 2, y - 4), "#8a5a35"); fl(c, R(c, x - 2, y - 3, x + 1, y - 3), "#8a5a35")
    fl(c, R(c, x - 5, y + 3, x + 5, y + 3), "#c4aa6c")
    fl(c, R(c, x - 1, y + 5, x + 1, y + 7), "#8a8a40")
    c:px(x, y + 4, "#8a8a40")
  end
  bigsack(26, 36, "#d9c48a"); bigsack(48, 36, "#d9c48a"); bigsack(37, 36, "#d9c48a")
  -- the wriggler: middle one shows a cat bump with two ears and shake lines
  part(c, c:poly({ { 33, 24 }, { 35, 19 }, { 36, 25 } }), "#c8a070"); part(c, c:poly({ { 38, 25 }, { 39, 19 }, { 41, 24 } }), "#c8a070")
  part(c, c:ellipse(37, 27, 4, 3), "#c8a070"); c:px(35, 26, INK); c:px(39, 26, INK); c:px(37, 28, "#e08a7a")
  for _, p in ipairs({ { 30, 20 }, { 29, 25 }, { 44, 20 }, { 45, 25 } }) do fl(c, R(c, p[1], p[2], p[1], p[2] + 2), "#f5cf6a") end
  -- gnome puzzling
  gnome(c, 11, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 3, 11 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  fl(c, R(c, 15, 15, 17, 15), "#c0442e"); fl(c, R(c, 17, 16, 17, 17), "#c0442e"); fl(c, R(c, 16, 18, 16, 18), "#c0442e"); fl(c, R(c, 16, 20, 16, 20), "#c0442e")
  c:px(60, 30, "#f4f0e4"); c:px(62, 36, "#f4f0e4")
  sack(c, 56, 40, 9, 8, "#cdb87e")
  finish(c, "w1_cat_sack")
end

-- 15. wheel_tales: rainy mill, gnome on a sack telling of the heron on the wheel; big water wheel turning
function S.w1_wheel_tales()
  seed = 50
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 40), { "#6e7e90", "#7a8a9a", "#8696a4", "#92a2ae" }, { dir = "v" })
  -- mill wall and roof at left
  part(c, R(c, 5, 22, 38, 42), "#8a7a68")
  for y = 26, 40, 5 do fl(c, R(c, 6, y, 37, y), "#6e6050") end
  for _, p in ipairs({ { 12, 23 }, { 22, 27 }, { 30, 23 }, { 16, 32 }, { 28, 36 }, { 10, 37 } }) do fl(c, R(c, p[1], p[2], p[1], p[2] + 3), "#6e6050") end
  part(c, c:poly({ { 3, 22 }, { 22, 14 }, { 41, 22 } }), "#6b3b2a")
  fl(c, R(c, 8, 21, 36, 21), "#4a2c1a")
  part(c, R(c, 28, 28, 35, 42), "#4a2c1a")
  -- ground and stream
  c:fill(R(c, 0, 42, W - 1, H - 1), "#5a7a58")
  fl(c, R(c, 0, 42, W - 1, 42), "#7a9a68")
  c:fill(c:ellipse(56, 48, 16, 3), "#4a88b0"); fl(c, R(c, 50, 48, 54, 48), "#8cc4dc"); fl(c, R(c, 58, 49, 63, 49), "#8cc4dc")
  -- the wheel
  local cx, cy = 56, 30
  part(c, c:ellipse(cx, cy, 14, 14), "#8a5a35")
  c:fill(c:ellipse(cx, cy, 11, 11), "#6a7a8a")
  for _, a in ipairs({ { 0, -11 }, { 8, -8 }, { 11, 0 }, { 8, 8 }, { 0, 11 }, { -8, 8 }, { -11, 0 }, { -8, -8 } }) do
    c:fill(c:line({ { cx, cy }, { cx + a[1], cy + a[2] } }, 1), "#8a5a35")
    part(c, R(c, cx + a[1] * 14 / 11 - 1, cy + a[2] * 14 / 11 - 1, cx + a[1] * 14 / 11 + 1, cy + a[2] * 14 / 11 + 1), "#a8703e", { noline = true })
  end
  part(c, c:ellipse(cx, cy, 3, 3), "#4a2c1a"); c:px(cx, cy, "#b07a45")
  fl(c, R(c, 69 - 1, 20, 68, 40), "#7a8a98")
  rain(c, 66, 52, "#cfe2ee", 5, 5, 68, 49)
  -- the storyteller on a sack
  sack(c, 10, 38, 11, 5, "#d9c48a")
  fl(c, R(c, 12, 43, 20, 45), "#d9c48a")
  gnome(c, 15, 40, { d = 1, sit = true, eyes = "happy", arms = { arm({ 4, 7 }, { 8, 13 }, true), arm({ -4, 7 }, { -7, 11 }, false) } })
  part(c, c:rrect(9, 43, 24, 48, 2), "#d9c48a"); fl(c, R(c, 10, 44, 23, 44), "#e8d49a")
  -- bubble: a heron on a wheel
  bubble(c, 22, 2, 46, 20, 26, 26)
  part(c, c:ellipse(34, 20, 6, 3):clip(R(c, 0, 0, 80, 19)), "#8a5a35", { noline = true })
  fl(c, R(c, 29, 17, 39, 18), "#8a5a35"); fl(c, R(c, 29, 18, 39, 18), "#6b3b2a")
  fl(c, R(c, 33, 13, 33, 17), "#e8a317"); fl(c, R(c, 36, 13, 36, 17), "#e8a317")
  part(c, c:ellipse(35, 11, 4, 3), "#aab4c8")
  fl(c, R(c, 32, 10, 36, 11), "#e8ecf0")
  fl(c, R(c, 38, 5, 38, 9), "#aab4c8"); fl(c, R(c, 39, 5, 39, 9), "#aab4c8")
  part(c, R(c, 38, 3, 40, 5), "#e8ecf0"); fl(c, R(c, 41, 4, 45, 4), "#e8a317"); c:px(40, 4, INK)
  fl(c, R(c, 29, 10, 31, 10), "#4a5a78")
  finish(c, "w1_wheel_tales")
end

local order = { "w1_forge_tales", "w1_egg_pick", "w1_spring_pickle", "w1_scrub_stones", "w1_splash_duel", "w1_star_float", "w1_toe_dip", "w1_guess_weight",
  "w1_bread_shapes", "w1_stall_shout", "w1_awning_mend", "w1_griddle_cakes", "w1_sweep_loft", "w1_cat_sack", "w1_wheel_tales" }
for _, s2 in ipairs(order) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
