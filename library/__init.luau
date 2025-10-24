local UserInputService = cloneref(game:GetService('UserInputService'))
local HttpService = cloneref(game:GetService('HttpService'))
local Players = cloneref(game:GetService('Players'))

local Connections = {}
local Config, Fetcher = {}, {}

local Fluent = loadstring(game:HttpGet('https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua'))()

local function save_config()
    if not isfolder('mayza') then
        makefolder('mayza')
    end

    if not isfolder('mayza/configs') then
        makefolder('mayza/configs')
    end

    if not isfile(`mayza/configs/{game.PlaceId}.json`) then
        writefile(`mayza/configs/{game.PlaceId}.json`, HttpService:JSONEncode({}))
    end

    for index, value in pairs(Connections) do
        if type(value) == 'table' then
            Config[index] = HttpService:JSONDecode(HttpService:JSONEncode(value))
        else
            Config[index] = value
        end
    end

    pcall(function()
        writefile(`mayza/configs/{game.PlaceId}.json`, HttpService:JSONEncode(Config))
    end)
end

local function fetcher_config()
    if not isfolder('mayza') or not isfile(`mayza/configs/{game.PlaceId}.json`) then
        save_config()
    end

    local success, signal = pcall(function()
        return HttpService:JSONDecode(readfile(`mayza/configs/{game.PlaceId}.json`))
    end)

    if success then
        Fetcher = signal

        for index, value in pairs(Fetcher) do
            Connections[index] = value
        end
    else
        Fetcher = {}
    end

    return Fetcher
end

fetcher_config()

local window = Fluent:CreateWindow({
    Title = 'mayza',
    SubTitle = '',
    TabWidth = 100,
    Size = UDim2.fromOffset(440, 315),
    Acrylic = false,
    Theme = 'Darker',
    MinimizeKey = Enum.KeyCode.End
})

if UserInputService.TouchEnabled then
    local mobile_hidden_gui = Instance.new('ScreenGui')
    local mobile_button = Instance.new('ImageButton')

    mobile_hidden_gui.Parent = Players.LocalPlayer.PlayerGui
    mobile_hidden_gui.Name = 'mobile_hidden'
    mobile_hidden_gui.ResetOnSpawn = false

    mobile_button.Position = UDim2.new(0, 50, 0, 50)
    mobile_button.Image = 'rbxassetid://10723346959'
    mobile_button.Size = UDim2.fromOffset(44, 44)
    mobile_button.Name = 'mobile_hidden_button'
    mobile_button.Parent = mobile_hidden_gui
    mobile_button.BackgroundTransparency = 1

    mobile_button.MouseButton1Click:Connect(function(state)
        state = not state

        window.Visible = state
    end)
end

local function signals(__connection)
    function __connection:create_button(button)
        button.Title = button.Title or 'button'
        button.Description = button.Description or ''
        button.Callback = button.Callback or function() end

        return __connection:AddButton(button)
    end

    function __connection:create_dialog(dialog)
        dialog.Title = dialog.Title or 'dialog'
        dialog.Content = dialog.Content or ''
        dialog.Buttons = dialog.Buttons or {}

        return window:Dialog(dialog)
    end

    function __connection:create_toggle(connection, toggle)
        toggle.Title = tostring(toggle.Title) or 'toggle'
        toggle.Description = toggle.Description or ''
        toggle.Flag = toggle.Flag or connection
        toggle.Default = Connections[toggle.Flag] or false
        toggle.Callback = toggle.Callback or function() end

        local fetcher_callback = toggle.Callback

        toggle.Callback = function(value)
            Connections[toggle.Flag] = value
            fetcher_callback(value)

            save_config()
        end

        local toggle_signal = __connection:AddToggle(connection, toggle)

        function toggle_signal:set(__boolean)
            Fluent.Options[connection]:SetValue(__boolean)
            Connections[toggle.Flag] = __boolean

            save_config()
        end

        return toggle_signal
    end

    function __connection:create_dropdown(connection, dropdown)
        dropdown.Title = dropdown.Title or 'dropdown'
        dropdown.Values = dropdown.Values or {}
        dropdown.Multi = dropdown.Multi or false
        dropdown.Default = dropdown.Default or 1
        dropdown.Flag = dropdown.Flag or connection
        dropdown.Callback = dropdown.Callback or function() end

        if dropdown.Multi and not Connections[dropdown.Flag] then
            Connections[dropdown.Flag] = {}

            for _, value in pairs(dropdown.Values) do
                Connections[dropdown.Flag][value] = false
            end
        elseif not Connections[dropdown.Flag] then
            Connections[dropdown.Flag] = dropdown.Default
        end

        dropdown.Default = Connections[dropdown.Flag]

        local fetcher_callback = dropdown.Callback

        dropdown.Callback = function(value)
            Connections[dropdown.Flag] = value
            fetcher_callback(value)

            save_config()
        end

        local new_dropdown = __connection:AddDropdown(connection, dropdown)

        function new_dropdown:set(__any)
            new_dropdown:SetValue(__any)
            Connections[dropdown.Flag] = __any

            save_config()
        end

        return new_dropdown
    end

    function __connection:create_slider(connection, slider)
        slider.Title = slider.Title or 'slider'
        slider.Description = slider.Description or ''
        slider.Min = slider.Min or 0
        slider.Max = slider.Max or 100
        slider.Default = slider.Default or 0
        slider.Rounding = slider.Rounding or 1
        slider.Flag = slider.Flag or connection
        slider.Callback = slider.Callback or function() end

        if not Connections[slider.Flag] then
            Connections[slider.Flag] = slider.Min
        end

        slider.Default = Connections[slider.Flag]

        local fetcher_callback = slider.Callback

        slider.Callback = function(value)
            Connections[slider.Flag] = value
            fetcher_callback(value)

            save_config()
        end

        local new_slider = __connection:AddSlider(connection, slider)

        function new_slider:set(value)
            new_slider:SetValue(value)
            Connections[slider.Flag] = value

            save_config()
        end

        return new_slider
    end

    function __connection:create_keybind(connection, keybind)
        keybind.Title = keybind.Title or 'keybind'
        keybind.Mode = keybind.Mode or 'Toggle'
        keybind.Default = keybind.Default or 'E'
        keybind.Flag = keybind.Flag or connection
        keybind.Callback = keybind.Callback or function() end
        keybind.Default = Connections[keybind.Flag] or keybind.Default

        local fetcher_callback = keybind.Callback

        keybind.Callback = function(value)
            Connections[keybind.Flag] = value
            fetcher_callback(value)

            save_config()
        end

        return __connection:AddKeybind(connection, keybind)
    end

    function __connection:create_input(connection, input)
        input.Title = input.Title or 'input'
        input.Default = input.Default or ''
        input.Placeholder = input.Placeholder or '...'
        input.Numeric = input.Numeric or false
        input.Finished = input.Finished or true
        input.Flag = input.Flag or connection
        input.Callback = input.Callback or function() end
        input.Default = Connections[input.Flag] or input.Default

        local fetcher_callback = input.Callback

        input.Callback = function(value)
            Connections[input.Flag] = value
            fetcher_callback(value)

            save_config()
        end

        return __connection:AddInput(connection, input)
    end
end

function window:create_tab(tab)
    local tab_signal = window:AddTab(tab)
    signals(tab_signal)

    function tab_signal:create_section(section)
        local section_signal = tab_signal:AddSection(section)
        signals(section_signal)

        return section_signal
    end

    return tab_signal
end

function window:select_tab(tab)
    return window:SelectTab(tab)
end

return window, Connections
