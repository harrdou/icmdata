$1 ~ dept &&
$2 == "0" &&
$3 !~ "group|ou=extern" &&
$4 ~ "Activated|Recover" &&
$5 ~ "@" &&
mktime(gensub("-", " ", "g", $8) " 0 0 0") > systime() &&
$9 == "TRUE" &&
$12 == "End User" &&
$15 ~ "gc_pers_loa|gc_id_medium" &&
$15 !~ "ocsp"
