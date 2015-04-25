--[[
	国战技能速查手册（K区）
	技能索引：
	看破、克己、空城、苦肉、狂斧、狂骨    
]]--
--[[
	看破
	相关武将：标-卧龙诸葛亮
	描述：你可以将一张黑色手牌当【无懈可击】使用。    
	引用：
	状态：
]]

LuaKanpo = sgs.CreateOneCardViewAsSkill{
	name = "LuaKanpo",
	filter_pattern = ".|black|.|hand",
	response_pattern = "nullification",
	response_or_use = true,
	view_as = function(self, first)
		local ncard = sgs.Sanguosha:cloneCard("nullification", first:getSuit(), first:getNumber())
		ncard:addSubcard(first)
		ncard:setSkillName(self:objectName())
		ncard:setShowSkill(self:objectName())
		return ncard
	end,
	enabled_at_nullification = function(self, player)
		for _, card in sgs.qlist(player:getHandcards()) do
			if card:isBlack() then return true end
		end
		return false
	end,
}

--[[
	克己
	相关武将：标-吕蒙
	描述：若你未于出牌阶段内使用或打出【杀】，你可以跳过弃牌阶段。 
	引用：
	状态：
]]


LuaKejiRecord = sgs.CreateTriggerSkill{
	name = "#LuaKejiRecord",
	events = {sgs.PreCardUsed,sgs.CardResponded},
	frequency = sgs.Compulsory;
	
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return false end
		local card
		if event == sgs.PreCardUsed then
			card = data:toCardUse().card
		else
			card = data:toCardResponse().m_card
		end
		if card:isKindOf("Slash") and player:getPhase() == sgs.Player_Play then
			player:setFlags("KejiSlashInPlayPhase")
		end
	end,
}

LuaKeji = sgs.CreateTriggerSkill{
	name = "LuaKeji",
	events = {sgs.EventPhaseChanging},
	frequency = sgs.Skill_Frequent,

	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return false end
		local change = data:toPhaseChange()
		if not player:hasFlag("KejiSlashInPlayPhase") and change.to == sgs.Player_Discard then
			return self:objectName()
		end
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke(self:objectName()) then
			if player:getHandcardNum() > player:getMaxCards() then
				room:broadcastSkillInvoke(self:objectName(), player)
			end
            return true
		end
	end,
	
	on_effect = function(self, event, room, player, data)
		player:skip(sgs.Player_Discard)
	end,
}

--[[
	空城
	相关武将：标-诸葛亮
	描述：锁定技，每当你成为【杀】或【决斗】的目标时，若你没有手牌，你取消之。 
	引用：
	状态：
]]

LuaKongcheng = sgs.CreateTriggerSkill{
	name = "LuaKongcheng",
	events = {sgs.TargetConfirming},
	frequency = sgs.Skill_Compulsory,

    can_trigger = function(self,event,room,player,data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return false end
        if player:isKongcheng() then
            local use = data:toCardUse()
            if use.card and (use.card:isKindOf("Slash") or use.card:isKindOf("Duel")) and use.to:contains(player) then
                return self:objectName()
			end
		end
	end,
    on_cost = function(self,event,room,player,data)
        if player:hasShownSkill(self) or player:askForSkillInvoke(self) then
            room:broadcastSkillInvoke(self:objectName(), player)
            return true
		end
	end,
    on_effect = function(self,event,room,player,data)
        room:sendCompulsoryTriggerLog(player, self:objectName(),true)
        local use = data:toCardUse()
        sgs.Room_cancelTarget(use, player)
        data:setValue(use)
	end,
}

--[[
	苦肉
	相关武将：标-黄盖
	描述：出牌阶段，你可以失去1点体力，摸两张牌。 
	引用：
	状态：
]]

LuaKurouCard = sgs.CreateSkillCard{
	name = "LuaKurouCard",
    target_fixed = true,

	extra_cost = function(self,room,card_use)
		room:loseHp(card_use.from)
	end,
	on_use = function(self,room,source)
		room:drawCards(source, 2)
	end,
}

LuaKurou = sgs.CreateViewAsSkill{
	name = "LuaKurou",
	view_filter = function(self)
		return false
	end,
	enabled_at_play = function(self,player)
		return player:getHp() > 0
	end,
	view_as = function(self)
		local card = LuaKurouCard:clone()
		card:setShowSkill(self:objectName())
		card:setSkillName(self:objectName())
		return card
	end,
}

--[[
	狂斧
	相关武将：标-潘凤
	描述：每当你使用【杀】对目标角色造成伤害后，你可以选择一项：1.将其装备区里的一张牌置入你的装备区；2.弃置其装备区里的一张牌。  
	引用：
	状态：
]]
--[[
	狂骨
	相关武将：标-魏延
	描述：锁定技，每当你对距离1以内的一名角色造成1点伤害后，你回复1点体力。    
	引用：
	状态：
]]


LuaKuanggu = sgs.CreateTriggerSkill{
	name = "LuaKuanggu",
	events = {sgs.PreDamageDone,sgs.Damage},
	frequency = sgs.Skill_Compulsory,

	can_trigger = function(self, event, room, player, data)
		if event == sgs.PreDamageDone then
			local damage = data:toDamage()
			local weiyan = damage.from
            if weiyan and weiyan:hasSkill(self:objectName()) then
				if weiyan:distanceTo(damage.to) ~= -1 and weiyan:distanceTo(damage.to) <= 1 then
                    weiyan:setTag("InvokeKuanggu", sgs.QVariant(damage.damage))
                else
                    weiyan:removeTag("InvokeKuanggu")
				end
			end
		else			
			if not player or player:isDead() or not player:hasSkill(self:objectName()) then return false end
			local recorded_damage = player:getTag("InvokeKuanggu"):toInt()
			if recorded_damage and recorded_damage > 0 and player:isWounded() then
				local skill_list = {}
				local damage = data:toDamage()
				for i = 1, damage.damage, 1 do
					table.insert(skill_list, self:objectName())
				end
                return table.concat(skill_list, ",")
			end
		end
	end,

	on_cost = function(self, event, room, player, data)
		if player:hasShownSkill(self:objectName()) or player:askForSkillInvoke(self:objectName()) then
			room:broadcastSkillInvoke(self:objectName(), player)
            return true
		end
	end,
	
	on_effect = function(self, event, room, player, data)
		room:sendCompulsoryTriggerLog(player, self:objectName(), true)
        local recover = sgs.RecoverStruct()
		recover.who = player
		room:recover(player, recover)
	end,
}
