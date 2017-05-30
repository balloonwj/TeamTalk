#include <jni.h>

#include <string.h>
#include <unistd.h>
//#include <speex/speex.h>
//#include <speex/speex_echo.h>

/*start*/
#include <fcntl.h>
#include <speex/speex.h>
#include <speex/speex_echo.h>
#include <speex/speex_preprocess.h>
#include <speex/speex_bits.h>
#include <speex/speex_buffer.h>
#include <speex/speex_header.h>
#include <speex/speex_types.h>

// the header length of the RTP frame (must skip when en/decoding)
static const int rtp_header = 0;

int codec_status = 0;

const int CODEC_OPENED = 1;
const int CODEC_CLOSED = 0;

int aec_status = 0;

const int AEC_OPENED = 1;
const int AEC_CLOSED = 0;

SpeexEchoState *echoState;
SpeexPreprocessState *den;
int sampleRate = 16000;
/*end*/

static int codec_open = 0;

static int dec_frame_size;
static int enc_frame_size;

static SpeexBits ebits, dbits;
void *enc_state;
void *dec_state;

static JavaVM *gJavaVM;

extern "C" JNIEXPORT jint JNICALL Java_com_mogujie_tt_imservice_support_audio_Speex_open(
		JNIEnv *env, jobject obj, jint compression) {
	int tmp = 0;
	if (codec_open++ != 0)
		return (jint) 0;

	speex_bits_init(&ebits);
	speex_bits_init(&dbits);

	enc_state = speex_encoder_init(&speex_nb_mode);
	dec_state = speex_decoder_init(&speex_nb_mode);

	tmp = compression;
	speex_encoder_ctl(enc_state, SPEEX_SET_QUALITY, &tmp);
	speex_encoder_ctl(enc_state, SPEEX_GET_FRAME_SIZE, &enc_frame_size);
	speex_decoder_ctl(dec_state, SPEEX_GET_FRAME_SIZE, &dec_frame_size);

	SpeexPreprocessState * m_st;
	m_st = speex_preprocess_state_init(enc_frame_size, 8000);
	int denoise = 1;
	int noiseSuppress = -25;
	speex_preprocess_ctl(m_st, SPEEX_PREPROCESS_SET_DENOISE, &denoise);
	speex_preprocess_ctl(m_st, SPEEX_PREPROCESS_SET_NOISE_SUPPRESS,
			&noiseSuppress);

	return (jint) 0;
}

extern "C" JNIEXPORT jint JNICALL Java_com_mogujie_tt_imservice_support_audio_Speex_encode(
		JNIEnv *env, jobject obj, jshortArray lin, jint offset,
		jbyteArray encoded, jint size) {

	jshort buffer[enc_frame_size];
	jbyte output_buffer[enc_frame_size];
	int nsamples = (size - 1) / enc_frame_size + 1;
	int i, tot_bytes = 0;

	if (!codec_open)
		return 0;

	speex_bits_reset(&ebits);

	for (i = 0; i < nsamples; i++) {
		env->GetShortArrayRegion(lin, offset + i * enc_frame_size,
				enc_frame_size, buffer);
		speex_encode_int(enc_state, buffer, &ebits);
	}
	//env->GetShortArrayRegion(lin, offset, enc_frame_size, buffer);
	//speex_encode_int(enc_state, buffer, &ebits);

	tot_bytes = speex_bits_write(&ebits, (char *) output_buffer,
			enc_frame_size);
	env->SetByteArrayRegion(encoded, 0, tot_bytes, output_buffer);

	return (jint) tot_bytes;
}

extern "C" JNIEXPORT jint Java_com_mogujie_tt_imservice_support_audio_Speex_decode(
		JNIEnv *env, jobject obj, jbyteArray encoded, jshortArray lin,
		jint size) {

	jbyte buffer[dec_frame_size];
	jshort output_buffer[dec_frame_size];
	jsize encoded_length = size;

	if (!codec_open)
		return 0;

	env->GetByteArrayRegion(encoded, 0, encoded_length, buffer);
	speex_bits_read_from(&dbits, (char *) buffer, encoded_length);
	speex_decode_int(dec_state, &dbits, output_buffer);
	env->SetShortArrayRegion(lin, 0, dec_frame_size, output_buffer);

	return (jint) dec_frame_size;
}

