-- ico-wind (final pass, Opus single pass). Bold icon: three gusts streaming left to right, each a slim tapered
-- air ribbon that rolls into a curl at its leading end (top and bottom curl up, the long middle one curls down).
-- Per-pixel tube light (6-tone airy cyan, cool-violet shade), a twist cue (diagonal ribbon bands that flip along
-- the length), darker back-of-ribbon on the inside of each curl, AO where the curl tucks over itself, one bright
-- streak on the long gust, small speed dashes trailing behind the tails.
-- quirk: a dandelion seed has hitched a ride and spins inside the middle curl.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/../_helpers/_aR1_1.lua")
local HP, X, K = T.HP, T.X, T.K
local floor, max, min, sqrt, abs, sin, cos, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.cos, math.pi
local c = T.new("ico-wind")
local AIR = { "#2d4580", "#3d68a8", "#5896cc", "#84c2e6", "#bce4f5", "#eefbff" }
local BACK = { "#2c3f74", "#3b5f9c", "#5486bd" }

-- path builder: straight wavy run (x0..x1 at y0) then a spiral curl about (cx,cy)
local function gust(x0, y0, x1, wave, cx, cy, r0, a0, turn, shrink)
  local pts = {}
  local n1 = 60
  for i = 0, n1 do local u = i / n1
    pts[#pts + 1] = { x0 + (x1 - x0) * u, y0 + wave * sin(u * pi * 1.4) } end
  local n2 = 80
  for i = 1, n2 do local u = i / n2
    local a = a0 + turn * u
    local r = r0 * (1 - shrink * u)
    pts[#pts + 1] = { cx + r * cos(a), cy + r * sin(a) } end
  -- arclength param
  local L = { 0 }
  for i = 2, #pts do L[i] = L[i - 1] + sqrt((pts[i][1] - pts[i-1][1])^2 + (pts[i][2] - pts[i-1][2])^2) end
  local tot = L[#L]
  local split = L[n1 + 1] / tot
  local function f(t)
    local s = t * tot
    local j = 1
    while j < #pts - 1 and L[j + 1] < s do j = j + 1 end
    local seg = L[j + 1] - L[j]
    local u = seg > 0 and (s - L[j]) / seg or 0
    return pts[j][1] + (pts[j+1][1] - pts[j][1]) * u, pts[j][2] + (pts[j+1][2] - pts[j][2]) * u
  end
  return f, split, tot
end

local gusts = {}
local function draw(f, split, tot, wmax, ccx, ccy, tag)
  local function wfn(t)
    if t < 0.4 then return 1.55 + (wmax - 1.55) * (t / 0.4) end
    if t < split then return wmax end
    return wmax - (wmax - 1.5) * ((t - split) / (1 - split)) ^ 0.8
  end
  local m, n, TT, S = T.sweep(f, wfn, 300)
  local tok = { r = { name = tag } }
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    local t = TT[k]
    -- twist bands on the run: thin diagonal flips, every ~8 px
    if t < split * 0.96 and t > 0.12 then
      local d = (t * tot + S[k] * 2.2) % 8.5
      if d < 1.0 then bias[k] = (bias[k] or 0) - 2 end
      if d >= 1.0 and d < 2.0 and S[k] < 0.2 then bias[k] = (bias[k] or 0) + 1 end
    end
    -- inside of the curl: back of the ribbon (cooler, darker)
    if t > split then
      local dx, dy = x + 0.5 - ccx, y + 0.5 - ccy
      local rr = sqrt(dx*dx + dy*dy)
      local ex, ey = f(t)
      local re = sqrt((ex - ccx)^2 + (ey - ccy)^2)
      if rr < re - 0.6 then bias[k] = (bias[k] or 0) - 1 end
    end
  end)
  local idx = T.shade(c, m, n, AIR, { amb = 0.02, wrap = 0.06, bias = bias, tok = tok, cuts = { 0.12, 0.28, 0.46, 0.66, 0.86 } })
  gusts[#gusts + 1] = { m = m, TT = TT, S = S, idx = idx, tok = tok, split = split, f = f, tot = tot }
  return m, idx, TT, S, tok
end

-- top gust: curls up and back over itself
local fA, sA, tA = gust(10, 21, 39, -1.0, 39, 14.0, 7.0, pi / 2, -1.7 * pi, 0.42)
draw(fA, sA, tA, 2.35, 39, 14.0, "gA")
-- middle gust: the long one, curls down
local fB, sB, tB = gust(5, 32, 44, 1.2, 44, 39.5, 7.5, -pi / 2, 1.72 * pi, 0.42)
local mB, iB, TB, SB, tokB = draw(fB, sB, tB, 2.6, 44, 39.5, "gB")
-- bottom gust: short, curls up
local fC, sC, tC = gust(14, 51, 28, -0.8, 28, 45.5, 5.5, pi / 2, -1.5 * pi, 0.5)
draw(fC, sC, tC, 2.2, 28, 45.5, "gC")

-- AO: where each curl's tail tucks back toward its own loop, darken the loop pixels next to it
for _, g in ipairs(gusts) do
  local tail = HP.mask()
  g.m:each(function(x, y) if g.TT[K(x, y)] > 0.93 then tail:set(x, y) end end)
  local near = tail:grow(1)
  g.m:each(function(x, y) local k = K(x, y)
    if near:has(x, y) and not tail:has(x, y) and g.TT[k] < 0.85 and g.TT[k] > g.split then
      c:put(x, y, BACK[1], g.tok) end end)
end

-- bright streak along the top of the long gust + one cream glint
for x = 14, 22 do
  for y = 25, 40 do
    local k = K(x, y)
    if mB:has(x, y) and SB[k] and SB[k] < -0.35 and SB[k] > -0.75 then c:put(x, y, AIR[6], tokB) break end
  end
end
do
  local gx, gy
  for y = 25, 40 do if mB:has(17, y) then gx, gy = 17, y break end end
  if gx then c:put(gx, gy + 0, T.CREAM, tokB) end
end

-- speed dashes trailing the tails (3 px tall, chunky enough for 16 px)
local function dash(x0, x1, y)
  local m = HP.rect(x0, y - 1, x1, y + 1)
  m:cut(HP.rect(x0, y - 1, x0, y - 1)):cut(HP.rect(x1, y + 1, x1, y + 1))
  local idx = T.pil(c, m, AIR, 1.4, { amb = 0.2, wrap = 0.35, tok = { r = { name = "dash" } } })
end
dash(4, 7, 22)
dash(8, 11, 51)

-- quirk: dandelion seed spinning in the middle curl (cream pappus fan, thin stalk, brown seed)
local qx, qy = 44, 40
local map = {
  ".c.c.",
  "ccccc",
  ".csc.",
  "..s..",
  "..b..",
}
local PAL = { c = T.CREAM, s = "#c9b48a", b = "#8a5638" }
T.map(c, map, qx - 2, qy - 3, PAL, { r = { name = "seed" } })
c:put(qx + 1, qy + 2, BACK[2], { r = { name = "seed" } })

T.save(c, "ico-wind")
