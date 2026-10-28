-- variety-act-g13.lua : shrine Do-tab scenes (w3_*) -> act-<slug>.png (144x108, drawn on 72x54, out=2). Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g13.lua
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

---------------------------------------------------------------- shrine helpers
local STONE, STONED, STONEL = "#9a9ea6", "#7a8088", "#c0c4c8"
local MOSS, MOSSL, MOSSD = "#5e8a44", "#8fc462", "#3f6a32"

local function snail(c, x, y, d)
  d = d or 1
  local rows = { "..sss..", ".sSSs.a", ".sSSsba", "bbbbbb." }
  local leg = { s = "#a8602a", S = "#d9a660", b = "#e8d2a0", a = "#e8d2a0" }
  local m = c:mask()
  for j, r in ipairs(rows) do
    for i = 1, #r do
      local ch = r:sub(i, i)
      if ch ~= "." then
        local px = (d > 0) and (x + i - 1) or (x + 7 - i)
        c:px(px, y + j - 1, leg[ch]); m:set(px, y + j - 1)
      end
    end
  end
  c:outline(m, { ol = 1, olx = 0 })
end

local function rock(c, x, y, rx, ry, hex)
  part(c, c:ellipse(x, y, rx, ry), hex or STONE, { shade = true })
end

local function bucket(c, x0, y0, w, h, water)
  part(c, R(c, x0, y0, x0 + w, y0 + h), "#a8703e")
  fl(c, R(c, x0, y0 + 1, x0 + w, y0 + 1), "#5e3f28"); fl(c, R(c, x0, y0 + h - 1, x0 + w, y0 + h - 1), "#5e3f28")
  if water then fl(c, R(c, x0 + 1, y0, x0 + w - 1, y0), "#7ccfd4") end
end

local function stone_lantern(c, x, yb, s)
  s = s or 1
  part(c, R(c, x - 1, yb - 8 * s, x, yb), STONE, { noline = true })
  part(c, R(c, x - 3, yb - 1, x + 2, yb), STONED)
  part(c, R(c, x - 3, yb - 8 * s - 4, x + 2, yb - 8 * s), STONE)
  fl(c, R(c, x - 1, yb - 8 * s - 3, x, yb - 8 * s - 1), "#ffd86a")
  part(c, c:poly({ { x - 1, yb - 8 * s - 8 }, { x + 1, yb - 8 * s - 8 }, { x + 4, yb - 8 * s - 4 }, { x - 5, yb - 8 * s - 4 } }), STONED)
end

local function torii(c, x0, x1, yb, h, col)
  col = col or "#c0442e"
  part(c, R(c, x0, yb - h, x0 + 1, yb), col, { noline = true })
  part(c, R(c, x1 - 1, yb - h, x1, yb), col, { noline = true })
  part(c, R(c, x0 - 2, yb - h - 1, x1 + 2, yb - h + 1), "#3d2a1c")
  part(c, R(c, x0, yb - h + 4, x1, yb - h + 5), col)
end

local function pine2(c, x, yb, h) pine(c, x, yb, h, false) end

local function mosspatch(c, x, y, rx, ry)
  c:fill(c:ellipse(x, y, rx, ry), MOSS); c:fill(c:ellipse(x, y - 1, math.max(1, rx - 1), math.max(1, ry - 1)), MOSSL)
end

-- shrine garden backdrop (daylight): sky, hills, grass, optional back stone wall at y wy0..wy1
local function garden(c, g, o)
  o = o or {}
  day(c, g, { cloud = o.cloud, sky = o.sky, hill = o.hill or "#4e7a3a", hill2 = o.hill2 or "#5e8a44", grass = o.grass or "#6e9a4e", edge = o.edge or "#8fb868" })
end

---------------------------------------------------------------- scenes
local S = {}

-- 1. worn_carvings: gnome, hand on chin, studies a tall weathered stone with worn glyphs and snails
function S.w3_worn_carvings()
  seed = 61
  local c = new()
  garden(c, 36, { cloud = 20 })
  pine2(c, 10, 38, 16)
  torii(c, 56, 64, 38, 14)
  -- the tall, rough stone
  local st = c:poly({ { 29, 46 }, { 31, 28 }, { 30, 18 }, { 35, 9 }, { 42, 11 }, { 47, 8 }, { 51, 16 }, { 50, 30 }, { 52, 46 } })
  part(c, st, STONE, { shade = true })
  c:fill(c:poly({ { 33, 44 }, { 34, 28 }, { 33, 19 }, { 36, 14 }, { 37, 20 }, { 37, 44 } }), STONEL)
  c:fill(c:ellipse(41, 10, 5, 1), MOSS); c:fill(c:ellipse(40, 9, 2, 1), MOSSL)
  local G = "#5e6068"
  local gl = { { "g.g", "ggg", "g.." }, { ".g.", "ggg", ".g." }, { "ggg", "..g", "gg." }, { "g..", "ggg", "g.g" } }
  for ri = 0, 3 do
    for k = 0, 2 do
      local g = gl[(ri + k) % 4 + 1]
      for j, line in ipairs(g) do
        for i = 1, 3 do
          if line:sub(i, i) == "g" and not (ri >= 2 and (i + j + k) % 3 == 0) and not (ri == 3 and k == 1) then
            c:px(35 + k * 4 + i - 1, 17 + ri * 6 + j - 1, G)
          end
        end
      end
    end
  end
  mosspatch(c, 32, 45, 4, 2); mosspatch(c, 49, 45, 3, 1)
  snail(c, 42, 40, 1); snail(c, 34, 29, -1)
  gnome(c, 17, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 6 }, { 3, 9 }, true) } })
  c:px(23, 27, "#f4eee0"); c:px(25, 25, "#f4eee0"); c:px(27, 22, "#f4eee0")
  c:px(60, 47, "#9cc070"); c:px(10, 48, "#f4eee0")
  finish(c, "w3_worn_carvings")
