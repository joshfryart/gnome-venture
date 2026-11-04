-- asparagus (ph, Opus single pass, aR3_0). A slim three-spear bunch fanning up from a flat-cut base: the middle
-- spear stands behind, the outer two lean out. Each spear is a per-pixel lit cylinder (6-tone green, cool shade),
-- pale woody base streaking into green, triangular bract scales at the nodes (dark V + lit lip, one proud pixel),
-- and a tight purple-tipped bud of overlapping scales. Waxy specular streak on the left spear, AO where spears
-- overlap and under the tie. Twisted jute twine band (diagonal twist, lit top row) with a loose end.
-- quirk: an inchworm has arched itself over the right spear, mid-step.
local NAME = "asparagus"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local GREEN = { "#1d4632", "#2b6638", "#41873f", "#5fa544", "#8ac458", "#bfe386" }
local PALE  = { "#56633a", "#7b8750", "#a4a96a", "#c7c788", "#e1dda8", "#f6f0cc" }
local BUD   = { "#2a1f47", "#463069", "#65478a", "#8666a6", "#a98bc1", "#d4bfe2" }
local TW    = { "#4a2c22", "#7a4c30", "#a8743e", "#cf9d58", "#ecc888" }
local SPEC  = "#f4ffd8"
local CUTS  = { 0.2, 0.37, 0.53, 0.69, 0.86 }
local BOT   = 56

local function hw(t)
  if t < 0.78 then return 1.75 end
  local u = (t - 0.78) / 0.22
  if u < 0.4 then return 1.75 + 0.6 * sin(pi * 0.5 * u / 0.4) end
  return 0.3 + 2.05 * ((1 - u) / 0.6) ^ 0.7
end
local defs = {
  { name = "back",  p = { { 32, BOT + 3 }, { 32, 40 }, { 33, 22 }, { 34, 7 } } },
  { name = "left",  p = { { 29, BOT + 3 }, { 28, 40 }, { 24, 22 }, { 18, 11 } } },
  { name = "right", p = { { 36, BOT + 3 }, { 37, 40 }, { 41, 24 }, { 47, 12 } } },
}
local flat = c:rect(0, 0, 63, BOT)
for _, d in ipairs(defs) do
  d.m, d.n, d.T, d.S, d.samp = G.tube(d.p, hw)
  d.m:clip(flat)
  d.len = 0
  for i = 2, #d.samp do d.len = d.len + sqrt((d.samp[i].x - d.samp[i-1].x)^2 + (d.samp[i].y - d.samp[i-1].y)^2) end
  d.tok = { r = { name = "spear-" .. d.name } }
end
-- bract nubs: one proud pixel at each node (outline follows them)
local nodes = { { 0.3, -1 }, { 0.44, 1 }, { 0.57, -1 }, { 0.68, 1 } }
for _, d in ipairs(defs) do
  for _, nd in ipairs(nodes) do
    local s = d.samp[floor(nd[1] * 160) + 1]
    local x, y = floor(s.x + s.px * (s.w + 1) * nd[2] + .5), floor(s.y + s.py * (s.w + 1) * nd[2] + .5)
    if not d.m:has(x, y) then d.m:set(x, y) local k = K(x, y)
      d.n[k] = { s.px * nd[2] * 0.8, s.py * nd[2] * 0.8, 0.6 } d.T[k] = nd[1] d.S[k] = nd[2] * 0.97 d.nub = d.nub or {} d.nub[k] = true end
  end
end
-- twine band region (shared by all spears)
local TY0, TY1 = 43, 46
local all = HP.mask() for _, d in ipairs(defs) do all:add(d.m) end
local band = HP.mask()
all:grow(1):each(function(x, y) if y >= TY0 and y <= TY1 then band:set(x, y) end end)

local front = { [1] = { 2, 3 }, [2] = { 3 }, [3] = {} }
for i, d in ipairs(defs) do
  local vis = d.m:copy()
  local bias = {}
  for _, j in ipairs(front[i]) do vis:cut(defs[j].m) X.ao(bias, d.m, defs[j].m, 1, -1) end
  X.ao(bias, d.m, band, 1, -1)
  local v = X.light(d.n, { amb = 0.07, wrap = 0.25 })
  local idx = {}
  vis:each(function(x, y) local k = K(x, y)
    local val, ii = v[k] or 0, 1
    for j, t in ipairs(CUTS) do if val >= t then ii = j + 1 end end
    ii = max(1, min(6, ii + (bias[k] or 0)))
    idx[k] = ii
    local t, s = d.T[k], d.S[k]
    local ramp = GREEN
    -- pale woody base streaking up into the green (fibre streaks run along the spear)
    local streak = X.hash(floor(s * 3 + 3), i, 7)
    if (BOT - y) < 4 + streak * 9 then ramp = PALE end
    -- bud: purple scale edges, green hearts
    if t > 0.8 then
      local u = (t - 0.8) / 0.2
      local row = (t * d.len - abs(s) * 1.6) / 2.3
      local f = row - floor(row)
      if abs(s) > 0.45 - u * 0.3 or f < 0.32 then ramp = BUD end
      if f < 0.18 then ii = max(1, ii - 2) end
    end
    c:put(x, y, ramp[ii], d.tok)
  end)
  -- bracts at the nodes: dark V scale + lit lip above, tinted purple at the tips
  for _, nd in ipairs(nodes) do
    vis:each(function(x, y) local k = K(x, y)
      local t, s = d.T[k], d.S[k]
      local dd = (t - nd[1]) * d.len + abs(s - nd[2] * 0.55) * 1.4
      if (s * nd[2]) > -0.1 then
        if dd > -0.5 and dd < 0.6 then c:put(x, y, (s * nd[2] > 0.75) and BUD[3] or GREEN[max(1, idx[k] - 2)], d.tok)
        elseif dd >= -1.6 and dd <= -0.5 and idx[k] <= 5 then c:put(x, y, GREEN[min(6, idx[k] + 1)], d.tok) end
      end
      if d.nub and d.nub[k] then c:put(x, y, (s < 0) and BUD[4] or BUD[2], d.tok) end
    end)
  end
  -- cut face: flat bottom row pale with a darker fibre ring
  vis:each(function(x, y) if y == BOT then local k = K(x, y)
    local s = d.S[k] c:put(x, y, (abs(s) > 0.6) and PALE[3] or (s < -0.1 and PALE[6] or PALE[5]), d.tok) end end)
  d.vis, d.idx = vis, idx
