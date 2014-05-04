if myHero.charName ~= "TwistedFate" then return end
--[[       ----------------------------------------------------------------------------------------------       ]]--
--[[									TwistedFate by Bilbao		    					   	 	        ]]--
--[[       ----------------------------------------------------------------------------------------------       ]]--


            _G.prodic = false
            _G.prodicfile = false           
            _G.vpredicfile = false      
            _G.vpredic = false           
            _G.freevippredic = false
			_G.freevippredicfile = false           
			_G.freepredic = false
            _G.freepredicfile = true          
     
           
            if VIP_USER then
                    if FileExist(SCRIPT_PATH..'Common/Prodiction.lua') then --prodiction
                            require "Prodiction"
							require "Collision"
                            prodicfile = true
                            prodic = true          
                    end
                    if FileExist(SCRIPT_PATH..'Common/VPrediction.lua') then --vprediction
                            require "VPrediction"
                            vpredic = true
                            vpredicfile = true
                    else                           
                            freevippredicfile = true --vipprediction
                    end            
            else
                    freepredicfile = true --freeprediction         
            end  


	-------Skills info-------
	local projSpeed = 1.2
	local Qrange, Qwidth, Qspeed, Qdelay = 1450, 40, 1000, 0.25
	
	local QReady, WReady, EReady, RReady = false, false, false, false
	local canQhrs, canWhrs, canEhrs, canRhrs = false, false, false, false
	local canQrota, canWrota, canErota, canRrota = false, false, false, false
	local IGNReady, IGNSlot = false, nil
	local castW = false
	-------/Skills info-------
	
	
	-------Vprediction info-------
	local VP = nil
	local vpredhitQ = 0
	------/Vprediction info-------
	
	
	-------Orbwalk & Farm info-------
	local lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0
	local myTrueRange = 0
	local orb_SELF, orb_MMA, orb_SAC = false, false, false
	-------/Orbwalk & Farm info-------
	
	
	-------MMA & SAC info-------
	local starttick = 0
	local checkedMMASAC = false
	local is_MMA = false
	local is_SAC = false
	-------/MMA & SAC info-------
	
	
	-------Target info-------
	local ts = nil
	local Target, currTargetPos = nil, nil
	local predQPos, predRQPos, preenemy = nil, nil, nil
	-------/Target info-------
	
	
	-------Autolvl info-------
	local abilitylvl = 0
	local lvlsequence = 1 
	-------/Autolvl info-------
	
	
	-------Auto update-------
	local CurVer = 0.1
	local CurName = "BilbaoTwistedFate"
	local NeedUpdate = false
	local updated = true	
	-------/Auto update-------
	
	
	
--[[       ----------------------------------------------------------------------------------------------       ]]--
--[[													Callbacks												]]--
--[[       ----------------------------------------------------------------------------------------------       ]]--	


function OnLoad()	
	starttick = GetTickCount()
	_loadP()
	_load_menu()
	_initiateTS()	
	PrintChat("<font color='#40FF00'> >> "..CurName.." v."..CurVer.." - loaded</font>")
end


function OnUnLoad()


end


function OnTick()
	_check_mmasac()
	if not myHero.dead then
		_update()
		_OrbWalk()
		_smartcore()
	end
end


function OnDraw()
	if myHero.dead then return end
	_draw_ranges()
	_draw_tarinfo()	
end


function OnProcessSpell(object, spell)
	if object == myHero then
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency()/2
			lastWindUpTime = spell.windUpTime*1000
			lastAttackCD = spell.animationTime*1000
		end 
	end
end
				--Menu.specl:addParam("card", "Force special card", SCRIPT_PARAM_ONOFF, false)
				--Menu.specl:addParam("scard", "special card", SCRIPT_PARAM_LIST, 3, { "BLUE", "RED", "GOLD"})

function OnRecvPacket(p)
	if p.header == 0x17 and Menu.specl.card and castW then
		p.pos = 1
		local NId = p:DecodeF()
		if NId == myHero.networkID then
			p.pos = 7
			local b = p:Decode1()
			if b == 0x52 and Menu.specl.scard == 2 then
				Packet('S_CAST', {spellId=_W}):send()				
			elseif b == 0x47 and Menu.specl.scard == 3 then
				Packet('S_CAST', {spellId=_W}):send()				
			elseif b == 0x42 and Menu.specl.scard == 1 then
				Packet('S_CAST', {spellId=_W}):send()				
			end
			
		
		end
	end
end


function OnSendPacket()


end


--[[       ----------------------------------------------------------------------------------------------       ]]--
--[[					     	 		    	    Core Functions		 	  	   								]]--
--[[       ----------------------------------------------------------------------------------------------       ]]--