end

-- 2. basin_water: climbing stone steps with a bucket in each hand to a mossy basin
function S.w3_basin_water()
  seed = 62
  local c = new()
  garden(c, 22, { cloud = 14 })
  pine2(c, 8, 28, 14); pine2(c, 15, 26, 10)
  for k = 0, 7 do
    local x0, top = 4 + k * 8, 44 - k * 4
    part(c, R(c, x0, top, W - 1, 52), (k % 2 == 0) and STONE or "#a8aeb4")
    fl(c, R(c, x0 + 1, top + 1, W - 2, top + 1), STONEL)
    fl(c, R(c, x0 + 1, top + 4, W - 2, top + 4), STONED)
    if k == 2 or k == 5 then fl(c, R(c, x0 + 3, top + 1, x0 + 5, top + 1), MOSS) end
  end
  part(c, c:ellipse(60, 15, 11, 6), MOSS, { shade = true })
  c:fill(c:ellipse(56, 11, 3, 1), MOSSL); c:fill(c:ellipse(64, 13, 2, 1), MOSSL)
  part(c, c:rrect(50, 15, 66, 20, 2), STONE, { shade = true })
  c:fill(c:ellipse(58, 16, 6, 1), "#7ccfd4"); c:fill(R(c, 54, 16, 57, 16), "#c8f0f0")
  local _, G = gnome(c, 32, 32, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 1 }, false), arm({ 4, 6 }, { 7, 1 }, true) } })
  bucket(c, 22, 36, 5, 6, true); bucket(c, 36, 36, 5, 6, true)
  fl(c, R(c, 24, 33, 24, 35), "#5e3f28"); fl(c, R(c, 38, 33, 38, 35), "#5e3f28")
  c:px(43, 41, "#7ccfd4"); c:px(44, 43, "#7ccfd4"); c:px(21, 40, "#7ccfd4"); c:px(20, 43, "#7ccfd4")
  finish(c, "w3_basin_water")
end

local function bird(c, x, y, col)
  c:fill(c:poly({ { x, y + 1 }, { x + 5, y + 1 }, { x + 3, y + 3 }, { x + 1, y + 3 } }), col)
  c:fill(c:poly({ { x + 2, y - 2 }, { x + 4, y + 1 }, { x + 1, y + 1 } }), col)
  c:px(x + 5, y + 1, "#e8a317"); c:px(x + 5, y + 2, "#e8a317")
  c:px(x + 1, y + 1, "#2a1a10")
  c:outline(c:poly({ { x, y + 1 }, { x + 5, y + 1 }, { x + 3, y + 3 }, { x + 1, y + 3 } }):add(c:poly({ { x + 2, y - 2 }, { x + 4, y + 1 }, { x + 1, y + 1 } })))
end

-- 3. paper_birds: behind a low table, folding a bird; a fence strung with finished ones
function S.w3_paper_birds()
  seed = 63
  local c = new()
  garden(c, 31, { cloud = false, sky = { "#c0dce8", "#d0e6ea", "#e0eee8" } })
  c:fill(R(c, 0, 31, W - 1, H - 1), "#8fb868")
  -- fence with strung birds
  for x = 7, 66, 6 do part(c, R(c, x, 18, x + 1, 36), "#b07a45", { noline = true }) end
  part(c, R(c, 5, 22, 68, 23), "#c8905a"); part(c, R(c, 5, 30, 68, 31), "#c8905a")
  c:fill(c:line({ { 5, 12 }, { 20, 16 }, { 36, 13 }, { 52, 17 }, { 68, 12 } }, 1), "#5e3f28")
  local cols = { "#f4eee0", "#f6b8cf", "#f5e6a8", "#a8d0f0", "#f4eee0", "#c8e8b0" }
  local pos = { { 8, 14 }, { 17, 16 }, { 27, 15 }, { 38, 14 }, { 47, 16 }, { 58, 14 }, { 64, 13 } }
  for i, p in ipairs(pos) do
    c:px(p[1] + 2, p[2] - 1, "#5e3f28")
    bird(c, p[1], p[2] + 1, cols[(i - 1) % 6 + 1])
  end
  -- table in front, gnome behind it
  gnome(c, 36, 41, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ -4, 5 }, { -3, 3 }, true, true), arm({ 4, 6 }, { 9, 9 }, true) } })
  part(c, R(c, 4, 38, 67, 42), "#b07a45"); fl(c, R(c, 5, 38, 66, 38), "#d9a660")
  part(c, R(c, 7, 43, 9, 50), "#8a5a35", { noline = true }); part(c, R(c, 62, 43, 64, 50), "#8a5a35", { noline = true })
  -- paper stack and finished birds on the table
  part(c, R(c, 9, 35, 16, 37), "#f6b8cf"); part(c, R(c, 10, 33, 17, 35), "#a8d0f0"); part(c, R(c, 8, 31, 15, 33), "#f5e6a8")
  bird(c, 52, 35, "#f4eee0"); bird(c, 59, 36, "#f6b8cf")
  -- the bird being folded, held up
  bird(c, 46, 25, "#f6b8cf"); c:px(44, 31, "#f6b8cf")
  finish(c, "w3_paper_birds")
end

