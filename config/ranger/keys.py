from ranger.api.keys import *

map = global_keys = KeyMapWithDirections()

map = keymanager.get_context('browser')
map('.', fm.tab_move(1))
map(',', fm.tab_move(-1))

map('<C-q>', fm.exit())
map('~', fm.cd('~'))
map('!', fm.open_console('shell -w '))
