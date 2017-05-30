/******************************************************************************
 *                                                                            *
 * Copyright (c) 1999-2003 Wimba S.A., All Rights Reserved.                   *
 *                                                                            *
 * COPYRIGHT:                                                                 *
 *      This software is the property of Wimba S.A.                           *
 *      This software is redistributed under the Xiph.org variant of          *
 *      the BSD license.                                                      *
 *      Redistribution and use in source and binary forms, with or without    *
 *      modification, are permitted provided that the following conditions    *
 *      are met:                                                              *
 *      - Redistributions of source code must retain the above copyright      *
 *      notice, this list of conditions and the following disclaimer.         *
 *      - Redistributions in binary form must reproduce the above copyright   *
 *      notice, this list of conditions and the following disclaimer in the   *
 *      documentation and/or other materials provided with the distribution.  *
 *      - Neither the name of Wimba, the Xiph.org Foundation nor the names of *
 *      its contributors may be used to endorse or promote products derived   *
 *      from this software without specific prior written permission.         *
 *                                                                            *
 * WARRANTIES:                                                                *
 *      This software is made available by the authors in the hope            *
 *      that it will be useful, but without any warranty.                     *
 *      Wimba S.A. is not liable for any consequence related to the           *
 *      use of the provided software.                                         *
 *                                                                            *
 * Class: OggSpeexWriter.java                                                 *
 *                                                                            *
 * Author: Marc GIMPEL                                                        *
 *                                                                            *
 * Date: 9th April  2003                                                      *
 *                                                                            *
 ******************************************************************************/

/* $Id: OggSpeexWriter.java,v 1.2 2011/12/28 02:45:11 gauss Exp $ */

package com.mogujie.tt.imservice.support.audio;

import com.mogujie.tt.utils.Logger;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Random;

/**
 * Ogg Speex Writer
 * 
 * @author Marc Gimpel, Wimba S.A. (mgimpel@horizonwimba.com)
 * @version $Revision: 1.2 $
 */
public class OggSpeexWriter extends AudioFileWriter {
    private static Logger log = Logger.getLogger(OggSpeexWriter.class);
    /** Number of packets in an Ogg page (must be less than 255) */
    public static final int PACKETS_PER_OGG_PAGE = 250;

    /** The OutputStream */
    private OutputStream out;

    /** Defines the encoder mode (0=NB, 1=WB and 2-UWB). */
    private int mode;
    /** Defines the sampling rate of the audio input. */
    private int sampleRate;
    /** Defines the number of channels of the audio input (1=mono, 2=stereo). */
    private int channels;
    /** Defines the number of frames per speex packet. */
    private int nframes;
    /** Defines whether or not to use VBR (Variable Bit Rate). */
    private boolean vbr;

    /** Ogg Stream Serial Number */
    private int streamSerialNumber;
    /** Data buffer */
    private byte[] dataBuffer;
    /** Pointer within the Data buffer */
    private int dataBufferPtr;
    /** Header buffer */
    private byte[] headerBuffer;
    /** Pointer within the Header buffer */
    private int headerBufferPtr;
    /** Ogg Page count */
    private int pageCount;
    /** Speex packet count within an Ogg Page */
    private int packetCount;
    /**
     * Absolute granule position (the number of audio samples from beginning of
     * file to end of Ogg Packet).
     */
    private long granulepos;

    /**
     * Builds an Ogg Speex Writer.
     */
    public OggSpeexWriter() {
        if (streamSerialNumber == 0)
            streamSerialNumber = new Random().nextInt();
        dataBuffer = new byte[65565];
        dataBufferPtr = 0;
        headerBuffer = new byte[255];
        headerBufferPtr = 0;
        pageCount = 0;
        packetCount = 0;
        granulepos = 0;
    }

    /**
     * Builds an Ogg Speex Writer.
     * 
     * @param mode the mode of the encoder (0=NB, 1=WB, 2=UWB).
     * @param sampleRate the number of samples per second.
     * @param channels the number of audio channels (1=mono, 2=stereo, ...).
     * @param nframes the number of frames per speex packet.
     * @param vbr
     */
    public OggSpeexWriter(final int mode, final int sampleRate, final int channels,
            final int nframes, final boolean vbr) {
        this();
        setFormat(mode, sampleRate, channels, nframes, vbr);
    }

