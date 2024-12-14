local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local screenGui
local checkLoop
local clonedTemplate
-- Variable to track if gliding is active
local isGliding = false
local bodyVelocity = nil
local animationTrack
local buttonCreated = false
local cooldown = 0
local userchar
local function getUserChar()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Access the LocalPlayer
local playerUsername = player.Name

-- Access the path with the LocalPlayer's username
local playerStats = ReplicatedStorage.displayPlayers:FindFirstChild(playerUsername)


if playerStats then
    local characterStats = playerStats:FindFirstChild("stats"):FindFirstChild("character")
    if characterStats then
        -- Set the userchar variable to the value of the character stat
        userchar = characterStats.Value
        print(userchar)
    else
        warn("Character stats not found for player:", playerUsername)
    end
else
    warn("Player stats not found for player:", playerUsername)
end
end
-- Function to create the animation
local function createAnimation()
    local animationId = "15198329335" -- Replace with your animation ID
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. animationId
    return player.Character:WaitForChild("Humanoid"):LoadAnimation(animation)
end



local function tRetreat()
if cooldown < 1 then
    cooldown = 35
        clonedTemplate.button.ImageColor3 = Color3.new(0, 255, 0)
        clonedTemplate.cooldown.currentCooldown.Text = cooldown
        game:GetService("Players").LocalPlayer.PlayerGui.stats:SetAttribute("runningSpeed", 45)
        end
end

-- Function to create the button and background image label
local function setupAbilityButton()
    if buttonCreated then return end
    print("Setting up cloned ability button")

    -- Access the original `abilityTemplate` and clone it
    local playerGui = player:WaitForChild("PlayerGui")
    local originalTemplate = playerGui.gui.hud.abilities.abilitiesScreen.templateButton
    clonedTemplate = originalTemplate:Clone()
    local targetButton
    -- Access the target button in mobileButtonPositions
    
        targetButton = playerGui.gui.hud.mobileButtonPositions.button4
    

    -- Set parent for the cloned button in the same GUI container
    clonedTemplate.Parent = playerGui.gui.hud.abilities.abilitiesScreen
    
    -- Copy AnchorPoint, Size, and Position
    clonedTemplate.AnchorPoint = targetButton.AnchorPoint
    
    -- Using UDim2 and not AbsolutePosition to set Position correctly
    clonedTemplate.Position = UDim2.new(
        targetButton.Position.X.Scale, 
        targetButton.Position.X.Offset, 
        targetButton.Position.Y.Scale, 
        targetButton.Position.Y.Offset
    )

    -- Set Size to be the same as the target button
    clonedTemplate.Size = UDim2.new(
        0, targetButton.AbsoluteSize.X, 
        0, targetButton.AbsoluteSize.Y
    )

    -- Adjust cloned button's position relative to its parent
    local parentAbsolutePosition = clonedTemplate.Parent.AbsolutePosition
    clonedTemplate.Position = UDim2.new(
        targetButton.Position.X.Scale,
        targetButton.Position.X.Offset + parentAbsolutePosition.X,
        targetButton.Position.Y.Scale,
        targetButton.Position.Y.Offset + parentAbsolutePosition.Y
    )

    -- Check character type to adjust visibility
    if userchar == "eggman" then
        clonedTemplate.Visible = true
        clonedTemplate.abilityName.Visible = true
    else
        clonedTemplate.Visible = false
        clonedTemplate.abilityName.Visible = false
    end

    -- Set button appearance
    clonedTemplate.abilityName.Text = "tacticalretreat"
    clonedTemplate.button.Image = "rbxassetid://73363777716120"
    clonedTemplate.button.PressedImage = "rbxassetid://73363777716120"
    
    -- Connect the button's click event on the clone
    clonedTemplate.button.MouseButton1Down:Connect(function()
        tRetreat()
    end)

    buttonCreated = true -- Prevent further cloning if already set up
end


-- Function to handle character respawn
local function onCharacterAdded(character)
    -- Set up necessary variables
    local humanoid = character:WaitForChild("Humanoid")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Load animation for the new character
    animationTrack = createAnimation()

    -- Reset the gliding state
    buttonCreated = false

    -- Listen for state changes
    humanoid.StateChanged:Connect(onStateChanged)
    if screenGui then
        screenGui:Destroy() -- Remove the existing ScreenGui
    end
    -- Create the button when the player is high enough
    wait(0.1)
    while humanoidRootPart.Position.Y < 90 do
            task.wait(0.1)
        end
        getUserChar()
        if userchar == "eggman" then
            setupAbilityButton()
            while humanoidRootPart.Position.Y > 90 do
        if cooldown > 0 then
        clonedTemplate.cooldown.currentCooldown.Text = cooldown
        wait(1)
        cooldown = cooldown - 1
        if cooldown < 31 then
        game:GetService("Players").LocalPlayer.PlayerGui.stats:SetAttribute("runningSpeed", 30)
        clonedTemplate.button.ImageColor3 = Color3.new(255, 0, 0)
        clonedTemplate.cooldown.Visible = true
         end
         else
         clonedTemplate.cooldown.Visible = false
         clonedTemplate.button.ImageColor3 = Color3.new(255, 255, 255)
         while cooldown < 1 do
         task.wait()
         end
         end
         task.wait()
        end
        
        end
end

-- Function to initialize GUI and events when the player joins
local function setup()

    screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    player.CharacterAdded:Connect(onCharacterAdded) -- Listen for character added
    if player.Character then
        onCharacterAdded(player.Character) -- Handle already existing character
    end
end

local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end

    if (input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonB) or 
       (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q) then
        tRetreat()
    end
end

-- Connect the input detection to the UserInputService
UserInputService.InputBegan:Connect(onInputBegan)

-- Initial setup
setup()