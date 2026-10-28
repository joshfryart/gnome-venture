-- variety-act-h6.lua : first-pass regional rest-stop activity scenes (group h6) -> act-<slug>.png (144x108, 72x54 grid, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-h6.lua   (params BEFORE --script)
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
  assert(t.semi == 0 and t.bw == 0, slug .. " semi=" .. t.semi .. " bw=" .. t.bw)
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

---------------------------------------------------------------- shared bits (h6)
local function rocks(c, list, col)
  for _, p in ipairs(list) do part(c, c:ellipse(p[1], p[2], p[3], p[4]), col or "#9a9ea6", { shade = true }) end
end
local function ripples(c, list, col)
  for _, p in ipairs(list) do fl(c, R(c, p[1], p[2], p[1] + (p[3] or 4), p[2]), col) end
end
local function stars(c, list, col) for _, p in ipairs(list) do c:px(p[1], p[2], col or "#f4eee0") end end
local function spark(c, x, y, a, b)
  a, b = a or "#fff1c8", b or "#f5cf6a"
  c:px(x, y, a); c:px(x - 1, y, b); c:px(x + 1, y, b); c:px(x, y - 1, b); c:px(x, y + 1, b)
end
local function tree(c, x, yb, r, col, trunk)
  part(c, R(c, x - 1, yb - r, x, yb), trunk or "#6b4a2e", { noline = true })
  part(c, c:ellipse(x, yb - r - 1, r, rnd(r * 0.85)), col or "#3f8a42", { shade = true })
end
local function sheep(c, x, y, d)
  part(c, c:ellipse(x, y, 4, 3), "#f4eee0")
  part(c, R(c, x + d * 4, y - 2, x + d * 5 + (d > 0 and 1 or -1), y + 1), "#3a2c26", { noline = true })
  fl(c, R(c, x - 2, y + 2, x - 2, y + 4), "#3a2c26"); fl(c, R(c, x + 2, y + 2, x + 2, y + 4), "#3a2c26")
end
local function goose(c, x, y, d)
  local hd = (d > 0) and 1 or -1
  part(c, c:ellipse(x, y, 4, 2), "#f4eee0")
  fl(c, R(c, x + hd * 3, y - 4, x + hd * 3 + (hd > 0 and 1 or 0), y - 1), "#f4eee0")
  fl(c, R(c, x + hd * 3, y - 5, x + hd * 4, y - 5), "#f4eee0")
  c:px(x + hd * 5, y - 5, "#e8a317"); c:px(x + hd * 4, y - 5, "#f4eee0")
  fl(c, R(c, x - 1, y + 2, x - 1, y + 3), "#e8a317"); fl(c, R(c, x + 1, y + 2, x + 1, y + 3), "#e8a317")
  c:px(x - hd * 4, y - 1, "#cfdcdc")
end
local function cat(c, x, y, col)
  part(c, c:ellipse(x, y, 3, 2), col)
  part(c, c:ellipse(x + 3, y - 3, 2, 2), col)
  fl(c, R(c, x + 2, y - 6, x + 2, y - 5), col); fl(c, R(c, x + 4, y - 6, x + 4, y - 5), col)
  c:px(x + 3, y - 3, INK); c:px(x + 4, y - 3, INK)
  fl(c, R(c, x - 5, y - 3, x - 5, y), col); fl(c, R(c, x - 4, y, x - 3, y), col)
end
local function note(c, x, y, col)
  col = col or "#fff1c8"
  c:px(x, y, col); c:px(x + 1, y, col); c:px(x + 1, y - 1, col); c:px(x + 1, y - 2, col); c:px(x + 1, y - 3, col); c:px(x + 2, y - 3, col)
end
-- a sleeping gnome lying on his back, head left (x = head centre, y = body centre row)
local function lying(c, x, y, eyes)
  local sil = c:mask()
  local function pp(m, hex)
    c:part(m, GV.ramp(hex, { rim = hex }), { flat = true, gloss = false, contact = false, outline = false, contour = false })
    sil:add(m)
  end
  pp(R(c, x + 4, y - 2, x + 16, y + 2), "#4a6e9a")
  pp(R(c, x + 17, y - 3, x + 19, y + 1), "#5a3a22")
  pp(R(c, x + 3, y, x + 11, y + 3), "#f4eee0")
  pp(R(c, x - 3, y - 3, x + 3, y + 2), "#f0c8a0")
  pp(R(c, x - 3, y + 1, x + 2, y + 3), "#f4eee0")
  local hat = c:poly({ { x - 3, y - 4 }, { x + 4, y - 4 }, { x - 9, y - 12 } })
  pp(hat, "#c0442e"); pp(R(c, x - 4, y - 4, x + 5, y - 3), "#8e2e1e")
  c:outline(sil, { ol = 1, olx = 0 })
  c:px(x - 1, y - 1, "#8a4a34"); c:px(x + 1, y - 1, "#8a4a34")
  c:px(x + 3, y, "#e08a7a")
end

---------------------------------------------------------------- scenes
local S = {}

-- Amazon: heavy mallet raised over a brazil-nut pod on a flat stone
function S.r_sa_nut_pod_crack()
  seed = 101
  local c = new()
  day(c, 36, { sky = { "#9fd0b0", "#b4dcb8", "#c8e6c0" }, cloud = false, hill = "#3f7f45", hill2 = "#2f6a3a", grass = "#5a8a42", edge = "#7aa855" })
  part(c, R(c, 55, 8, 61, 38), "#7a5a3a", { noline = true })
  fl(c, R(c, 57, 12, 57, 36), "#5e3f28")
  c:fill(c:ellipse(58, 8, 14, 6), "#2f6a3a"); c:fill(c:ellipse(40, 5, 10, 3), "#3f7f45"); c:fill(c:ellipse(18, 7, 12, 5), "#2f6a3a")
  c:fill(c:ellipse(52, 5, 5, 2), "#4a9a4a"); c:fill(c:ellipse(22, 5, 4, 1), "#4a9a4a")
  for _, x in ipairs({ 46, 49, 66 }) do fl(c, R(c, x, 11, x, 20 + (x % 5)), "#4e8a3c") end
  -- hanging pods in the canopy
  part(c, c:ellipse(49, 14, 2, 2), "#6b4a2e", { noline = true }); part(c, c:ellipse(65, 13, 2, 2), "#6b4a2e", { noline = true })
  -- workshop bench stump + flat stone
  part(c, R(c, 62, 42, 67, 49), "#8a5a35"); fl(c, R(c, 63, 43, 66, 43), "#a8703e")
  part(c, R(c, 34, 43, 54, 47), "#9a9ea6", { shade = true })
  fl(c, R(c, 35, 43, 53, 43), "#b8bcc2")
  -- pod, cracked open
  part(c, c:ellipse(44, 39, 5, 5), "#7a5236")
  c:fill(c:line({ { 41, 36 }, { 43, 39 }, { 45, 41 } }, 1), "#d9bc84")
  fl(c, R(c, 41, 41, 42, 41), "#d9bc84")
  c:px(42, 36, "#a8703e"); c:px(46, 37, "#a8703e")
  -- crescent nuts and shards flying
  for _, p in ipairs({ { 53, 41 }, { 31, 45 }, { 58, 45 } }) do
    c:fill(c:poly({ { p[1], p[2] }, { p[1] + 3, p[2] }, { p[1] + 1, p[2] + 2 } }), "#e8d2a0"); c:px(p[1] + 1, p[2] + 2, "#8a5a35")
  end
  for _, p in ipairs({ { 37, 33 }, { 51, 31 }, { 48, 35 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#7a5236") end
  spark(c, 36, 36); spark(c, 52, 34)
  -- mallet over the head: handle first so the hand sits on it
  c:fill(c:line({ { 33, 37 }, { 41, 27 } }, 2), "#a8703e")
  part(c, R(c, 36, 19, 47, 26), "#8a5a35")
  fl(c, R(c, 36, 20, 47, 20), "#a8703e"); fl(c, R(c, 40, 19, 40, 26), "#5e3f28"); fl(c, R(c, 44, 19, 44, 26), "#5e3f28")
  gnome(c, 28, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { 0, 14 }, false), arm({ 4, 8 }, { 6, 15 }, true) } })
  finish(c, "r_sa_nut_pod_crack")
end

-- Amazon: shoving a pale balsa raft off a mudbank
function S.r_sa_raft_launch()
  seed = 102
  local c = new()
  day(c, 30, { sky = { "#b0dccc", "#c6e6cc", "#d8eed0" }, cloud = 50, hill = "#3f7f45", hill2 = "#2f6a3a", grass = "#7aa08a", edge = "#5a8a5a" })
  tree(c, 12, 33, 7, "#2f6a3a"); tree(c, 62, 33, 8, "#3f7f45")
  c:fill(R(c, 0, 33, W - 1, H - 1), "#7ea6a2")
  ripples(c, { { 40, 36, 6 }, { 55, 39 }, { 20, 34 }, { 60, 45, 6 }, { 48, 48 }, { 36, 44 } }, "#a8cccc")
  -- mud bank
  c:fill(c:poly({ { 0, 54 }, { 0, 38 }, { 24, 38 }, { 32, 44 }, { 38, 54 } }), "#8a6a48")
  c:fill(c:poly({ { 0, 54 }, { 0, 44 }, { 20, 44 }, { 28, 49 }, { 30, 54 } }), "#6b4e34")
  for _, p in ipairs({ { 6, 41 }, { 14, 40 }, { 22, 41 }, { 8, 48 }, { 17, 49 } }) do c:px(p[1], p[2], "#b8946a"); c:px(p[1] + 1, p[2], "#b8946a") end
  -- balsa raft, light logs with rope lashings
  for i = 0, 3 do
    local y = 36 + i * 3
    part(c, R(c, 34, y, 62, y + 2), (i % 2 == 0) and "#ead6a0" or "#dcc388")
    part(c, c:ellipse(34, y + 1, 1, 1), "#c8a45e", { noline = true })
  end
  fl(c, R(c, 41, 36, 41, 46), "#6b4a2e"); fl(c, R(c, 55, 36, 55, 46), "#6b4a2e")
  fl(c, R(c, 40, 37, 42, 37), "#8a6a44"); fl(c, R(c, 54, 37, 56, 37), "#8a6a44")
  -- push marks
  fl(c, R(c, 30, 34, 33, 34), "#f4eee0"); fl(c, R(c, 29, 47, 33, 47), "#6b4e34")
  fl(c, R(c, 66, 41, 68, 41), "#f4f8fa"); fl(c, R(c, 63, 47, 66, 47), "#f4f8fa")
  gnome(c, 22, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 8 }, { 10, 8 }, true), arm({ -4, 7 }, { 8, 5 }, false) } })
  finish(c, "r_sa_raft_launch")