function _smartcore()	
		if (Menu.keys.permrota or Menu.keys.okdrota) then
			if Menu.rota.useW and canWrota then
				cast_pred_W()	
			end
			
			if Menu.rota.useQ and canQrota then			
				cast_pred_Q()
			end
		end
		if (Menu.keys.permhrs or Menu.keys.okdhrs) then	
			if Menu.rota.useW and canWhrs then
				cast_pred_W()	
			end	
			if Menu.rota.useQ and canQhrs then
				cast_pred_Q()
			end	
		end	
end

function cast_pred_W()
--if castW then print("ISCASTW") else print("isNOTcastw") end
if Target~=nil and ValidTarget(Target) and GetDistance(Target) < Qrange*0.75 and not castW then
	if VIP_USER then
		CastSpell(_W)
		castW = true
	else
		CastSpell(_W)
		CastSpell(_W)
	end
end
end

function cast_pred_Q()
local pred_Q_pos = nil
local qenemy = nil
--[[
regular target = Target
Menu.specl.forcestun 1=never 2=combo 3=always

]]
	if Menu.ta.co == 1 then	 --FREEPrediction
		if Target ~=nil and Target.visible and GetDistance(Target) < Qrange then
			local Position = FreePredictionQ:GetPrediction(Target)
			if Position ~= nil then
				pred_Q_pos = Position
				qenemy = Target
			end		
		end	
	end	 --//FREEPrediction

	
	if Menu.ta.co == 2 and VIP_USER then --VIPPrediction
		if Target ~=nil and Target.visible and GetDistance(Target) < Qrange then
			local Position = VipPredictionQ:GetPrediction(Target)
			if Position ~= nil then
				pred_Q_pos = Position
				qenemy = Target
			end		
		end	
	end	--//VIPPrediction

	
	if Menu.ta.co == 3 and vpredicfile then --VPrediction 	
			if ValidTarget(Target) and not Target.dead and Target.visible and GetDistance(Target) < Qrange then
				local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, Qdelay, Qwidth, Qrange, Qspeed, myHero, false)
				if HitChance >= Menu.ta.vpredhit and Target.visible and GetDistance(CastPosition) < Qrange then
					if CastPosition ~= nil then
						pred_Q_pos = CastPosition 
						qenemy = Target
					end
				end	
			end	
	end--//VPrediction

	
	if Menu.ta.co == 4 and prodicfile then --prOdiction
	
	end--//prOdiction	
		
--isburning(target)
--Menu.specl.forcestun never combo always
	if pred_Q_pos ~= nil and QReady then			
		_castSpell(_Q, pred_Q_pos.x, pred_Q_pos.z, nil)	
	end			

end




--[[       ----------------------------------------------------------------------------------------------       ]]--
--[[					     	 		    	    General				 	  	   								]]--
--[[       ----------------------------------------------------------------------------------------------       ]]--


function _OrbWalk()
	if not (Menu.ta.orb == 1 or Menu.ta.orb == 2) then return end
	if Menu.ta.orb == 1 then
		if not (Menu.keys.permrota or Menu.keys.okdrota or Menu.keys.permhrs or Menu.keys.okdhrs) then return end
	end
	
		if Target ~=nil and GetDistance(Target) <= myTrueRange then		
			if timeToShoot() then
				myHero:Attack(Target)
			elseif heroCanMove()  then
				moveToCursor()
			end
		else		
			moveToCursor() 
		end
end


function _update()
	ts:update()
	QReady = (myHero:CanUseSpell(_Q) == READY)
    WReady = (myHero:CanUseSpell(_W) == READY)
    EReady = (myHero:CanUseSpell(_E) == READY)
    RReady = (myHero:CanUseSpell(_R) == READY)
	myTrueRange = myHero.range + (GetDistance(myHero.minBBox) - 5)
	Target = _getTarget()
	_autoskill()
	_checkcancastHRS()
	_checkcancastROTA()
	if not QReady then castW = false end
end


function _autoskill()
	if not Menu.extra.alvl.alvlstatus then return end	
	if myHero.level > abilitylvl then
		abilitylvl = abilitylvl + 1
		if Menu.extra.alvl.lvlseq == 1 then			
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_W)
			LevelSpell(_E)
		end
		if Menu.extra.alvl.lvlseq == 2 then	
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_E)
			LevelSpell(_W)
		end
		if Menu.extra.alvl.lvlseq == 3 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_Q)
			LevelSpell(_E)
		end
		if Menu.extra.alvl.lvlseq == 4 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_E)
			LevelSpell(_Q)
		end
		if Menu.extra.alvl.lvlseq == 5 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_Q)
			LevelSpell(_W)
		end
		if Menu.extra.alvl.lvlseq == 6 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_W)
			LevelSpell(_Q)
		end
	end
