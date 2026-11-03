-- ico-snowflake first draft. six-armed ice crystal with side branches. quirk: a single drop melts off the lowest arm tip
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("ico-snowflake")
local cx, cy = 32, 30
local m = c:ellipse(cx, cy, 6, 6)
for k = 0, 5 do
  local a = k * pi / 3 - pi / 2
  local function P(r, off, side)
    return { floor(cx + cos(a) * r - sin(a) * off * (side or 0) + .5), floor(cy + sin(a) * r + cos(a) * off * (side or 0) + .5) }
  end
  m:add(c:line({ P(0, 0), P(24, 0) }, 3))
  for _, r in ipairs{ 11, 17 } do
    for _, s in ipairs{ -1, 1 } do
      m:add(c:line({ P(r, 0), P(r + 6, 6 + (r > 12 and -2 or 0), s) }, 3))
    end
  end
end
m:clip(c:rect(5, 3, 58, 58))
D.lit(c, m, D.ICE, 3)
D.lit(c, c:ellipse(cx, cy, 4, 4), D.ICE, 2)
c:px(30, 28, "#ffffff" == "" and "" or "#f0fdff") c:px(31, 28, "#f0fdff")
c:sparkle(52, 9)
-- drop
D.lit(c, c:poly{ {32, 53}, {30, 58}, {31, 60}, {33, 60}, {34, 58} }, D.ICE, 1)
D.fin()
