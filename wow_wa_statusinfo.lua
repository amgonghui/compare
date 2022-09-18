local tplayerClass = string.upper(select(2, UnitClass("player")))
local tnumTabs = GetNumTalentTabs()
local usetalent
local tname1, tname2
local tRank = {}
local tTalentText = {}
local tStance, Tclass
--local mediaFolder = "Interface\\AddOns\\StatusInfo\\"
local NameFont = GameTooltipTextLeft1:GetFont()
local NumbFont = GameTooltipTextLeft1:GetFont()
--local NameFont = smed:Fetch("font", "ARHei _backup") -- mediaFolder.."impact.ttf"
--local NumbFont = smed:Fetch("font", "ARHei _backup")
local NameFS = 18
local NumbFS = 16
local FontF = "THINOUTLINE"
local FontFMain = "OUTLINE, MONOCHROME"
local StatuPoint, StatuRelay, StatuX, StatuY
local StatusToggle = false
local spellSuffix
local extraCrit = 0

local PlayAs  -- 1:物理 DPS,2:法术 DPS,3:治疗, 4 坦克 5,猎人
local region = WeakAuras.regions[aura_env.id].region
local StatuFrame = CreateFrame("Frame", "StatuFrame", region)
StatuFrame:SetWidth(100)
StatuFrame:SetHeight(75)
StatuFrame:SetAlpha(0.8)
StatuFrame:Show()

local statuMain = StatuFrame:CreateFontString(nil, "OVERLAY")
statuMain:SetFont(NameFont, NumbFS * 2, FontF)
statuMain:SetPoint("TOPRIGHT", StatuFrame, "TOPRIGHT", 10, 0)
statuMain:SetJustifyH("RIGHT")
local statu2 = StatuFrame:CreateFontString(nil, "OVERLAY")
statu2:SetFont(NameFont, NumbFS * 1.2, FontF)
statu2:SetPoint("TOPRIGHT", StatuFrame, "BOTTOMRIGHT", 10, 45)
statu2:SetJustifyH("RIGHT")
local statu3 = StatuFrame:CreateFontString(nil, "OVERLAY")
statu3:SetFont(NameFont, NumbFS * 1.2, FontF)
statu3:SetPoint("TOPRIGHT", StatuFrame, "BOTTOMRIGHT", 10, 25)
statu3:SetJustifyH("RIGHT")
local statu4 = StatuFrame:CreateFontString(nil, "OVERLAY")
statu4:SetFont(NameFont, NumbFS * 1.2, FontF)
statu4:SetPoint("TOPRIGHT", StatuFrame, "BOTTOMRIGHT", 10, 5)
statu4:SetJustifyH("RIGHT")
local statu5 = StatuFrame:CreateFontString(nil, "OVERLAY")
statu5:SetFont(NameFont, NumbFS * 1.2, FontF)
statu5:SetPoint("TOPRIGHT", StatuFrame, "BOTTOMRIGHT", 10, -15)
statu5:SetJustifyH("RIGHT")
-- Describe--
local statuMainDes = StatuFrame:CreateFontString(nil, "OVERLAY")
statuMainDes:SetFont(NameFont, NumbFS * 1.1, FontF)
statuMainDes:SetPoint("BOTTOMLEFT", statuMain, "BOTTOMRIGHT", 0, 5)
statuMainDes:SetJustifyH("LEFT")
local statu2Des = StatuFrame:CreateFontString(nil, "OVERLAY")
statu2Des:SetFont(NameFont, NumbFS * 1, FontF)
statu2Des:SetPoint("BOTTOMLEFT", statu2, "BOTTOMRIGHT", 0, 2)
statu2Des:SetJustifyH("LEFT")
local statu3Des = StatuFrame:CreateFontString(nil, "OVERLAY")
statu3Des:SetFont(NameFont, NumbFS * 1, FontF)
statu3Des:SetPoint("BOTTOMLEFT", statu3, "BOTTOMRIGHT", 0, 2)
statu3Des:SetJustifyH("LEFT")
local statu4Des = StatuFrame:CreateFontString(nil, "OVERLAY")
statu4Des:SetFont(NameFont, NumbFS * 1, FontF)
statu4Des:SetPoint("BOTTOMLEFT", statu4, "BOTTOMRIGHT", 0, 2)
statu4Des:SetJustifyH("LEFT")
local statu5Des = StatuFrame:CreateFontString(nil, "OVERLAY")
statu5Des:SetFont(NameFont, NumbFS * 1, FontF)
statu5Des:SetPoint("BOTTOMLEFT", statu5, "BOTTOMRIGHT", 0, 2)
statu5Des:SetJustifyH("LEFT")

