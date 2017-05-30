/*******************************************************************************
YaoLog v1.6

Description: A powerful, easy-use, cross-platform C++ log utility
Updated:     Mar 31, 2013
Author:      Neil.L
E-mail:      Neil.L@qq.com
See detail:  http://www.codeproject.com/Articles/508529/yaolog-A-powerful-easy-use-cross-platform-Cplusplu
********************************************************************************/


#ifndef _YAOLOG_H_
#define _YAOLOG_H_

///////////////////////////////////////////////////////////////
// platform
///////////////////////////////////////////////////////////////
#ifndef _YAOLOG_PLATFORM_DEFINED_
    #if defined(_WIN32) || defined(__WIN32__) || defined(__WINDOWS__)
        #define _YAOLOG_WIN32_
    #else
        #define _YAOLOG_POSIX_
    #endif
    #define _YAOLOG_PLATFORM_DEFINED_
#endif


///////////////////////////////////////////////////////////////
// include
///////////////////////////////////////////////////////////////
#ifdef _YAOLOG_WIN32_
#include <winsock2.h>
#include <windows.h>
#include <tchar.h>
#pragma warning(push)
#pragma warning(disable : 4251)
#else
#include <stdarg.h>
#include <pthread.h>
#include <arpa/inet.h>
#endif

#include <string>
#include <map>
#include <vector>
#include <cassert>


///////////////////////////////////////////////////////////////
// Uncomment the block below if you want to compile yaolog.dll
// define YAOLOG_EXPORTS for dll itself.
// And, you must guarantee that your yaolog.dll and invoker.exe are built with the same toolchain.
///////////////////////////////////////////////////////////////
#ifdef _YAOLOG_WIN32_
    #ifdef YAOLOG_EXPORTS
        #define YAOLOG_EXPORT_API _declspec(dllexport)
    #else
        #define YAOLOG_EXPORT_API _declspec(dllimport)
    #endif
#else
    #define YAOLOG_EXPORT_API
#endif


///////////////////////////////////////////////////////////////
// for protect... 
///////////////////////////////////////////////////////////////
#ifndef YAOLOG_EXPORT_API
#define YAOLOG_EXPORT_API
#endif


///////////////////////////////////////////////////////////////
// charset
///////////////////////////////////////////////////////////////
#ifndef _YAOLOG_CHARSET_DEFINED_
    #if defined(_YAOLOG_WIN32_) && defined(_UNICODE)
        #define _YAOLOG_UNICODE_
    #else
        #define _YAOLOG_ANSI_
    #endif
    #define _YAOLOG_CHARSET_DEFINED_
#endif


///////////////////////////////////////////////////////////////
// string
///////////////////////////////////////////////////////////////
#ifndef yao_tstring
    #ifdef _YAOLOG_UNICODE_
        #define yao_tstring   std::wstring
    #else
        #define yao_tstring   std::string
        #ifndef _T
        #define _T(x)     x
        #endif
        typedef char      TCHAR;
    #endif
#endif


///////////////////////////////////////////////////////////////
// Macros for log
// These log marcos will not be compiled if _NO_YAOLOG defined...
///////////////////////////////////////////////////////////////
#ifdef _NO_YAOLOG

#ifndef YAOLOG_INIT
#define YAOLOG_INIT
#endif
#ifndef YAOLOG_EXIT
#define YAOLOG_EXIT
#endif
#ifndef YAOLOG_CREATE
#define YAOLOG_CREATE(szLogID, bEnable, logType)
#endif
#ifndef YAOLOG_DISABLE_ALL
#define YAOLOG_DISABLE_ALL(bDisableAll)
#endif
#ifndef YAOLOG_SET_LOG_ATTR
#define YAOLOG_SET_LOG_ATTR(szLogID, bEnable, nOutFlag, bWithTime,\
    bWithMillisecond, bWithSrcFile, bWithFunction, szDestUrl)
#endif
#ifndef YAOLOG_SET_LOGFILE_ATTR
#define YAOLOG_SET_LOGFILE_ATTR(szLogID, bOverwrite, bFlushBufferImmediately,\
    bGenNewLogFileDaily, szLogFileDir, szLogFileName)
