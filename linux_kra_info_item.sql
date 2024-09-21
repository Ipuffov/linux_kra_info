spool db_item.log

set trimspool on
set trimout on


define host_name_par=''
COLUMN host_name_par NEW_VALUE host_name_par

define instance_name_par=''
COLUMN instance_name_par NEW_VALUE instance_name_par

select host_name as host_name_par, instance_name as instance_name_par from v$database, v$instance;


define host_name_lpad=''
COLUMN host_name_lpad NEW_VALUE host_name_lpad

define instance_name_lpad=''
COLUMN instance_name_lpad NEW_VALUE instance_name_lpad


select lpad(host_name,9, '_') as host_name_lpad, lpad(instance_name,9, '_') as instance_name_lpad from v$database, v$instance;

select   pool,pool as pool2, round(sum(bytes/1024/1024/1024),3)  as Gb
from v$sgastat
where pool is not null
group by pool
union all
select   pool,name as pool2,round(sum(bytes/1024/1024/1024),3)  as Gb
from v$sgastat
where pool is null
group by pool, name
;

column SGA_PGA_PAR format 000000.000


define SGA_PGA_PAR=''
COLUMN SGA_PGA_PAR NEW_VALUE SGA_PGA_PAR


select sum(pga_alloc_par) as SGA_PGA_PAR from (
select round(sum(PGA_ALLOC_MEM_MB)/1024,3) as pga_alloc_par from (
select 
--* 
round(pga_alloc_mem/1024/1024) as pga_alloc_mem_Mb
,OSUSER, MACHINE, s.TERMINAL, s.PROGRAM, SQL_ID
, s.logon_time, s.sid, s.serial#
from v$process p, v$session s
where s.paddr( + )=p.addr
order by p.pga_alloc_mem desc)
union all
select sum(gb) as sga_gb_par_n from (
select   pool,pool as pool2, round(sum(bytes/1024/1024/1024),3)  as Gb
from v$sgastat
where pool is not null
group by pool
union all
select   pool,name as pool2,round(sum(bytes/1024/1024/1024),3)  as Gb
from v$sgastat
where pool is null
group by pool, name
));


column sga_gb_par format 000000.000

define sga_gb_par=''
COLUMN sga_gb_par NEW_VALUE sga_gb_par


select sum(gb) as sga_gb_par from (
select   pool,pool as pool2, round(sum(bytes/1024/1024/1024),3)  as Gb
from v$sgastat
where pool is not null
group by pool
union all
select   pool,name as pool2,round(sum(bytes/1024/1024/1024),3)  as Gb
from v$sgastat
where pool is null
group by pool, name
);






define sga_gb_par_n=''
COLUMN sga_gb_par_n NEW_VALUE sga_gb_par_n


select sum(gb) as sga_gb_par_n from (
select   pool,pool as pool2, round(sum(bytes/1024/1024/1024),3)  as Gb
from v$sgastat
where pool is not null
group by pool
union all
select   pool,name as pool2,round(sum(bytes/1024/1024/1024),3)  as Gb
from v$sgastat
where pool is null
group by pool, name
);


define use_large_pages_par=''
COLUMN use_large_pages_par NEW_VALUE use_large_pages_par

select value as use_large_pages_par
from v$parameter 
where name='use_large_pages' 
order by name;


define lock_sga_par=''
COLUMN lock_sga_par NEW_VALUE lock_sga_par

select value as lock_sga_par
from v$parameter 
where name='lock_sga' 
order by name;

define pre_page_sga_par=''
COLUMN pre_page_sga_par NEW_VALUE pre_page_sga_par


select 
value as pre_page_sga_par
from v$parameter 
where name='pre_page_sga' 
order by name;



prompt  ===== >  1015. PGA + SGA. MEMORY POOLS STATs ( v$PGAstat, v$SGAstat ?????) 

select pool2 as pool, sum(gb) from (
select   pool,pool as pool2, round(sum(bytes/1024/1024/1024),3)  as Gb
from v$sgastat
where pool is not null
group by pool
union all
select   pool,name as pool2,round(sum(bytes/1024/1024/1024),3)  as Gb
from v$sgastat
where pool is null
group by pool, name
union all
select 'PGA','PGA allocated', round(sum(value/1024/1024/1024),3)  as Gb
from v$pgastat where name like 'total%alloc%'
order by 2 desc, 1)
group by rollup(pool2)
;

prompt  ===== >  1020. PGA  UGA SESSION  MEMORY in v sesstat

select sum(sess_mem_Mbytes) from (
SELECT   NVL (username, 'SYS-BKGD') username, sess.SID, round(SUM (VALUE)/1024/1024,3) sess_mem_Mbytes
    FROM v$session sess, v$sesstat stat, v$statname NAME
   WHERE sess.SID = stat.SID
     AND stat.statistic# = NAME.statistic#
     AND NAME.NAME LIKE 'session % memory'
GROUP BY username, sess.SID);