local function GetCurrentInfo()
    local Stance = GetShapeshiftForm()
    local _, _, num1, _ = GetTalentTabInfo(1)
    local _, _, num2, _ = GetTalentTabInfo(2)
    local _, _, num3, _ = GetTalentTabInfo(3)
    
    local usetalent
    if num1 > num2 and num1 > num3 then
        usetalent = 1
    elseif num2 > num1 and num2 > num3 then
        usetalent = 2
    elseif num3 > num1 and num3 > num2 then
        usetalent = 3
    else
        usetalent = 1
    end
    if tplayerClass == "DRUID" then
        -- 德鲁伊，现在是4系天赋，分别是法术、坦克、物理、治疗
        if usetalent == 1 then
            PlayAs = 2
        elseif usetalent == 3 then
            PlayAs = 3
        elseif usetalent == 2 and GetShapeshiftFormID() == 8 then
            PlayAs = 4
        else
            PlayAs = 1
        end
    elseif tplayerClass == "PALADIN" then
        -- 1,2,同时能做3样的
        -- 圣骑士不好说……因为有防惩的存在……还是以天赋判定吧
        if usetalent == 1 then
            PlayAs = 3
        elseif usetalent == 2 then
            PlayAs = 4
        else
            PlayAs = 1
        end
    elseif tplayerClass == "SHAMAN" then
        -- 萨满，根据天赋判定了……
        if usetalent == 1 then
            local _, _, _, _, point = GetTalentInfo(1, 8) --《雷霆召唤》 每点加1爆
            extraCrit = point
            PlayAs = 2
        elseif usetalent == 2 then
            PlayAs = 1
        else
            PlayAs = 3
        end
    elseif tplayerClass == "PRIEST" then
        -- 3,4 can play as 能做DPS和治疗的
        -- 牧师，当天赋为暗影时被认为是法系DPS，否则被认为治疗
        if usetalent == 3 then
            PlayAs = 2
        else
            PlayAs = 3
        end
    elseif tplayerClass == "WARRIOR" then
        -- 5,6 can play as 能做DPS和坦克的
        -- 战士，开防御姿态认定为坦克
        if GetShapeshiftFormID() == 18 then
            PlayAs = 4
        else
            PlayAs = 1
        end
    elseif tplayerClass == "ROGUE" then
        PlayAs = 1
    elseif tplayerClass == "HUNTER" then
        -- 7 to 8 :只能做物理DPS
        PlayAs = 5 -- 猎人要看远程的，所以单独
    elseif tplayerClass == "MAGE" then
        local _, _, _, _, point = GetTalentInfo(2, 14) --《火焰重击》 每点加2爆
        local _, _, _, _, point1 = GetTalentInfo(2, 18) --《纵火》 每点加1爆
        extraCrit = (point * 2) + point1
        PlayAs = 2
    elseif tplayerClass == "WARLOCK" then
        local _, _, _, _, point = GetTalentInfo(3, 7) --《毁坏》 每点加1爆
        extraCrit = point
        PlayAs = 2
        -- 9 to 10:只能做法系DPS
    end
    -- print("StatuInfo Loaded  "..PlayAs..GetTalentTabInfo(usetalent))