end

-- Amazon dusk: telling dolphin tales on stone landing steps, pink dolphin leaps
function S.r_sa_dolphin_tales()
  seed = 103
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 32), { "#3b3a72", "#6a4a88", "#a8588a", "#d8706e", "#f09a68", "#f8c07a" }, { dir = "v" })
  stars(c, { { 10, 8 }, { 26, 7 }, { 44, 9 }, { 60, 8 } })
  c:fill(c:ellipse(52, 31, 20, 4), "#2f3a50"); c:fill(c:ellipse(14, 31, 14, 3), "#2f3a50")
  for _, x in ipairs({ 44, 50, 57, 63 }) do c:fill(c:ellipse(x, 28, 3, 3), "#2a3248") end
  c:bands(R(c, 0, 32, W - 1, H - 1), { "#d88a58", "#c8784a", "#b86a4a", "#a45a48" }, { dir = "v" })
  ripples(c, { { 34, 34, 8 }, { 48, 36, 6 }, { 56, 40, 9 }, { 40, 44, 7 }, { 62, 47, 5 } }, "#f6b878")
  -- dolphin arc: leaping out of the water on the left, diving back on the right
  local pc = "#e89aa8"
  part(c, c:poly({ { 40, 35 }, { 43, 28 }, { 49, 23 }, { 56, 23 }, { 61, 27 }, { 66, 30 }, { 62, 31 }, { 57, 29 }, { 51, 29 }, { 46, 32 }, { 44, 36 } }), pc)
  c:fill(c:line({ { 46, 31 }, { 51, 28 }, { 57, 28 } }, 1), "#f6c8d0")
  part(c, c:poly({ { 40, 35 }, { 36, 31 }, { 39, 33 }, { 41, 29 }, { 43, 33 } }), pc)
  c:fill(c:poly({ { 51, 23 }, { 53, 18 }, { 56, 23 } }), "#c8708a")
  c:px(61, 27, INK)
  fl(c, R(c, 36, 38, 41, 38), "#f8e0b0"); fl(c, R(c, 63, 38, 68, 38), "#f8e0b0")
  c:px(37, 36, "#f8e0b0"); c:px(41, 35, "#f8e0b0"); c:px(66, 35, "#f8e0b0"); c:px(68, 36, "#f8e0b0")
  -- landing steps
  part(c, R(c, 5, 38, 34, 41), "#9a8a86", { shade = true })
  part(c, R(c, 5, 42, 28, 45), "#8b8f96", { shade = true })
  part(c, R(c, 5, 46, 22, 49), "#7a7a84", { shade = true })
  part(c, R(c, 5, 34, 6, 38), "#3d2a1c", { noline = true }); part(c, R(c, 5, 31, 7, 33), "#ffd86a")
  gnome(c, 18, 38, { d = 1, sit = true, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 10, 13 }, true) } })
  finish(c, "r_sa_dolphin_tales")
end

-- pampas night: ranch hands, coals, one tale growing taller
function S.r_sa_ranch_tales()
  seed = 104
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#1f2748", "#2a3558", "#34426a", "#44507a" }, { dir = "v" })
  stars(c, { { 8, 8 }, { 20, 14 }, { 44, 6 }, { 46, 14 }, { 58, 7 }, { 64, 18 }, { 14, 24 }, { 50, 24 }, { 38, 20 } })
  c:fill(c:ellipse(32, 11, 5, 5), "#f4eee0"); c:fill(c:ellipse(34, 10, 4, 4), "#34426a")
  c:fill(c:ellipse(40, 36, 36, 6), "#2f3a58")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#3a5a3a"); c:fill(R(c, 0, 34, W - 1, 34), "#4a7048")
  -- fence and windmill
  for x = 6, 30, 8 do part(c, R(c, x, 26, x + 1, 36), "#5e3f28", { noline = true }) end
  fl(c, R(c, 5, 28, 32, 28), "#6b4a2e"); fl(c, R(c, 5, 31, 32, 31), "#6b4a2e")
  part(c, R(c, 59, 18, 60, 36), "#3d2a1c", { noline = true })
  c:fill(c:line({ { 55, 14 }, { 64, 22 } }, 1), "#6b6a78"); c:fill(c:line({ { 64, 14 }, { 55, 22 } }, 1), "#6b6a78")
  -- coals ring with a small fire and hanging pot
  for i = 0, 6 do part(c, c:ellipse(30 + i * 2 + (i % 2), 47 - (i % 3), 2, 1), "#8b8f96") end
  fl(c, R(c, 31, 45, 42, 46), "#6b3b2a")
  part(c, c:poly({ { 36, 36 }, { 40, 44 }, { 32, 44 } }), "#e0501f")
  c:fill(c:poly({ { 36, 40 }, { 38, 44 }, { 34, 44 } }), "#f08a24"); c:px(36, 43, "#ffd86a")
  c:px(33, 33, "#f08a24"); c:px(40, 31, "#ffd86a")
  c:fill(c:line({ { 28, 46 }, { 36, 33 }, { 44, 46 } }, 1), "#5e3f28")
  -- big gesturing gnome
  gnome(c, 16, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -10, 16 }, false), arm({ 4, 8 }, { 11, 12 }, true) } })
  -- laughing seated listener, wide-brim hat tipped
  part(c, R(c, 52, 43, 56, 47), "#8a5a35"); fl(c, R(c, 52, 43, 56, 43), "#c08a52")
  gnome(c, 57, 43, { d = -1, sit = true, hat = "#e8a317", eyes = "happy", arms = { arm({ -3, 7 }, { -4, 4 }, true) } })
  -- saddle on the ground
  part(c, R(c, 62, 45, 68, 47), "#8a4a1a"); fl(c, R(c, 63, 44, 66, 44), "#6b3b2a")
  finish(c, "r_sa_ranch_tales")
end

-- Salt flat: feet in the warm pool, telling of the white flat
function S.r_sa_salt_tales()
  seed = 105
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#8ec4e0", "#a8d4e8", "#c4e2ee", "#e0f0f4" }, { dir = "v" })
  c:fill(c:ellipse(18, 9, 9, 2), "#f4f8fa"); c:fill(c:ellipse(52, 14, 8, 2), "#f4f8fa")
  c:fill(c:ellipse(40, 28, 32, 3), "#a8b8d0")
  -- mirror flat: white salt with the sky reflected
  c:fill(R(c, 0, 29, W - 1, H - 1), "#f0f2f4")
  c:bands(R(c, 0, 29, W - 1, 38), { "#c8e0ec", "#d8e8f0", "#e4eef4" }, { dir = "v" })
  fl(c, R(c, 8, 33, 18, 33), "#f4f8fa"); fl(c, R(c, 44, 35, 56, 35), "#f4f8fa")
  for _, p in ipairs({ { 12, 44 }, { 30, 49 }, { 50, 47 }, { 64, 44 }, { 8, 49 } }) do c:px(p[1], p[2], "#d4dae0"); c:px(p[1] + 1, p[2] - 1, "#d4dae0") end
  -- salt mounds with rakes
  part(c, c:poly({ { 56, 40 }, { 62, 31 }, { 68, 40 } }), "#f6f6f6")
  part(c, c:poly({ { 6, 37 }, { 10, 31 }, { 14, 37 } }), "#f6f6f6")
  c:fill(c:line({ { 66, 28 }, { 68, 38 } }, 1), "#8a5a35"); fl(c, R(c, 64, 27, 68, 27), "#8a5a35")
  -- warm pool with steam
  part(c, c:ellipse(40, 46, 20, 5), "#e8e8e4", { shade = true })
  c:fill(c:ellipse(40, 46, 17, 3.5), "#58c4c0"); fl(c, R(c, 32, 45, 40, 45), "#98ece4"); fl(c, R(c, 44, 47, 52, 47), "#98ece4")
  for i = 0, 3 do fl(c, c:ellipse(46 + (i % 2) * 2, 40 - i * 3, 2, 1), "#f4f8fa") end
  -- teller on the pool edge, feet in the water
  gnome(c, 24, 41, { d = 1, sit = true, eyes = "open", arms = { arm({ -3, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 10, 14 }, true) } })
  -- listener with a yellow hat
  gnome(c, 56, 43, { d = -1, sit = true, hat = "#e8a317", eyes = "open", arms = { arm({ -3, 6 }, { -5, 3 }, true) } })
  finish(c, "r_sa_salt_tales")
