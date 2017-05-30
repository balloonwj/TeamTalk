#include "network/util.h"
#include <sstream>
using namespace std;


CRefObject::CRefObject()
{
	m_lock = NULL;
	m_refCount = 1;
}

CRefObject::~CRefObject()
{

}

void CRefObject::AddRef()
{
	if (m_lock)
	{
		m_lock->lock();
		m_refCount++;
		m_lock->unlock();
	}
	else
	{
		m_refCount++;
	}
}

void CRefObject::ReleaseRef()
{
	if (m_lock)
	{
		m_lock->lock();
		m_refCount--;
		if (m_refCount == 0)
		{
			delete this;
			return;
		}
		m_lock->unlock();
	}
	else
	{
		m_refCount--;
		if (m_refCount == 0)
			delete this;
	}
}

uint64_t get_tick_count()
{
#ifdef _MSC_VER
	LARGE_INTEGER liCounter; 
	LARGE_INTEGER liCurrent;

	if (!QueryPerformanceFrequency(&liCounter))
		return GetTickCount();

	QueryPerformanceCounter(&liCurrent);
	return (uint64_t)(liCurrent.QuadPart * 1000 / liCounter.QuadPart);
#else
	struct timeval tval;
	uint64_t ret_tick;

	gettimeofday(&tval, NULL);

	ret_tick = tval.tv_sec * 1000L + tval.tv_usec / 1000L;
	return ret_tick;
#endif
}

void util_sleep(uint32_t millisecond)
{
#ifdef _MSC_VER
	Sleep(millisecond);
#else
	usleep(millisecond * 1000);
#endif
}

CStrExplode::CStrExplode(char* str, char seperator)
{
	m_item_cnt = 1;
	char* pos = str;
	while (*pos) {
		if (*pos == seperator) {
			m_item_cnt++;
		}

		pos++;
	}

	m_item_list = new char* [m_item_cnt];

	int idx = 0;
	char* start = pos = str;
	while (*pos) {
		if (*pos == seperator) {
			uint32_t len = pos - start;
			m_item_list[idx] = new char [len + 1];
			strncpy(m_item_list[idx], start, len);
			m_item_list[idx][len]  = '\0';
			idx++;

			start = pos + 1;
		}

		pos++;
	}

	uint32_t len = pos - start;
	m_item_list[idx] = new char [len + 1];
	strncpy(m_item_list[idx], start, len);
	m_item_list[idx][len]  = '\0';
}

CStrExplode::~CStrExplode()
{
	for (uint32_t i = 0; i < m_item_cnt; i++) {
		delete [] m_item_list[i];
	}

	delete [] m_item_list;
}

////////
string int2string(uint32_t user_id)
{
	stringstream ss;
	ss << user_id;
	return ss.str();
}

uint32_t string2int(const string& value)
{
    return (uint32_t)atoi(value.c_str());
}

// 由于被替换的内容可能包含?号，所以需要更新开始搜寻的位置信息来避免替换刚刚插入的?号
void replace_mark(string& str, string& new_value, uint32_t& begin_pos)
{
	string::size_type pos = str.find('?', begin_pos);
	if (pos == string::npos) {
		return;
	}

	string prime_new_value = "'"+ new_value + "'";
	str.replace(pos, 1, prime_new_value);

	begin_pos = pos + prime_new_value.size();
}

void replace_mark(string& str, uint32_t new_value, uint32_t& begin_pos)
{
	stringstream ss;
	ss << new_value;

	string str_value = ss.str();
	string::size_type pos = str.find('?', begin_pos);
	if (pos == string::npos) {
		return;
	}

	str.replace(pos, 1, str_value);
	begin_pos = pos + str_value.size();
}

char* replaceStr(char* pSrc, char oldChar, char newChar)
{
    if(NULL == pSrc)
    {
        return NULL;
    }
    
    char *pHead = pSrc;
    while (*pHead != '\0') {
        if(*pHead == oldChar)
        {
            *pHead = newChar;
        }
        ++pHead;
    }
    return pSrc;
}

size_t get_file_size(const char *path)
{
	size_t filesize = -1;
    struct stat statbuff;
    if(stat(path, &statbuff) < 0){
        return filesize;
    }else{
        filesize = statbuff.st_size;
    }
    return filesize;
}

char* long2ip(const unsigned int in)
{
    unsigned short v1, v2, v3, v4;
    v4 = in % 256;
    v3 = (in >> 8) % 256;
    v2 = (in >> 16) % 256;
    v1 = (in >> 24) % 256;
    static char output[16];
    snprintf(output,sizeof(output), "%hd.%hd.%hd.%hd",v1,v2, v3, v4);
    return output;
}

unsigned int ip2long(const char* ip)
{
    unsigned short v1, v2, v3, v4;
    sscanf(ip, "%hd.%hd.%hd.%hd", &v1,&v2, &v3, &v4);
    unsigned int vl =  (v1<<24) + (v2<<16) + (v3<<8) + v4;
    return vl;
}

void writePid()
{
	uint32_t curPid;
#ifdef _MSC_VER
	curPid = (uint32_t) GetCurrentProcess();
#else
	curPid = (uint32_t) getpid();
#endif
    FILE* f = fopen("server.pid", "w");
    assert(f);
    char szPid[32];
    snprintf(szPid, sizeof(szPid), "%d", curPid);
    fwrite(szPid, strlen(szPid), 1, f);
    fclose(f);
}