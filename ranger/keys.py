from ranger.api.keys import *

map = global_keys = KeyMapWithDirections()

map = keymanager.get_context('browser')
map('.', fm.tab_move(1))
map(',', fm.tab_move(-1))


map('gs', fm.cd('/sun/'))
map('gd', fm.cd('/sun/open'))
map('gd', fm.cd('/sun/desktop'))
map('gt', fm.cd('/tmp'))
