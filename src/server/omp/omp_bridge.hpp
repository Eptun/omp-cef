#pragma once

#include <functional>
#include <mutex>
#include <vector>

#include <Server/Components/Pawn/pawn.hpp>
#include "common/bridge.hpp"

std::unique_ptr<IPlatformBridge> CreateOmpPlatformBridge(ICore* core, IPawnComponent* pawn);

class OmpPlatformBridge final : public IPlatformBridge
{
public:
    OmpPlatformBridge(ICore* core, IPawnComponent* pawn);

    void LogInfo(const std::string& message) override;
    void LogWarn(const std::string& message) override;
    void LogError(const std::string& message) override;
    void LogDebug(const std::string& message) override;

    void CallPawnPublic(const std::string& name, const std::vector<Argument>& args) override;
    void CallOnBrowserCreated(int playerid, int browserid, bool success, int code, const std::string& reason) override;
    void CallOnDownloadStart(int playerid) override;
    void CallOnDownloadFinish(int playerid) override;
    void CallOnPressKey(int playerid, int key, int scancode, int modifiers, bool down, bool repeat) override;

    std::string GetPlayerAddressIp(int playerid) override;
    void KickPlayer(int playerid) override;
    bool IsPlayerNpcBot(int playerid) override;

    void ProcessPending() override;   // drain queued calls on the main thread

private:
    void Enqueue(std::function<void()> fn);
    void InvokePawnPublic(const std::string& name, const std::vector<Argument>& args);

    ICore* core_;
    IPawnComponent* pawn_;

    std::mutex queue_mutex_;
    std::vector<std::function<void()>> pending_;
};
