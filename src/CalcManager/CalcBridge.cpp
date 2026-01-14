#include "CalcBridge.h"
#include "Header Files/CalcEngine.h"

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

    std::string CalcBridge::GetDisplayUTF8() const
    {
        std::string res;
        for (wchar_t wc : m_display)
        {
            if (wc < 128)
                res += (char)wc;
            else
                res += '?';
        }
        return res;
    }

    void CalcBridge::RegisterUpdateCallback(void (*callback)(void*), void* context)
    {
        m_updateCallback = callback;
        m_callbackContext = context;
    }
}
