local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local screenGui
local checkLoop
local clonedTemplate
-- Variables to track the highest point and bounce calculations
local highestYPosition = 0
local bounceForceMultiplier = 3.8 -- 380% of the fall distance
local fallingAnimationTrack
local bouncingAnimationTrack
local buttonCreated = false
local imageButton -- Moved imageButton to be a global variable
local backgroundImageLabel -- ImageLabel for the custom background image
local shouldBounce = false
local userchar
local cooldown = 0
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
local function createBouncingAnimation()
    local animationId = "14694012690" -- Replace with your animation ID
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. animationId
    return player.Character:WaitForChild("Humanoid"):LoadAnimation(animation)
end

local function createFallingAnimation()
    local animationId = "14693821579" -- Replace with your animation ID
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. animationId
    return player.Character:WaitForChild("Humanoid"):LoadAnimation(animation)
end

-- Function to apply bounce effect
local function applyBounce()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    if humanoid and humanoidRootPart then
        local fallDistance = highestYPosition - humanoidRootPart.Position.Y -- Calculate fall distance
        local bounceForce = fallDistance * bounceForceMultiplier -- Calculate bounce force
        if bounceForce < 85 then
            bounceForce = 85
        end
        print(bounceForce)
        humanoidRootPart.Velocity = Vector3.new(humanoidRootPart.Velocity.X, bounceForce, humanoidRootPart.Velocity.Z) -- Set upward velocity
        highestYPosition = 0 -- Reset highest position after bouncing
    end
end

-- Function to detect when the player lands
local function onStateChanged(_, newState)
    if newState == Enum.HumanoidStateType.Landed then
        fallingAnimationTrack:Stop()
        if shouldBounce then
            applyBounce() -- Apply bounce effect on landing
            shouldBounce = false
            
            bouncingAnimationTrack:Play()
        else
            bouncingAnimationTrack:Stop()
        end
    elseif newState == Enum.HumanoidStateType.Freefall then
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            highestYPosition = math.max(highestYPosition, humanoidRootPart.Position.Y) -- Update highest Y position
        end
    end
end

-- Function to create the button and background image label
local function createButton()
    if buttonCreated then return end
    print("Created button")

if buttonCreated then return end
    print("Setting up cloned ability button")

    -- Access the original `abilityTemplate` and clone it
    local playerGui = player:WaitForChild("PlayerGui")
    local originalTemplate = playerGui.gui.hud.abilities.abilitiesScreen.templateButton
    clonedTemplate = originalTemplate:Clone()
    local targetButton
    -- Access the target button in mobileButtonPositions
        targetButton = playerGui.gui.hud.mobileButtonPositions.button3
    

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
    if userchar == "amy" then
        clonedTemplate.Visible = true
        clonedTemplate.abilityName.Visible = true
    else
        clonedTemplate.Visible = false
        clonedTemplate.abilityName.Visible = false
    end

    -- Set button appearance
    clonedTemplate.abilityName.Text = "hammerbounce"
    clonedTemplate.button.Image = "rbxassetid://15353589738"
    clonedTemplate.button.PressedImage = "rbxassetid://15353589738"
    
    -- Connect the button click event to set the highest point
    clonedTemplate.button.MouseButton1Click:Connect(function()
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart and humanoid and cooldown < 1 then
        -- Check if the humanoid is in freefall (midair)
        if humanoid:GetState() == Enum.HumanoidStateType.Freefall or humanoid:GetState() == Enum.HumanoidStateType.Jumping then
            highestYPosition = humanoidRootPart.Position.Y -- Set the highest point to the current position
            fallingAnimationTrack:Play()
            shouldBounce = true
            clonedTemplate.button.ImageColor3 = Color3.new(0, 255, 0) -- Change button color to green
            while shouldBounce do
            wait(0.1)
            end
            clonedTemplate.button.ImageColor3 = Color3.new(255, 0, 0)
            cooldown = 24
        clonedTemplate.cooldown.Visible = true
        clonedTemplate.cooldown.currentCooldown.Text = cooldown
        else
            print("Cannot use the button while on the ground.")
        end
    end
end)


    buttonCreated = true -- Prevent multiple button creations
end



-- Function to handle character respawn
local function onCharacterAdded(character)
    -- Set up necessary variables
    local humanoid = character:WaitForChild("Humanoid")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Load animation for the new character
    fallingAnimationTrack = createFallingAnimation()
    BouncingAnimationTrack = createBouncingAnimation()
    
    -- Reset the highest position
    highestYPosition = 0
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
        if userchar == "amy" then
            createButton()
            while humanoidRootPart.Position.Y > 90 do
        if cooldown > 0 then
        clonedTemplate.cooldown.currentCooldown.Text = cooldown
        wait(1)
        cooldown = cooldown - 1
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

    if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonB then
        if humanoidRootPart and humanoid and cooldown < 1 then
        -- Check if the humanoid is in freefall (midair)
        if humanoid:GetState() == Enum.HumanoidStateType.Freefall or humanoid:GetState() == Enum.HumanoidStateType.Jumping then
            highestYPosition = humanoidRootPart.Position.Y -- Set the highest point to the current position
            fallingAnimationTrack:Play()
            shouldBounce = true
            clonedTemplate.button.ImageColor3 = Color3.new(0, 255, 0) -- Change button color to green
            while shouldBounce do
            wait(0.1)
            end
            clonedTemplate.button.ImageColor3 = Color3.new(255, 0, 0)
            cooldown = 24
        clonedTemplate.cooldown.Visible = true
        clonedTemplate.cooldown.currentCooldown.Text = cooldown
        else
            print("Cannot use the button while on the ground.")
        end
    end
    end
end

local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end

    if (input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonY) or 
       (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.X) then
        local humanoid = player.Character:FindFirstChild("Humanoid")
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart and humanoid and cooldown < 1 and userchar == "amy" then
        -- Check if the humanoid is in freefall (midair)
        if humanoid:GetState() == Enum.HumanoidStateType.Freefall or humanoid:GetState() == Enum.HumanoidStateType.Jumping then
            highestYPosition = humanoidRootPart.Position.Y -- Set the highest point to the current position
            fallingAnimationTrack:Play()
            shouldBounce = true
            clonedTemplate.button.ImageColor3 = Color3.new(0, 255, 0) -- Change button color to green
            while shouldBounce do
            wait(0.1)
            end
            clonedTemplate.button.ImageColor3 = Color3.new(255, 0, 0)
            cooldown = 24
        clonedTemplate.cooldown.Visible = true
        clonedTemplate.cooldown.currentCooldown.Text = cooldown
        else
            print("Cannot use the button while on the ground.")
        end
    end
    end
end

-- Connect the input detection to the UserInputService
UserInputService.InputBegan:Connect(onInputBegan)

-- Initial setup
setup()
