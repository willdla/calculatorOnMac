#include "include/CalcBridge.h"
#include "include/Header Files/CalcEngine.h"

namespace CalculationManager
{
    CalcBridge::CalcBridge()
        : m_display(L"0")
        , m_updateCallback(nullptr)
        , m_callbackContext(nullptr)
    {
        m_manager = std::make_unique<CalculationManager::CalculatorManager>(this, this);
        m_manager->SetStandardMode();
    }

    CalcBridge::~CalcBridge()
    {
    }

    void CalcBridge::SetPrimaryDisplay(const std::wstring& pszText, bool isError)
    {
        m_display = pszText;
        // Simple conversion for Mac (UTF-8)
        m_displayUTF8.clear();
        for (wchar_t wc : m_display)
        {
            if (wc < 128)
                m_displayUTF8 += (char)wc;
            else
                m_displayUTF8 += '?';
        }

        if (m_updateCallback)
        {
            m_updateCallback(m_callbackContext);
        }
    }

    void CalcBridge::SetIsInError(bool isError)
    {
    }
    void CalcBridge::SetExpressionDisplay(
        _Inout_ std::shared_ptr<std::vector<std::pair<std::wstring, int>>> const& tokens,
        _Inout_ std::shared_ptr<std::vector<std::shared_ptr<IExpressionCommand>>> const& commands)
    {
    }
    void CalcBridge::SetParenthesisNumber(_In_ unsigned int count)
    {
    }
    void CalcBridge::OnNoRightParenAdded()
    {
    }
    void CalcBridge::MaxDigitsReached()
    {
    }
    void CalcBridge::BinaryOperatorReceived()
    {
    }
    void CalcBridge::OnHistoryItemAdded(_In_ unsigned int addedItemIndex)
    {
    }
    void CalcBridge::SetMemorizedNumbers(_In_ const std::vector<std::wstring>& memorizedNumbers)
    {
    }
    void CalcBridge::MemoryItemChanged(unsigned int indexOfMemory)
    {
    }
    void CalcBridge::InputChanged()
    {
    }

    std::wstring CalcBridge::GetCEngineString(std::wstring_view id)
    {
        if (id == L"sDecimal")
            return L".";
        if (id == L"sThousand")
            return L",";
        if (id == L"sGrouping")
            return L"3;0";
        return L"";
    }

    void CalcBridge::SendCommand(int commandId)
    {
        m_manager->SendCommand(static_cast<CalculationManager::Command>(commandId));
    }

    std::wstring CalcBridge::GetDisplay() const
    {
        return m_display;
    }

    const std::string& CalcBridge::GetDisplayUTF8() const
    {
        return m_displayUTF8;
    }

    void CalcBridge::RegisterUpdateCallback(void (*callback)(void*), void* context)
    {
        m_updateCallback = callback;
        m_callbackContext = context;
    }

    const std::string& CalcBridge::GetExpressionUTF8() const
    {
        // For now, return empty - we'll track expression in Swift layer
        m_expressionUTF8 = "";
        return m_expressionUTF8;
    }

    void CalcBridge::SetStandardMode()
    {
        m_manager->SetStandardMode();
    }

    void CalcBridge::SetScientificMode()
    {
        m_manager->SetScientificMode();
    }

    void CalcBridge::SetProgrammerMode()
    {
        m_manager->SetProgrammerMode();
    }
}

// C-Bridge Implementation
extern "C"
{
    void* CalcBridge_Create()
    {
        return new CalculationManager::CalcBridge();
    }
    void CalcBridge_Destroy(void* bridge)
    {
        delete static_cast<CalculationManager::CalcBridge*>(bridge);
    }
    void CalcBridge_SendCommand(void* bridge, int commandId)
    {
        static_cast<CalculationManager::CalcBridge*>(bridge)->SendCommand(commandId);
    }
    const char* CalcBridge_GetDisplay(void* bridge)
    {
        // Return pointer to internal cache
        return static_cast<CalculationManager::CalcBridge*>(bridge)->GetDisplayUTF8().c_str();
    }
    void CalcBridge_RegisterUpdateCallback(void* bridge, void (*callback)(void*), void* context)
    {
        static_cast<CalculationManager::CalcBridge*>(bridge)->RegisterUpdateCallback(callback, context);
    }
    void CalcBridge_SetStandardMode(void* bridge)
    {
        static_cast<CalculationManager::CalcBridge*>(bridge)->SetStandardMode();
    }
    void CalcBridge_SetScientificMode(void* bridge)
    {
        static_cast<CalculationManager::CalcBridge*>(bridge)->SetScientificMode();
    }
    void CalcBridge_SetProgrammerMode(void* bridge)
    {
        static_cast<CalculationManager::CalcBridge*>(bridge)->SetProgrammerMode();
    }

    const char* CalcBridge_GetExpression(void* bridge)
    {
        if (!bridge)
            return "";
        return static_cast<CalculationManager::CalcBridge*>(bridge)->GetExpressionUTF8().c_str();
    }
}
