-- _dB25.lua: helpers for first-draft items durian .. elderberry-seed (wraps _dB23 -> batch2/_b2.lua, edits nothing shared)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dB23.lua")
local H, HP, X = D.H, D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local rp = D.rp
-- seeds with tiny dark contact shadow on a leaf scrap; list of {cx,cy,rx,ry,ang}
function D.seeds(list, ramp, o)
  o = o or {}
  local ms = {}
  for i, s in ipairs(list) do ms[i] = D.seed(s[1], s[2], s[3], s[4], s[5] or 0, ramp, o) end
  return ms
end
-- sprout: stem polyline pts, then leaves {cx,cy,rx,ry,ang}
function D.sprout(pts, stemLt, stemDk, leaves, ramp, rib)
  D.stem(pts, stemLt, stemDk, 1)
  for _, L in ipairs(leaves) do D.leaf(L[1], L[2], L[3], L[4], L[5], ramp, rib) end
end
-- tapered swept shape lit as ramp; pts = 4 bezier points, wfn(t) half width
function D.tube(pts, wfn, ramp, R)
  local m, T = H.sweep(pts, wfn, 70)
  D.blob(m, ramp, R or 3)
  return m, T
end
-- small round berry/bead with light
function D.bead(cx, cy, r, ramp, glint)
  local m = D.el(cx, cy, r, r, 0, ramp, r + .4)
  if glint then D.cv():px(floor(cx - r * .4), floor(cy - r * .5), glint) end
  return m
end
function D.cv() return getmetatable(D).__index.c end
return D