#endif
#ifndef YAOLOG_SET_ATTR_FROM_CONFIG_FILE
#define YAOLOG_SET_ATTR_FROM_CONFIG_FILE(szLogID, szINI)
#endif
#ifndef LOGBIN__
#define LOGBIN__(szLogID, pData, nSize)
#endif
#ifndef LOGBIN_F__
#define LOGBIN_F__(szLogID, szTitle, pData, nSize)
#endif
#ifndef LOG__
#define LOG__(szLogID, szFormat, ...)
#endif
#ifndef LOGA__
#define LOGA__(szLogID, szFormat, ...)
#endif
#ifndef LOGW__
#define LOGW__(szLogID, szFormat, ...)
#endif

#else

#ifndef YAOLOG_INIT
#define YAOLOG_INIT YaoUtil::LogFactory::Init()
#endif

#ifndef YAOLOG_EXIT
#define YAOLOG_EXIT YaoUtil::LogFactory::Exit()
#endif

#ifndef YAOLOG_CREATE
#define YAOLOG_CREATE(szLogID, bEnable, logType) \
    YaoUtil::LogFactory::Create(szLogID, bEnable, logType)
#endif

#ifndef YAOLOG_DISABLE_ALL
#define YAOLOG_DISABLE_ALL(bDisableAll) \
    YaoUtil::LogFactory::DisableAllLogs(bDisableAll)
#endif

#ifndef YAOLOG_SET_LOG_ATTR
#define YAOLOG_SET_LOG_ATTR(szLogID, bEnable, nOutFlag, bWithTime,\
    bWithMillisecond, bWithSrcFile, bWithFunction, szDestUrl) \
    YaoUtil::LogFactory::SetLogAttr(szLogID, bEnable, nOutFlag, bWithTime,\
    bWithMillisecond, bWithSrcFile, bWithFunction, szDestUrl)
#endif

#ifndef YAOLOG_SET_LOGFILE_ATTR
#define YAOLOG_SET_LOGFILE_ATTR(szLogID, bOverwrite, bFlushBufferImmediately,\
    bGenNewLogFileDaily, szLogFileDir, szLogFileName) \
    YaoUtil::LogFactory::SetLogFileAttr(szLogID, bOverwrite, bFlushBufferImmediately,\
    bGenNewLogFileDaily, szLogFileDir, szLogFileName)
#endif

#ifndef YAOLOG_SET_ATTR_FROM_CONFIG_FILE
#define YAOLOG_SET_ATTR_FROM_CONFIG_FILE(szLogID, szINI) \
    YaoUtil::LogFactory::SetAttrFromConfigFile(szLogID, szINI)
#endif

// for LOG_TYPE_BIN
#ifndef LOGBIN__
    #define LOGBIN__(szLogID, pData, nSize) do {\
        if (YaoUtil::LogFactory::Disabled()) break;\
        YaoUtil::LogFactory::m_tm.Lock();\
        YaoUtil::BaseLog *p = YaoUtil::LogFactory::Get(szLogID);\
        if ((!p) || (p->IsTextLog())) { YaoUtil::LogFactory::m_tm.Unlock(); break; }\
        p->LogBin(pData, nSize);\
        YaoUtil::LogFactory::m_tm.Unlock();\
        } while (0)
#endif

// for LOG_TYPE_FORMATTED_BIN
#ifndef LOGBIN_F__
    #define LOGBIN_F__(szLogID, szTitle, pData, nSize) do {\
        if (YaoUtil::LogFactory::Disabled()) break;\
        YaoUtil::LogFactory::m_tm.Lock();\
        YaoUtil::BaseLog *p = YaoUtil::LogFactory::Get(szLogID);\
        if ((!p) || (!p->IsTextLog())) { YaoUtil::LogFactory::m_tm.Unlock(); break; }\
        p->LogFormattedBin(__FILE__, __FUNCTION__, __LINE__, szTitle, pData, nSize);\
        YaoUtil::LogFactory::m_tm.Unlock();\
        } while (0)
