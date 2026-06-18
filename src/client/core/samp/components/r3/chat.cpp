#include "chat.hpp"

#include <cstring>

sampapi::v037r3::CChat* ChatView_R3::GetChat() const
{
    return sampapi::v037r3::RefChat();
}

void ChatView_R3::Clear()
{
    auto* chat = GetChat();
    if (!chat)
        return;

    for (int i = 0; i < sampapi::v037r3::CChat::MAX_MESSAGES; ++i)
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

void ChatView_R3::Send(const char* text)
{
    if (!text || !*text)
        return;

    auto* input = sampapi::v037r3::RefInputBox();
    if (!input)
        return;

    // Register SA-MP's reserved client commands (/save, /quit, ...) once. See R1 note.
    static bool s_commandsReady = false;
    if (!s_commandsReady)
    {
        sampapi::v037r3::Commands::Setup();
        s_commandsReady = true;
    }

    input->Send(text);
}
