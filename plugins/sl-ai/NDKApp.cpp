/**
 * Copyright 2023-2024 Theai, Inc. dba Inworld AI
 *
 * Use of this source code is governed by the Inworld.ai Software Development Kit License Agreement
 * that can be found in the LICENSE.md file or at https://www.inworld.ai/sdk-license
 */

#include "NDKApp.h"

#include "Utils/Log.h"
#include "Packets.h"

// !!! Fill out this options !!!
constexpr std::string_view g_SceneName = "";
constexpr std::string_view g_Base64 = "";
constexpr std::string_view g_ApiKey = "";
constexpr std::string_view g_ApiSecret = "";

static bool IsConfigValid()
{
	// cppcheck-suppress redundantCondition
	// cppcheck-suppress knownConditionTrueFalse
	if (g_SceneName.empty())
	{
		return false;
	}
	// cppcheck-suppress redundantCondition
	// cppcheck-suppress knownConditionTrueFalse
	// cppcheck-suppress identicalConditionAfterEarlyExit
	return !g_Base64.empty() || (g_ApiKey.empty() && g_ApiSecret.empty());
}

void NDKApp::App::Run()
{
	if (!IsConfigValid())
	{
		Inworld::LogError("Fill out client options in Application.cpp");
		return;
	}

	_Options.ServerUrl = "api-engine.inworld.ai:443";
	_Options.UserConfig.Name = "Streamlabs";

	_Options.SceneName = g_SceneName;
	_Options.Base64 = g_Base64;
	_Options.ApiKey = g_ApiKey;
	_Options.ApiSecret = g_ApiSecret;
	//_Options.GameSessionId = "ndk-test-game-session";

	_Options.Capabilities.Animations = false;
	_Options.Capabilities.Audio = false;
	_Options.Capabilities.Emotions = true;
	_Options.Capabilities.Interruptions = true;
	_Options.Capabilities.EmotionStreaming = true;
	_Options.Capabilities.SilenceEvents = true;
	_Options.Capabilities.PhonemeInfo = true;
	_Options.Capabilities.NarratedActions = true;
	_Options.Capabilities.Multiagent = true;

	std::vector<Inworld::AgentInfo> AgentInfos;

	_Client.Client().InitClientAsync(
		{},
		[this](Inworld::Client::ConnectionState ConnectionState)
		{
			std::string Error;
			int32_t Code;
			_Client.Client().GetConnectionError(Error, Code);

			Inworld::Log("Connection state: %d. %s", static_cast<int32_t>(ConnectionState), Error.empty() ? "" : (std::string(" Error: ") + Error).c_str());

			if (ConnectionState == Inworld::Client::ConnectionState::Disconnected)
			{
				_Client.Client().ResumeClient();
			}
		},
		[this](std::shared_ptr<Inworld::Packet> Packet)
		{
			Packet->Accept(*this);
		}
		);

	_Client.Client().SetPerceivedLatencyTrackerCallback([](const std::string& InteractonId, int32_t Latency)
		{
			//Inworld::Log("PerceivedLatencyTracker. Latency is '%d', Interaction: %s", Latency, ARG_STR(InteractonId));
		});

	Inworld::SessionInfo SessionInfo;
	_Client.Client().StartClient(_Options, SessionInfo);

	while (!m_stop)
	{
		_Client.TaskExec.Execute();
		std::this_thread::sleep_for(std::chrono::milliseconds(30));
	}
}

void NDKApp::App::Stop()
{
	m_stop = false;
}

void NDKApp::App::Error(std::string Msg)
{
	Inworld::LogError("%s", ARG_STR(Msg));
}

void NDKApp::App::NextCharacter()
{
	if (_AgentInfos.empty())
	{
		Error("Agents are empty");
		return;
	}

	if (_CurrentAgentIdxs.empty())
	{
		_CurrentAgentIdxs.push_back(0);
	}
	else if (_CurrentAgentIdxs.size() > 1)
	{
		Error("Multiple characters, use SetChar");
	}
	else if (++_CurrentAgentIdxs[0] == _AgentInfos.size())
	{
		_CurrentAgentIdxs[0] = 0;
	}
	NotifyCurrentCharacter();
}

void NDKApp::App::PrevCharacter()
{
	if (_AgentInfos.empty())
	{
		Error("Agents are empty");
		return;
	}

	if (_CurrentAgentIdxs.empty())
	{
		_CurrentAgentIdxs.push_back(0);
	}
	else if (_CurrentAgentIdxs.size() > 1)
	{
		Error("Multiple characters, use SetChar");
	}
	else if (--_CurrentAgentIdxs[0] == 0)
	{
		_CurrentAgentIdxs[0] = _AgentInfos.size() - 1;
	}

	NotifyCurrentCharacter();
}

