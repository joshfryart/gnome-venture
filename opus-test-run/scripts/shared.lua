-- shared.lua : pieces every stage backdrop uses, so the lands read as one family
-- (same sky bands, same sun, same horizon heights, same ground strip and soil bank).
local X = ...
local S = {}
S.M = X.ramp("#7ab55c")   -- moss 400 ramp: gloss #bdd292 and rim #acc47d are the far hills
local floor, sin = math.floor, math.sin

-- THE HOLLOW IS UNDERGROUND: the "sky" is a cavern ceiling. Rock ceiling with stalactites, then glowing cave air in four hard bands that brighten toward the
-- horizon, a glow-stone orb in the upper left (the light source) and drifting spore mist. Themes give each land its own cave-air colour.
S.THEMES = {
  grassland = { "#3d2a1c", "#7a4a1f", "#9a6b3f", "#c9a96e" }, forest = { "#3d2a1c", "#2f5a2a", "#4f9a45", "#a4b86a" }, mountain = { "#3d2a1c", "#4e3a8a", "#7a5cc0", "#c3b2ea" },
  wetland = { "#3d2a1c", "#25637d", "#3f8fb0", "#a9d6ea" }, tundra = { "#3d2a1c", "#4e3a8a", "#3f8fb0", "#c8ecdc" }, desert = { "#3d2a1c", "#7a4a1f", "#d9885a", "#f5cf6a" },
  island = { "#3d2a1c", "#25637d", "#3f8fb0", "#c8ecdc" }, coast = { "#3d2a1c", "#2a3c6c", "#3f8fb0", "#a9d6ea" }, rainforest = { "#3d2a1c", "#2f5a2a", "#4f9a45", "#c8d77a" },
  trek1 = { "#3d2a1c", "#7a4a1f", "#9a6b3f", "#f2e4c0" },
}
S.SKY = S.THEMES.grassland
function S.ceiling(c)
  -- rock mass with a wavy underside, then stalactites of mixed length (a few long ones), each with a lit left edge and a drip
  for x = 0, c.W - 1 do local d = 12 + math.floor(2 * math.sin(x / 11) + 2 * math.sin(x / 4.7) + 0.5); c:fill(c:rect(x, 0, x, d), "#3d2a1c"); if x % 5 < 2 then c:px(x, math.max(1, d - 4), "#4a2c1a") end end
  c:fill(c:rect(0, 5, c.W - 1, 5), "#4a2c1a")
  local i = 0
  for x = 3, c.W - 1, 9 do
    i = i + 1; local h = 8 + ((x * 13) % 14); if i % 6 == 0 then h = h + 16 elseif i % 4 == 0 then h = h + 7 end
    local y0 = 12
    c:fill(c:poly({ { x - 4, y0 }, { x, y0 + h }, { x + 4, y0 } }), "#2a1a10"); c:fill(c:poly({ { x - 4, y0 }, { x - 1, y0 + h * 0.7 }, { x - 1, y0 } }), "#4a2c1a")
    if i % 6 == 0 then c:px(x, y0 + h + 3, "#a9d6ea"); c:px(x, y0 + h + 4, "#eef8f2") end   -- a falling drip
  end
end
function S.sky(c, rows)
  rows = rows or { 0, 15, 31, 46, 135 }
  local pal = S.THEMES[S.theme] or S.SKY
  for i, col in ipairs(pal) do c:fill(c:rect(0, rows[i], c.W - 1, rows[i+1] - 1), col) end
  S.ceiling(c)
end
-- glow-stone orb in the upper left: a stepped halo, a gold disc and a pale core; hangs from the ceiling on a root
function S.sun(c, x, y, r)   -- a hanging glow-crystal cluster: stepped halo, gold and pale shards
  r = r or 9
  c:fill(c:ellipse(x, y, r + 5, r + 5), "#f2e4c0"); c:fill(c:ellipse(x, y, r + 2, r + 2), "#fff3c8")
  c:fill(c:rect(x, 11, x, y - 6), "#8a4f2a")
  c:fill(c:poly({ { x - 6, y - 3 }, { x - 2, y - 8 }, { x + 2, y - 3 }, { x + 1, y + 6 }, { x - 3, y + 8 } }), "#f5cf6a")
  c:fill(c:poly({ { x + 1, y - 4 }, { x + 5, y - 9 }, { x + 9, y - 2 }, { x + 6, y + 9 }, { x + 2, y + 5 } }), "#e8a317")
  c:fill(c:poly({ { x - 2, y - 2 }, { x, y - 6 }, { x + 3, y - 1 }, { x + 1, y + 7 }, { x - 1, y + 7 } }), "#fff3c8")
  c:px(x - 1, y - 3, "#fff3c8")
end
-- spore mist: a flat pale wisp
function S.cloud(c, x, y, s)
  local m = c:ellipse(x, y, 11*s, 3*s):add(c:ellipse(x - 6*s, y + 1, 7*s, 2*s)):add(c:ellipse(x + 5*s, y - 2*s, 7*s, 3*s))
  m:cut(c:rect(x - 40, y + 3*s + 1, x + 40, y + 20))
  c:fill(m, "#eef8f2")
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
function S.bird(c, x, y)   -- a drifting glow-moth: two gold dots and a cream spark
  c:px(x, y, "#f5cf6a"); c:px(x + 1, y, "#f5cf6a"); c:px(x + 3, y + 1, "#f5cf6a"); c:px(x + 2, y - 1, "#fff3c8")
end
return S
