-- shared helpers for the treehouse / yard / dressing scripts (hero scale, hard pixels, 1px dark edges, no text/circles/people/animals)
local C = {}
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
function C.setup(c)
  local S = {}
  function S.hash(x, y, s)
    x, y, s = floor(x), floor(y), floor(s or 0)
    local n = (x * 374761393 + y * 668265263 + s * 1013904223) & 0xffffffff
    n = ((n ~ (n >> 13)) * 1274126177) & 0xffffffff
    n = n ~ (n >> 16)
    return (n & 0xffff) / 65535
  end
  S.TIMB   = {"#2a1a22","#46282a","#643a30","#845236","#a46e44","#c48e5a"}
  S.OAK    = {"#30202a","#4e3230","#70483a","#946244","#b88058","#d8a474"}
  S.CREAM  = {"#5e4658","#8e7476","#bca290","#dcc4a6","#eed9b8","#f8eacc"}
  S.ROSE   = {"#4e2840","#7c4458","#aa6670","#cc8a88","#e6ae9e","#f6d0bc"}
  S.GREEN  = {"#1c3434","#2a5240","#3a704a","#529054","#78b064","#a8d080"}
  S.LEAF   = {"#26341c","#3a5222","#557228","#7a922e","#a4b444","#d0cc6a"}
  S.SBLUE  = {"#20264a","#323e6a","#46598a","#6076a4","#7e94bc","#a8b8d4"}
  S.BARN   = {"#38181e","#5c2428","#843230","#a6483a","#c66648","#e08c62"}
  S.GOLD   = {"#5a3a14","#8a5a1a","#bc8420","#e0aa2c","#f4cc4a","#fce67c"}
  S.STONE  = {"#382e40","#5a4e5c","#7a6e76","#9a8e90","#b8aca6","#d6cabc"}
  S.TEAL   = {"#14303a","#1e4a52","#2c686a","#408a84","#64aa9a","#94c8b2"}
  S.VIOLET = {"#2c2052","#443478","#5e4c9a","#7e68b8","#a290d0","#c8b8ec"}
  S.PINK   = {"#4e2840","#7c3c5c","#a85478","#d07494","#ec9ab4","#fac4d4"}
  S.DIRT   = {"#4a3428","#6a502e","#8a6a34","#a8863c","#c2a04a","#d8b862"}
  S.IRON   = {"#24202e","#3a3446","#545066","#727088","#9696a8","#bcbccc"}
  function S.rect(x0, y0, x1, y1) return c:rect(floor(x0), floor(y0), floor(x1), floor(y1)) end
  function S.rr(x0, y0, x1, y1, r) return c:rrect(floor(x0), floor(y0), floor(x1), floor(y1), r or 2) end
  function S.poly(t) local o = {} for i, p in ipairs(t) do o[i] = { floor(p[1] + .5), floor(p[2] + .5) } end return c:poly(o) end
  function S.tex(m, f) m:each(function(x, y) local col = f(x, y) if col then c:put(x, y, col) end end) end
  -- a solid chunky object: base, lit top/left, shaded bottom/right, 1px dark rim
  function S.obj(m, ramp, o)
    o = o or {}
    local b = o.base or 4
    local x0, y0, x1, y1 = m:bbox()
    c:rim(m, o.rim or ramp[1])
    S.tex(m, function(x, y)
      local lit = (y - y0 < (o.lit or 2)) or (x - x0 < 1)
      local sh = (y1 - y < (o.shade or 2)) or (x1 - x < 2)
      if lit and not sh then return ramp[min(6, b + 1)] end
      if sh then return ramp[max(1, b - 1)] end
      return ramp[b]
    end)
    return m
  end
  function S.planks(m, ramp, o)   -- vertical or horizontal boards with seams and a little grain
    o = o or {}
    local w, base, vert, s = o.w or 6, o.base or 4, o.vert ~= false, o.seed or 1
    S.tex(m, function(x, y)
      local a, b = vert and x or y, vert and y or x
      local k = floor(a / w); local p = a - k * w
      local tone = base + ((S.hash(k, 0, s) > .5) and 0 or -1)
      if p == 0 then return ramp[max(1, tone - 1)] end
      if S.hash(a, floor(b / 3), s + 3) > .93 then return ramp[max(1, tone - 1)] end
      if p == 1 then return ramp[min(6, tone + 1)] end
      return ramp[tone]
    end)
  end
  function S.glow(cx, cy, r, col, a, clip)  -- warm light: stepped, hard pixels
    local function mix(h1, h2, t)
      local function rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
      local r1,g1,b1 = rgb(h1); local r2,g2,b2 = rgb(h2)
      return string.format("#%02x%02x%02x", floor(r1+(r2-r1)*t+.5), floor(g1+(g2-g1)*t+.5), floor(b1+(b2-b1)*t+.5))
    end
    for y = cy - r, cy + r do for x = cx - r, cx + r do
      local d = math.sqrt((x-cx)^2 + ((y-cy)*1.2)^2) / r
      local cur = c:get(x, y)
      local inside = not clip or (x >= clip[1] and x <= clip[3] and y >= clip[2] and y <= clip[4])
      if d < 1 and cur and inside then c:put(x, y, mix(cur, col, a * floor((1-d)*3 + .999) / 3)) end
    end end
  end
  function S.diamond(cx, cy, r) return S.poly({{cx, cy - r}, {cx + r, cy}, {cx, cy + r}, {cx - r, cy}}) end
  return S
end
return C