end


--[[       ----------------------------------------------------------------------------------------------       ]]--
--[[					     	 		    	    Utility				 	  	   								]]--
--[[       ----------------------------------------------------------------------------------------------       ]]--
--canQ, canW, canE, canR
function _checkcancastHRS()	
	if Menu.manamenu.manahrs.manaq then 
		if mynamaislowerthen(Menu.manamenu.manahrs.sliderq) then
			canQhrs = false
		else			
			canQhrs = true
		end
	else
		canQhrs = true	
	end
	if Menu.manamenu.manahrs.manaw then 
		if mynamaislowerthen(Menu.manamenu.manahrs.sliderw) then
			canWhrs = false
		else			
			canWhrs = true
		end
	else
		canWhrs = true	
	end	
	if Menu.manamenu.manahrs.manae then 
		if mynamaislowerthen(Menu.manamenu.manahrs.slidere) then
			canEhrs = false
		else			
			canEhrs = true
		end
	else
		canEhrs = true	
	end		
	if Menu.manamenu.manahrs.manar then 
		if mynamaislowerthen(Menu.manamenu.manahrs.sliderr) then
			canRhrs = false
		else			
			canRhrs = true
		end
	else
		canRhrs = true	
	end	
end
--		Menu.manamenu.manarota:addParam("manae", "E ManaManager", SCRIPT_PARAM_ONOFF, true)
function _checkcancastROTA()	
	if Menu.manamenu.manarota.manaq then 
		if mynamaislowerthen(Menu.manamenu.manarota.sliderq) then
			canQrota = false
		else			
			canQrota = true
		end
	else
		canQrota = true	
	end
	if Menu.manamenu.manarota.manaw then 
		if mynamaislowerthen(Menu.manamenu.manarota.sliderw) then
			canWrota = false
		else			
			canWrota = true
		end
	else
		canWrota = true	
	end	
	if Menu.manamenu.manarota.manae then 
		if mynamaislowerthen(Menu.manamenu.manarota.slidere) then
			canErota = false
		else			
			canErota = true
		end
	else
		canErota = true	
	end		
	if Menu.manamenu.manarota.manar then 
		if mynamaislowerthen(Menu.manamenu.manarota.sliderr) then
			canRrota = false
		else			
			canRrota = true
		end
	else
		canRrota = true	
	end	
end

function mynamaislowerthen(percent)
    if myHero.mana < (myHero.maxMana * ( percent / 100)) then
        return true
    else
        return false
    end
end


function _getTarget()
	if not checkedMMASAC then return end
	if is_MMA and is_SAC then
		if Menu.ta.mma.mmastatus then
			Menu.ta.sac.sacstatus = false
			Menu.ta.basic.basicstatus = false
		elseif Menu.ta.sac.sacstatus then
			Menu.ta.mma.mmastatus = false
			Menu.ta.basic.basicstatus = false
		elseif	Menu.ta.basic.basicstatus then
			Menu.ta.mma.mmastatus = false
			Menu.ta.sac.sacstatus = false
		end
	end	
	if not is_MMA and is_SAC then
		if Menu.ta.sac.sacstatus then
			Menu.ta.basic.basicstatus = false
		else
			Menu.ta.basic.basicstatus = true
		end	
	end
	if is_MMA and not is_SAC then
		if Menu.ta.mma.mmastatus then
			Menu.ta.basic.basicstatus = false
		else
			Menu.ta.basic.basicstatus = true
		end	
	end
	if not is_MMA and not is_SAC then
		Menu.ta.basic.basicstatus = true	
	end	
	if _G.MMA_Target and _G.MMA_Target.type == myHero.type then
		return _G.MMA_Target 
	end
    if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then
		return _G.AutoCarry.Attack_Crosshair.target		
	end
    return ts.target	
end


function heroCanMove()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
end 
 
 
function timeToShoot()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
end 
 
 
function moveToCursor()
	if GetDistance(mousePos) > 1 or lastAnimation == "Idle1" then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized() * 500
		if Menu.extra.packetmove then
			Packet('S_MOVE', { type = 2, x = moveToPos.x, y = moveToPos.z }):send()
		else			
			myHero:MoveTo(moveToPos.x, moveToPos.z)
		end
	end 
end	


function _draw_ranges()
	if Menu.draw.drawsub2.drawaa then
		DrawCircle(myHero.x, myHero.y, myHero.z, 525, ARGB(25 , 125, 125, 125))
	end
	if Menu.draw.drawsub2.drawQ and QReady then			
			DrawCircle(myHero.x, myHero.y, myHero.z, Qrange, ARGB(100, 0, 0, 250))	
	end
