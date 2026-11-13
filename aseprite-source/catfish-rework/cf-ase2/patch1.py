s=open('cats.lua').read()
def rep(a,b):
    global s
    assert s.count(a)==1,(a[:60],s.count(a))
    s=s.replace(a,b)
rep('''local function head(c, info, ox, oy, eyes, ears, fluff)
''','''local EAR_RT = { [2] = { 33, 34 }, [3] = { 32, 34 }, [4] = { 31, 32 }, [5] = { 30, 31 }, [6] = { 29, 32 }, [7] = { 26, 32 }, [8] = { 25, 32 }, [9] = { 24, 32 } }
local EYE_BORED = { ".......", ".......", "uuuuuuu", "ucuuucu", "ucuuucu", ".ucccu.", "..uuu.." }
local function head(c, info, ox, oy, eyes, ears, fluff, opts)
  opts = opts or {}
''')
rep("    earsM = L.spans(EAR_L, X0, oy):add(L.spans(EAR_R, X0, oy))","    earsM = L.spans(EAR_L, X0, oy):add(L.spans(opts.twitch and EAR_RT or EAR_R, X0, oy))")
rep('    c:put(X0 + 30, 5 + oy, \'L\', "detail")','    if not opts.twitch then c:put(X0 + 30, 5 + oy, \'L\', "detail") end')
rep('''    elseif eyes == "happy" then''','''    elseif eyes == "blink" then
      for dx = -2, 2 do c:put(cx + dx, cy, '#', "detail") end
      c:put(cx - 3, cy + 1, '#', "detail") c:put(cx + 3, cy + 1, '#', "detail")
    elseif eyes == "bored" then
      c:stamp(L.stamp(EYE_BORED, cx - 3, cy - 3))
    elseif eyes == "yawn" then
      local sg = (ex == 16) and 1 or -1
      for _, p in ipairs({ { -2, -2 }, { -1, -1 }, { 0, 0 }, { -1, 1 }, { -2, 2 } }) do c:put(cx + sg * p[1], cy + p[2], '#', "detail") end
    elseif eyes == "happy" then''')
rep('''  for _, p in ipairs(face) do c:put(p[1] + ox, p[2] + oy, p[3], "detail") prot:set(p[1] + ox, p[2] + oy) end''','''  for _, p in ipairs(face) do
    if not ((opts.mouth == "open" or opts.mouth == "smile") and p[2] >= 26 and p[1] >= 23 and p[1] <= 27) then
      c:put(p[1] + ox, p[2] + oy, p[3], "detail") prot:set(p[1] + ox, p[2] + oy)
    end
  end
  if opts.mouth == "open" or opts.mouth == "smile" then
    local big = opts.mouth == "open"
    local my, rx, ry = big and 29.5 or 27.8, big and 3.8 or 2.9, big and 3.4 or 1.9
    local mo = L.ellipse(25 + ox, my + oy, rx, ry)
    mo:grow(1):cut(mo):each(function(x, y) c:put(x, y, '#', "detail") prot:set(x, y) end)
    mo:each(function(x, y) c:put(x, y, 'P', "detail") prot:set(x, y) end)
    L.ellipse(25 + ox, my + ry * 0.55 + oy, rx * 0.62, ry * 0.5):clip(mo):each(function(x, y) c:put(x, y, 'p', "detail") end)
  elseif opts.mouth == "tongue" then
    for _, p in ipairs({ { 25, 27, 'p' }, { 25, 28, 'p' }, { 26, 28, 'P' } }) do c:put(p[1] + ox, p[2] + oy, p[3], "detail") prot:set(p[1] + ox, p[2] + oy) end
  end''')
rep("local function tailIdle(c, info, bob)","local function tailIdle(c, info, bob, pts0, tip0)")
rep('''  local pts = { { 36, 54 }, { 44, 55 }, { 50, 53 }, { 54, 48 }, { 55, 42 }, { 53, 36 }, { 52, 33 } }
  local m, T = L.tube(pts, BRUSH)
  c:part(m, { ws = 1, wl = 2 })
  info.tail, info.tailT, info.tailPts = m, T, pts
  tailTip(c, { { 52, 34, 'g' }, { 51, 35, 'L' }, { 52, 36, 'L' }, { 54, 37, 's' } })''','''  local pts = pts0 or { { 36, 54 }, { 44, 55 }, { 50, 53 }, { 54, 48 }, { 55, 42 }, { 53, 36 }, { 52, 33 } }
  local m, T = L.tube(pts, BRUSH)
  c:part(m, { ws = 1, wl = 2 })
  info.tail, info.tailT, info.tailPts = m, T, pts
  tailTip(c, tip0 or { { 52, 34, 'g' }, { 51, 35, 'L' }, { 52, 36, 'L' }, { 54, 37, 's' } })''')
a=s.index("CATS.idleA = function(o)")
b=s.index("CATS.catch = function(o)")
old=s[a:b]
new=old.replace('''CATS.idleA = function(o)
  local c, info = L.canvas(64, 64), { frame = "idleA", ox = 0, oy = 0 }''','''local function sit(o, cfg, frame)
  cfg = cfg or {}
  local hx, hy = cfg.hx or 0, cfg.hy or 0
  local c, info = L.canvas(64, 64), { frame = frame, ox = hx, oy = hy }''')
new=new.replace('tailIdle(c, info, o.tail == "bobtail")','tailIdle(c, info, o.tail == "bobtail", cfg.tailPts, cfg.tailTip)')
new=new.replace('  head(c, info, 0, 0, "open", o.ears, true)\n','  if cfg.armsUp then cfg.armsUp(c, info) end\n  head(c, info, hx, hy, cfg.eyes or "open", o.ears, true, cfg.opts)\n')
new=new.replace('  finish(c, info, 56)\n  return c, info\nend','  if cfg.arm then cfg.arm(c, info) end\n  finish(c, info, 56)\n  return c, info\nend\nCATS.idleA = function(o) return sit(o, {}, "idleA") end')
assert 'cfg.arm' in new and 'cfg.armsUp' in new and 'sit(o, {}' in new
s=s[:a]+new+s[b:]
open('cats.lua','w').write(s)
