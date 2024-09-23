#!/bin/bash
echo ''
echo 2024.09.20 puff@mail.ru Script "$(basename "$0")" for linux 6-7 and Oracle database info '(run with oracle user, not root, with env for db)'

file_size_b=`du -b "$(basename "$0")" | cut -f1`
file_date=`stat $(basename "$0") | grep Modify`

echo 2024.09.20 Script "$(basename "$0")" size ${file_size_b} bytes and date ${file_date}.

lag_debug_delay=0

echo ''
echo --------------
echo ''
echo 001. Hostname
echo ''
hostname


echo ''
echo ------------------
echo ''
echo 002. Date
echo ''
echo `date +'%Y/%m/%d %H:%M:%S %a'`

echo ''
echo -------------------------------------------------------------------------------------------------
echo ''
echo 003. uname -a
echo ''
uname -a

echo ''
echo -----------------------------------------------------------------------------------------------
echo ''
echo 004. hugepages_setting.sh recomended huge pages size. on host=`hostname`  date=`date +'%Y/%m/%d %H:%M:%S %a'`
echo ''

#
# hugepages_setting.sh
#
# Linux bash script to compute values for the
# recommended HugePages/HugeTLB configuration
#
# Note: This script does calculation for all shared memory
# segments available when the script is run, no matter it
# is an Oracle RDBMS shared memory segment or not.
# Check for the kernel version
KERN=`uname -r | awk -F. '{ printf("%d.%d\n",$1,$2); }'`
# Find out the HugePage size
HPG_SZ=`grep Hugepagesize /proc/meminfo | awk {'print $2'}`
# Start from 1 pages to be on the safe side and guarantee 1 free HugePage
NUM_PG=1
# Cumulative number of pages required to handle the running shared memory segments
for SEG_BYTES in `ipcs -m | awk {'print $5'} | grep "[0-9][0-9]*"`
do
   MIN_PG=`echo "$SEG_BYTES/($HPG_SZ*1024)" | bc -q`
   if [ $MIN_PG -gt 0 ]; then
      NUM_PG=`echo "$NUM_PG+$MIN_PG+1" | bc -q`
   fi
done
# Finish with results
case $KERN in
   '2.4') HUGETLB_POOL=`echo "$NUM_PG*$HPG_SZ/1024" | bc -q`;
          echo "Recommended setting: vm.hugetlb_pool = $HUGETLB_POOL" ;;
   '2.6' | '3.8' | '3.10' | '4.1' | '4.14' | '5.4' |'7.1'|'5.15' ) echo "Recommended setting: vm.nr_hugepages = $NUM_PG" ;;
    *) echo "Unrecognized kernel version $KERN. Exiting." ;;
esac
# End

sleep ${lag_debug_delay}

echo ''
echo '------------------------------------------------------------'
echo ''
echo '005. -- Huge pages per Oracle DB:' on host=`hostname`  date=`date +'%Y/%m/%d %H:%M:%S %a'`
echo ''
echo '--'


function pshugepage () {
 HUGEPAGECOUNT=0
 for num in `grep 'huge.*dirty=' /proc/$@/numa_maps | awk '{print $5}' | sed 's/dirty=//'` ; do
 HUGEPAGECOUNT=$((HUGEPAGECOUNT+num))
 done
 echo process $@ using $HUGEPAGECOUNT huge pages
 }

for pid in `ps -eaf | grep [p]mon | awk '{print $2}'` ; do pshugepage $pid ; done

Hugepagesize=`cat /proc/meminfo | grep Hugepagesize | awk '{ print $2}'`
HugePages_Total=`cat /proc/meminfo | grep HugePages_Total | awk '{ print $2}'`
HugePages_Free=`cat /proc/meminfo | grep HugePages_Free | awk '{ print $2}'`
HugePages_Rsvd=`cat /proc/meminfo | grep HugePages_Rsvd | awk '{ print $2}'`


hp_total_gb=`expr $(($Hugepagesize * $HugePages_Total / 1024 /1024 ))`
hp_free_gb=`expr $(($Hugepagesize * $HugePages_Free / 1024 /1024))`
hp_rsvd_gb=`expr $(($Hugepagesize * $HugePages_Rsvd / 1024 /1024))`



