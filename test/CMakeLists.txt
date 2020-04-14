

add_executable(snappy_test snappy-test.cc snappy_unittest.cc)
target_link_libraries(snappy_test snappy_static z gtest_main gtest)