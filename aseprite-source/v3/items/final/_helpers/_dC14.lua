-- dC14 helper: thin layer over batch2/_b2.lua (+ batch1/_h.lua). Not editing shared files.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local D = { B = B, H = H, HP = HP, X = X, K = B.K, P = H.P, INK = "#2b1c26", CREAM = "#fff4d6", GLINT = "#fff4d6" }
D.new, D.lit, D.ell, D.ln, D.polyline, D.leaf, D.cyl, D.sweep, D.ramp, D.blade = B.new, B.lit, B.ell, B.ln, B.polyline, H.leaf, H.cyl, H.sweep, H.ramp, B.blade
function D.fin() H.fin(B.c) end
-- heart mask centred cx,cy (tip down), width w, height h
function D.heart(c, cx, cy, w, h)
  local m = B.ell(cx - w * .24, cy - h * .18, w * .28, h * .3, 0)
  m:add(B.ell(cx + w * .24, cy - h * .18, w * .28, h * .3, 0))
  m:add(c:poly{ { cx - w * .5, cy - h * .12 }, { cx + w * .5, cy - h * .12 }, { cx, cy + h * .5 } })
  return m
end
-- lit scrap leaf with a midrib polyline (pts) in hex pair
function D.scrap(c, m, ramp, R, rib, ribhex)
  local r = H.ramp(ramp)
  B.lit(c, m, r, R or 4)
  if rib then B.polyline(c, rib, ribhex or r[6], m) end
  return m
end
-- seed lit with contact shadow clipped to leaf mask
function D.seed(c, leaf, cx, cy, rx, ry, ang, ramp, shadow, glint)
  local sm = B.ell(cx + 1, cy + 1.2, rx + .3, ry + .3, ang) sm:clip(leaf)
  c:fillMask(sm, shadow or "#1f553f")
  local m = B.ell(cx, cy, rx, ry, ang)
  B.lit(c, m, ramp, min(rx, ry) + .6)
  if glint ~= false then c:px(floor(cx - rx * .35), floor(cy - ry * .45), glint or D.GLINT) end
  return m
end
-- fixed ramps
D.R = {
  kelp = { "#2e2e18", "#46461f", "#646427", "#868634", "#aaa64c", "#cfca7c" },
  red  = { "#2e1220", "#4e1a2a", "#7a2431", "#a53a3c", "#c9584a", "#e88a6c" },
  tan  = { "#4a3322", "#6e4d30", "#946a3e", "#b98a52", "#d9ad72", "#f0d09a" },
  leaf = { "#123a3c", "#1a5a4b", "#247b55", "#3a9c5f", "#64be6c", "#a2dc86" },
  leaf2 = { "#18483f", "#246c4f", "#32905a", "#52b264", "#86d276", "#bfeb98" },
  glass = { "#4a6e86", "#6a9bb0", "#8fc4d0", "#b4e2e4", "#d4f2ee", "#f0fff6" },
  purple = { "#35204f", "#522f76", "#70429a", "#8f5cb8", "#b080d4", "#d3aaec" },
  yellow = { "#7a4a14", "#a8701c", "#d09a24", "#eebe34", "#f8d85a", "#fff0a0" },
  iron = { "#1e1a2a", "#32304a", "#4a4a66", "#66667f", "#8a8aa0", "#b4b4c6" },
  amber = { "#4a1e12", "#7a3416", "#a8501c", "#d07a28", "#eca43c", "#fcd070" },
}
-- cottage builder. o: x0,x1,yt,yb (wall), ay (roof apex y), ov (overhang), roof, wall (ramps), chx (chimney x), door={x,w,h}, wins={{x,y,w,h},..}
function D.cottage(c, o)
  local HP = D.HP
  local STONE = D.P.stone
  c:groundShadow((o.x0 + o.x1) / 2, o.yb + 1, (o.x1 - o.x0) / 2 + 4, 3)
  if o.chx then
    local cht = math.max(5, o.ay - 6)
    local ch = c:rect(o.chx, cht, o.chx + 5, o.yt - 4)
    D.lit(c, ch, { "#2a2a3e", "#444663", "#5e607a", "#74758c", "#9a9ab0", "#c2c2d0" }, 2)
    c:fillMask(c:rect(o.chx - 1, cht - 2, o.chx + 6, cht), "#9a9ab0")
    D.ln(c, o.chx - 1, cht, o.chx + 6, cht, "#444663")
  end
  local wall = c:rect(o.x0, o.yt, o.x1, o.yb)
  D.lit(c, wall, o.wall, 5)
  for y = o.yt + 4, o.yb - 2, 4 do D.ln(c, o.x0 + 1, y, o.x1 - 1, y, o.wall[2], wall) D.ln(c, o.x0 + 1, y - 1, o.x1 - 1, y - 1, o.wall[5], wall) end
  local cx = (o.x0 + o.x1) / 2
  local roof = c:poly{ { cx, o.ay }, { o.x1 + o.ov, o.yt + 1 }, { o.x0 - o.ov, o.yt + 1 } }
  D.lit(c, roof, o.roof, 6)
  for y = o.ay + 4, o.yt, 4 do D.ln(c, math.floor(cx - (y - o.ay) * (cx - o.x0 + o.ov) / (o.yt - o.ay)), y, math.floor(cx + (y - o.ay) * (o.x1 - cx + o.ov) / (o.yt - o.ay)), y, o.roof[2], roof) end
  D.ln(c, o.x0 - o.ov, o.yt + 1, o.x1 + o.ov, o.yt + 1, o.roof[1])
  if o.door then
    local d = o.door
    local dm = c:rect(d[1], o.yb - d[3], d[1] + d[2] - 1, o.yb) dm:add(D.ell(d[1] + d[2] / 2 - .5, o.yb - d[3] + 1, d[2] / 2, 2.5, 0))
    D.lit(c, dm, d.ramp or D.P.wood and { "#2a1a1e", "#51302b", "#6e4030", "#864c33", "#a0663e", "#c08a56" }, 3)
    c:px(d[1] + d[2] - 2, o.yb - 3, "#ffe38a")
  end
  for _, w in ipairs(o.wins or {}) do
    local wm = c:rect(w[1], w[2], w[1] + w[3] - 1, w[2] + w[4] - 1)
    D.lit(c, wm, o.glass or { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fff0b0", "#fffadc" }, 2)
    D.ln(c, w[1] + math.floor(w[3] / 2), w[2], w[1] + math.floor(w[3] / 2), w[2] + w[4] - 1, "#51302b")
    D.ln(c, w[1], w[2] + math.floor(w[4] / 2), w[1] + w[3] - 1, w[2] + math.floor(w[4] / 2), "#51302b")
    c:px(w[1] - 1, w[2], "#51302b") c:px(w[1] + w[3], w[2], "#51302b")
  end
  return wall, roof
end
return D
