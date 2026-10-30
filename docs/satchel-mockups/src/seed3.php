<?php $d=new PDO('sqlite:/tmp/pt/g/data/game.sqlite'); $d->setAttribute(PDO::ATTR_ERRMODE,PDO::ERRMODE_EXCEPTION);
$uid=2; $now=gmdate('Y-m-d H:i:s');
$give=function($slug,$n) use($d,$uid){ $id=$d->query("select id from items where slug=".$d->quote($slug))->fetchColumn(); if(!$id){echo "no $slug\n";return;}
 $d->prepare("insert into user_items(user_id,item_id,qty,got_at) values(?,?,?,datetime('now','-'||abs(random()%200)||' hours')) on conflict(user_id,item_id) do update set qty=max(qty,excluded.qty)")->execute([$uid,$id,$n]); };
$learn=function($cat,$n,$makeEvery) use($d,$uid,$now,$give){ $rs=$d->query("select id,ingredients,tier from recipes where category='$cat' order by (tier='feast') desc, id limit $n")->fetchAll(PDO::FETCH_ASSOC);
 if($cat==='cooking') $rs=$d->query("select id,ingredients,tier from recipes where category='cooking' order by case tier when 'feast' then 0 when 'snack' then 1 else 2 end, id")->fetchAll(PDO::FETCH_ASSOC);
 $rs=array_slice($rs,0,$n); $k=0;
 foreach($rs as $r){ $d->exec("insert or ignore into user_recipes (user_id,recipe_id,learned_at) values ($uid,{$r['id']},'$now')");
  if($k++%$makeEvery===0) foreach(json_decode($r['ingredients'],true) as $s=>$q) $give($s,$q*3); }
 echo "$cat ".count($rs)."\n"; };
$learn('cooking',46,9); $learn('tools',6,6); $learn('building',8,8); $learn('garden',8,8); $learn('decor',8,8);
// satchel variety
$names=$d->query("select slug from items where category='food' and slug not like 'feast%' order by id limit 4")->fetchAll(PDO::FETCH_COLUMN); foreach($names as $s) $give($s,2);
foreach($d->query("select slug from items where category='flower' order by id limit 3")->fetchAll(PDO::FETCH_COLUMN) as $s) $give($s,4);
foreach(['guide','broken','decor'] as $c) foreach($d->query("select slug from items where category='$c' order by id limit ".($c==='decor'?2:1))->fetchAll(PDO::FETCH_COLUMN) as $s) $give($s,1);
// pots
$d->exec("delete from cook_pots where user_id=$uid");
$rid=$d->query("select id from recipes where category='cooking' and tier='meal' limit 1")->fetchColumn();
$rid2=$d->query("select id from recipes where category='cooking' and tier='snack' limit 1")->fetchColumn();
$d->exec("insert into cook_pots(user_id,recipe_id,makes,dishes,started_at,ready_at) values ($uid,$rid,1,1,'$now','".gmdate('Y-m-d H:i:s',time()-60)."'),($uid,$rid2,2,2,'$now','".gmdate('Y-m-d H:i:s',time()+520)."')");
$plot=$d->query("select id from plots where user_id=$uid")->fetchColumn();
$d->exec("insert or ignore into garden_buildings (plot_id,building,built_at,level) values ($plot,'tool_shed','$now',1)");
$d->exec("update users set energy=40 where id=$uid");
echo $d->query("select count(*) from user_items where user_id=$uid")->fetchColumn()," kinds\n";
