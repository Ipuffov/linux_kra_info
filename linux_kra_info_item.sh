#!/bin/bash
# 2024.09.19 akra for linux 6-7

PID_KRAYNOV="$1"

echo ''
echo --------------------------------------------------------------------
echo ''
echo Viewing PID=${PID_KRAYNOV} on host=`hostname`  date=`date +'%Y/%m/%d %k:%M:%S %a'`
echo Process:
ps -ef | grep ${PID_KRAYNOV} | grep -v grep | grep -v kraynov

echo ''
echo --------------------------------------------------------------------
echo ''
echo 301.0 ORACLE_SID of current PID on host=`hostname`  date=`date +'%Y/%m/%d %k:%M:%S %a'`:
unset  ORACLE_SID_KRA
ORACLE_SID_KRA=`ps -q ${PID_KRAYNOV} -eo cmd | grep -v slub_flushwq | tail -1  | sed s/.........//`
echo ORACLE_SID_KRA=${ORACLE_SID_KRA}



echo ''
echo --------------------------------------------------------------------
echo 301.1 finding enviroment variables of current PID=${PID_KRAYNOV} ORACLE_SID_KRA=${ORACLE_SID_KRA} on host=`hostname`  date=`date +'%Y/%m/%d %k:%M:%S %a'`:
echo ''
strings /proc/${PID_KRAYNOV}/environ | grep ORA

echo ''
echo --------------------------------------------------------------------
echo 301.2 VmSize of current PID=${PID_KRAYNOV} ORACLE_SID_KRA=${ORACLE_SID_KRA}:
echo ''
strings /proc/${PID_KRAYNOV}/status | grep VmSize

echo ''
echo --------------------------------------------------------------------
echo 301.3 Start date from ps -eo lstart,cmd,pid grep ${ORACLE_SID_SMON_PID} for ORACLE_SID=${ORACLE_SID_KRA} on host=`hostname`  date=`date +'%Y/%m/%d %k:%M:%S %a'`:
echo ''
ps -eo lstart,cmd,pid | grep ${PID_KRAYNOV} | grep -v grep




echo ''
echo --------------------------------------------------------------------
echo 301.4 Start date from ps -eo lstart,cmd,pid grep ${ORACLE_SID_SMON_PID} for ORACLE_SID=${ORACLE_SID_KRA} on host=`hostname`  date=`date +'%Y/%m/%d %k:%M:%S %a'`:
echo ''

echo Column number 5 is the VSS memory size of SGA of this db in Kbytes:
#top -p ${ORACLE_SID_SMON_PID} -n 1 | tail -3 | head -1 


ORACLE_SID_MEM_KBYTES=`top -p ${ORACLE_SID_SMON_PID} -n 1 | tail -3 | head -1 |  awk '{print $5'}`
echo ${ORACLE_SID_MEM_KBYTES} kbytes

ORACLE_SID_MEM_MB=`expr $(($ORACLE_SID_MEM_KBYTES / 1024 ))`
echo ${ORACLE_SID_MEM_MB} Mbytes

ORACLE_SID_MEM_GB=`expr $(($ORACLE_SID_MEM_KBYTES / 1024 / 1024 ))`
echo ${ORACLE_SID_MEM_GB} Gbytes

echo free -h
free -h


ORACLE_OS_MEM_TOTAL_KB=`free -k | tail -2 | head -1 | awk '{print $2}'`
ORACLE_OS_MEM_TOTAL_MB=`expr $(($ORACLE_OS_MEM_TOTAL_KB / 1024 ))`
ORACLE_OS_MEM_TOTAL_GB=`expr $(($ORACLE_OS_MEM_TOTAL_KB / 1024 / 1024))`


ORACLE_MEM_PERCENT1=`expr $(((ORACLE_SID_MEM_KBYTES*100) / $ORACLE_OS_MEM_TOTAL_KB  ))`

echo ''
echo --------------------------------------------------------------------
echo ''
echo 301.5 OS eaten memory for this PID ${ORACLE_SID_SMON_PID} for ORACLE_SID=${ORACLE_SID_KRA} on host=`hostname`  date=`date +'%Y/%m/%d %k:%M:%S %a'`:
echo 301.6 Echo so we can say that Oracle instance ${ORACLE_SID_ITEM1}  eat ${ORACLE_SID_MEM_GB} Gb of total in OS ${ORACLE_OS_MEM_TOTAL_GB} Gb, = ${ORACLE_MEM_PERCENT1} %


echo ''
echo --------------------------------------------------------------------
echo ''
echo 301.7 Memory usage from Oracle DB if ORACLE_SID and other env set and sqlplus / as sysdba working OK on host=`hostname`  date=`date +'%Y/%m/%d %k:%M:%S %a'`


