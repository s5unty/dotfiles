from ranger.defaults.apps import CustomApplications as DefaultApps
from ranger.api.apps import *
class CustomApplications(DefaultApps):
    def app_qiv(self, c):
        f = c.file

        if f.image:
            return self.either(c, 'qiv')

    @depends_on('qiv')
    def app_feh(self, c):
        arg = {1: '-z', 2: '-y', 3: '-x'}

        c.flags += 'd'

        if c.mode in arg: # mode 1, 2 and 3 will set the image as the background
            return tup('qiv', arg[c.mode], c.file.path)
        if c.mode is 11 and len(c.files) is 1: # view all files in the cwd
            images = (f.basename for f in self.fm.env.cwd.files if f.image)
            return tup('qiv', *images)
        return tup('qiv', *c)
