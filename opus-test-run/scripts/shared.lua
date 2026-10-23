-- shared.lua : pieces every stage backdrop uses, so the lands read as one family
-- (same sky bands, same sun, same horizon heights, same ground strip and soil bank).
local X = ...
local S = {}
S.M = X.ramp("#7ab55c")   -- moss 400 ramp: gloss #bdd292 and rim #acc47d are the far hills
local floor, sin = math.floor, math.sin

-- five hard sky bands, darkest at the top (water family + glass gloss + cream at the horizon)
S.SKY = { "#8fcbd8", "#a9d6ea", "#c8ecdc", "#eef8f2" }
function S.sky(c, rows)
  rows = rows or { 0, 15, 31, 46, 135 }
  for i, col in ipairs(S.SKY) do c:fill(c:rect(0, rows[i], c.W - 1, rows[i+1] - 1), col) end
end
-- sun in the upper left: the light source of every scene
function S.sun(c, x, y, r)
  c:part(c:ellipse(x, y, r or 9), X.ramp("gold", { base = "#f5cf6a", shade = "#e8a317" }), { outline = false, bounce = false, rim = false, deep = 0, cres = 3, gloss = false })
end
function S.cloud(c, x, y, s)
  local m = c:ellipse(x, y, 13*s, 5*s):add(c:ellipse(x - 7*s, y + 1, 8*s, 4*s)):add(c:ellipse(x + 5*s, y - 3*s, 8*s, 5*s))
  m:cut(c:rect(x - 40, y + 3*s + 1, x + 40, y + 20))
  c:part(m, "cream", { outline = false, gloss = false, bounce = false, rim = false, deep = 0, cres = 2 })
end
-- a band of land from a wavy top line down to the bottom; waves = { {amp, period, phase}, ... }
function S.ridge(c, col, base, waves)
  local m = c:mask()
  for x = 0, c.W - 1 do
    local t = base
    for _, w in ipairs(waves) do t = t + w[1] * sin(x / w[2] + w[3]) end
    m:rect(x, floor(t + 0.5), x, c.H - 1)
  end
  c:fill(m, col)
  return m
end
function S.farTree(c, x, y, col)
  c:fill(c:ellipse(x, y - 4, 3, 3):add(c:rect(x, y - 1, x, y)), col)
end
-- walkable strip (grid y 92..110 = exported y 184..221, feet at 195 and 215), near band, soil bank
function S.ground(c, o)
  local walkTop, nearTop, bankTop = o.walkTop or 92, 111, 127
  c:fill(c:rect(0, walkTop, c.W - 1, c.H - 1), o.walk)
  local near = c:mask()
  for x = 0, c.W - 1 do near:rect(x, nearTop + ((x // 9) % 3 == 1 and 1 or 0), x, c.H - 1) end
  c:fill(near, o.near)
  local bank = c:mask()
  for x = 0, c.W - 1 do
    local d = ((x % 7) < 3) and 1 or 0
    if x % 23 == 5 or x % 23 == 6 then d = 2 end
    bank:rect(x, bankTop + d, x, c.H - 1)
  end
  c:fill(bank, o.bank or "#9a6b3f")
  c:fill(c:rect(0, 132, c.W - 1, c.H - 1), o.bankDeep or "#7a4a1f")
  -- tufts: deterministic scatter, fewer in the calm side thirds
  local seed = o.seed or 7
  local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  for i = 1, o.tufts or 70 do
    local x, y = rnd(c.W - 6), walkTop + 3 + rnd(bankTop - walkTop - 6)
    local side = x < 80 or x > 160
    if not side or rnd(3) == 0 then
      local col = y >= nearTop and o.tuftNear or o.tuft
      c:paint({ "x.x.x", ".x.x." }, x, y, { x = col })
    end
  end
end
function S.flowers(c, list)
  for _, f in ipairs(list) do
    local x, y, k = f[1], f[2], f[3]
    if k == "p" then c:paint({ "lb", "bb", ".s" }, x, y, { l = "#f6b8cf", b = "#e46a9b", s = "#2f5a2a" })
    else c:paint({ "lb", "bb", ".s" }, x, y, { l = "#f5cf6a", b = "#e8a317", s = "#2f5a2a" }) end
  end
end
function S.bird(c, x, y)
  c:paint({ "x...x", ".x.x." }, x, y, { x = "#4a2c1a" })
end
return S
