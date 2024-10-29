#include "ConnectorFrontApi.h"

#include <vector>

//calldata_set_string(cd, "output", output.dump().c_str());

void ConnectorFrontApi::func_load_device(void *data, calldata_t *cd)
{
	std::string input = calldata_string(cd, "input");
	blog(LOG_WARNING, "func_load_device %s", input.c_str());
}

void ConnectorFrontApi::func_stop_receiver(void *data, calldata_t *cd)
{
	std::string input = calldata_string(cd, "input");
	blog(LOG_WARNING, "func_stop_receiver %s", input.c_str());
}

void ConnectorFrontApi::func_stop_sender(void *data, calldata_t *cd)
{
	std::string input = calldata_string(cd, "input");
	blog(LOG_WARNING, "func_stop_sender %s", input.c_str());
}

void ConnectorFrontApi::func_stop_consumer(void *data, calldata_t *cd)
{
	std::string input = calldata_string(cd, "input");
	blog(LOG_WARNING, "func_stop_consumer %s", input.c_str());
}

void ConnectorFrontApi::func_stop_producer(void *data, calldata_t *cd)
{
	std::string input = calldata_string(cd, "input");
	blog(LOG_WARNING, "func_stop_producer %s", input.c_str());
}

void ConnectorFrontApi::func_connect_result(void *data, calldata_t *cd)
{
	std::string input = calldata_string(cd, "input");
	blog(LOG_WARNING, "func_connect_result %s", input.c_str());
}

void ConnectorFrontApi::func_produce_result(void *data, calldata_t *cd)
{
	std::string input = calldata_string(cd, "input");
	blog(LOG_WARNING, "func_produce_result %s", input.c_str());
}

void ConnectorFrontApi::func_create_send_transport(void *data, calldata_t *cd)
{
	std::string input = calldata_string(cd, "input");
	blog(LOG_WARNING, "func_create_send_transport %s", input.c_str());
}

void ConnectorFrontApi::func_create_audio_producer(void *data, calldata_t *cd)
{
	std::string input = calldata_string(cd, "input");
	blog(LOG_WARNING, "func_create_audio_producer %s", input.c_str());
}

void ConnectorFrontApi::func_create_video_producer(void *data, calldata_t *cd)
{
	std::string input = calldata_string(cd, "input");
	blog(LOG_WARNING, "func_create_video_producer %s", input.c_str());
}

void ConnectorFrontApi::func_create_receive_transport(void *data, calldata_t *cd)
{
	std::string input = calldata_string(cd, "input");
	blog(LOG_WARNING, "func_create_receive_transport %s", input.c_str());
}

void ConnectorFrontApi::func_video_consumer_response(void *data, calldata_t *cd)
{
	std::string input = calldata_string(cd, "input");
	blog(LOG_WARNING, "func_video_consumer_response %s", input.c_str());
}

void ConnectorFrontApi::func_audio_consumer_response(void *data, calldata_t *cd)
{
	std::string input = calldata_string(cd, "input");
	blog(LOG_WARNING, "func_audio_consumer_response %s", input.c_str());
}

/*void ConnectorFrontApi::GetCanvasFrameData(std::vector<uint8_t>& output)
{
	obs_source_t *source = obs_get_output_source(0); // Gets the main output source.
	if (!source) {
		return {}; // Handle case where no canvas source is available.
	}

	// Increase reference count to ensure source isn't released mid-access
	obs_source_addref(source);

	// Lock the video frame
	obs_source_video_frame *frame = obs_source_get_frame(source);
	if (!frame) {
		obs_source_release(source); // Clean up reference if no frame is available
		return {};                  // Handle case where frame isn't accessible
	}

	uint32_t width = frame->width;
	uint32_t height = frame->height;
	std::vector<uint8_t> pixels(width * height * 4); // Assume RGBA

	// Copy the frame data line by line
	for (uint32_t y = 0; y < height; y++)
		memcpy(pixels.data() + y * width * 4, frame->data[0] + y * frame->linesize[0], width * 4);

	// Release the frame and source references
	obs_source_release_frame(source, frame);
	obs_source_release(source);

	output.swap(pixels);
}*/