end

-- Reaches: asleep in a woven hammock between two cashew trees
function S.r_sa_canopy_hammock()
  seed = 106
  local c = new()
  day(c, 38, { sky = { "#a8d8e4", "#bce2e4", "#d0ece4" }, cloud = 44, hill = "#4e8a3c", hill2 = "#3f7f45" })
  for _, x in ipairs({ 13, 59 }) do
    part(c, R(c, x - 2, 14, x + 1, 44), "#7a5a3a", { noline = true }); fl(c, R(c, x - 1, 16, x - 1, 42), "#5e3f28")
    c:fill(c:ellipse(x - 1, 12, 13, 8), "#3f8a42"); c:fill(c:ellipse(x - 5, 8, 6, 3), "#5aa04e")
  end
  -- cashew apples
  for _, p in ipairs({ { 7, 19, "#e0501f" }, { 21, 18, "#f0a030" }, { 53, 20, "#e8a317" }, { 66, 18, "#e0501f" }, { 14, 22, "#f0a030" } }) do
    part(c, c:ellipse(p[1], p[2], 2, 2), p[3], { noline = true }); fl(c, R(c, p[1], p[2] + 2, p[1] + 1, p[2] + 3), "#6b4a2e")
  end
  -- hammock
  part(c, c:line({ { 15, 25 }, { 24, 31 }, { 36, 33 }, { 48, 31 }, { 57, 25 } }, 3), "#e0c88a", { noline = true })
  for x = 20, 52, 3 do c:px(x, 31 + ((x == 36) and 3 or 0), "#a8703e") end
  fl(c, R(c, 14, 24, 16, 26), "#8a5a35"); fl(c, R(c, 56, 24, 58, 26), "#8a5a35")
  lying(c, 26, 28)
  part(c, c:line({ { 15, 25 }, { 24, 32 }, { 36, 35 }, { 48, 32 }, { 57, 25 } }, 2), "#d0b070", { noline = true })
  -- breeze lines and fallen fruit
  fl(c, R(c, 28, 21, 33, 21), "#f4f8fa"); fl(c, R(c, 42, 18, 47, 18), "#f4f8fa")
  for _, p in ipairs({ { 20, 46, "#e0501f" }, { 38, 47, "#f0a030" }, { 50, 45, "#e0501f" } }) do part(c, c:ellipse(p[1], p[2], 2, 1), p[3], { noline = true }) end
  c:px(30, 45, "#e08a7a"); note(c, 40, 26, "#f4f8fa")
  finish(c, "r_sa_canopy_hammock")
end

-- Downs, winter: bending cut stems flat to lay the hedge
function S.r_nwe_hedge_laying()
  seed = 107
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#b4c0c8", "#c4ced4", "#d4dcdc" }, { dir = "v" })
  c:fill(c:ellipse(18, 36, 34, 10), "#9aa888"); c:fill(c:ellipse(60, 36, 28, 8), "#8a9a78")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#a8b48a"); c:fill(R(c, 0, 36, W - 1, 36), "#c4ccaa")
  for _, p in ipairs({ { 8, 45 }, { 20, 49 }, { 52, 47 }, { 64, 44 }, { 40, 48 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#f4f8fa") end
  -- laid half (left): thick pleached stems slanting up, with stakes
  for i = 0, 7 do
    c:fill(c:line({ { 5 + i * 3, 41 - (i % 2) }, { 15 + i * 3, 27 + (i % 3) * 2 } }, 2), (i % 2 == 0) and "#7a5a38" or "#a07a4c")
  end
  for _, x in ipairs({ 9, 20, 31 }) do part(c, R(c, x, 25, x, 41), "#e8c48a", { noline = true }) end
  fl(c, R(c, 5, 41, 34, 42), "#5e3f28")
  -- uncut half (right): tall bare stems with haws
  for x = 50, 68, 2 do
    c:fill(c:line({ { x, 42 }, { x + (x % 3) - 1, 21 + (x % 4) } }, (x % 4 == 0) and 2 or 1), "#6b4a2e")
  end
  for _, p in ipairs({ { 54, 25 }, { 60, 23 }, { 65, 28 }, { 57, 32 } }) do c:px(p[1], p[2], "#c0442e") end
  fl(c, R(c, 49, 42, 68, 43), "#5e3f28")
  -- wren on a stake
  c:fill(R(c, 30, 22, 32, 23), "#a8703e"); c:px(33, 21, "#a8703e"); c:px(29, 20, "#a8703e"); c:px(29, 21, "#a8703e"); c:px(32, 24, "#e8c48a"); c:px(33, 22, INK)
  -- the gnome bends a cut stem down and holds the billhook
  local _, G = gnome(c, 42, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -9, 15 }, false), arm({ 4, 7 }, { 8, 5 }, true) } })
  c:fill(c:line({ { 50, 40 }, { 50, 28 }, { 44, 22 }, { 34, 21 }, { 31, 24 } }, 2), "#b8905a")
  c:px(50, 34, "#f4eee0"); c:px(51, 34, "#f4eee0")
  local hx, hy = G.P(8, 5)
  fl(c, R(c, hx + 1, hy - 4, hx + 3, hy - 1), "#aeb4bc"); c:px(hx + 4, hy - 4, "#aeb4bc"); c:px(hx + 3, hy - 5, "#aeb4bc")
  fl(c, R(c, hx, hy, hx + 1, hy + 4), "#8a5a35")
  c:px(34, 46, "#f4f8fa"); c:px(14, 45, "#f4f8fa")
  finish(c, "r_nwe_hedge_laying")
end

-- Moor: stepping a flat spade into the peat bank, turves leaning in stacks, a neighbour waves
function S.r_nwe_peat_cut()
  seed = 108
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#aab4c8", "#bcc4d4", "#cdd4dc" }, { dir = "v" })
  c:fill(c:ellipse(18, 12, 10, 2), "#e8ecf0"); c:fill(c:ellipse(50, 8, 12, 2), "#e8ecf0")
  c:fill(c:ellipse(16, 32, 30, 9), "#7a6a8a"); c:fill(c:ellipse(58, 31, 26, 8), "#8a6a7a")
  c:fill(R(c, 0, 32, W - 1, H - 1), "#7a6850"); c:fill(R(c, 0, 32, W - 1, 32), "#9a8a6a")
  for _, p in ipairs({ { 8, 36 }, { 16, 40 }, { 24, 35 }, { 60, 34 }, { 66, 38 } }) do c:px(p[1], p[2], "#a86a9a"); c:px(p[1] + 1, p[2] - 1, "#a86a9a") end
  -- neighbour far off, waving
  gnome(c, 14, 34, { s = 0.6, d = 1, hat = "#4f9a45", eyes = "open", arms = { arm({ 4, 7 }, { 8, 14 }, true) } })
  -- peat bank: dark layered face
  c:fill(c:poly({ { 40, 49 }, { 40, 36 }, { 46, 34 }, { 70, 34 }, { 70, 49 } }), "#4a3022")
  for _, y in ipairs({ 38, 42, 46 }) do fl(c, R(c, 41, y, 68, y), "#35201a") end
  c:fill(R(c, 40, 34, 70, 35), "#6a4a34")
  fl(c, R(c, 41, 36, 41, 48), "#6b4a34")
  -- turves drying in leaning stacks
  for _, x0 in ipairs({ 47, 58 }) do
    part(c, R(c, x0, 30, x0 + 8, 33), "#5e4030")
    part(c, R(c, x0 + 1, 27, x0 + 7, 29), "#4a3022")
    part(c, R(c, x0 + 2, 24, x0 + 6, 26), "#5e4030")
    fl(c, R(c, x0 + 4, 30, x0 + 4, 33), "#35201a")
  end
  -- gnome with a flat spade driven in
  c:fill(c:line({ { 31, 30 }, { 40, 41 } }, 1), "#a8703e")
  part(c, R(c, 39, 40, 43, 47), "#c4cad2")
  fl(c, R(c, 40, 41, 40, 46), "#e8ecf0")
  fl(c, R(c, 29, 29, 32, 30), "#8a5a35")
  gnome(c, 24, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 7, 11 }, true), arm({ -4, 7 }, { 5, 9 }, false) } })
  -- cut turves on the ground and flying crumbs
  part(c, R(c, 44, 46, 49, 48), "#4a3022"); c:px(52, 44, "#4a3022"); c:px(54, 46, "#4a3022")
  finish(c, "r_nwe_peat_cut")
end

local function seal(c, x, y, d, col)
  part(c, c:ellipse(x, y, 4, 2), col or "#8a8f96")
  part(c, c:ellipse(x + d * 4, y - 1, 2, 2), col or "#8a8f96")
  c:px(x + d * 5, y - 2, INK); c:px(x + d * 4, y - 1, INK)
  fl(c, R(c, x - d * 5, y, x - d * 4, y), col or "#8a8f96")
end

