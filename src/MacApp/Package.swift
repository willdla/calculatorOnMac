// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CalculatorMac",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "CalculatorMac", targets: ["CalculatorMac"])
    ],
    targets: [
        .executableTarget(
            name: "CalculatorMac",
            dependencies: ["CalcManagerLib"],
            path: "Sources/CalculatorMac",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ],
            linkerSettings: [
                .unsafeFlags(["../../build/src/CalcManager/libCalcManager.a"])
            ]
        ),
        .target(
            name: "CalcManagerLib",
            path: "Sources/CalcManagerLib",
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("include"),
                .headerSearchPath("include/Header Files"),
                .headerSearchPath("include/Ratpack"),
                .unsafeFlags(["-std=c++20"])
            ]
        )
    ]
)
