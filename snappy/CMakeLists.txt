
include(TestBigEndian)
test_big_endian(SNAPPY_IS_BIG_ENDIAN)

include(CheckIncludeFile)
check_include_file("byteswap.h" HAVE_BYTESWAP_H)
check_include_file("sys/endian.h" HAVE_SYS_ENDIAN_H)
check_include_file("sys/mman.h" HAVE_SYS_MMAN_H)
check_include_file("sys/resource.h" HAVE_SYS_RESOURCE_H)
check_include_file("sys/time.h" HAVE_SYS_TIME_H)
check_include_file("sys/uio.h" HAVE_SYS_UIO_H)
check_include_file("unistd.h" HAVE_UNISTD_H)
check_include_file("windows.h" HAVE_WINDOWS_H)

include(CheckLibraryExists)
check_library_exists(z zlibVersion "" HAVE_LIBZ)
check_library_exists(lzo2 lzo1x_1_15_compress "" HAVE_LIBLZO2)

include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("/arch:AVX" HAVE_VISUAL_STUDIO_ARCH_AVX)
CHECK_CXX_COMPILER_FLAG("/arch:AVX2" HAVE_VISUAL_STUDIO_ARCH_AVX2)
CHECK_CXX_COMPILER_FLAG("-mavx" HAVE_CLANG_MAVX)
CHECK_CXX_COMPILER_FLAG("-mbmi2" HAVE_CLANG_MBMI2)
if(SNAPPY_REQUIRE_AVX2)
    if(HAVE_VISUAL_STUDIO_ARCH_AVX2)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:AVX2")
    endif(HAVE_VISUAL_STUDIO_ARCH_AVX2)
    if(HAVE_CLANG_MAVX)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mavx")
    endif(HAVE_CLANG_MAVX)
    if(HAVE_CLANG_MBMI2)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mbmi2")
    endif(HAVE_CLANG_MBMI2)
elseif (SNAPPY_REQUIRE_AVX)
    if(HAVE_VISUAL_STUDIO_ARCH_AVX)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:AVX")
    endif(HAVE_VISUAL_STUDIO_ARCH_AVX)
    if(HAVE_CLANG_MAVX)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mavx")
    endif(HAVE_CLANG_MAVX)
endif(SNAPPY_REQUIRE_AVX2)

include(CheckCXXSourceCompiles)
check_cxx_source_compiles("
int main() {
  return __builtin_expect(0, 1);
}" HAVE_BUILTIN_EXPECT)

check_cxx_source_compiles("
int main() {
  return __builtin_ctzll(0);
}" HAVE_BUILTIN_CTZ)

check_cxx_source_compiles("
#include <tmmintrin.h>

int main() {
  const __m128i *src = 0;
  __m128i dest;
  const __m128i shuffle_mask = _mm_load_si128(src);
  const __m128i pattern = _mm_shuffle_epi8(_mm_loadl_epi64(src), shuffle_mask);
  _mm_storeu_si128(&dest, pattern);
  return 0;
}" SNAPPY_HAVE_SSSE3)

check_cxx_source_compiles("
#include <immintrin.h>
int main() {
  return _bzhi_u32(0, 1);
}" SNAPPY_HAVE_BMI2)

include(CheckSymbolExists)
check_symbol_exists("mmap" "sys/mman.h" HAVE_FUNC_MMAP)
check_symbol_exists("sysconf" "unistd.h" HAVE_FUNC_SYSCONF)

find_package(GTest QUIET)
if(GTEST_FOUND)
    set(HAVE_GTEST 1)
endif(GTEST_FOUND)

find_package(Gflags QUIET)
if(GFLAGS_FOUND)
    set(HAVE_GFLAGS 1)
endif(GFLAGS_FOUND)

configure_file(
        "config.h.in"
        "${PROJECT_BINARY_DIR}/snappy/config.h"
)


FILE(GLOB SNAPPY_SRC "*.cc")


add_library(snappy_static STATIC ${SNAPPY_SRC})
add_library(snappy_shared SHARED ${SNAPPY_SRC})

target_link_libraries(snappy_static pthread)
if (APPLE)
    find_library(CoreFoundation CoreFoundation)
    target_link_libraries(snappy_static ${CoreFoundation} pthread)
    target_link_libraries(snappy_shared ${CoreFoundation} pthread)
elseif (${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    target_link_libraries(snappy_static pthread)
    target_link_libraries(snappy_shared pthread rt)
endif ()

set_target_properties(snappy_shared PROPERTIES
        OUTPUT_NAME snappy
        VERSION ${CMAKE_PROJECT_VERSION}
        SOVERSION ${CMAKE_PROJECT_VERSION_MAJOR}
        )

set_target_properties(snappy_static PROPERTIES
        OUTPUT_NAME snappy
        VERSION ${CMAKE_PROJECT_VERSION}
        SOVERSION ${CMAKE_PROJECT_VERSION_MAJOR}
        )

install(TARGETS snappy_static snappy_shared
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        )

file(GLOB SNAPPY_HEADER "*.h")
install(FILES ${SNAPPY_HEADER}
        DESTINATION include
        )
file(GLOB SNAPPY_GEN_HEADER "${PROJECT_BINARY_DIR}/snappy/*.h")
install(FILES ${SNAPPY_GEN_HEADER} DESTINATION include)