-- Fjord: counting seals (and rocks) on the skerry with a spyglass
function S.r_nwe_seal_skerry()
  seed = 109
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#b8c8d4", "#ccd8e0", "#dce6ea" }, { dir = "v" })
  c:fill(c:ellipse(52, 12, 9, 2), "#f4f8fa")
  -- fjord walls with snowy tops
  c:fill(c:poly({ { 0, 28 }, { 0, 14 }, { 12, 6 }, { 26, 24 }, { 30, 28 } }), "#5a6a82")
  c:fill(c:poly({ { 40, 28 }, { 52, 12 }, { 62, 20 }, { 72, 8 }, { 72, 28 } }), "#4e5e78")
  c:fill(c:poly({ { 12, 6 }, { 8, 12 }, { 14, 11 }, { 17, 12 } }), "#f4f8fa")
  c:fill(c:poly({ { 52, 12 }, { 48, 18 }, { 53, 16 }, { 56, 18 } }), "#f4f8fa")
  c:bands(R(c, 0, 28, W - 1, H - 1), { "#5a8aa8", "#4e7ea0", "#4272a0", "#386694" }, { dir = "v" })
  ripples(c, { { 8, 31, 6 }, { 38, 30, 5 }, { 56, 33, 7 }, { 30, 46, 6 }, { 60, 47, 6 }, { 44, 49, 5 } }, "#8cb8d0")
  -- the skerry: seals and look-alike rocks
  part(c, c:ellipse(46, 41, 20, 4), "#7a7e86", { shade = true })
  seal(c, 36, 37, 1); seal(c, 47, 36, -1); seal(c, 56, 37, 1, "#a8a8a0")
  part(c, c:ellipse(41, 38, 3, 2), "#8a8f96"); part(c, c:ellipse(52, 39, 3, 2), "#8a8f96")
  part(c, c:ellipse(61, 41, 2, 1), "#8a8f96")
  fl(c, R(c, 32, 42, 60, 42), "#d8e0e4"); fl(c, R(c, 28, 44, 36, 44), "#c8d8e0"); fl(c, R(c, 58, 44, 66, 44), "#c8d8e0")
  -- jetty
  part(c, R(c, 5, 40, 26, 43), "#a8703e")
  for _, x in ipairs({ 8, 14, 20 }) do fl(c, R(c, x, 40, x, 43), "#6b3b2a") end
  part(c, R(c, 8, 44, 9, 49), "#6b4a2e", { noline = true }); part(c, R(c, 22, 44, 23, 49), "#6b4a2e", { noline = true })
  -- gnome with a spyglass
  local _, G = gnome(c, 16, 40, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 7, 12 }, true), arm({ -4, 8 }, { 8, 11 }, false) } })
  local hx, hy = G.P(7, 12)
  c:fill(c:line({ { hx, hy }, { hx + 9, hy - 3 } }, 2), "#8a5a35")
  fl(c, R(c, hx + 8, hy - 5, hx + 11, hy - 2), "#d9a660"); c:px(hx + 4, hy - 1, "#f5cf6a")
  -- tally slate on the jetty
  part(c, R(c, 6, 36, 9, 39), "#4a4a52"); for x = 6, 9 do c:px(x, 37, "#f4eee0") end
  finish(c, "r_nwe_seal_skerry")
end

-- Summer bog: one amber cloudberry per plant, the picker choosing carefully
function S.r_nwe_cloudberry_bog()
  seed = 110
  local c = new()
  day(c, 30, { sky = { "#a8d4ec", "#bce0f0", "#d0ecf2" }, cloud = 40, hill = "#6a86a8", hill2 = "#7a96b0", grass = "#8a9a56", edge = "#a8b86a" })
  c:fill(c:ellipse(60, 31, 20, 3), "#7a96b0")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#8a9a56")
  -- bog pools and cotton grass
  c:fill(c:ellipse(18, 44, 12, 3), "#4a7a80"); c:fill(R(c, 10, 43, 16, 43), "#78aab0")
  c:fill(c:ellipse(58, 46, 10, 2), "#4a7a80")
  for _, p in ipairs({ { 8, 36 }, { 30, 34 }, { 64, 34 }, { 46, 36 } }) do
    fl(c, R(c, p[1], p[2], p[1], p[2] + 3), "#6a7a3a"); part(c, c:ellipse(p[1], p[2] - 1, 1, 1), "#f4f8fa", { noline = true })
  end
  local function berry(x, y, ripe)
    fl(c, R(c, x, y, x, y + 7), "#5a7a30")
    fl(c, R(c, x - 2, y + 3, x - 1, y + 4), "#4e8a3c"); fl(c, R(c, x + 1, y + 5, x + 2, y + 6), "#4e8a3c")
    part(c, c:ellipse(x, y - 1, 2, 2), ripe and "#f0a030" or "#d04a3a", { noline = true }); c:px(x - 1, y - 2, ripe and "#ffd070" or "#e8806a")
    fl(c, R(c, x - 2, y - 3, x + 2, y - 3), "#4e8a3c")
  end
  berry(8, 42, true); berry(26, 46, false); berry(48, 44, true); berry(62, 40, true)
  gnome(c, 38, 45, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -7, 4 }, false), arm({ 4, 7 }, { 10, 5 }, true) } })
  berry(50, 40, true)
  -- basket at his feet
  part(c, R(c, 18, 44, 26, 48), "#c8903e"); fl(c, R(c, 18, 45, 26, 45), "#8a5a35"); fl(c, R(c, 18, 47, 26, 47), "#8a5a35")
  for i = 0, 3 do part(c, c:ellipse(19 + i * 2, 43, 1, 1), (i % 2 == 0) and "#f0a030" or "#d04a3a", { noline = true }) end
  finish(c, "r_nwe_cloudberry_bog")
end

-- Tearoom: two friends turned away, one scone, jam in one spoon and cream in the other
function S.r_nwe_jam_or_cream()
  seed = 111
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#e0c89a")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 38), "#d0b484") end
  fl(c, R(c, 0, 30, W - 1, 31), "#8a5a35")
  c:fill(R(c, 0, 39, W - 1, H - 1), "#9a6a42"); for y = 43, 52, 5 do fl(c, R(c, 0, y, W - 1, y), "#7a4a2a") end
  -- window with a thatch-green view
  part(c, R(c, 8, 8, 22, 22), "#8a5a35")
  c:fill(R(c, 10, 10, 20, 20), "#a8d4e0"); c:fill(R(c, 10, 17, 20, 20), "#7ea85a")
  fl(c, R(c, 15, 10, 15, 20), "#8a5a35"); fl(c, R(c, 10, 15, 20, 15), "#8a5a35")
  fl(c, R(c, 8, 8, 10, 14), "#dd5a42"); fl(c, R(c, 20, 8, 22, 14), "#dd5a42")
  -- teapot shelf and bunting
  part(c, R(c, 46, 14, 64, 15), "#8a5a35")
  part(c, c:ellipse(52, 11, 3, 2), "#f4eee0"); fl(c, R(c, 50, 8, 54, 8), "#f4eee0"); part(c, R(c, 56, 9, 58, 13), "#f4eee0")
  -- the two friends behind the table, backs turned
  gnome(c, 40, 42, { d = -1, upper = true, hat = "#4f9a45", eyes = "shut", arms = { arm({ 4, 6 }, { -1, 9 }, true, true) } })
  gnome(c, 63, 42, { d = 1, upper = true, hat = "#e8a317", eyes = "shut", arms = { arm({ -4, 6 }, { 1, 9 }, true, true) } })
  -- table with checked cloth
  part(c, R(c, 31, 38, 68, 41), "#c08a52"); fl(c, R(c, 32, 38, 67, 38), "#d9a660")
  part(c, R(c, 33, 42, 67, 47), "#f4eee0")
  for x = 33, 66, 4 do for y = 42, 47, 4 do fl(c, R(c, x, y, x + 1, y + 1), "#dd3a2a") end end
  -- plate with one scone, jam pot, cream pot
  part(c, c:ellipse(50, 38, 5, 1), "#f4eee0")
  part(c, c:ellipse(50, 36, 3, 2), "#d9a660"); fl(c, R(c, 48, 36, 52, 36), "#f0c880")
  part(c, R(c, 38, 34, 43, 38), "#b82a2a"); fl(c, R(c, 38, 34, 43, 34), "#e0503a"); fl(c, R(c, 41, 31, 41, 34), "#8a5a35")
  part(c, R(c, 57, 34, 62, 38), "#f4eee0"); fl(c, R(c, 57, 34, 62, 34), "#fffaf0"); fl(c, R(c, 59, 31, 59, 34), "#8a5a35")
  -- the decider: a spoon of each held wide
  local _, G = gnome(c, 17, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -8, 16 }, false), arm({ 4, 8 }, { 9, 14 }, true) } })
  local ax, ay = G.P(-8, 16); local bx, by = G.P(9, 14)
  c:fill(c:line({ { ax, ay }, { ax - 1, ay - 5 } }, 1), "#8a5a35"); part(c, c:ellipse(ax - 1, ay - 6, 2, 2), "#d03a3a", { noline = true })
  c:fill(c:line({ { bx, by }, { bx + 1, by - 5 } }, 1), "#8a5a35"); part(c, c:ellipse(bx + 1, by - 6, 2, 2), "#fffaf0", { noline = true })
  finish(c, "r_nwe_jam_or_cream")
end

