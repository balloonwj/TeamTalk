package com.mogujie.tt.protobuf.base;

import com.mogujie.tt.utils.Logger;

import org.jboss.netty.buffer.ChannelBuffer;
import org.jboss.netty.buffer.ChannelBuffers;

import java.nio.charset.Charset;

/**
 * 数据缓冲区对象(ChannelBuffer)
 * 
 * @author Nana
 */
public class DataBuffer {

	public ChannelBuffer buffer;
	private static Logger logger = Logger.getLogger(DataBuffer.class);

	public DataBuffer() {
		buffer = ChannelBuffers.dynamicBuffer();
	}

	public DataBuffer(ChannelBuffer binaryBuffer) {
		buffer = binaryBuffer;
	}

	public DataBuffer(int length) {
		buffer = ChannelBuffers.buffer(length);
	}

	public byte[] array() {
		return buffer.array();
	}

	public void setOrignalBuffer(ChannelBuffer buffer) {
		this.buffer = buffer;
	}

	public ChannelBuffer getOrignalBuffer() {
		return buffer;
	}

	public void writeByte(int value) {
		buffer.writeByte(value);
	}

	public byte readByte() {
		return buffer.readByte();
	}

	public byte[] readBytes(int length) {
		byte[] bytes = new byte[length];
		buffer.readBytes(bytes);
		return bytes;
	}

	public int readInt() {
		if (buffer.readable()) {
			return buffer.readInt();
		} else {
			return 0;
		}
	}

	public void writeShort(short value) {
		buffer.writeShort(value);
	}

	public short readShort() {
		if (buffer.readable()) {
			return buffer.readShort();
		} else {
			return 0;
		}
	}

	public void writeInt(int value) {
		buffer.writeInt(value);
	}

	public char readChar() {
		return buffer.readChar();
	}

	public void writeChar(char c) {
		buffer.writeChar(c);
	}

	public long readLong() {
		return buffer.readLong();
	}

	public void writeLong(long value) {
		buffer.writeLong(value);
	}

	public double readDouble() {
		return buffer.readDouble();
	}

	public void writeDouble(double value) {
		buffer.writeDouble(value);
	}

	/**
	 * 读取一个字符串
	 * 
	 * @return 格式：前导length表示字符串的byte数 length(4字节)string(length字节)
	 */
	public String readString() {
		int length = readInt();
//		logger.d("debug#length:%d", length);
		
		byte[] bytes = readBytes(length);

		return new String(bytes, Charset.forName("utf8"));
	}

	public String readString(int length) {
		byte[] bytes = readBytes(length);

		return new String(bytes);
	}

	public void writeBytes(byte[] bytes) {
		buffer.writeBytes(bytes);
	}

	public void writeSourceBytes(byte[] bytes) {
		writeInt(bytes.length);
		buffer.writeBytes(bytes);
	}

	/**
	 * 读取int数组
	 * 
	 * @return 格式：前导count表示数组中有多少个元素 count(4字节)int1(4字节)...intCount(4字节)
	 */
	public int[] readIntArray() {
		int count = readInt();
		int[] intArray = new int[count];
		for (int i = 0; i < count; i++) {
			intArray[i] = readInt();
		}
		return intArray;
	}

	/**
	 * 写入int数组
	 * 
	 * @param intArray
	 *            格式见readIntArray()
	 */
	public void writeIntArray(int[] intArray) {
		int count = intArray.length;
		writeInt(count);
		for (int i = 0; i < count; i++) {
			writeInt(intArray[i]);
		}
	}

	/**
	 * 获取有效(可读取)的byte数
	 * 
	 * @return
	 */
	public int readableBytes() {
		return buffer.readableBytes();
	}

	public DataBuffer readDataBuffer() {
		if (null == buffer || buffer.readableBytes() == 0) {
			return new DataBuffer(0);
		}
		int length = readInt();
		DataBuffer dataBuffer = new DataBuffer(0);
		dataBuffer.setOrignalBuffer(buffer.readBytes(length));
		return dataBuffer;
	}

	public void writeDataBuffer(DataBuffer inputBuffer) {
		if (null == inputBuffer || inputBuffer.readableBytes() == 0) {
			return;
		}
		buffer.writeBytes(inputBuffer.buffer);
	}

	public void resetReaderIndex() {
		buffer.resetReaderIndex();
	}

	public void resetWriterIndex() {
		buffer.resetWriterIndex();
	}
}
