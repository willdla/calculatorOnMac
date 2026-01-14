add_executable(CalcConsole main.cpp)

target_link_libraries(CalcConsole PRIVATE CalcManager)

target_include_directories(CalcConsole PRIVATE
    ${PROJECT_SOURCE_DIR}/src
    ${PROJECT_SOURCE_DIR}/src/CalcManager
)
