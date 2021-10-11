\ -----------------------------
\ From core_portme.h

\ typedef unsigned char  ee_u8  -> char
\ typedef signed short   ee_s16 -> n
\ typedef unsigned short ee_u16 -> u
\ typedef signed int     ee_s32 -> d
\ typedef unsigned int   ee_u32 -> ud

\ #define HAS_FLOAT 0 - no floating point.
\ #define HAS_TIME_H 0 - no time.h header file.
\ #define USE_CLOCK 0 - no time.h header file.
\ #define HAS_STDIO 0 - no stdio.h header file.
\ #define HAS_PRINTF 0 - no stdio.h header file.
\ #define SEED_METHOD SEED_VOLATILE - from volatile variables.
\ #define MEM_METHOD MEM_STATIC - to use a static memory array.
\ #define MULTITHREAD 1 - only one context.
\ #define MAIN_HAS_NOARGC 0 - argc/argv to main is supported.
\ #define MAIN_HAS_NORETURN 1 - platform does not support returning a value from main


2variable start_time_var
2variable stop_time_var

[undefined] d> [if]
: d>  ( d1 d2 -- flag )  \ SwiftForth
   2over 2over d= >r     \ SwiftForth
   d< r> or invert ;     \ SwiftForth
[then]

\	This function will be called right before starting the timed portion of the benchmark.
\ void start_time(void)
[defined] vfxforth [if]
: start_time  ( -- )
   (ticks) #1000 um* start_time_var 2! ;  \ Vfx
: stop_time  ( -- )
   (ticks) #1000 um* stop_time_var 2! ;  \ Vfx
[then]

[defined] swiftforth [if]
: start_time  ( -- )
   ucounter start_time_var 2! ;  \ SwiftForth
: stop_time  ( -- )
   ucounter stop_time_var 2! ;  \ SwiftForth
[then]

[defined] swiftforth [if]
: start_time  ( -- )
   ucounter start_time_var 2! ;  \ SwiftForth
: stop_time  ( -- )
   ucounter stop_time_var 2! ;  \ SwiftForth
[then]

\ NOTE: current "stable" gforth-0.7.3 doesn't define this...
\ To run with old versions you must:
\ $ gforth -e ": GFORTH ;" run.fth
[defined] gforth [if]
: start_time  ( -- )
   utime start_time_var 2! ;  \ gforth
: stop_time  ( -- )
   utime stop_time_var 2! ;  \ gforth
[then]

[undefined] start_time [if]
." unable to detect forth system. You must provide start_time stop_time words"
bye
[then]

0 [IF]
: start_time  ( -- )
   utime start_time_var 2! ;  \ gforth
\   ucounter start_time_var 2! ;  \ SwiftForth
\   (ticks) #1000 um* start_time_var 2! ;  \ Vfx

\ This function will be called right after ending the timed portion of the benchmark.
\ void stop_time(void)
: stop_time  ( -- )
   utime stop_time_var 2! ;  \ gforth
\   ucounter stop_time_var 2! ;  \ SwiftForth
\   (ticks) #1000 um* stop_time_var 2! ;  \ Vfx
[then]

\	Return an abstract "ticks" number that signifies time on the system.
\ typedef ee_u32 CORE_TICKS
\ CORE_TICKS get_time(void)
: get_time  ( -- ud )
   stop_time_var 2@ start_time_var 2@ d- ;

\	Convert the value returned by get_time to seconds.
\ typedef ee_u32 secs_ret
\ secs_ret time_in_secs(CORE_TICKS ticks)
\ secs_ret -> u - no need for double cell
: time_in_secs  ( ud -- u )
   #1000000 um/mod nip ;