-- 4. dip_tapers: lifting a pair of honey tapers from a pot of wax; cooled ones hang to dry
function S.w3_dip_tapers()
  seed = 64
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 42), "#a8703e")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 42), "#8a5a35") end
  fl(c, R(c, 0, 12, W - 1, 12), "#8a5a35")
  c:fill(R(c, 0, 43, W - 1, H - 1), "#6b3b2a")
  for y = 46, 52, 3 do fl(c, R(c, 0, y, W - 1, y), "#5e2f1e") end
  c:fill(c:rrect(24, 17, 40, 30, 2), "#c9a96e"); c:fill(R(c, 25, 18, 39, 29), "#a8d4e0")
  fl(c, R(c, 32, 18, 32, 29), "#8a5a35"); fl(c, R(c, 25, 24, 39, 24), "#8a5a35")
  -- drying beam with hanging tapers
  part(c, R(c, 5, 7, 40, 9), "#5e3f28")
  for i = 0, 6 do
    local x = 8 + i * 5
    fl(c, R(c, x, 10, x, 10), "#e8d2a0")
    fl(c, R(c, x - 1, 11, x, 12 + (i % 3) * 2 + 7), (i % 2 == 0) and "#e8a317" or "#f5cf6a")
    c:px(x, 10 + (i % 3) * 2 + 1 + 7 + 1, "#fff1c8")
  end
  -- pot on a brazier
  part(c, R(c, 48, 38, 64, 44), "#3d2a1c")
  part(c, c:poly({ { 46, 26 }, { 66, 26 }, { 64, 38 }, { 48, 38 } }), "#4a4e58")
  c:fill(c:ellipse(56, 26, 10, 2), "#e8a317"); c:fill(c:ellipse(55, 26, 6, 1), "#f5cf6a")
  fl(c, R(c, 47, 29, 47, 34), "#6a6e78")
  for _, x in ipairs({ 52, 56, 60 }) do c:fill(c:poly({ { x, 40 }, { x + 2, 40 }, { x + 1, 38 } }), "#e0501f") end
  c:px(56, 41, "#ffd86a"); c:px(52, 41, "#ffd86a")
  for i = 0, 2 do fl(c, c:ellipse(55 + i * 2 - (i % 2), 21 - i * 3, 2, 1), "#f4f8fa") end
  -- gnome lifting a rod with two dipped tapers
  local _, G = gnome(c, 31, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 9, 12 }, true) } })
  c:fill(c:line({ { 38, 31 }, { 52, 31 } }, 1), "#5e3f28")
  c:fill(R(c, 42, 32, 42, 37), "#e8d2a0"); c:fill(R(c, 50, 32, 50, 37), "#e8d2a0")
  fl(c, R(c, 41, 33, 43, 40), "#e8a317"); fl(c, R(c, 49, 33, 51, 41), "#e8a317")
  c:px(42, 41, "#f5cf6a"); c:px(50, 42, "#f5cf6a")
  fl(c, R(c, 46, 34, 46, 36), "#f5cf6a")
  finish(c, "w3_dip_tapers")
end

-- 5. shell_chime: knotting shells onto a hanging wooden ring under the eave
function S.w3_shell_chime()
  seed = 65
  local c = new()
  garden(c, 38, { cloud = 12, hill = "#4e7a3a" })
  -- eave and post
  part(c, R(c, 38, 5, 68, 9), "#8e2e1e"); fl(c, R(c, 38, 9, 68, 9), "#5e1e12")
  for x = 40, 66, 4 do fl(c, R(c, x, 6, x, 8), "#b04a36") end
  part(c, R(c, 62, 9, 66, 46), "#8a5a35", { noline = true })
  fl(c, R(c, 64, 10, 64, 44), "#6b3b2a")
  part(c, R(c, 36, 10, 62, 11), "#6b3b2a")
  -- the chime: ring, strings, shells
  part(c, c:ellipse(46, 15, 7, 2), "#c8905a")
  fl(c, R(c, 46, 11, 46, 13), "#e0c88a")
  local shells = {
    { 40, 24, "#f6b8cf" }, { 43, 31, "#f4eee0" }, { 46, 22, "#f5cf6a" }, { 49, 30, "#f4eee0" }, { 52, 25, "#f6b8cf" },
  }
  for _, s in ipairs(shells) do
    c:fill(R(c, s[1], 16, s[1], s[2] - 2), "#e0c88a")
    part(c, c:ellipse(s[1], s[2], 1, 1), s[3])
    c:px(s[1], s[2], "#c08a82")
    c:px(s[1], s[2] - 2, "#e0c88a")
  end
  -- gnome with raised hand flicking a shell, wicker basket of shells at the feet
  gnome(c, 24, 47, { d = 1, eyes = "happy", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 12, 16 }, true) } })
  part(c, c:ellipse(46, 45, 8, 3), "#c8905a", { shade = true })
  for i, p in ipairs({ { 42, 43 }, { 46, 42 }, { 50, 43 } }) do part(c, c:ellipse(p[1], p[2], 2, 1), (i == 2) and "#f6b8cf" or "#f4eee0") end
  -- wind lines and ring sparkles
  fl(c, R(c, 56, 20, 60, 20), "#f4f8fa"); fl(c, R(c, 55, 26, 58, 26), "#f4f8fa"); fl(c, R(c, 34, 35, 36, 35), "#f4f8fa")
  c:px(36, 28, "#fff1c8"); c:px(36, 27, "#f5cf6a"); c:px(55, 33, "#fff1c8"); c:px(54, 33, "#f5cf6a"); c:px(56, 33, "#f5cf6a")
  finish(c, "w3_shell_chime")
end