#endif

// for LOG_TYPE_TEXT
#ifndef LOG__
    #ifdef _YAOLOG_WIN32_
        #define LOG__(szLogID, szFormat, ...) do {\
            if (YaoUtil::LogFactory::Disabled()) break;\
            YaoUtil::LogFactory::m_tm.Lock();\
            YaoUtil::BaseLog *p = YaoUtil::LogFactory::Get(szLogID);\
            if ((!p) || (!p->IsTextLog())) { YaoUtil::LogFactory::m_tm.Unlock(); break; }\
            p->Log(__FILE__, __FUNCTION__, __LINE__, szFormat, __VA_ARGS__);\
            YaoUtil::LogFactory::m_tm.Unlock();\
            } while (0)
    #else
        #define LOG__(szLogID, szFormat, ...) do {\
            if (YaoUtil::LogFactory::Disabled()) break;\
            YaoUtil::LogFactory::m_tm.Lock();\
            YaoUtil::BaseLog *p = YaoUtil::LogFactory::Get(szLogID);\
            if ((!p) || (!p->IsTextLog())) { YaoUtil::LogFactory::m_tm.Unlock(); break; }\
            p->Log(__FILE__, __FUNCTION__, __LINE__, szFormat, ##__VA_ARGS__);\
            YaoUtil::LogFactory::m_tm.Unlock();\
            } while (0)
    #endif
#endif
#ifndef LOGA__
    #ifdef _YAOLOG_WIN32_
        #define LOGA__(szLogID, szFormat, ...) do {\
            if (YaoUtil::LogFactory::Disabled()) break;\
            YaoUtil::LogFactory::m_tm.Lock();\
            YaoUtil::BaseLog *p = YaoUtil::LogFactory::Get(szLogID);\
            if ((!p) || (!p->IsTextLog())) { YaoUtil::LogFactory::m_tm.Unlock(); break; }\
            p->LogA(__FILE__, __FUNCTION__, __LINE__, szFormat, __VA_ARGS__);\
            YaoUtil::LogFactory::m_tm.Unlock();\
            } while (0)
    #else
        // linux has no LOGA__...
    #endif
#endif
#ifndef LOGW__
    #ifdef _YAOLOG_WIN32_
        #define LOGW__(szLogID, szFormat, ...) do {\
            if (YaoUtil::LogFactory::Disabled()) break;\
            YaoUtil::LogFactory::m_tm.Lock();\
            YaoUtil::BaseLog *p = YaoUtil::LogFactory::Get(szLogID);\
            if ((!p) || (!p->IsTextLog())) { YaoUtil::LogFactory::m_tm.Unlock(); break; }\
            p->LogW(__FILE__, __FUNCTION__, __LINE__, szFormat, __VA_ARGS__);\
            YaoUtil::LogFactory::m_tm.Unlock();\
            } while (0)
    #else
        // linux has no LOGW__...
    #endif
#endif

#endif


namespace YaoUtil {
///////////////////////////////////////////////////////////////
// TinyMutex
///////////////////////////////////////////////////////////////
class YAOLOG_EXPORT_API TinyMutex
{
public:
    TinyMutex();
    ~TinyMutex();
    void Lock();
    void Unlock();

private:
#ifdef _YAOLOG_WIN32_
    CRITICAL_SECTION m_handle;
#else
    pthread_mutex_t m_handle;
#endif

private:
    TinyMutex(const TinyMutex&);
    const TinyMutex& operator=(const TinyMutex&);
};


///////////////////////////////////////////////////////////////
// StrUtil
///////////////////////////////////////////////////////////////
class StrUtil
{
public:
    static void vFormat(yao_tstring& s, const TCHAR *fmt, va_list ap);
    static void vFormatA(std::string& s, const char *fmt, va_list ap);
    static bool CompareNoCase(const std::string& strIn1, const std::string& strIn2);
    static std::string GetSysTimeStr(bool withMillisecond);
    static std::string GetSysTimeStrForFileName(bool isTextFile);
    static int SplitString(
        const std::string& strIn,
        const std::string& strDelimiter,
        std::vector<std::string>& ret,
        bool retWithEmpty);
    static size_t IndexOfFirst(const std::string& strIn, const std::string& strMatch);
    static size_t IndexOfLast(const std::string& strIn, const std::string& strMatch);

