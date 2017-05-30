/* Copyright (c) 2002, John Edwards

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

   - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   - Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   - Neither the name of the Xiph.org Foundation nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

/* Set TABS = 4 */
/********************************************************************

 function: To provide playback of 16 bit PCM wave data in Win32
           environments from decoded compressed files.

 ********************************************************************/

#if defined WIN32 || defined _WIN32

#include <string.h>
#include <errno.h>
#include "wave_out.h"
#include <windows.h>

#define MAXWAVESIZE     4294967040LU
#define MAX_WAVEBLOCKS    32

// This is modified for USE_WIN_AUDIO - ONLY 2002-02-27


CRITICAL_SECTION  cs;
static HWAVEOUT          dev                    = NULL;
static int               ScheduledBlocks        = 0;
static int               PlayedWaveHeadersCount = 0;          // free index
static WAVEHDR*          PlayedWaveHeaders [MAX_WAVEBLOCKS];
UINT g_sPlayFinished = 0;
BOOL g_bEnd = FALSE;
char* g_audioFile = 0;
extern HWND g_hMsgWindow;
extern int WriteDebugLog(char *str);
extern uintptr_t _beginthread(void( __cdecl *start_address )( void * ),unsigned stack_size,void *arglist );
extern BOOL sendTeamTalkMessage(const PCOPYDATASTRUCT cpyData);

DWORD playSpeexAudio(LPVOID pParam);

static int
Box ( const char* msg )
{
	MessageBox ( NULL, msg, " "VERSION_STRING": Error Message . . .", MB_OK | MB_ICONEXCLAMATION );
	return -1;
}

/*
 *  This function registers already played WAVE chunks. Freeing is done by free_memory(),
 */

static void CALLBACK
wave_callback ( HWAVE hWave, UINT uMsg, DWORD dwInstance, DWORD dwParam1, DWORD dwParam2 )
{
    if ( uMsg == WOM_DONE ) 
    {
        EnterCriticalSection ( &cs );
        PlayedWaveHeaders [PlayedWaveHeadersCount++] = (WAVEHDR*) dwParam1;
        LeaveCriticalSection ( &cs );
    }
}


static void
free_memory ( void )
{
	WAVEHDR*  wh;
	HGLOBAL   hg;

	EnterCriticalSection ( &cs );
	wh = PlayedWaveHeaders [--PlayedWaveHeadersCount];
	ScheduledBlocks--;                               // decrease the number of USED blocks
	LeaveCriticalSection ( &cs );

	waveOutUnprepareHeader ( dev, wh, sizeof (WAVEHDR) );

	hg = GlobalHandle ( wh -> lpData );       // Deallocate the buffer memory
	GlobalUnlock (hg);
	GlobalFree   (hg);

	hg = GlobalHandle ( wh );                 // Deallocate the header memory
	GlobalUnlock (hg);
	GlobalFree   (hg);
}


Int
Set_WIN_Params ( FILE_T   dummyFile ,
                 Ldouble  SampleFreq,
                 Uint     BitsPerSample,
                 Uint     Channels )
{
	WAVEFORMATEX  outFormat;
	UINT          deviceID = WAVE_MAPPER;
    g_sPlayFinished = RegisterWindowMessage("TeamTalk_msg_950E5225_F4A8_4b92_B339_6013154BA4F1");

	(void) dummyFile;

	outFormat.wFormatTag      = WAVE_FORMAT_PCM;
	outFormat.wBitsPerSample  = BitsPerSample;
	outFormat.nChannels       = Channels;
	outFormat.nSamplesPerSec  = (unsigned long)(SampleFreq + 0.5);
	outFormat.nBlockAlign     = (outFormat.wBitsPerSample + 7) / 8 * outFormat.nChannels;
	outFormat.nAvgBytesPerSec = outFormat.nSamplesPerSec * outFormat.nBlockAlign;

	switch ( waveOutOpen ( &dev, deviceID, &outFormat, (DWORD)wave_callback, 0, CALLBACK_FUNCTION /*| WAVE_ALLOWSYNC*/ ) )
	{
		case MMSYSERR_ALLOCATED:   return WriteDebugLog("Device is already open.");
		case MMSYSERR_BADDEVICEID: return WriteDebugLog("The specified device is out of range." );
		case MMSYSERR_NODRIVER:    return WriteDebugLog("There is no audio driver in this system." );
		case MMSYSERR_NOMEM:       return WriteDebugLog("Unable to allocate sound memory." );
		case WAVERR_BADFORMAT:     return WriteDebugLog("This audio format is not supported." );
		case WAVERR_SYNC:          return WriteDebugLog("The device is synchronous." );
		default:                   return WriteDebugLog("Unknown media error." );
		case MMSYSERR_NOERROR:     break;
	}

	waveOutReset ( dev );
	SetPriorityClass ( GetCurrentProcess (), HIGH_PRIORITY_CLASS );
	return 0;
}


