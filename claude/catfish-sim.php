<?php
// Balance sim: php claude/catfish-sim.php <run minutes> <cycles>. Greedy active player, Nap at the end of every run.
function is_admin(){return false;} function setting($n){return '';}
require __DIR__ . '/../game/includes/catfish.php';
$mins=(int)($argv[1]??120); $cycles=(int)($argv[2]??10); $yarn=0; $cat=['mood'=>'lazy'];
echo "run length {$mins}m: ";
for($c=1;$c<=$cycles;$c++){ $up=[]; $k=0.0; $runk=0.0; $kph=catfish_kph($up,$cat,true,$yarn);
 for($t=1;$t<=$mins;$t++){ $kph=catfish_kph($up,$cat,true,$yarn); $k+=$kph/60; $runk+=$kph/60;
  while(true){ $best=null;$bv=0;
   foreach(CATFISH_UPGRADES as $key=>$d){ $n=$up[$key]??0; $cc=catfish_cost($key,$n); if($cc>$k) continue;
    $u2=$up; $u2[$key]=$n+1; $v=(catfish_kph($u2,$cat,true,$yarn)-$kph)/$cc; if($v>$bv){$bv=$v;$best=$key;} }
   if(!$best)break; $n=$up[$best]??0; $k-=catfish_cost($best,$n); $up[$best]=$n+1; $kph=catfish_kph($up,$cat,true,$yarn); } }
 $y=catfish_nap_yarn((int)$runk,$cat); $yarn+=$y; printf("[%d: run %s +%dY =%d] ",$c,number_format($runk),$y,$yarn);}
echo "\n";
