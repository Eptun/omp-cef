#pragma once

#include "component.hpp"
#include "chat_view.hpp"

#include <memory>
#include <string>

class ChatComponent : public ISampComponent
{
public:
    void Initialize() override;

    void Clear();
    void Send(const std::string& text);

private:
    std::unique_ptr<IChatView> view_;
};
