color = {
	{
		hex, rgb,
		text = "Main FG",
		var  = "main_fg"
	},
	{
		hex, rgb,
		text = "Secondary FG",
		var  = "secondary_fg"
	},
	{
		hex, rgb,
		text = "Main BG",
		var  = "main_bg"
	},
	{
		hex, rgb,
		text = "Sidebar BG, player BG",
		var  = "sidebar_and_player_bg"
	},
	{
		hex, rgb,
		text = "Cover overlay, Shadow",
		var  = "cover_overlay_and_shadow"
	},
	{
		hex, rgb,
		text = "Indicator FG, Button BG",
		var  = "indicator_fg_and_button_bg"
	},
	{
		hex, rgb,
		text = "Pressing FG",
		var  = "pressing_fg"
	},
	{
		hex, rgb,
		text = "Slider BG",
		var  = "slider_bg"
	},
	{
		hex, rgb,
		text = "Sidebar indicator, Hover button BG",
		var  = "sidebar_indicator_and_hover_button_bg"
	},
	{
		hex, rgb,
		text = "Scrollbar FG, Selected row BG",
		var  = "scrollbar_fg_and_selected_row_bg"
	},
	{
		hex, rgb,
		text = "Pressing button FG",
		var  = "pressing_button_fg"
	},
	{
		hex, rgb,
		text = "Pressing button BG",
		var  = "pressing_button_bg"
	},
	{
		hex, rgb,
		text = "Selected button",
		var  = "selected_button"
	},
	{
		hex, rgb,
		text = "Miscellaneous BG",
		var  = "miscellaneous_bg"
	},
	{
		hex, rgb,
		text = "Miscellaneous hover BG",
		var  = "miscellaneous_hover_bg"
	},
	{
		hex, rgb,
		text = "Preserve",
		var  = "preserve_1"
	}
}


function Initialize()
	-- Parsing color from skin variables
	local meter = 1
	for k, v in ipairs(color) do
		color[k].hex = parseColor(SKIN:GetVariable(v.var))
		color[k].rgb = hexToRGB(color[k].hex)
		SKIN:Bang('!SetOption', 'Box' .. meter, 'Color', 'Fill Color ' .. color[k].hex)
		SKIN:Bang('!SetOption', 'Box' .. meter, 'LeftMouseUpAction', table.concat({'["#@#RainRGB4.exe" "VarName=', v.var, '" "FileName=#ROOTCONFIGPATH#Themes\\#CurrentTheme#\\color.inc\\" "RefreshConfig=#CURRENTCONFIG#"]'}))

		local t = 'Text' .. meter
		local tM = SKIN:GetMeter(t)
		SKIN:Bang('!SetOption', t, 'Text', color[k].text)
		SKIN:Bang('!UpdateMeter', t)
		local s = 13
		while tM:GetH() > 45 do
			s = s - 1
			SKIN:Bang('!SetOption', t, 'FontSize', s)
			SKIN:Bang('!UpdateMeter', t)
		end
		meter = meter + 1
	end

	currentTheme = SKIN:GetVariable("CurrentTheme")
	hideAds = SKIN:GetVariable("Hide_Ads") == '1'
	injectCSS = SKIN:GetVariable("Inject_CSS") == '1'
	theme = SKIN:GetVariable("Replace_Colors") == '1'

	fileCount = SKIN:GetMeasure("FileCount")
	fileName = SKIN:GetMeasure("FileName")
	cssName = SKIN:GetMeasure("CSSFileName")
	status = 'Please wait'
	nC = 0
	curSpa = 0
end

function Update()
	return status
end

-- Get total SPA files count
function UpdateFileCount()
	SKIN:Bang('!UpdateMeasure', 'FileCount')
	totalSpa = fileCount:GetValue()
end

