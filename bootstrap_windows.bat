@echo off
SETLOCAL

:: Ensure the script starts in the directory where the batch script is located
cd /d "%~dp0"

:: Check if CMakeLists exists
if not exist "CMakeLists.txt" (
    echo Error: CMakeLists.txt not found in this directory
    exit /b
)

:: If vcpkg is missing (because we deleted it), clone a fresh, clean copy
if not exist "vcpkg\" (
    echo vcpkg directory not found. Cloning fresh copy from GitHub...
    git clone https://github.com/microsoft/vcpkg.git
)

:: Force bootstrap to ensure the vcpkg.exe is the absolute latest version
echo Bootstrapping vcpkg...
call vcpkg\bootstrap-vcpkg.bat -disableMetrics

:: Integrate vcpkg with Visual Studio
echo Integrating vcpkg with build systems
vcpkg\vcpkg integrate install

:: Install necessary packages explicitly for 64-bit windows
echo Installing packages...
vcpkg\vcpkg install glfw3 opencl glad opengl zlib --triplet x64-windows

:: Configure the project with CMake
echo Configuring CMake project
cmake -B build -S . -G "Visual Studio 18 2026" -A x64 -DCMAKE_TOOLCHAIN_FILE="%CD%\vcpkg\scripts\buildsystems\vcpkg.cmake" -DUSE_ARM=OFF

:: Build the project using CMake
echo Building CMake project
cmake --build build --config Release

:: Pause to view output before closing the window
pause

ENDLOCAL