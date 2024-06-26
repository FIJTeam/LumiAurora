/mob/living/proc/handle_autohiss(message, datum/language/L)
	return message // no autohiss at this level

/mob/living/carbon/human/handle_autohiss(message, datum/language/L)
	if(!client || client.autohiss_mode == AUTOHISS_OFF) // no need to process if there's no client or they have autohiss off
		return message
	return species.handle_autohiss(message, L, client.autohiss_mode)

/client
	var/autohiss_mode = AUTOHISS_OFF

/client/verb/toggle_autohiss()
	set name = "Toggle Auto-Hiss"
	set desc = "Toggle automatic hissing as Unathi, r-rolling as Taj, buzzing as Vaurca, or beakmouth-speech as Skrell."
	set category = "OOC"

	autohiss_mode = (autohiss_mode + 1) % AUTOHISS_NUM
	switch(autohiss_mode)
		if(AUTOHISS_OFF)
			to_chat(src, "Auto-hiss is now OFF.")
		if(AUTOHISS_BASIC)
			to_chat(src, "Auto-hiss is now BASIC.")
		if(AUTOHISS_FULL)
			to_chat(src, "Auto-hiss is now FULL.")
		else
			soft_assert(0, "invalid autohiss value [autohiss_mode]")
			autohiss_mode = AUTOHISS_OFF
			to_chat(src, "Auto-hiss is now OFF.")

/datum/species
	var/has_autohiss = FALSE
	var/list/autohiss_basic_map = null
	var/list/autohiss_extra_map = null
	var/list/autohiss_exempt = null
	var/list/autohiss_basic_extend = null
	var/list/autohiss_extra_extend = null
	var/autohiss_extender = "..."
	var/ignore_subsequent = FALSE

/datum/species/unathi
	autohiss_basic_map = list(
			"s" = list("ss", "sss", "ssss"),
			"с" = list("сс", "ссс", "сссс")
		)
	autohiss_extra_map = list(
			"x" = list("ks", "kss", "ksss"),
			"ш" = list("шш", "шшш", "шшшш"),
			"ч" = list("щ", "щщ", "щщщ")
		)
	autohiss_exempt = list(
			LANGUAGE_UNATHI,
			LANGUAGE_AZAZIBA
		)

/datum/species/tajaran
	autohiss_basic_map = list(
			"r" = list("rr", "rrr", "rrrr"),
			"р" = list("рр", "ррр", "рррр")
		)
	autohiss_exempt = list(
			LANGUAGE_SIIK_MAAS,
			LANGUAGE_SIIK_TAJR,
			LANGUAGE_SIGN_TAJARA,
			LANGUAGE_YA_SSA,
			LANGUAGE_DELVAHII
		)

/datum/species/skrell
	autohiss_basic_map = list(
			"s" = list("sch", "ssch"),
			"с" = list("щ", "щщ")
		)
	autohiss_extra_map = list(
			"x" = list("ksch", "kssch"),
			"кс" = list("кщ", "кщщ")
		)
	autohiss_exempt = list(LANGUAGE_SKRELLIAN)
	ignore_subsequent = TRUE

/datum/species/bug
	autohiss_basic_map = list(
			"f" = list("v","vh"),
			"ph" = list("v", "vh"),
			"ф" = list("в", "вх"),
			"пх" = list("в", "вх")
		)
	autohiss_extra_map = list(
			"s" = list("z", "zz", "zzz"),
			"ce" = list("z", "zz"),
			"ci" = list("z", "zz"),
			"v" = list("vv", "vvv"),
			"с" = list("з", "зз", "ззз"),
			"се" = list("з", "зз"),
			"си" = list("з", "зз"),
			"в" = list("вв", "ввв")
		)
	autohiss_exempt = list(LANGUAGE_VAURCA)