-- 6. moss_cushion: seated, patting damp moss onto a clay tray; a basket of moss clumps beside
function S.w3_moss_cushion()
  seed = 66
  local c = new()
  garden(c, 30, { cloud = 50 })
  -- low stone wall with moss and a lantern behind
  part(c, R(c, 5, 22, 68, 31), STONE, { noline = true })
  for x = 5, 68, 8 do fl(c, R(c, x, 22, x, 31), STONED) end
  fl(c, R(c, 5, 26, 68, 26), STONED); fl(c, R(c, 5, 22, 68, 22), STONEL)
  for _, x in ipairs({ 9, 24, 47, 62 }) do mosspatch(c, x, 22, 3, 1) end
  c:fill(R(c, 0, 32, W - 1, H - 1), "#7ea85a")
  for i = 0, 11 do c:px(6 + i * 5, 34 + (i % 4) * 3, "#5e8a44") end
  stone_lantern(c, 58, 31)
  -- gnome sits, patting
  local _, G = gnome(c, 14, 44, { d = 1, sit = true, eyes = "open", arms = { arm({ 4, 6 }, { 11, 3 }, true) } })
  -- clay tray with a rising cushion of moss
  part(c, R(c, 28, 41, 49, 45), "#b8661a")
  fl(c, R(c, 29, 41, 48, 41), "#d9894a")
  part(c, c:rrect(29, 33, 48, 42, 4), MOSS, { shade = true })
  c:fill(c:rrect(31, 34, 42, 37, 2), MOSSL)
  for _, p in ipairs({ { 36, 39 }, { 44, 38 }, { 32, 40 }, { 40, 41 } }) do c:px(p[1], p[2], MOSSD) end
  c:px(46, 35, MOSSL)
  -- basket of moss clumps and a bowl of water
  part(c, c:rrect(54, 41, 66, 48, 2), "#c8905a", { shade = true })
  for _, x in ipairs({ 57, 61, 65 }) do fl(c, R(c, x, 42, x, 47), "#8a5a35") end
  c:fill(c:ellipse(57, 40, 3, 2), MOSS); c:fill(c:ellipse(62, 39, 3, 2), MOSSL); c:fill(c:ellipse(65, 41, 2, 1), MOSS)
  c:px(56, 38, MOSSL); c:px(61, 37, MOSS)
  c:px(50, 38, "#5a4a30"); c:px(24, 48, "#9cc070")
  finish(c, "w3_moss_cushion")
end

-- 7. gift_house: on a ladder re-thatching the little gift-house roof, half old and half fresh gold
function S.w3_gift_house()
  seed = 67
  local c = new()
  garden(c, 30, { cloud = 14 })
  c:fill(R(c, 0, 31, W - 1, H - 1), "#7ea85a")
  pine2(c, 8, 33, 13)
  -- house on a post
  part(c, R(c, 52, 36, 53, 47), "#6b3b2a", { noline = true })
  part(c, R(c, 39, 25, 66, 36), "#b07a45")
  fl(c, R(c, 40, 26, 65, 26), "#c8905a")
  for x = 44, 62, 6 do fl(c, R(c, x, 27, x, 35), "#8a5a35") end
  part(c, R(c, 47, 28, 58, 36), "#3d2a1c")
  fl(c, R(c, 47, 28, 58, 28), "#2a1a10")
  -- small gifts inside
  part(c, c:ellipse(50, 34, 1, 1), "#c8802a"); c:px(49, 32, "#6b3b2a")
  part(c, c:ellipse(54, 34, 1, 1), "#f6b8cf"); c:px(54, 34, "#e8a317")
  part(c, R(c, 56, 33, 57, 35), "#dd3a2a")
  -- roof: old moss thatch on the left, fresh gold reed on the right
  local roof = c:poly({ { 36, 25 }, { 52, 11 }, { 70, 25 } })
  part(c, roof, "#7a6a46")
  c:fill(c:poly({ { 52, 11 }, { 70, 25 }, { 52, 25 } }), "#e8b84a")
  for i = 0, 5 do fl(c, R(c, 53 + i, 14 + i * 2, 53 + i, 14 + i * 2 + 1), "#c89a40") end
  for _, p in ipairs({ { 42, 21 }, { 46, 17 }, { 40, 24 }, { 49, 20 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), MOSS) end
  fl(c, R(c, 47, 14, 49, 14), MOSSL)
  fl(c, R(c, 52, 9, 52, 11), "#c89a40")
  -- drips from the old side
  c:px(41, 28, "#7ccfd4"); c:px(41, 30, "#7ccfd4"); c:px(44, 29, "#7ccfd4")
  -- ladder
  part(c, R(c, 24, 18, 25, 48), "#8a5a35", { noline = true }); part(c, R(c, 36, 18, 37, 48), "#8a5a35", { noline = true })
  for y = 22, 46, 5 do part(c, R(c, 25, y, 36, y), "#a8703e", { noline = true }) end
  local _, G = gnome(c, 30, 33, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 2 }, false), arm({ 4, 9 }, { 8, 15 }, true) } })
  local hx, hy = G.P(8, 15)
  part(c, R(c, hx - 1, hy - 7, hx + 3, hy - 1), "#e8b84a")
  fl(c, R(c, hx - 1, hy - 4, hx + 3, hy - 4), "#c89a40")
  fl(c, R(c, hx, hy - 8, hx, hy - 7), "#e8b84a"); fl(c, R(c, hx + 2, hy - 9, hx + 2, hy - 7), "#e8b84a")
  -- a bundle of reeds waiting at the foot
  part(c, R(c, 8, 44, 18, 46), "#e8b84a"); fl(c, R(c, 10, 44, 10, 46), "#c89a40"); fl(c, R(c, 15, 44, 15, 46), "#c89a40")
  finish(c, "w3_gift_house")
end

