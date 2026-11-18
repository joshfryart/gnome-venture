-- tortoise tables from specs/tortoise.md. Opus: replace draw_figure only.
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "tortoise", feet_y = 71, outline = "#2b1c26"}
S.ramps = {
  skin = {"#78b04e", "#93a666", "#667a52", "#434d4a"},
  shell = {"#b28c4e", "#c07d3c", "#8a5236", "#57343c"},
  hat = {"#e4c26c", "#dcbc72"}, band = "#78b04e", sprig = "#6a9a48",
  overalls = {"#6188bc", "#465c92", "#323c66"}, strap = "#dcbc72",
  pot = {"#d6693e", "#8a5236", "#57343c"}, sprout = "#78b04e", petal = "#f5809f",
}
S.palette_list = {"#2b1c26", "#78b04e", "#93a666", "#667a52", "#434d4a", "#b28c4e", "#c07d3c", "#8a5236",
  "#57343c", "#e4c26c", "#dcbc72", "#6a9a48", "#6188bc", "#465c92", "#323c66", "#d6693e", "#f5809f", "#fff4d6"}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 1, -1}, {-1, -1, 0, -1, 0, 0}, {-1, -1, -1, 0, -1, 1},
          {0, 0, -2, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}, {-1, -1, -1, 0, 1, -1}}
local h = N.hex
S.c = {body = h"#c07d3c", bshade = h"#8a5236", bhi = h"#b28c4e", belly = h"#6188bc", arm = h"#93a666",
  head = h"#93a666", hat = h"#dcbc72", ink = h"#2b1c26", fbase = h"#93a666", fshade = h"#667a52",
  q = h"#d6693e", qhi = h"#78b04e"}
S.bw, S.top = 32, 11
S.quirk = {w = 4, h = 3, y = 33, x = {front = 44, back = 30, side = 28}}

