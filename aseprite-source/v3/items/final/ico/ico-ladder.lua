-- ico-ladder (final pass, Opus). A slim A-leaning wooden ladder: two round-shaved rails that taper in toward the
-- top, four doweled rungs. Material: per-pixel cylinder light (6-tone warm wood, violet-brown shade), long broken
-- grain streaks on the rails, a knot on one rung, pale end grain with a ring on the rail tops, dark dowel pegs,
-- AO where every rung enters a rail and a cast shadow under it, 2-tone ground shadow under the feet.
-- quirk: the third rung has split and is lashed to the right rail with twine, its twisted end dangling.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new("ico-ladder")
local WOOD = { "#3e2230", "#683a30", "#925535", "#b87a48", "#d89c5e", "#f2c78a" }
local END  = { "#c48a55", "#e8bf86", "#f7dcaa" }
local TW   = { "#6e4220", "#c48c38", "#f0d07a" }
local wtok = { r = { name = "wood" } }

c:groundShadow(32, 57, 16, 1)

-- rails (geometry first, painted after rungs so they sit in front)
local L0, L1 = { 23, 7 }, { 18, 56 }
local R0, R1 = { 41, 7 }, { 46, 56 }
local function rw(t) return 1.95 end
local lm, ln, LT, LS = X.cyl(L0[1], L0[2], L1[1], L1[2], rw)
local rm, rn, RT, RS = X.cyl(R0[1], R0[2], R1[1], R1[2], rw)
local rails = lm:copy():add(rm)
local function railX(P0, P1, y) return P0[1] + (P1[1] - P0[1]) * (y - P0[2]) / (P1[2] - P0[2]) end

-- rungs: horizontal cylinders
local RY = { 16, 27, 38, 49 }
local rungAll = HP.mask()
for i, y in ipairs(RY) do
  local xa, xb = railX(L0, L1, y) - 1, railX(R0, R1, y) + 1
  local m, n, T, S = X.cyl(xa, y + 0.5, xb, y + 0.5, function() return 1.6 end)
  m:cut(rails)
  local bias = {}
  X.ao(bias, m, rails, 2, -1)
  local idx = A.shade(c, m, n, WOOD, { amb = 0, wrap = 0.15, bias = bias, tok = wtok, cuts = { 0.3, 0.46, 0.6, 0.74, 0.9 } })
  -- horizontal grain: a broken dark line on the lower half
  m:each(function(x, yy) local k = K(x, yy)
    if yy == y + 1 and X.hash(x, i, 3) > 0.55 then A.step(c, idx, WOOD, x, yy, -1, wtok) end
    if yy == y and X.hash(x, i, 7) > 0.78 then A.step(c, idx, WOOD, x, yy, 1, wtok) end
  end)
  if i == 2 then -- knot
    local kx = floor(xa + 8)
    c:put(kx, y, WOOD[2], wtok) c:put(kx + 1, y, WOOD[1], wtok) c:put(kx + 1, y + 1, WOOD[2], wtok)
    c:put(kx - 1, y, WOOD[3], wtok) c:put(kx + 2, y + 1, WOOD[3], wtok)
  end
  if i == 3 then -- split along the rung
    for x = floor(xa + 11), floor(xb - 2) do
      if m:has(x, y + 1) then c:put(x, y + 1, WOOD[1], wtok) end
      if m:has(x, y) and x > xb - 7 then c:put(x, y, WOOD[2], wtok) end
    end
  end
  rungAll:add(m)
end

-- paint rails
local function rail(m, n, T, S, P0, P1, seed)
  local bias = {}
  -- cast shadow just under each rung on the rail face
  for _, y in ipairs(RY) do
    m:each(function(x, yy) if yy == y + 2 or yy == y + 3 then local k = K(x, yy) bias[k] = (bias[k] or 0) - 1 end end)
  end
  -- feet darken toward the ground
  m:each(function(x, yy) if yy >= 54 then local k = K(x, yy) bias[k] = (bias[k] or 0) - 1 end end)
  local idx = A.shade(c, m, n, WOOD, { amb = 0, wrap = 0.15, bias = bias, tok = wtok, cuts = { 0.3, 0.46, 0.6, 0.74, 0.9 } })
  -- long grain streaks: dark on the face, broken by hash
  m:each(function(x, y) local k = K(x, y)
    local s = S[k]
    local lane = floor((s + 1) * 2.2)
    if (lane == 1 or lane == 3) and X.hash(lane, floor(y / 5), seed) > 0.35 and (y + lane * 3) % 9 ~= 0 then
      A.step(c, idx, WOOD, x, y, -1, wtok)
    end
  end)
  -- specular: a short bright streak on the lit edge
  for y = 10, 46, 1 do
    if (y % 11) < 5 then
      local x = floor(railX(P0, P1, y) - 0.6 + 0.5)
      if m:has(x, y) and idx[K(x, y)] and idx[K(x, y)] >= 4 then c:put(x, y, WOOD[6], wtok) end
    end
  end
  -- end grain on the top
  local tx = floor(P0[1] + 0.5)
  for x = tx - 2, tx + 2 do
    for y = 6, 8 do if m:has(x, y) then c:put(x, y, END[2], wtok) end end
  end
  for x = tx - 2, tx + 2 do if m:has(x, 6) then c:put(x, 6, END[3], wtok) end end
  if m:has(tx + 1, 8) then c:put(tx + 1, 8, END[1], wtok) end
  if m:has(tx - 1, 9) then c:put(tx - 1, 9, WOOD[3], wtok) end
  c:put(tx, 7, END[1], wtok)
  -- dowel pegs where rungs pass through
  for _, y in ipairs(RY) do
    local x = floor(railX(P0, P1, y) + 0.5)
    c:put(x, y, WOOD[1], wtok) c:put(x, y + 1, WOOD[2], wtok) c:put(x - 1, y, WOOD[3], wtok)
  end
  return idx
end
rail(lm, ln, LT, LS, L0, L1, 11)
rail(rm, rn, RT, RS, R0, R1, 29)

-- quirk: twine lashing the split third rung to the right rail; twisted end dangling
local y3 = RY[3]
local rx = floor(railX(R0, R1, y3) + 0.5)
local lash = {
  "..hmd..",
  ".hmd.hm",
  "hmd.hmd",
  "md.hmd.",
  "d.hmd..",
  "..md...",
}
A.map(c, lash, rx - 4, y3 - 2, { h = TW[3], m = TW[2], d = TW[1] })
-- dangling twisted end
local tail = { { rx - 3, y3 + 4 }, { rx - 3, y3 + 5 }, { rx - 4, y3 + 6 }, { rx - 4, y3 + 7 }, { rx - 4, y3 + 8 }, { rx - 3, y3 + 9 } }
for i, p in ipairs(tail) do c:put(p[1], p[2], i % 2 == 0 and TW[3] or TW[1]) c:put(p[1] + 1, p[2], i % 2 == 0 and TW[1] or TW[2]) end
c:put(tail[#tail][1], tail[#tail][2] + 1, TW[2])

A.save(c, "ico-ladder")
