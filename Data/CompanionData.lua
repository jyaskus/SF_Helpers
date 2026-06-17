
-- Companion data indexed by level (1-20)
local CompanionDataAll = {
  [1] = { price = 100,  hp = 10, attack = 2, damage = "1d4+1",   eac = 11, kac = 14, ac=0,  goodSave =4,  poorSave =1, firstAbility = 2, secondAbility =1, skillBonus = 5 },
  [2] = { price = 500,  hp = 20, attack = 3, damage = "1d4+2",   eac = 12, kac = 15, ac=1,  goodSave =5,  poorSave =1, firstAbility = 2, secondAbility =1, skillBonus = 6 },
  [3] = { price = 1200, hp = 30, attack = 4, damage = "1d4+3",   eac = 13, kac = 16, ac=2,  goodSave =5,  poorSave =2, firstAbility = 2, secondAbility =1, skillBonus = 7 },
  [4] = { price = 1800, hp = 40, attack = 5, damage = "1d4+4",   eac = 15, kac = 18, ac=4,  goodSave =5,  poorSave =2, firstAbility = 2, secondAbility =1, skillBonus = 8 },
  [5] = { price = 2700, hp = 55, attack = 6, damage = "1d4+5",   eac = 16, kac = 19, ac=5,  goodSave =7,  poorSave =3, firstAbility = 2, secondAbility =1, skillBonus = 9 },
  [6] = { price = 4900, hp = 65, attack = 7, damage = "1d6+6",   eac = 17, kac = 20, ac=6,  goodSave =7,  poorSave =3, firstAbility = 2, secondAbility =1, skillBonus = 10 },
  [7] = { price = 5400, hp = 80, attack = 9, damage = "1d8+7",   eac = 19, kac = 22, ac=8,  goodSave =8,  poorSave =4, firstAbility = 3, secondAbility =2, skillBonus = 12 },
  [8] = { price = 8400, hp = 90, attack =10, damage = "1d12+8",  eac = 20, kac = 23, ac=9,  goodSave =8,  poorSave =4, firstAbility = 3, secondAbility =2, skillBonus = 13 },
  [9] = { price =12000, hp =105, attack =11, damage = "3d4+9",   eac = 21, kac = 24, ac=10, goodSave =8,  poorSave =4, firstAbility = 3, secondAbility =2, skillBonus = 14 },
  [10]= { price =17000, hp =120, attack =13, damage = "2d8+10",  eac = 23, kac = 26, ac=12, goodSave =10, poorSave =5, firstAbility = 3, secondAbility =2, skillBonus = 15 },
  [11]= { price =23000, hp =135, attack =14, damage = "2d10+11", eac = 23, kac = 26, ac=12, goodSave =10, poorSave =6, firstAbility = 3, secondAbility =2, skillBonus = 16 },
  [12]= { price =31000, hp =145, attack =14, damage = "2d12+12", eac = 24, kac = 27, ac=13, goodSave =10, poorSave =6, firstAbility = 3, secondAbility =2, skillBonus = 17 },
  [13]= { price =46000, hp =160, attack =16, damage = "6d4+13",  eac = 26, kac = 29, ac=15, goodSave =11, poorSave =6, firstAbility = 4, secondAbility =3, skillBonus = 19 },
  [14]= { price =63000, hp =175, attack =17, damage = "6d6+14",  eac = 27, kac = 30, ac=16, goodSave =11, poorSave =6, firstAbility = 4, secondAbility =3, skillBonus = 20 },
  [15]= { price =94000, hp =190, attack =18, damage = "5d8+15",  eac = 28, kac = 31, ac=17, goodSave =12, poorSave =8, firstAbility = 4, secondAbility =3, skillBonus = 21 },
  [16]= { price=144000, hp =205, attack =19, damage = "6d8+16",  eac = 30, kac = 33, ac=19, goodSave =12, poorSave =8, firstAbility = 4, secondAbility =3, skillBonus = 22 },
  [17]= { price=216000, hp =225, attack =20, damage = "8d6+17",  eac = 31, kac = 34, ac=20, goodSave =12, poorSave =8, firstAbility = 4, secondAbility =3, skillBonus = 23 },
  [18]= { price=325000, hp =250, attack =21, damage = "8d8+18",  eac = 32, kac = 35, ac=21, goodSave =13, poorSave =8, firstAbility = 4, secondAbility =3, skillBonus = 24 },
  [19]= { price=480000, hp =275, attack =23, damage = "9d8+19",  eac = 34, kac = 37, ac=23, goodSave =13, poorSave =9, firstAbility = 5, secondAbility =4, skillBonus = 26 },
  [20]= { price=720000, hp =300, attack =23, damage = "13d6+20", eac = 35, kac = 38, ac=24, goodSave =14, poorSave =9, firstAbility = 5, secondAbility =4, skillBonus = 27 },
}

