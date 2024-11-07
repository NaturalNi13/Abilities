-- Function to show a notification using Roblox's default corner notification
local function showNotification(title, text, duration)
    game.StarterGui:SetCore("SendNotification", {
        Title = title;         -- Title of the notification
        Text = text;           -- Body of the notification
        Duration = duration;   -- Duration in seconds
    })
end

-- Example usage: Display a welcome message
showNotification("Natural Idiot", "If you got this from somewhere besides my discord server dm me: naturalidiot123", 15)

-- You can use this function anytime to display other notifications. For example:
-- showNotification("Achievement Unlocked!", "You reached Level 10!", 3)
