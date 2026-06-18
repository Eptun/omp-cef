#pragma once

#include "samp/components/chat_view.hpp"

#include <sampapi/0.3.7-R1/CChat.h>
#include <sampapi/0.3.7-R1/CInput.h>

class ChatView_R1 : public IChatView
{
public:
    ChatView_R1() = default;
    ~ChatView_R1() override = default;

    void Clear() override;
    void Send(const char* text) override;

private:
    sampapi::v037r1::CChat* GetChat() const;
};
