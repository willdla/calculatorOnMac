#pragma once

#include <string>
#include <vector>
#include <memory>
#include <functional>

#include "sal_cross_platform.h"
#include "CalculatorResource.h"
#include "Header Files/ICalcDisplay.h"
#include "CalculatorManager.h"

namespace CalculationManager
{
    class CalcBridge : public ::ICalcDisplay, public CalculationManager::IResourceProvider
    {
    public:
        CalcBridge();
        virtual ~CalcBridge();

        // ICalcDisplay
        void SetPrimaryDisplay(const std::wstring& pszText, bool isError) override;
        void SetIsInError(bool isInError) override;
        void SetExpressionDisplay(
            _Inout_ std::shared_ptr<std::vector<std::pair<std::wstring, int>>> const& tokens,
            _Inout_ std::shared_ptr<std::vector<std::shared_ptr<IExpressionCommand>>> const& commands) override;
        void SetParenthesisNumber(_In_ unsigned int count) override;
        void OnNoRightParenAdded() override;
        void MaxDigitsReached() override;
        void BinaryOperatorReceived() override;
        void OnHistoryItemAdded(_In_ unsigned int addedItemIndex) override;
        void SetMemorizedNumbers(_In_ const std::vector<std::wstring>& memorizedNumbers) override;
        void MemoryItemChanged(unsigned int indexOfMemory) override;
        void InputChanged() override;

        // IResourceProvider
        std::wstring GetCEngineString(std::wstring_view id) override;

        // Bridge Methods
        void SendCommand(int commandId);
        std::wstring GetDisplay() const;
        std::string GetDisplayUTF8() const;

        void RegisterUpdateCallback(void (*callback)(void*), void* context);

    private:
        std::unique_ptr<CalculationManager::CalculatorManager> m_manager;
        std::wstring m_display;
        void (*m_updateCallback)(void*);
        void* m_callbackContext;
    };
}
