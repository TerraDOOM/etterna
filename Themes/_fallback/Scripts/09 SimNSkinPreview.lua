function LoadNSkinPreview(Noteskin, Button, Element, Player)
	if Noteskin == "Get" then
		local t = Def.ActorFrame{
			OnCommand=function(self)
				SCREENMAN:GetTopScreen():AddInputCallback(NSkinPreviewChange(self,Player))
			end;
		};
		for i, n in pairs(NOTESKIN:GetNoteSkinNames()) do
			t[#t+1] = Def.ActorFrame{
				Name="N"..i;
				InitCommand=function(self) 
					if n ~= GAMESTATE:GetPlayerState(Player):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin() then
						self:visible(false)
					end
					if Element == "Tap Note" then
						local TexY = NOTESKIN:GetMetricFForNoteSkin("NoteDisplay","TapNoteNoteColorTextureCoordSpacingY",n)
						local TexX = NOTESKIN:GetMetricFForNoteSkin("NoteDisplay","TapNoteAdditionTextureCoordOffsetX",n)
						if TexY > 0 then
							for _, i in pairs(SimChild(self,"Sprite")) do
								local ani = i:GetNumStates()
								local Skip = 1
								local TexY2 = (TexY*64)
								local StateF = {}
								if TexX == 0.5 then Skip = 2; TexY2 = (TexY*64)*2 end
								for timer = 1, TexY2,Skip do
									for frame = (ani*timer)-ani,(ani*timer)-1 do
										StateF[#StateF+1] = {Frame=frame, Delay=4/((TexY*64)*ani)}
									end
								end
								i:SetStateProperties(StateF)
							end
						end
					end
				end;
				NOTESKIN:LoadActorForNoteSkin(Button, Element, n);
			};
		end
		return t;
	else
		return NOTESKIN:LoadActorForNoteSkin(Button, Element, NOTESKIN:DoesNoteSkinExist(Noteskin) and Noteskin or "default");	
	end
end

function NSkinPreviewChange(Container,Player)
	return function(event)
		for i, n in pairs(NOTESKIN:GetNoteSkinNames()) do
			Container:GetChild("N"..i):visible(false)
		end
		for i = 1,SCREENMAN:GetTopScreen():GetNumRows()-1 do
			if SCREENMAN:GetTopScreen():GetOptionRow(i):GetName() == "NoteSkins" then
				local nSkin = Container:GetChild("N"..SCREENMAN:GetTopScreen():GetOptionRow(i):GetChoiceInRowWithFocus(Player)+1)
				nSkin:visible(true)
			end
		end
	end
end

function SimChild(Container, Type)
	local notable,Count
	local rType = {}
	local Child = {Container}
	repeat
		notable = true
		Count = Child
		Child = {}
		for no in pairs(Count) do
			if lua.CheckType("ActorFrame",Count[no]) then

				for _, cld in pairs(Count[no]:GetChildren()) do
					if lua.CheckType("ActorFrame",cld) then
						notable = false
						Child[#Child+1] = cld
					elseif lua.CheckType(Type,cld) then
						rType[#rType+1] = cld
					end
				end
			end
		end
	until notable == true
	return rType
end
