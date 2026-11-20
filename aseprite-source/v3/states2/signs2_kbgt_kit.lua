-- pass 2 (SMALL signs) helpers for kitchen, beehive, greenhouse, tailor. Builds on signs_kbgt_common.lua.
local G = dofile("/tmp/ase/states2/signs_kbgt_common.lua")
local P, HP = G.P, G.HP
local px = G.px
G.NOSHADOW = (app.params.noshadow == "1")

-- shadow (skipped when noshadow=1, so the sprite box can be measured without it)
function G.shadow2(m, t) if not G.NOSHADOW then G.shadow(m, t) end end

-- small flat cleared plot: 2-tone earth + cut rim, a few speckles, no furrows
function G.miniPlot(x0, y0, x1, y1, seed)
  local E = G.EARTH
  local cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
  local rx, ry = (x1 - x0) / 2 + .5, (y1 - y0) / 2 + .5
  local m = HP.mask()
  for y = y0, y1 do for x = x0, x1 do
    local u, v = (x + .5 - cx - .5) / rx, (y + .5 - cy - .5) / ry
    if math.abs(u) ^ 3 + math.abs(v) ^ 3 <= 1.02 then m:set(x, y) end
  end end
  G.c:fillMask(m, E.base)
  local inner = m:shrink(1)
  inner:each(function(x, y)
    if not inner:has(x, y - 1) then px(x, y, E.dark)
    elseif not inner:has(x, y + 1) then px(x, y, E.lite) end
  end)
  m:edge():each(function(x, y) px(x, y, (y < cy + 1) and E.rim or E.dark) end)
  inner:each(function(x, y)
    if inner:has(x, y - 1) and inner:has(x, y + 1) then
      local h = G.hsh(x * 5 + seed, y * 3 + seed)
      if h < 6 then px(x, y, E.lite) elseif h > 94 then px(x, y, E.dark) end
    end
  end)
  G.plotMask = m
  return m
end

-- tiny corner stake: 1 px peg, 3 tall, ink rim; returns tie point (top)
function G.peg(x, yb)
  local m = G.c:rect(x, yb - 2, x, yb)
  G.ink(m) G.c:fillMask(m, P.wood.base) px(x, yb - 2, P.wood.hi) px(x, yb, P.wood.shade)
  return { x, yb - 2 }
end
function G.line1(a, b) G.seg(a[1], a[2], b[1], b[2], P.cream) end

-- S = { bl, br, fl, fr } peg bases. back: far line + side lines + far pegs. front: near line + near pegs.
function G.pegsBack(S)
  local t = function(p) return { p[1], p[2] - 2 } end
  G.line1(t(S[1]), t(S[2])) G.line1(t(S[1]), t(S[3])) G.line1(t(S[2]), t(S[4]))
  G.peg(S[1][1], S[1][2]) G.peg(S[2][1], S[2][2])
end
function G.pegsFront(S)
  G.line1({ S[3][1], S[3][2] - 2 }, { S[4][1], S[4][2] - 2 })
  G.peg(S[3][1], S[3][2]) G.peg(S[4][1], S[4][2])
end

function G.tinyTuft(x, y)   -- 3 wide, 2 tall, bottom centre (x, y)
  local M = P.moss
  px(x - 1, y, M.shade) px(x, y, M.base) px(x + 1, y, M.shade) px(x, y - 1, M.hi) px(x - 1, y - 1, M.base)
end
function G.tinyPebble(x, y) px(x, y, P.stone.hi) px(x + 1, y, P.stone.shade) end

-- flat plate: ink ring + fill (outer box x0..x0+22, y0..y0+8), optional corner cut
function G.plate(x0, y0, w, h, fill, cut)
  local m = G.c:rect(x0 + 1, y0 + 1, x0 + w - 2, y0 + h - 2)
  if cut then
    for _, q in ipairs(cut) do m:cut(G.pts{ q }) end
  end
  G.c:rim(m, G.INK)
  G.c:fillMask(m, fill)
  return m
end
return G
