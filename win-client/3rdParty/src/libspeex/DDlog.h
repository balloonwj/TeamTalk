/*******************************************************************************
 *  @file      DDlog.h 2014\5\5 15:59:54 $
 *  @author    大佛<dafo@mogujie.com>
 *  @summary   
 ******************************************************************************/

#ifndef DDLOG_45D14A3E_DFD2_4568_A624_F7D32AFB7707_H__
#define DDLOG_45D14A3E_DFD2_4568_A624_F7D32AFB7707_H__

/******************************************************************************/

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

#define LOGFILE "audio_errorlog.txt"

void GetModuleFilePath(IN char* pPath,IN DWORD nSize)
{
    char path_buffer[_MAX_PATH] = {0};
    char drive[_MAX_DRIVE] = {0};
    char dir[_MAX_DIR] = {0};
    char fname[_MAX_FNAME] = {0};
    char ext[_MAX_EXT] = {0};
    if (NULL == pPath)
    {
        return;
    }
    GetModuleFileName(NULL,path_buffer,_MAX_PATH);
    _splitpath(path_buffer,drive,dir,fname,ext);
    strcat(pPath,drive);
    strcat(pPath,dir);
}

int WriteDebugLog(char *str)
{
    char buf[2048]={0};
    char logFileName[MAX_PATH]={0};
    int iMax =  10*1024*1024;//10M
    int len = 0;
    time_t timep;
    FILE *fp = NULL;
    struct tm *p;
    time(&timep);
    p = localtime(&timep);
    memset(buf,0,sizeof(buf));
    GetModuleFilePath(logFileName,MAX_PATH);
    sprintf(buf,"[%d-%d-%d %02d:%02d:%02d] ",(1900+p->tm_year),(1+p->tm_mon), p->tm_mday,p->tm_hour, p->tm_min, p->tm_sec); //星期p->tm_wday
    strcat(buf,str);
    strcat(buf,"\n");
    strcat(logFileName,LOGFILE);
    fp = fopen(logFileName,"a");
    fseek(fp,0,2);//SEEK_END值为2
    if( ftell(fp) >= iMax)//若文件存在,且大于10M，则文件长度清为零
    {
        fclose(fp);
        fp = fopen(logFileName,"w+");
    }
    fwrite(buf,1,strlen(buf),fp);
    fclose(fp);
    return -1;
}
/******************************************************************************/
#endif// DDLOG_45D14A3E_DFD2_4568_A624_F7D32AFB7707_H__