-- Dawn: first light through one gap in the ring onto a flat stone laid for breakfast
function S.r_nwe_stones_sunrise()
  seed = 112
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#5a6aa8", "#8a7ab8", "#c890b0", "#f0a8a0", "#f8c890", "#fce0a0" }, { dir = "v" })
  c:fill(c:ellipse(18, 35, 34, 8), "#4a6a5a"); c:fill(c:ellipse(58, 35, 30, 7), "#4a6a5a")
  c:fill(c:ellipse(36, 35, 8, 8):clip(R(c, 0, 0, W, 34)), "#fff0b8")
  c:fill(c:ellipse(36, 35, 5, 5):clip(R(c, 0, 0, W, 34)), "#ffffe0")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#4a7050"); c:fill(R(c, 0, 34, W - 1, 34), "#6a9060")
  -- beam of light on the ground
  c:fill(c:poly({ { 34, 34 }, { 38, 34 }, { 56, 49 }, { 18, 49 } }), "#a8c070")
  c:fill(c:poly({ { 35, 35 }, { 37, 35 }, { 46, 49 }, { 28, 49 } }), "#d8dc88")
  -- standing stones, a gap in the middle
  local st = { { 8, 12, 4 }, { 15, 9, 4 }, { 23, 11, 4 }, { 29, 7, 3 }, { 43, 8, 3 }, { 50, 11, 4 }, { 58, 9, 4 }, { 65, 12, 4 } }
  for _, s in ipairs(st) do
    local x, h, w = s[1], s[2], s[3]
    part(c, c:poly({ { x - w // 2, 36 }, { x - w // 2, 36 - h + 2 }, { x - w // 2 + 1, 36 - h }, { x + w // 2, 36 - h + 1 }, { x + w // 2 + 1, 36 } }), "#6a7088", { shade = true })
  end
  -- breakfast stone
  part(c, c:ellipse(36, 44, 12, 3), "#9a9ea6", { shade = true })
  fl(c, R(c, 27, 43, 45, 43), "#c4c8ce")
  part(c, c:ellipse(30, 42, 3, 2), "#d9a660"); fl(c, R(c, 28, 41, 32, 41), "#f0c880")
  part(c, R(c, 36, 39, 39, 42), "#8b929c"); fl(c, R(c, 40, 40, 40, 41), "#8b929c")
  part(c, c:ellipse(43, 42, 2, 2), "#f4eee0"); c:px(43, 42, "#f5cf6a")
  c:px(37, 36, "#f4f8fa"); c:px(38, 34, "#f4f8fa")
  gnome(c, 14, 42, { d = 1, sit = true, eyes = "open", arms = { arm({ 4, 7 }, { 9, 9 }, true) } })
  spark(c, 36, 28); spark(c, 24, 26); spark(c, 49, 27)
  finish(c, "r_nwe_stones_sunrise")
end

-- Downs: whistling the miller's geese home, mill and wheel behind
function S.r_nwe_geese_home()
  seed = 113
  local c = new()
  day(c, 32, { cloud = 46, hill = "#7ea85a", hill2 = "#6a9a4c", grass = "#8ab864", edge = "#a8d078" })
  -- mill on the hill
  part(c, R(c, 8, 20, 21, 32), "#e8dcc0"); part(c, c:poly({ { 6, 21 }, { 14, 12 }, { 23, 21 } }), "#c0442e")
  fl(c, R(c, 12, 26, 15, 32), "#6b4a2e"); fl(c, R(c, 17, 23, 19, 25), "#a8d4e0")
  c:fill(c:line({ { 22, 25 }, { 22, 33 } }, 1), "#8a5a35"); part(c, c:ellipse(23, 29, 4, 4), "#8a5a35", { shade = true }); c:fill(c:ellipse(23, 29, 2, 2), "#c08a52")
  -- the flock, heading for him
  goose(c, 12, 44, 1); goose(c, 22, 40, 1); goose(c, 30, 46, 1); goose(c, 40, 41, 1); goose(c, 47, 47, 1)
  -- gnome whistling, hand curled at the mouth
  gnome(c, 58, 47, { d = -1, eyes = "open", arms = { arm({ 4, 8 }, { -1, 12 }, true), arm({ -4, 7 }, { 4, 4 }, false) } })
  note(c, 48, 24); note(c, 43, 20, "#f4f8fa"); note(c, 51, 17, "#f5cf6a")
  c:px(60, 39, "#f4f8fa")
  finish(c, "r_nwe_geese_home")
end

local function bracken(c, x, y, h, col)
  for k = -3, 3 do
    c:fill(c:line({ { x, y }, { x + k * 2, y - h + math.abs(k) } }, 1), col)
  end
  c:fill(R(c, x - 6, y - 3, x + 6, y - 3), col)
end

-- Fog: slipping through fog-filled bracken with a lantern
function S.r_nwe_bracken_fog()
  seed = 114
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#c8d0d0", "#d4dad8", "#dde2de" }, { dir = "v" })
  c:fill(R(c, 0, 33, W - 1, H - 1), "#9aa48a")
  -- ghostly trees, pale far to dark near
  for _, t in ipairs({ { 10, "#b4bfba" }, { 28, "#b4bfba" }, { 52, "#a8b4ae" }, { 66, "#a8b4ae" } }) do
    c:fill(R(c, t[1] - 1, 12, t[1] + 1, 34), t[2]); c:fill(c:ellipse(t[1], 12, 7, 6), t[2])
  end
  c:fill(R(c, 40, 6, 43, 36), "#8a988e"); c:fill(c:ellipse(41, 9, 9, 6), "#8a988e")
  -- path winding away into the fog
  c:fill(c:poly({ { 28, 34 }, { 38, 34 }, { 52, 49 }, { 12, 49 } }), "#c4bc9c")
  -- fog band with dithered edges
  local function fog(y0, y1, col)
    c:fill(R(c, 5, y0 + 1, 68, y1 - 1), col)
    for x = 5, 68 do if x % 2 == 0 then c:px(x, y0, col) else c:px(x, y1, col) end end
  end
  fog(24, 36, "#e4e8e6")
  -- bracken fronds
  for _, b in ipairs({ { 12, 49, 12, "#7a6a2a" }, { 28, 46, 9, "#8a7a34" }, { 58, 48, 12, "#7a6a2a" }, { 66, 44, 9, "#8a7a34" }, { 46, 49, 8, "#6a7a3a" } }) do bracken(c, b[1], b[2], b[3], b[4]) end
  local _, G = gnome(c, 36, 44, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 9 }, true) } })
  local hx, hy = G.P(8, 9)
  part(c, R(c, hx, hy + 1, hx + 3, hy + 5), "#3d2a1c"); fl(c, R(c, hx + 1, hy + 2, hx + 2, hy + 4), "#ffd86a")
  fl(c, R(c, hx - 1, hy - 1, hx, hy + 1), "#f0c8a0")
  c:px(hx - 1, hy + 3, "#fff1c8"); c:px(hx + 4, hy + 3, "#fff1c8")
  -- fog drifting over his boots
  fog(43, 49, "#dde2de")
  for _, b in ipairs({ { 24, 49, 7, "#7a6a2a" }, { 50, 49, 7, "#8a7a34" } }) do bracken(c, b[1], b[2], b[3], b[4]) end
  finish(c, "r_nwe_bracken_fog")
end

-- The barrow: tiptoeing past a vast frosty toad, finger to lips
function S.r_nwe_frost_toad()
  seed = 115
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#a8bcd4", "#bccadc", "#d0dce6" }, { dir = "v" })
  c:fill(c:ellipse(14, 36, 26, 8), "#cdd9e4")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#e8eff4"); c:fill(R(c, 0, 46, W - 1, H - 1), "#dbe5ee")
  -- small shrine stone
  part(c, c:poly({ { 7, 38 }, { 8, 26 }, { 10, 22 }, { 12, 26 }, { 13, 38 } }), "#8b8f96"); fl(c, R(c, 8, 25, 12, 26), "#f4f8fa"); fl(c, R(c, 10, 30, 10, 36), "#6a6e76")
  -- barrow mound with the toad
  part(c, c:ellipse(52, 46, 24, 8), "#c8d4de")
  part(c, c:ellipse(53, 37, 17, 10), "#78a090", { shade = true })
  c:fill(c:ellipse(53, 33, 12, 5), "#9ac0b0")
  part(c, c:ellipse(45, 26, 4, 3), "#8ab0a4"); part(c, c:ellipse(60, 26, 4, 3), "#8ab0a4")
  fl(c, R(c, 43, 27, 47, 27), INK); fl(c, R(c, 58, 27, 62, 27), INK)
  fl(c, R(c, 38, 38, 67, 38), "#3a5a50"); fl(c, R(c, 37, 37, 38, 37), "#3a5a50"); fl(c, R(c, 67, 37, 68, 37), "#3a5a50")
  for _, p in ipairs({ { 47, 33 }, { 58, 32 }, { 52, 42 }, { 62, 41 }, { 44, 41 } }) do c:fill(c:ellipse(p[1], p[2], 1, 1), "#5a8070") end
  for _, p in ipairs({ { 46, 31 }, { 55, 28 }, { 62, 33 }, { 50, 31 }, { 41, 41 }, { 60, 43 } }) do c:px(p[1], p[2], "#f4fbff") end
  c:fill(R(c, 44, 22, 46, 22), "#f4fbff"); c:fill(R(c, 59, 22, 61, 22), "#f4fbff")
  -- frosty breath
  c:fill(c:ellipse(34, 36, 3, 2), "#e8f6fc"); c:fill(c:ellipse(30, 33, 3, 2), "#e8f6fc"); c:fill(c:ellipse(28, 29, 2, 2), "#cfe8f4")
  spark(c, 25, 26, "#f4fbff", "#cfe8f4"); spark(c, 33, 28, "#f4fbff", "#cfe8f4")
  -- the tiptoer
  gnome(c, 20, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 8 }, { 4, 11 }, true), arm({ -4, 7 }, { -6, 11 }, false) } })
  c:px(34, 13, "#fbfdfe"); c:px(20, 14, "#fbfdfe"); c:px(60, 12, "#fbfdfe"); c:px(8, 18, "#fbfdfe")
  finish(c, "r_nwe_frost_toad")