/datum/species/bug/type_b
	autohiss_basic_map = list(
			"f" = list("v","vh"),
			"ph" = list("v", "vh"),
			"ф" = list("в", "вх"),
			"пх" = list("в", "вх")
		)
	autohiss_extra_map = list(
			"s" = list("z", "zz", "zzz"),
			"ce" = list("z", "zz"),
			"ci" = list("z", "zz"),
			"v" = list("vv", "vvv"),
			"с" = list("з", "зз", "ззз"),
			"се" = list("з", "зз"),
			"си" = list("з", "зз"),
			"в" = list("вв", "ввв")
		)
	autohiss_exempt = list(LANGUAGE_VAURCA)

/datum/species/diona

	autohiss_basic_extend = list("who","what","when","where","why","how")
	autohiss_extra_extend = list("i'm","i","am","this","they","are","they're","their","his","her","their","the","he","she")
	autohiss_extender = "..."

	autohiss_basic_map = list(
			"s" = list("s","ss","sss"),
			"z" = list("z","zz","zzz"),
			"ee" = list("ee","eee"),
			"с" = list("с", "сс", "ссс"),
			"з" = list("з", "зз", "ззз"),
			"и" = list("и", "ии")
		)
	autohiss_extra_map = list(
			"a" = list("a","aa", "aaa"),
			"i" = list("i","ii", "iii"),
			"o" = list("o","oo", "ooo"),
			"u" = list("u","uu", "uuu"),
			"а" = list("а", "аа", "ааа"),
			"и" = list("и", "ии", "иии"),
			"о" = list("о", "оо", "ооо"),
			"у" = list("у", "уу", "ууу")
		)
	autohiss_exempt = list(
			LANGUAGE_ROOTSONG
		)

/datum/species/proc/handle_autohiss(message, datum/language/lang, mode)
	if (!autohiss_basic_map || !autohiss_basic_map.len)
		return message

	if(autohiss_exempt && (lang.name in autohiss_exempt))
		return message
	// No reason to auto-hiss in sign-language.
	if (lang.flags && (lang.flags & SIGNLANG))
		return message

	if(autohiss_extender && autohiss_basic_extend)
		var/longwords = autohiss_basic_extend.Copy()
		if(mode == AUTOHISS_FULL && autohiss_extra_extend)
			longwords |= autohiss_extra_extend

		var/list/returninglist = list()

		for(var/word in text2list(message," ")) // For each word in a message
			if (lowertext(word) in longwords)
				word += autohiss_extender
			returninglist += word
		message = returninglist.Join(" ")

	if (autohiss_basic_map)
		var/map = autohiss_basic_map.Copy()
		if(mode == AUTOHISS_FULL && autohiss_extra_map)
			map |= autohiss_extra_map

		. = list()

		while(length_char(message))
			var/min_index = 10000 // if the message is longer than this, the autohiss is the least of your problems
			var/min_char = null
			for(var/char in map)
				var/i = findtext_char(message, char)
				if(!i) // no more of this character anywhere in the string, don't even bother searching next time
					map -= char
				else if(i < min_index)
					min_index = i
					min_char = char
			if(!min_char) // we didn't find any of the mapping characters
				. += message
				break
			. += copytext_char(message, 1, min_index)
			if(copytext_char(message, min_index, min_index+1) == uppertext(min_char))
				switch(text2ascii(message, min_index+1))
					if(65 to 90) // A-Z, uppercase; uppercase R/S followed by another uppercase letter, uppercase the entire replacement string
						. += uppertext(pick(map[min_char]))
					else
						. += capitalize(pick(map[min_char]))
			else
				. += pick(map[min_char])
			if(ignore_subsequent && lowertext(copytext_char(message, min_index, min_index+1)) == lowertext(copytext(message, min_index+1, min_index+2)))
				message = copytext_char(message, min_index + 2) // If the current letter and the subsequent letter are the same, skip the subsequent letter
			else
				message = copytext_char(message, min_index + 1)

	return jointext(., "")

#undef AUTOHISS_OFF
#undef AUTOHISS_BASIC
#undef AUTOHISS_FULL
#undef AUTOHISS_NUM