-- 8. shrine_rill (autumn): raking a leaf jam out of a stone channel; a surprised newt on the dam
function S.w3_shrine_rill()
  seed = 68
  local c = new()
  garden(c, 34, { cloud = false, sky = { "#c8d8d8", "#dce4d8", "#ece6d0" }, hill = "#7a8a3a", hill2 = "#8a8a3a", grass = "#8a9a48", edge = "#a8b060" })
  -- autumn tree
  part(c, R(c, 8, 22, 11, 38), "#6b4a2e", { noline = true })
  part(c, c:ellipse(10, 15, 11, 9), "#d8742a", { shade = true })
  c:fill(c:ellipse(7, 12, 4, 2), "#e8a317"); c:fill(c:ellipse(14, 17, 3, 2), "#b8441e")
  for _, p in ipairs({ { 22, 22 }, { 26, 28 }, { 17, 32 }, { 56, 14 }, { 62, 24 }, { 50, 30 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), (p[1] % 2 == 0) and "#d8742a" or "#e8a317") end
  -- the channel: stone lips, water, leaf jam
  part(c, R(c, 5, 39, 68, 48), STONE)
  fl(c, R(c, 5, 39, 68, 39), STONEL); fl(c, R(c, 5, 48, 68, 48), STONED)
  c:fill(R(c, 6, 41, 67, 46), "#4a9ab8")
  c:fill(R(c, 46, 41, 67, 46), "#7ccfd4")
  for _, p in ipairs({ { 50, 42 }, { 56, 44 }, { 62, 42 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#c8f0f0") end
  for _, p in ipairs({ { 8, 42 }, { 14, 44 }, { 20, 42 }, { 27, 45 }, { 33, 43 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2] + 1), (p[1] % 2 == 0) and "#d8742a" or "#b8441e") end
  part(c, c:ellipse(40, 42, 8, 3), "#8a5a35", { shade = true })
  for _, p in ipairs({ { 34, 41 }, { 40, 39 }, { 44, 42 }, { 37, 43 }, { 42, 44 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2] + 1), (p[1] % 2 == 0) and "#d8742a" or "#e8a317") end
  fl(c, R(c, 35, 40, 35, 39), "#6b4a2e"); fl(c, R(c, 46, 41, 47, 39), "#6b4a2e")
  -- newt on top of the jam
  part(c, R(c, 36, 35, 43, 37), "#4a9a3a")
  fl(c, R(c, 44, 34, 46, 36), "#4a9a3a"); fl(c, R(c, 36, 38, 36, 38), "#4a9a3a"); fl(c, R(c, 35, 36, 35, 36), "#4a9a3a")
  c:px(45, 34, "#2a1a10"); c:px(46, 34, "#f4eee0"); c:px(38, 36, "#f5cf6a"); c:px(41, 36, "#f5cf6a"); fl(c, R(c, 38, 37, 41, 37), "#e8a317")
  fl(c, R(c, 41, 38, 41, 39), "#4a9a3a"); fl(c, R(c, 38, 38, 38, 39), "#4a9a3a")
  c:px(49, 32, "#f4eee0"); c:px(50, 31, "#f4eee0"); c:px(51, 33, "#f4eee0"); c:px(41, 30, "#f4eee0"); c:px(41, 31, "#f4eee0"); c:px(41, 32, "#f4eee0")
  -- gnome with a rake
  local _, G = gnome(c, 22, 37, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 7, 9 }, true) } })
  c:fill(c:line({ { 29, 31 }, { 36, 43 } }, 1), "#5e3f28")
  fl(c, R(c, 33, 44, 38, 44), "#5e3f28"); fl(c, R(c, 33, 45, 33, 46), "#5e3f28"); fl(c, R(c, 35, 45, 35, 46), "#5e3f28"); fl(c, R(c, 37, 45, 37, 46), "#5e3f28")
  finish(c, "w3_shrine_rill")
end

-- 9. sunken_stones: levering a moss-swallowed stepping stone back up with a pole
function S.w3_sunken_stones()
  seed = 69
  local c = new()
  garden(c, 28, { cloud = 52 })
  c:fill(R(c, 0, 29, W - 1, H - 1), "#5e8a44")
  for i = 0, 16 do c:px(6 + i * 4, 31 + (i % 5) * 4, "#7ab55c"); c:px(7 + i * 4, 31 + (i % 5) * 4, "#7ab55c") end
  stone_lantern(c, 60, 34)
  -- stepping stones along a curve, mossed over
  local function sunk(x, y, rx, ry)
    c:fill(c:ellipse(x, y, rx, ry), "#4e7a3a")
    c:fill(c:ellipse(x, y - 1, rx - 1, ry - 1), STONE)
    c:fill(c:ellipse(x, y + 1, rx, math.max(1, ry - 1)):clip(R(c, 0, y, W, H)), MOSS)
    c:fill(c:ellipse(x - 2, y, rx - 3, 1), MOSSL)
  end
  sunk(9, 46, 7, 3); sunk(25, 47, 7, 3); sunk(62, 46, 7, 3)
  -- the stone being heaved up on a lever
  part(c, c:ellipse(46, 45, 8, 2), "#5e3f28", { noline = true })
  c:fill(c:ellipse(46, 45, 7, 1), "#4a2c1a")
  part(c, c:poly({ { 38, 40 }, { 44, 33 }, { 54, 33 }, { 56, 40 }, { 50, 45 }, { 40, 45 } }), STONE, { shade = true })
  c:fill(R(c, 45, 34, 50, 34), STONEL)
  c:fill(c:ellipse(41, 43, 2, 1), MOSS); c:fill(c:ellipse(53, 42, 2, 1), MOSS)
  rock(c, 36, 46, 3, 2, STONED)
  -- gnome pushes the pole down
  local _, G = gnome(c, 14, 40, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 6 }, true), arm({ -3, 6 }, { 5, 3 }, true) } })
  c:fill(c:line({ { 21, 31 }, { 45, 43 } }, 2), "#8a5a35")
  fl(c, R(c, 22, 32, 23, 32), "#a8703e")
  c:px(60, 47, "#f4eee0"); c:px(34, 38, "#f4eee0")
  finish(c, "w3_sunken_stones")