end

-- Smugglers' cave: racing the tide through the arch
function S.r_nwe_sea_cave_tide()
  seed = 116
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 12), { "#a8cce0", "#c0dce8" }, { dir = "v" })
  c:fill(R(c, 0, 12, W - 1, 38), "#7a6a60")
  c:fill(R(c, 0, 12, W - 1, 14), "#5e8a44")
  for _, y in ipairs({ 18, 24, 30 }) do fl(c, R(c, 0, y, W - 1, y), "#66584f") end
  for _, p in ipairs({ { 8, 21 }, { 20, 27 }, { 30, 17 }, { 62, 20 }, { 66, 28 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#8a7a6e") end
  -- the arch
  c:fill(c:ellipse(48, 33, 13, 17):clip(R(c, 0, 0, W, 40)), "#1a1420")
  c:fill(c:ellipse(48, 35, 9, 12):clip(R(c, 0, 0, W, 40)), "#2a2030")
  part(c, R(c, 52, 31, 55, 38), "#6b4a2e"); fl(c, R(c, 52, 33, 55, 33), "#3d2a1c")
  c:fill(c:ellipse(46, 30, 3, 3), "#f8c070"); c:fill(c:ellipse(46, 30, 1, 1), "#fff1c8")
  fl(c, R(c, 46, 27, 46, 28), "#3d2a1c")
  -- wet sand, tide coming in from the left
  c:fill(R(c, 0, 39, W - 1, H - 1), "#c8b48a"); c:fill(R(c, 0, 45, W - 1, H - 1), "#b49e76")
  c:fill(c:poly({ { 0, 54 }, { 0, 39 }, { 18, 40 }, { 24, 45 }, { 30, 54 } }), "#4a7aa0")
  c:fill(c:poly({ { 0, 54 }, { 0, 46 }, { 10, 47 }, { 14, 54 } }), "#3a6a94")
  for _, p in ipairs({ { 14, 41, 5 }, { 20, 45, 5 }, { 25, 50, 4 }, { 2, 43, 4 } }) do fl(c, R(c, p[1], p[2], p[1] + p[3], p[2]), "#f4f8fa") end
  for x = 5, 23, 2 do c:px(x, 39 + (x // 5), "#f4f8fa") end
  -- wave crest
  c:fill(c:ellipse(24, 43, 4, 2), "#a8d8e8"); fl(c, R(c, 21, 41, 26, 41), "#f4f8fa")
  gnome(c, 36, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 7 }, { -7, 11 }, false), arm({ 4, 7 }, { 7, 4 }, true) } })
  c:px(31, 48, "#f4f8fa"); c:px(30, 46, "#a8d8e8"); c:px(29, 49, "#a8d8e8")
  finish(c, "r_nwe_sea_cave_tide")
end

local function fish(c, x, y, col, d)
  part(c, c:ellipse(x, y, 4, 2), col)
  c:fill(c:poly({ { x - d * 4, y }, { x - d * 7, y - 2 }, { x - d * 7, y + 2 } }), col)
  c:px(x + d * 2, y - 1, INK); fl(c, R(c, x - 1, y + 1, x + 1, y + 1), "#f8e0a0")
end

-- Mill kitchen: rye batter dropping from a spoon onto the hot iron
function S.r_nwe_rye_pancakes()
  seed = 117
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#b89a6a")
  for x = 4, W - 1, 8 do fl(c, R(c, x, 0, x, 40), "#a8895a") end
  c:fill(R(c, 0, 41, W - 1, H - 1), "#7a5a3a"); for y = 44, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#5e4228") end
  part(c, R(c, 8, 8, 20, 20), "#8a5a35"); c:fill(R(c, 10, 10, 18, 18), "#a8d4e0"); fl(c, R(c, 14, 10, 14, 18), "#8a5a35"); fl(c, R(c, 10, 14, 18, 14), "#8a5a35")
  -- chimney and stove
  part(c, R(c, 48, 4, 53, 30), "#6b6a78", { shade = true })
  part(c, R(c, 26, 35, 62, 38), "#5a5a66")
  part(c, R(c, 27, 39, 61, 49), "#3a3a42")
  part(c, R(c, 40, 41, 52, 47), "#1a1420"); c:fill(R(c, 42, 44, 50, 47), "#e0501f"); c:fill(R(c, 44, 45, 48, 47), "#ffd86a")
  fl(c, R(c, 28, 40, 60, 40), "#5a5a66")
  -- scones on the iron, dark and round
  for _, x in ipairs({ 44, 51, 58 }) do part(c, c:ellipse(x, 34, 2, 2), "#6b4a2e"); fl(c, R(c, x - 1, 33, x, 33), "#8a6a44") end
  part(c, c:ellipse(37, 35, 2, 1), "#d8b878", { noline = true })
  for i = 0, 2 do fl(c, c:ellipse(52 + (i % 2) * 3, 28 - i * 3, 1, 1), "#f4f8fa") end
  -- rye sheaf in the corner
  part(c, R(c, 63, 40, 68, 49), "#d9bc84"); fl(c, R(c, 63, 44, 68, 44), "#8a5a35")
  for x = 63, 68, 2 do fl(c, R(c, x, 35, x, 39), "#c8a45e"); c:px(x, 34, "#e8c48a") end
  -- the spoon dripping batter
  local _, G = gnome(c, 16, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -6, 4 }, false), arm({ 4, 8 }, { 12, 14 }, true) } })
  local hx, hy = G.P(12, 14)
  c:fill(c:line({ { hx, hy }, { hx + 7, hy - 3 } }, 1), "#8a5a35")
  part(c, c:ellipse(hx + 9, hy - 3, 2, 1), "#d8b878")
  c:px(hx + 9, hy, "#d8b878"); c:px(hx + 9, hy + 2, "#d8b878")
  finish(c, "r_nwe_rye_pancakes")
end

-- Spring: sliced beets stain everything pink, even the cat
function S.r_nwe_dill_beets()
  seed = 118
  local c = new()
  day(c, 34, { cloud = 20, hill = "#6a9a4c", hill2 = "#5a8a40" })
  -- dill patch behind
  for _, x in ipairs({ 10, 16, 24, 62, 67 }) do
    fl(c, R(c, x, 22, x, 34), "#5e8a3a")
    part(c, c:ellipse(x, 21, 3, 2), "#c8d048", { noline = true }); c:px(x - 1, 20, "#e8e878"); c:px(x + 1, 22, "#e8e878")
    fl(c, R(c, x - 3, 28, x - 1, 28), "#5e8a3a"); fl(c, R(c, x + 1, 25, x + 3, 25), "#5e8a3a")
  end
  -- the cold spring with a crock sunk in it
  part(c, c:ellipse(54, 44, 15, 5), "#8b8f96", { shade = true })
  c:fill(c:ellipse(54, 44, 12, 3.5), "#7cc9c8"); fl(c, R(c, 46, 43, 51, 43), "#b8e8e0"); fl(c, R(c, 58, 45, 63, 45), "#b8e8e0")
  part(c, R(c, 49, 38, 58, 45), "#b8663a"); fl(c, R(c, 50, 38, 57, 38), "#8a4a2a")
  c:fill(c:ellipse(53.5, 38, 4, 1.5), "#c02a6a"); fl(c, R(c, 51, 40, 52, 44), "#d4824a")
  fl(c, R(c, 49, 45, 58, 45), "#7cc9c8")
  -- stump with beet slices
  part(c, R(c, 4, 40, 15, 49), "#8a5a35"); part(c, c:ellipse(9.5, 40, 6, 2), "#e8c48a")
  for _, p in ipairs({ { 7, 39 }, { 11, 38 }, { 9, 41 } }) do part(c, c:ellipse(p[1], p[2], 2, 1), "#c02a6a", { noline = true }); c:px(p[1], p[2], "#f0a8c8") end
  -- pink cat
  cat(c, 22, 47, "#e8a0b8")
  -- gnome with pink hands holding a slice up to the light
  local _, G = gnome(c, 36, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -6, 3 }, false), arm({ 4, 8 }, { 9, 13 }, true) } })
  local hx, hy = G.P(9, 13)
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#c02a6a")
  part(c, c:ellipse(hx + 1, hy - 4, 3, 3), "#c02a6a", { noline = true }); c:fill(c:ellipse(hx + 1, hy - 4, 1, 1), "#f0a8c8")
  local lx, ly = G.P(-6, 3); fl(c, R(c, lx - 1, ly - 1, lx + 1, ly + 1), "#c02a6a")
  c:px(30, 46, "#c02a6a"); c:px(44, 48, "#c02a6a")
  finish(c, "r_nwe_dill_beets")