    //in:  http://www.baidu.com:80/1.html
    //out: www.baidu.com  /1.html  80
    static bool ParseUrl(
        const std::string& strUrl,
        std::string& strServer,
        std::string& strPath,
        int& nPort);

#ifdef _YAOLOG_WIN32_
    static void vFormatW(std::wstring& s, const wchar_t *fmt, va_list ap);
    static std::string WStrToStr(const std::wstring& strIn);
    static std::wstring StrToWStr(const std::string& strIn);
#endif
};


///////////////////////////////////////////////////////////////
// PathUtil
///////////////////////////////////////////////////////////////
class PathUtil
{
public:
    static std::string ModuleFileDirectory_();

    static std::string GetDirectory_(const std::string& fileFullPath);

    static std::string GetFile_(const std::string& fileFullPath);

    // directory+folder or directory+file
    static std::string PathCombine_(const std::string& path1, const std::string& path2);

    // path_ -> directory or fileFullPath
    static bool PathFileExists_(const std::string& path_);

    static bool IsStrJustFileName_(const std::string& str);

    static void CreateFolder_(const std::string& directory_);
};


///////////////////////////////////////////////////////////////
// IniReader
///////////////////////////////////////////////////////////////
class IniReader
{
public:
    static bool ReadStrA(const std::string& section, const std::string& key_,
        std::string& value_, const std::string& defaultValue,
        const std::string& filePath);

    static int ReadIntA(const std::string& section, const std::string& key_,
        int defaultValue, std::string& filePath);

private:
    static int ReadStr_(const char *section, const char *key_, char *value_,
        int size_, const char *defaultValue, const char *file);
    static int LoadIniFile(const char *file, char *buf, int *file_size);
    static int NewLine(char c);
    static int EndOfStr(char c);
    static int LeftBrace(char c);
    static int RightBrace(char c);
    static int ParseFile(
        const char *section, const char *key_, const char *buf,
        int *sec_s, int *sec_e, int *key_s, int *key_e, int *value_s, int *value_e);
};


///////////////////////////////////////////////////////////////
// MachineID
///////////////////////////////////////////////////////////////
class YAOLOG_EXPORT_API MachineID
{
public:
    // I use MAC address as a machine's unique identifier.
    // Maybe it is not an "absolute unique identifier" in reality,
    // but it is good enough to meet our requirements here.
    static std::string GetMachineID();

private:
#ifdef _YAOLOG_WIN32_
    static long GetMACAddressMSW(unsigned char * result);
#else
    static long GetMACAddressLinux(unsigned char * result);
#endif
};


///////////////////////////////////////////////////////////////
// FileUtil
///////////////////////////////////////////////////////////////
#ifdef _YAOLOG_WIN32_
typedef HANDLE P_FILE;
#else
typedef FILE* P_FILE;
#endif
class FileUtil
{
public:
    static P_FILE Open(const std::string& path_, bool overwrite_);
    static void Write(P_FILE pFile, const char *pBuf, unsigned int bufSize, bool bFlushBuffer);
    static void Close(P_FILE pFile);
    static bool Valid(P_FILE pFile);
	static P_FILE HalfSizeOfFile(P_FILE pFile,const std::string& path_);//日志文件太大的时候需要删除，文件的前半部分

};


///////////////////////////////////////////////////////////////
// Encoding
///////////////////////////////////////////////////////////////
class Encoding
{
public:
    // base64 without newline
    static std::string Base64Encode(const unsigned char *bytes_to_encode, unsigned int in_len);
    static std::string Base64Decode(std::string const& encoded_string);

