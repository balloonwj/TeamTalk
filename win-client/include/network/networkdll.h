#ifdef WIN32
	#ifdef NETWORK_EXPORTS
		#define NETWORK_DLL __declspec(dllexport)
	#else
		#define NETWORK_DLL __declspec(dllimport)
	#endif
#else
		#define NETWORK_DLL
#endif
