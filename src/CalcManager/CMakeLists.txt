add_library(CalcManager STATIC
    CalculatorHistory.cpp
    CalculatorManager.cpp
    CEngine/calc.cpp
    CEngine/CalcUtils.cpp
    CEngine/History.cpp
    CEngine/CalcInput.cpp
    CEngine/Number.cpp
    CEngine/Rational.cpp
    CEngine/scicomm.cpp
    CEngine/scidisp.cpp
    CEngine/scifunc.cpp
    CEngine/RationalMath.cpp
    CEngine/scioper.cpp
    CEngine/sciset.cpp
    ExpressionCommand.cpp
    Ratpack/basex.cpp
    Ratpack/conv.cpp
    Ratpack/exp.cpp
    Ratpack/fact.cpp
    Ratpack/itrans.cpp
    Ratpack/itransh.cpp
    Ratpack/logic.cpp
    Ratpack/num.cpp
    Ratpack/rat.cpp
    Ratpack/support.cpp
    Ratpack/trans.cpp
    Ratpack/transh.cpp
    NumberFormattingUtils.cpp
    UnitConverter.cpp
    CalcBridge.cpp
)

target_include_directories(CalcManager PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/Header\ Files
    ${PROJECT_SOURCE_DIR}/src
)

target_compile_features(CalcManager PUBLIC cxx_std_17)

# Precompiled headers support (CMake 3.16+)
target_precompile_headers(CalcManager PRIVATE pch.h)

# Definitions for cross-platform compatibility
target_compile_definitions(CalcManager PRIVATE
    UNICODE
    _UNICODE
)