end


function _draw_tarinfo()--reconfig for champ
	if Target~=nil and ValidTarget(Target, 2000) then	
		if Menu.draw.prdraw.enemyline then		
			DrawLine3D(myHero.x, myHero.y, myHero.z, Target.x, Target.y, Target.z, 1, ARGB(250,235,33,33))
		end	
		if Menu.draw.prdraw.enemy then
			DrawCircle(Target.x, Target.y, Target.z, 100, ARGB(250, 253, 33, 33))
		end
	end
	--[[
	if Menu.draw.prdraw.preQ and predQPos~=nil and ValidTarget(preenemy)  then
		DrawCircle(predQPos.x, predQPos.y, predQPos.z, 70, ARGB(100, 0, 0, 250))
		DrawCircle(predQPos.x, predQPos.y, predQPos.z, 73, ARGB(100, 0, 0, 250))
		DrawCircle(predQPos.x, predQPos.y, predQPos.z, 75, ARGB(100, 0, 0, 250))
	end
	if Menu.draw.prdraw.preQR and predQPos~=nil and ValidTarget(preenemy) then
		DrawCircle(predQPos.x, predQPos.y, predQPos.z, 245, ARGB(100, 0, 0, 250))
		DrawCircle(predQPos.x, predQPos.y, predQPos.z, 248, ARGB(100, 0, 0, 250))
		DrawCircle(predQPos.x, predQPos.y, predQPos.z, 250, ARGB(100, 0, 0, 250))
	end
	if Menu.draw.prdraw.preMOVE and predQPos~=nil and ValidTarget(preenemy) then
		DrawLine3D(predQPos.x, predQPos.y, predQPos.z, preenemy.x,preenemy.y, preenemy.z, 15, ARGB(100, 0, 0, 250))			
	end	
	]]
end


function _drawpreddmg()--reconfig for champ
	if not Menu.draw.prdraw.predmg then return end	
	local currLine = 1
	for i, enemy in ipairs(GetEnemyHeroes()) do	
		--local enemy= GetMyHero()
		if enemy~=nil and ValidTarget(enemy, 2500) then				
				if QReady and not RReady then
					DrawLineHPBar(dmgQ(enemy), currLine, "Q: "..dmgQ(enemy), enemy)
					currLine = currLine + 1
				end			
			--EnemyDummy
			---	DrawLineHPBar(0, 10, "TEST ZERO ", enemy) --dummy for calibration 
			---	DrawLineHPBar(myHero.maxHealth*0.5, 11, "TEST 50% ", enemy) --dummy for calibration
			---	DrawLineHPBar(myHero.maxHealth, 12, "TEST 100% ", enemy) --dummy for calibration
			
			--SelfDummy - SelfOffsets=/=EnemyOffsets
			--DrawLineHPBar(0, 10, "TEST ZERO ", GetMyHero()) --dummy for calibration 
			--DrawLineHPBar(myHero.maxHealth*0.5, 11, "TEST 50% ", GetMyHero()) --dummy for calibration
			--DrawLineHPBar(myHero.maxHealth, 12, "TEST 100% ", GetMyHero()) --dummy for calibration
			end
		end		
end


function dmgQ(target) --reconfig for champ
    local myQDmg = getDmg("Q", target, myHero, 1)
    return math.round(myQDmg)
end


function dmgRQSAVE(target)--reconfig for champ
    local myRQDmg = getDmg("Q", target, myHero, 1)
	local myRQDmgD = getDmg("Q", target, myHero, 2)
    return math.round(myRQDmg+myRQDmgD)
end


function dmgRQRISK(target)--reconfig for champ
    local myRQDmg = getDmg("Q", target, myHero, 1)
	local myRQDmgD = getDmg("Q", target, myHero, 2)
	local myRQDmgDE = getDmg("Q", target, myHero, 3)
    return math.round(myRQDmg+myRQDmgD+myRQDmgDE)
end


function dmgW(target)--reconfig for champ
    local myWDmg = getDmg("W", target, myHero)
    return math.round(myWDmg)
end


function dmgRW(target)--reconfig for champ
	local myRWDmgE = getDmg("W", target, myHero, 1)
    local myRWDmg = getDmg("W", target, myHero, 2)
    return math.round(myRWDmg+myRWDmgE)
end


function dmgAA(target)--reconfig for champ
	local ADDmg = getDmg("AD", target, myHero)
	return math.round(ADDmg)
end


function dmgIGN(target)--reconfig for champ
	local IGNDmg = getDmg("IGNITE", target, myHero)
	return math.round(IGNDmg)
end