echo ''
echo '------------------------------------------------------------'
echo ''
echo '006. Who using swap in free -m (From IBurry) (/proc/*/status)'
echo ''
cat /proc/*/status | awk '{if ($0 ~ "Name")
{name=$0}
else if ($0 ~ "VmSwap"){print name" "$0}}' | sort -nr -k 4 | head


sleep ${lag_debug_delay}

echo ''
echo --------------------------------------------------------------------
echo ''
echo 010. /proc/meminfo  grep Huge on host=`hostname`  date=`date +'%Y/%m/%d %H:%M:%S %a'`
echo ''
cat /proc/meminfo | grep Huge




echo ''
echo --------------------------------------------------------------------
echo ''
echo 011. /proc/meminfo   on host=`hostname`  date=`date +'%Y/%m/%d %H:%M:%S %a'`
echo ''
cat /proc/meminfo 




echo ''
echo --------------------------------------------------------------------
echo ''
echo '020. ---- Oracle instances total count: ' on host=`hostname`  date=`date +'%Y/%m/%d %H:%M:%S %a'`
echo ''
echo '--'

ps -ef | grep smon | grep -v grep | wc -l


echo ''
echo --------------------------------------------------------------------
echo ''
echo '021. ---- DBs list with owner and PID:'  on host=`hostname`  date=`date +'%Y/%m/%d %H:%M:%S %a'`
echo ''
echo '--'
ps -ef | grep smon | grep -v grep | awk '{print $1 " " $2 " " $NF}'


echo ''
echo --------------------------------------------------------------------
echo ''
echo 050. free -h
free -h

sleep ${lag_debug_delay}



echo ''
echo --------------------------------------------------------------------
echo ''
echo '080. ps aux --sort=-%mem | head -n 10'
ps aux --sort=-%mem | head -n 10
sleep ${lag_debug_delay}



echo ''
echo --------------------------------------------------------------------
echo ''
echo 051. /proc/meminfo  2me as of note MOS 2691445.1
echo 052. Cached: Amount of memory in the Pagecache = Diskcache and Shared Memory
echo ''
cat /proc/meminfo | grep Cached | grep -v SwapCached

echo ''       
echo '------------------------------------------------------------'
echo ''
echo 053. MemFree: Amount of physical memory not being used by the system
echo ''
cat /proc/meminfo | grep MemFree | grep -v SwapCached


echo ''
echo '------------------------------------------------------------'
echo ''
echo 054. MemTotal: Amount of physical memory not being used by the system
echo ''
cat /proc/meminfo | grep MemTotal


echo ''
echo '------------------------------------------------------------'
echo ''
echo 050.2 free -h  on host=`hostname`  date=`date +'%Y/%m/%d %H:%M:%S %a'`
echo ''
free -h


echo ''
echo '------------------------------------------------------------'
echo ''
echo 056. ipcs -m  on host=`hostname`  date=`date +'%Y/%m/%d %H:%M:%S %a'`
echo ''
ipcs -sm


echo ''
echo '------------------------------------------------------------'
echo ''
echo 057. ipcs -m sum Gbytes on host=`hostname`  date=`date +'%Y/%m/%d %H:%M:%S %a'`
echo ''

IPCS_M_SUM_B=`ipcs -m | awk '{sum += $5} END {print sum}'`
IPCS_M_SUM_GB=`expr $(($IPCS_M_SUM_B / 1024 /1024 /1024 ))`

echo $IPCS_M_SUM_GB Gb

echo ''
echo --------------------------------------------------------------------
echo ''
echo 060. PIDs of smon processes of Oracle database:
echo ''
ps -ef | grep smon | grep -v grep |awk '{ print $2 }'




echo ''
echo --------------------------------------------------------------------
echo ''
echo 061. PID of first smon processes of Oracle database on host=`hostname`  date=`date +'%Y/%m/%d %H:%M:%S %a'`:
echo ''

ps -ef | grep smon | grep -v grep |awk '{ print $2 }' | tail -1
export ORACLE_SID_SMON_PID=`ps -ef | grep smon | grep -v grep |awk '{ print $2 }' | tail -1`
echo ORACLE_SID_SMON_PID=${ORACLE_SID_SMON_PID}

echo ''
echo Oracle SID of this process sid on host=`hostname`  date=`date +'%Y/%m/%d %H:%M:%S %a'`: 
ps -ef | grep ${ORACLE_SID_SMON_PID} | grep -v grep | awk '{print $NF}' | sed 's/.........//'

export ORACLE_SID_ITEM1=`ps -ef | grep ${ORACLE_SID_SMON_PID} | grep -v grep | awk '{print $NF}' | sed 's/.........//'`

#echo top -p ${ORACLE_SID_SMON_PID}:
#top -p ${ORACLE_SID_SMON_PID} -n 1
# script exit after this command 

echo ''
echo in top -p command column number 5 is the VSS memory size of SGA of this db:
echo ''
#top -p ${ORACLE_SID_SMON_PID} -n 1 | tail -3 | head -1 
# script exit after this command 


export ORACLE_SID_MEM_KBYTES=`top -p ${ORACLE_SID_SMON_PID} -n 1 | tail -3 | head -1 |  awk '{print $5}'`
echo ${ORACLE_SID_MEM_KBYTES} kbytes

export ORACLE_SID_MEM_MB=`expr $(($ORACLE_SID_MEM_KBYTES / 1024 ))`
echo ${ORACLE_SID_MEM_MB} Mbytes

export ORACLE_SID_MEM_GB=`expr $(($ORACLE_SID_MEM_KBYTES / 1024 / 1024 ))`
echo ${ORACLE_SID_MEM_GB} Gbytes

echo ''
echo 050.3 Compare again with free -h:
echo ''
free -h

sleep ${lag_debug_delay}

export ORACLE_OS_MEM_TOTAL_KB=`free -k | tail -2 | head -1 | awk '{print $2}'`
export ORACLE_OS_MEM_TOTAL_MB=`expr $(($ORACLE_OS_MEM_TOTAL_KB / 1024 ))`
export ORACLE_OS_MEM_TOTAL_GB=`expr $(($ORACLE_OS_MEM_TOTAL_KB / 1024 / 1024))`


export ORACLE_MEM_PERCENT1=`expr $(((ORACLE_SID_MEM_KBYTES*100) / $ORACLE_OS_MEM_TOTAL_KB  ))`

RED='\033[0;31m'
NC='\033[0m' # No Color
#printf "I ${RED}love${NC} Stack Overflow\n"

echo ''
printf "So we can say that ${RED} Oracle instance ${ORACLE_SID_ITEM1}  eat ${ORACLE_SID_MEM_GB} Gb of total in OS ${ORACLE_OS_MEM_TOTAL_GB} Gb, = ${ORACLE_MEM_PERCENT1} percents ${NC} \n"
echo ''



echo ''
echo --------------------------------------------------------------------
echo '200. Detecting current env PID of smon'
echo ''
PID_KRA=`ps -ef | grep smon | grep ${ORACLE_SID} | awk '{ print $2 }'`

echo 201. Detecting current env PID of smon: ${PID_KRA} 
echo 202. Next run: linux_kra_info_item.sh ${PID_KRA} 
#sh linux_kra_info_item.sh ${PID_KRA}


sleep ${lag_debug_delay}



echo ''
echo --------------------------------------------------------------------
echo 300. Per instance info iterations assuming all of them using the same current ORACLE_HOME and PATH
echo ''


for pid in `ps -eaf | grep smon | grep -v grep | grep -v kra |  awk '{print $2}'` ; do sh linux_kra_info_item.sh $pid ; done


echo 1001. Host cumulative info
echo ''

#Saving fo future
export free_h_available=`free -h | tail -2 | head -1 | awk '{print $NF}'`

export free_h_buff_cache=`free -h | tail -2 | head -1 | awk '{print $(NF-1) }'`

export free_h_shared=`free -h | tail -2 | head -1 | awk '{print $(NF-3) }'`

export free_h_free=`free -h | tail -2 | head -1 | awk '{print $(NF-4) }'`

#Saving fo future
export OS_HUGE_PAGES_KB=`cat /proc/meminfo | grep Hugetlb | awk '{print $2}'`
export OS_HUGE_PAGES_MB=`expr $(($OS_HUGE_PAGES_KB / 1024 ))`
export OS_HUGE_PAGES_GB=`expr $(($OS_HUGE_PAGES_MB / 1024 ))`

#Saving fo future
export OS_MEM_TOTAL_KB=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`
export OS_MEM_TOTAL_MB=`expr $(($OS_MEM_TOTAL_KB / 1024 ))`
export OS_MEM_TOTAL_GB=`expr $(($OS_MEM_TOTAL_MB / 1024 ))`


echo HOST `hostname` RAM memory in OS ${OS_MEM_TOTAL_GB} Gb, Hugetlb=${OS_HUGE_PAGES_GB} Gb, free_h_free=${free_h_free}, free_h_shared=${free_h_shared}, free_h_buff_cache=${free_h_buff_cache}, free_h_available=${free_h_available}  > last_host_info_`hostname`.txt
#cat last_host_info_`hostname`.txt

echo `date +'%Y/%m/%d %H:%M:%S %a'` `hostname` memory in OS ${OS_MEM_TOTAL_GB} Gb, Hugetlb=${OS_HUGE_PAGES_GB} Gb, free_h_free=${free_h_free}, free_h_shared=${free_h_shared}, free_h_buff_cache=${free_h_buff_cache}, free_h_available=${free_h_available} >> host_info_`hostname`_history.txt



echo ''                                                                     >  report_result_`hostname`.txt
echo 2000. Results of script "$(basename "$0")":                            >>  report_result_`hostname`.txt

echo ''                                                                     >>  report_result_`hostname`.txt
echo --2----------------------------------------------------------------------------------------------------------   >>  report_result_`hostname`.txt
echo ''                                                                     >>  report_result_`hostname`.txt
cat last_host_info_`hostname`.txt                                           >>  report_result_`hostname`.txt
echo ''                                                                     >>  report_result_`hostname`.txt
echo --- Instances list:                                                    >>  report_result_`hostname`.txt
echo ''                                                                     >>  report_result_`hostname`.txt
cat db_item_result_`hostname`_*.log                                         >>  report_result_`hostname`.txt
echo ''                                                                     >>  report_result_`hostname`.txt
echo -------------------------------------------------------------------------------------------------------------------------------------------   >>  report_result_`hostname`.txt



echo ''                                                                     >>  report_result_`hostname`.txt
echo Sum of SGA_PGA of these DBs GBytes: 'cat db_item_result_`hostname`*.log | awk {sum += $4} END {print sum}' Gb >>  report_result_`hostname`.txt
echo ''                                                                     >>  report_result_`hostname`.txt

cat db_item_result_`hostname`*.log | awk '{sum += $4} END {print sum}'      >>  report_result_`hostname`.txt


echo ''                                                                     >>  report_result_`hostname`.txt
echo 'Sum of ipcs -m segments GBytes in OS: ipcs -m | awk {sum += $5} END {print sum}' >> report_result_`hostname`.txt
echo ''                                                                     >>  report_result_`hostname`.txt
IPCS_M_SUM_B=`ipcs -m | awk '{sum += $5} END {print sum}'`
IPCS_M_SUM_MB=`expr $(($IPCS_M_SUM_B / 1024 /1024  ))`
IPCS_M_SUM_GB=`expr $(($IPCS_M_SUM_B / 1024 /1024 /1024 ))`

echo ${IPCS_M_SUM_GB} GBytes                                                       >>  report_result_`hostname`.txt
echo ${IPCS_M_SUM_MB} MBytes                                                       >>  report_result_`hostname`.txt

#cat db_item_result_`hostname`*.log | awk '{sum += $4} END {print sum}'

echo ''                                                                     >>  report_result_`hostname`.txt
echo '050.4 free -h' >> report_result_`hostname`.txt                        >>  report_result_`hostname`.txt
free -h                                                                     >>  report_result_`hostname`.txt
echo ''                                                                     >>  report_result_`hostname`.txt

cat report_result_`hostname`.txt

