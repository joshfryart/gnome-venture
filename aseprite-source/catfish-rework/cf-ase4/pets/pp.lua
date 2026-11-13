-- pp.lua: pet-item helpers on top of h3/cflib
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(DIR .. "/h3.lua")
local L = H.L
local P = { H = H, L = L, DIR = DIR }
local R = H.R
for k, v in pairs(H) do if type(v) == "table" and v.m and v.D then P[k] = v end end
P.CLAY = R("#4a1f1c", "#8a3a2a", "#c0613a", "#d98050", "#ec9f6c", "#ffd0a0")
P.LIME = R("#16422a", "#2c7a38", "#58a83e", "#86c850", "#b0e070", "#e8ffb0")
P.SAND = R("#6a4a3a", "#b08a62", "#dcb884", "#ecd0a0", "#f6e2b8", "#fff6dc")
P.IVORY = R("#8a6a70", "#d8c4b0", "#f6ead2", "#fff4e0", "#fffaf0", "#ffffff")
P.AQUA = R("#14405a", "#2a78a0", "#46a8d0", "#78ccec", "#a8e4f8", "#e8fbff")
P.CORAL = R("#7a2a3a", "#c4485a", "#ee6a6a", "#f88a80", "#ffb0a0", "#ffe4d8")
P.MAROON = R("#3a1020", "#701c38", "#a02c48", "#c4465a", "#e06a74", "#ffb0b0")
P.DEEP = R("#2a1a3a", "#4a3070", "#6a48a0", "#8a68c4", "#aa8ee0", "#d8c8ff")
P.MINT = R("#1a4a44", "#2a8a78", "#4cc0a4", "#80e0c0", "#b0f4dc", "#f0fff8")
P.LEMON = R("#7a5a10", "#c8a020", "#f0d030", "#f8e458", "#fff080", "#fffbd0")
function P.new(w, h) local c = H.new(w, h) return c end
function P.part(c, m, ramp, ws, wl, o) H.part(c, m, ramp, ws or 1, wl or 1, o) end
P.px, P.sep, P.rrect, P.leaf = H.px, H.sep, H.rrect, H.leaf
P.E = L.ellipse
P.RC = L.rect
P.poly = L.poly
function P.lathe(cx, y0, ws)  -- half widths per row; cx may be .5 for symmetric
  local m = L.mask()
  for i, w in ipairs(ws) do for x = cx - w, cx + w - 1 do m:set(x, y0 + i - 1) end end
  return m
end
function P.ln(c, pts, col, m) local q = {} for i, p in ipairs(pts) do q[i] = { math.floor(p[1] + 0.5), math.floor(p[2] + 0.5) } end L.line(q):each(function(x, y) if not m or m:has(x, y) then c:put(x, y, col, "detail") end end) end
function P.fillm(c, m, col, lay) m:each(function(x, y) c:put(x, y, col, lay or "detail") end) end
function P.finish(c, name, w, h)
  assert(c.w == w and c.h == h)
  H.finish(c, name)
end
return P