-- Helper function to validate and clamp level to valid range (1-20)
function validateLevel(nLevel)
  if sf.isGt(nLevel, 20) then
    return 20;
  end
  if sf.isGt(1, nLevel) then
    return 1;
  end
  return nLevel;
end

-- Get the price/cost for a companion at the specified level
function getLevelCost(nLevel)
  nLevel = validateLevel(nLevel);
  local data = CompanionDataAll[nLevel];
  return data and data.price or 0;
end

-- Calculate the upgrade cost from current level to target level
function getUpgradeCost(nCurrentLevel, nTargetLevel)
  nCurrentLevel = validateLevel(nCurrentLevel);
  nTargetLevel = validateLevel(nTargetLevel);
  
  local currentData = CompanionDataAll[nCurrentLevel];
  local targetData = CompanionDataAll[nTargetLevel];
  
  local nCurrentCost = currentData and currentData.price or 0;
  local nTargetCost = targetData and targetData.price or 0;
  
  return nTargetCost - nCurrentCost;
end

-- Get the HP for a companion at the specified level
function getLevelHP(nLevel)
  nLevel = validateLevel(nLevel);
  local data = CompanionDataAll[nLevel];
  return data and tonumber(data.hp) or 0;
end

-- Get the attack bonus for a companion at the specified level
function getLevelAttack(nLevel)
  nLevel = validateLevel(nLevel);
  local data = CompanionDataAll[nLevel];
  return data and data.attack or 0;
end

-- Get the damage string for a companion at the specified level

-- Get the melee damage string for a companion at the specified level
function getLevelMeleeDamage(nLevel)
  nLevel = validateLevel(nLevel);
  local data = CompanionDataAll[nLevel];
  return data and data.damage or "1d4";
end

-- Get the ranged damage string for a companion at the specified level
function getLevelRangedDamage(nLevel)
  nLevel = validateLevel(nLevel);
  local data = CompanionDataAll[nLevel];
  -- For now, use the same damage as melee; customize if needed
  return data and data.damage or "1d4";
end

-- Get the EAC for a companion at the specified level
function getLevelEAC(nLevel)
  nLevel = validateLevel(nLevel);
  local data = CompanionDataAll[nLevel];
  return data and data.eac or 10;
end

-- Get the KAC for a companion at the specified level
function getLevelKAC(nLevel)
  nLevel = validateLevel(nLevel);
  local data = CompanionDataAll[nLevel];
  return data and data.kac or 10;
end

-- Get the good save bonus for a companion at the specified level
function getLevelGoodSave(nLevel)
  nLevel = validateLevel(nLevel);
  local data = CompanionDataAll[nLevel];
  return data and data.goodSave or 0;
end

-- Get the poor save bonus for a companion at the specified level
function getLevelPoorSave(nLevel)
  nLevel = validateLevel(nLevel);
  local data = CompanionDataAll[nLevel];
  return data and data.poorSave or 0;
end

-- Get the first ability score modifier for a companion at the specified level
function getLevelFirstAbility(nLevel)
  nLevel = validateLevel(nLevel);
  local data = CompanionDataAll[nLevel];
  return data and data.firstAbility or 0;
end

-- Get the second ability score modifier for a companion at the specified level
function getLevelSecondAbility(nLevel)
  nLevel = validateLevel(nLevel);
  local data = CompanionDataAll[nLevel];
  return data and data.secondAbility or 0;
end

-- Get the skill bonus for a companion at the specified level
function getLevelSkillBonus(nLevel)
  nLevel = validateLevel(nLevel);
  local data = CompanionDataAll[nLevel];
  return data and data.skillBonus or 0;
end

-- Get all companion data for a specified level
function getLevelData(nLevel)
  nLevel = validateLevel(nLevel);
  return CompanionDataAll[nLevel];
end

-- Function to return the bonus for a given stat value from 1 to 30
function getStatBonus(nStatValue)
  nStatValue = math.floor(nStatValue);
  if nStatValue < 1 then
    nStatValue = 1;
  elseif nStatValue > 30 then
    nStatValue = 30;
  end
  return math.floor((nStatValue - 10) / 2);
end

-- Function to convert a bonus back to an ability score
-- Formula: score = (bonus * 2) + 10
-- Example: +4 bonus = 18 score, -4 bonus = 2 score
function getScoreFromBonus(nBonus)
  return (nBonus * 2) + 10;
end