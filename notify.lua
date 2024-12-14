-- Function to create and show a custom notification
local function showCustomNotification(title, text, duration)
    -- Create a ScreenGui to hold the notification UI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NotificationGui"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create the main notification Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 80)      -- Width: 250px, Height: 80px
    frame.Position = UDim2.new(1, -270, 0, 20) -- Position it in the top-right corner with a little padding
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Dark background
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- Create a UI Corner for rounded edges
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8) -- Slightly rounded corners
    uiCorner.Parent = frame

    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1, -20, 0, 30) -- Fit within the frame
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 20
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    -- Text Label
    local textLabel = Instance.new("TextLabel")
    textLabel.Text = text
    textLabel.Size = UDim2.new(1, -20, 0, 35) -- Fit within the frame below the title
    textLabel.Position = UDim2.new(0, 10, 0, 35)
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextSize = 16
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.BackgroundTransparency = 1
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.Parent = frame

    -- Fade-in Effect
    frame.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    textLabel.TextTransparency = 1

    -- Tween the transparency to fade in
    game:GetService("TweenService"):Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 0.2}):Play()
    game:GetService("TweenService"):Create(titleLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    game:GetService("TweenService"):Create(textLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

    -- Wait for the duration before fading out
    wait(duration)

    -- Fade-out Effect
    game:GetService("TweenService"):Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    game:GetService("TweenService"):Create(titleLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    game:GetService("TweenService"):Create(textLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()

    -- Remove the GUI after fade-out
    wait(0.5)
    screenGui:Destroy()
end

-- Example usage
showCustomNotification("Natural Idiot", "Custom Abilities Enabled! Only execute this script once or it'll break!", 8)