    // see http://en.wikipedia.org/wiki/Percent-encoding
    static std::string UrlEncode(const std::string& str);
    static std::string UrlDecode(const std::string& str);

private:
    static bool IsBase64(unsigned char c);
    static unsigned char ToHex(unsigned char x);
    static unsigned char FromHex(unsigned char x);
    const static std::string base64_chars;
};


///////////////////////////////////////////////////////////////
// HttpConn
///////////////////////////////////////////////////////////////
class HttpConn
{
public:
    HttpConn(const std::string& host_, int port_);
    ~HttpConn();

    bool connect();
    void close();

    // method_  -> "GET", "POST" etc...
    // path_    -> "/index.html"
    void putrequest(const char *method_, const char *path_);
    void putheader(const std::string& header_, const std::string& value_);
    void putheader(const std::string& header_, int numericvalue);
    void endheaders();
    void send(const unsigned char *buf, int numbytes);
    void rev();

private:
    // Try to work out address from string
    // returns 0 if bad
    struct in_addr host2addr(const char *host_name);

    std::string m_host;
    int m_port;
    int m_sock;
    std::vector<std::string> m_buffer;
};


///////////////////////////////////////////////////////////////
// TinyThread
///////////////////////////////////////////////////////////////
class TinyThread;

struct ThreadStartInfo
{
    void (*pFn)(void *);
    void *pArg;
    int cycleSpanMilliseconds;
    bool *pThreadEnd;
    TinyThread *pThread;
};

class TinyThread
{
public:
    TinyThread();

    void SetSig(int timeout_millisecond);
    void Join(int timeout_millisecond);
    bool Start(
        void (*pFn)(void *),
        void *pArg,
        int cycleSpanMilliseconds,
        bool *pThreadEnd);

private:
#ifdef _YAOLOG_WIN32_
    HANDLE m_handle;
    unsigned int m_threadID;
    HANDLE m_event;
#else
    pthread_t m_handle;
    pthread_cond_t m_cond;
    pthread_mutex_t m_mutex;
#endif

#ifdef _YAOLOG_WIN32_
    static unsigned WINAPI Run(void *pArg);
#else
    static void *Run(void *pArg);
#endif
};


///////////////////////////////////////////////////////////////
// Log classes
///////////////////////////////////////////////////////////////
enum LOG_TYPE
{
    LOG_TYPE_TEXT,
    LOG_TYPE_BIN,
    LOG_TYPE_FORMATTED_BIN
};

enum OUT_FLAG
{
    OUT_FLAG_FILE               = 1<<0,
    OUT_FLAG_STDOUT             = 1<<1,
    OUT_FLAG_REMOTE             = 1<<2,
    OUT_FLAG_OUTPUTDEBUGSTRING  = 1<<3  // windows only
};

struct LogParams
{
    bool bEnable;
    int nOutFlag;
    bool bWithTime;
    bool bWithMillisecond;
    bool bWithSrcFile;
    bool bWithFunction;
    std::string destUrl;

    // for OUT_FLAG_FILE
    bool bOverwrite;              
    bool bFlushBufferImmediately;
    bool bGenNewLogFileDaily;
    std::string logFileDir;
    std::string logFileName;
    
    LogParams()
    {
        Reset();
    }

    void Reset()
    {
        bEnable = false;
        nOutFlag = OUT_FLAG_STDOUT;
        bWithTime = true;
        bWithMillisecond = false;
        bWithSrcFile = false;
        bWithFunction = false;
        destUrl.clear();

        bOverwrite = true;
        bFlushBufferImmediately = false;
        bGenNewLogFileDaily = false;
        logFileDir.clear();
        logFileName.clear();
    }

    bool operator==(const LogParams &lp) const
    {
        return (bEnable == lp.bEnable &&
            nOutFlag == lp.nOutFlag &&
            bWithTime == lp.bWithTime &&
            bWithMillisecond == lp.bWithMillisecond &&
            bWithSrcFile == lp.bWithSrcFile &&
            bWithFunction == lp.bWithFunction &&
            destUrl == lp.destUrl &&
            bOverwrite == lp.bOverwrite &&
            bFlushBufferImmediately == lp.bFlushBufferImmediately &&
            bGenNewLogFileDaily == lp.bGenNewLogFileDaily &&
            logFileDir == lp.logFileDir &&
            logFileName == lp.logFileName);
    }  
};

class BaseLog;

class YAOLOG_EXPORT_API LogFactory
{
public:
    static void Init();
    static void Exit();