function GetHPBarPos(enemy) --DONE
	enemy.barData = GetEnemyBarData()
	local barPos = GetUnitHPBarPos(enemy)
	local barPosOffset = GetUnitHPBarOffset(enemy)
	local barOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
	local barPosPercentageOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
	local BarPosOffsetX = 171
	local BarPosOffsetY = 46
	local CorrectionY =  0
	local StartHpPos = 31
	barPos.x = barPos.x + (barPosOffset.x - 0.3225 + barPosPercentageOffset.x) * BarPosOffsetX + StartHpPos
	barPos.y = barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * BarPosOffsetY + CorrectionY 						
	local StartPos = Vector(barPos.x , barPos.y, 0)
	local EndPos =  Vector(barPos.x + 108 , barPos.y , 0)
	return Vector(StartPos.x, StartPos.y, 0), Vector(EndPos.x, EndPos.y, 0)
end


function DrawLineHPBar(damage, line, text, unit) --DONE
	local thedmg = 0
	if damage >= unit.maxHealth then
		thedmg = unit.maxHealth-1
	else
		thedmg=damage
	end
	local StartPos, EndPos = GetHPBarPos(unit)
	local Real_X = StartPos.x+24
	local Offs_X = (Real_X + ((unit.health-thedmg)/unit.maxHealth) * (EndPos.x - StartPos.x - 2))
	if Offs_X < Real_X then Offs_X = Real_X end	
	local mytrans = 350 - math.round(255*((unit.health-thedmg)/unit.maxHealth)) ---   255 * 0.5
	if mytrans >= 255 then mytrans=254 end
	local my_bluepart = math.round(400*((unit.health-thedmg)/unit.maxHealth))
	if my_bluepart >= 255 then my_bluepart=254 end
	--math.round(255*((unit.health-damage)/unit.maxHealth))
	--math.round(NUMBER)
	--ARGB(255,7,255,7)
	DrawLine(Offs_X-150, StartPos.y-(30+(line*15)), Offs_X-150, StartPos.y-2, 2, ARGB(mytrans, 255,my_bluepart,0))
	DrawText(tostring(text),15,Offs_X-148,StartPos.y-(30+(line*15)),ARGB(mytrans, 255,my_bluepart,0))  --ARGB(mytrans, 255,255,255)
end

--Menu.extra.ex:addParam("packetcast", "Casting", SCRIPT_PARAM_LIST, 1, { "Regular", "NoFace(P)", "Packets" })
function _castSpell(TSPELL, TSPELLX, TSPELLZ, TUNIT) --DONE
	if TUNIT~=nil and TSPELLX==nil and TSPELLZ==nil and ValidTarget(TUNIT) then --targetted
		if Menu.extra.ex.packetcast == 1 and TSPELL~=_R then	
			CastSpell(TSPELL, TUNIT)
		end
		if (Menu.extra.ex.packetcast == 2 or Menu.extra.ex.packetcast == 3) then
			_CastSpellOverPacket(TSPELL, nil, nil, TUNIT)
		end
	end
	if TUNIT==nil and TSPELLX~=nil and TSPELLZ~=nil then --skillshot
		if Menu.extra.ex.packetcast == 1 then
			CastSpell(TSPELL, TSPELLX, TSPELLZ)
		end
		if (Menu.extra.ex.packetcast == 2 or Menu.extra.ex.packetcast == 3) then
			_CastSpellOverPacket(TSPELL, TSPELLX, TSPELLZ, nil)
		end
	end
end


--[[
	_CastSpellOverPacket(_Q, PosX, PosZ, nil) --skillshot
	_CastSpellOverPacket(_Q, nil, nil, CUnit) --targeted
]]
function _CastSpellOverPacket(mySpell, PosX, PosZ, CUnit) --DONE
local tnid, tposX, tposZ = nil, nil, nil
local cansend = false
	if PosX ~= nil and PosZ ~= nil then
		tposX = PosX
		tposZ = PosZ
		cansend = true
	else
		if CUnit ~= nil then
			tposX = CUnit.x
			tposZ = CUnit.z
			tnid  = CUnit.networkID
			cansend = true
		else			
			cansend = false
		end
	end
	if cansend then
		local CSOpacket = CLoLPacket(153)
		CSOpacket.dwArg1 = 1
		CSOpacket.dwArg2 = 0
		CSOpacket:EncodeF(myHero.networkID)
		CSOpacket:Encode1(mySpell)
		CSOpacket:EncodeF(tposX)
		CSOpacket:EncodeF(tposZ)
		CSOpacket:EncodeF(tposX)
		CSOpacket:EncodeF(tposZ)
		if tnid~=nil then
			CSOpacket:EncodeF(tnid)
		else
			CSOpacket:EncodeF(0)
		end
		SendPacket(CSOpacket)
	end
	if not cansend then print("<font color='#F72828'>[CSOP][ERROR]Invalid Operator</font>") end
