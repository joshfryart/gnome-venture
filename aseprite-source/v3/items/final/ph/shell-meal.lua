-- shell-meal (D15, final pass, Sonnet). A slim, plump-bellied burlap sack with a thick rolled cuff, open at the top on a heap of
-- pearly pink-cream ground shell (nacre flecks in pink / mint / lilac, two curved shell shards poking out). A little wooden scoop
-- stands in the heap, its slim handle leaning up and to the right. A small spill of meal and one whole spiral shell sit at the
-- foot. Burlap: diagonal weave, vertical fold creases, a gold stitched bottom seam, per-pixel belly light with a cool bounce;
-- ambient rows under the cuff, in the mouth and where the shell leans on the sack.
-- quirk: a whole snail shell sits by the sack, showing what the meal was made from.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_3.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("shell-meal")

local BUR = { "#4a2e22", "#6e4530", "#946440", "#b8864f", "#d8ac6c", "#f0d296" }
local PEARL = { "#7a6684", "#a88e9e", "#d0b4b8", "#ecd4d0", "#fbeee2", "#fffaf0" }
local SHELL = { "#5a2e30", "#8a4a3a", "#c0764a", "#e6a066", "#f6c890", "#fff0cc" }
local WOOD = { "#2e1c1c", "#4f2d26", "#74422f", "#9a5d3a", "#bc8250", "#dcb07a" }
local btok, ptok, stok, wtok = { r = { name = "burlap" } }, { r = { name = "pearl" } }, { r = { name = "shell" } }, { r = { name = "wood" } }

c:groundShadow(32, 57, 21, 2.4)

-- sack body --------------------------------------------------------------------------------------------------------------------
local body = c:poly{ { 22, 32 }, { 42, 32 }, { 44, 37 }, { 46, 43 }, { 46, 49 }, { 44, 54 }, { 40, 56 }, { 24, 56 }, { 20, 54 }, { 18, 49 }, { 18, 43 }, { 20, 37 } }
local bn = G.body(body, 32, 46, 16, 7, 0.4)
local bbias = {}
-- ambient: darker row right under the cuff
body:each(function(x, y) if y <= 38 then bbias[K(x, y)] = (y <= 36) and -1 or 0 end end)
local bidx = G.shade(c, body, bn, BUR, { amb = 0.08, wrap = 0.3, bias = bbias, tok = btok })
local function bat(k, d) return BUR[max(1, min(6, (bidx[k] or 3) + d))] end
body:each(function(x, y) local k = K(x, y)
  if (x + y) % 4 == 0 then c:put(x, y, bat(k, -1), btok)
  elseif (x - y) % 6 == 0 then c:put(x, y, bat(k, 1), btok) end
end)
-- vertical fold creases
for _, cr in ipairs{ { 27, 0.0, 38, 54 }, { 38, 1.9, 37, 52 } } do
  for y = cr[3], cr[4] do
    local x = cr[1] + floor(1.3 * sin(y / 4.5 + cr[2]) + 0.5)
    if body:has(x, y) then c:px(x, y, bat(K(x, y), -2)) if body:has(x - 1, y) then c:px(x - 1, y, bat(K(x - 1, y), 1)) end end
  end
end
-- cool bounce on the lower right rim
do local rim = X.rim(bn)
  body:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.8 and x > 38 and y > 42 then c:put(x, y, "#a0586a", btok) end end) end
-- gold stitched bottom seam (2 on, 1 off)
c:stitch{ { 22, 52 }, { 27, 53 }, { 32, 53.5 }, { 37, 53 }, { 42, 52 } }

-- rolled cuff ------------------------------------------------------------------------------------------------------------------
local cuff = c:rrect(19, 27, 45, 35, 3)
local cn = {}
cuff:each(function(x, y)
  local t = max(-0.95, min(0.95, ((y - 27) / 8) * 2 - 1))
  local u = max(-0.95, min(0.95, ((x - 19) / 26) * 2 - 1))
  cn[K(x, y)] = { A.norm(u * 0.4, t * 0.8, sqrt(max(0.05, 1 - t * t * 0.64))) }
end)
local cidx = G.shade(c, cuff, cn, BUR, { amb = 0.14, wrap = 0.36, tok = btok })
cuff:each(function(x, y) local k = K(x, y)
  if (x + y) % 3 == 0 and y > 28 then c:put(x, y, BUR[max(1, (cidx[k] or 3) - 1)], btok) end
  if (x - y) % 5 == 0 and y > 28 then c:put(x, y, BUR[min(6, (cidx[k] or 3) + 1)], btok) end
end)
-- roll seam line + fold shade at the bottom of the cuff
for x = 19, 45 do if cuff:has(x, 34) then c:px(x, 34, BUR[2]) end end
for x = 20, 44 do if cuff:has(x, 35) then c:px(x, 35, BUR[1]) end end
for x = 20, 44 do if cuff:has(x, 28) and x < 33 then c:px(x, 28, BUR[6]) end end

-- mouth + heap ---------------------------------------------------------------------------------------------------------------
local mouth = c:ellipse(32, 27.5, 10.8, 3.0)
mouth:each(function(x, y) c:px(x, y, (y > 27) and "#4a2a30" or "#6a3a3a") end)
local hm = c:ellipse(32, 24.5, 10.2, 6.8)
hm:cut(c:rect(0, 30, 63, 63))
local hnn = X.sphere(30, 28, 10.6, hm)
local hbias = {}
hm:each(function(x, y) if y >= 28 then hbias[K(x, y)] = -1 end end)
local hidx = G.shade(c, hm, hnn, PEARL, { amb = 0.16, wrap = 0.3, bias = hbias, tok = ptok })
-- nacre flecks: pink / mint / lilac, plus a few sparkles
hm:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 11)
  if h > 0.975 then c:put(x, y, "#f4a4bc", ptok) elseif h > 0.95 and (hidx[k] or 3) >= 3 then c:put(x, y, "#a4e0cc", ptok)
  elseif h < 0.02 then c:put(x, y, "#c4b0ee", ptok) end end)