end

-- the deep-bowing gnome (side view, facing right). bow = 1 deep, 0 nod
local function bow(c, ox, oy, hat)
  local BODY, BEARD, SKIN, BOOT = "#4a6e9a", "#f4eee0", "#f0c8a0", "#5a3a22"
  local sil = c:mask()
  local function pp(m, hex)
    c:part(m, GV.ramp(hex, { rim = hex }), { flat = true, gloss = false, contact = false, outline = false, contour = false })
    sil:add(m)
  end
  pp(R(c, ox - 3, oy - 1, ox + 2, oy), BOOT)
  pp(R(c, ox - 2, oy - 8, ox + 1, oy - 2), BODY)
  pp(R(c, ox - 4, oy - 12, ox + 7, oy - 8), BODY)       -- torso, level
  pp(R(c, ox + 7, oy - 12, ox + 11, oy - 8), SKIN)      -- head lowered
  pp(R(c, ox + 7, oy - 8, ox + 11, oy - 4), BEARD)      -- beard hangs down
  c:px(ox + 9, oy - 10, INK); c:px(ox + 11, oy - 9, "#e08a7a")
  pp(R(c, ox + 3, oy - 7, ox + 4, oy - 3), BODY)        -- arm hanging
  pp(R(c, ox + 3, oy - 4, ox + 5, oy - 3), SKIN)
  local h = c:poly({ { ox + 5, oy - 14 }, { ox + 12, oy - 13 }, { ox + 18, oy - 8 }, { ox + 12, oy - 11 }, { ox + 5, oy - 11 } })
  pp(h, hat or "#c0442e")
  pp(R(c, ox + 6, oy - 14, ox + 6, oy - 10), "#8e2e1e")
  c:outline(sil, { ol = 1, olx = 0 })
end

-- 10. politest_bow: two pilgrims bowing at the gate, the red-hat deep, the other a polite nod
function S.w3_politest_bow()
  seed = 70
  local c = new()
  garden(c, 33, { cloud = 12, hill = "#4e7a3a" })
  c:fill(R(c, 0, 34, W - 1, H - 1), "#7ea85a")
  c:fill(c:poly({ { 28, 34 }, { 44, 34 }, { 60, 50 }, { 12, 50 } }), "#c9a96e")
  for _, p in ipairs({ { 30, 37 }, { 40, 38 }, { 24, 43 }, { 47, 44 }, { 35, 47 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#b8965c") end
  pine2(c, 10, 36, 14); pine2(c, 63, 35, 15)
  torii(c, 26, 46, 36, 21)
  fl(c, R(c, 32, 17, 40, 21), "#f4eee0")
  c:paint({ "..g..", ".ggg.", "ggggg", ".ggg.", ".g.g." }, 34, 15, { g = "#f5cf6a" })
  bow(c, 16, 46, "#c0442e")
  gnome(c, 56, 46, { d = -1, eyes = "shut", hat = "#e8a317", arms = { arm({ -4, 6 }, { -5, 3 }, true), arm({ 4, 6 }, { 5, 3 }, true) } })
  c:px(50, 24, "#fff1c8"); c:px(30, 26, "#fff1c8")
  finish(c, "w3_politest_bow")
end

-- 11. pebble_stack: behind a low wall, setting the last pebble on a wobbling tower; the keeper's tower is steadier
function S.w3_pebble_stack()
  seed = 71
  local c = new()
  garden(c, 30, { cloud = 56, hill = "#4e7a3a" })
  c:fill(R(c, 0, 31, W - 1, H - 1), "#7ea85a")
  pine2(c, 63, 33, 14)
  -- gnome behind the wall
  local _, G = gnome(c, 18, 40, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, true), arm({ 4, 10 }, { 12, 17 }, true) } })
  -- wall
  part(c, R(c, 5, 38, 68, 49), STONE)
  for x = 5, 68, 9 do fl(c, R(c, x, 38, x, 43), STONED) end
  for x = 9, 68, 9 do fl(c, R(c, x, 44, x, 49), STONED) end
  fl(c, R(c, 5, 43, 68, 43), STONED); fl(c, R(c, 5, 38, 68, 38), STONEL)
  mosspatch(c, 22, 38, 3, 1); mosspatch(c, 58, 49, 4, 1)
  -- tall wobbly tower
  local tower = {
    { 40, 36, 6, 2, "#8b8f96" }, { 41, 32, 4, 3, "#a8aeb4" }, { 39, 28, 5, 2, "#7a8088" }, { 42, 24, 3, 3, "#b8bcc4" }, { 40, 20, 3, 2, "#9a9ea6" },
  }
  for _, t in ipairs(tower) do part(c, c:ellipse(t[1], t[2], t[3], t[4]), t[5]) end
  -- the pebble about to land
  part(c, c:ellipse(37, 15, 2, 2), "#b8bcc4")
  c:px(36, 14, STONEL)
  fl(c, R(c, 31, 17, 33, 19), "#f0c8a0")
  -- the keeper's steadier tower
  local t2 = { { 56, 36, 7, 2, "#8b8f96" }, { 56, 32, 6, 2, "#a8aeb4" }, { 56, 29, 4, 2, "#7a8088" }, { 56, 26, 3, 2, "#9a9ea6" } }
  for _, t in ipairs(t2) do part(c, c:ellipse(t[1], t[2], t[3], t[4]), t[5]) end
  c:px(30, 24, "#f4eee0"); c:px(31, 22, "#f4eee0")
  snail(c, 26, 34, 1)
  finish(c, "w3_pebble_stack")
