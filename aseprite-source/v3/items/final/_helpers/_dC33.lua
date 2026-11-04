-- _dC33: helper for chunk C3 (pear-seed .. pickled-asparagus). Wraps batch2/_b2.lua (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X, K = B.H, B.HP, B.X, B.K
local P = H.P
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local D = { B = B, H = H, HP = HP, X = X, P = P }
D.INK, D.CREAM = P.ink, P.cream
function D.new(name) return B.new(name) end
function D.fin() B.fin() end
function D.mix(a, b, t) return H.mix(a, b, t) end
-- 6-tone ramp from 4 hex (hi base shade deep) or from a named ramp
function D.R(r) return H.ramp(r) end
function D.rampHex(deep, shade, base, hi) return { deep = deep, shade = shade, base = base, hi = hi } end
-- leaf scrap + optional veins. cfg {ax,ay,bx,by,w,ramp,veins}
function D.scrap(c, cfg)
  return B.blade(c, cfg[1], cfg[2], cfg[3], cfg[4], cfg[5], cfg.ramp, { veins = cfg.veins or { 6, 12, 18, 24, 30, 36 }, slant = cfg.slant, prof = cfg.prof })
end
-- 2px stem line
function D.stem(c, x0, y0, x1, y1, hex, hex2)
  B.ln(c, x0, y0, x1, y1, hex)
  B.ln(c, x0 + 1, y0, x1 + 1, y1, hex2 or hex)
end
-- small contact shadow under a seed (cool dark ellipse), then seed lit
function D.seed(c, cx, cy, rx, ry, ang, ramp, shadow, glint)
  return B.seed(c, cx, cy, rx, ry, ang, ramp, shadow, glint)
end
-- tiny round dot (2x2) with glint
function D.dot(c, x, y, ramp, shadow)
  c:px(x + 1, y + 1, shadow or "#1f553f")
  local m = c:rect(x, y, x + 1, y + 1)
  c:px(x, y, ramp[5] or ramp[4]) c:px(x + 1, y, ramp[4]) c:px(x, y + 1, ramp[3]) c:px(x + 1, y + 1, ramp[2])
  return m
end
-- sprout: stem then leaves {ax,ay,bx,by,w,veins}
function D.sprout(c, st, leaves, ramp, stemHex)
  D.stem(c, st[1], st[2], st[3], st[4], stemHex or "#4f9f52", stemHex and D.mix(stemHex, "#2b1c26", .3) or "#2e7646")
  for _, L in ipairs(leaves) do
    B.blade(c, L[1], L[2], L[3], L[4], L[5], ramp, { veins = L[6] or { 3, 6, 9 }, slant = L.slant })
  end
end
-- vertical-axis glass jar: body x0..x1, y0..y1, round bottom corners. returns mask
function D.jarBody(c, x0, y0, x1, y1, r, glass)
  local m = c:rrect(x0, y0, x1, y1, r)
  return m
end
-- simple lit rect-ish wood plank (horizontal or vertical), returns mask
function D.plank(c, x0, y0, x1, y1, ramp, o)
  local m = c:rect(x0, y0, x1, y1)
  c:part(m, ramp, o or { nopop = true })
  return m
end

-- glass jar: body rrect + neck; returns body, inner masks. o {x0,y0,x1,y1,r,nx0,nx1,ny0}
D.GLASS = { "#3a5688", "#6a92c0", "#9cc8e4", "#c4e6f4", "#e4f6ff", "#fffaf0" }
function D.jar(c, o)
  local body = c:rrect(o.x0, o.y0, o.x1, o.y1, o.r or 4)
  body:add(c:rect(o.nx0, o.ny0, o.nx1, o.y0 + 3))
  H.vcyl(c, body, D.GLASS, o.x0 - 1, o.x1 + 1, { amb = .15, wrap = .3 })
  return body, body:shrink(1)
end
-- glass sheen over contents: bright column on the lit side + faint bounce on the dark side
function D.sheen(c, body, x0, x1, y0, y1)
  for y = y0, y1 do c:px(x0, y, D.GLASS[6]) end
  c:px(x0, y0 - 1, D.GLASS[5]) c:px(x0, y1 + 1, D.GLASS[5])
  for y = y0 + 3, y1 - 2 do if (y % 2) == 0 then c:px(x1, y, D.GLASS[3]) end end
end
-- fence helpers (plan view with a little height)
D.PALE = { hi = "#fff4d6", base = "#f2dcae", shade = "#c89a6a", deep = "#8a5a3a" }
D.WOOD = P.wood
function D.picketH(c, x, yc, w)   -- one picket seen from above on a horizontal run
  local m = c:rect(x, yc - 3, x + (w or 3), yc + 2)
  c:part(m, D.PALE, { nopop = true, band = 1 })
  c:px(x, yc - 3, "#fffaf0")
  return m
end
function D.picketV(c, xc, y, w)
  local m = c:rect(xc - 3, y, xc + 2, y + (w or 3))
  c:part(m, D.PALE, { nopop = true, band = 1 })
  c:px(xc - 3, y, "#fffaf0")
  return m
end
function D.runH(c, x0, x1, yc, skip)
  c:part(c:rect(x0, yc - 1, x1, yc), D.WOOD, { nopop = true, band = 1 })
  local i = 0
  for x = x0, x1 - 3, 6 do
    if not (skip and skip[i]) then D.picketH(c, x, yc) end
    i = i + 1
  end
end
function D.runV(c, xc, y0, y1, skip)
  c:part(c:rect(xc - 1, y0, xc, y1), D.WOOD, { nopop = true, band = 1 })
  local i = 0
  for y = y0, y1 - 3, 6 do
    if not (skip and skip[i]) then D.picketV(c, xc, y) end
    i = i + 1
  end
end
-- post 8x8 at top-left (x,y) with a paler cap and a nail
function D.post(c, x, y)
  local m = c:rect(x, y, x + 7, y + 7)
  c:part(m, D.WOOD, { band = 2 })
  local cap = c:rect(x + 1, y + 1, x + 6, y + 6)
  c:part(cap, D.PALE, { band = 2 })
  c:px(x + 3, y + 3, "#8a5a3a") c:px(x + 4, y + 3, "#f5b82e")
  return m
end
function D.ladybug(c, x, y)
  c:fillMask(c:rect(x, y, x + 2, y + 2), "#e8493b") c:px(x + 1, y, "#2b1c26") c:px(x, y + 1, "#2b1c26") c:px(x + 2, y + 2, "#2b1c26") c:px(x, y, "#ff8a5c")
end
function D.tuft(c, x, y)
  for _, p in ipairs{ { 0, 0 }, { 1, -1 }, { 2, 0 }, { 3, -2 }, { 1, 0 }, { 3, -1 } } do c:px(x + p[1], y + p[2], p[2] < -1 and "#a8d870" or "#3f9150") end
end
return D
