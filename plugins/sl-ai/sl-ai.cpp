#include <util/platform.h>
#include <util/dstr.h>
#include <media-io/video-frame.h>
#include <obs-module.h>

#include "NDKApp.h"
#include "ConnectorFrontApi.h"

//bool obs_module_load(void)
//{
//	NDKApp::App::instance().Stop();
//	return true;
//}

/**
* Source
*/

OBS_DECLARE_MODULE()
OBS_MODULE_USE_DEFAULT_LOCALE("sl-ai", "en-US")
MODULE_EXPORT const char *obs_module_description(void)
{
	return "Streamlabs AI";
}

static const char *slai_getname(void *unused)
{
	UNUSED_PARAMETER(unused);
	return obs_module_text("StreamlabsAI");
}

/**
* Filter (Audio)
*/

static const char *slai_faudio_name(void *unused)
{
	UNUSED_PARAMETER(unused);
	return obs_module_text("slai-audio-filter");
}

// Create
static void *slai_faudio_create(obs_data_t *settings, obs_source_t *source)
{
	proc_handler_t *ph = obs_source_get_proc_handler(source);
	proc_handler_add(ph, "void func_load_device(in string input, out string output)", ConnectorFrontApi::func_load_device, data);
	proc_handler_add(ph, "void func_create_send_transport(in string input, out string output)", ConnectorFrontApi::func_create_send_transport, data);
	proc_handler_add(ph, "void func_create_receive_transport(in string input, out string output)", ConnectorFrontApi::func_create_receive_transport, data);
	proc_handler_add(ph, "void func_video_consumer_response(in string input, out string output)", ConnectorFrontApi::func_video_consumer_response, data);
	proc_handler_add(ph, "void func_audio_consumer_response(in string input, out string output)", ConnectorFrontApi::func_audio_consumer_response, data);
	proc_handler_add(ph, "void func_create_audio_producer(in string input, out string output)", ConnectorFrontApi::func_create_audio_producer, data);
	proc_handler_add(ph, "void func_create_video_producer(in string input, out string output)", ConnectorFrontApi::func_create_video_producer, data);
	proc_handler_add(ph, "void func_produce_result(in string input, out string output)", ConnectorFrontApi::func_produce_result, data);
	proc_handler_add(ph, "void func_connect_result(in string input, out string output)", ConnectorFrontApi::func_connect_result, data);
	proc_handler_add(ph, "void func_stop_receiver(in string input, out string output)", ConnectorFrontApi::func_stop_receiver, data);
	proc_handler_add(ph, "void func_stop_sender(in string input, out string output)", ConnectorFrontApi::func_stop_sender, data);
	proc_handler_add(ph, "void func_stop_consumer(in string input, out string output)", ConnectorFrontApi::func_stop_consumer, data);
	proc_handler_add(ph, "void func_stop_producer(in string input, out string output)", ConnectorFrontApi::func_stop_producer, data);

	return source;
}

// Destroy
static void slai_faudio_destroy(void *data)
{
	UNUSED_PARAMETER(data);
}

static struct obs_audio_data *slai_faudio_filter_audio(void *data, struct obs_audio_data *audio)
{
	auto source = static_cast<obs_source_t *>(data);
	auto parent = obs_filter_get_parent(source);
	auto settings = obs_source_get_settings(source);
	std::string producerId = obs_data_get_string(settings, "producerId");
	obs_data_release(settings);

	if (obs_source_muted(parent))
		return audio;

	//const struct audio_output_info *aoi = audio_output_get_info(obs_get_audio());
	//mailbox->assignOutgoingAudioParams(aoi->format, aoi->speakers, static_cast<int>(get_audio_size(aoi->format, aoi->speakers, 1)),
	//				   static_cast<int>(audio_output_get_channels(obs_get_audio())),
	//				   static_cast<int>(audio_output_get_sample_rate(obs_get_audio())));
	//mailbox->assignOutgoingVolume(obs_source_get_volume(parent));
	//mailbox->push_outgoing_audioFrame((const uint8_t **)audio->data, audio->frames);

	return audio;
}

static obs_properties_t *slai_faudio_properties(void *data)
{
	obs_properties_t *props = obs_properties_create();
	UNUSED_PARAMETER(data);
	return props;
}

static void slai_faudio_update(void *data, obs_data_t *settings)
{

}

static void slai_faudio_save(void *data, obs_data_t *settings)
{

}

bool obs_module_load(void)
{
	struct obs_source_info slabsai_connector = {};

	// Filter (Audio)
	struct obs_source_info slabsai_filter_audio = {};
	slabsai_filter_audio.id = "slabsai_afilter";
	slabsai_filter_audio.type = OBS_SOURCE_TYPE_FILTER;
	slabsai_filter_audio.output_flags = OBS_SOURCE_AUDIO;
	slabsai_filter_audio.get_name = slai_faudio_name;
	slabsai_filter_audio.create = slai_faudio_create;
	slabsai_filter_audio.destroy = slai_faudio_destroy;
	slabsai_filter_audio.update = slai_faudio_update;
	slabsai_filter_audio.filter_audio = slai_faudio_filter_audio;
	slabsai_filter_audio.get_properties = slai_faudio_properties;
	slabsai_filter_audio.save = slai_faudio_save;

	obs_register_source(&slabsai_filter_audio);
	return true;
}
