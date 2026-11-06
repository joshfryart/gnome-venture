-- buckwheat (final, Opus aB13_2 single pass). A slim flowering buckwheat sprig: thin red stem with a node kink,
-- two arrow-heart leaves on short petioles (midrib + swept veins, V-fold light), a dense top raceme of tiny
-- pink-white five-dot blossoms (sphere-lit, AO between them), and three dark triangular achenes ripening below it.
-- Material: waxy red stem with a pale lit line, glossy faceted achenes with a bright ridge, AO where leaves meet stem.
-- quirk: a tiny honeybee is visiting the top flowers (buckwheat honey).
local NAME = "buckwheat"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB13_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new(NAME)

local STEM = { "#44182c", "#6c2238", "#94303f", "#b84a4a", "#d8705c", "#f2a080" }
local LEAF = { "#173f36", "#23593f", "#317546", "#4a954d", "#70b457", "#a2d070" }
local FLW  = { "#8a4a6e", "#c27a9a", "#e6a6bc", "#f6cad6", "#fde6ea", "#fff6f2" }
local HULL = { "#24161c", "#3a2224", "#563226", "#76482e", "#9c683e", "#c99660" }
local stok, ltok = { r = { name = "stem" } }, { r = { name = "leaf" } }

-- main stem: base to raceme, slight S
local stem, _, ST, SS = A.stem(c, { { 30, 55 }, { 27, 43 }, { 34, 28 }, { 32, 14 } }, function(t) return 1.35 - t * 0.35 end, STEM, { tok = stok })
-- lit waxy line on the stem
stem:each(function(x, y) local k = K(x, y) if SS[k] < -0.35 and SS[k] > -0.75 and ST[k] > 0.05 and ST[k] < 0.9 then c:put(x, y, STEM[6], stok) end end)
-- side branch to a small lower raceme
local br = A.stem(c, { { 29, 35 }, { 26, 33 }, { 23, 31 }, { 21, 27 } }, function(t) return 0.9 end, STEM, { tok = stok, cut = stem })

-- leaves: petiole + arrow-heart blade
local function hleaf(pts, base, ctl, tip, W, flip)
  local pm = A.stem(c, pts, function() return 0.7 end, STEM, { tok = stok, cut = stem })
  local m, n, T, S, len, lb = A.heart(base[1], base[2], ctl[1], ctl[2], tip[1], tip[2], W, 2.4)
  m:cut(stem)
  local bias = {}
  X.ao(bias, m, stem, 1, -1)
  local idx = A.shade(c, m, n, LEAF, { amb = 0.12, wrap = 0.28, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = ltok, bias = bias })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if lb:has(x, y) then return end
    if abs(s) < 0.15 and t < 0.9 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok)
    elseif t > 0.08 and t < 0.8 and abs(s) > 0.3 and abs(s) < 0.75 then
      local d = (t * len - abs(s) * W * 1.2) % 3.6
      if d < 0.9 then c:put(x, y, s < 0 and LEAF[min(6, (idx[k] or 3) + 1)] or LEAF[max(1, (idx[k] or 3) - 1)], ltok) end
    end
  end)
  -- cool reflected edge lower-right
  m:edge():each(function(x, y) local k = K(x, y) if S[k] and S[k] > 0.7 and T[k] > 0.2 and T[k] < 0.85 then c:put(x, y, "#3c6e74", ltok) end end)
  return m
end
local L1 = hleaf({ { 28, 45 }, { 25, 45 }, { 22, 46 }, { 20, 46 } }, { 20, 46 }, { 13, 47 }, { 8, 53 }, 4.8)
local L2 = hleaf({ { 33, 26 }, { 36, 25 }, { 39, 25 }, { 41, 25 } }, { 41, 25 }, { 48, 25 }, { 56, 31 }, 4.4)

-- raceme: blossoms as small spheres (top) + one small lower cluster on the branch
local function cluster(list, sep)
  local all = HP.mask()
  for i, b in ipairs(list) do
    local m = c:ellipse(b[1], b[2], b[3], b[3]):cut(all)
    local bias = {}
    if i > 1 then X.ao(bias, m, all, 1, -1) end
    local n = X.sphere(b[1] - 0.3, b[2] - 0.3, b[3], m)
    local idx = A.shade(c, m, n, FLW, { amb = 0.1, wrap = 0.3, bias = bias, tok = { r = { name = "flw" .. i } } })
    -- five-dot blossom eye: green-gold centre
    if b[3] >= 1.5 then c:px(floor(b[1] + 0.5), floor(b[2] + 0.5), "#c9b04a") end
    all:add(m)
  end
  return all
end
local top = cluster({ { 32, 11, 2 }, { 29, 14, 1.6 }, { 35, 14, 1.6 }, { 31, 17, 1.6 }, { 35, 18, 1.5 }, { 28, 19, 1.5 }, { 33, 7, 1.5 }, { 29, 9, 1.4 }, { 36, 10, 1.4 } })
local low = cluster({ { 20, 25, 1.6 }, { 17, 27, 1.4 }, { 22, 22, 1.4 }, { 18, 23, 1.3 } })

-- achenes ripening on the stem below the raceme
local function achene(p, tilt)
  local m, F, n = A.tri(p, nil, 0.9)
  m:cut(top)
  local idx = A.shade(c, m, n, HULL, { amb = 0.08, wrap = 0.2, cuts = { 0.25, 0.42, 0.58, 0.74, 0.9 }, tok = { r = { name = "ach" } } })
  -- bright ridge where lit facets meet
  m:each(function(x, y) local k = K(x, y)
    local f = F[k]
    for _, d in ipairs{ { 1, 0 }, { 0, 1 } } do local q = F[K(x + d[1], y + d[2])]
      if q and q ~= f and (idx[k] or 1) >= 3 then c:put(x, y, HULL[min(6, idx[k] + 2)], { r = { name = "ach" } }) end end
  end)
  return m
end
achene({ { 37, 16 }, { 43, 17 }, { 39, 24 } })
achene({ { 22, 12 }, { 28, 12 }, { 24, 19 } })
achene({ { 15, 30 }, { 21, 30 }, { 17, 37 } })

-- quirk: honeybee on the top flowers (wings cream-blue, striped body)
local bee = {
  ".ww..",
  "wwww.",
  "ybyby",
  ".byb.",
}
A.map(c, bee, 39, 7, { w = "#e8f4ff", y = "#f5b82e", b = "#3a2430" }, { r = { name = "bee" } })
c:px(40, 9, "#ffe38a") c:px(44, 9, "#2b1c26")

-- specular glint on the top blossom
c:px(31, 10, FLW[6])
A.save(c, NAME)