int
WIN_Play_Samples ( const void* data, size_t len )
{
	HGLOBAL    hg;
	HGLOBAL    hg2;
	LPWAVEHDR  wh;
	void*      allocptr;

	do {
		while ( PlayedWaveHeadersCount > 0 )                // free used blocks ...
			free_memory ();

		if ( ScheduledBlocks < sizeof(PlayedWaveHeaders)/sizeof(*PlayedWaveHeaders) ) // wait for a free block ...
			break;
		Sleep (26);
	} while (1);

	if ( (hg2 = GlobalAlloc ( GMEM_MOVEABLE, len )) == NULL )   // allocate some memory for a copy of the buffer
		return WriteDebugLog ( "GlobalAlloc failed." );

	allocptr = GlobalLock (hg2);
	CopyMemory ( allocptr, data, len );                         // Here we can call any modification output functions we want....

	if ( (hg = GlobalAlloc (GMEM_MOVEABLE | GMEM_ZEROINIT, sizeof (WAVEHDR))) == NULL ) // now make a header and WRITE IT!
		return -1;

	wh                   = GlobalLock (hg);
	wh -> dwBufferLength = (DWORD)len;
	wh -> lpData         = allocptr;

	if ( waveOutPrepareHeader ( dev, wh, sizeof (WAVEHDR)) != MMSYSERR_NOERROR ) {
		GlobalUnlock (hg);
		GlobalFree   (hg);
		return -1;
	}

	if ( waveOutWrite ( dev, wh, sizeof (WAVEHDR)) != MMSYSERR_NOERROR ) {
		GlobalUnlock (hg);
		GlobalFree   (hg);
		return -1;
	}

	EnterCriticalSection ( &cs );
	ScheduledBlocks++;
	LeaveCriticalSection ( &cs );

	return (int)len;
}


int
WIN_Audio_close ( void )
{
	if ( dev != NULL ) 
    {
		while ( ScheduledBlocks > 0 ) {
			Sleep (ScheduledBlocks);
			while ( PlayedWaveHeadersCount > 0 )         // free used blocks ...
				free_memory ();
		}

		waveOutReset (dev);      // reset the device
		waveOutClose (dev);      // close the device
		dev = NULL;
	}
	ScheduledBlocks = 0;

	return 0;
}

void startPlayAudio(char* inFile)
{
    char* inFileCopy = 0;
    size_t length = strlen(inFile);
    if(0 == length)
        return;

    inFileCopy = (char*)malloc(length + 1);
    memset(inFileCopy,0,length + 1);
    memcpy(inFileCopy,inFile,length + 1);
    _beginthread(playSpeexAudio,0, inFileCopy);
}

LRESULT CALLBACK StartupMsgWndProc(HWND hWnd, UINT nMsg, WPARAM wParam, LPARAM lParam)
{
    PCOPYDATASTRUCT pCpyData = 0;
    switch(nMsg)
    {
        case WM_COPYDATA:
        {
            pCpyData = (PCOPYDATASTRUCT) lParam;
            if(1 == pCpyData->dwData) //1 表示退出进程
            {
                PostMessage(g_hMsgWindow,WM_QUIT,0,0);
                WriteDebugLog("break playing by TeamTalk");
            }
            break;
        }
    }

    return DefWindowProc(hWnd, nMsg, wParam, lParam);
}

void MessagePump()
{
    MSG	msg;
    while(GetMessage(&msg, NULL, 0, 0) > 0)
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
}

DWORD CreatWindow(LPVOID pParam)
{
    TCHAR	WND_CLASS_NAME[] = TEXT("teamtalkspeexdecWindow");
    TCHAR	WND_NAME[] = TEXT("teamtalkaudio-speexdecWindow");

    WNDCLASSEX	wc;
    ZeroMemory(&wc, sizeof(wc));
    wc.cbSize = sizeof(wc);
    wc.hInstance = GetModuleHandle(NULL);
    wc.lpfnWndProc = StartupMsgWndProc;
    wc.lpszClassName = WND_CLASS_NAME;
    RegisterClassEx(&wc);

    g_hMsgWindow = CreateWindow(WND_CLASS_NAME,
        WND_NAME, 
        (WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN | WS_CLIPSIBLINGS),
        0, 0, 0, 0,
        NULL,
        NULL,
        GetModuleHandle(NULL),
        NULL
        );
    return 0;
}

#endif

/* end of wave_out.c */
