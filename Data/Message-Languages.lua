local _, ns = ...
local Data = ns.Data

--------------------------------------------------------------------------------
-- Message Languages
--------------------------------------------------------------------------------

--[[
    The languages Good to Go can write its whispers in, for the "Send Messages
    In" dropdown. This is the language other players read. The Locales files
    are the language of the player's own UI, and AceLocale loads only the
    client's own file, so the default text of every editable whisper lives
    here, where every language loads in every client: an English client
    whispering in German still needs the German default.

    One row per supported locale, in the master list's order (which is also
    the dropdown's): the client locale code, the language's name in that
    language (so a player finds their own in any client, and it needs no
    translation), then the default text of each editable whisper:
      buffAsk             Buff Duty's whispered ask for a missing raid buff
      rankWatchTip        Rank Watch's low-rank tip to the caster
      rankWatchTipPet     the same tip to a hunter whose pet cast it
      rankWatchTipDemon   the same tip to a warlock whose demon cast it
      rankWatchOptOut     the opt-out offer, with a player's second tip in a session
      rankWatchOptOutDone the reply to a group member who whispered "Opt Out"
    and two forms of the ask that only the default uses, so a player who
    never edits it gets the same grammar as the ask said to the group:
      buffAskOne          one player missing the buff
      buffAskCount        more players missing it than the ask names

    TRANSLATORS: keep {names}, {spell}, {count}, {level} and {pet} exactly as
    written; Good to Go swaps in the missing players' names (or how many), the
    buff or spell, the count, the level and the pet. Keep "Opt Out" in English
    in every language: it is the words a player whispers back, and Good to Go
    listens for exactly those.
]]
Data.MESSAGE_LANGUAGES = {
	{
		locale = "enUS",
		name = "English",
		buffAsk = "{names} are missing {spell}.",
		buffAskOne = "{names} is missing {spell}.",
		buffAskCount = "{count} people are missing the {spell} buff.",
		rankWatchTip = "FYI, no biggie, but you used {spell}. There's a newer rank at level {level}. Update your action bars or visit your trainer and you'll be Good to Go.",
		rankWatchTipPet = "FYI, no biggie, but your pet {pet} used {spell}. There's a newer rank at pet level {level}. Teach it with Beast Training and you'll be Good to Go.",
		rankWatchTipDemon = "FYI, no biggie, but your {pet} used {spell}. There's a newer rank at level {level}. Grab its grimoire from a demon trainer and you'll be Good to Go.",
		rankWatchOptOut = 'Not your thing? Reply "Opt Out" and I\'ll stop sending these.',
		rankWatchOptOutDone = "Heard, I won't message you about this again!",
	},
	{
		locale = "deDE",
		name = "Deutsch",
		buffAsk = "{names} fehlt {spell}.",
		buffAskOne = "{names} fehlt {spell}.",
		buffAskCount = "{count} Spielern fehlt der Buff {spell}.",
		rankWatchTip = "Nur als Info, nichts Wildes, aber du hast {spell} benutzt. Ab Stufe {level} gibt es einen neueren Rang. Aktualisiere deine Aktionsleisten oder besuch deinen Lehrer, und du bist Good to Go.",
		rankWatchTipPet = "Nur als Info, nichts Wildes: Dein Begleiter {pet} hat {spell} benutzt. Ab Begleiterstufe {level} gibt es einen neueren Rang. Per Wildtierausbildung beibringen, und du bist Good to Go.",
		rankWatchTipDemon = "Nur als Info, nichts Wildes: Dein Dämon {pet} hat {spell} benutzt. Ab Stufe {level} gibt es einen neueren Rang. Hol dir das Grimoire beim Dämonenausbilder, und du bist Good to Go.",
		rankWatchOptOut = 'Nicht dein Ding? Antworte mit "Opt Out", dann schicke ich dir keine mehr.',
		rankWatchOptOutDone = "Verstanden, ich schreibe dich deswegen nicht mehr an!",
	},
	{
		locale = "esES",
		name = "Español (EU)",
		buffAsk = "A {names} les falta {spell}.",
		buffAskOne = "A {names} le falta {spell}.",
		buffAskCount = "A {count} personas les falta el beneficio {spell}.",
		rankWatchTip = "Por cierto, nada grave, pero has usado {spell}. Hay un rango más alto desde el nivel {level}. Actualiza tus barras de acción o visita a tu instructor y estarás Good to Go.",
		rankWatchTipPet = "Por cierto, nada grave, pero tu mascota {pet} ha usado {spell}. Hay un rango más alto desde el nivel de mascota {level}. Enséñaselo con Adiestrar bestia y estarás Good to Go.",
		rankWatchTipDemon = "Por cierto, nada grave, pero tu {pet} ha usado {spell}. Hay un rango más alto desde el nivel {level}. Hazte con su grimorio en un instructor de demonios y estarás Good to Go.",
		rankWatchOptOut = '¿No te interesa? Responde "Opt Out" y dejaré de enviártelos.',
		rankWatchOptOutDone = "Entendido, ¡no volveré a escribirte sobre esto!",
	},
	{
		locale = "esMX",
		name = "Español (AL)",
		buffAsk = "A {names} les falta {spell}.",
		buffAskOne = "A {names} le falta {spell}.",
		buffAskCount = "A {count} personas les falta el beneficio {spell}.",
		rankWatchTip = "Oye, no pasa nada, pero usaste {spell}. Hay un rango más alto desde el nivel {level}. Actualiza tus barras de acción o visita a tu instructor y estarás Good to Go.",
		rankWatchTipPet = "Oye, no pasa nada, pero tu mascota {pet} usó {spell}. Hay un rango más alto desde el nivel de mascota {level}. Enséñaselo con Adiestramiento de bestias y estarás Good to Go.",
		rankWatchTipDemon = "Oye, no pasa nada, pero tu {pet} usó {spell}. Hay un rango más alto desde el nivel {level}. Consigue su grimorio con un instructor de demonios y estarás Good to Go.",
		rankWatchOptOut = '¿No te late? Responde "Opt Out" y ya no te los mando.',
		rankWatchOptOutDone = "Entendido, ¡ya no te voy a escribir sobre esto!",
	},
	{
		locale = "frFR",
		name = "Français",
		buffAsk = "{names} n'ont pas {spell}.",
		buffAskOne = "{names} n'a pas {spell}.",
		buffAskCount = "{count} joueurs n'ont pas l'amélioration {spell}.",
		rankWatchTip = "Pour info, rien de grave : tu as utilisé {spell}, mais il y a un rang supérieur dès le niveau {level}. Mets à jour tes barres ou passe voir ton maître, et tu seras Good to Go.",
		rankWatchTipPet = "Pour info, rien de grave : ton familier {pet} a utilisé {spell}, mais il y a un rang supérieur dès son niveau {level}. Enseigne-le-lui avec Dressage des bêtes et tu seras Good to Go.",
		rankWatchTipDemon = "Pour info, rien de grave : ton démon ({pet}) a utilisé {spell}, mais il y a un rang supérieur dès le niveau {level}. Prends son grimoire chez un maître des démons et tu seras Good to Go.",
		rankWatchOptOut = 'Pas ton truc ? Réponds "Opt Out" et je n\'en enverrai plus.',
		rankWatchOptOutDone = "Compris, je ne t'écrirai plus à ce sujet !",
	},
	{
		locale = "itIT",
		name = "Italiano",
		buffAsk = "A {names} manca {spell}.",
		buffAskOne = "A {names} manca {spell}.",
		buffAskCount = "A {count} giocatori manca il potenziamento {spell}.",
		rankWatchTip = "Ehi, niente di grave, ma hai usato {spell}. C'è un grado più alto al livello {level}. Aggiorna le barre delle azioni o passa dal tuo istruttore e sarai Good to Go.",
		rankWatchTipPet = "Ehi, niente di grave, ma il tuo famiglio {pet} ha usato {spell}. C'è un grado più alto al livello {level} del famiglio. Insegnaglielo con Addestramento bestie e sarai Good to Go.",
		rankWatchTipDemon = "Ehi, niente di grave, ma il tuo demone {pet} ha usato {spell}. C'è un grado più alto al livello {level}. Prendi il suo grimorio da un istruttore di demoni e sarai Good to Go.",
		rankWatchOptOut = 'Non fa per te? Rispondi "Opt Out" e smetterò di mandarteli.',
		rankWatchOptOutDone = "Ricevuto, non ti scriverò più per questo!",
	},
	{
		locale = "koKR",
		name = "한국어",
		buffAsk = "{names} 님에게 {spell} 버프가 없습니다.",
		buffAskOne = "{names} 님에게 {spell} 버프가 없습니다.",
		buffAskCount = "{count}명에게 {spell} 버프가 없습니다.",
		rankWatchTip = "참고로 {spell}을(를) 쓰셨는데, {level}레벨부터 상위 레벨이 있어요. 단축바를 바꾸시거나 상급자에게 들르시면 바로 Good to Go!",
		rankWatchTipPet = "참고로 소환수 {pet}이(가) {spell}을(를) 썼는데, 소환수 {level}레벨부터 상위 레벨이 있어요. 야수 조련으로 가르쳐 주시면 바로 Good to Go!",
		rankWatchTipDemon = "참고로 소환하신 {pet}이(가) {spell}을(를) 썼는데, {level}레벨부터 상위 레벨이 있어요. 악마 조련사에게서 마법서를 구하시면 바로 Good to Go!",
		rankWatchOptOut = '이런 팁이 필요 없으신가요? "Opt Out"이라고 답장하시면 더는 보내지 않을게요.',
		rankWatchOptOutDone = "알겠어요, 이 일로 다시 연락하지 않을게요!",
	},
	{
		locale = "ptBR",
		name = "Português (BR)",
		buffAsk = "{names} estão sem {spell}.",
		buffAskOne = "{names} está sem {spell}.",
		buffAskCount = "{count} pessoas estão sem o buff {spell}.",
		rankWatchTip = "Só um toque, nada demais: você usou {spell}. Tem um grau mais novo no nível {level}. Atualize suas barras de ação ou visite seu instrutor e você vai estar Good to Go.",
		rankWatchTipPet = "Só um toque, nada demais: seu ajudante {pet} usou {spell}. Tem um grau mais novo no nível {level} do ajudante. Ensine com Treinamento de Feras e você vai estar Good to Go.",
		rankWatchTipDemon = "Só um toque, nada demais: seu {pet} usou {spell}. Tem um grau mais novo no nível {level}. Pegue o grimório com um instrutor de demônios e você vai estar Good to Go.",
		rankWatchOptOut = 'Não é a sua? Responda "Opt Out" e eu paro de mandar.',
		rankWatchOptOutDone = "Entendido, não vou mais te mandar mensagem sobre isso!",
	},
	{
		locale = "ruRU",
		name = "Русский",
		buffAsk = "{names}: нет {spell}.",
		buffAskOne = "{names}: нет {spell}.",
		buffAskCount = "{count} чел. без {spell}.",
		rankWatchTip = "Вы применили {spell}, а с {level} ур. есть ранг выше. Обновите панели или зайдите к учителю, и будете Good to Go.",
		rankWatchTipPet = "Ваш питомец {pet} применил {spell}, а с {level} ур. есть ранг выше. Обучите его, и будете Good to Go.",
		rankWatchTipDemon = "Ваш {pet} применил {spell}, а с {level} ур. есть ранг выше. Купите гримуар у учителя демонов, и будете Good to Go.",
		rankWatchOptOut = 'Не нужно? Ответьте "Opt Out", и я перестану их присылать.',
		rankWatchOptOutDone = "Принято, больше не буду писать вам об этом!",
	},
	{
		locale = "zhCN",
		name = "简体中文",
		buffAsk = "{names}缺少{spell}。",
		buffAskOne = "{names}缺少{spell}。",
		buffAskCount = "{count}名玩家缺少{spell}增益。",
		rankWatchTip = "友情提示，没啥大不了的：你刚才用的是{spell}，{level}级就有更新的等级了。更新一下动作条或者去找训练师，马上就 Good to Go。",
		rankWatchTipPet = "友情提示，没啥大不了的：你的宠物{pet}刚才用的是{spell}，宠物{level}级就有更新的等级了。用训练野兽教给它，马上就 Good to Go。",
		rankWatchTipDemon = "友情提示，没啥大不了的：你的{pet}刚才用的是{spell}，{level}级就有更新的等级了。去恶魔训练师那里买本魔典，马上就 Good to Go。",
		rankWatchOptOut = '不需要这些提示？回复 "Opt Out"，我就不再发了。',
		rankWatchOptOutDone = "收到，我不会再为这事给你发消息了！",
	},
	{
		locale = "zhTW",
		name = "繁體中文",
		buffAsk = "{names}缺少{spell}。",
		buffAskOne = "{names}缺少{spell}。",
		buffAskCount = "{count}名玩家缺少{spell}增益。",
		rankWatchTip = "小提醒，沒什麼大不了的：你剛剛用的是{spell}，{level}級就有更新的等級了。更新一下快捷列或去找訓練師，馬上就 Good to Go。",
		rankWatchTipPet = "小提醒，沒什麼大不了的：你的寵物{pet}剛剛用的是{spell}，寵物{level}級就有更新的等級了。用訓練野獸教牠，馬上就 Good to Go。",
		rankWatchTipDemon = "小提醒，沒什麼大不了的：你的{pet}剛剛用的是{spell}，{level}級就有更新的等級了。去惡魔訓練師那裡買本魔典，馬上就 Good to Go。",
		rankWatchOptOut = '不需要這些提示？回覆 "Opt Out"，我就不再傳了。',
		rankWatchOptOutDone = "收到，我不會再為這件事傳訊息給你了！",
	},
}