    static bool Create(const char *szLogID, bool bEnable, LOG_TYPE logType);

    static BaseLog *Get(const char *szLogID);

    // 1. szDestUrl -> http server address, for example "http://192.168.1.200/default.aspx"
    // 2. post data content:
    //    logID=v1&isText=v2&machineID=v3&logData=v4
    //    v2 -> 0 or 1
    //    v4 -> log data, have used base64encode and urlencode
    static void SetLogAttr(
        const char *szLogID,
        bool bEnable,
        int nOutFlag,
        bool bWithTime,
        bool bWithMillisecond,
        bool bWithSrcFile,
        bool bWithFunction,
        const char *szDestUrl);

    // 1. if szLogFileDir is NULL or "", it means
    //    use default dir -> "module file dir\log\"
    // 2. if szLogFileName is NULL or "", it means
    //    use default filename -> "logID_time.log" or "logID_time.bl"
    // 3. bGenNewLogFileDaily takes effect
    //    only if szLogFileName is NULL or ""
    static void SetLogFileAttr(
        const char *szLogID,
        bool bOverwrite,
        bool bFlushBufferImmediately,
        bool bGenNewLogFileDaily,
        const char *szLogFileDir,
        const char *szLogFileName);

    // szINI: config file name(in module file dir) or config file full path
    static void SetAttrFromConfigFile(const char *szLogID, const char *szINI);

    // call DisableAllLogs(true) will disable all logs totally, 
    // then all logs are disabled and cannot be enable,
    // the only way to cancel it is by calling DisableAllLogs(false)
    static void DisableAllLogs(bool disableAll) { m_disableAll = disableAll; }
    static bool Disabled() { return m_disableAll; }

    static TinyMutex m_tm;

private:
    //static void Destroy(const char *szLogID);
    static bool Exists(const char *szLogID);
    static void BkWorker(void *pArg);
    static void PostData(const std::string& logID, const std::vector<std::string>& logData);

    static std::map<std::string, BaseLog*> m_allLoggers;
    static bool m_threadEnd;
    static TinyThread *m_pTT;
    static bool m_inited;
    static bool m_disableAll;

    LogFactory(const LogFactory&);
    const LogFactory& operator=(const LogFactory&);
};

class YAOLOG_EXPORT_API BaseLog
{
    friend class LogFactory;

public:
    BaseLog(const char *szLogID, bool bEnable);
    virtual ~BaseLog();

    void SetAttr(
        bool bEnable,
        int nOutFlag,
        bool bWithTime,
        bool bWithMillisecond,
        bool bWithSrcFile,
        bool bWithFunction,
        const std::string& destUrl,
        bool bOverwrite,
        bool bFlushBufferImmediately,
        bool bGenNewLogFileDaily,
        const std::string& logFileDir,
        const std::string& logFileName);

    void SetAttrFromConfigFile(const char *szINI);

    const LogParams* GetLogParams() { return &m_params; }

    // LOG_TYPE_FORMATTED_BIN is essentially a text logger
    bool IsTextLog() { return m_logType != LOG_TYPE_BIN; }

    virtual void Log(const char *szSrcFile, const char *szFunction,
        int nLine, const TCHAR *szFormat, ...) = 0;
#ifdef _YAOLOG_WIN32_
    virtual void LogA(const char *szSrcFile, const char *szFunction,
        int nLine, const char *szFormat, ...) = 0;
    virtual void LogW(const char *szSrcFile, const char *szFunction,
        int nLine, const wchar_t *szFormat, ...) = 0;
#endif
    virtual void LogBin(const void *pData, int nSize) = 0;
    virtual void LogFormattedBin(const char *szSrcFile,
        const char *szFunction, int nLine, const char *szTitle,
        const void *pData, int nSize) = 0;

protected:
    LOG_TYPE m_logType;
    LogParams m_params;
    std::string m_iniFullPath;
    std::string m_logFullPath;
    std::string m_logID;
    tm m_localTime;

