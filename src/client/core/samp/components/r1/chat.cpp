#include "chat.hpp"

#include <cstring>

sampapi::v037r1::CChat* ChatView_R1::GetChat() const
{
    return sampapi::v037r1::RefChat();
}

void ChatView_R1::Clear()
{
    auto* chat = GetChat();
    if (!chat)
        return;

    // Clear entries
    for (int i = 0; i < sampapi::v037r1::CChat::MAX_MESSAGES; ++i)
    {
        std::memset(&chat->m_entry[i], 0, sizeof(chat->m_entry[i]));
    }

    // Reset helper fields where available
    if (chat->m_szLastMessage)
        chat->m_szLastMessage[0] = '\0';

    chat->m_nScrollbarPos = 0;
    chat->m_bRedraw = TRUE;

    chat->UpdateScrollbar();
    chat->ScrollToBottom();
}

void ChatView_R1::Send(const char* text)
{
    if (!text || !*text)
        return;

    auto* input = sampapi::v037r1::RefInputBox();
    if (!input)
        return;

    // Register SA-MP's reserved client commands (/save, /quit, ...) once. omp-cef
    // disables the native chat input, so SA-MP's own Commands::Setup() never runs;
    // without it CInput::Send forwards every "/cmd" to the server instead of
    // dispatching the client handler.
    static bool s_commandsReady = false;
    if (!s_commandsReady)
    {
        sampapi::v037r1::Commands::Setup();
        s_commandsReady = true;
    }

    input->Send(text);
}
