-- For cards with the speakers+HDMI profile set (session.select-plugged-hdmi),
-- pick the profile whose HDMI port has a display plugged in. ACP reports every
-- one of those profiles as available (the speakers always are), so the stock
-- find-best-profile can't tell them apart; with nothing plugged in it falls
-- through to the higher-priority speakers-only profile.

cutils = require ("common-utils")
log = Log.open_topic ("s-device")

local function enabled (device)
  return cutils.parseBool (device.properties ["session.select-plugged-hdmi"])
end

-- Jack changes only update EnumRoute (profile availability stays "yes"), so
-- re-run profile selection on those too.
SimpleEventHook {
  name = "custom/select-profile-on-hdmi-jack",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "device-params-changed" },
      Constraint { "event.subject.param-id", "=", "EnumRoute" },
    },
  },
  execute = function (event)
    local device = event:get_subject ()
    if enabled (device) then
      event:get_source ():call ("push-event", "select-profile", device, nil)
    end
  end
}:register ()

SimpleEventHook {
  name = "custom/find-plugged-hdmi-profile",
  after = { "device/find-stored-profile", "device/find-preferred-profile" },
  before = "device/find-best-profile",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "select-profile" },
    },
  },
  execute = function (event)
    local device = event:get_subject ()
    if event:get_data ("selected-profile") or not enabled (device) then
      return
    end

    local plugged = {}
    for p in device:iterate_params ("EnumRoute") do
      local route = cutils.parseParam (p, "EnumRoute")
      if route and route.direction == "Output" and route.available == "yes" and
          route.name:find ("^hdmi%-output%-") and route.profiles then
        for _, index in pairs (route.profiles) do
          plugged [index] = true
        end
      end
    end

    local best = nil
    for p in device:iterate_params ("EnumProfile") do
      local profile = cutils.parseParam (p, "EnumProfile")
      if profile and plugged [profile.index] and
          (best == nil or profile.priority > best.priority) then
        best = profile
      end
    end

    if best then
      log:info (device, "Found plugged HDMI profile " .. best.name)
      event:set_data ("selected-profile", best)
    end
  end
}:register ()
