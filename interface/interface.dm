//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki(var/sub_page = null as null|text)
	set name = "wiki"
	set desc = "Visit the wiki."
	set hidden = 1

	if(GLOB.config.wikiurl)
		if(tgui_alert(usr, "This will open the wiki in your browser. Are you sure?", "Wiki", list("Yes", "No")) == "No")
			return

		var/to_open = GLOB.config.wikiurl
		if (sub_page)
			to_open += sub_page

		send_link(src, to_open)
	else
		to_chat(src, SPAN_WARNING("The wiki URL is not set in the server configuration."))

/client/verb/forum()
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = 1
	if(GLOB.config.forumurl)
		if(tgui_alert(usr, "This will open the forum in your browser. Are you sure?", "Forum", list("Yes", "No")) == "No")
			return
		send_link(src, GLOB.config.forumurl)
	else
		to_chat(src, SPAN_WARNING("The forum URL is not set in the server configuration."))
	return

/client/verb/reportbug()
	set name = "reportbug"
	set desc = "Report a bug."
	set hidden = 1

	if(GLOB.config.githuburl)
		if(tgui_alert(usr, "This will open the issue tracker in your browser. Are you sure?", "Issue Tracker", list("Yes", "No")) == "No")
			return
		send_link(src, GLOB.config.githuburl + "/issues")
	else
		to_chat(src, SPAN_WARNING("The issue tracker URL is not set in the server configuration."))
	return

/client/verb/rules()
	set name = "Rules"
	set desc = "Show Server Rules."
	set hidden = 1

	if(GLOB.config.rulesurl)
		if(tgui_alert(usr, "This will open the rules in your browser. Are you sure?", "Rules", list("Yes", "No")) == "No")
			return
		send_link(src, GLOB.config.rulesurl)
	else
		to_chat(src, SPAN_WARNING("The rules URL is not set in the server configuration."))
	return

/client/verb/hotkeys_help()
	set name = "hotkeys-help"
	set category = "OOC"

	var/admin = {"<font color='purple'>
Admin:
\tF5 = Aghost (admin-ghost)
\tF6 = player-panel-new
\tF7 = admin-pm
\tF8 = Invisimin
</font>"}

	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\ta = left
\ts = down
\td = right
\tw = up
\tq = drop
\te = equip
\tr = throw
\tt = say
\t5 = emote
\tx = swap-hand
\tz = activate held object (or y)
\tj = toggle-aiming-mode
\tf = cycle-intents-left
\tg = cycle-intents-right
\t1 = help-intent
\t2 = disarm-intent
\t3 = grab-intent
\t4 = harm-intent
\tCtrl = drag
\tCtrl + W,A,S,D = look around
\tc = stop pull
\tm = me
\tv = face direction
\tShit+B = rest
\tB = resist
\t+ = Move up
\t- = Move down
\t0 = Look Up
\t9 = Look Down
\tl = LOOC
\tu = Whisper
\to = OOC
\tshift+wheelClick = point
\tspace = switch run and walk
\tShift = examine
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = left
\tCtrl+s = down
\tCtrl+d = right
\tCtrl+w = up
\tCtrl+q = drop
\tCtrl+e = equip
\tCtrl+r = throw
\tCtrl+x = swap-hand
\tCtrl+z = activate held object (or Ctrl+y)
\tCtrl+f = cycle-intents-left
\tCtrl+g = cycle-intents-right
\tCtrl+1 = help-intent
\tCtrl+2 = disarm-intent
\tCtrl+3 = grab-intent
\tCtrl+4 = harm-intent
\tF1 = adminhelp
\tF2 = ooc
\tF3 = say
\tF4 = emote
\tDEL = pull
\tINS = cycle-intents-right
\tHOME = drop
\tPGUP = swap-hand
\tPGDN = activate held object
\tEND = throw
</font>"}

	var/robot_hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\ta = left
\ts = down
\td = right
\tw = up
\tq = unequip active module
\tt = say
\tx = cycle active modules
\tz = activate held object (or y)
\tf = cycle-intents-left
\tg = cycle-intents-right
\t1 = activate module 1
\t2 = activate module 2
\t3 = activate module 3
\t4 = toggle intents
\t5 = emote
\tCtrl = drag
\tShift = examine
</font>"}

	var/robot_other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = left
\tCtrl+s = down
\tCtrl+d = right
\tCtrl+w = up
\tCtrl+q = unequip active module
\tCtrl+x = cycle active modules
\tCtrl+z = activate held object (or Ctrl+y)
\tCtrl+f = cycle-intents-left
\tCtrl+g = cycle-intents-right
\tCtrl+1 = activate module 1
\tCtrl+2 = activate module 2
\tCtrl+3 = activate module 3
\tCtrl+4 = toggle intents
\tF1 = adminhelp
\tF2 = ooc
\tF3 = say
\tF4 = emote
\tDEL = pull
\tINS = toggle intents
\tPGUP = cycle active modules
\tPGDN = activate held object
</font>"}

	if(isrobot(src.mob))
		to_chat(src, robot_hotkey_mode)
		to_chat(src, robot_other)
	else
		to_chat(src, hotkey_mode)
		to_chat(src, other)
	if(holder)
		to_chat(src, admin)

/client/verb/open_webint()
	set name = "open_webint"
	set desc = "Visit the web interface."
	set hidden = 1

	if (GLOB.config.webint_url)
		if(tgui_alert(usr, "This will open the Web Interface in your browser. Are you sure?", "Web Interface", list("Yes", "No")) == "No")
			return
		send_link(src, GLOB.config.webint_url)
	else
		to_chat(src, SPAN_WARNING("The web interface URL is not set in the server configuration."))
	return

/client/verb/open_discord()
	set name = "open_discord"
	set desc = "Get a link to the Discord server."
	set hidden = 1

	if (SSdiscord && SSdiscord.active)
		if(tgui_alert(usr, "This will open Discord in your browser. Are you sure?", "Discord", list("Yes", "No")) == "No")
			var/url_link = SSdiscord.retreive_invite()
			if (url_link)
				send_link(src, url_link)
			else
				to_chat(src, SPAN_DANGER("An error occured retreiving the invite."))
	else
		to_chat(src, SPAN_WARNING("The serverside Discord bot is not set up."))
