--[[
	国战技能速查手册（J区）
	技能索引：
	激昂、急救、急袭、激诏、集智、奸雄、节命、结姻、据守、巨象  
]]--
--[[
	激昂
	相关武将：势-孙策
	描述：每当你使用一张【决斗】或红色【杀】指定目标后，或成为一张【决斗】或红色【杀】的目标后，你可以摸一张牌。   
	引用：
	状态：
]]
--[[
	急救
	相关武将：标-华佗
	描述：你于回合外可以将一张红色牌当【桃】使用。   
	引用：
	状态：
]]
--[[
	急袭
	相关武将：阵-邓艾
	描述：主将技，此武将牌上单独的阴阳鱼个数-1；主将技，你可以将一张“田”当【顺手牵羊】使用。 
	引用：
	状态：
]]
--[[
	激诏
	相关武将：阵-君刘备
	描述：限定技，当你处于濒死状态时，你可以将手牌补至X张（X为你的体力上限），然后将体力值回复至2点，最后失去“授钺”并获得“仁德”。 
	引用：
	状态：
]]
--[[
	集智
	相关武将：标-黄月英
	描述：每当你使用非转化的非延时类锦囊牌时，你可以摸一张牌。  
	引用：
	状态：
]]
--[[
	奸雄
	相关武将：标-曹操
	描述：每当你受到伤害后，你可以获得造成此伤害的牌。   
	引用：
	状态：
]]

Luajianxiong = sgs.CreateTriggerSkill{
	name = "Luajianxiong",
	events = {sgs.Damaged},
	can_preshow = true,
	can_trigger = function(self, event, room, player, data)
		if not player or player:isAlive() or player:hasSkill(self:objectName()) then return false end
		if card and room:getCardPlace(card:getEffectiveId()) == sgs.Player_PlaceTable then
			return self:objectName()
		end
	end,
	on_cost = function(self,event,room,player,data)
		return player:askForSkillInvoke(self:objectName(), data)
	end,
	on_effect = function(self,event,room,player,data)
		local damage = data:toDamage()
		local card = damage.card
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		player:obtainCard(card)
	end,
}

--[[
	节命
	相关武将：标-荀彧
	描述：每当你受到1点伤害后，你可以令一名角色将手牌补至X张（X为该角色的体力上限且至多为5）。   
	引用：
	状态：
]]
--[[
	结姻
	相关武将：标-孙尚香
	描述：出牌阶段限一次，你可以弃置两张手牌并选择一名已受伤的其他男性角色，令你与其各回复1点体力。   
	引用：
	状态：
]]
--[[
	据守
	相关武将：标-曹仁
	描述：结束阶段开始时，你可以摸三张牌，然后你叠置。   
	引用：
	状态：
]]

luaJushou = sgs.CreatePhaseChangeSkill{
	name = "luaJushou",  
	frequency = sgs.Skill_Frequent,
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return false end
		if player:getPhase() == sgs.Player_Finish then return self:objectName() end
	end,
	on_cost = function(self, event, room, player, data)
		return player:askForSkillInvoke(self:objectName(), data)
	end,
	
	on_phasechange = function(self, player)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		player:drawCards(3, self:objectName())
		player:turnOver()
		return false
	end,
}

--[[
	巨象
	相关武将：标-祝融
	描述：锁定技，【南蛮入侵】对你无效；锁定技，每当其他角色使用的【南蛮入侵】因结算完毕而置入弃牌堆后，你获得之。 
	引用：
	状态：
]]
