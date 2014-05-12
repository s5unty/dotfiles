#!/usr/bin/env python
#
# Copyright (C) 2008-2011 W. Trevor King
# Copyright (C) 2012 Wade Berrier
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

"""LDAP address searches for Mutt.

Add :file:`mutt-ldap.py` to your ``PATH`` and add the following line
to your :file:`.muttrc`::

set query_command = "mutt-ldap.py '%s'"

Search for addresses with `^t`, optionally after typing part of the
name. Configure your connection by creating :file:`~/.mutt-ldap.rc`
contaning something like::

[connection]
server = myserver.example.net
basedn = ou=people,dc=example,dc=net

See the `CONFIG` options for other available settings.
"""

import email.utils
import itertools
import os.path
import ConfigParser
import pickle

import ldap
import ldap.sasl


CONFIG = ConfigParser.SafeConfigParser()
CONFIG.add_section('connection')
CONFIG.set('connection', 'server', 'domaincontroller.yourdomain.com')
CONFIG.set('connection', 'port', '389') # set to 636 for default over SSL
CONFIG.set('connection', 'ssl', 'no')
CONFIG.set('connection', 'starttls', 'no')
CONFIG.set('connection', 'basedn', 'ou=x co.,dc=example,dc=net')
CONFIG.add_section('auth')
CONFIG.set('auth', 'user', '')
CONFIG.set('auth', 'password', '')
CONFIG.set('auth', 'gssapi', 'no')
CONFIG.add_section('query')
CONFIG.set('query', 'filter', '') # only match entries according to this filter
CONFIG.set('query', 'search_fields', 'cn uid mail') # fields to wildcard search
CONFIG.add_section('results')
CONFIG.set('results', 'optional_column', '') # mutt can display one optional column
CONFIG.add_section('cache')
CONFIG.set('cache', 'enable', 'yes') # enable caching by default
CONFIG.set('cache', 'path', '~/.mutt-ldap.cache') # cache results here
#CONFIG.set('cache', 'longevity_days', '14') # TODO: cache results for 14 days by default
CONFIG.read(os.path.expanduser('~/.mutt-ldap.rc'))

def connect():
    protocol = 'ldap'
    if CONFIG.getboolean('connection', 'ssl'):
        protocol = 'ldaps'
    url = '%s://%s:%s' % (
        protocol,
        CONFIG.get('connection', 'server'),
        CONFIG.get('connection', 'port'))
    connection = ldap.initialize(url)
    if CONFIG.getboolean('connection', 'starttls') and protocol == 'ldap':
        connection.start_tls_s()
    if CONFIG.getboolean('auth', 'gssapi'):
        sasl = ldap.sasl.gssapi()
        connection.sasl_interactive_bind_s('', sasl)
    else:
        connection.bind(
            CONFIG.get('auth', 'user'),
            CONFIG.get('auth', 'password'),
            ldap.AUTH_SIMPLE)
    return connection

def search(query, connection):
      post = ''
      if query:
          post = '*'
      filterstr = '(|%s)' % (
          u' '.join([u'(%s=*%s%s)' % (field, query, post)
                     for field in CONFIG.get('query', 'search_fields').split()]))
      filter = CONFIG.get('query', 'filter')
      if filter:
          filterstr = u'(&(%s)%s)' % (filter, filterstr)
      msg_id = connection.search(
          CONFIG.get('connection', 'basedn'),
          ldap.SCOPE_SUBTREE,
          filterstr.encode('utf-8'))
      return msg_id

def format_columns(address, data):
    yield address
    for c in ['cn'] + [CONFIG.get('results', 'optional_column')]:
        if c in data:
            yield data[c][-1]

def format_entry(entry):
    cn,data = entry
    if 'mail' in data:
        for m in data['mail']:
            # Format: tab separated columns
            # http://www.mutt.org/doc/manual/manual.html#toc4.5
            yield "\t".join(format_columns(m, data))

def cache_filename(query):
    # TODO: is the query filename safe?
    return os.path.expanduser(CONFIG.get('cache', 'path')) + os.sep + query

def settings_match(serialized_settings):
    """Check to make sure the settings are the same for this cache"""
    return pickle.dumps(CONFIG) == serialized_settings

def cache_lookup(query):
    hit = False
    addresses = []
    if CONFIG.get('cache', 'enable') == 'yes':
        cache_file = cache_filename(query)
        cache_dir = os.path.dirname(cache_file)
        if not os.path.exists(cache_dir): os.mkdir(cache_dir)

        # TODO: validate longevity setting

        if os.path.exists(cache_file):
            cache_info = pickle.loads(open(cache_file).read())
            if settings_match(cache_info['settings']):
                hit = True
                addresses = cache_info['addresses']

    # DEBUG
    #print "Cache hit?: " + str(hit)
    return hit, addresses

def cache_persist(query, addresses):
    cache_info = {
        'settings': pickle.dumps(CONFIG),
        'addresses': addresses
        }
    fd = open(cache_filename(query), 'w')
    pickle.dump(cache_info, fd)
    fd.close()

if __name__ == '__main__':
    import sys

    if len(sys.argv) < 2:
        sys.stderr.write('%s: no search string given\n' % sys.argv[0])
        sys.exit(1)

    query = unicode(' '.join(sys.argv[1:]), 'utf-8')

    (cache_hit, addresses) = cache_lookup(query)

    if not cache_hit:
        connection = connect()
        msg_id = search(query, connection)

        # wacky, but allows partial results
        while True:
            try:
                res_type, res_data = connection.result(msg_id, 0)
            except ldap.ADMINLIMIT_EXCEEDED:
                #print "Partial results"
                break
            # last result will have this set
            if res_type == ldap.RES_SEARCH_RESULT:
                break

            addresses += [entry for entry in format_entry(res_data[-1])]

        # Cache results for next lookup
        cache_persist(query, addresses)

    print '%d addresses found:' % len(addresses)
    print '\n'.join(addresses)
