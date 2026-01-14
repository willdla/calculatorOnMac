#ifndef _In_
#define _In_
#endif
#ifndef _Inout_
#define _Inout_
#endif
#ifndef _Out_
#define _Out_
#endif
#ifndef _In_opt_
#define _In_opt_
#endif
#ifndef _Out_opt_
#define _Out_opt_
#endif
#ifndef _Frees_ptr_opt_
#define _Frees_ptr_opt_
#endif
#ifndef __in_opt
#define __in_opt
#endif

#include <iostream>
#include <string>
#include <vector>
#include <memory>
#include "CalculatorManager.h"
#include "ICalcDisplay.h"

using namespace std;
using namespace CalculationManager;

class ConsoleDisplay : public ICalcDisplay
{
public:
    void SetPrimaryDisplay(const std::wstring& pszText, bool isError) override
    {
        std::wcout << L"\rResult: " << pszText << (isError ? L" (Error)" : L"") << L"    " << std::endl;
        std::wcout << L"> " << std::flush;
    }
    void SetIsInError(bool isInError) override
    {
    }
    void SetExpressionDisplay(
        std::shared_ptr<std::vector<std::pair<std::wstring, int>>> const& tokens,
        std::shared_ptr<std::vector<std::shared_ptr<IExpressionCommand>>> const& commands) override
    {
    }
    void SetParenthesisNumber(unsigned int count) override
    {
    }
    void OnNoRightParenAdded() override
    {
    }
    void MaxDigitsReached() override
    {
    }
    void BinaryOperatorReceived() override
    {
    }
    void OnHistoryItemAdded(unsigned int addedItemIndex) override
    {
    }
    void SetMemorizedNumbers(const std::vector<std::wstring>& memorizedNumbers) override
    {
    }
    void MemoryItemChanged(unsigned int indexOfMemory) override
    {
    }
    void InputChanged() override
    {
    }
};

class SimpleResourceProvider : public IResourceProvider
{
public:
    std::wstring GetCEngineString(std::wstring_view id) override
    {
        if (id == L"sDecimal")
            return L".";
        if (id == L"sThousand")
            return L",";
        if (id == L"sGrouping")
            return L"3;0";
        return L"";
    }
};

void SendString(CalculatorManager& manager, const string& input)
{
    for (char c : input)
    {
        if (c >= '0' && c <= '9')
        {
            manager.SendCommand(static_cast<Command>(static_cast<int>(Command::Command0) + (c - '0')));
        }
        else if (c == '.')
        {
            manager.SendCommand(Command::CommandPNT);
        }
        else if (c == '+')
        {
            manager.SendCommand(Command::CommandADD);
        }
        else if (c == '-')
        {
            manager.SendCommand(Command::CommandSUB);
        }
        else if (c == '*')
        {
            manager.SendCommand(Command::CommandMUL);
        }
        else if (c == '/')
        {
            manager.SendCommand(Command::CommandDIV);
        }
        else if (c == '=')
        {
            manager.SendCommand(Command::CommandEQU);
        }
        else if (c == 'c' || c == 'C')
        {
            manager.SendCommand(Command::CommandCLEAR);
        }
    }
}

int main()
{
    ConsoleDisplay d;
    SimpleResourceProvider r;
    CCalcEngine::InitialOneTimeOnlySetup(r);

    CalculatorManager manager(&d, &r);
    manager.SetStandardMode();

    std::cout << "========================================" << std::endl;
    std::cout << "   Windows Calculator Core for macOS    " << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << "Basic commands: 0-9, +, -, *, /, =, C(lear), Q(uit)" << std::endl;
    std::cout << "> " << std::flush;

    string input;
    while (cin >> input)
    {
        if (input == "q" || input == "Q")
            break;
        SendString(manager, input);
    }

    std::cout << "Goodbye!" << std::endl;
    return 0;
}
