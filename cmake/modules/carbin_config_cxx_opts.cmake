
include(carbin_cxx_opts)

set(CARBIN_LSAN_LINKOPTS "")
set(CARBIN_HAVE_LSAN OFF)
set(CARBIN_DEFAULT_LINKOPTS "")

if (BUILD_SHARED_LIBS AND MSVC)
    set(CARBIN_BUILD_DLL TRUE)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
else()
    set(CARBIN_BUILD_DLL FALSE)
endif()

if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86_64" OR "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "AMD64")
    if (MSVC)
        set(CARBIN_RANDOM_RANDEN_COPTS "${CARBIN_RANDOM_HWAES_MSVC_X64_FLAGS}")
    else()
        set(CARBIN_RANDOM_RANDEN_COPTS "${CARBIN_RANDOM_HWAES_X64_FLAGS}")
    endif()
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "arm.*|aarch64")
    if ("${CMAKE_SIZEOF_VOID_P}" STREQUAL "8")
        set(CARBIN_RANDOM_RANDEN_COPTS "${CARBIN_RANDOM_HWAES_ARM64_FLAGS}")
    elseif("${CMAKE_SIZEOF_VOID_P}" STREQUAL "4")
        set(CARBIN_RANDOM_RANDEN_COPTS "${CARBIN_RANDOM_HWAES_ARM32_FLAGS}")
    else()
        message(WARNING "Value of CMAKE_SIZEOF_VOID_P (${CMAKE_SIZEOF_VOID_P}) is not supported.")
    endif()
else()
    message(WARNING "Value of CMAKE_SYSTEM_PROCESSOR (${CMAKE_SYSTEM_PROCESSOR}) is unknown and cannot be used to set CARBIN_RANDOM_RANDEN_COPTS")
    set(CARBIN_RANDOM_RANDEN_COPTS "")
endif()


if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    set(CARBIN_DEFAULT_COPTS "${CARBIN_GCC_FLAGS}")
    set(CARBIN_TEST_COPTS "${CARBIN_GCC_FLAGS};${CARBIN_GCC_TEST_FLAGS}")
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    # MATCHES so we get both Clang and AppleClang
    if(MSVC)
        # clang-cl is half MSVC, half LLVM
        set(CARBIN_DEFAULT_COPTS "${CARBIN_CLANG_CL_FLAGS}")
        set(CARBIN_TEST_COPTS "${CARBIN_CLANG_CL_FLAGS};${CARBIN_CLANG_CL_TEST_FLAGS}")
        set(CARBIN_DEFAULT_LINKOPTS "${CARBIN_MSVC_LINKOPTS}")
    else()
        set(CARBIN_DEFAULT_COPTS "${CARBIN_LLVM_FLAGS}")
        set(CARBIN_TEST_COPTS "${CARBIN_LLVM_FLAGS};${CARBIN_LLVM_TEST_FLAGS}")
        if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            # AppleClang doesn't have lsan
            # https://developer.apple.com/documentation/code_diagnostics
            if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.5)
                set(CARBIN_LSAN_LINKOPTS "-fsanitize=leak")
                set(CARBIN_HAVE_LSAN ON)
            endif()
        endif()
    endif()
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    set(CARBIN_DEFAULT_COPTS "${CARBIN_MSVC_FLAGS}")
    set(CARBIN_TEST_COPTS "${CARBIN_MSVC_FLAGS};${CARBIN_MSVC_TEST_FLAGS}")
    set(CARBIN_DEFAULT_LINKOPTS "${CARBIN_MSVC_LINKOPTS}")
else()
    message(WARNING "Unknown compiler: ${CMAKE_CXX_COMPILER}.  Building with no default flags")
    set(CARBIN_DEFAULT_COPTS "")
    set(CARBIN_TEST_COPTS "")
endif()

set(CARBIN_CXX_STANDARD "${CMAKE_CXX_STANDARD}")
