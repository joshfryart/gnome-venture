-- ico-bat (final, Opus). Front view, wings spread wide: a slim arm bone to each wrist with a thumb claw, three
-- finger bones fanning to the tips, scalloped trailing edges; a small round furry body, big ears, tiny feet.
-- Material: membrane lit per pixel (6-tone berry violet) with lit bones and a dark sag row under each bone,
-- AO where the wings meet the body; fur (6-tone dusk) with tuft strands and a pale collar; face with 2x3 eyes,
-- a pushed-up snout with an ink nose tip + cream glint, and two tiny fangs.
-- quirk: a little V nick bitten out of the left ear.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("ico-bat")
local MEM = { "#3a1a3e", "#55264f", "#773566", "#9a4a7e", "#bc6894", "#dc92ae" }
local FUR = { "#251a3c", "#3a2a5c", "#524088", "#6c58a8", "#8b78c6", "#b2a2e2" }
local SNOUT = { "#6c58a8", "#a08cd6", "#c4b6ee" }

local function mirror(pts) local r = {} for i, p in ipairs(pts) do r[i] = { 63 - p[1], p[2] } end return r end
local L = {
  S = { 27, 30 }, W = { 14, 13 },
  F = { { 6, 25 }, { 9, 37 }, { 18, 43 } }, Hp = { 27, 40 },
}
local function wing(S, W, F, Hp)
  local m = c:poly{ S, { W[1], W[2] - 1 }, { W[1] - 1, W[2] }, F[1], F[2], F[3], Hp }
  -- scallops between tips
  local tips = { F[1], F[2], F[3], Hp }
  local cx0, cy0 = (W[1] + S[1]) / 2, (W[2] + S[2]) / 2
  for i = 1, #tips - 1 do
    local a, b = tips[i], tips[i + 1]
    local mx, my = (a[1] + b[1]) / 2, (a[2] + b[2]) / 2
    local d = sqrt((a[1] - b[1])^2 + (a[2] - b[2])^2)
    local ox, oy = mx - W[1], my - W[2]
    local ol = sqrt(ox * ox + oy * oy) ox, oy = ox / ol, oy / ol
    local r = d * 0.5 + 0.6
    m:cut(A.ellM(mx + ox * (r - 2.9), my + oy * (r - 2.9), r, r))
  end
  return m
end
local lw = wing(L.S, L.W, L.F, L.Hp)
local rw = wing(mirror{ L.S }[1], mirror{ L.W }[1], mirror(L.F), mirror{ L.Hp }[1])
local mtok = { r = { name = "membrane" } }
local bonesM = HP.mask()
local function paintWing(m, S, W, F)
  local n = X.pillow(m, 2.2)
  local bias = {}
  -- sag: membrane darker along the trailing edge between bones
  local e = m:edge()
  e:each(function(x, y) if y > W[2] + 4 then bias[K(x, y)] = -1 end end)
  -- panels: lighter next to each bone, darker toward the free edge
  m:each(function(x, y) local k = K(x, y)
    local best = 1e9
    for _, f in ipairs(F) do
      local vx, vy = f[1] - W[1], f[2] - W[2]
      local t = max(0, min(1, ((x - W[1]) * vx + (y - W[2]) * vy) / (vx * vx + vy * vy)))
      local dx, dy = x - (W[1] + vx * t), y - (W[2] + vy * t)
      best = min(best, dx * dx + dy * dy)
    end
    if best > 12 then bias[k] = (bias[k] or 0) - 1 elseif best <= 2 then bias[k] = (bias[k] or 0) + 1 end
  end)
  local idx = A.shade(c, m, n, MEM, { tok = mtok, bias = bias, amb = 0.16, wrap = 0.35, cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 } })
  -- finger bones (1 px lit, dark sag row below), arm bone 3 px
  for _, f in ipairs(F) do
    local bl = c:line({ W, f }, 1)
    bl:each(function(x, y) if m:has(x, y) then
      c:put(x, y, MEM[1], mtok) bonesM:set(x, y)
      if m:has(x, y - 1) and not bl:has(x, y - 1) then c:put(x, y - 1, MEM[6], mtok) end
    end end)
  end
  local arm = c:line({ S, W }, 3)
  local an = X.pillow(arm, 1.5)
  A.shade(c, arm, an, { MEM[2], MEM[3], MEM[4], MEM[5], MEM[6], "#f2bccc" }, { tok = mtok, amb = 0.1, wrap = 0.3 })
  -- thumb claw at the wrist
  local tx = W[1] < 32 and -1 or 1
  c:put(W[1] + tx, W[2] - 2, MEM[4], mtok) c:put(W[1] + tx * 2, W[2] - 3, MEM[2], mtok)
  bonesM:add(arm)
  return idx
