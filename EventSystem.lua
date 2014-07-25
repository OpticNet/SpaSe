local EventSystem = { }
local EventCallbacks = { } 

function EventSystem.AddCallback(ref_id, event_id, func)
	EventCallbacks[ref_id] = {event_id, func}
end

function EventSystem.RemoveCallback(ref_id)
	EventCallbacks[ref_id] = nil
end

function EventSystem.FireEvent(id, ...)
	local args = {...}
	for _, v in pairs(EventCallbacks) do
		if v[1] == id then
			v[2](unpack(args))
		end
	end
end
return EventSystem