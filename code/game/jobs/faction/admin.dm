/datum/faction/admin
	name = "Admin Jobs"
	description = {"<p><meta charset=\"UTF-8\">
	Эта фракция предназначена для IC вмешательства в раунд со стороны администрации.
	</p>"}

	departments = {"Command"}
	title_suffix = "SCC"

	allowed_role_types = ADMIN_ROLES

	allowed_species_types = list(
		/datum/species/human,
		/datum/species/skrell
	)

/datum/faction/admin/is_visible(var/mob/user)
	return check_rights(R_CCIAA, FALSE, user)