end
local function updateStatu(playas)
    if playas == 1 then
        -- "Melee DPS")
        local base, posBuff, negBuff = UnitAttackPower("player")
        local effective = base + posBuff + negBuff
        statuMain:SetFont(NumbFont, NumbFS * 2, FontF)
        statuMain:SetText("|cffff3333" .. effective)
        
        local crb = GetCombatRatingBonus(CR_HIT_MELEE)
        local hm = GetHitModifier()
        statu2:SetText(format("|cffffffcc %d", GetArmorPenetration()))
        
        if crb ~= nil and hm ~= nil then
            statu3:SetText(format("|cffffffcc %.2f%%", (crb + hm)))
        end
        statu4:SetText(format("|cffffffcc %.2f%%", GetCritChance()))
        --statu4:SetText(format("|cffffffcc %.2f%%", GetCombatRatingBonus(CR_HASTE_MELEE)))
        
        mainSpeed, offSpeed = UnitAttackSpeed("player")
        if offSpeed then
            statu5:SetText(format("|cffffff66 %.2f/%.2f", mainSpeed, offSpeed))
        else
            statu5:SetText(format("|cffffff66 %.2f", mainSpeed))
        end
        statuMainDes:SetText("攻强")
        statu2Des:SetText("穿甲")
        statu3Des:SetText("命中")
        statu4Des:SetText("爆击")
        statu5Des:SetText("攻速")
        
    elseif playas == 2 then
        -- "Cast DPS")
        
        local SpellDamageFire = GetSpellBonusDamage(3)
        local SpellDamageNature = GetSpellBonusDamage(4)
        local SpellDamageFrost = GetSpellBonusDamage(5)
        local SpellDamageShadow = GetSpellBonusDamage(6)
        local SpellDamageArcane = GetSpellBonusDamage(7)
        
        local arr = {SpellDamageFire, SpellDamageNature, SpellDamageFrost, SpellDamageShadow, SpellDamageArcane}
        local SpellDamage = math.max(unpack(arr))
        
        if SpellDamageFire == SpellDamageFrost and SpellDamageFrost == SpellDamageShadow then
            spellSuffix = "法伤"
        else
            if SpellDamage == SpellDamageFire then
                spellSuffix = "火伤"
                if SpellDamageFire == SpellDamageArcane and tplayerClass == "DRUID" then
                    spellSuffix = "奥伤"
                end
            elseif SpellDamage == GetSpellBonusDamage then
                spellSuffix = "自然伤"
            elseif SpellDamage == SpellDamageFrost then
                spellSuffix = "冰伤"
                
                if SpellDamageFrost == SpellDamageShadow and (tplayerClass == "WARLOCK" or tplayerClass == "PRIEST") then
                    spellSuffix = "暗伤"
                end
            elseif SpellDamage == SpellDamageShadow then
                spellSuffix = "暗伤"
            elseif SpellDamage == SpellDamageArcane then
                spellSuffix = "奥伤"
            else
                spellSuffix = "法伤"
            end
        end
        
        statuMain:SetFont(NumbFont, NumbFS * 2, FontF)
        statuMain:SetText("|cffff3333" .. SpellDamage)
        local spellHitRating = GetCombatRatingBonus(CR_HIT_SPELL)
        if spellHitRating == nil then -- sets the rating to 0 instead of nil when you have no hit
            spellHitRating = 0
        end
        
        local spellHit = spellHitRating -- (GetSpellHitModifier() or 0) + spellHitRating  -- GetSpellHitModifier  is  buggy now, just show the rating from gear
        if tplayerClass == "DRUID" then --鸟德+4命中
            spellHit = spellHit + 4
        end
        
        --直接使用面板命中,加上图腾和德莱尼
        local y, n, s, _
        for i = 1, 40 do
            local _, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i)
            --28878 鼓舞灵气 使你和身边半径30码范围内的所有小队成员的法术命中几率提高1%。
            if spellId == 28878 then
                --print(n .. " on target, steal it!")
                spellHit = spellHit + 1
            end
            --天怒图腾  成员的法术命中几率和法术爆击几率提高3%。
            if spellId == 30708 then
                --print(n .. " on target, steal it!")
                spellHit = spellHit + 3
            end
        end
        local spellCrit = GetSpellCritChance(7) + extraCrit
        
        -- statuMain:SetAlphaGradient(0,40)
        statu2:SetText(format("|cffffff66 %.2f%%", GetCombatRatingBonus(CR_HASTE_SPELL)))
        statu3:SetText(format("|cffffff66 %.2f%%", spellHit))
        --statu3:SetText(format("|cffffff66 %d", spellHit  * 12.65))
        statu4:SetText(format("|cffffff66 %.2f%%", spellCrit))
        
        statuMainDes:SetText(spellSuffix)
        
        statu4Des:SetText("爆击")
        statu3Des:SetText("命中")
        statu2Des:SetText("急速")
    elseif playas == 3 then
        -- "Health")
        statuMain:SetFont(NumbFont, NumbFS * 2, FontF)
        statuMain:SetText("|cff00ff00" .. GetSpellBonusHealing())
        statu2:SetText(format("|cffffffcc %.2f%%", GetSpellCritChance(2)))
        base, casting = GetManaRegen()
        statu3:SetText(format("|cff0066cc %d/%d", base * 5, casting * 5))
        statuMainDes:SetText("治疗")
        statu2Des:SetText("爆击")
        statu3Des:SetText("回复")
        statu4:SetText(format("|cffffff33 %.2f%%", GetCombatRatingBonus(CR_HASTE_SPELL)))
        statu4Des:SetText("急速")
        statu5:SetText(format("|cffffff33 %d", UnitPowerMax("player")))
        statu5Des:SetText("蓝量")
    elseif playas == 4 then
        -- "Tank")
        
        --
        local baseArmor, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player")
        statuMain:SetFont(NumbFont, NumbFS * 2, FontF)
        if tplayerClass == "PALADIN" then
            local SpellDamageHoly = GetSpellBonusDamage(2)
            statuMain:SetText("|cffff3333" .. SpellDamageHoly)
            statuMainDes:SetText("法伤")
            statu5:SetText("|cff0066cc" .. effectiveArmor)
            statu5Des:SetText("护甲")
        else
            statuMain:SetText("|cff0066cc" .. effectiveArmor)
            statuMainDes:SetText("护甲")
            statu5:SetText(format("|cffffff33 %d", UnitHealthMax("player")))
            statu5Des:SetText("血量")
        end
        
        statu2:SetText(format("|cffffffcc %.2f%%", GetDodgeChance()))
        statu2Des:SetText("躲闪")
        if GetParryChance() ~= 0 then
            statu3:SetText(format("|cffcc99cc %.2f%%", GetParryChance()))
            statu3Des:SetText("招架")
        else
            statu3:SetText()
            statu3Des:SetText()
        end
        statu4:SetText(format("|cffffff33 %.2f%%", GetBlockChance()))
        statu4Des:SetText("格挡")
    elseif playas == 5 then -- 猎人
        local base, posBuff, negBuff = UnitRangedAttackPower("player")
        local effective = base + posBuff + negBuff
        statuMain:SetFont(NumbFont, NumbFS * 2, FontF)
        statuMain:SetText("|cffff3333" .. effective)
        
        statu2:SetText(format("|cffffffcc %.2f%%", (GetCombatRatingBonus(CR_HIT_RANGED) + GetHitModifier())))
        
        statu3:SetText(format("|cffffffcc %.2f%%", GetRangedCritChance()))
        
        statu4:SetText(format("|cffffffcc %.2f%%", GetCombatRatingBonus(CR_HASTE_RANGED)))
        
        speed, lowDmg, hiDmg, posBuff, negBuff, percent = UnitRangedDamage("player")
        statu5:SetText(format("|cffffff66 %.2f", speed))
        statuMainDes:SetText("攻强")
        statu2Des:SetText("命中")
        statu3Des:SetText("爆击")
        statu4Des:SetText("急速")
        statu5Des:SetText("攻速")
    end
end

StatuFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
StatuFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
StatuFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
StatuFrame:RegisterEvent("ADDON_LOADED")
StatuFrame:RegisterEvent("UNIT_AURA")
StatuFrame:SetScript(
    "OnEvent",
    function(self, event)
        if event == "UPDATE_SHAPESHIFT_FORM" or event == "UNIT_AURA" then
        elseif event == "PLAYER_REGEN_DISABLED" then
        elseif event == "PLAYER_REGEN_ENABLED" then
        elseif event == "ADDON_LOADED" then
        end
    end
)
local TimeSinceLastUpdate = 0
local f = CreateFrame("frame", nil, UIParent)
f:SetScript(
    "OnUpdate",
    function(self, elapsed)
        TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
        if (TimeSinceLastUpdate > 0.5) then
            GetCurrentInfo()
            updateStatu(PlayAs or 1)
            TimeSinceLastUpdate = 0
        end
    end
)
StatuFrame:SetPoint("CENTER")
region:SetScript("OnSizeChanged", StatuFrame.OnSizeChanged)

