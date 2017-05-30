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
 * Class: OggCrc.java                                                         *
 *                                                                            *
 * Author: Marc GIMPEL                                                        *
 * Based on code by: Ross WILLIAMS                                            *
 *                                                                            *
 * Date: 20th April  2003                                                     *
 *                                                                            *
 ******************************************************************************/

/* $Id: OggCrc.java,v 1.1 2011/12/27 04:39:13 gauss Exp $ */

/********************************************************************
 *                                                                  *
 * THIS FILE IS PART OF THE OggVorbis SOFTWARE CODEC SOURCE CODE.   *
 * USE, DISTRIBUTION AND REPRODUCTION OF THIS LIBRARY SOURCE IS     *
 * GOVERNED BY A BSD-STYLE SOURCE LICENSE INCLUDED WITH THIS SOURCE *
 * IN 'COPYING'. PLEASE READ THESE TERMS BEFORE DISTRIBUTING.       *
 *                                                                  *
 * THE OggVorbis SOURCE CODE IS (C) COPYRIGHT 1994-2002             *
 * by the Xiph.Org Foundation http://www.xiph.org/                  *
 *                                                                  *
 ********************************************************************

 function: code raw [Vorbis] packets into framed OggSquish stream and
 decode Ogg streams back into raw packets
 last mod: $Id: OggCrc.java,v 1.1 2011/12/27 04:39:13 gauss Exp $

 note: The CRC code is directly derived from public domain code by
 Ross Williams (ross@guest.adelaide.edu.au).  See docs/framing.html
 for details.

 ********************************************************************/

package com.mogujie.tt.imservice.support.audio;

/**
 * Calculates the CRC checksum for Ogg packets.
 * <p>
 * Ogg uses the same generator polynomial as ethernet, although with an
 * unreflected alg and an init/final of 0, not 0xffffffff.
 * 
 * @author Jim Lawrence, helloNetwork.com
 * @author Marc Gimpel, Wimba S.A. (mgimpel@horizonwimba.com)
 * @version $Revision: 1.1 $
 */
public class OggCrc
{
    // TODO - implement java.util.zip.Checksum

    /**
     * CRC checksum lookup table
     */
    private static int[] crc_lookup;

    static {
        crc_lookup = new int[256];
        for (int i = 0; i < crc_lookup.length; i++) {
            int r = i << 24;
            for (int j = 0; j < 8; j++) {
                if ((r & 0x80000000) != 0) {
                    /*
                     * The same as the ethernet generator polynomial, although
                     * we use an unreflected alg and an init/final of 0, not
                     * 0xffffffff
                     */
                    r = (r << 1) ^ 0x04c11db7;
                }
                else {
                    r <<= 1;
                }
            }
            crc_lookup[i] = (r & 0xffffffff);
        }
    }

    /**
     * Calculates the checksum on the given data, from the give offset and for
     * the given length, using the given initial value. This allows on to
     * calculate the checksum iteratively, by reinjecting the last returned
     * value as the initial value when the function is called for the next data
     * chunk. The initial value should be 0 for the first iteration.
     * 
     * @param crc - the initial value
     * @param data - the data
     * @param offset - the offset at which to start calculating the checksum.
     * @param length - the length of data over which to calculate the checksum.
     * @return the checksum.
     */
    public static int checksum(int crc,
            final byte[] data,
            int offset,
            final int length)
    {
        int end = offset + length;
        for (; offset < end; offset++) {
            crc = (crc << 8) ^ crc_lookup[((crc >>> 24) & 0xff) ^ (data[offset] & 0xff)];
        }
        return crc;
    }
}
