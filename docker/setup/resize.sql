--Disable recyclebin
alter system set recyclebin = off deferred;

-- Set stats hist retention to 10 days
exec dbms_stats.alter_stats_history_retention(10);

-- Remove stats older than 10 days
exec dbms_stats.purge_stats(sysdate-10);

-- Coalesce tablespace
alter tablespace SYSAUX coalesce;
alter tablespace system coalesce;

--Uninstall Apex
@@/u01/app/oracle/product/11.2.0/xe/apex/apxremov.sql

--Generate move.sql
create or replace procedure spool_resize_installation as
     V_FILE_ID NUMBER; 
     V_BLOCK_SIZE NUMBER; 
     V_RESIZE_SIZE NUMBER; 
begin 
     v_file_id := 2;--file_id; 
     v_resize_size := 200000000;--RESIZE_FILE_TO; 
     SELECT BLOCK_SIZE INTO V_BLOCK_SIZE FROM V$DATAFILE WHERE FILE# = V_FILE_ID; 
    
     DBMS_OUTPUT.PUT_LINE('--OBJECTS IN FILE '||V_FILE_ID||' THAT MUST MOVE IN ORDER TO RESIZE THE FILE TO '||V_RESIZE_SIZE||' BYTES'); 

     for my_record in ( 
          SELECT DISTINCT('alter '|| segment_type ||' '|| OWNER||'.'||SEGMENT_NAME||decode(segment_type,'TABLE',' move ','INDEX',' rebuild ')||' tablespace SYSAUX;') ONAME 
          FROM DBA_EXTENTS 
          WHERE (block_id + blocks-1)*V_BLOCK_SIZE > V_RESIZE_SIZE 
          and file_id = v_file_id 
          and segment_type not like '%PARTITION%' 
          and segment_type in ('TABLE','INDEX')
          order by 1 desc) 
        LOOP 
         DBMS_OUTPUT.PUT_LINE(my_record.ONAME); 
     end loop;   
end;
/

set echo off
SET term off
set feedback off
set verify off
set linesize 200
set serveroutput on
spool /tmp/move.sql
call SPOOL_RESIZE_INSTALLATION();
spool off
set feedback on
set term on
set verify on
set echo on

drop procedure spool_resize_installation;

--Move data
@/tmp/move.sql


--Resize files
ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/XE/sysaux.dbf' RESIZE 200M;
ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/XE/sysaux.dbf' AUTOEXTEND ON NEXT 10M MAXSIZE 33554416K;
ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/XE/users.dbf' RESIZE 20M;
ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/XE/users.dbf' AUTOEXTEND ON NEXT 10M MAXSIZE 11G;

--Create sandbox dba
create user sandbox identified by sandbox default tablespace users temporary tablespace temp;
grant dba to sandbox;

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER SYSTEM ENABLE RESTRICTED SESSION;
ALTER SYSTEM SET JOB_QUEUE_PROCESSES=0;
ALTER SYSTEM SET AQ_TM_PROCESSES=0;
ALTER DATABASE OPEN;
ALTER DATABASE CHARACTER SET INTERNAL_USE WE8ISO8859P1;
-- Replace <NEW NLS_CHARACTERSET> in the command with the characterset you want to use instead of AL32UTF8.
SHUTDOWN IMMEDIATE;
STARTUP;

exit;
