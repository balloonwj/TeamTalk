package com.mogujie.tt.utils;

import android.util.Log;

import java.util.List;

public class DumpUtils {
	public static void dumpStringList(Logger logger, String desc,
			List<String> memberList) {
		String log = String.format("%s, members:", desc);
		for (String memberId : memberList) {
			log += memberId + ",";
		}

		logger.d("%s", log);
	}

    public static void dumpIntegerList(Logger logger, String desc,
                                      List<Integer> memberList) {
        String log = String.format("%s, members:", desc);
        for (int memberId : memberList) {
            log += memberId + ",";
        }

        logger.d("%s", log);
    }

	//oneLine for purpose of "tail -f", so you can track them at one line
	public static void dumpStacktrace(Logger logger, String desc,
			boolean oneLine) {
		String stackTraceString = Log.getStackTraceString(new Throwable());

		if (oneLine) {
			stackTraceString = stackTraceString.replace("\n", "####");
		}
		
		logger.d("%s:%s", desc, stackTraceString);
	}
}
