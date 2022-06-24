echo on 

set CMakeGenerator=Visual Studio 16 2019
set GPUPriority=1
set MAIN_DIR=%CD%

if defined ReleaseName (
    echo "ReleaseName is defined no need in default env variables"
) else (
    set ReleaseName=release
    set BuildConfig=Release
    set CefBuildConfig=Release
)

call slobs_CI\win-install-dependency.cmd

cd "%MAIN_DIR%"

cmake -H. ^
         -B%CD%\build ^
         -G"%CmakeGenerator%" ^
         -A x64 ^
         -DCMAKE_SYSTEM_VERSION=10.0 ^
         -DCMAKE_INSTALL_PREFIX=%CD%\%InstallPath% ^
         -DDepsPath=%CD%\build\deps\deps_bin\win64 ^
         -DVLCPath=%CD%\build\deps\vlc ^
         -DCEF_ROOT_DIR=%CEFPATH% ^
         -DUSE_UI_LOOP=false ^
         -DENABLE_UI=false ^
         -DCOPIED_DEPENDENCIES=false ^
         -DCOPY_DEPENDENCIES=true ^
         -DENABLE_SCRIPTING=false ^
         -DGPU_PRIORITY_VAL="%GPUPriority%" ^
         -DBUILD_CAPTIONS=false ^
         -DCOMPILE_D3D12_HOOK=true ^
         -DBUILD_BROWSER=true ^
         -DBROWSER_FRONTEND_API_SUPPORT=false ^
         -DBROWSER_PANEL_SUPPORT=false ^
         -DBROWSER_USE_STATIC_CRT=false ^
         -DEXPERIMENTAL_SHARED_TEXTURE_SUPPORT=true ^
         -DCHECK_FOR_SERVICE_UPDATES=true ^
         -DProtobuf_DIR="%GRPC_DIST%\cmake" ^
         -Dabsl_DIR="%GRPC_DIST%\lib\cmake\absl" ^
         -DgRPC_DIR="%GRPC_DIST%\lib\cmake\grpc"

cmake --build %CD%\build --target install --config %BuildConfig% -v

cmake --build %CD%\build --target check_dependencies --config %BuildConfig% -v
if %errorlevel% neq 0 exit /b %errorlevel%

mkdir %CD%\%InstallPath%\data\obs-plugins\obs-virtualoutput
move %CD%\build\deps\%OBS_VIRTUALCAM% %CD%\%InstallPath%\data\obs-plugins\obs-virtualoutput\%OBS_VIRTUALCAM%