end

-- 12. small_gifts: leaving a flower on the flat stone by the steps; what others left sits beside it
function S.w3_small_gifts()
  seed = 72
  local c = new()
  garden(c, 24, { cloud = 50, hill = "#4e7a3a" })
  c:fill(R(c, 0, 25, W - 1, H - 1), "#7ea85a")
  -- stone steps behind
  for k = 3, 0, -1 do
    part(c, R(c, 22 - k * 2 + 6, 21 + (3 - k) * 4 - 0, 50 + k * 2 - 6, 25 + (3 - k) * 4), (k % 2 == 0) and "#a8aeb4" or STONE)
  end
  stone_lantern(c, 12, 30, 1); stone_lantern(c, 60, 30, 1)
  -- the flat stone on a stump of rock
  part(c, R(c, 36, 41, 64, 48), STONED)
  fl(c, R(c, 38, 43, 40, 47), STONE)
  part(c, c:rrect(32, 37, 68, 42, 3), STONEL, { shade = true })
  c:fill(c:ellipse(46, 38, 5, 1), "#d4d8dc")
  mosspatch(c, 36, 48, 3, 1); mosspatch(c, 64, 48, 3, 1)
  -- gifts: acorn, berry, shell, button, folded note, flower
  part(c, c:ellipse(40, 36, 2, 2), "#a8602a"); fl(c, R(c, 38, 34, 42, 34), "#6b3b2a"); c:px(40, 33, "#6b3b2a")
  part(c, c:ellipse(46, 36, 1, 1), "#dd3a2a"); c:px(46, 35, "#fff1c8")
  part(c, c:ellipse(50, 37, 2, 1), "#f6b8cf"); c:px(50, 37, "#c08a82")
  part(c, R(c, 54, 34, 57, 37), "#f4eee0"); c:px(55, 35, "#a8d0f0"); c:px(56, 36, "#a8d0f0")
  part(c, c:ellipse(61, 37, 1, 1), "#5ab0d8"); c:px(61, 37, "#f4f8fa")
  -- the gnome holding a flower out
  gnome(c, 22, 47, { d = 1, eyes = "happy", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 7 }, { 9, 9 }, true) } })
  fl(c, R(c, 31, 41, 31, 46), "#4e8a3c")
  part(c, c:ellipse(31, 39, 2, 2), "#f5cf6a"); c:px(31, 39, "#dd3a2a")
  c:px(27, 31, "#fff1c8"); c:px(26, 31, "#f5cf6a"); c:px(28, 31, "#f5cf6a"); c:px(27, 30, "#f5cf6a"); c:px(27, 32, "#f5cf6a")
  finish(c, "w3_small_gifts")
end

-- 13. shrine_mosses: kneeling with a magnifying glass, a boulder of many mosses, lens full of tiny stars
function S.w3_shrine_mosses()
  seed = 73
  local c = new()
  garden(c, 24, { cloud = 14, sky = { "#c0dcd0", "#d0e6d4", "#e0eed8" } })
  c:fill(R(c, 0, 25, W - 1, H - 1), "#6e9a4e")
  -- boulder, patched with different mosses
  part(c, c:ellipse(52, 36, 22, 15), "#8e9298", { shade = true })
  c:fill(c:ellipse(46, 26, 12, 4), MOSS); c:fill(c:ellipse(56, 30, 8, 3), "#9aa84a"); c:fill(c:ellipse(60, 40, 6, 3), "#3f8a6a")
  c:fill(c:ellipse(42, 38, 5, 3), "#c8a040"); c:fill(c:ellipse(52, 44, 7, 2), MOSSD); c:fill(c:ellipse(48, 25, 5, 1), MOSSL)
  for _, p in ipairs({ { 38, 30 }, { 64, 34 }, { 54, 36 }, { 46, 42 } }) do c:px(p[1], p[2], MOSSL); c:px(p[1] + 1, p[2] - 1, MOSSL) end
  -- gnome kneeling on the grass
  local _, G = gnome(c, 12, 44, { d = 1, sit = true, eyes = "open", arms = { arm({ 4, 6 }, { 9, 8 }, true) } })
  -- lens
  local lx, ly = 30, 33
  c:fill(c:line({ { 21, 35 }, { 26, 36 } }, 2), "#6b3b2a")
  part(c, c:ellipse(lx, ly, 7, 7), "#8a5a35")
  c:fill(c:ellipse(lx, ly, 5, 5), "#b8dce8")
  c:fill(c:ellipse(lx, ly, 5, 5):clip(R(c, 0, ly - 1, W, H)), "#7ab55c")
  c:fill(c:ellipse(lx + 1, ly + 2, 4, 2), MOSSD)
  c:fill(c:ellipse(lx - 2, ly, 1, 1), "#c8e890")
  for _, p in ipairs({ { 28, 32 }, { 31, 36 }, { 33, 33 }, { 27, 35 } }) do
    c:px(p[1], p[2], "#e8f8c0"); c:px(p[1] - 1, p[2], "#9ad060"); c:px(p[1] + 1, p[2], "#9ad060"); c:px(p[1], p[2] - 1, "#9ad060"); c:px(p[1], p[2] + 1, "#9ad060")
  end
  c:px(27, 30, "#f4f8fa"); c:px(28, 29, "#f4f8fa")
  -- string and tiny flowers
  c:fill(c:line({ { 17, 25 }, { 23, 33 } }, 1), "#e0c88a")
  c:px(8, 49, "#f4eee0"); c:px(9, 48, "#f5cf6a"); c:px(66, 22, "#f4eee0")
  finish(c, "w3_shrine_mosses")
