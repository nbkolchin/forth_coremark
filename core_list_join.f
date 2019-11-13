: dataregen  ( a-addr -- )  \ &data
   cell+
   dup @  ( data16 )
   $FF00 and
   dup #8 rshift $00FF and
   or swap ! ;

: cmp_idx_dr  ( a-addr1 a-addr2 -- n )  \ &elem_a &elem_b
   cell+ @
   dup dataregen
   swap cell+ @
   dup dataregen
   @ swap @ - ;

: cmp_idx  ( a-addr1 a-addr2 -- n )  \ &elem_a &elem_b
   cell+ @
   swap cell+ @
   @ swap @ - ;

: mergesort  ( a-addr1 a-addr2 a-addr3 xt -- a-addr4 )  \ &tail p q cmp
   \ p is <> 0
   r>  \ &tail p q
   begin
      dup if
         over if
            2dup r@ execute
            0> if
            else
               swap
            then
         then
      else
         over if
            swap
         else
            2drop r> drop exit
         then
      then
      rot over swap ! tuck @
   again ;

: list_mergesort  ( a-addr1 xt -- a-addr2 )  \ &elem &cmp
   
;

: data!  ( u1 u2 a-addr -- )  \ idx data16 &elem
   cell+ @
   swap over cell+ !  \ elem->info->data16=u2
   ! ;  \ elem->info->idx=u1

: idx!  ( u a-addr -- )  \ idx &elem
   cell+ @
   ! ;  \ elem->info->idx=u1

: data16!  ( u a-addr -- )  \ data16 &elem
   cell+ @
   cell+ ! ;  \ elem->info->data16=u2

: elem+  ( a-addr1 -- a-addr2 )
   2 cells + ;

: list_new  ( a-addr1 -- a-addr2 )  \ &end_elem -- &newend_elem
   dup cell+ @ elem+  ( &end_elem &newend_data )
   swap elem+  \ &newend_elem
   tuck cell+ ! ; \ newend_elem->info=&newend_data

: list_insert  ( a-addr1 a-addr2 -- )  \ &elem &newend_elem
   over @ over !  \ newtail_elem->next= elem->next
   swap ! ;  \ elem->next=&newend_elem

: core_list_init  ( u1 a-addr1 u2 -- a-addr2 )  \ list_head *core_list_init(ee_u32 blksize, list_head *memblock, ee_s16 seed)
   >r  \ blksize memblock R: seed
   over swap  \ blksize blksize memblock
   $0 over !  \ list->next=NULL
   over 2/ over + over cell+ !  \ list->info=datablock
   dup $0000 $8080 rot data!
   dup list_new
   dup $7FFF $FFFF rot data!
   2dup list_insert  \ &elem &end_elem
   rot 2/ 2/ cell / 3 -
   0 do
      list_new
      j i xor $000F and
      #3 lshift i $0007 and or
      dup #8 lshift or
      over data16!
      2dup list_insert
   loop
   drop swap 2/ 2/ cell / 5 / >r  \ list R: size/5
   1 over
   begin
      @ dup @
   while
         swap  ( list i )
         dup r@ < if
            dup
         else
            dup r> r@ swap >r xor
            over 1+ $0007 and #8 lshift
            or $3FFF and
         then
         swap 1+ rot rot
         over idx!
   repeat
   2drop
   r> r> 2drop
;