function UpdateInitStatus()
	UpdateFileCount()
	if totalSpa == 0 then
		SKIN:Bang('!HideMeterGroup', 'ApplyButton')
		SKIN:Bang('!ShowMeterGroup', 'ApplyButton_Disabled')
		SKIN:Bang('!HideMeterGroup', 'BackupButton_Disabled')
		SKIN:Bang('!ShowMeterGroup', 'BackupButton')
		status = 'Please backup first'
	else
		SKIN:Bang('!HideMeterGroup', 'ApplyButton_Disabled')
		SKIN:Bang('!ShowMeterGroup', 'ApplyButton')
		SKIN:Bang('!HideMeterGroup', 'BackupButton')
		SKIN:Bang('!ShowMeterGroup', 'BackupButton_Disabled')
		status = 'Ready'
	end
end

-- For progress bar
function UpdatePercent()
	if not totalSpa or not curSpa then
		return 0
	else
		return curSpa / totalSpa
	end
end

function Init_Unzip()
	bC = 0
	SKIN:Bang('!SetOption', 'FileView', 'FinishAction', '!CommandMeasure Script "UpdateFileCount();Unzip()"')
	SKIN:Bang('!UpdateMeasure', 'FileView')
	SKIN:Bang('!CommandMeasure', 'FileView', 'Update')
end

function Unzip()
	bC = bC + 1
	if bC > totalSpa then
		glue = nil
		SKIN:Bang('!Refresh')
		return
	end
	SKIN:Bang('!SetOption', 'FileName', 'Index', bC)
	SKIN:Bang('!UpdateMeasure', 'FileName')
	n = fileName:GetStringValue()
	nX = n:gsub('%.','_')
	status = "Unzipping " .. n
	curSpa = bC

	SKIN:Bang('!SetOption', 'Unzip', 'Parameter', 'e "Backup\\' .. n .. '" -oExtracted\\' .. nX .. '\\raw *.css -r')
	SKIN:Bang('!UpdateMeasure', 'Unzip')
	SKIN:Bang('!CommandMeasure', 'Unzip', 'Run')
end

function DuplicateExtracted()
	SKIN:Bang('!SetOption', 'Duplicate', 'Parameter', '"robocopy ' .. nX .. '\\raw ' .. nX .. '\\themed"')
	SKIN:Bang('!UpdateMeasure', 'Duplicate')
	SKIN:Bang('!CommandMeasure', 'Duplicate', 'Run')
end

function Init_PrepareCSS()
	pC = 1
	SKIN:Bang('!SetOption', 'CSSFileView', 'Path', '#@#Extracted\\'.. nX .. '\\themed')
	SKIN:Bang('!SetOption', 'CSSFileView', 'FinishAction', '[!CommandMeasure Script "PrepareCSS()"]')
	SKIN:Bang('!UpdateMeasure', 'CSSFileView')
	SKIN:Bang('!CommandMeasure', 'CSSFileView', 'Update')
end