end
paintWing(lw, L.S, L.W, L.F)
paintWing(rw, mirror{ L.S }[1], mirror{ L.W }[1], mirror(L.F))

-- body
local ftok = { r = { name = "fur" } }
local body = A.ellM(31.5, 35, 5.6, 8)
local bn = X.sphere(31, 34.5, 7, body)
local bb = {}
local bidx = A.shade(c, body, bn, FUR, { tok = ftok, bias = bb, amb = 0.06, wrap = 0.25 })
-- AO on the membrane next to the body
local wings = lw:copy():add(rw)
local ring = body:grow(1):cut(body)
ring:each(function(x, y) if wings:has(x, y) and not bonesM:has(x, y) then c:put(x, y, MEM[1], mtok) end end)
-- feet: two tiny clawed toes
for _, fx in ipairs{ 29, 34 } do c:put(fx, 43, FUR[2], ftok) c:put(fx, 44, FUR[1], ftok) end
-- fur strands on the belly
for _, p in ipairs{ { 30, 36 }, { 33, 37 }, { 31, 39 }, { 34, 40 }, { 29, 40 } } do
  if body:has(p[1], p[2]) then A.step(c, bidx, FUR, p[1], p[2], -1, ftok) A.step(c, bidx, FUR, p[1] + 1, p[2] - 1, 1, ftok) end
end

-- ears (behind head), left one nicked
local earL = c:poly{ { 24, 23 }, { 22, 8 }, { 31, 17 } }
local earR = c:poly{ { 32, 17 }, { 41, 8 }, { 39, 23 } }
earL:cut(c:poly{ { 20, 12 }, { 24, 14 }, { 20, 16 } })
for _, em in ipairs{ earL, earR } do
  local n = X.pillow(em, 1.5)
  A.shade(c, em, n, FUR, { tok = ftok, amb = 0.08, wrap = 0.3 })
end
local inL = c:poly{ { 25, 20 }, { 23, 11 }, { 28, 17 } }
local inR = c:poly{ { 35, 17 }, { 40, 11 }, { 38, 20 } }
for _, im in ipairs{ inL, inR } do
  im:each(function(x, y) c:put(x, y, (y < 16) and MEM[4] or MEM[3], mtok) end)
end
-- head
local head = A.ellM(31.5, 24.2, 6.4, 5.8)
local hn = X.sphere(30.8, 23, 7.5, head)
local hb = {}
local hidx = A.shade(c, head, hn, FUR, { tok = ftok, bias = hb, amb = 0.08, wrap = 0.28 })
-- contact shade where the head sits on the body + pale collar tuft below the chin
for x = 27, 36 do local y = 31 if false and body:has(x, y) and not head:has(x, y) then c:put(x, y, FUR[1], ftok) end end
for _, p in ipairs{ { 30, 32 }, { 31, 33 }, { 32, 33 }, { 33, 32 }, { 31, 34 } } do c:put(p[1], p[2], FUR[5], ftok) end
c:put(32, 34, FUR[4], ftok) c:put(31, 32, FUR[6], ftok)
-- head fur tuft between the ears
c:put(31, 17, FUR[4], ftok) c:put(32, 17, FUR[3], ftok) c:put(31, 18, FUR[5], ftok)
-- face
c:eyeSmall(27, 21) c:eyeSmall(35, 21)
local snout = c:rrect(29, 24, 34, 27, 1)
snout:each(function(x, y) c:put(x, y, (y == 24 or x == 29) and SNOUT[3] or SNOUT[2], ftok) end)
c:put(34, 26, SNOUT[1], ftok) c:put(33, 27, SNOUT[1], ftok)
-- nose tip: ink with a cream glint
c:put(30, 25, A.INK) c:put(31, 25, A.CREAM) c:put(32, 25, A.INK) c:put(33, 25, A.INK)
c:put(31, 26, A.INK) c:put(32, 26, A.INK)
-- small smile + fangs
c:put(30, 28, A.INK) c:put(31, 28, A.INK) c:put(32, 28, A.INK) c:put(33, 28, A.INK)
c:put(30, 29, A.CREAM) c:put(33, 29, A.CREAM)

A.save(c, "ico-bat")