extern "C" JNIEXPORT jint JNICALL Java_com_mogujie_tt_imservice_support_audio_Speex_getFrameSize(
		JNIEnv *env, jobject obj) {

	if (!codec_open)
		return 0;
	return (jint) enc_frame_size;

}

extern "C" JNIEXPORT void JNICALL Java_com_mogujie_tt_imservice_support_audio_Speex_close(
		JNIEnv *env, jobject obj) {

	if (--codec_open != 0)
		return;

	speex_bits_destroy(&ebits);
	speex_bits_destroy(&dbits);
	speex_decoder_destroy(dec_state);
	speex_encoder_destroy(enc_state);
}

extern "C" JNIEXPORT void Java_com_mogujie_tt_imservice_support_audio_Speex_initEcho(
		JNIEnv *env, jobject jobj, jint frame_size, jint filter_length) {
	if (aec_status == AEC_OPENED)
		return;
	aec_status = AEC_OPENED;

	int frm_size;
	int f_length;

	frm_size = frame_size;
	f_length = filter_length;

	echoState = speex_echo_state_init(frame_size, filter_length);
	den = speex_preprocess_state_init(frame_size, sampleRate);
	speex_echo_ctl(echoState, SPEEX_ECHO_SET_SAMPLING_RATE, &sampleRate);
	speex_preprocess_ctl(den, SPEEX_PREPROCESS_SET_ECHO_STATE, echoState);
}

extern "C" JNIEXPORT void Java_com_mogujie_tt_imservice_support_audio_Speex_echoCancellation(
		JNIEnv *env, jshortArray rec, jshortArray play, jshortArray out) {

	jshort echo_buf[enc_frame_size];
	jshort ref_buf[enc_frame_size];
	jshort e_buf[enc_frame_size];

	env->GetShortArrayRegion(rec, 0, enc_frame_size, echo_buf);
	env->GetShortArrayRegion(play, 0, enc_frame_size, ref_buf);

	speex_echo_cancellation(echoState, echo_buf, ref_buf, e_buf);
// speex_preprocess_run(den, e_buf);

	env->SetShortArrayRegion(out, 0, enc_frame_size, e_buf);

}

extern "C" JNIEXPORT int Java_com_mogujie_tt_imservice_support_audio_Speex_echoCancellationEncode(
		JNIEnv *env, jshortArray rec, jshortArray play, jbyteArray encoded) {

	jshort echo_buf[enc_frame_size];
	jshort ref_buf[enc_frame_size];
	jshort e_buf[enc_frame_size];
	jbyte output_buffer[enc_frame_size];

	env->GetShortArrayRegion(rec, 0, enc_frame_size, echo_buf);
	env->GetShortArrayRegion(play, 0, enc_frame_size, ref_buf);

	speex_echo_cancellation(echoState, echo_buf, ref_buf, e_buf);
	speex_preprocess_run(den, e_buf);

	speex_bits_reset(&ebits);

	speex_encode_int(enc_state, e_buf, &ebits);

	jint tot_bytes = speex_bits_write(&ebits, (char *) output_buffer,
			enc_frame_size);
	env->SetByteArrayRegion(encoded, 0, tot_bytes, output_buffer);

	return (jint) tot_bytes;
}

extern "C" JNIEXPORT jint JNICALL Java_com_mogujie_tt_imservice_support_audio_Speex_getAecStatus() {
	return (jint) aec_status;
}

extern "C" JNIEXPORT void Java_com_mogujie_tt_imservice_support_audio_Speex_destroyEcho(
		JNIEnv * env, jobject jobj) {
	if (aec_status == AEC_CLOSED)
		return;
	aec_status = AEC_CLOSED;

	speex_echo_state_destroy(echoState);
	speex_preprocess_state_destroy(den);
}