function PrepareCSS()
	SKIN:Bang('!SetOption', 'CSSFileName', 'Index', pC)
	SKIN:Bang('!UpdateMeasure', 'CSSFileName')
	local nP = cssName:GetStringValue()
	if not nP or nP == '' then
		Unzip()
		return
	end

	local d = ''

	if glue and nP:match("glus%.css$") then
		d = glue
	else
		local f = io.open(nP, 'r')
		d = f:read("*a")
		f:close()
		-- Replace default color scheme with our keywords.
		-- When we apply custom color scheme, we just find
		-- and replace keywords, no need to search color
		-- again and again.
		d = d:gsub("1ed660", "modspotify_sidebar_indicator_and_hover_button_bg")
		d = d:gsub("1ed760", "modspotify_sidebar_indicator_and_hover_button_bg")
		d = d:gsub("1db954", "modspotify_indicator_fg_and_button_bg")
		d = d:gsub("1df369", "modspotify_indicator_fg_and_button_bg")
		d = d:gsub("1df269", "modspotify_indicator_fg_and_button_bg")
		d = d:gsub("1cd85e", "modspotify_indicator_fg_and_button_bg")
		d = d:gsub("1bd85e", "modspotify_indicator_fg_and_button_bg")
		d = d:gsub("18ac4d", "modspotify_selected_button")
		d = d:gsub("18ab4d", "modspotify_selected_button")
		d = d:gsub("179443", "modspotify_pressing_button_bg")
		d = d:gsub("14833b", "modspotify_pressing_button_bg")
		d = d:gsub("282828", "modspotify_main_bg")
		d = d:gsub("121212", "modspotify_main_bg")
		d = d:gsub("rgba%(18, 18, 18, ([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("181818", "modspotify_sidebar_and_player_bg")
		d = d:gsub("rgba%(18,19,20,([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("000000", "modspotify_sidebar_and_player_bg")
		d = d:gsub("333333", "modspotify_scrollbar_fg_and_selected_row_bg")
		d = d:gsub("3f3f3f", "modspotify_scrollbar_fg_and_selected_row_bg")
		d = d:gsub("535353", "modspotify_scrollbar_fg_and_selected_row_bg")
		d = d:gsub("404040", "modspotify_slider_bg")
		d = d:gsub("rgba%(80,55,80,([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("rgba%(40, 40, 40, ([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("rgba%(40,40,40,([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("rgba%(24, 24, 24, ([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("rgba%(18, 19, 20, ([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("#000011", "#modspotify_sidebar_and_player_bg")
		d = d:gsub("#0a1a2d", "#modspotify_sidebar_and_player_bg")
		d = d:gsub("ffffff", "modspotify_main_fg")
		d = d:gsub("f8f8f7", "modspotify_pressing_fg")
		d = d:gsub("fcfcfc", "modspotify_pressing_fg")
		d = d:gsub("d9d9d9", "modspotify_pressing_fg")
		d = d:gsub("adafb2", "modspotify_secondary_fg")
		d = d:gsub("c8c8c8", "modspotify_secondary_fg")
		d = d:gsub("a0a0a0", "modspotify_secondary_fg")
		d = d:gsub("bec0bb", "modspotify_secondary_fg")
		d = d:gsub("bababa", "modspotify_secondary_fg")
		d = d:gsub("b3b3b3", "modspotify_secondary_fg")
		d = d:gsub("rgba%(179, 179, 179, ([%d%.]+)%)", "rgba(modspotify_rgb_secondary_fg,%1)")
		d = d:gsub("cccccc", "modspotify_pressing_button_fg")
		d = d:gsub("ededed", "modspotify_pressing_button_fg")
		d = d:gsub("4687d6", "modspotify_miscellaneous_bg")
		d = d:gsub("rgba%(70, 135, 214, ([%d%.]+)%)", "rgba(modspotify_rgb_miscellaneous_bg,%1)")
		d = d:gsub("2e77d0", "modspotify_miscellaneous_hover_bg")
		d = d:gsub("rgba%(51,153,255,([%d%.]+)%)", "rgba(modspotify_rgb_miscellaneous_hover_bg,%1)")
		d = d:gsub("rgba%(30,50,100,([%d%.]+)%)", "rgba(modspotify_rgb_miscellaneous_hover_bg,%1)")
		d = d:gsub("rgba%(24, 24, 24, ([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("rgba%(25,20,20,([%d%.]+)%)", "rgba(modspotify_rgb_sidebar_and_player_bg,%1)")
		d = d:gsub("rgba%(160, 160, 160, ([%d%.]+)%)", "rgba(modspotify_rgb_pressing_button_fg,%1)")
		d = d:gsub("rgba%(255, 255, 255, ([%d%.]+)%)", "rgba(modspotify_rgb_pressing_button_fg,%1)")
		d = d:gsub("#ddd;", "#modspotify_pressing_button_fg;")
		d = d:gsub("#000;", "#modspotify_sidebar_and_player_bg;")
		d = d:gsub("#000 ", "#modspotify_sidebar_and_player_bg ")
		d = d:gsub("#333;", "#modspotify_scrollbar_fg_and_selected_row_bg;")
		d = d:gsub("#333 ", "#modspotify_scrollbar_fg_and_selected_row_bg ")
		d = d:gsub("#444;", "#modspotify_slider_bg;")
		d = d:gsub("#444 ", "#modspotify_slider_bg ")
		d = d:gsub("#fff;", "#modspotify_main_fg;")
		d = d:gsub("#fff ", "#modspotify_main_fg ")
		d = d:gsub(" black;", " #modspotify_sidebar_and_player_bg;")
		d = d:gsub(" black ", " #modspotify_sidebar_and_player_bg ")
		d = d:gsub(" gray ", " #modspotify_main_bg ")
		d = d:gsub(" gray;", " #modspotify_main_bg;")
		d = d:gsub(" lightgray ", " #modspotify_pressing_button_fg ")
		d = d:gsub(" lightgray;", " #modspotify_pressing_button_fg;")
		d = d:gsub(" white;", " #modspotify_main_fg;")
		d = d:gsub(" white ", " #modspotify_main_fg ")
		d = d:gsub("rgba%(0, 0, 0, ([%d%.]+)%)", "rgba(modspotify_rgb_cover_overlay_and_shadow,%1)")
		d = d:gsub("rgba%(0,0,0,([%d%.]+)%)", "rgba(modspotify_rgb_cover_overlay_and_shadow,%1)")
		d = d:gsub("#fff", "#modspotify_main_fg")
		d = d:gsub("#000", "#modspotify_sidebar_and_player_bg")
		d = table.concat({d, "\n.SearchInput__input {\nbackground-color: #modspotify_sidebar_and_player_bg !important;\ncolor: #modspotify_secondary_fg !important;}\n"})

		--Because all glue.css in all spa are the same, so
		--just store modded glue.css and we can apply to all remaining glue.css
		if not glue and nP:match("glue%.css$") then
			glue = d
		end
	end

	f = io.open(nP, 'w')
	f:write(d)
	f:close()
	pC = pC + 1
	PrepareCSS()
end

function StartMod()
	nC = 0
	SKIN:Bang('!SetOption', 'CSSFileView', 'Path', '#@#Decomp\\css')
	SKIN:Bang('!SetOption', 'CSSFileView', 'FinishAction', '[!CommandMeasure Script "ModCSS()"]')
	SKIN:Bang('!UpdateMeasure', 'CSSFileView')
	if injectCSS then
		local userCSS = io.open(SKIN:ReplaceVariables("#ROOTCONFIGPATH#Themes\\#CurrentTheme#\\user.css"),'r')
		if userCSS then
			customCSS = userCSS:read('*a')
			userCSS:close()
			for k, v in ipairs(color) do
				customCSS = customCSS:gsub("modspotify_" .. v.var, v.hex)
				customCSS = customCSS:gsub("modspotify_rgb_" .. v.var, v.rgb)
			end
		else
			customCSS = ''
			print('user.css is not found in @Resource folder. Please make one.')
		end
	end
	ModSpa()
end

function ModSpa()
	nC = nC + 1
	if nC > totalSpa then
		glue = nil
		status = "Mod succeeded"
		SKIN:Bang('"#@#AutoRestart.exe"')
		return
	end
	SKIN:Bang('!SetOption', 'FileName', 'Index', nC)
	SKIN:Bang('!UpdateMeasure', 'FileName')
	n = fileName:GetStringValue()
	status = 'Updating '.. n
	curSpa = nC
	if theme then
		SKIN:Bang('!SetOption', 'Replicate', 'Parameter', 'robocopy "Extracted\\' .. n:gsub('%.', '_') .. '\\themed" "Decomp\\css"')
	else
		SKIN:Bang('!SetOption', 'Replicate', 'Parameter', 'robocopy "Extracted\\' .. n:gsub('%.', '_') .. '\\raw" "Decomp\\css"')
	end
	SKIN:Bang('!UpdateMeasure', 'Replicate')
	SKIN:Bang('!CommandMeasure', 'Replicate', 'Run')
end

function Zip()
	SKIN:Bang('!SetOption', 'Zip', 'Parameter', 'u -bb0 -mx0 "%appdata%\\Spotify\\Apps\\' .. n .. '" "*.css" -r')
	SKIN:Bang('!UpdateMeasure', 'Zip')
	SKIN:Bang('!CommandMeasure', 'Zip', 'Run')
end

function StartCSS()
	c2 = 1
	SKIN:Bang('!CommandMeasure', 'CSSFileView', 'Update')
end


function ModCSS()
	SKIN:Bang('!SetOption', 'CSSFileName', 'Index', c2)
	SKIN:Bang('!UpdateMeasure', 'CSSFileName')
	n2 = cssName:GetStringValue()
	if not n2 or n2 == '' then
		Zip()
		return
	end

	local d = ''

	if glue and n2:match("glue%.css$") then
		d = glue
	else
		local f = io.open(n2, 'r')
		d = f:read("*a")
		f:close()

		-- Replace keywords that we prepared when backing up and unzipping
		-- with actual color hex or rgb value
		if theme then
			for k, v in ipairs(color) do
				d = d:gsub("modspotify_" .. v.var, v.hex)
				d = d:gsub("modspotify_rgb_" .. v.var, v.rgb)
			end
		end

		if hideAds then
			d = table.concat({d,
				"#hpto-container {\ndisplay: none !important}\n",
				"#concerts {\ndisplay: none !important}\n",
				".sponsored-credits {\ndisplay: none !important}\n",
				".billboard-ad {\ndisplay: none !important}\n",
				"#leaderboard-ad-wrapper {\ndisplay: none !important}\n"
			})
		end

		if injectCSS then
			d = table.concat({d, customCSS})
		end

		if not glue and n2:match("glue%.css$") then
			glue = d
		end
	end

	f = io.open(n2, 'w')
	f:write(d)
	f:close()

	c2 = c2 + 1

	ModCSS()
end

function parseColor(raw)
	local hex = ''
	--RRR,GGG,BBB
	if raw:find(',') then
		for c in raw:gmatch('%d+') do
			c = string.format("%x", c)
			hex = hex .. c
		end
	else
		hex = raw
	end
	local r = 6 - hex:len()
	--Less than 6 hex
	if r > 0 then
		for i = 1, r do
			hex = hex .. 'f'
		end
	-- More than 6 hex
	elseif r < 0 then
		while hex:len() ~= 6 do
			hex = hex:sub(1, -2)
		end
	end
	return hex
end

function hexToRGB(hex)
	local rgb = {}
	for h in hex:gmatch("..") do
		table.insert(rgb, tonumber(h, 16))
	end
	return table.concat(rgb, ',')
end

function NameToIndex(nameTable, name)
	for i = 1, #nameTable do
		if name == nameTable[i] then
			return i
		end
	end
	return nil
end

themeTable = {}
function UpdateTheme()
	local themeCount = SKIN:GetMeasure("ThemeFolderCount"):GetValue()
	if (themeCount == 0) then
		print('No theme found in Themes folder.')
		return
	end
	themeName = SKIN:GetMeasure("ThemeFolderName")

	for i = 1, themeCount do
		SKIN:Bang('!SetOption', 'ThemeFolderName', 'Index', i)
		SKIN:Bang('!UpdateMeasure', 'ThemeFolderName')
		table.insert(themeTable, themeName:GetStringValue())
	end

	currentThemeIndex = NameToIndex(themeTable, currentTheme)

	if not currentThemeIndex then
		--Fallback to first theme if cannot find current theme name in Themes folder.
		SKIN:Bang('!WriteKeyValue', 'Variables', 'CurrentTheme', themeTable[1])
		SKIN:Bang('!Refresh')
		return
	end

	if currentThemeIndex > 1 then
		SKIN:Bang('!ShowMeter', 'ThemeBack')
		SKIN:Bang('!HideMeter', 'ThemeBack_Disabled')
	end

	if (themeCount - currentThemeIndex) > 0 then
		SKIN:Bang('!ShowMeter', 'ThemeNext')
		SKIN:Bang('!HideMeter', 'ThemeNext_Disabled')
	end
end

function ThemeChange(dir)
	currentThemeIndex = currentThemeIndex + dir
	SKIN:Bang('!SetOption', 'ThemeFolderName', 'Index', currentThemeIndex)
	SKIN:Bang('!UpdateMeasure', 'ThemeFolderName')
	SKIN:Bang('!WriteKeyValue', 'Variables', 'CurrentTheme', themeName:GetStringValue())
	SKIN:Bang('!Refresh')
end

function ThemeNew()
	local name = "New_Theme"
	local n = 1
	while NameToIndex(themeTable, name) do
		n = n + 1
		name = "New_Theme_" .. n
	end
	newThemeFolder = SKIN:ReplaceVariables('#ROOTCONFIGPATH#Themes\\' .. name)
	SKIN:Bang('!WriteKeyValue', 'Variables', 'CurrentTheme', name)
	SKIN:Bang('!SetOption', 'ThemeRunCommand', 'Parameter', 'mkdir "' .. newThemeFolder .. '"')
	SKIN:Bang('!SetOption', 'ThemeRunCommand', 'FinishAction', '!CommandMeasure Script "ThemeNewContent()"')
	SKIN:Bang('!UpdateMeasure', 'ThemeRunCommand')
	SKIN:Bang('!CommandMeasure', 'ThemeRunCommand', 'Run')
end

function ThemeNewContent()
	local file = io.open(newThemeFolder .. '\\color.inc', 'w+')
	file:write(
		'[Variables]\n',
		'Main_FG = 8a4fff\n',
		'Secondary_FG = 8a4fff\n',
		'Main_BG = 8a4fff\n',
		'Sidebar_And_Player_BG = 8a4fff\n',
		'Cover_Overlay_And_Shadow = 8a4fff\n',
		'Indicator_FG_And_Button_BG = 8a4fff\n',
		'Pressing_FG = 8a4fff\n',
		'Slider_BG = 8a4fff\n',
		'Sidebar_Indicator_And_Hover_Button_BG = 8a4fff\n',
		'Scrollbar_FG_And_Selected_Row_BG = 8a4fff\n',
		'Pressing_Button_FG = 8a4fff\n',
		'Pressing_Button_BG = 8a4fff\n',
		'Selected_Button = 8a4fff\n',
		'Miscellaneous_BG = 8a4fff\n',
		'Miscellaneous_Hover_BG = 8a4fff\n',
		'Preserve_1 = 8a4fff'
	)
	file:close()

	file = io.open(newThemeFolder .. '\\user.css', 'w+')
	file:write()
	file:close()
	SKIN:Bang('!Refresh')
end

function ThemeDuplicate()
	local name = currentTheme .. '_2'
	local n = 2
	while NameToIndex(themeTable, name) do
		n = n + 1
		name = currentTheme .. '_' .. n
	end
	SKIN:Bang('!SetOption', 'ThemeRunCommand', 'Parameter', table.concat(
		{'robocopy "', currentTheme, '" "', name, '"'}
	))
	SKIN:Bang('!SetOption', 'ThemeRunCommand', 'FinishAction', '[!WriteKeyValue Variables CurrentTheme "' .. name .. '"][!Refresh]')
	SKIN:Bang('!UpdateMeasure', 'ThemeRunCommand')
	SKIN:Bang('!CommandMeasure', 'ThemeRunCommand', 'Run')
end