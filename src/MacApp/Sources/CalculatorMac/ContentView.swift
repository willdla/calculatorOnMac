import SwiftUI

struct ContentView: View {
    @State private var engine = CalculatorEngine()
    @State private var selectedMode: CalculatorMode = .standard
    @State private var selectedRadix: String = "DEC"
    @State private var showHistory: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            // History sidebar
            if showHistory {
                historyPanel
                    .frame(width: 300)
                    .transition(.move(edge: .leading))
            }
            
            // Main calculator
            VStack(spacing: 0) {
                // Mode Picker
                Picker("Mode", selection: $selectedMode) {
                    Text("Standard").tag(CalculatorMode.standard)
                    Text("Scientific").tag(CalculatorMode.scientific)
                    Text("Programmer").tag(CalculatorMode.programmer)
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedMode) { oldMode, newMode in
                    // Don't clear when switching modes - preserve the value
                    engine.setMode(newMode)
                }
                
                // History toggle button
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showHistory.toggle()
                        }
                    }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .padding(.horizontal)
                
                // Display
                displayView
                
                // Buttons
                if selectedMode == .programmer {
                    programmerView
                } else if selectedMode == .scientific {
                    scientificView
                } else {
                    standardView
                }
            }
            .frame(width: 360, height: windowHeight)
            .animation(.easeInOut(duration: 0.3), value: selectedMode)
        }
        .background(Color(white: 0.12))
        .preferredColorScheme(.dark)
        .onAppear {
            setupKeyboardMonitor()
        }
    }
    
    private var windowHeight: CGFloat {
        // Base UI components:
        // - Picker: ~60px
        // - History Toggle: ~40px
        // - Display: 120px
        // Total Base: ~220px
        let baseHeight: CGFloat = 220
        
        switch selectedMode {
        case .standard:
            // 6 rows of buttons approx 350px + padding
            return baseHeight + 390 // Total 610
        case .scientific:
            // Standard + extra header text
            return baseHeight + 430 // Total 650
        case .programmer:
            // - Bit Panel: ~140px
            // - Radix/Size selectors: ~80px
            // - 8 rows of buttons: ~470px
            // Total additional: ~690px
            return baseHeight + 730 // Total 950
        }
    }
    
    private var historyPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("History")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    engine.history.removeAll()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            
            Divider()
                .background(Color.gray)
            
            // History list
            if engine.history.isEmpty {
                VStack {
                    Spacer()
                    Text("No history yet")
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(engine.history) { item in
                            historyItemView(item)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color(white: 0.1))
    }
    
    private func historyItemView(_ item: HistoryItem) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(item.expression)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text(item.result)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(white: 0.15))
        .cornerRadius(8)
        .onTapGesture {
            // Copy result to display
            engine.sendCommand(81) // Clear
            for char in item.result {
                if let digit = char.wholeNumberValue {
                    engine.sendCommand(Int32(130 + digit))
                }
            }
        }
    }
    
    private var displayView: some View {
        VStack(spacing: 4) {
            // Expression display
            HStack {
                Spacer()
                Text(engine.expression)
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .frame(height: 30)
            }
            
            // Main display
            HStack {
                Spacer()
                Text(engine.display)
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
            Spacer()
        }
        .frame(height: 120)
        .background(Color(white: 0.15))
    }
    
    private var standardView: some View {
        VStack(spacing: 8) {
            // Memory buttons row
            HStack(spacing: 8) {
                ForEach(["MC", "MR", "M+", "M-", "MS"], id: \.self) { label in
                    memoryButton(label)
                }
            }
            .padding(.horizontal)
            
            // Standard calculator buttons
            let rows: [[CalcButton]] = [
                [.percent, .ce, .clear, .backspace],
                [.reciprocal, .square, .sqrt, .divide],
                [.seven, .eight, .nine, .multiply],
                [.four, .five, .six, .subtract],
                [.one, .two, .three, .add],
                [.negate, .zero, .decimal, .equals]
            ]
            
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { button in
                        calcButton(button)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private var scientificView: some View {
        VStack(spacing: 8) {
            Text("Scientific Mode")
                .foregroundColor(.gray)
            standardView
        }
    }
    
    private var programmerView: some View {
        VStack(spacing: 8) {
            // Bit display panel
            bitDisplayPanel
            
            // Radix selector
            HStack(spacing: 8) {
                ForEach(["HEX", "DEC", "OCT", "BIN"], id: \.self) { radix in
                    Button(radix) {
                        selectedRadix = radix
                        setRadix(radix)
                    }
                    .buttonStyle(RadixButtonStyle(isSelected: selectedRadix == radix))
                }
            }
            .padding(.horizontal)
            
            // Bit width selector
            HStack(spacing: 8) {
                ForEach(["QWORD", "DWORD", "WORD", "BYTE"], id: \.self) { width in
                    Button(width) {
                        // TODO: Set bit width
                    }
                    .buttonStyle(BitWidthButtonStyle())
                }
            }
            .padding(.horizontal)
            
            // Programmer buttons
            let rows: [[CalcButton]] = [
                [.modulo, .ce, .clear, .backspace],
                [.a, .b, .leftShift, .rightShift],
                [.c, .d, .or, .divide],
                [.e, .f, .xor, .multiply],
                [.seven, .eight, .nine, .subtract],
                [.four, .five, .six, .add],
                [.one, .two, .three, .and],
                [.negate, .zero, .decimal, .equals]
            ]
            
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { button in
                        calcButton(button)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private var bitDisplayPanel: some View {
        VStack(spacing: 4) {
            // Display bits in groups of 4, showing 64 bits total
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<16, id: \.self) { col in
                        let bitIndex = (3 - row) * 16 + (15 - col)
                        bitButton(bitIndex)
                        
                        // Add spacing every 4 bits
                        if col % 4 == 3 && col != 15 {
                            Spacer().frame(width: 4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(white: 0.18))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private func bitButton(_ index: Int) -> some View {
        let bitValue = getBitValue(index)
        
        return Button(action: {
            toggleBit(index)
        }) {
            Text(bitValue ? "1" : "0")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .frame(width: 16, height: 20)
                .foregroundColor(bitValue ? .blue : .gray)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getBitValue(_ index: Int) -> Bool {
        // Parse current display value as integer based on current radix
        var displayStr = engine.display.trimmingCharacters(in: .whitespaces)
        
        // Remove any spaces or separators that might be in the display
        displayStr = displayStr.replacingOccurrences(of: " ", with: "")
        displayStr = displayStr.replacingOccurrences(of: ",", with: "")
        displayStr = displayStr.replacingOccurrences(of: "_", with: "")
        
        let value: Int64?
        
        switch selectedRadix {
        case "HEX":
            value = Int64(displayStr, radix: 16)
        case "OCT":
            value = Int64(displayStr, radix: 8)
        case "BIN":
            value = Int64(displayStr, radix: 2)
        default: // DEC
            value = Int64(displayStr, radix: 10)
        }
        
        guard let intValue = value else { return false }
        return (intValue & (1 << index)) != 0
    }
    
    private func toggleBit(_ index: Int) {
        // Parse current value based on current radix
        var displayStr = engine.display.trimmingCharacters(in: .whitespaces)
        
        // Remove any spaces or separators
        displayStr = displayStr.replacingOccurrences(of: " ", with: "")
        displayStr = displayStr.replacingOccurrences(of: ",", with: "")
        displayStr = displayStr.replacingOccurrences(of: "_", with: "")
        
        let currentValue: Int64
        
        switch selectedRadix {
        case "HEX":
            currentValue = Int64(displayStr, radix: 16) ?? 0
        case "OCT":
            currentValue = Int64(displayStr, radix: 8) ?? 0
        case "BIN":
            currentValue = Int64(displayStr, radix: 2) ?? 0
        default: // DEC
            currentValue = Int64(displayStr, radix: 10) ?? 0
        }
        
        let newValue = currentValue ^ (1 << index)
        
        // Remember current radix
        let currentRadix = selectedRadix
        
        // Switch to DEC mode to input the value
        if currentRadix != "DEC" {
            engine.sendCommand(314) // CommandDec
        }
        
        // Clear current value and enter new value
        engine.sendCommand(81) // Clear
        
        // Send digits of new value
        let valueStr = String(newValue)
        for char in valueStr {
            if let digit = char.wholeNumberValue {
                engine.sendCommand(Int32(130 + digit))
            } else if char == "-" {
                engine.sendCommand(80) // Negate
            }
        }
        
        // Switch back to original radix
        if currentRadix != "DEC" {
            setRadix(currentRadix)
        }
    }
    
    private func memoryButton(_ label: String) -> some View {
        Button(label) {
            // TODO: Memory operations
        }
        .frame(maxWidth: .infinity)
        .frame(height: 32)
        .background(Color(white: 0.2))
        .foregroundColor(.white)
        .cornerRadius(4)
    }
    
    private func calcButton(_ button: CalcButton) -> some View {
        Button(action: {
            engine.sendCommand(button.commandId)
        }) {
            Text(button.title)
                .font(button.isOperator ? .title2 : .title3)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(button.backgroundColor)
                .foregroundColor(.white)
                .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func setRadix(_ radix: String) {
        let command: Int32
        switch radix {
        case "HEX":
            command = 313 // CommandHex
        case "DEC":
            command = 314 // CommandDec
        case "OCT":
            command = 315 // CommandOct
        case "BIN":
            command = 316 // CommandBin
        default:
            return
        }
        engine.sendCommand(command)
    }
    
    private func setupKeyboardMonitor() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Check for Cmd+1/2/3 mode switching
            if event.modifierFlags.contains(.command) {
                if let char = event.charactersIgnoringModifiers?.first {
                    switch char {
                    case "1":
                        self.selectedMode = .standard
                        return nil
                    case "2":
                        self.selectedMode = .scientific
                        return nil
                    case "3":
                        self.selectedMode = .programmer
                        return nil
                    default:
                        break
                    }
                }
            }
            
            guard let characters = event.charactersIgnoringModifiers else { return event }
            
            for char in characters {
                switch char {
                case "0"..."9":
                    let cmd = Int32(130 + (char.wholeNumberValue ?? 0))
                    engine.sendCommand(cmd)
                    return nil
                case "a", "A":
                    engine.sendCommand(140) // CommandA
                    return nil
                case "b", "B":
                    engine.sendCommand(141) // CommandB
                    return nil
                case "c", "C":
                    // Only send CommandC in programmer mode, otherwise it's Clear
                    if selectedMode == .programmer && selectedRadix == "HEX" {
                        engine.sendCommand(142) // CommandC
                        return nil
                    }
                    engine.sendCommand(81) // CommandCLEAR
                    return nil
                case "d", "D":
                    engine.sendCommand(143) // CommandD
                    return nil
                case "e", "E":
                    engine.sendCommand(144) // CommandE
                    return nil
                case "f", "F":
                    engine.sendCommand(145) // CommandF
                    return nil
                case ".":
                    engine.sendCommand(84) // CommandPNT
                    return nil
                case "+":
                    engine.sendCommand(93) // CommandADD
                    return nil
                case "-":
                    engine.sendCommand(94) // CommandSUB
                    return nil
                case "*":
                    engine.sendCommand(92) // CommandMUL
                    return nil
                case "/":
                    engine.sendCommand(91) // CommandDIV
                    return nil
                case "=", "\r":
                    engine.sendCommand(121) // CommandEQU
                    return nil
                default:
                    break
                }
            }
            
            // Handle special keys
            if event.keyCode == 51 { // Delete
                engine.sendCommand(83) // CommandBACK
                return nil
            }
            
            if event.keyCode == 53 { // ESC
                engine.sendCommand(82) // CommandCENTR (CE - Clear Entry)
                return nil
            }
            
            return event
        }
    }
}

struct RadixButtonStyle: ButtonStyle {
    var isSelected: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(isSelected ? Color.accentColor : Color(white: 0.25))
            .foregroundColor(.white)
            .cornerRadius(4)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct BitWidthButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(Color(white: 0.22))
            .foregroundColor(.white)
            .cornerRadius(4)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

enum CalcButton: Hashable {
    case zero, one, two, three, four, five, six, seven, eight, nine
    case a, b, c, d, e, f  // Hex digits
    case add, subtract, multiply, divide, equals, clear, ce, backspace
    case decimal, negate, percent
    case square, sqrt, reciprocal
    case and, or, xor, leftShift, rightShift, modulo
    
    var title: String {
        switch self {
        case .zero: return "0"
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .a: return "A"
        case .b: return "B"
        case .c: return "C"
        case .d: return "D"
        case .e: return "E"
        case .f: return "F"
        case .add: return "+"
        case .subtract: return "−"
        case .multiply: return "×"
        case .divide: return "÷"
        case .equals: return "="
        case .clear: return "C"
        case .ce: return "CE"
        case .backspace: return "⌫"
        case .decimal: return "."
        case .negate: return "±"
        case .percent: return "%"
        case .square: return "x²"
        case .sqrt: return "√"
        case .reciprocal: return "1/x"
        case .and: return "AND"
        case .or: return "OR"
        case .xor: return "XOR"
        case .leftShift: return "<<"
        case .rightShift: return ">>"
        case .modulo: return "Mod"
        }
    }
    
    var commandId: Int32 {
        switch self {
        case .zero: return 130
        case .one: return 131
        case .two: return 132
        case .three: return 133
        case .four: return 134
        case .five: return 135
        case .six: return 136
        case .seven: return 137
        case .eight: return 138
        case .nine: return 139
        case .a: return 140
        case .b: return 141
        case .c: return 142
        case .d: return 143
        case .e: return 144
        case .f: return 145
        case .add: return 93
        case .subtract: return 94
        case .multiply: return 92
        case .divide: return 91
        case .equals: return 121
        case .clear: return 81
        case .ce: return 82
        case .backspace: return 83
        case .decimal: return 84
        case .negate: return 80
        case .percent: return 118
        case .square: return 97  // CommandPWR with 2
        case .sqrt: return 96    // CommandROOT
        case .reciprocal: return 113 // CommandREC
        case .and: return 86     // CommandAnd
        case .or: return 87      // CommandOR
        case .xor: return 88     // CommandXor
        case .leftShift: return 89  // CommandLSHF
        case .rightShift: return 90 // CommandRSHF
        case .modulo: return 95     // CommandMOD
        }
    }
    
    var isOperator: Bool {
        switch self {
        case .add, .subtract, .multiply, .divide, .equals:
            return true
        default:
            return false
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .equals:
            return .accentColor
        case .add, .subtract, .multiply, .divide:
            return Color(white: 0.25)
        case .and, .or, .xor, .leftShift, .rightShift, .modulo:
            return Color(white: 0.23)
        default:
            return Color(white: 0.2)
        }
    }
}