end

-- Orchard: stirring lingonberry jam in a big copper pot, jars cooling
function S.r_nwe_lingonberry_jam()
  seed = 119
  local c = new()
  day(c, 33, { cloud = 20, hill = "#7ea85a", hill2 = "#6a9a4c" })
  for _, x in ipairs({ 10, 64 }) do
    part(c, R(c, x - 1, 22, x, 34), "#6b4a2e", { noline = true })
    part(c, c:ellipse(x, 17, 8, 7), "#4e8a3c", { shade = true })
    for _, d in ipairs({ { -3, 15 }, { 2, 19 }, { 3, 14 }, { -2, 20 } }) do c:px(x + d[1], d[2], "#d03a3a") end
  end
  -- jars on a plank table
  part(c, R(c, 3, 38, 19, 40), "#a8703e"); part(c, R(c, 4, 41, 5, 48), "#8a5a35", { noline = true }); part(c, R(c, 17, 41, 18, 48), "#8a5a35", { noline = true })
  for i = 0, 2 do
    part(c, R(c, 5 + i * 5, 31, 8 + i * 5, 37), "#b8e0e8"); fl(c, R(c, 5 + i * 5, 33, 8 + i * 5, 37), "#a01c34"); fl(c, R(c, 5 + i * 5, 30, 8 + i * 5, 30), "#f4eee0")
  end
  -- fire under a copper pot
  part(c, c:ellipse(34, 48, 15, 2), "#8b8f96", { noline = true })
  for _, p in ipairs({ { 24, 46 }, { 29, 44 }, { 38, 44 }, { 43, 46 } }) do part(c, c:poly({ { p[1], p[2] - 5 }, { p[1] + 3, p[2] }, { p[1] - 3, p[2] } }), "#e0501f"); c:px(p[1], p[2] - 1, "#ffd86a") end
  part(c, c:rrect(22, 33, 46, 46, 3), "#c8803a", { shade = true })
  part(c, c:ellipse(34, 33, 12, 3), "#a86a2a")
  c:fill(c:ellipse(34, 33, 10, 2), "#a01c34"); fl(c, R(c, 29, 33, 31, 33), "#e0503a"); c:px(38, 32, "#4a1a3a"); c:px(40, 33, "#4a1a3a"); c:px(33, 32, "#4a1a3a")
  fl(c, R(c, 24, 36, 25, 42), "#e8a860")
  part(c, R(c, 19, 34, 21, 36), "#8a5a35"); part(c, R(c, 47, 34, 49, 36), "#8a5a35")
  -- steam
  for i = 0, 3 do fl(c, c:ellipse(30 + (i % 2) * 4, 29 - i * 3, 1, 1), "#f4f8fa") end
  -- stirring spoon, then the gnome holding its top
  c:fill(c:line({ { 35, 36 }, { 47, 28 } }, 2), "#a8703e")
  gnome(c, 58, 47, { d = -1, eyes = "open", arms = { arm({ -4, 8 }, { -10, 15 }, true), arm({ 4, 7 }, { 6, 4 }, false) } })
  -- berries in a bowl
  part(c, R(c, 46, 45, 52, 48), "#8a5a35")
  for i = 0, 4 do c:px(46 + i + 1, 44, (i % 2 == 0) and "#d03a3a" or "#3a2a5a") end
  finish(c, "r_nwe_lingonberry_jam")
end

-- Moor: a golden trout out of the peat-smoke hut
function S.r_nwe_peat_trout()
  seed = 120
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#b4bccc", "#c8ced8", "#dce0e4" }, { dir = "v" })
  c:fill(c:ellipse(14, 31, 28, 8), "#7a6a8a"); c:fill(c:ellipse(60, 30, 24, 7), "#8a6a7a")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#7a6850"); c:fill(R(c, 0, 31, W - 1, 31), "#9a8a6a")
  -- smokehouse
  part(c, R(c, 6, 20, 40, 47), "#6b4a2e")
  for x = 10, 38, 6 do fl(c, R(c, x, 21, x, 46), "#5e3f28") end
  part(c, c:poly({ { 3, 21 }, { 14, 11 }, { 32, 11 }, { 43, 21 } }), "#4a3a30")
  part(c, R(c, 28, 4, 32, 12), "#6b6a78")
  part(c, R(c, 12, 27, 34, 46), "#1a1420")
  fl(c, R(c, 11, 26, 35, 26), "#8a5a35")
  c:fill(R(c, 14, 44, 32, 46), "#e0501f"); c:fill(R(c, 17, 45, 29, 46), "#ffd86a")
  for _, p in ipairs({ { 17, 31 }, { 23, 33 }, { 29, 31 } }) do
    fl(c, R(c, p[1], 28, p[1], p[2] - 2), "#8a5a35"); fish(c, p[1], p[2] + 3, "#d89a2a", 1)
  end
  -- smoke curling
  for i = 0, 3 do fl(c, c:ellipse(32 + (i % 2) * 3, 2 + i * 0, 1, 1), "#d4d8dc") end
  c:fill(c:ellipse(30, 6, 3, 2), "#cfd4da"); c:fill(c:ellipse(34, 2, 3, 2), "#dde2e6")
  c:fill(R(c, 18, 36, 20, 38), "#d4d8dc")
  -- peat stacks
  for _, x0 in ipairs({ 50, 59 }) do
    part(c, R(c, x0, 30, x0 + 6, 32), "#5e4030"); part(c, R(c, x0 + 1, 27, x0 + 5, 29), "#4a3022")
  end
  -- gnome shows off a smoked trout
  local _, G = gnome(c, 54, 47, { d = -1, eyes = "happy", arms = { arm({ -4, 8 }, { -8, 15 }, true), arm({ 4, 7 }, { 6, 4 }, false) } })
  local hx, hy = G.P(-8, 15)
  fish(c, hx - 4, hy - 4, "#e0a030", -1)
  c:fill(R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  finish(c, "r_nwe_peat_trout")
end

-- Jetty: broth of fjord mussels, a leek, and a bit of rain in the pot
function S.r_nwe_mussel_broth()
  seed = 121
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 22), { "#b4c4d0", "#c8d4dc", "#d8e2e6" }, { dir = "v" })
  c:fill(c:poly({ { 0, 28 }, { 0, 16 }, { 10, 8 }, { 24, 22 }, { 30, 28 } }), "#5a6a82")
  c:fill(c:poly({ { 44, 28 }, { 56, 12 }, { 72, 10 }, { 72, 28 } }), "#4e5e78")
  c:bands(R(c, 0, 28, W - 1, 40), { "#6a94b0", "#5e88a8", "#5280a0" }, { dir = "v" })
  ripples(c, { { 8, 31, 6 }, { 40, 30, 8 }, { 58, 34, 6 }, { 22, 36, 6 } }, "#98c0d4")
  -- rope of mussels hanging off the jetty post into the water
  part(c, R(c, 9, 24, 11, 39), "#6b4a2e", { noline = true })
  c:fill(c:line({ { 12, 26 }, { 14, 33 }, { 13, 39 } }, 1), "#d0b070")
  for _, y in ipairs({ 28, 31, 34, 37 }) do part(c, c:ellipse(14, y, 2, 1), "#2a3a5a", { noline = true }); c:px(13, y, "#5a6a8a") end
  -- deck
  c:fill(R(c, 0, 41, W - 1, H - 1), "#a8703e")
  for x = 3, W - 1, 6 do fl(c, R(c, x, 41, x, H - 1), "#7a4a2a") end
  fl(c, R(c, 0, 41, W - 1, 41), "#c8905a")
  -- pot on a little fire, steaming
  part(c, c:ellipse(34, 47, 11, 2), "#8b8f96", { noline = true })
  part(c, c:poly({ { 29, 47 }, { 31, 41 }, { 33, 47 } }), "#e0501f"); part(c, c:poly({ { 36, 47 }, { 38, 42 }, { 40, 47 } }), "#e0501f")
  part(c, c:rrect(24, 34, 44, 45, 3), "#2f3238", { shade = true })
  part(c, c:ellipse(34, 34, 10, 2), "#4a4e56")
  c:fill(c:ellipse(34, 34, 8, 1), "#d8a850")
  for _, p in ipairs({ { 30, 33 }, { 34, 34 }, { 38, 33 } }) do part(c, c:ellipse(p[1], p[2], 2, 1), "#2a3a5a", { noline = true }) end
  fl(c, R(c, 36, 32, 40, 32), "#6aa84a")
  for i = 0, 3 do fl(c, c:ellipse(31 + (i % 2) * 4, 29 - i * 3, 1, 1), "#f4f8fa") end
  -- a couple of rain drops falling into the pot
  for _, p in ipairs({ { 31, 18 }, { 37, 22 }, { 34, 26 } }) do c:px(p[1], p[2], "#d0e8f4"); c:px(p[1] - 1, p[2] - 1, "#d0e8f4") end
  -- bucket of mussels and the leek
  part(c, R(c, 8, 42, 16, 48), "#8a5a35"); fl(c, R(c, 8, 44, 16, 44), "#6b3b2a")
  for i = 0, 3 do part(c, c:ellipse(9 + i * 2, 41, 1, 1), "#2a3a5a", { noline = true }) end
  fl(c, R(c, 18, 47, 25, 48), "#f4eee0"); fl(c, R(c, 22, 47, 28, 48), "#6aa84a")
  -- cook with the ladle
  gnome(c, 56, 47, { d = -1, eyes = "open", arms = { arm({ -4, 8 }, { -9, 13 }, true), arm({ 4, 7 }, { 6, 4 }, false) } })
  c:fill(c:line({ { 47, 34 }, { 42, 35 } }, 1), "#8a5a35"); part(c, c:ellipse(41, 35, 2, 1), "#aeb4bc")
  finish(c, "r_nwe_mussel_broth")
