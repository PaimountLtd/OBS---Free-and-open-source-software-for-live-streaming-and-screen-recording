cmake_minimum_required(VERSION 3.22...3.25)

# ----------------------
# -- SL AI PLUGIN --
# ----------------------

set(sl-ai_SOURCES
	sl-ai.cpp
	NDKApp.cpp
	NDKApp.h
)

add_library(sl-ai MODULE
	${sl-ai_SOURCES})

add_library(OBS::sl-ai ALIAS sl-ai)

#target_compile_options(sl-ai PRIVATE "$<IF:$<CONFIG:Debug>,/MTd,/MT>" /wd4100)
target_compile_features(sl-ai PRIVATE cxx_std_20)

target_link_libraries(sl-ai
    OBS::libobs
    w32-pthreads
    
    # TODO
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/inworld-ndk.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/inworld-ndk.dll.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/inworld-ndk-proto.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_bad_optional_access.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_base.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_cord.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_graphcycles_internal.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_int128.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_malloc_internal.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_raw_logging_internal.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_spinlock_wait.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_stacktrace.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_status.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_statusor.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_strings.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_strings_internal.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_str_format_internal.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_symbolize.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_synchronization.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_throw_delegate.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_time.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/absl_time_zone.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/address_sorting.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/cares.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/gpr.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/grpc++.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/grpc.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/libcrypto.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/libprotobuf.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/libssl.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/re2.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/spdlog.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/upb.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/webrtc_aec_plugin.lib
    C:/Users/srogers/Desktop/inworld-ndk-built/lib/Win64/zlibstatic.lib
    
    ws2_32.lib
    advapi32.lib
    iphlpapi.lib
    Crypt32.lib
)
  
# TODO
target_include_directories(sl-ai PRIVATE C:/Users/srogers/Desktop/inworld-ndk-built/src/Public)

    
target_link_options(sl-ai PRIVATE /ignore:4099)

target_compile_options(sl-ai PRIVATE /wd4251)
target_compile_options(sl-ai PRIVATE $<$<CONFIG:RelWithDebInfo>:/Od>)

set_target_properties(sl-ai PROPERTIES FOLDER "plugins")

set_property(TARGET sl-ai PROPERTY CXX_STANDARD 20)
set_property(TARGET sl-ai PROPERTY CXX_STANDARD_REQUIRED ON)

setup_plugin_target(sl-ai PROPERTIES FOLDER plugins PREFIX "")
