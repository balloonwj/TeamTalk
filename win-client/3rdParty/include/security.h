/*================================================================
*   Copyright (C) 2015 All rights reserved.
*   
*   文件名称：security.h
*   �?�?者：Zhang Yuanhao
*   �?   箱：bluefoxah@gmail.com
*   创建日期�?015�?1�?9�?
*   �?   述：
*
#pragma once
================================================================*/

#ifndef __SECURITY_H__
#define __SECURITY_H__


#ifdef __cplusplus
extern "C" {
#endif
    
#ifdef __ANDROID__
    jstring Java_com_mogujie_im_security_EncryptMsg(JNIEnv* env, jobject obj, jstring jstr);
    jstring Java_com_mogujie_im_security_DecryptMsg(JNIEnv* env, jobject obj, jstring jstr);
    jstring Java_com_mogujie_im_security_EncryptPass(JNIEnv* env, jobject obj, jstring jstr, jstring jkey);

#else
    /**
     *  对消息加�?
     *
     *  @param pInData  待加密的消息内容指针
     *  @param nInLen   待加密消息内容长�?
     *  @param pOutData 加密后的文本
     *  @param nOutLen  加密后的文本长度
     *
     *  @return 返回 0-成功; 其他-失败
     */
    int EncryptMsg(const char* pInData, uint32_t nInLen, char** pOutData, uint32_t& nOutLen);
    
    /**
     *  对消息解�?
     *
     *  @param pInData  待解密的消息内容指针
     *  @param nInLen   待解密消息内容长�?
     *  @param pOutData 解密后的文本
     *  @param nOutLen  解密后的文本长度
     *
     *  @return 返回 0-成功; 其他-失败
     */
    int DecryptMsg(const char* pInData, uint32_t nInLen, char** pOutData, uint32_t& nOutLen);
    
    /**
     *  对密码进行加�?
     *
     *  @param pInData  待解密的消息内容指针
     *  @param nInLen   待解密消息内容长�?
     *  @param pOutData 解密后的文本
     *  @param nOutLen  解密后的文本长度
     *  @param pKey     32位密�?
     *
     *  @return 返回 0-成功; 其他-失败
     */
    int EncryptPass(const char* pInData, uint32_t nInLen, char** pOutData, uint32_t& nOutLen);
    
    /**
     *  释放资源
     *
     *  @param pOutData 需要释放的资源
     */
    void Free(char* pOutData);
    
#endif
    
#ifdef __cplusplus
}
#endif

#endif
