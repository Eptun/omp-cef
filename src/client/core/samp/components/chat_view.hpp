#pragma once

class IChatView
{
public:
    virtual ~IChatView() = default;

    virtual void Clear() = 0;

    // Sends a line through SA-MP's input box, exactly as if the player typed it
    // and pressed Enter (handles /commands and plain chat).
    virtual void Send(const char* text) = 0;
};
