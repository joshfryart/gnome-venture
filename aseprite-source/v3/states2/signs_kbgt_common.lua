-- shared helpers for the BUILD-sign pass of kitchen, beehive, greenhouse, tailor (empty state only)
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local SF = dofile("/tmp/ase/states2/signfont.lua")
local P = HP.P
local floor = math.floor
local G = { HP = HP, P = P, SF = SF }
G.INK = P.ink
G.DUSKSH = "#5a4660"
-- packed earth: hue-shifted, warmer when lit, cooler/purpler in the dark
G.EARTH = { lite = "#c4945f", base = "#a7724b", dark = "#835340", rim = "#5c3a36" }
G.GRASS = "#a8cc70"

local function hexrgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
function G.lerp(a, b, t)
  local r1, g1, b1 = hexrgb(a); local r2, g2, b2 = hexrgb(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
local lerp = G.lerp
G.SHC = lerp(G.GRASS, G.DUSKSH, .42)
function G.hsh(x, y)
  local h = (x * 374761393 + y * 668265263) & 0xffffffff
  h = ((h ~ (h >> 13)) * 1274126177) & 0xffffffff
  return (h ~ (h >> 16)) % 100
end
local hsh = G.hsh

function G.new(w, h, name) G.c = HP.canvas{ w = w, h = h, scale = 1, name = name } G.W, G.H = w, h return G.c end
function G.px(x, y, hex) G.c:px(x, y, hex) end
function G.get(x, y) return G.c:get(x, y) end
function G.R(x0, y0, x1, y1, hex) G.c:fillMask(G.c:rect(x0, y0, x1, y1), hex) end
function G.seg(x0, y0, x1, y1, hex)
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  for i = 0, n do local t = n == 0 and 0 or i / n; G.px(floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5), hex) end
end
function G.segMask(x0, y0, x1, y1)
  local m = HP.mask()
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  for i = 0, n do local t = n == 0 and 0 or i / n; m:set(floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)) end
  return m
end
function G.pts(list) local m = HP.mask() for _, q in ipairs(list) do m:set(q[1], q[2]) end return m end
function G.ink(...) local u = HP.mask() for _, m in ipairs{ ... } do u:add(m) end G.c:rim(u, G.INK) return u end
function G.text(x, y, col, shadow) SF.text(G.px, x, y, col, shadow) end

local EARTHSET = {}
for _, v in pairs(G.EARTH) do EARTHSET[v] = true end
G.EARTHSET = EARTHSET

