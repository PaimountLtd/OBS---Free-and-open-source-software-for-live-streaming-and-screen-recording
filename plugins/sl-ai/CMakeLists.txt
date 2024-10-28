cmake_minimum_required(VERSION 3.22...3.25)

# ----------------------
# -- SL AI PLUGIN --
# ----------------------

if(MSVC)
	set(sl-ai_PLATFORM_DEPS
		w32-pthreads)
endif()

# WEBRTC_INCLUDE_PATH must use forward slashes
set(sl-ai_SOURCES
	sl-ai.cpp)

add_library(sl-ai MODULE
	${sl-ai_SOURCES})

add_library(OBS::sl-ai ALIAS sl-ai)

target_compile_options(sl-ai PRIVATE "$<IF:$<CONFIG:Debug>,/MTd,/MT>" /wd4100)

target_link_libraries(sl-ai
	OBS::libobs
	${sl-ai_PLATFORM_DEPS})

if(MSVC)
	target_link_libraries(sl-ai Iphlpapi.lib)
endif()

set_target_properties(sl-ai PROPERTIES FOLDER "plugins")

set_property(TARGET sl-ai PROPERTY CXX_STANDARD 20)
set_property(TARGET sl-ai PROPERTY CXX_STANDARD_REQUIRED ON)

setup_plugin_target(sl-ai PROPERTIES FOLDER plugins PREFIX "")
