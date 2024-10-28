#include <util/platform.h>
#include <util/dstr.h>
#include <media-io/video-frame.h>

#include "NDKApp.h"

bool obs_module_load(void)
{
	NDKApp::App::instance().Stop();
	return true;
}