end


--[[       ----------------------------------------------------------------------------------------------       ]]--
--[[					     	 		    	    Once loaded			 	  	   								]]--
--[[       ----------------------------------------------------------------------------------------------       ]]--


function _check_mmasac() --DONE
	if checkedMMASAC then return end
	if not (starttick + 5000 < GetTickCount()) then return end
	checkedMMASAC = true
    if _G.MMA_Loaded then
     	print(' >> MMA found. MMA support loaded.')
		is_MMA = true
	else
		print(' >>'..CurName..': MMA not found')
	end	
	if _G.AutoCarry then
		print(' >>'..CurName..': SAC found. SAC support loaded.')
		is_SAC = true
	else
		print(' >>'..CurName..': SAC not found.')
	end	
	if is_MMA then
		Menu.ta:addSubMenu("Marksman's Mighty Assistant", "mma")
		Menu.ta.mma:addParam("mmastatus", "Use MMA", SCRIPT_PARAM_ONOFF, false)				
	end
	if is_SAC then
		Menu.ta:addSubMenu("Sida's Auto Carry", "sac")
		Menu.ta.sac:addParam("sacstatus", "Use SAC", SCRIPT_PARAM_ONOFF, false)
	end
	if VIP_USER then
		if prodicfile and not vpredicfile then
			print(' >>'..CurName..': VipPrediction and Prodiction loaded.')
		end
		if prodicfile and vpredicfile then
			print(' >>'..CurName..': VipPrediction, Prodiction and VPrediction loaded.')
		end
	else
		print(' >>'..CurName..': FreeUser Prediction loaded.')
	end
	if VIP_USER then
		print(' >>'..CurName..': VIP Menu loaded.')
	else
		print(' >>'..CurName..': FreeUser Menu loaded.')
	end	 
end


--[[ SAC
	AutoCarry.Orbwalker = nil
	AutoCarry.SkillsCrosshair = nil
	AutoCarry.CanMove = true
	AutoCarry.CanAttack = true
	AutoCarry.MainMenu = nil
	AutoCarry.PluginMenu = nil
	AutoCarry.EnemyTable = nil
	AutoCarry.shotFired = false
	AutoCarry.OverrideCustomChampionSupport = false
	AutoCarry.CurrentlyShooting = false
]]
--[[ MMA
    _G.MMA_Loaded // Boolean
    _G.MMA_AttackAvailable //Boolean
    _G.MMA_AbleToMove //Boolean
    _G.MMA_NextAttackAvailability // from 0 to 1, percentage of next attack
    _G.MMA_ForceTarget // Unit object, with this you can force MMA target selector to select a different target, for ex.: AllClass TS target
    _G.MMA_Target //Currently selected target (unit object)
    _G.MMA_Orbwalker, _G.MMA_HybridMode, _G.MMA_LaneClear, _G.MMA_LastHit //Boolean, indicates what mode is active.
    _G.MMA_ConsideredTarget(range) //function, returns MMA considered target(unit) from custom range.
    _G.MMA_ResetAutoAttack() //function, forces MMA to think that your attack is available.
]]


