#include "chat.hpp"

#include <cstring>

sampapi::v03dl::CChat* ChatView_DL::GetChat() const
{
    return sampapi::v03dl::RefChat();
}

void ChatView_DL::Clear()
{
    auto* chat = GetChat();
    if (!chat)
        return;

    for (int i = 0; i < sampapi::v03dl::CChat::MAX_MESSAGES; ++i)
    {
        std::memset(&chat->m_entry[i], 0, sizeof(chat->m_entry[i]));
    }

    if (chat->m_szLastMessage)
        chat->m_szLastMessage[0] = '\0';

    chat->m_nScrollbarPos = 0;
    chat->m_bRedraw = TRUE;

    chat->UpdateScrollbar();
    chat->ScrollToBottom();
}

void ChatView_DL::Send(const char* text)
{
    if (!text || !*text)
        return;

    auto* input = sampapi::v03dl::RefInputBox();
    if (!input)
        return;

    // Register SA-MP's reserved client commands (/save, /quit, ...) once. See R1 note.
    static bool s_commandsReady = false;
    if (!s_commandsReady)
    {
        sampapi::v03dl::Commands::Setup();
        s_commandsReady = true;
    }

    input->Send(text);
}
