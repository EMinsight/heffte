
@PACKAGE_INIT@

include("${CMAKE_CURRENT_LIST_DIR}/HeffteTargets.cmake")

if (@Heffte_ENABLE_FFTW@ AND NOT TARGET Heffte::FFTW)
    add_library(Heffte::FFTW INTERFACE IMPORTED GLOBAL)
    target_link_libraries(Heffte::FFTW INTERFACE @FFTW_LIBRARIES@)
    set_target_properties(Heffte::FFTW PROPERTIES INTERFACE_INCLUDE_DIRECTORIES @FFTW_INCLUDES@)
endif()

if (@Heffte_ENABLE_MKL@ AND NOT TARGET Heffte::MKL)
    add_library(Heffte::MKL INTERFACE IMPORTED GLOBAL)
    target_link_libraries(Heffte::MKL INTERFACE @Heffte_MKL_LIBRARIES@)
    set_target_properties(Heffte::MKL PROPERTIES INTERFACE_INCLUDE_DIRECTORIES @Heffte_MKL_INCLUDES@)
endif()

if (@Heffte_ENABLE_ROCM@ AND NOT TARGET roc::rocfft)
    if (NOT "@Heffte_ROCM_ROOT@" STREQUAL "")
        list(APPEND CMAKE_PREFIX_PATH "@Heffte_ROCM_ROOT@")
    endif()
    find_package(rocfft REQUIRED)
endif()

if (@Heffte_ENABLE_ONEAPI@ AND NOT TARGET Heffte::OneMKL)
    add_library(Heffte::OneMKL INTERFACE IMPORTED GLOBAL)
    target_link_libraries(Heffte::OneMKL INTERFACE @heffte_onemkl@)
endif()

if (@Heffte_ENABLE_CUDA@)
    if (NOT CUDA_TOOLKIT_ROOT_DIR AND NOT "@CUDA_TOOLKIT_ROOT_DIR@" STREQUAL "")
        set(CUDA_TOOLKIT_ROOT_DIR @CUDA_TOOLKIT_ROOT_DIR@)
    endif()
    find_package(CUDA REQUIRED)
endif()

if (@Heffte_ENABLE_MAGMA@ AND NOT TARGET Heffte::MAGMA)
    add_library(Heffte::MAGMA INTERFACE IMPORTED GLOBAL)
    target_link_libraries(Heffte::MAGMA INTERFACE @HeffteMAGMA_LIBRARIES@)
    set_target_properties(Heffte::MAGMA PROPERTIES INTERFACE_INCLUDE_DIRECTORIES @HeffteMAGMA_INCLUDES@)
endif()

if (@Heffte_ENABLE_FORTRAN@)
    get_property(heffte_project_languages GLOBAL PROPERTY ENABLED_LANGUAGES)
    if (NOT Fortran IN_LIST heffte_project_languages)
        if (NOT CMAKE_Fortran_COMPILER)
            set(CMAKE_Fortran_COMPILER @CMAKE_Fortran_COMPILER@)
        endif()
        enable_language(Fortran)
    endif()
    unset(heffte_project_languages)
    set(Heffte_Fortran_FOUND  "ON")
    if (NOT TARGET Heffte::Fortran)
        add_library(Heffte::Fortran INTERFACE IMPORTED GLOBAL)
        foreach(heffte_backend fftw cufft rocfft)
            if (TARGET Heffte::heffte_${heffte_backend})
                target_link_libraries(Heffte::Fortran INTERFACE Heffte::heffte_${heffte_backend})
            endif()
        endforeach()
        unset(heffte_backend)
    endif()
endif()

if (NOT TARGET MPI::MPI_CXX)
    if (NOT MPI_CXX_COMPILER)
        set(MPI_CXX_COMPILER @MPI_CXX_COMPILER@)
    endif()
    find_package(MPI REQUIRED)
endif()

if (@Heffte_ENABLE_PYTHON@)
    set(Heffte_PYTHON_FOUND  "ON")
    set(Heffte_PYTHONPATH "@CMAKE_INSTALL_PREFIX@/share/heffte/python")
endif()

if ("@BUILD_SHARED_LIBS@")
    set(Heffte_SHARED_FOUND "ON")
else()
    set(Heffte_STATIC_FOUND "ON")
endif()
set(Heffte_FFTW_FOUND    "@Heffte_ENABLE_FFTW@")
set(Heffte_MKL_FOUND     "@Heffte_ENABLE_MKL@")
set(Heffte_CUDA_FOUND    "@Heffte_ENABLE_CUDA@")
set(Heffte_ROCM_FOUND    "@Heffte_ENABLE_ROCM@")
set(Heffte_ONEAPI_FOUND  "@Heffte_ENABLE_ONEAPI@")
set(Heffte_INTRINSICS_FOUND  "@Heffte_ENABLE_INTRINSICS@")
if ("@Heffte_DISABLE_GPU_AWARE_MPI@")
    set(Heffte_GPUAWARE_FOUND "OFF")
else()
    set(Heffte_GPUAWARE_FOUND "ON")
endif()

check_required_components(Heffte)

if (Heffte_FOUND OR "${Heffte_FOUND}" STREQUAL "")
    # oddly enough, Heffte_FOUND is empty when there is no error
    message(STATUS "Found Heffte: @CMAKE_INSTALL_PREFIX@ (found version @PROJECT_VERSION@)")
    set(Heffte_ALL_MODULES "")
    foreach(_heffte_mod SHARED STATIC FFTW MKL CUDA ROCM ONEAPI INTRINSICS GPUAWARE PYTHON Fortran)
        if (Heffte_${_heffte_mod}_FOUND)
            set(Heffte_ALL_MODULES "${Heffte_ALL_MODULES} ${_heffte_mod}")
        endif()
    endforeach()
    unset(_heffte_mod)
    message(STATUS "Found Heffte modules: ${Heffte_ALL_MODULES}")
endif()
