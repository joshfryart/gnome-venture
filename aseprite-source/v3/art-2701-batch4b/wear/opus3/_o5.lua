-- _o5.lua: helpers for the Opus richness pass (opus3) on the batch4b wear rank icons, 64x64.
-- Reuses ../opus2/_o4.lua (load, get, px, paint, reink, wool, graft, save4) and points output at this folder.
-- Every icon loads its opus2 PNG read only and hand-places pixels on top.
-- Added here:
--   O.ramp(list)              -> index lookup for a light-to-dark hue-shifted ramp
--   O.step(img,x,y,R,d)       move one pixel d tones along ramp R (only if it is on R)
--   O.rimbounce(img,R,box,o)  lit rim on edges facing the upper left, bounce colour on edges facing lower right
--   O.texture(img,R,box,fn,o) per-pixel tone step from fn(x,y) (weave, grain, twill), ramp pixels only
--   O.safe(fn)                predicate guard (patch / quirk zones stay untouched)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/../opus2/_o4.lua")
O.OUT = (app.params and app.params.out) or (DIR .. "/")
O.OP2 = DIR .. "/../opus2/"
O.ME = DIR .. "/"

function O.ramp(list)
  local R = { list = list, idx = {} }
  for i, h in ipairs(list) do R.idx[h] = i end
  return R
end
function O.step(img, x, y, R, d)
  local h = O.get(img, x, y)
  local i = h and R.idx[h]
  if not i then return false end
  local j = math.max(1, math.min(#R.list, i + d))
  O.px(img, x, y, R.list[j]); return true
end
local function edge(img, x, y) return not O.isBody(img, x, y) end
-- o: { ok=fn(x,y), rim=d (default -1), bounce=hex or nil, bounceStep=d, minRim=index cap }
function O.rimbounce(img, R, x0, y0, x1, y1, o)
  o = o or {}
  local ch = {}
  for y = y0, y1 do for x = x0, x1 do
    local h = O.get(img, x, y)
    if h and R.idx[h] and (not o.ok or o.ok(x, y)) then
      local i = R.idx[h]
      if (edge(img, x - 1, y) or edge(img, x, y - 1)) and not o.noRim then
        ch[#ch + 1] = { x, y, R.list[math.max(o.minRim or 1, i + (o.rim or -1))] }
      elseif (edge(img, x + 1, y) or edge(img, x, y + 1)) and o.bounce and (not o.bounceOk or o.bounceOk(x, y)) then
        ch[#ch + 1] = { x, y, o.bounce }
      end
    end
  end end
  for _, c in ipairs(ch) do O.px(img, c[1], c[2], c[3]) end
end
function O.texture(img, R, x0, y0, x1, y1, fn, ok)
  local ch = {}
  for y = y0, y1 do for x = x0, x1 do
    local h = O.get(img, x, y)
    if h and R.idx[h] and (not ok or ok(x, y)) then
      local d = fn(x, y, R.idx[h])
      if d and d ~= 0 then
        local j = math.max(1, math.min(#R.list, R.idx[h] + d)); ch[#ch + 1] = { x, y, R.list[j] }
      end
    end
  end end
  for _, c in ipairs(ch) do O.px(img, c[1], c[2], c[3]) end
end
-- a run of pixels with a pattern string ("hbbs" repeated) along a list of points, body pixels only
function O.cord(img, pts, pat, map, ok)
  for i, p in ipairs(pts) do
    if O.isBody(img, p[1], p[2]) and (not ok or ok(p[1], p[2])) then
      local k = (i - 1) % #pat + 1
      O.px(img, p[1], p[2], map[pat:sub(k, k)])
    end
  end
end
function O.hpts(x0, x1, y) local t = {} for x = x0, x1 do t[#t + 1] = { x, y } end return t end
-- felt / leather nap: a scatter of single pixels one tone lighter or darker, from a fixed hash (repeatable)
function O.nap(img, R, x0, y0, x1, y1, ok, rate)
  rate = rate or 9
  O.texture(img, R, x0, y0, x1, y1, function(x, y, i)
    local h = (x * 73 + y * 151 + x * y * 7) % (rate * 2)
    if h == 0 and i > 1 then return -1 elseif h == rate and i < #R.list then return 1 end
  end, ok)
end
-- 4-step distance to the outside (transparent or ink), capped at m
function O.dist(img, x, y, m)
  for d = 1, m do
    for dy = -d, d do for dx = -d, d do
      if math.abs(dx) + math.abs(dy) == d and not O.isBody(img, x + dx, y + dy) then return d end
    end end
  end
  return m + 1
end
return O
