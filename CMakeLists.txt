project("lua-shmup" NONE)

cmake_minimum_required ( VERSION 2.8 )

file(GLOB_RECURSE SRC_LIST "${CMAKE_SOURCE_DIR}/*.lua")

add_custom_target(${PROJECT_NAME} SOURCES ${SRC_LIST})