-- Stage 3 (Opus): hand-placed pixel art. Light from upper left, shade lower right.
-- Frame 7 lifts the L foot (step note "L lifting") so it differs from frame 4.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local b, hd = o.body, o.head
  local fL, fR = o.footL, o.footR
  if frame == 7 then fL, fR = -1, 0 end
  local K = h(species.outline)
  local SK = {hi = h"#78b04e", base = h"#93a666", shade = h"#667a52", deep = h"#434d4a"}
  local SH = {hi = h"#b28c4e", base = h"#c07d3c", shade = h"#8a5236", deep = h"#57343c"}
  local HAT, HATHI, BAND, SPRIG = h"#dcbc72", h"#e4c26c", h"#78b04e", h"#6a9a48"
  local OV = {base = h"#6188bc", shade = h"#465c92", deep = h"#323c66"}
  local STRAP = h"#dcbc72"
  local POT, POTS, POTD = h"#d6693e", h"#8a5236", h"#57343c"
  local CREAM, PINK = h"#fff4d6", h"#f5809f"
  local function P(x, y, c) N.px(img, x, y, c) end
  local function R(x, y, w, hh, c) N.rect(img, x, y, w, hh, c) end
  local function E(x, y, w, hh, c) N.ellipse(img, x, y, w, hh, c) end
  local function rows(x0, y0, t, map)
    for j, row in ipairs(t) do
      for i = 1, #row do
        local c = map[row:sub(i, i)]
        if c then P(x0 + i - 1, y0 + j - 1, c) end
      end
    end
  end
  local sway = (frame == 5 or frame == 8) and 1 or 0
  -- flowerpot with sprout; (x,y) = top-left of the 6x5 pot (ink drawn in)
  local function pot(x, y)
    rows(x, y, {"KKKKKK", "KoohsK", ".KosK.", ".KdsK.", ".KKKK."},
      {K = K, o = POT, h = POT, s = POTS, d = POTS})
    P(x + 1, y + 1, h"#d6693e")
    P(x + 2, y - 1, SK.shade)
    P(x + 2 + sway, y - 2, SK.hi)
    P(x + 1 + sway, y - 2, SK.hi)
    P(x + 3 + sway, y - 3, SK.hi)
    P(x + 2 + sway, y - 3, SK.hi)
    P(x + 2 + sway, y - 4, PINK)
  end
  -- leg: column of skin from top y to sole row (70+lift); toes notched in ink
  local function leg(x, w, top, lift, ramp, dir)
    local sole = 70 + lift
    R(x, top, w, sole - top + 1, ramp.base)
    R(x + w - 2, top, 2, sole - top + 1, ramp.shade)
    P(x, top, ramp.hi); P(x, top + 1, ramp.hi)
    -- foot pad widens 1 px toward dir (0 = both)
    if dir >= 0 then P(x + w, sole, ramp.shade); P(x + w, sole - 1, ramp.shade) end
    if dir <= 0 then P(x - 1, sole, ramp.base); P(x - 1, sole - 1, ramp.base) end
    local cx = dir > 0 and x + 2 or (dir < 0 and x or x + 1)
    P(cx + 1, sole, K); P(cx + 3, sole, K)
  end

  if view == "front" then
    -- rear feet peeking behind (diagonal gait: rear-left lifts with front-right)
    leg(17, 4, 64, fR, {hi = SK.shade, base = SK.shade, shade = SK.deep}, -1)
    leg(43, 4, 64, fL, {hi = SK.shade, base = SK.shade, shade = SK.deep}, 1)
    -- shell behind body
    E(11, 30 + b, 42, 33, SH.deep)
    E(12, 30 + b, 40, 31, SH.shade)
    E(12, 30 + b, 38, 29, SH.hi)
    E(13, 31 + b, 37, 28, SH.base)
    -- scute seams on the visible sides
    for _, q in ipairs({{13, 40}, {14, 41}, {14, 49}, {13, 50}, {49, 40}, {48, 41}, {49, 49}, {50, 50}}) do
      P(q[1], q[2] + b, SH.shade)
    end
    -- front legs
    leg(22, 7, 58 + b, fL, SK, -1)
    leg(35, 7, 58 + b, fR, SK, 1)
    -- torso (skin chest) and overalls
    E(20, 32 + b, 24, 30, SK.base)
    R(37, 40 + b, 5, 18, SK.shade)
    R(21, 49 + b, 22, 11, OV.base)       -- trousers
    R(22, 41 + b, 20, 9, OV.base)        -- bib
    R(39, 41 + b, 3, 19, OV.shade)
    R(22, 59 + b, 21, 1, OV.deep)
    R(31, 52 + b, 1, 7, OV.shade)        -- leg seam
    R(27, 43 + b, 10, 1, OV.shade)       -- pocket top
    P(27, 44 + b, OV.shade); P(36, 44 + b, OV.shade)
    R(27, 47 + b, 10, 1, OV.shade)
    -- straps
    for y = 33, 40 do P(24, y + b, STRAP); P(25, y + b, STRAP); P(38, y + b, STRAP); P(39, y + b, HAT) end
    P(24, 41 + b, HATHI); P(39, 41 + b, HATHI)
    -- arms (swing shown as hand height)
    local function arm(x, ay, mirror)
      R(x, ay, 5, 11, SK.base)
      if mirror then R(x + 3, ay, 2, 11, SK.shade) else P(x, ay, SK.hi); P(x, ay + 1, SK.hi); P(x + 4, ay + 2, SK.shade) end
      R(x, ay + 11, 5, 3, mirror and SK.shade or SK.base)
      P(x + 1, ay + 13, K); P(x + 3, ay + 13, K)
      R(mirror and x - 1 or x + 5, ay + 1, 1, 9, K) -- inner edge against body
    end
    arm(15, 37 + b - o.armL, false)
    arm(44, 37 + b - o.armR, true)
    -- neck shadow
    R(27, 32 + hd, 10, 2, SK.shade)
    -- head
    E(21, 17 + hd, 22, 16, SK.shade)
    E(21, 17 + hd, 20, 15, SK.base)
    E(23, 19 + hd, 7, 4, SK.hi)
    R(22, 21 + hd, 20, 1, SK.deep)        -- brim shadow
    R(23, 22 + hd, 18, 1, SK.shade)
    -- eyes: cream with 2x3 ink pill and glint
    rows(25, 23 + hd, {"cKK", "cKc", "cKK"}, {c = CREAM, K = K})
    rows(36, 23 + hd, {"KKc", "cKc", "KKc"}, {c = CREAM, K = K})
    P(26, 23 + hd, CREAM); P(37, 23 + hd, CREAM)
    -- snout: nostrils
    P(30, 26 + hd, SK.deep); P(33, 26 + hd, SK.deep)
    -- cheeks
    R(23, 27 + hd, 2, 1, PINK); R(39, 27 + hd, 2, 1, PINK)
    -- smile
    R(28, 29 + hd, 8, 1, K); P(27, 28 + hd, K); P(36, 28 + hd, K)
    P(31, 30 + hd, SK.shade); P(32, 30 + hd, SK.shade)
    -- straw hat
    E(15, 15 + hd, 34, 7, HAT)
    R(17, 17 + hd, 30, 1, HATHI)
    R(19, 20 + hd, 26, 1, SH.hi)
    for x = 17, 46, 3 do P(x, 18 + hd, HATHI) end
    R(25, 11 + hd, 14, 6, HAT)
    R(26, 11 + hd, 6, 1, HATHI); R(25, 12 + hd, 2, 2, HATHI)
    R(25, 14 + hd, 14, 2, BAND)
    R(36, 14 + hd, 3, 2, SPRIG)
    -- leaf sprig on band
    rows(37, 11 + hd, {"..ll", ".lLl", "lL.."}, {l = SPRIG, L = BAND})
    -- flowerpot peeking above right shoulder
    pot(44, 30 + b)
    N.outline(img, K)
    -- round off crown corners
    P(25, 11 + hd, 0); P(38, 11 + hd, 0)
    P(25, 10 + hd, 0); P(38, 10 + hd, 0)
    P(25, 11 + hd, K); P(38, 11 + hd, K)

  elseif view == "back" then
    -- rear legs, feet pointing outward
    leg(19, 7, 58 + b, fL, SK, -1)
    leg(38, 7, 58 + b, fR, SK, 1)
    -- head back (mostly behind shell)
    E(22, 17 + hd, 20, 15, SK.shade)
    E(22, 17 + hd, 18, 14, SK.base)
    R(23, 21 + hd, 18, 1, SK.deep)
    -- arms peeking at the shell sides
    R(11, 41 + b - o.armL, 3, 9, SK.base)
    R(50, 41 + b - o.armR, 3, 9, SK.shade)
    -- shell dome
    E(12, 28 + b, 40, 36, SH.deep)
    E(12, 28 + b, 40, 33, SH.shade)
    E(12, 28 + b, 38, 32, SH.hi)
    E(13, 29 + b, 37, 31, SH.base)
    -- scutes: centre plate and 4 ring plates, seams in shade
    local cy = 44 + b
    rows(25, cy - 6, {
      "...SSSSSSSS...",
      "..S........S..",
      ".S..........S.",
      "S............S",
      "S............S",
      "S............S",
      "S............S",
      "S............S",
      ".S..........S.",
      "..S........S..",
      "...SSSSSSSS...",
    }, {S = SH.shade})
    -- radial seams from centre plate to rim
    for k = 0, 5 do P(25 - k, cy - 7 - k // 2, SH.shade); P(38 + k, cy - 7 - k // 2, SH.shade) end
    for k = 0, 6 do P(25 - k, cy + 5 + k // 2, SH.shade); P(38 + k, cy + 5 + k // 2, SH.shade) end
    R(26, cy - 5, 4, 1, SH.hi); R(26, cy - 4, 2, 2, SH.hi)
    -- rim band
    for x = 14, 49, 4 do P(x, 58 + b + (x < 20 and -2 or (x > 44 and -2 or 0)), SH.shade) end
    -- overall straps crossing over the shell
    for k = 0, 9 do
      P(25 + k, 30 + b + k, STRAP); P(26 + k, 30 + b + k, STRAP)
      P(38 - k, 30 + b + k, HAT); P(37 - k, 30 + b + k, HAT)
    end
    R(31, 34 + b, 2, 2, HATHI)
    -- straw hat from behind
    E(15, 15 + hd, 34, 7, HAT)
    R(17, 17 + hd, 30, 1, HATHI)
    for x = 18, 46, 3 do P(x, 19 + hd, HATHI) end
    R(25, 11 + hd, 14, 6, HAT)
    R(26, 11 + hd, 6, 1, HATHI); R(25, 12 + hd, 2, 2, HATHI)
    R(25, 14 + hd, 14, 2, BAND)
    rows(23, 11 + hd, {"ll..", "lLl.", "..Ll"}, {l = SPRIG, L = BAND})
    pot(34, 25 + b)
    N.outline(img, K)
    P(25, 10 + hd, 0); P(38, 10 + hd, 0)
    P(38, 11 + hd, K)

  else -- side, facing right
    local farS = {hi = SK.shade, base = SK.shade, shade = SK.deep}
    local function get(x, y) return img:getPixel(x, y) end
    local darker = {[SK.hi] = SK.base, [SK.base] = SK.shade, [SK.shade] = SK.deep,
      [OV.base] = OV.shade, [OV.shade] = OV.deep, [STRAP] = HAT}
    -- far leg (shade), opposite phase, peeks in front of the near leg
    leg(41 + o.armR, 5, 58 + b, fR, farS, 1)
    -- SHELL, seen edge-on: a thick "(" slab standing behind the spine. Its
    -- patterned top faces left (away); we see the carapace curve with seam
    -- notches, the marginal rim along the near side and the plastron at the bottom.
    local ocx, ocy, orx, ory = 32.5, 41 + b, 14.2, 18.5     -- outer curve
    local icx, icy, irx, iry = 38.5, 42 + b, 8.5, 15.5      -- inner curve (toward body)
    local function inO(x, y) local u, v = (x - ocx) / orx, (y - ocy) / ory; return u * u + v * v <= 1 end
    local function inI(x, y) local u, v = (x - icx) / irx, (y - icy) / iry; return u * u + v * v <= 1 end
    local function inshell(x, y) return inO(x, y) and not inI(x, y) end
    local shellpx = {}
    for y = 20 + b, 62 + b do
      -- outer edge and inner edge of this row
      local xo, xi
      for x = 10, 46 do if inshell(x, y) then xo = xo or x; xi = x end end
      if xo then
        for x = xo, xi do
          if inshell(x, y) then
            local v = (y - ocy) / ory
            local k, r = x - xo, xi - x                     -- from outer edge / from inner edge
            local c
            if not inO(x, y + 2) and v > 0.35 then
              c = inO(x, y + 1) and SH.deep or SH.deep       -- plastron edge underneath
              if not inO(x, y + 1) and v < 0.8 and r > 3 then c = SH.shade end
            elseif r <= 3 then                               -- marginal rim, lit lip
              c = v < 0.45 and SH.hi or (v < 0.62 and SH.base or SH.shade)
              if r == 0 then c = (v < -0.2) and SH.base or SH.shade end
            elseif r == 4 then
              c = SH.deep                                    -- groove above the rim
            else                                             -- carapace curve
              c = v < 0.3 and SH.base or (v < 0.6 and SH.shade or SH.deep)
              if k <= 1 and v < 0.15 and x - ocx < -3 then c = SH.hi end
              if k == 0 and v >= 0.15 then c = SH.shade end
            end
            P(x, y, c); shellpx[y * 64 + x] = true
          end
        end
      end
    end
    -- rim segments: short blocks along the curve, split by deep ticks
    for _, y in ipairs({27, 32, 37, 42, 47, 52}) do
      local yy = y + b
      local xi; for x = 10, 46 do if inshell(x, yy) then xi = x end end
      if xi then P(xi - 1, yy, SH.deep); P(xi - 2, yy, SH.deep); P(xi - 3, yy, SH.shade) end
    end
    -- foreshortened scutes bulge 1 px past the curve between the seams
    for _, a in ipairs({-139, -161, 177, 152}) do
      for da = -6, 6 do
        local ca, sa = math.cos(math.rad(a + da)), math.sin(math.rad(a + da))
        local x = math.floor(ocx + ca * (orx + 0.9) + 0.5)
        local y = math.floor(ocy + sa * (ory + 0.9) + 0.5)
        if not shellpx[y * 64 + x] then
          P(x, y, (a < -150 and SH.hi) or (a < 0 and SH.base) or (a > 170 and SH.base) or SH.shade)
          shellpx[y * 64 + x] = true
        end
      end
    end
    -- vertebral/costal seams: notches in the outer silhouette + short ticks
    for _, a in ipairs({-128, -150, -172, 166}) do
      local ca, sa = math.cos(math.rad(a)), math.sin(math.rad(a))
      local ex, ey = math.floor(ocx + ca * orx + 0.5), math.floor(ocy + sa * ory + 0.5)
      while not inO(ex, ey) do ex = ex - math.floor(ca * 1.5 + 0.5); ey = ey - math.floor(sa * 1.5 + 0.5) end
      P(ex, ey, 0)
      for t = 1, 2 do
        local tx, ty = ex - math.floor(ca * t + 0.5), ey - math.floor(sa * t + 0.5)
        if shellpx[ty * 64 + tx] then P(tx, ty, SH.deep) end
      end
    end
    -- torso: rounded chest and belly; the back half is hidden by the shell
    local spans = {{31, 34, 42}, {32, 32, 44}, {33, 31, 44}, {34, 30, 45}, {42, 30, 46}, {56, 30, 45}, {58, 31, 44}, {59, nil}}
    for k = 1, #spans - 1 do
      local s = spans[k]
      for y = s[1], spans[k + 1][1] - 1 do R(s[2], y + b, s[3] - s[2] + 1, 1, SK.base) end
    end
    R(43, 33 + b, 2, 9, SK.shade)
    -- overalls: sloped bib top (front higher), wraps the body down to the hem
    for x = 30, 46 do
      local top = x < 34 and 39 or (x < 38 and 37 or 35)
      for y = top, 58 do
        local c = get(x, y + b)
        if c == SK.base or c == SK.shade then P(x, y + b, OV.base) end
      end
    end
    R(45, 36 + b, 2, 20, OV.shade); R(38, 35 + b, 8, 1, OV.shade); R(44, 56 + b, 2, 2, OV.shade)
    R(31, 57 + b, 14, 1, OV.shade); R(31, 58 + b, 14, 1, OV.deep)
    R(33, 48 + b, 6, 1, OV.shade)                      -- waist seam
    -- neck: leans forward out of the collar, wrinkle ticks, jaw shadow
    for y = 23, 33 do
      local x1 = 46 - (y - 25) // 4
      R(34, y + hd, x1 - 33, 1, SK.base)
      P(x1, y + hd, SK.shade); P(x1 - 1, y + hd, SK.shade)
    end
    P(40, 29 + hd, SK.shade); P(41, 29 + hd, SK.shade); P(41, 31 + hd, SK.shade); P(42, 31 + hd, SK.shade)
    -- strap over the shoulder, emerging from under the shell rim, button at bib
    for k = 0, 5 do P(34 + k * 2 // 3, 30 + k + b, STRAP); P(35 + k * 2 // 3, 30 + k + b, HAT) end
    P(38, 35 + b, STRAP); P(39, 35 + b, HATHI); P(40, 35 + b, STRAP)
    -- cast shadow of the shell on the back of the torso / neck (2 px)
    for y = 24 + b, 59 + b do
      local x = 10
      while x < 46 and not (shellpx[y * 64 + x] and get(x, y) ~= 0 and not darker[get(x, y)]) do x = x + 1 end
      if x < 46 then
        while x < 46 and not darker[get(x, y)] and get(x, y) ~= 0 do x = x + 1 end
        for dx = 0, 1 do local c = get(x + dx, y); if darker[c] then P(x + dx, y, darker[c]) end end
      end
    end
    -- head
    E(35, 14 + hd, 19, 15, SK.shade)
    E(35, 14 + hd, 18, 14, SK.base)
    R(49, 22 + hd, 6, 5, SK.base)           -- snout
    R(49, 26 + hd, 6, 1, SK.shade)
    P(54, 22 + hd, 0); P(54, 26 + hd, 0)
    E(37, 15 + hd, 6, 4, SK.hi)
    R(37, 19 + hd, 16, 1, SK.deep)
    R(38, 20 + hd, 14, 1, SK.shade)
    R(40, 27 + hd, 9, 1, SK.shade)           -- jaw shadow onto neck
    rows(45, 21 + hd, {"cKK", "cKc", "cKK"}, {c = CREAM, K = K})
    P(46, 21 + hd, CREAM)
    P(53, 23 + hd, SK.deep)                  -- nostril
    R(49, 27 + hd, 4, 1, K); P(48, 26 + hd, K) -- mouth
    R(43, 25 + hd, 2, 1, PINK)
    -- near arm (swings with armL), in front of the shell lip
    local ax = 38 + o.armL
    R(ax, 37 + b, 5, 13, SK.base)
    R(ax + 3, 38 + b, 2, 12, SK.shade)
    R(ax + 1, 36 + b, 3, 1, SK.base)
    P(ax + 1, 37 + b, SK.hi); P(ax, 38 + b, SK.hi)
    R(ax, 50 + b, 6, 3, SK.base)
    R(ax + 4, 50 + b, 2, 2, SK.shade)
    P(ax + 2, 52 + b, K); P(ax + 4, 52 + b, K)
    R(ax - 1, 39 + b, 1, 13, K)
    -- near leg, steps out from under the hem
    leg(33 + o.armL, 7, 59 + b, fL, SK, 1)
    R(33 + o.armL, 59 + b, 7, 1, SK.shade)
    -- hat profile
    E(30, 15 + hd, 24, 6, HAT)
    R(32, 17 + hd, 21, 1, HATHI)
    for x = 33, 52, 3 do P(x, 18 + hd, HATHI) end
    R(34, 20 + hd, 18, 1, SH.hi)
    R(37, 11 + hd, 12, 6, HAT)
    R(38, 11 + hd, 5, 1, HATHI); R(37, 12 + hd, 2, 2, HATHI)
    R(37, 14 + hd, 12, 2, BAND)
    rows(34, 11 + hd, {"ll..", "lLl.", "..Ll"}, {l = SPRIG, L = BAND})
    pot(24, 20 + b)
    N.outline(img, K)
    P(48, 10 + hd, 0); P(48, 11 + hd, K)
  end
end
return S
