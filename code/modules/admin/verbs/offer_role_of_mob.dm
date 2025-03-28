/client/proc/cmd_offer_to_ghosts_to_be_somebody(mob/living/M as mob in GLOB.mob_list)
	set category = "Special Verbs"
	set name = "Offer Ghost To Become This"

	if(!holder)
		to_chat(src, "Только администратор может использовать эту команду.")
		return
	if(!istype(M))
		alert("Нельзя предложить 'неживого' моба.")
		return
	if(M.check_have_client())
		alert("Невозможно предложить уже занятого моба.")
		return

	if(alert("Вы уверены?", "Confirm", "Да", "Нет") == "Да")
		for(var/mob/abstract/ghost/observer/C in GLOB.player_list)
			spawn(0)
				switch(alert(C, "Вам предложили вселиться в [M], вы согласны?", "Offer", "Да", "Нет"))
					if("Да")
						if(M?.check_have_client())
							alert(C, "Извините, но вы опоздали, кто-то ответил на запрос быстрее вас.")
						else if(M)
							M.ckey = C.ckey
							M.resting = 0
							tgui_windows.Remove()
							init_verbs()
