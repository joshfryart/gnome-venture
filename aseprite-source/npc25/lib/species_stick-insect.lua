-- stick-insect (six-legged) tables from specs/stick-insect.md. Opus: replace S.draw_figure only (body-plan helper: D.sixleg).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "stick-insect", feet_y = 71, outline = "#2b1c26", plan = "sixleg", T = 7, W = 34}
S.ramps = {main = {"#a88ae0", "#7f5cc4", "#5c4196", "#3f2c6a"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#a88ae0", "#7f5cc4", "#5c4196", "#3f2c6a", "#9a6e48", "#d9668a", "#a8496e", "#6e4a44", "#7cc35a", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 1, -1}, {-1, -1, -1, -1, 0, 0}, {-1, -1, -2, 0, -1, 1}, {0, 0, -1, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {-1, -1, 0, 0, 1, -1}}
local h = N.hex
S.c = {
  body = h"#7f5cc4",
  bshade = h"#5c4196",
  bhi = h"#a88ae0",
  deep = h"#3f2c6a",
  head = h"#7f5cc4",
  hat = h"#9a6e48",
  hatshade = h"#9a6e48",
  wing = h"#5c4196",
  belly = h"#9a6e48",
  acc = h"#9a6e48",
  accs = h"#9a6e48",
  eye = h"#9a6e48",
  q = h"#6e4a44",
  qshade = h"#7cc35a",
  qhi = h"#6e4a44",
  ink = h"#3f2c6a", arm = h"#7f5cc4", fbase = h"#5c4196", fshade = h"#3f2c6a"}
S.bw, S.top = 20, 8
S.quirk = {w = 5, h = 3, anchor = "crown", hex = "#6e4a44"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local b, hd = o.body, o.head
  local fL, fR, aL, aR = o.footL, o.footR, o.armL, o.armR
  local floor, abs = math.floor, math.abs
  local K = h(species.outline)
  local PU = {hi = h"#a88ae0", base = h"#7f5cc4", shade = h"#5c4196", deep = h"#3f2c6a"}
  local FACE, BARK = h"#9a6e48", h"#6e4a44"
  local PINK, PINKS, LEAF = h"#d9668a", h"#a8496e", h"#7cc35a"
  local SL, SD = h"#aaa9b8", h"#74758c"
  local wi = frame - 2
  local walking = frame >= 3
  -- body sway on x with the walk (whole upper body), twig sways the other way a beat later
  local SWAY = {[0] = 0, 0, 1, 1, 0, -1, -1}
  local sw = walking and SWAY[wi] or 0
  local tsw = walking and ({0, 0, 1, 1, 0, -1})[wi] * -1 or 0
  local G = {}
  local function P(x, y, c)
    x, y = floor(x), floor(y)
    if c and x >= 0 and x <= 63 and y >= 0 and y <= 79 then G[y * 64 + x] = c end
  end
  local function get(x, y) return G[floor(y) * 64 + floor(x)] end
  local function ell(cx, cy, rx, ry, fn)
    for y = floor(cy - ry - 1), floor(cy + ry + 1) do
      for x = floor(cx - rx - 1), floor(cx + rx + 1) do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        if nx * nx + ny * ny <= 1 then P(x, y, fn(x, y, nx, ny)) end
      end
    end
  end
  local function lit(nx, ny, r)
    local s = nx * 0.6 + ny * 0.8
    if s > 0.8 and r.deep then return r.deep end
    if s > 0.4 then return r.shade end
    if s < -0.5 then return r.hi end
    return r.base
  end
  local function line(x0, y0, x1, y1, c)
    local n = math.max(abs(x1 - x0), abs(y1 - y0), 1)
    for i = 0, n do P(floor(x0 + (x1 - x0) * i / n + 0.5), floor(y0 + (y1 - y0) * i / n + 0.5), c) end
  end
  local function rows(x0, y0, t, map)
    for j, row in ipairs(t) do
      for i = 1, #row do
        local c = map[row:sub(i, i)]
        if c then P(x0 + i - 1, y0 + j - 1, c) end
      end
    end
  end
  -- a spindly leg: hip -> high knee (lit femur) -> foot (shaded tibia), knee knob, bark tarsus
  local function leg(hx, hy, kx, ky, fx, lift, dir, far)
    local fy = 70 + lift
    local fem, tib = PU.base, PU.base
    if far then fem, tib = PU.shade, PU.shade end
    line(hx, hy, kx, ky, fem)
    line(kx, ky, fx, fy - 1, tib)
    P(kx, ky, far and PU.base or PU.hi)
    P(fx, fy, BARK); P(fx + dir, fy, BARK)
  end
  -- quirk: twig-hat: a 5 px twig with a knot and two 2x1 leaves
  local function twig(x, y)
    rows(x + tsw, y, {
      "LL..LL.",
      ".LTTL..",
      "TTTTTT.",
      ".T..T..",
    }, {T = BARK, L = LEAF})
  end
  local function ant(x0, y0, pts, c)
    local px, py = x0, y0
    for _, p in ipairs(pts) do line(px, py, x0 + p[1], y0 + p[2], c); px, py = x0 + p[1], y0 + p[2] end
  end

  -- ground shadow (rows 65-70; the outline lands on 71)
  ell(32, 67.5, 14.5, 3, function(x, y, nx, ny) return ny < -0.2 and SL or SD end)

  if view == "front" or view == "back" then
    local front = view == "front"
    local CX = 31.5 + sw
    local function M(x) return 63 - x + 2 * sw end    -- mirror about the swayed centre
    -- tripods (front view: viewer-left = creature right)
    -- A: L front, R middle, L rear -> footL ; B: R front, L middle, R rear -> footR
    local vl_mid, vr_mid, vl_rear, vr_rear = fL, fR, fR, fL
    if not front then vl_mid, vr_mid, vl_rear, vr_rear = fR, fL, fL, fR end
    local function pair(hy, ky, kxo, fxo, liftL, liftR)
      -- viewer-left leg, then mirrored viewer-right leg; a lifted foot tucks in and the knee rises
      local inl, inr = liftL < 0 and 2 or 0, liftR < 0 and 2 or 0
      leg(29 + sw, hy + b, kxo + sw, ky + b + liftL, fxo + inl, liftL, -1, false)
      leg(M(29), hy + b, M(kxo), ky + b + liftR, 63 - fxo - inr, liftR, 1, false)
    end
    pair(47, 40, 24, 22, vl_rear, vr_rear)    -- rear pair, inner stance
    pair(41, 32, 19, 17, vl_mid, vr_mid)      -- middle pair, wide knees above the body
    -- long body: thorax then ringed abdomen tapering to a tip
    for y = 28, 62 do
      local w = y < 44 and 6 or (y < 52 and 5 or (y < 58 and 4 or (y < 61 and 3 or 2)))
      local yy = y + b
      local x0 = floor(CX - w / 2 + 0.5)
      for x = x0, x0 + w - 1 do
        local c = PU.base
        if x == x0 then c = PU.hi elseif x == x0 + w - 1 then c = PU.deep elseif x == x0 + w - 2 and w > 3 then c = PU.shade end
        if front and x == x0 + 1 and w > 4 and y < 44 then c = PU.hi end
        P(x, yy, c)
      end
      if y >= 44 and (y - 44) % 4 == 3 then for x = x0 + 1, x0 + w - 1 do P(x, yy, PU.deep) end end
    end
    if not front then  -- wing-case seam and tiny folded wings
      for y = 30, 46 do P(floor(CX), y + b, PU.deep) end
      for y = 32, 37 do P(floor(CX) - 2, y + b, PU.hi) end
    end
    -- forelegs held like arms: shoulder -> elbow out -> hands folded at the middle
    local function arm(side, a)
      local sx = side < 0 and floor(CX) - 3 or floor(CX) + 3
      local ex = side < 0 and floor(CX) - 8 or floor(CX) + 8
      local hx = side < 0 and floor(CX) - 1 or floor(CX) + 1
      local hy = 45 + b - 2 * a
      line(sx, 31 + b, ex, 38 + b - a, PU.base)
      line(ex, 38 + b - a, hx, hy, PU.shade)
      P(ex, 38 + b - a, PU.hi)
      P(hx, hy, BARK); P(hx, hy + 1, BARK)
    end
    if front then arm(-1, aR); arm(1, aL) else arm(-1, aL); arm(1, aR) end
    -- bow at the collar (front) or between the shoulders (back)
    rows(floor(CX) - 3, 28 + b, {
      "dD.Dd",
      "dDkDd",
      "d...d",
    }, {d = PINKS, D = PINK, k = PINKS})
    -- head: small purple capsule, face
    local hcx, hcy = CX, 19 + hd
    -- antennae: long, curling outward, tips at y 8
    ant(floor(CX) - 2, 14 + hd, {{-1, -2}, {-2, -4}, {-3, -6}, {-5, -6}, {-6, -5}}, BARK)
    ant(floor(CX) + 3, 14 + hd, {{1, -2}, {2, -4}, {3, -6}, {5, -6}, {6, -5}}, BARK)
    ell(hcx, hcy, 6.2, 7.2, function(x, y, nx, ny) return lit(nx, ny, PU) end)
    -- neck
    P(floor(CX) - 1, 26 + hd, PU.base); P(floor(CX), 26 + hd, PU.shade); P(floor(CX) - 1, 27 + hd, PU.base); P(floor(CX), 27 + hd, PU.shade)
    if front then
      ell(hcx, hcy + 1.5, 4.4, 5, function(x, y, nx, ny)
        if nx * 0.6 + ny * 0.8 > 0.78 then return BARK end
        return FACE
      end)
      local ex = floor(CX)
      -- eyes: 2x3 ink pills with a lilac glint
      for _, e in ipairs({ex - 3, ex + 2}) do
        P(e, 19 + hd, PU.hi); P(e + 1, 19 + hd, K)
        P(e, 20 + hd, K); P(e + 1, 20 + hd, K)
        P(e, 21 + hd, K); P(e + 1, 21 + hd, K)
      end
      -- button nose, smile, cheeks
      P(ex, 22 + hd, BARK); P(ex + 1, 22 + hd, BARK)
      P(ex - 1, 24 + hd, K); P(ex, 25 + hd, K); P(ex + 1, 25 + hd, K); P(ex + 2, 24 + hd, K)
      P(ex - 3, 23 + hd, PINK); P(ex + 4, 23 + hd, PINK)
      -- hood rim (brow line)
      for x = ex - 3, ex + 4 do if get(x, 15 + hd) == FACE then P(x, 15 + hd, PU.deep) end end
    else
      for y = 14, 25 do P(floor(CX), y + hd, PU.shade) end
      P(floor(CX) - 2, 15 + hd, PU.hi); P(floor(CX) - 3, 16 + hd, PU.hi)
    end
    twig(floor(CX) - 3, 9 + hd)

  else -- side, facing right
    -- stride: tripod A swings forward on frames 4-6, tripod B on 7-8-3
    local SA = {-3, -1, 1, 3, 1, -1}
    local sa = walking and SA[wi] or 0
    local sb = -sa
    local lean = 0
    -- body axis: neck (36,27) down to the abdomen tip (27,62)
    local function bx(y) return 36 - (y - 27) * 0.26 + sw * 0 end
    -- far legs (deep): middle = tripod B (footR), rear = tripod A (footL)
    leg(floor(bx(41)), 41 + b, floor(bx(41)) + 5 + floor(sb / 2), 35 + b + fR, 39 + sb, fR, 1, true)
    leg(floor(bx(47)), 47 + b, floor(bx(47)) - 6 + floor(sa / 2), 41 + b + fL, 23 + sa, fL, -1, true)
    -- far foreleg (arm) reaching forward
    local function arm(a, far)
      local sx = floor(bx(31))
      local ex, ey = sx + 4, 38 + b
      local hx, hy = sx + 8 + a, 33 + b - a
      line(sx, 31 + b, ex, ey, far and PU.shade or PU.base)
      line(ex, ey, hx, hy, far and PU.deep or PU.shade)
      P(ex, ey, far and PU.base or PU.hi)
      P(hx + 1, hy, BARK)
    end
    arm(aL, true)
    -- body
    for y = 27, 62 do
      local w = y < 44 and 4 or (y < 54 and 3 or 2)
      local x0 = floor(bx(y) - w / 2 + 0.5)
      local yy = y + b
      for x = x0, x0 + w - 1 do
        local c = PU.base
        if x == x0 then c = PU.hi elseif x == x0 + w - 1 then c = (w > 2) and PU.shade or PU.deep end
        P(x, yy, c)
      end
      if y >= 44 and (y - 44) % 4 == 3 then P(x0 + w - 1, yy, PU.deep); if w > 2 then P(x0 + 1, yy, PU.shade) end end
    end
    -- near legs: middle = tripod A (footL), rear = tripod B (footR)
    leg(floor(bx(41)) + 1, 41 + b, floor(bx(41)) + 6 + floor(sa / 2), 35 + b + fL, 40 + sa, fL, 1, false)
    leg(floor(bx(47)), 47 + b, floor(bx(47)) - 7 + floor(sb / 2), 42 + b + fR, 24 + sb, fR, -1, false)
    -- bow at the collar
    rows(floor(bx(28)) - 1, 27 + b, {"dDd", "dkD", "d.d"}, {d = PINKS, D = PINK, k = PINKS})
    -- near foreleg (arm)
    arm(aR, false)
    -- head: capsule, face on the right
    local hcx, hcy = 39.5, 19 + hd
    ant(40, 14 + hd, {{1, -2}, {3, -4}, {5, -6}, {7, -6}, {9, -5}}, BARK)
    ell(hcx, hcy, 5.8, 6.8, function(x, y, nx, ny) return lit(nx, ny, PU) end)
    ell(hcx + 2.2, hcy + 1.5, 3.8, 4.8, function(x, y, nx, ny)
      if ny > 0.7 then return BARK end
      return FACE
    end)
    for x = 39, 44 do if get(x, 15 + hd) == FACE then P(x, 15 + hd, PU.deep) end end
    P(42, 19 + hd, PU.hi); P(43, 19 + hd, K); P(42, 20 + hd, K); P(43, 20 + hd, K); P(42, 21 + hd, K); P(43, 21 + hd, K)
    P(46, 21 + hd, FACE); P(46, 22 + hd, BARK)      -- button nose
    P(43, 24 + hd, K); P(44, 24 + hd, K); P(45, 23 + hd, K)
    P(40, 22 + hd, PINK)
    P(37, 26 + hd, PU.shade); P(38, 26 + hd, PU.base)
    twig(34, 9 + hd)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, K)
end
return S