function _load_menu()
	Menu = scriptConfig(""..CurName, "bilbao")   --RECONFIGER FOR CHAMP	
		-----------------------------------------------------------------------------------------------------
		Menu:addSubMenu("Drawing", "draw")
			Menu.draw:addSubMenu("Prediction&Co", "prdraw")
				Menu.draw.prdraw:addParam("enemy", "Mark Enemy", SCRIPT_PARAM_ONOFF, true)
				Menu.draw.prdraw:addParam("enemyline", "Line2Enemy", SCRIPT_PARAM_ONOFF, true)
				--Menu.draw.prdraw:addParam("predmg", "Draw Predicted Dmg", SCRIPT_PARAM_ONOFF, true)
				--Menu.draw.prdraw:addParam("preQ", "Draw Predicted Q-Pos", SCRIPT_PARAM_ONOFF, true)--RECONFIGER FOR CHAMP
				--Menu.draw.prdraw:addParam("preQR", "Draw Predicted QR-Pos", SCRIPT_PARAM_ONOFF, true)--RECONFIGER FOR CHAMP
				--Menu.draw.prdraw:addParam("preMOVE", "Draw Predicted Move", SCRIPT_PARAM_ONOFF, true)				
		-----------------------------------------------------------------------------------------------------

		-----------------------------------------------------------------------------------------------------
			Menu.draw:addSubMenu("Ranges", "drawsub2") --DONE
				Menu.draw.drawsub2:addParam("drawaa", "Draw AARange", SCRIPT_PARAM_ONOFF, true)
				Menu.draw.drawsub2:addParam("drawQ", "Draw QRange", SCRIPT_PARAM_ONOFF, true)

		-----------------------------------------------------------------------------------------------------
		
		
		-----------------------------------------------------------------------------------------------------
		Menu:addSubMenu("Harrass", "harrass")			--RECONFIGER FOR CHAMP
			Menu.harrass:addParam("autohrsQ", "Auto Use Q", SCRIPT_PARAM_ONOFF, true)
			Menu.harrass:addParam("autohrsW", "Auto Use W", SCRIPT_PARAM_ONOFF, true)
		-----------------------------------------------------------------------------------------------------
		
		
		-----------------------------------------------------------------------------------------------------
		Menu:addSubMenu("Rotation", "rota")			
			Menu.rota:addParam("useQ", "Q Usage", SCRIPT_PARAM_ONOFF, true)
			Menu.rota:addParam("useW", "W Usage", SCRIPT_PARAM_ONOFF, true)
		-----------------------------------------------------------------------------------------------------
		
		Menu:addSubMenu("Mana Manager", "manamenu")
			Menu.manamenu:addSubMenu("Harrass", "manahrs")
				Menu.manamenu.manahrs:addParam("manaq", "Q ManaManager", SCRIPT_PARAM_ONOFF, true) 
				Menu.manamenu.manahrs:addParam("sliderq", "Use Q only if mana over %",  SCRIPT_PARAM_SLICE, 50, 0, 100, 0) 
				Menu.manamenu.manahrs:addParam("manaw", "W ManaManager", SCRIPT_PARAM_ONOFF, true)
				Menu.manamenu.manahrs:addParam("sliderw", "Use W only if mana over %",  SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
			Menu.manamenu:addSubMenu("Rotation", "manarota")
				Menu.manamenu.manarota:addParam("manaq", "Q ManaManager", SCRIPT_PARAM_ONOFF, true)
				Menu.manamenu.manarota:addParam("sliderq", "Use Q only if mana over %",  SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
				Menu.manamenu.manarota:addParam("manaw", "W ManaManager", SCRIPT_PARAM_ONOFF, true)
				Menu.manamenu.manarota:addParam("sliderw", "Use W only if mana over %",  SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		-----------------------------------------------------------------------------------------------------
		Menu:addSubMenu("Hotkeys", "keys")		
			Menu.keys:addParam("permrota", "Auto Rotation", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("S"))
			Menu.keys:permaShow("permrota")
			Menu.keys:addParam("okdrota", "OnKeyDown Rotation", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
			Menu.keys:permaShow("okdrota")		
			Menu.keys:addParam("permhrs", "Auto Harrass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("Z"))
			Menu.keys:permaShow("permhrs")
			Menu.keys:addParam("okdhrs", "OnKeyDown Harrass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
			Menu.keys:permaShow("okdhrs")
		-----------------------------------------------------------------------------------------------------
		
		
		-----------------------------------------------------------------------------------------------------
		Menu:addSubMenu("Target acquisition", "ta")	
			if not VIP_USER then
				Menu.ta:addParam("co", "Use", SCRIPT_PARAM_LIST, 1, {"FREEPrediction"})
			end
			if VIP_USER and not prodicfile and not vpredicfile then
				Menu.ta:addParam("co", "Use", SCRIPT_PARAM_LIST, 2, {"FREEPrediction", "VIPPrediction",  }) 
				Menu.ta.co = 2
			end
			if VIP_USER and not prodicfile and vpredicfile then
				Menu.ta:addParam("co", "Use", SCRIPT_PARAM_LIST, 3, {"FREEPrediction","VIPPrediction", "VPrediction" }) 
				Menu.ta.co = 3 
				Menu.ta:addParam("vpredhit", "Vpred Hitchance",  SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
			end
			
			if VIP_USER and prodicfile and vpredicfile then 
				Menu.ta:addParam("co", "Use", SCRIPT_PARAM_LIST, 4, {"FREEPrediction","VIPPrediction","VPrediction","Prodiction"})  
				Menu.ta.co = 4 
				Menu.ta:addParam("vpredhit", "Vpred Hitchance",  SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
			end		
			
			
				Menu.ta:addSubMenu("Basic", "basic")
					Menu.ta.basic:addParam("basicstatus", "Use BasicTS&Orbwalk", SCRIPT_PARAM_ONOFF, false)
					
				Menu.ta:addParam("orb", "Orbwalk", SCRIPT_PARAM_LIST, 1, { "COMBO", "ALWAYS", "NEVER" })				
		-----------------------------------------------------------------------------------------------------


		-----------------------------------------------------------------------------------------------------
		Menu:addSubMenu("Extra", "extra")
			Menu.extra:addSubMenu("Extended", "ex")
				if VIP_USER then
					Menu.extra.ex:addParam("packetcast", "Casting", SCRIPT_PARAM_LIST, 1, { "Regular", "NoFace(P)", "Packets" })
				else
					Menu.extra.ex:addParam("packetcast", "Casting", SCRIPT_PARAM_LIST, 1, {"Regular"})
				end
				if VIP_USER then
					Menu.extra.ex:addParam("packetmove", "Movement", SCRIPT_PARAM_LIST, 1, { "Regular", "Packets" })
				else
					Menu.extra.ex:addParam("packetmove", "Movement", SCRIPT_PARAM_LIST, 1, { "Regular"})
				end
			Menu.extra:addSubMenu("Auto level", "alvl")
				Menu.extra.alvl:addParam("alvlstatus", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
				Menu.extra.alvl:addParam("lvlseq", "Choose your lvl Sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
				
				
			Menu:addSubMenu("Special", "specl")
				Menu.specl:addParam("card", "Force special card", SCRIPT_PARAM_ONOFF, false)
				Menu.specl:addParam("scard", "special card", SCRIPT_PARAM_LIST, 3, { "BLUE", "RED", "GOLD"})
				
		-----------------------------------------------------------------------------------------------------
		Menu:addParam("info", " >> created by Bilbao", SCRIPT_PARAM_INFO, "")
		Menu:addParam("info2", " >> Version "..CurVer, SCRIPT_PARAM_INFO, "")
		
		_setimpdef()
end


function _initiateTS()
	ts = TargetSelector(TARGET_PRIORITY, 525) --Rrange
	ts.name = ""..myHero.charName
	Menu.ta.basic:addTS(ts)
end


function _setimpdef()
	Menu.extra.alvl.alvlstatus = false
	Menu.keys.permrota = false
	Menu.keys.okdrota = false
	Menu.keys.permhrs = false
	Menu.keys.okdhrs = false
end
	

function _loadP()

	if prodicfile then --initiate paidprOdiction
		--require "Prodiction"		--not needed anymore
		Prodiction = ProdictManager.GetInstance()
		ProdictionQ = Prodiction:AddProdictionObject(_Q, Qrange, Qspeed, Qdelay, Qwidth)
		--ProdictionW = Prodiction:AddProdictionObject(_Q, Qrange, Qspeed, Qdelay, Qwidth)
		--ProdictionE = Prodiction:AddProdictionObject(_Q, Qrange, Qspeed, Qdelay, Qwidth)
		--ProdictionR = Prodiction:AddProdictionObject(_Q, Qrange, Qspeed, Qdelay, Qwidth)
		
		--[[
		local collision = GetMinionCollision(pStart, pEnd)    coliision kann true or false sein
		GetHeroCollision(pStart, pEnd, mode)
		GetCollision(pStart, pEnd)
		DrawCollision(pStart, pEnd)
		]]
		
		--[[
			local coll = Collision(Qrange, Qspeed, Qdelay, Qwidth)
			if not coll:GetMinionCollision(predQPos, myHero) then
				keine collision
			end
		]]
		--[[
		collQ = Collision(Qrange, Qspeed, Qdelay, Qwidth)
		collW = Collision(Wrange, Wspeed, Wdelay, Wwidth)
		collE = Collision(Erange, Espeed, Edelay, Ewidth)
		collR = Collision(Rrange, Rspeed, Rdelay, Rwidth)
		]]
	end
	if vpredicfile then --initiate VPprediction
		--require "VPrediction"		
		VP = VPrediction()	
	end
	if VIP_USER then --initiate VIPPrediction
			VipPredictionQ = TargetPredictionVIP(Qrange, Qspeed, Qdelay, Qwidth, myHero)
			--VipPredictionW = TargetPredictionVIP(Wrange, Wspeed, Wdelay, Wwidth, myHero)
			--VipPredictionE = TargetPredictionVIP(Erange, Espeed, Edelay, Ewidth, myHero)
			--VipPredictionR = TargetPredictionVIP(Rrange, Rspeed, Rdelay, Rwidth, myHero)
	end
	-- --initiate FreePredition always cuz every can use it
		FreePredictionQ = TargetPrediction(Qrange, Qspeed, Qdelay, Qwidth)	
		--FreePredictionW = TargetPrediction(Wrange, Wspeed, Wdelay, Wwidth)
		--FreePredictionE = TargetPrediction(Erange, Espeed, Edelay, Ewidth)
		--FreePredictionR = TargetPrediction(Rrange, Rspeed, Rdelay, Rwidth)		
end	


	
	
	