-- English unless the player picks another, whatever the client's own language.
Data.DEFAULT_MESSAGE_LANGUAGE = "enUS"

--[[
    Where each editable whisper keeps the player's own text, by its field in
    Data.MESSAGE_LANGUAGES: the ns.db.global table and the key in it. A key
    left unset means the whisper goes out in the chosen language's default;
    an empty string sends nothing.
]]
Data.EDITABLE_MESSAGES = {
	buffAsk = { scope = "buffWindow", key = "askMessage" },
	rankWatchTip = { scope = "rankWatch", key = "tipMessage" },
	rankWatchTipPet = { scope = "rankWatch", key = "tipMessagePet" },
	rankWatchTipDemon = { scope = "rankWatch", key = "tipMessageDemon" },
	rankWatchOptOut = { scope = "rankWatch", key = "optOutMessage" },
	rankWatchOptOutDone = { scope = "rankWatch", key = "optOutDoneMessage" },
}

local languageByLocale = {}
for _, language in ipairs(Data.MESSAGE_LANGUAGES) do
	languageByLocale[language.locale] = language
end

-- The row for a locale code, or nil when Good to Go has no whispers in it (enGB, for one).
function ns.GetMessageLanguageInfo(locale)
	return locale and languageByLocale[locale] or nil
end