    bool NewDay();
    bool NeedChangeLogFilePath(
        const LogParams& lp1, const LogParams& lp2);
    void SetLogFilePath();
    bool ParseConfigFile(LogParams& lp);

    // lazy-init: doesn't open the log file until actually start to write...
    P_FILE GetFilePointer();

    int MakeLogText(
        const std::string& str,
        const std::string& srcFile,
        const std::string& function_,
        int nLine);

private:
    BaseLog(const BaseLog&);
    const BaseLog& operator=(const BaseLog&);
};

class YaoLog : public BaseLog
{
public:
    YaoLog(const char *szLogID, bool bEnable);
    virtual ~YaoLog();
    virtual void Log(const char *szSrcFile, const char *szFunction,
        int nLine, const TCHAR *szFormat, ...);
#ifdef _YAOLOG_WIN32_
    virtual void LogA(const char *szSrcFile, const char *szFunction,
        int nLine, const char *szFormat, ...);
    virtual void LogW(const char *szSrcFile, const char *szFunction,
        int nLine, const wchar_t *szFormat, ...);
#endif

private:
    void DoLog(
        const std::string& str,
        const std::string& srcFile,
        const std::string& function_,
        int nLine);

    // unuseful...
    virtual void LogBin(const void *pData, int nSize) { assert(0); }
    virtual void LogFormattedBin(const char *szSrcFile,
        const char *szFunction, int nLine, const char *szTitle,
        const void *pData, int nSize) { assert(0); }
};

class YaoBinLog : public BaseLog
{
public:
    YaoBinLog(const char *szLogID, bool bEnable);
    virtual void LogBin(const void *pData, int nSize);

private:
    // unuseful...
    virtual void Log(const char *szSrcFile, const char *szFunction,
        int nLine, const TCHAR *szFormat, ...) { assert(0); }
#ifdef _YAOLOG_WIN32_
    virtual void LogA(const char *szSrcFile, const char *szFunction,
        int nLine, const char *szFormat, ...) { assert(0); }
    virtual void LogW(const char *szSrcFile, const char *szFunction,
        int nLine, const wchar_t *szFormat, ...) { assert(0); }
#endif
    virtual void LogFormattedBin(const char *szSrcFile,
        const char *szFunction, int nLine, const char *szTitle,
        const void *pData, int nSize) { assert(0); }
};

class YaoFormattedBinLog : public BaseLog
{
public:
    YaoFormattedBinLog(const char *szLogID, bool bEnable);
    virtual void LogFormattedBin(const char *szSrcFile,
        const char *szFunction, int nLine, const char *szTitle,
        const void *pData, int nSize);

private:
    std::string FormatBin(const std::string& title, const void *pData, int nSize);

    // unuseful...
    virtual void Log(const char *szSrcFile, const char *szFunction,
        int nLine, const TCHAR *szFormat, ...) { assert(0); }
#ifdef _YAOLOG_WIN32_
    virtual void LogA(const char *szSrcFile, const char *szFunction,
        int nLine, const char *szFormat, ...) { assert(0); }
    virtual void LogW(const char *szSrcFile, const char *szFunction,
        int nLine, const wchar_t *szFormat, ...) { assert(0); }
#endif
    virtual void LogBin(const void *pData, int nSize) { assert(0); }
};

} // namespace YaoUtil

#ifdef _YAOLOG_WIN32_
#pragma warning(pop)
#endif

#endif // _YAOLOG_H_

//////////////////////////////////////////////////////////
// config file example
//
// [MyLogID]
// Enable = 1
// OutFlag = file|stdout|remote|outputdebugstring
// WithTime = 1
// WithMillisecond = 0
// WithSrcFile = 0
// WithFunction = 0
// DestUrl = http://...
// Overwrite = 1
// FlushBufferImmediately = 0
// GenNewLogFileDaily = 0
// LogFileDir = c:\logfile
// LogFileName = log1.txt
//////////////////////////////////////////////////////////