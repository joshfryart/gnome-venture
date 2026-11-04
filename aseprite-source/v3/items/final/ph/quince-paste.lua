-- quince-paste (D10_5, redraw): a slab of ruby-amber membrillo in 3/4 view on a sheet of creased wax paper. The top is
-- glossy and scored with a fine diamond lattice, dusted with sugar; the cut front face glows from amber at the top to
-- ruby at the foot; the right side is deep garnet. A thin cut slice stands in front. Material: bevelled planes with a
-- bright top edge, jelly gradient, sugar grains, paper crease and a curled corner, contact shadow of the block.
-- quirk: a toothpick flag with a little quince-leaf pennant is stuck in the top.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_5.lua")
local B, HP, X, K, H = D.B, D.HP, D.X, D.K, D.H
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local c = D.new("quince-paste")
local hash = D.hash

local PA = { "#b8a878", "#d6c898", "#eadfb4", "#f8f0cc", "#fff8de", "#fffdf0" }
local QP = { "#4a1210", "#7a2418", "#a43a1c", "#cc5a22", "#ea7c30", "#ffa850" }
local LF = { "#1d4a30", "#2c6a3c", "#468a46", "#68aa50", "#8ec868", "#bce090" }

-- generic planar face with bevel; off = overall tone offset, grad(x,y) = extra
local function planar(m, ramp, off, grad, R)
  local n = X.pillow(m, R or 1.8)
  local v = X.light(n, { amb = 0.08, wrap = 0.25 })
  local v2 = {}
  for kk, val in pairs(v) do v2[kk] = val end
  m:each(function(x, y)
    local kk = K(x, y)
    v2[kk] = max(0, min(1, v[kk] + off + (grad and grad(x, y) or 0)))
  end)
  X.tone(c, m, v2, ramp, { cuts = { 0.26, 0.44, 0.6, 0.75, 0.88 } })
  return v2
end

-- ------------------------------------------------------------ wax paper
local paper = c:poly({ { 7, 53 }, { 13, 44 }, { 54, 44 }, { 52, 53 } })
c:groundShadow(30, 55, 23, 2)
planar(paper, PA, 0.05, function(x, y) return (y - 46) * 0.012 end, 1.5)
-- crease lines and printed dashes near the edge
for x = 19, 47, 6 do c:px(x, 45, PA[3]) c:px(x + 1, 45, PA[3]) end
B.ln(c, 23, 52, 29, 45, PA[2], paper)
B.ln(c, 43, 52, 46, 45, PA[2], paper)
-- curled lower-left corner
c:fillMask(c:poly({ { 7, 53 }, { 13, 50 }, { 13, 54 } }), PA[5])
c:px(13, 50, PA[6]) c:px(8, 53, PA[6]) c:px(13, 53, PA[1]) c:px(12, 53, PA[2]) c:px(11, 52, PA[3])

-- ------------------------------------------------------------ block (front / top / side)
local top = c:poly({ { 14, 31 }, { 23, 23 }, { 47, 23 }, { 38, 31 } })
local front = c:poly({ { 14, 31 }, { 38, 31 }, { 38, 47 }, { 14, 47 } })
local side = c:poly({ { 38, 31 }, { 47, 23 }, { 47, 39 }, { 38, 47 } })
-- contact shadow on paper, right and under the block
c:fillMask(c:poly({ { 14, 47 }, { 38, 47 }, { 47, 39 }, { 49, 41 }, { 40, 49 }, { 16, 49 } }), PA[1])
planar(front, QP, -0.06, function(x, y) return 0.12 - (y - 31) * 0.016 end)
planar(side, QP, -0.3, function(x, y) return 0.05 - (y - 23) * 0.008 end)
planar(top, QP, 0.3, function(x, y) return -(x - 30) * 0.004 end)
-- bright top-front edge and ambient foot
for x = 15, 37 do c:px(x, 31, QP[6]) end
for x = 14, 38 do c:px(x, 47, QP[2]) c:px(x, 46, hash(x, 1, 3) > 0.4 and QP[3] or QP[2]) end
-- jelly layer lines on the front face
for x = 16, 36 do if hash(x, 2, 5) > 0.5 then c:px(x, 38, QP[3]) end if hash(x, 3, 5) > 0.7 then c:px(x, 42, QP[2]) end end
-- inner glow: lighter patches of amber on the cut face
for _, p in ipairs({ { 18, 35 }, { 19, 35 }, { 26, 36 }, { 27, 36 }, { 28, 36 }, { 32, 34 } }) do c:px(p[1], p[2], QP[5]) end
-- right side edge highlight and grain
for y = 24, 38 do c:px(47, y, QP[2]) end
B.ln(c, 38, 31, 47, 23, QP[3])
-- diamond lattice on top
top:each(function(x, y)
  if (x + y) % 6 == 0 or (x - y) % 6 == 3 then c:px(x, y, QP[2]) end
end)
top:each(function(x, y)
  if ((x + y) % 6 == 1 or (x - y) % 6 == 4) and hash(x, y, 2) > 0.45 then c:px(x, y, QP[6]) end
end)
-- sugar dust
top:shrink(1):each(function(x, y) if hash(x, y, 9) < 0.07 then c:px(x, y, "#ffe6c4") end end)
front:each(function(x, y) if y < 34 and hash(x, y, 11) < 0.06 then c:px(x, y, "#ffd2a0") end end)
-- specular streak on the top (upper-left)
c:px(21, 26, "#fff4dc") c:px(22, 26, "#fff4dc") c:px(23, 26, "#fff4dc") c:px(20, 27, "#ffe2b8")

-- ------------------------------------------------------------ cut slice in front, lit more (fresh, translucent)
local sf = c:rect(41, 40, 52, 50)
local st = c:poly({ { 41, 40 }, { 44, 37 }, { 55, 37 }, { 52, 40 } })
local ss = c:poly({ { 52, 40 }, { 55, 37 }, { 55, 47 }, { 52, 50 } })
-- shadow of the slice
c:fillMask(c:poly({ { 41, 50 }, { 52, 50 }, { 55, 47 }, { 56, 49 }, { 53, 52 }, { 42, 52 } }):clip(paper), PA[1])
local SL = { "#5a1a14", "#8a2c1a", "#b84a22", "#e06a2c", "#ff9040", "#ffc070" }
planar(sf, SL, 0.1, function(x, y) return 0.12 - (y - 40) * 0.02 end, 1.5)
planar(ss, SL, -0.28, nil, 1.2)
planar(st, SL, 0.22, nil, 1.2)
for x = 42, 51 do c:px(x, 40, SL[6]) end
for x = 42, 51 do c:px(x, 49, SL[2]) end
c:px(43, 42, "#fff0cc") c:px(44, 42, "#ffd89a") c:px(48, 44, SL[5])
st:each(function(x, y) if (x + y) % 5 == 0 then c:px(x, y, SL[3]) end end)

-- ------------------------------------------------------------ toothpick flag (quirk)
local px_ = 30
for y = 12, 26 do c:px(px_, y, y % 4 == 0 and "#b88a4a" or "#e2bb78") end
c:px(px_, 27, "#7a3016") c:px(px_ - 1, 27, "#7a3016") c:px(px_ + 1, 27, QP[2]) c:px(px_ - 1, 26, QP[2])
local fl = B.ell(35.6, 14.2, 5.6, 2.8, -0.12)
fl:cut(c:rect(0, 0, px_, 63))
B.lit(c, fl, LF, 1.6)
B.ln(c, px_ + 1, 14, 40, 13, LF[6], fl)
c:px(41, 13, LF[3])
D.fin(c)