--[[
    The language whispers go out in. A saved code Good to Go no longer lists
    reads as the default, so a stale value never leaves a whisper with no text.
]]
function ns.GetMessageLanguage()
	local saved = ns.db and ns.db.global.messageLanguage
	if languageByLocale[saved] then
		return saved
	end
	return Data.DEFAULT_MESSAGE_LANGUAGE
end

-- A whisper's default text in `locale`, or in the language whispers go out in now.
function ns.GetDefaultMessage(field, locale)
	local language = languageByLocale[locale or ns.GetMessageLanguage()]
		or languageByLocale[Data.DEFAULT_MESSAGE_LANGUAGE]
	return language[field]
end

-- The table holding a whisper's saved text, or nil before the database is open.
local function MessageSettings(field)
	local message = Data.EDITABLE_MESSAGES[field]
	return ns.db and ns.db.global[message.scope], message.key
end

-- What a whisper goes out with: the player's own text, or the chosen language's default while they haven't edited it.
function ns.GetMessageText(field)
	local settings, key = MessageSettings(field)
	local saved = settings and settings[key]
	if saved == nil then
		return ns.GetDefaultMessage(field)
	end
	return saved
end

--[[
    Saves a whisper's text, trimmed. Nil, or the chosen language's default,
    clears it, so it follows the language from then on; an empty string is
    kept, and sends nothing.
]]
function ns.SetMessageText(field, text)
	local settings, key = MessageSettings(field)
	if not settings then
		return
	end
	if text ~= nil then
		text = text:match("^%s*(.-)%s*$")
	end
	if text == ns.GetDefaultMessage(field) then
		text = nil
	end
	settings[key] = text
end

--[[
    Switches the language whispers go out in. A whisper still holding the old
    language's default follows to the new one; text the player wrote is never
    replaced.
]]
function ns.SetMessageLanguage(locale)
	if not ns.db or not languageByLocale[locale] then
		return
	end
	local current = ns.GetMessageLanguage()
	for field in pairs(Data.EDITABLE_MESSAGES) do
		local settings, key = MessageSettings(field)
		if settings and settings[key] == ns.GetDefaultMessage(field, current) then
			settings[key] = nil
		end
	end
	ns.db.global.messageLanguage = locale
end