echo ''
echo --------------------------------------------------------------------
echo ''
echo 301.11 sysresv on host=`hostname`  date=`date +'%Y/%m/%d %k:%M:%S %a'`
echo ''

sysresv


echo ''
echo --------------------------------------------------------------------
echo ''
echo 301.12 sysresv light mode on host=`hostname`  date=`date +'%Y/%m/%d %k:%M:%S %a'`
echo ''


sysresv | grep Oracle
sysresv | grep Total | grep used


echo ''
echo ''
echo --------------------------------------------------------------------
echo ''
echo 301.13 Next will sqlplus info for ORACLE_SID=${ORACLE_SID_KRA} on host=`hostname`  date=`date +'%Y/%m/%d %k:%M:%S %a'`
echo ''


ORACLE_SID=${ORACLE_SID_KRA}

sqlplus / as sysdba <<- EOF
spool mem_ora_usage.txt
select instance_name from v\$instance;
select to_char(sysdate,'YYYY/MM/DD HH24:MI:SS DY') as info_date from dual;



prompt  ===== >  1015. PGA + SGA. MEMORY POOLS STATs ( v\$PGAstat, v\$SGAstat ?????) 

select pool2 as pool, sum(gb) from (
select   pool,pool as pool2, round(sum(bytes/1024/1024/1024),3)  as Gb
from v\$sgastat
where pool is not null
group by pool
union all
select   pool,name as pool2,round(sum(bytes/1024/1024/1024),3)  as Gb
from v\$sgastat
where pool is null
group by pool, name
union all
select 'PGA','PGA allocated', round(sum(value/1024/1024/1024),3)  as Gb
from v\$pgastat where name like 'total%alloc%'
order by 2 desc, 1)
group by rollup(pool2)
;

prompt  ===== >  1020. PGA  UGA SESSION  MEMORY in v sesstat

select sum(sess_mem_Mbytes) from (
SELECT   NVL (username, 'SYS-BKGD') username, sess.SID, round(SUM (VALUE)/1024/1024,3) sess_mem_Mbytes
    FROM v\$session sess, v\$sesstat stat, v\$statname NAME
   WHERE sess.SID = stat.SID
     AND stat.statistic# = NAME.statistic#
     AND NAME.NAME LIKE 'session % memory'
GROUP BY username, sess.SID);

prompt  ===== >  1105. PGA sum from  v\$session 

select sum(PGA_ALLOC_MEM_MB) as sum_PGA_ALLOC_MEM_Mb_v_process from (
select 
--* 
round(pga_alloc_mem/1024/1024) as pga_alloc_mem_Mb
,OSUSER, MACHINE, s.TERMINAL, s.PROGRAM, SQL_ID
, s.logon_time, s.sid, s.serial#
from v\$process p, v\$session s
where s.paddr( + )=p.addr
order by p.pga_alloc_mem desc)
--where rownum<11
;


exit;
EOF

echo ''
echo --------------------------------------------------------------------
echo ''
echo 401. Run sqlplus as sysdba linux_kra_info_item.sql for current PID=${PID_KRAYNOV} ORACLE_SID_KRA=${ORACLE_SID_KRA} on host=`hostname`  date=`date +'%Y/%m/%d %k:%M:%S %a'`:
sqlplus / as sysdba @linux_kra_info_item.sql


echo ''
echo --------------------------------------------------------------------
echo 402. run save_variable_from_sqlplus.sh to read variables such as ALERT_LOG_LOCATION
echo ''
#sh save_variable_from_sqlplus.sh
. ./save_variable_from_sqlplus.sh

echo ''
echo ALERT_LOG_LOCATION=${ALERT_LOG_LOCATION}
echo ''


echo ''
echo --------------------------------------------------------------------
echo ''
echo 403. Getting last alert log messages for ORACLE_SID_KRA=${ORACLE_SID_KRA} about PAGESIZE  AVAILABLE_PAGES  EXPECTED_PAGES  ALLOCATED_PAGES cat ${ALERT_LOG_LOCATION} '| grep PAGES -a5 -b6 | tail -14'
echo ''
cat ${ALERT_LOG_LOCATION} | grep PAGES -a5 -b6 | tail -14



echo ----------------------------------------------------------------------------------------------------
echo ''
echo 600. End of item ORACLE_SID_KRA=${ORACLE_SID_KRA} PID=${PID_KRAYNOV} on host=`hostname`  date=`date +'%Y/%m/%d %k:%M:%S %a'`
echo ''
echo ------------------------------------------------------------------------------------------------------------------------------------------------


