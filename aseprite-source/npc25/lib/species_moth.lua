-- moth (flyer) tables from specs/moth.md. Opus: replace S.draw_figure only (body-plan helper: D.flyer).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "moth", feet_y = 71, outline = "#2b1c26", plan = "flyer", T = 8, W = 42}
S.ramps = {main = {"#d6e3a2", "#bcd694", "#98d69a", "#62a894"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#d6e3a2", "#bcd694", "#98d69a", "#62a894", "#5c78ac", "#435488", "#2f3a62", "#e2b65e", "#b27e4a", "#ece6bc"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, 0, 2, 2}, {-1, -1, 0, -1, 1, 1}, {-2, -2, 0, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {0, 0, 0, -1, 2, 2}, {-1, -1, 0, 0, 1, 1}}
local h = N.hex
S.c = {
  body = h"#bcd694",
  bshade = h"#98d69a",
  bhi = h"#d6e3a2",
  deep = h"#62a894",
  head = h"#ece6bc",
  hat = h"#e2b65e",
  hatshade = h"#b27e4a",
  wing = h"#d6e3a2",
  belly = h"#5c78ac",
  acc = h"#5c78ac",
  accs = h"#435488",
  eye = h"#5c78ac",
  q = h"#ece6bc",
  qshade = h"#e2b65e",
  qhi = h"#ece6bc",
  ink = h"#62a894", arm = h"#bcd694", fbase = h"#98d69a", fshade = h"#62a894"}
S.bw, S.top = 16, 9
S.quirk = {w = 4, h = 3, anchor = "hand", hex = "#ece6bc"}

-- Stage 3 (Opus): hand-placed pixel art for one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local b, hd = o.body, o.head
  local walk = frame >= 3
  local s = o.armL                      -- wing spread: 2 open, 1 down-stroke, 0 half, -1 closed
  local top = species.T + 1 + hd         -- first painted row (outline sits one above)
  local G, TAG, cur = {}, {}, "x"
  local floor, ceil, sqrt, rad, cos, sin = math.floor, math.ceil, math.sqrt, math.rad, math.cos, math.sin
  local function P(x, y, c)
    if c and x >= 1 and x <= 62 and y >= top and y <= 70 then G[y * 64 + x] = c; TAG[y * 64 + x] = cur end
  end
  local function get(x, y) return G[y * 64 + x] end
  local function tag(x, y) return TAG[y * 64 + x] end
  local function mx(x) return 63 - x end
  local function lit(nx, ny, r)
    local d = nx * 0.55 + ny * 0.83
    if d > 0.92 and r.deep then return r.deep end
    if d > 0.42 then return r.shade end
    if d < -0.55 then return r.hi end
    return r.base
  end
  local function paint(r, x, y, nx, ny)
    if type(r) == "function" then return r(x, y, nx, ny) end
    if type(r) == "table" then return lit(nx, ny, r) end
    return r
  end
  local function E(cx, cy, rx, ry, r)
    for y = floor(cy - ry - 1), ceil(cy + ry + 1) do
      for x = floor(cx - rx - 1), ceil(cx + rx + 1) do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        if nx * nx + ny * ny <= 1 then P(x, y, paint(r, x, y, nx, ny)) end
      end
    end
  end
  -- rotated ellipse from (x0,y0) along (dx,dy), length L, half width w
  local function limb(x0, y0, dx, dy, L, w, r)
    local n = sqrt(dx * dx + dy * dy); dx, dy = dx / n, dy / n
    local cx, cy, R = x0 + dx * L / 2, y0 + dy * L / 2, L / 2 + w
    for y = floor(cy - R), ceil(cy + R) do
      for x = floor(cx - R), ceil(cx + R) do
        local px, py = x - cx, y - cy
        local u, v = (px * dx + py * dy) / (L / 2), (-px * dy + py * dx) / w
        if u * u + v * v <= 1 then P(x, y, paint(r, x, y, u * dx - v * dy, u * dy + v * dx)) end
      end
    end
  end
  local function line(x0, y0, x1, y1, c)
    local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0), 1)
    for i = 0, n do P(floor(x0 + (x1 - x0) * i / n + 0.5), floor(y0 + (y1 - y0) * i / n + 0.5), c) end
  end
  local function stamp(x0, y0, rows, map)
    for j, row in ipairs(rows) do
      for i = 1, #row do
        local ch = row:sub(i, i)
        if ch ~= "." then P(x0 + i - 1, y0 + j - 1, map[ch]) end
      end
    end
  end
  -- paint pixels of part `back` that touch part `front` with colour c (inner separation line)
  local function sep(back, front, c)
    local list = {}
    for k, t in pairs(TAG) do
      if t == back then
        local x, y = k % 64, k // 64
        for _, d in ipairs({{1, 0}, {-1, 0}, {0, 1}, {0, -1}}) do
          if tag(x + d[1], y + d[2]) == front then list[#list + 1] = k; break end
        end
      end
    end
    for _, k in ipairs(list) do G[k] = c end
  end
  local function wingdir(sg, e) e = rad(e); return sg * cos(e), -sin(e) end
  -- moth: cream fuzzy face, straw hat, feather antennae, blue overalls, big pale-green wings, lantern shade (quirk)
  local WG = {hi = H"#d6e3a2", base = H"#bcd694", shade = H"#98d69a", deep = H"#62a894"}
  local HW = {hi = H"#bcd694", base = H"#98d69a", shade = H"#62a894", deep = H"#62a894"}
  local OV = {hi = H"#5c78ac", base = H"#435488", shade = H"#2f3a62", deep = H"#2f3a62"}
  local HAT, HATS = H"#e2b65e", H"#b27e4a"
  local CRM = H"#ece6bc"
  local FACE = {hi = CRM, base = CRM, shade = H"#d6e3a2", deep = H"#bcd694"}
  local EW = walk and ({[2] = 58, [1] = 26, [0] = -4, [-1] = -38})[s] or 30
  local sw = walk and (s >= 1 and -1 or (s < 0 and 1 or 0)) or 0
  local function mwing(sg, sx, sy, e, L, w, R, spot)
    local dx, dy = wingdir(sg, e)
    limb(sx, sy, dx, dy, L, w, function(x, y, nx, ny)
      local px, py = x - sx, y - sy
      local u, v = (px * dx + py * dy) / L, (-px * dy + py * dx) / w
      local d = nx * nx + ny * ny
      if d > 0.66 then return R.deep end
      if spot then
        local su, sv = (u - 0.64) * L, v * w
        local q = su * su + sv * sv
        if q <= 1.3 then return HATS end
        if q <= 4.2 then return HAT end
      end
      if u > 0.12 and (math.abs(v) < 0.09 or math.abs(v - u * 0.55) < 0.09 or math.abs(v + u * 0.55) < 0.09) then return R.shade end
      return lit(nx, ny, R)
    end)
  end
  local function antenna(x0, y0, sg)   -- 1 px stalk with a comb of 2 px feathers
    cur = "ant"
    local n = y0 - top
    for i = 0, n do
      local y = y0 - i
      local x = x0 + floor(sg * i * 0.6 + 0.5)
      local t = i / n
      local half = (t > 0.15 and t < 0.9) and 2 or 1
      if i >= 1 then for k = 1, half do P(x - k, y, HAT); P(x + k, y, (k == half) and HATS or HAT) end end
      P(x, y, HATS)
    end
  end
  local function eye(x, y)   -- big dark moth eye: ink pill in a teal ring
    stamp(x - 1, y - 1, {".rr.", "rppr", "rppr", "rppr", ".rr."}, {r = WG.deep, p = INK})
    P(x, y, CRM)
  end
  local function lantern(x, y)   -- hand point x,y: 1 px wire then a 4x3 shade
    cur = "lamp"
    P(x, y + 1, HATS); P(x, y + 2, HATS)
    stamp(x - 1, y + 3, {".cc.", "cccc", "rrrr"}, {c = CRM, r = HAT})
  end
  local function hat(cx, cy, back)   -- cy = brim row
    cur = "hat"
    E(cx, cy, 13.2, 2.6, function(x, y, nx, ny)
      if ny < -0.4 then return HAT end
      if ny > 0.3 or nx > 0.8 then return HATS end
      return HAT
    end)
    for y = cy - 6, cy - 1 do
      for x = floor(cx - 6.5), ceil(cx + 6.5) do
        local yy = y - (cy - 6)
        if not (yy == 0 and (x == floor(cx - 6.5) or x == ceil(cx + 6.5))) then
          local c = ((x + y) % 4 == 0) and HATS or HAT
          if x >= cx + 5 then c = HATS end
          if yy == 0 and x < cx + 3 and x > cx - 6 then c = CRM end
          if yy == 3 or yy == 4 then c = OV.base end
          if yy == 4 and x >= cx + 4 then c = OV.shade end
          P(x, y, c)
        end
      end
    end
  end
  local function leg(cx, lift, r)
    local bot = 70 + lift
    cur = "leg"
    for y = 62 + b, bot - 2 do P(cx, y, WG.shade); P(cx + 1, y, WG.deep) end
    E(cx + 0.5, bot - 0.5, 2.3, 1.6, r)
  end
  local function ruff(cx, cy, rx)   -- cream fluff collar with a scalloped hem
    cur = "ruff"
    E(cx, cy, rx, 3.4, function(x, y, nx, ny)
      if ny > 0.55 and (x % 3 == 0) then return nil end
      if ny > 0.3 or nx > 0.75 then return FACE.shade end
      return CRM
    end)
  end

  if view == "front" or view == "back" then
    local front = view == "front"
    local ftVL, ftVR = o.footR, o.footL
    if not front then ftVL, ftVR = o.footL, o.footR end
    if front then
      cur = "hwing"
      mwing(-1, 26, 49 + b, EW - 50, 11, 4.5, HW); mwing(1, 37, 49 + b, EW - 50, 11, 4.5, HW)
      cur = "wing"
      mwing(-1, 25, 43 + b, EW, 14, 5, WG, true); mwing(1, 38, 43 + b, EW, 14, 5, WG, true)
    end
    leg(26, ftVL, OV); leg(36, ftVR, OV)
    -- overalls body
    cur = "body"
    E(31.5, 54 + b, 9.6, 10.5, OV)
    if front then
      for y = 45, 52 do for x = 27, 36 do P(x, y + b, x >= 35 and OV.base or OV.hi) end end
      for x = 27, 36 do P(x, 53 + b, OV.shade) end
      for x = 28, 35 do if x % 3 ~= 1 then P(x, 46 + b, HAT) end end
      P(28, 45 + b, HAT); P(35, 45 + b, HAT)
      for y = 55, 64 do P(31, y + b, OV.shade) end
    else
      for y = 44, 63 do P(31, y + b, OV.shade); P(32, y + b, OV.shade) end
      for t = 0, 6 do P(25 + t, 44 + t + b, OV.hi); P(38 - t, 44 + t + b, OV.base) end
      for x = 27, 36 do P(x, 52 + b, OV.shade) end
    end
    -- arms (thin legs) and lantern
    cur = "arm"
    local aa = walk and sw or 0
    limb(23, 45 + b, -0.35, 1, 8, 1.6, WG); limb(40, 45 + b, 0.35, 1, 8, 1.6, WG)
    if front then lantern(20 + aa, 53 + b) end
    ruff(31.5, 42 + b, 10.5)
    -- head
    cur = "face"
    E(31.5, 30 + hd, 10.5, 8.2, FACE)
    if front then
      eye(26, 29 + hd); eye(37, 29 + hd)
      P(31, 33 + hd, HATS); P(32, 33 + hd, HATS); P(31, 32 + hd, HAT)
      P(30, 35 + hd, INK); P(31, 36 + hd, INK); P(32, 36 + hd, INK); P(33, 35 + hd, INK)
      P(23, 33 + hd, HAT); P(24, 33 + hd, HAT); P(39, 33 + hd, HAT); P(40, 33 + hd, HAT)
    else
      for y = 32, 37 do P(31, y + hd, FACE.shade) end
    end
    antenna(28, 17 + hd, -1); antenna(35, 17 + hd, 1)
    hat(31.5, 23 + hd, not front)
    if not front then
      cur = "hwing"
      mwing(-1, 28, 49 + b, EW - 48, 13, 5, HW); mwing(1, 35, 49 + b, EW - 48, 13, 5, HW)
      cur = "wing"
      mwing(-1, 29, 43 + b, EW, 16, 6.2, WG, true); mwing(1, 34, 43 + b, EW, 16, 6.2, WG, true)
      lantern(43 + (walk and sw or 0), 54 + b)
    end
    sep("wing", "body", WG.deep); sep("hwing", "body", WG.deep)
    sep("hwing", "wing", WG.deep)
    sep("face", "hat", HATS); sep("ruff", "face", FACE.deep)
    sep("body", "arm", OV.deep); sep("ruff", "arm", WG.deep)
    sep("body", "lamp", OV.deep); sep("wing", "lamp", WG.deep); sep("hwing", "lamp", WG.deep)
  else
    -- side, facing right
    local e = EW
    cur = "hwing"
    mwing(-1, 28, 49 + b, e - 52, 12, 4.6, HW)
    leg(29, o.footL, {hi = OV.shade, base = OV.shade, shade = OV.deep, deep = OV.deep})
    leg(34, o.footR, OV)
    cur = "body"
    E(31.5, 54 + b, 8.5, 10.5, OV)
    for y = 46, 53 do for x = 35, 39 do if tag(x, y + b) == "body" then P(x, y + b, OV.hi) end end end
    for y = 46, 53 do P(34, y + b, OV.shade) end
    P(36, 46 + b, HAT); P(38, 46 + b, HAT)
    ruff(32.5, 42 + b, 8.5)
    cur = "face"
    E(33.5, 30 + hd, 9.5, 8.2, FACE)
    E(40, 32 + hd, 4, 4.4, FACE)
    eye(39, 28 + hd)
    P(44, 33 + hd, HATS); P(43, 32 + hd, HAT); P(43, 33 + hd, HATS)
    P(41, 36 + hd, INK); P(42, 36 + hd, INK); P(43, 35 + hd, INK)
    P(37, 34 + hd, HAT); P(38, 34 + hd, HAT)
    antenna(36, 17 + hd, 1)
    hat(31.5, 23 + hd, false)
    -- near forewing raised, in front of the body
    cur = "wing"
    mwing(-1, 29, 43 + b, e, 15, 5.6, WG, true)
    -- near arm reaching forward with the lantern
    cur = "arm"
    limb(36, 45 + b, 1, 0.9, 8, 1.6, WG)
    lantern(42 + (walk and sw or 0), 51 + b)
    sep("wing", "body", WG.deep); sep("hwing", "body", WG.deep); sep("wing", "ruff", WG.deep)
    sep("face", "hat", HATS); sep("ruff", "face", FACE.deep)
    sep("body", "arm", OV.deep); sep("ruff", "arm", WG.deep)
    sep("body", "lamp", OV.deep)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
end
return S
