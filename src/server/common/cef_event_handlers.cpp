#include "cef_event_handlers.hpp"

std::vector<ICefEventHandler*>& CefHandlerList()
{
    static std::vector<ICefEventHandler*> s;
    return s;
}

const std::vector<ICefEventHandler*>& GetCefEventHandlers()
{
    return CefHandlerList();
}
