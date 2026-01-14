import Foundation
import CalcManagerLib

enum CalculatorMode {
    case standard
    case scientific
    case programmer
}

struct HistoryItem: Identifiable {
    let id = UUID()
    let expression: String
    let result: String
}

@MainActor
@Observable
class CalculatorEngine {
    nonisolated(unsafe) private let bridgePtr: UnsafeMutableRawPointer?
    var display: String = "0"
    var expression: String = ""
    var currentMode: CalculatorMode = .standard
    var history: [HistoryItem] = []
    private var lastCommand: Int32 = 0
    private var pendingOperator: String = ""
    private var firstOperand: String = ""
    
    init() {
        let ptr = CalcBridge_Create()
        self.bridgePtr = ptr
        
        let context = Unmanaged.passUnretained(self).toOpaque()
        
        let callback: @convention(c) (UnsafeMutableRawPointer?) -> Void = { ctx in
            guard let ctx = ctx else { return }
            let engine = Unmanaged<CalculatorEngine>.fromOpaque(ctx).takeUnretainedValue()
            
            Task { @MainActor in
                engine.updateDisplay()
            }
        }
        
        if let p = ptr {
            CalcBridge_RegisterUpdateCallback(p, callback, context)
        }
        
        updateDisplay()
    }
    
    deinit {
        if let ptr = bridgePtr {
            CalcBridge_Destroy(ptr)
        }
    }
    
    func updateDisplay() {
        if let ptr = bridgePtr, let cStr = CalcBridge_GetDisplay(ptr) {
            self.display = String(cString: cStr)
        }
    }
    
    func sendCommand(_ command: Int32) {
        if let ptr = bridgePtr {
            // Track operators for expression display
            switch command {
            case 93: // ADD
                firstOperand = display
                pendingOperator = " + "
                expression = display + pendingOperator
            case 94: // SUB
                firstOperand = display
                pendingOperator = " − "
                expression = display + pendingOperator
            case 92: // MUL
                firstOperand = display
                pendingOperator = " × "
                expression = display + pendingOperator
            case 91: // DIV
                firstOperand = display
                pendingOperator = " ÷ "
                expression = display + pendingOperator
            case 121: // EQU
                if !expression.isEmpty {
                    // Add to history
                    let fullExpression = expression + display
                    CalcBridge_SendCommand(ptr, command)
                    updateDisplay()
                    let result = display
                    history.insert(HistoryItem(expression: fullExpression, result: result), at: 0)
                }
                expression = ""
                pendingOperator = ""
                firstOperand = ""
                lastCommand = command
                return
            case 81, 82: // CLEAR, CE
                expression = ""
                pendingOperator = ""
                firstOperand = ""
            default:
                break
            }
            
            lastCommand = command
            CalcBridge_SendCommand(ptr, command)
        }
    }
    
    func setMode(_ mode: CalculatorMode) {
        guard let ptr = bridgePtr else { return }
        currentMode = mode
        
        switch mode {
        case .standard:
            CalcBridge_SetStandardMode(ptr)
        case .scientific:
            CalcBridge_SetScientificMode(ptr)
        case .programmer:
            CalcBridge_SetProgrammerMode(ptr)
        }
    }
}
