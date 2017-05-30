package com.mogujie.tt.utils;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

public class MoGuHttpClient {

	private static Logger logger = Logger.getLogger(MoGuHttpClient.class);

	public String uploadImage3(String strUrl, byte[] bytes, String fileName) {
		logger.d("pic#uploadImage3 strUlr:%s", strUrl);
		List<String> list = new ArrayList<String>(); // 要上传的文件名,如：d:\haha.doc.你要实现自己的业务。我这里就是一个空list.
		list.add(fileName);
		try {
			String BOUNDARY = "---------7d4a6d158c9"; // 定义数据分隔线
			URL url = new URL(strUrl);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			// 发送POST请求必须设置如下两行
			conn.setDoOutput(true);
			conn.setDoInput(true);
			conn.setUseCaches(false);
			conn.setRequestMethod("POST");
			conn.setRequestProperty("connection", "Keep-Alive");
			conn.setRequestProperty("user-agent",
					"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)");
			conn.setRequestProperty("Charsert", "UTF-8");
			conn.setRequestProperty("Content-Type",
					"multipart/form-data; boundary=" + BOUNDARY);

			OutputStream out = new DataOutputStream(conn.getOutputStream());
			byte[] end_data = ("\r\n--" + BOUNDARY + "--\r\n").getBytes();// 定义最后数据分隔线
			int leng = list.size();
			for (int i = 0; i < leng; i++) {
				String fname = list.get(i);
				File file = new File(fname);
				StringBuilder sb = new StringBuilder();
				sb.append("--");
				sb.append(BOUNDARY);
				sb.append("\r\n");
				sb.append("Content-Disposition: form-data;name=\"file" + i
						+ "\";filename=\"" + file.getName() + "\"\r\n");
				sb.append("Content-Type:application/octet-stream\r\n\r\n");

				byte[] data = sb.toString().getBytes();
				out.write(data);
				out.write(bytes);
				out.write("\r\n".getBytes()); // 多个文件时，二个文件之间加入这个
			}
			out.write(end_data);
			out.flush();
			out.close();

			// 定义BufferedReader输入流来读取URL的响应
			BufferedReader reader = new BufferedReader(new InputStreamReader(
					conn.getInputStream()));
			String line = null;
			while ((line = reader.readLine()) != null) {
				logger.d("pic#line:%s", line);

				// todo eric
				/*
				 * {"error_code":0,"error_msg":
				 * "成功","path":"g0/000/000/1410706133246550_140184328214.jpg"
				 * ,"url":
				 * "http://122.225.68.125:8001/g0/000/000/1410706133246550_140184328214.jpg"
				 * }
				 */
				JSONObject root = new JSONObject(line);
				return root.getString("url");
			}

		} catch (Exception e) {
			System.out.println("pic#发送POST请求出现异常！" + e);
			e.printStackTrace();
		}

		return "";
	}
}
