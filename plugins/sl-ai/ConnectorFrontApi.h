#pragma once

#include <obs-module.h>

class ConnectorFrontApi
{
public:
	static void func_load_device(void *data, calldata_t *cd);
	static void func_create_send_transport(void *data, calldata_t *cd);
	static void func_create_receive_transport(void *data, calldata_t *cd);
	static void func_video_consumer_response(void *data, calldata_t *cd);
	static void func_audio_consumer_response(void *data, calldata_t *cd);
	static void func_create_audio_producer(void *data, calldata_t *cd);
	static void func_create_video_producer(void *data, calldata_t *cd);
	static void func_produce_result(void *data, calldata_t *cd);
	static void func_connect_result(void *data, calldata_t *cd);
	static void func_stop_receiver(void *data, calldata_t *cd);
	static void func_stop_sender(void *data, calldata_t *cd);
	static void func_stop_consumer(void *data, calldata_t *cd);
	static void func_stop_producer(void *data, calldata_t *cd);

private:
};