-- crumbly texture on the shade side
hm:each(function(x, y) local k = K(x, y) if X.hash(x, y, 4) > 0.8 and (hidx[k] or 3) <= 4 then c:put(x, y, PEARL[max(1, (hidx[k] or 3) - 1)], ptok) end end)
c:px(27, 20, "#fffaf0") c:px(28, 20, "#fffaf0") c:px(25, 22, "#fff4d6")
-- shell shards: curved, with a ridge line and a nacre edge
local function shard(x0, y0, rows)
  for i, r in ipairs(rows) do
    for x = r[1], r[2] do
      local col = SHELL[3]
      if x == r[1] then col = SHELL[5] elseif x == r[2] then col = SHELL[2] elseif (x + i) % 3 == 0 then col = SHELL[4] end
      c:px(x0 + x, y0 + i - 1, col)
    end
  end
end
shard(34, 17, { { 0, 2 }, { 0, 4 }, { 1, 5 }, { 2, 5 }, { 3, 4 } })
shard(24, 21, { { 0, 3 }, { 0, 4 }, { 1, 4 }, { 2, 3 } })
shard(29, 25, { { 0, 2 }, { 0, 3 }, { 1, 2 } })
c:px(34, 17, SHELL[6]) c:px(24, 21, SHELL[6]) c:px(29, 25, SHELL[6])
-- ambient shadow where the heap meets the mouth rim
for x = 22, 42 do if hm:has(x, 29) then c:px(x, 29, "#7a5a6a") end end

-- scoop with a slim handle ------------------------------------------------------------------------------------------------------
local hmsk, hmn, HT, HS, hidx2 = G.stem(c, { { 33, 24 }, { 37, 20 }, { 41, 16 }, { 45, 12 } }, function(t) return 1.15 + 0.1 * t end, WOOD, { tok = wtok, amb = 0.1, wrap = 0.3 })
hmsk:each(function(x, y) local k = K(x, y)
  if abs(HS[k]) < 0.5 and X.hash(x, y, 8) > 0.82 then c:put(x, y, WOOD[max(1, (hidx2[k] or 3) - 1)], wtok) end end)
-- grip knob with a hanging hole
local knob = c:ellipse(46.5, 10.5, 2.2, 2.2)
G.shade(c, knob, X.sphere(46, 10, 2.5, knob), WOOD, { tok = wtok })
c:px(47, 10, WOOD[1])
c:px(45, 9, WOOD[6])
-- scoop bowl peeking out of the heap + heap dusted on it
c:px(32, 24, WOOD[3]) c:px(33, 25, WOOD[2]) c:px(31, 25, WOOD[4])
-- contact shadow of the handle on the heap
c:px(34, 24, "#8a6a7a") c:px(35, 23, "#8a6a7a")

-- spilled meal ------------------------------------------------------------------------------------------------------------------
local sp = c:ellipse(46, 55.5, 6.5, 2.5)
sp:cut(c:rect(0, 58, 63, 63))
local sidx = G.shade(c, sp, X.pillow(sp, 2.5), PEARL, { amb = 0.2, wrap = 0.3, tok = ptok })
sp:each(function(x, y) local h = X.hash(x, y, 21) if h > 0.9 then c:put(x, y, "#f4a4bc", ptok) elseif h < 0.06 then c:put(x, y, "#a4e0cc", ptok) end end)
c:px(47, 52, SHELL[3]) c:px(48, 52, SHELL[5]) c:px(47, 53, SHELL[2])
c:px(41, 57, PEARL[4]) c:px(52, 56, PEARL[3])

-- the whole spiral shell ------------------------------------------------------------------------------------------------------
local scx, scy = 15, 51
local shd = c:ellipse(scx + 1.4, scy + 2, 7, 5.4)
shd:each(function(x, y) if body:has(x, y) then c:px(x, y, BUR[1]) end end)
local sh = A.ell(scx, scy, 6.6, 6.0, 0.35)
local shn = G.body(sh, scx, scy, 6.4, 4, 0.85)
local shidx = G.shade(c, sh, shn, SHELL, { amb = 0.02, wrap = 0.12, cuts = { 0.3, 0.46, 0.62, 0.78, 0.92 }, tok = stok })
for i = 0, 420 do
  local th = i * 0.04
  local r = 0.5 + th * 0.37
  local x = floor(scx + 0.5 + cos(th + 1.0) * r + 0.5)
  local y = floor(scy + 0.5 + sin(th + 1.0) * r * 0.92 + 0.5)
  if sh:has(x, y) and r < 5.9 then c:px(x, y, SHELL[1])
    if sh:has(x - 1, y - 1) and not (cos(th + 1.0) > 0 and sin(th + 1.0) > 0) then c:px(x - 1, y - 1, SHELL[5]) end end
end
-- aperture opening at the lower right, dark with a cream lip
local ap = A.ell(scx + 3.8, scy + 3.4, 2.4, 1.8, 0.7):clip(sh)
ap:each(function(x, y) c:px(x, y, "#3a1a22") end)
ap:grow(1):cut(ap):each(function(x, y) if sh:has(x, y) and x + y < scx + scy + 7 then c:px(x, y, SHELL[6]) end end)
c:px(scx - 3, scy - 3, SHELL[6]) c:px(scx - 2, scy - 4, SHELL[6]) c:px(scx - 4, scy - 2, "#fff4d6")
-- tiny apex nub
c:px(scx - 1, scy - 1, SHELL[1])

A.save(c, "shell-meal")