    /**
     * Sets the output format. Must be called before WriteHeader().
     * 
     * @param mode the mode of the encoder (0=NB, 1=WB, 2=UWB).
     * @param sampleRate the number of samples per second.
     * @param channels the number of audio channels (1=mono, 2=stereo, ...).
     * @param nframes the number of frames per speex packet.
     * @param vbr
     */
    private void setFormat(final int mode, final int sampleRate, final int channels,
            final int nframes, boolean vbr) {
        this.mode = mode;
        this.sampleRate = sampleRate;
        this.channels = channels;
        this.nframes = nframes;
        this.vbr = vbr;
    }

    /**
     * Sets the Stream Serial Number. Must not be changed mid stream.
     * 
     * @param serialNumber
     */
    public void setSerialNumber(final int serialNumber) {
        this.streamSerialNumber = serialNumber;
    }

    /**
     * Closes the output file.
     * 
     * @exception IOException if there was an exception closing the Audio
     *                Writer.
     */
    public void close() throws IOException {
        flush(true);
        out.close();
    }

    /**
     * Open the output file.
     * 
     * @param file - file to open.
     * @exception IOException if there was an exception opening the Audio
     *                Writer.
     */
    public void open(final File file) throws IOException {
        file.delete();
        out = new FileOutputStream(file);
    }

    /**
     * Open the output file.
     * 
     * @param filename - file to open.
     * @exception IOException if there was an exception opening the Audio
     *                Writer.
     */
    public void open(final String filename) throws IOException {
        open(new File(filename));
    }

    /**
     * Writes the header pages that start the Ogg Speex file. Prepares file for
     * data to be written.
     * 
     * @param comment description to be included in the header.
     * @exception IOException
     */
    public void writeHeader(final String comment) throws IOException {
        int chksum;
        byte[] header;
        byte[] data;
        /* writes the OGG header page */
        header = buildOggPageHeader(2, 0, streamSerialNumber, pageCount++, 1, new byte[] {
            80
        });
        data = buildSpeexHeader(sampleRate, mode, channels, vbr, nframes);
        chksum = OggCrc.checksum(0, header, 0, header.length);
        chksum = OggCrc.checksum(chksum, data, 0, data.length);
        writeInt(header, 22, chksum);
        out.write(header);
        out.write(data);
        /* writes the OGG comment page */
        header = buildOggPageHeader(0, 0, streamSerialNumber, pageCount++, 1, new byte[] {
            (byte) (comment.length() + 8)
        });
        data = buildSpeexComment(comment);
        chksum = OggCrc.checksum(0, header, 0, header.length);
        chksum = OggCrc.checksum(chksum, data, 0, data.length);
        writeInt(header, 22, chksum);
        out.write(header);
        out.write(data);
    }

    /**
     * Writes a packet of audio.
     * 
     * @param data - audio data.
     * @param offset - the offset from which to start reading the data.
     * @param len - the length of data to read.
     * @exception IOException
     */
    public void writePacket(final byte[] data, final int offset, final int len) throws IOException {
        log.i("**************************data=" + data.toString() + " len=" + len);
        if (len <= 0) { // nothing to write
            return;
        }
        if (packetCount > PACKETS_PER_OGG_PAGE) {
            flush(false);
        }
        System.arraycopy(data, offset, dataBuffer, dataBufferPtr, len);
        dataBufferPtr += len;
        headerBuffer[headerBufferPtr++] = (byte) len;
        packetCount++;
        granulepos += nframes * (mode == 2 ? 640 : (mode == 1 ? 320 : 160));
    }

    /**
     * Flush the Ogg page out of the buffers into the file.
     * 
     * @param eos - end of stream
     * @exception IOException
     */
    private void flush(final boolean eos) throws IOException {
        int chksum;
        byte[] header;
        /* writes the OGG header page */
        header = buildOggPageHeader((eos ? 4 : 0), granulepos, streamSerialNumber, pageCount++,
                packetCount, headerBuffer);
        chksum = OggCrc.checksum(0, header, 0, header.length);
        chksum = OggCrc.checksum(chksum, dataBuffer, 0, dataBufferPtr);
        writeInt(header, 22, chksum);
        out.write(header);
        out.write(dataBuffer, 0, dataBufferPtr);
        dataBufferPtr = 0;
        headerBufferPtr = 0;
        packetCount = 0;
    }
}
