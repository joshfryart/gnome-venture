-- flood-boots: tall waxed green wellies, rolled tan cuff, a drip. quirk: a drop about to fall off the toe.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_gw.lua")
local HP, X, K, R = W.HP, W.X, W.K, W.R
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "flood-boots" }

local function boot(dx, dy, bias)
  local B = {}
  local shaft = c:poly{ {12+dx,16+dy}, {27+dx,16+dy}, {27+dx,40+dy}, {12+dx,42+dy} }
  local foot = c:rrect(12+dx, 37+dy, 30+dx, 49+dy, 3):add(c:ellipse(33+dx, 45+dy, 6, 4.5))
    :add(c:poly{ {24+dx,36+dy}, {30+dx,38+dy}, {36+dx,41+dy}, {27+dx,44+dy} })
  local body = shaft:copy():add(foot)
  local sole = c:rrect(11+dx, 49+dy, 40+dx, 52+dy, 1):cut(c:rect(20+dx, 52+dy, 26+dx, 52+dy))
  local cuff = c:rrect(10+dx, 11+dy, 28+dx, 18+dy, 2)
  B.body, B.sole, B.cuff, B.all = body, sole, cuff, body:copy():add(sole):add(cuff)
  B.paint = function()
    local bmap = {}
    if bias then body:each(function(x, y) bmap[K(x, y)] = bias end) end
    local idx = W.vcyl(c, shaft, R.welly, 12+dx, 27+dx, { bias = bmap, cuts = { .2, .36, .52, .7, .9 } })
    local fidx = W.lit(c, foot:copy():cut(shaft), R.welly, { R = 6, hs = 0.6, bias = bmap, cuts = { .2, .36, .52, .7, .9 } })
    -- ankle crease and toe-cap line
    W.put(c, { {22+dx,38+dy}, {23+dx,37+dy}, {24+dx,37+dy}, {25+dx,38+dy} }, R.welly[2])
    for x = 28+dx, 38+dx do if foot:has(x, 46+dy) then c:put(x, 46+dy, R.welly[2]) end end
    -- sole with tread notches
    local sidx = W.lit(c, sole, R.sole, { R = 1 })
    for x = 12+dx, 39+dx, 3 do c:put(x, 52+dy, R.sole[1]) end
    W.hline(c, 12+dx, 39+dx, 49+dy, R.sole[5])
    -- contact shadow under the cuff
    W.hline(c, 12+dx, 27+dx, 19+dy, R.welly[1 + (bias and 0 or 1)])
    -- rolled cuff: two rolls with a fold line
    local cbias = {}
    if bias then cuff:each(function(x, y) cbias[K(x, y)] = bias end) end
    W.lit(c, cuff, R.lining, { R = 2, bias = cbias })
    W.hline(c, 11+dx, 27+dx, 14+dy, R.lining[2])
    W.hline(c, 11+dx, 26+dx, 15+dy, R.lining[5 + (bias or 0)])
    return idx
  end
  return B
end

local back = boot(11, -5, -1)
local front = boot(0, 0, nil)
back.paint()
W.sep(c, front.all, back.all, W.ink)
front.paint()
-- waxed specular streak on the front shaft + toe
W.vline(c, 14, 21, 37, R.welly[6])
W.vline(c, 15, 23, 30, R.welly[6])
c:px(14, 22, W.cream) c:px(14, 23, W.cream)
c:px(31, 42, R.welly[6]) c:px(32, 42, R.welly[6]) c:px(30, 43, R.welly[5])
-- back boot streak (dimmer)
W.vline(c, 37, 22, 34, R.welly[2])
-- the drip: water running down from the cuff, pooling to a drop off the toe
for y = 19, 27 do c:px(20, y, R.water[y < 24 and 4 or 3]) end
c:px(20, 28, R.water[2]) c:px(19, 20, R.water[6])
local drop = c:poly{ {43.5,44}, {46,48.5}, {45.5,51}, {41.5,51}, {41,48.5} }
W.lit(c, drop, R.water, { R = 2 })
c:px(42, 49, W.cream)
W.save(c, "flood-boots")