-- cleared plot, flush with the ground: packed earth in 3 tones, darker cut rim, lit near lip.
function G.plot(x0, y0, x1, y1, r, seed)
  local c, E = G.c, G.EARTH
  seed = seed or 1
  -- soft superellipse with a slightly ragged edge (a cleared patch, not a box)
  local cx, cy, rx, ry = (x0 + x1) / 2, (y0 + y1) / 2, (x1 - x0) / 2 + .5, (y1 - y0) / 2 + .5
  local m = HP.mask()
  for y = y0, y1 do for x = x0, x1 do
    local u, v = (x + .5 - cx - .5) / rx, (y + .5 - cy - .5) / ry
    local q = (math.abs(u) ^ 3.2) + (math.abs(v) ^ 3.2)
    local n = (hsh(x // 3 + seed, y // 2 + seed * 3) - 50) / 50 * .09
    if q <= 1 + n then m:set(x, y) end
  end end
  c:fillMask(m, E.base)
  local inner = m:shrink(1)
  m:each(function(x, y)
    local h = hsh(x * 3 + seed, y * 7 + seed)
    if h < 8 then G.px(x, y, E.lite) if h < 3 and m:has(x + 1, y) then G.px(x + 1, y, E.lite) end
    elseif h > 91 then G.px(x, y, E.dark) end
  end)
  -- rake furrows: short dark dashes with a lit lower lip
  for yy = y0 + 4, y1 - 3, 4 do
    for xx = x0 + 3, x1 - 4 do
      local k = (xx + (yy // 4) * 3 + seed) % 9
      if k < 3 and hsh(xx // 9 + seed, yy) < 55 and inner:has(xx, yy) and inner:has(xx, yy + 1) then
        G.px(xx, yy, E.dark) G.px(xx, yy + 1, E.lite)
      end
    end
  end
  -- cut walls: far wall and left wall in shade, right wall and near lip lit
  inner:each(function(x, y)
    if not inner:has(x, y - 1) then G.px(x, y, E.dark)
    elseif not inner:has(x - 1, y) and y < cy then G.px(x, y, E.dark)
    elseif (not inner:has(x + 1, y) or not inner:has(x, y + 1)) and y > cy then G.px(x, y, E.lite) end
  end)
  m:edge():each(function(x, y) G.px(x, y, (y < cy + 2) and E.rim or E.dark) end)
  G.plotMask = m
  return m
end

-- cool hard shadow over whatever is below (earth darkens, grass gets the grass shadow tone)
function G.shadow(m, t)
  m:each(function(x, y)
    local v = G.c:get(x, y)
    if not v then G.px(x, y, G.SHC)
    elseif v ~= G.INK then G.px(x, y, lerp(v, G.DUSKSH, t or .5)) end
  end)
end

-- corner stake (1 px wide wooden peg with ink rim), base at (x, yb), 6 tall
function G.stake(x, yb)
  local W = P.wood
  local m = G.c:rect(x, yb - 5, x, yb)
  G.ink(m) G.c:fillMask(m, W.base) G.px(x, yb - 5, W.hi) G.px(x, yb, W.shade) G.px(x, yb - 4, P.cream)
end
-- twine between two stake tie points (cream on top, tan underside: 2 px read)
function G.twine(a, b)
  local dx, dy = math.abs(b[1] - a[1]), math.abs(b[2] - a[2])
  local ox, oy = 0, 1
  if dy > dx then ox, oy = 1, 0 end
  G.seg(a[1], a[2], b[1], b[2], P.cream)
end
-- stakes = { bl, br, fl, fr } bases. back(): far twine + far stakes + side twines. front(): near twine + near stakes.
function G.stringBack(S)
  local t = function(p) return { p[1], p[2] - 4 } end
  G.twine(t(S[1]), t(S[2]))
  G.twine(t(S[1]), t(S[3]))
  G.twine({ S[2][1] - 1, S[2][2] - 4 }, { S[4][1] - 1, S[4][2] - 4 })
  G.stake(S[1][1], S[1][2]) G.stake(S[2][1], S[2][2])
end
function G.stringFront(S)
  G.twine({ S[3][1], S[3][2] - 4 }, { S[4][1], S[4][2] - 4 })
  G.stake(S[3][1], S[3][2]) G.stake(S[4][1], S[4][2])
end

function G.pebble(x, y, big)
  local m = big and G.c:rect(x, y, x + 2, y + 1):add(G.c:rect(x + 1, y - 1, x + 1, y - 1)) or G.c:rect(x, y, x + 1, y)
  G.ink(m) G.c:fillMask(m, P.stone.base) G.px(x, y, P.stone.hi)
  if big then G.px(x + 1, y - 1, P.stone.hi) G.R(x + 1, y + 1, x + 2, y + 1, P.stone.shade) else G.px(x + 1, y, P.stone.shade) end
end
function G.tuft(x, y)   -- (x, y) = bottom centre
  local M = P.moss
  G.px(x - 1, y, M.shade) G.px(x, y, M.shade) G.px(x + 1, y, M.shade)
  G.px(x - 1, y - 1, M.base) G.px(x, y - 2, M.hi) G.px(x, y - 1, M.base) G.px(x + 1, y - 1, M.base) G.px(x + 2, y - 2, M.base)
  G.px(x - 2, y - 1, M.shade)
end
function G.flower(x, y, col, eye)   -- head centre (x, y), stem below
  local head = G.pts{ { x, y - 1 }, { x - 1, y }, { x, y }, { x + 1, y }, { x, y + 1 } }
  local stem = G.c:rect(x, y + 2, x, y + 3)
  local leaf = G.pts{ { x + 1, y + 3 } }
  G.ink(head, stem, leaf)
  G.c:fillMask(stem, P.moss.shade) G.px(x + 1, y + 3, P.moss.base)
  G.c:fillMask(head, col) G.px(x, y, eye or P.gold.hi)
end

function G.save(frames, out, b)
  for _, f in ipairs(frames) do HP.assertClean(f) end
  HP.sheet{ cellw = G.W, cellh = G.H, frames = frames, tags = { { name = "empty", from = 1, to = #frames } } }:save{
    aseprite = out .. b .. "-empty.aseprite", png = out .. b .. "-empty.png", scale = 1 }
end
return G