void NDKApp::App::SetCharacter(const std::vector<int32_t>& Idxs)
{
	if (Idxs.empty())
	{
		Error("Empty char list");
		return;
	}

	_CurrentAgentIdxs.clear();
	for (int32_t Idx : Idxs)
	{
		if (Idx >= 0 && Idx < _AgentInfos.size())
		{
			_CurrentAgentIdxs.push_back(Idx);
		}
	}
	NotifyCurrentCharacter();
}

void NDKApp::App::NotifyCurrentCharacter()
{
	if (_CurrentAgentIdxs.empty())
	{
		Inworld::Log("No current character");
	}

	for (int32_t Idx : _CurrentAgentIdxs)
	{
		auto& Info = _AgentInfos[Idx];
		Inworld::Log("Current character: %d %s %s", Idx, ARG_STR(Info.GivenName), ARG_STR(Info.AgentId));
	}
}

std::vector<std::string> NDKApp::App::GetCurrentAgentBrains() const
{
	std::vector<std::string> Brains;
	for (int32_t i = 0; i < _CurrentAgentIdxs.size(); i++)
	{
		Brains.push_back(_AgentInfos[_CurrentAgentIdxs[i]].AgentId);
	}
	return Brains;
}

void NDKApp::App::Visit(const Inworld::TextEvent& Event)
{
	std::string Targets;
	for (const auto& Target : Event._Routing._Targets)
	{
		Targets += (Target._Type == 1/*InworldPackets::Actor_Type_PLAYER*/) ? "Player" : GetGivenName(Target._Name);
		Targets += " ";
	}

	Inworld::Log("%s to %s: Text: %s", ARG_STR(GetGivenName(Event._Routing._Source._Name)), ARG_STR(Targets), ARG_STR(Event.GetText()));
}

void NDKApp::App::Visit(const Inworld::CustomEvent& Event)
{
	Inworld::Log("%s: Custom: %s", ARG_STR(GetGivenName(Event._Routing._Source._Name)), ARG_STR(Event.GetName()));
}

void NDKApp::App::Visit(const Inworld::AudioDataEvent& Event)
{
	Inworld::Log("%s: Audio: %d", ARG_STR(GetGivenName(Event._Routing._Source._Name)), Event.GetDataChunk().size());
}

void NDKApp::App::Visit(const Inworld::SessionControlResponse_LoadScene& Event)
{
	_Client.TaskExec.Push([this, AgentInfos = Event.GetAgentInfos()]()
		{
			_AgentInfos = AgentInfos;
			if (!AgentInfos.empty())
			{
				_CurrentAgentIdxs.clear();
				_CurrentAgentIdxs.push_back(0);
				NotifyCurrentCharacter();
			}
		});
}

void NDKApp::App::Visit(const Inworld::SessionControlResponse_LoadCharacters& Event)
{
	_Client.TaskExec.Push([this, AgentInfos = Event.GetAgentInfos()]()
		{
			Inworld::Log("LoadCharacters done.");

			_AgentInfos.insert(_AgentInfos.end(), AgentInfos.begin(), AgentInfos.end());
		});
}

void NDKApp::App::Visit(const Inworld::CustomGestureEvent& Event)
{
	//Inworld::Log("%s: Custom gesture: %s", ARG_STR(GetGivenName(Event._Routing._Source._Name)), ARG_STR(Event.GetCustomGesture()));
}

void NDKApp::App::Visit(const Inworld::CancelResponseEvent& Event)
{

}

void NDKApp::App::Visit(const Inworld::EmotionEvent& Event)
{
	//Inworld::Log("%s: Emotion: Behavior %d, Strengths %d", ARG_STR(GetGivenName(Event._Routing._Source._Name)), (int32_t)Event.GetEmotionalBehavior(), (int32_t)Event.GetStrength());
}

void NDKApp::App::Visit(const Inworld::ControlEvent& Event)
{
	Inworld::Log("%s: Control: %d %s", ARG_STR(GetGivenName(Event._Routing._Source._Name)), (int32_t)Event.GetControlAction(), ARG_STR(Event.GetDescription()));
}

void NDKApp::App::Visit(const Inworld::SilenceEvent& Event)
{
	Inworld::Log("%s: Silence: Duration %f", ARG_STR(GetGivenName(Event._Routing._Source._Name)), Event.GetDuration());
}

void NDKApp::App::Visit(const Inworld::DataEvent& Event)
{
	Inworld::Log("%s: Data: Size %d", ARG_STR(GetGivenName(Event._Routing._Source._Name)), Event.GetDataChunk().size());
}

std::string NDKApp::App::GetGivenName(const std::string& AgentId) const
{
	auto it = std::find_if(_AgentInfos.begin(), _AgentInfos.end(), [&AgentId](const auto& Info) { return Info.AgentId == AgentId; });
	if (it == _AgentInfos.end())
	{
		return "InvalidName";
	}
	return it->GivenName;
}
