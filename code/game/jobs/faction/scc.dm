/datum/faction/scc
	name = "Stellar Corporate Conglomerate"
	description = {"<p><meta charset=\"UTF-8\">
	Звёздный корпоративный конгломерат (ЗКК) был образован на пике могущества корпораций в галактике,
	первоначально для защиты активов Тау-Кита во время Второго Соларианского вторжения.
	Теперь 'ЗКК' занимает неоспоримое экономическое господство над рукавом Ориона,
	и теперь желает оттеснить все вышестоящие инстанции, стоящие перед ним.
	Сотрудничество стало необходимым с тех пор, как появились 'Einstein Engines' в связи с появлением варп-перемещений.
	Они сохранили свой шаткий мир благодаря 'NanoTrasen', став их марионетками, исполняющими прихоти семьи Трэйзен.
	Конечно, это не остановит их жажду власти и славы - в конце концов, они всего лишь корпорации.
	</p>"}
	departments = {"Command<br>Equipment"}
	title_suffix = "SCC"

	allowed_role_types = SCC_ROLES

	allowed_species_types = list(
		/datum/species/human,
		/datum/species/skrell,
		/datum/species/tajaran,
		/datum/species/unathi,
		/datum/species/diona,
		/datum/species/machine
	)

	job_species_blacklist = list(
		"Corporate Liaison" = list(
			SPECIES_TAJARA,
			SPECIES_TAJARA_MSAI,
			SPECIES_TAJARA_ZHAN,
			SPECIES_DIONA,
			SPECIES_DIONA_COEUS,
			SPECIES_VAURCA_WORKER,
			SPECIES_VAURCA_WARRIOR,
			SPECIES_UNATHI,
			SPECIES_IPC,
			SPECIES_IPC_G1,
			SPECIES_IPC_G2,
			SPECIES_IPC_XION,
			SPECIES_IPC_ZENGHU,
			SPECIES_IPC_BISHOP,
			SPECIES_IPC_SHELL,
		)
	)
