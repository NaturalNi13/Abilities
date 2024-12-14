local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local screenGui
local checkLoop
local currentChar
local canRoll = true
local cooldown = 0
local clonedTemplate
local animationTrack
local buttonCreated = false
local shouldBounce = false
local userchar

local function getUserChar()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local playerUsername = player.Name
    local playerStats = ReplicatedStorage.displayPlayers:FindFirstChild(playerUsername)
    
    if playerStats then
        local characterStats = playerStats:FindFirstChild("stats"):FindFirstChild("character")
        if characterStats then
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
    local animationId = "18400648383"
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. animationId
    return player.Character:WaitForChild("Humanoid"):LoadAnimation(animation)
end


-- Function to apply bounce effect
local function applyBounce()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    if humanoid and humanoidRootPart and canRoll then
        canRoll = false  -- Prevent further bounces during the effect

        -- Stop all other animations initially
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if track ~= animationTrack then
                    track:Stop()
                end
            end
        end

        -- Play the specified bounce animation
        animationTrack:Play()

        -- Store the original walk speed and set bounce speed
        local originalSpeed = humanoid.WalkSpeed
        local bounceSpeed = 75
        local bounceDuration = 4  -- Time over which speed decays
        local elapsedTime = 0  -- Timer to track bounce duration

        -- Set speed to bounce speed
        humanoid.WalkSpeed = bounceSpeed

        -- Push player forward in current direction
        local forwardDirection = humanoidRootPart.CFrame.LookVector
        humanoidRootPart.Velocity = forwardDirection * bounceSpeed

        -- Set up RenderStepped for smooth deceleration
        local connection  -- Will hold the RenderStepped connection
        connection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
            -- Continuously stop any other animations
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    if track ~= animationTrack then
                        track:Stop()
                    end
                end
            end

            if elapsedTime < bounceDuration then
                -- Update elapsed time
                elapsedTime = elapsedTime + deltaTime
                -- Smoothly transition speed back to original
                local speedProgress = elapsedTime / bounceDuration
                humanoid.WalkSpeed = originalSpeed + (bounceSpeed - originalSpeed) * (1 - speedProgress)
            else
                -- Restore original speed and re-enable rolling
                humanoid.WalkSpeed = originalSpeed
                canRoll = true
                animationTrack:Stop()  -- Stop the bounce animation
                connection:Disconnect()  -- Stop RenderStepped
            end
        end)
    end
end





-- Updated Function to set up the ability template button
local function setupAbilityButton()
    if buttonCreated then return end
    print("Setting up cloned ability button")

    -- Access the original `abilityTemplate` and clone it
    local playerGui = player:WaitForChild("PlayerGui")
    local originalTemplate = playerGui.gui.hud.abilities.abilitiesScreen.templateButton
    clonedTemplate = originalTemplate:Clone()
    local targetButton
    -- Access the target button in mobileButtonPositions
    
        targetButton = playerGui.gui.hud.mobileButtonPositions.button6
    

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
    if userchar == "tails" or userchar == "knuckles"  then
        clonedTemplate.Visible = true
        clonedTemplate.abilityName.Visible = true
    else
        clonedTemplate.Visible = false
        clonedTemplate.abilityName.Visible = false
    end

    -- Set button appearance
    clonedTemplate.abilityName.Text = "spindash"
    clonedTemplate.button.Image = "rbxassetid://18426815197"
    clonedTemplate.button.PressedImage = "rbxassetid://18426815197"
    
    -- Connect the button's click event on the clone
    clonedTemplate.button.MouseButton1Down:Connect(function()
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        
        if humanoidRootPart and humanoid and cooldown < 1  then
            if humanoid:GetState() == Enum.HumanoidStateType.Landed or humanoid:GetState() == Enum.HumanoidStateType.Running and canRoll == true then
                
                animationTrack:Play()
                clonedTemplate.button.ImageColor3 = Color3.new(0, 255, 0)
                applyBounce()
                while not canRoll do
                task.wait()
                end
                 clonedTemplate.button.ImageColor3 = Color3.new(255, 0, 0)
                 cooldown = 25
                clonedTemplate.cooldown.Visible = true
        clonedTemplate.cooldown.currentCooldown.Text = cooldown
            else
                print("Cannot use the button while on the ground.")
            end
        end
    end)

    buttonCreated = true -- Prevent further cloning if already set up
end



-- Function to handle character respawn
local function onCharacterAdded(character)
    currentChar = character
    local humanoid = character:WaitForChild("Humanoid")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    animationTrack = createAnimation()
    
    
    buttonCreated = false
    
    humanoid.StateChanged:Connect(onStateChanged)
    canRoll = true
    wait(0.1)
    while humanoidRootPart.Position.Y < 90 do
        task.wait(0.1)
    end
    getUserChar()
    if userchar == "tails" or userchar == "knuckles" then
        setupAbilityButton()
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
-- Initial setup
local function setup()
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then
        onCharacterAdded(player.Character)
    end
end
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    getUserChar()
    if (input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonB) or 
       (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q) then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if userchar == "tails" or userchar == "knuckles" then
        if humanoidRootPart and humanoid and cooldown < 1  then
            if humanoid:GetState() == Enum.HumanoidStateType.Landed or humanoid:GetState() == Enum.HumanoidStateType.Running and canRoll == true then
                
                animationTrack:Play()
                clonedTemplate.button.ImageColor3 = Color3.new(0, 255, 0)
                applyBounce()
                while not canRoll do
                task.wait()
                end
                 clonedTemplate.button.ImageColor3 = Color3.new(255, 0, 0)
                 cooldown = 25
                clonedTemplate.cooldown.Visible = true
        clonedTemplate.cooldown.currentCooldown.Text = cooldown
            else
                print("Cannot use the button while on the ground.")
            end
        end
        end
    end
end

UserInputService.InputBegan:Connect(onInputBegan)
setup()