end

-- Downs: fitting a loose stone into the gap, a sheep looks on through it
function S.r_nwe_drystone_gap()
  seed = 122
  local c = new()
  day(c, 27, { cloud = 20, hill = "#7ea85a", hill2 = "#6a9a4c", grass = "#7ea85a" })
  c:fill(c:ellipse(40, 30, 36, 6), "#8ab864")
  c:fill(R(c, 0, 33, W - 1, H - 1), "#7ea85a")
  sheep(c, 40, 33, -1); sheep(c, 58, 29, 1)
  -- the wall: courses of stones, a gap in the middle
  c:fill(R(c, 5, 32, 68, 41), "#5a5e66")
  local greys = { "#9a9ea6", "#8b8f96", "#aab0b6", "#7a8088" }
  local rows = { { 28, 31 }, { 32, 35 }, { 36, 39 }, { 40, 43 } }
  for ri, r in ipairs(rows) do
    local x = 5 + (ri % 2) * 3
    while x < 69 do
      local w = 4 + floor(rand() * 4)
      local skip = (ri <= 2 and x + w >= 31 and x <= 43) or (ri == 3 and x + w >= 33 and x <= 41 and rand() < 0.5)
      if not skip then fl(c, R(c, x, r[1], math.min(68, x + w - 2), r[2]), greys[floor(rand() * 4) + 1]) end
      x = x + w
    end
  end
  c:fill(R(c, 5, 44, 68, 44), "#5a5e66")
  fl(c, R(c, 30, 28, 44, 31), "#8ab864")
  -- rubble from the gap
  rocks(c, { { 34, 46, 3, 2 }, { 40, 47, 4, 2 }, { 46, 46, 3, 2 }, { 56, 47, 3, 2 } }, "#9a9ea6")
  local _, G = gnome(c, 22, 48, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -6, 4 }, false), arm({ 4, 8 }, { 8, 14 }, true) } })
  local hx, hy = G.P(8, 14)
  part(c, c:ellipse(hx + 2, hy - 3, 4, 3), "#aab0b6")
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  finish(c, "r_nwe_drystone_gap")
end

-- Autumn: raking a leaf dam out of the mill leat, water backed up on the lane
function S.r_nwe_mill_leat()
  seed = 123
  local c = new()
  day(c, 30, { sky = { "#c8d0d4", "#d8dcd8", "#e4e4d8" }, cloud = 22, hill = "#8a8a4a", hill2 = "#9a7a3a", grass = "#a89a56", edge = "#c8b070" })
  tree(c, 11, 33, 7, "#d07a2a", "#6b4a2e")
  -- mill building with wheel
  part(c, R(c, 52, 14, 68, 36), "#d8c8a0"); part(c, c:poly({ { 50, 15 }, { 60, 6 }, { 70, 15 } }), "#8a5a35")
  fl(c, R(c, 58, 24, 62, 30), "#6b4a2e"); fl(c, R(c, 55, 18, 57, 20), "#a8c0cc")
  part(c, c:ellipse(52, 31, 7, 7), "#8a5a35", { shade = true }); c:fill(c:ellipse(52, 31, 5, 5), "#6a94b0"); c:fill(c:ellipse(52, 31, 1, 1), "#c08a52")
  fl(c, R(c, 52, 24, 52, 38), "#6b3b2a"); fl(c, R(c, 45, 31, 59, 31), "#6b3b2a")
  -- channel, water backing up to the left and across the lane
  c:fill(R(c, 5, 36, 52, 41), "#5a8aa0")
  c:fill(R(c, 5, 38, 52, 38), "#7ab0c0")
  c:fill(c:poly({ { 5, 49 }, { 5, 36 }, { 30, 36 }, { 34, 49 } }), "#6a98a8")
  ripples(c, { { 8, 40, 6 }, { 16, 44, 7 }, { 22, 38, 5 }, { 10, 47, 6 } }, "#a8ccd8")
  fl(c, R(c, 42, 38, 46, 38), "#8ab4c4")
  -- the leaf dam
  part(c, c:ellipse(37, 38, 7, 4), "#c0442e", { shade = true })
  for _, p in ipairs({ { 33, 37, "#e8a317" }, { 36, 35, "#d07a2a" }, { 40, 37, "#e8a317" }, { 38, 40, "#8a5a2a" }, { 34, 40, "#d07a2a" } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), p[3]) end
  -- gnome with the rake
  c:fill(c:line({ { 30, 27 }, { 36, 37 } }, 1), "#a8703e")
  fl(c, R(c, 34, 38, 40, 38), "#8b929c")
  for x = 34, 40, 2 do fl(c, R(c, x, 39, x, 40), "#8b929c") end
  gnome(c, 26, 48, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 7, 11 }, true), arm({ -4, 7 }, { 4, 9 }, false) } })
  for _, p in ipairs({ { 14, 12 }, { 20, 20 }, { 42, 14 }, { 46, 24 }, { 30, 8 }, { 8, 28 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), (p[1] % 2 == 0) and "#d07a2a" or "#e8a317") end
  c:px(14, 46, "#d07a2a"); c:px(44, 45, "#c0442e"); c:px(48, 48, "#e8a317")
  finish(c, "r_nwe_mill_leat")
end

-- Tearoom roof: reed bundle up the ladder to the bald patch
function S.r_nwe_rethatch()
  seed = 124
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#b4c8d4", "#c8d8de", "#d8e4e4" }, { dir = "v" })
  c:fill(c:ellipse(60, 8, 8, 2), "#f4f8fa")
  c:fill(R(c, 0, 35, W - 1, H - 1), "#7ea85a"); c:fill(R(c, 0, 35, W - 1, 35), "#9cc070")
  -- walls, door, window
  part(c, R(c, 12, 28, 62, 49), "#ecdcb4")
  part(c, R(c, 48, 36, 54, 49), "#8a5a35"); c:px(52, 43, "#f5cf6a")
  part(c, R(c, 56, 33, 61, 39), "#a8d4e0"); fl(c, R(c, 58, 33, 58, 39), "#8a5a35"); fl(c, R(c, 56, 36, 61, 36), "#8a5a35")
  part(c, R(c, 55, 39, 62, 40), "#8a5a35")
  part(c, c:ellipse(58, 38, 2, 1), "#f4eee0", { noline = true })
  -- thatch roof with courses, and a bald patch showing the rafters
  part(c, c:poly({ { 6, 31 }, { 17, 10 }, { 57, 10 }, { 68, 31 } }), "#d8b858")
  for y = 14, 28, 3 do fl(c, R(c, 8 + (31 - y) * 0 + (y - 10) // 2, y, 66 - (y - 10) // 2, y), "#b8963e") end
  fl(c, R(c, 17, 10, 57, 11), "#c8a84a")
  c:fill(R(c, 36, 14, 52, 25), "#4a3322")
  for x = 38, 52, 4 do fl(c, R(c, x, 14, x, 25), "#8a5a35") end
  fl(c, R(c, 36, 18, 52, 18), "#8a5a35"); fl(c, R(c, 36, 22, 52, 22), "#8a5a35")
  for _, p in ipairs({ { 40, 28 }, { 46, 31 }, { 50, 29 } }) do c:px(p[1], p[2], "#6a94b0"); c:px(p[1], p[2] + 1, "#6a94b0") end
  -- reed bundles on the ground
  part(c, R(c, 62, 43, 67, 49), "#e0c060"); fl(c, R(c, 62, 46, 67, 46), "#8a5a35"); for x = 62, 67, 2 do c:px(x, 42, "#e8d070") end
  part(c, R(c, 4, 44, 9, 49), "#e0c060"); fl(c, R(c, 4, 47, 9, 47), "#8a5a35"); for x = 4, 9, 2 do c:px(x, 43, "#e8d070") end
  -- ladder
  part(c, R(c, 22, 14, 23, 49), "#a8703e", { noline = true }); part(c, R(c, 36, 14, 37, 49), "#a8703e", { noline = true })
  for y = 16, 48, 4 do fl(c, R(c, 22, y, 37, y), "#8a5a35") end
  local _, G = gnome(c, 29, 40, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 14 }, true), arm({ -4, 7 }, { -2, 13 }, false) } })
  local hx, hy = G.P(9, 14)
  part(c, R(c, hx - 1, hy - 5, hx + 4, hy + 1), "#e0c060"); fl(c, R(c, hx, hy - 2, hx + 3, hy - 2), "#8a5a35")
  fl(c, R(c, hx - 2, hy - 1, hx - 1, hy + 1), "#f0c8a0")
  local mx, my = G.P(-2, 13)
  part(c, R(c, mx - 4, my - 3, mx - 1, my - 1), "#8a5a35")
  finish(c, "r_nwe_rethatch")
end

local order = {}
for k, _ in pairs(S) do order[#order + 1] = k end
table.sort(order)
for _, s2 in ipairs(order) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