end
-- waxy specular streak on the left spear + one glint
do local d = defs[2]
  for _, q in ipairs{ { 0.22 }, { 0.26 }, { 0.3 - 0.01 }, { 0.36 }, { 0.4 }, { 0.48 }, { 0.52 } } do
    local s = d.samp[floor(q[1] * 160) + 1]
    local x, y = floor(s.x - s.px * s.w * 0.45 + .5), floor(s.y - s.py * s.w * 0.45 + .5)
    if d.vis:has(x, y) and y < TY0 - 1 then c:put(x, y, GREEN[6], d.tok) end
  end
  local s = d.samp[floor(0.34 * 160) + 1]
  c:put(floor(s.x - s.px * s.w * 0.45 + .5), floor(s.y - s.py * s.w * 0.45 + .5), SPEC, d.tok)
end
-- tip glint on each bud (small, glossy scales)
for i, d in ipairs(defs) do
  local s = d.samp[floor(0.86 * 160) + 1]
  local x, y = floor(s.x - s.px * 0.9 + .5), floor(s.y - s.py * 0.9 + .5)
  if d.vis:has(x, y) then c:put(x, y, BUD[6], d.tok) end
end

-- twine: twisted band, lit top row, dark under row, diagonal twist strands
local ttok = { r = { name = "twine" } }
band:each(function(x, y)
  local r = y - TY0
  local tw = (x + y * 1) % 3
  local i
  if r == 0 then i = (tw == 0) and 4 or 5
  elseif r == TY1 - TY0 then i = (tw == 0) and 1 or 2
  else i = (tw == 0) and 2 or ((tw == 1) and 3 or 4) end
  local bx0, _, bx1 = band:bbox()
  c:put(x, y, TW[i], ttok)
end)
-- loose twine end curling off the right, with twist
local tail = { { 40, 46, 3 }, { 41, 47, 2 }, { 42, 48, 4 }, { 42, 49, 2 }, { 43, 50, 3 }, { 44, 51, 4 }, { 44, 52, 2 }, { 45, 53, 3 }, { 46, 53, 5 } }
for _, q in ipairs(tail) do if not band:has(q[1], q[2]) then c:put(q[1], q[2], TW[q[3]], ttok) end end
-- contact shadow of the tail on the right spear
for _, q in ipairs(tail) do local x, y = q[1] - 1, q[2] if defs[3].vis:has(x, y) and not band:has(x, y) then
  c:put(x, y, GREEN[1], defs[3].tok) end end

-- quirk: inchworm arched off the right spear's shade edge (tail low, head up the spear), lime body, dark belly, ink eye
do
  local d = defs[3]
  local wtok = { r = { name = "worm" } }
  local WL, WM, WD, WS = "#eef58a", "#c4da52", "#7f9a30", "#4d6326"
  local pts = {}
  for i = 0, 40 do
    local a = i / 40
    local s = d.samp[floor((0.47 + a * 0.18) * 160) + 1]
    local o = s.w + 0.2 + 4.2 * sin(pi * a) ^ 0.8
    pts[#pts + 1] = { s.x + s.px * o, s.y + s.py * o, a, s.px, s.py }
  end
  local wm, wa, wo = HP.mask(), {}, {}
  for _, q in ipairs(pts) do for oy = -1, 1 do for ox = -1, 1 do
    local x, y = floor(q[1] + ox * 0.6 + .5), floor(q[2] + oy * 0.6 + .5)
    local dd = (x - q[1]) * q[4] + (y - q[2]) * q[5]
    if abs(x - q[1]) + abs(y - q[2]) < 1.1 then wm:set(x, y) local k = K(x, y)
      if not wa[k] or abs(dd) < abs(wo[k]) then wa[k], wo[k] = q[3], dd end end
  end end end
  wm:each(function(x, y) local k = K(x, y)
    local col = (wo[k] < -0.3) and WL or ((wo[k] > 0.35) and WD or WM)
    if floor(wa[k] * 9) % 3 == 0 and wo[k] > -0.3 then col = WS end
    c:put(x, y, col, wtok) end)
  -- head (end of the arch, up the spear) with an ink eye
  local hq = pts[#pts]
  c:put(floor(hq[1] + 1.4 * hq[4] + .5), floor(hq[2] + 1.4 * hq[5] + .5), "#2b1c26", wtok)
  -- prolegs gripping the spear
  local fq = pts[1]
  c:put(floor(fq[1] - 0.6 * fq[4] + .5), floor(fq[2] - 0.6 * fq[5] + .5), WD, wtok)
end
G.save2(c, NAME)