prompt  ===== >  1105. PGA sum from  v$session 

select sum(PGA_ALLOC_MEM_MB) as sum_PGA_ALLOC_MEM_Mb_v_process from (
select 
--* 
round(pga_alloc_mem/1024/1024) as pga_alloc_mem_Mb
,OSUSER, MACHINE, s.TERMINAL, s.PROGRAM, SQL_ID
, s.logon_time, s.sid, s.serial#
from v$process p, v$session s
where s.paddr( + )=p.addr
order by p.pga_alloc_mem desc)
--where rownum<11
;


column pga_alloc_par format 000000.000

define pga_alloc_par=''
COLUMN pga_alloc_par NEW_VALUE pga_alloc_par


select round(sum(PGA_ALLOC_MEM_MB)/1024,3) as pga_alloc_par from (
select 
--* 
round(pga_alloc_mem/1024/1024) as pga_alloc_mem_Mb
,OSUSER, MACHINE, s.TERMINAL, s.PROGRAM, SQL_ID
, s.logon_time, s.sid, s.serial#
from v$process p, v$session s
where s.paddr( + )=p.addr
order by p.pga_alloc_mem desc)
--where rownum<11
;



 

define pga_alloc_par_n=''
COLUMN pga_alloc_par_n NEW_VALUE pga_alloc_par_n


select round(sum(PGA_ALLOC_MEM_MB)/1024,3) as pga_alloc_par_n from (
select 
--* 
round(pga_alloc_mem/1024/1024) as pga_alloc_mem_Mb
,OSUSER, MACHINE, s.TERMINAL, s.PROGRAM, SQL_ID
, s.logon_time, s.sid, s.serial#
from v$process p, v$session s
where s.paddr( + )=p.addr
order by p.pga_alloc_mem desc)
--where rownum<11
;



select value||''||(select decode(instr(value,'/'),1,'/','\') alert_log_location 
from  v$diag_info 
where name ='Diag Trace')||'alert_'||(select instance_name from v$instance)||'.log' as "alert log location" from v$diag_info where name ='Diag Trace'
;


spool off

set linesize 1000
set pagesize 0
set feedback off
set head off
set verify off

spool save_variable_from_sqlplus.sh

select 'export ALERT_LOG_LOCATION='||value||''||(select decode(instr(value,'/'),1,'/','\') alert_log_location 
from  v$diag_info 
where name ='Diag Trace')||'alert_'||(select instance_name from v$instance)||'.log' as "alert log location" from v$diag_info where name ='Diag Trace'
;

spool off


spool db_item_result.log

--select 'HOST='||'&host_name_lpad'||', INSTANCE='||'&instance_name_lpad' || ', SGA_PGA='||to_char('&SGA_PGA_PAR', '000.000')||', SGA='||to_char('&SGA_GB_PAR', '000.000')||', PGA='||to_char('&PGA_ALLOC_PAR', '0000.000')||', use_large_pages=&use_large_pages_par,  lock_sga_par=&lock_sga_par, pre_page_sga_par=&pre_page_sga_par, started='||to_char(startup_time,'YYYY/MM/DD HH24:MI:SS DY') as info 
--from v$database, v$instance;

spool db_item_result_&host_name_par._&instance_name_par..log

select 'HOST='||'&host_name_lpad'||', INSTANCE='||'&instance_name_lpad' || ', SGA_PGA='||to_char('&SGA_PGA_PAR', '000.000')||', SGA='||to_char('&SGA_GB_PAR', '000.000')||', PGA='||to_char('&PGA_ALLOC_PAR', '000.000')||', use_large_pages=&use_large_pages_par,  lock_sga_par=&lock_sga_par, pre_page_sga_par=&pre_page_sga_par, started='||to_char(startup_time,'YYYY/MM/DD HH24:MI:SS DY') as info 
from v$database, v$instance;

spool db_item_result_&host_name_par._&instance_name_par._history.txt append
select 'Date: '||to_char(sysdate,'YYYY/MM/DD HH24:MI:SS DY'), 
       'HOST='||'&host_name_lpad'||', INSTANCE='||'&instance_name_lpad' || ', SGA_PGA='||to_char('&SGA_PGA_PAR', '000.000')||', SGA='||to_char('&SGA_GB_PAR', '000.000')||', PGA='||to_char('&PGA_ALLOC_PAR', '000.000')||', use_large_pages=&use_large_pages_par,  lock_sga_par=&lock_sga_par, pre_page_sga_par=&pre_page_sga_par, started='||to_char(startup_time,'YYYY/MM/DD HH24:MI:SS DY') as info 
from v$database, v$instance;



spool off

exit
