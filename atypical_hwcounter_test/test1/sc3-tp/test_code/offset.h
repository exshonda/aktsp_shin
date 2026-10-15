
#ifndef TOPPERS_OFFSET_H
#define TOPPERS_OFFSET_H

#define TCB_p_tinib	8
#define TCB_curpri	12
#define TCB_sp	32
#define TCB_pc	36
#define TCB_p_lastosapcb	40
#define TINIB_task	0
#define TINIB_sstksz	4
#define TINIB_sstk	8
#define TINIB_ustksz	12
#define TINIB_ustk	16
#define TINIB_p_osapcb	20
#define TINIB_p_scdcb	44
#define TINIB_exepri	32
#define TINIB_mpubase	48
#define TINIB_mpuacc	52
#define ISRCB_p_isrinib	0
#define ISRINIB_p_osapcb	4
#define OSAPCB_p_osapinib	0
#define OSAPINIB_osap_trusted	4
#define INTINIB_remain_stksz	12
#define ISRINIB_p_intinib	0

#endif /* TOPPERS_OFFSET_H */