end

-- 14. ringing_stone: three grey stones by the path; tapping the middle one makes it ring
function S.w3_ringing_stone()
  seed = 74
  local c = new()
  garden(c, 31, { cloud = 12 })
  c:fill(R(c, 0, 32, W - 1, H - 1), "#8fb868")
  c:fill(c:poly({ { 8, 36 }, { 64, 36 }, { 70, 50 }, { 2, 50 } }), "#d0b078")
  for _, p in ipairs({ { 10, 41 }, { 28, 47 }, { 46, 40 }, { 60, 45 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#b8965c") end
  pine2(c, 8, 33, 15); pine2(c, 63, 33, 12)
  -- the three stones
  part(c, c:rrect(24, 41, 34, 47, 3), "#8b8f96", { shade = true })
  part(c, c:rrect(38, 31, 52, 47, 5), "#8aa0b4", { shade = true })
  c:fill(c:rrect(40, 33, 42, 41, 1), "#cfe0ec"); c:px(41, 33, "#f4f8fa")
  part(c, c:rrect(56, 38, 66, 47, 4), "#9a8a7a", { shade = true })
  mosspatch(c, 29, 47, 3, 1); mosspatch(c, 61, 47, 3, 1)
  -- sound rings above the middle stone
  for r = 1, 3 do
    local m = c:ellipse(45, 30, 5 + r * 4, 3 + r * 2):cut(c:ellipse(45, 30, 4 + r * 4, 2 + r * 2)):clip(R(c, 6, 5, 67, 29))
    c:fill(m, (r == 1) and "#fff1c8" or "#f5e6a8")
  end
  c:px(45, 20, "#f4f8fa")
  -- gnome tapping with a little wooden mallet
  gnome(c, 14, 47, { d = 1, eyes = "happy", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 7 }, { 11, 11 }, true) } })
  c:fill(c:line({ { 27, 34 }, { 35, 34 } }, 1), "#8a5a35")
  part(c, R(c, 35, 31, 37, 35), "#a8703e")
  finish(c, "w3_ringing_stone")
end

-- 15. lit_lantern: night hedge with four glowing paper lanterns, the gnome cupping a hand at one
function S.w3_lit_lantern()
  seed = 75
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#141c3a", "#1c2646", "#253258", "#2e3e66" }, { dir = "v" })
  for _, p in ipairs({ { 8, 8 }, { 20, 12 }, { 33, 7 }, { 47, 11 }, { 58, 8 }, { 66, 14 }, { 14, 18 }, { 52, 19 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(63, 10, 3, 3), "#f5e6a8"); c:fill(c:ellipse(65, 9, 2, 2), "#1c2646")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#1c3a30")
  -- hedge
  part(c, R(c, 5, 20, 68, 36), "#1f4a2e", { noline = true })
  seed = 75
  for i = 1, 70 do
    local x, y = 6 + floor(rand() * 62), 21 + floor(rand() * 15)
    c:px(x, y, (i % 3 == 0) and "#2e6a3c" or "#163a24")
  end
  for x = 5, 68, 3 do c:px(x, 20 + (x % 2), "#2e6a3c") end
  -- glowing moss on the ground
  for _, e in ipairs({ { 14, 44, 9, 2 }, { 40, 48, 10, 2 }, { 58, 43, 8, 2 }, { 28, 41, 5, 1 } }) do
    c:fill(c:ellipse(e[1], e[2], e[3], e[4]), "#6ac47a"); c:fill(c:ellipse(e[1], e[2] - 1, e[3] - 2, math.max(1, e[4] - 1)), "#b8f090")
  end
  -- rail and lanterns
  fl(c, R(c, 5, 14, 68, 14), "#5e3f28")
  for i, x in ipairs({ 13, 28, 44, 59 }) do
    fl(c, R(c, x, 14, x, 17), "#5e3f28")
    part(c, c:ellipse(x, 22, 4, 5), "#f5d070", { shade = true, cres = 1 })
    c:fill(c:ellipse(x, 22, 3, 4), "#fff1c8")
    fl(c, R(c, x - 3, 18, x + 3, 18), "#8a5a35"); fl(c, R(c, x - 2, 27, x + 2, 27), "#8a5a35")
    fl(c, R(c, x, 19, x, 26), "#f5d070")
    for _, d in ipairs({ { -7, -3 }, { 7, 0 }, { -6, 4 } }) do c:px(x + d[1], 22 + d[2], "#f5d070") end
  end
  -- inside: a real flame (3rd), a glow-worm (1st)
  fl(c, R(c, 44, 22, 44, 24), "#e0501f"); c:px(44, 21, "#e0501f"); fl(c, R(c, 43, 23, 45, 24), "#f08a24")
  c:px(13, 23, "#4a8a3e"); c:px(13, 24, "#2e6a3c")
  -- gnome peering with a cupped hand
  gnome(c, 38, 48, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 5, 14 }, true) } })
  c:px(5, 47, "#b8f090")
  finish(c, "w3_lit_lantern")
end

local order = { "w3_worn_carvings", "w3_basin_water", "w3_paper_birds", "w3_dip_tapers", "w3_shell_chime", "w3_moss_cushion", "w3_gift_house", "w3_shrine_rill", "w3_sunken_stones", "w3_politest_bow", "w3_pebble_stack", "w3_small_gifts", "w3_shrine_mosses", "w3_ringing_stone", "w3_lit_lantern" }
for _, s2 in ipairs(order) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
