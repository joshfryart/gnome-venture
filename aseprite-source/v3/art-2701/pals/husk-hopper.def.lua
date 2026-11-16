-- Husk Hopper (bloomcaller): a tree-frog that lives in a corn husk. Quirk: one husk leaf flopped over its head like a hat.
return function(H)
  local c, P = H.c, H.P
  H.shadow(32, 59, 17, 2)
  -- big back feet
  c:part(H.E(18, 55, 7, 3), "moss", { band = 1 })
  c:part(H.E(46, 55, 7, 3), "moss", { band = 1 })
  -- husk behind and around
  c:part(H.Pg({ {10,56},{14,26},{22,40},{20,56} }), "gold")
  c:part(H.Pg({ {54,56},{50,26},{42,40},{44,56} }), "gold")
  c:part(H.Pg({ {20,58},{32,22},{44,58} }), "gold", { band = 3 })
  -- body
  c:part(H.E(32, 44, 13, 12), "moss")
  c:part(H.E(32, 50, 8, 6), "moss", { noshade = true, nopop = true })
  c:fillMask(H.E(32, 51, 6, 4), P.moss.hi)
  -- head
  c:part(H.E(32, 32, 11, 9), "moss")
  -- eye bumps
  c:part(H.E(24, 24, 5, 5), "moss", { band = 1 })
  c:part(H.E(40, 24, 5, 5), "moss", { band = 1 })
  H.eye(24, 24) H.eye(40, 24)
  -- husk hat leaf
  c:part(H.Pg({ {26,18},{46,12},{50,20},{38,20},{30,24} }), "gold", { band = 1 })
  if H.big then for i = 0, 3 do c:px(H.S(30 + i * 4), H.S(18 - i), P.gold.deep) end end
  c:px(H.S(30), H.S(37), P.moss.deep) c:px(H.S(34), H.S(37), P.moss.deep) c:px(H.S(31), H.S(38), P.moss.deep) c:px(H.S(33), H.S(38), P.moss.deep)
  H.cheek(21, 33) H.cheek(41, 33)
  -- husk ribs
  if H.big then for _, x in ipairs{14,17,50,47} do c:line({ {H.S(x), H.S(46)}, {H.S(x), H.S(55)} }, 1) end end
end
