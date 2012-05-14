'''
Created on Mar 5, 2009

@author: Keith Lawless (keith at keithlawless dot com)

    Copyright 2009 Keith Lawless
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

'''
from os.path import abspath, exists, join
from os import pathsep, getenv
import cPickle
import os.path
import os
import shutil
import sys
import time

from optparse import OptionParser


#
# Define some exceptions that our application can raise. These are used
# to exit the program gracefully, and control the error message displayed
# to the user when the program exits.
#

class PunchCommandError(ValueError):
    """Used to indicate that an invalid command was passed to Punch"""

    
class ToDoConfigNotFoundError(IOError):
    """Used to indicate that todo.cfg was not found on the path"""

    
class ToDoFileNotFoundError(IOError):
    """Used to indicate that todo.txt was not found on the path"""


class TaskFileNotFoundError(IOError):
    """Used to indicate that the user specified task file was not found"""

    
class TaskNotFoundError(IOError):
    """Used to indicate that the task number specified does not exist in the task file"""

class NoOpenTaskError(IOError):
    """Used to indicate that an 'out' command was issued, but the last task was already closed out."""
   
class DateFormatError(IOError):
    """Used to indicate that a poorly formatted date was passed where a date was expected."""
     
class Punch(object):

    timestampFormat = '%Y%m%dT%H%M%S'
    
    def __init__(self, optlist, args):
        self.optlist = optlist
        self.args = args
        
    def execute(self):
        """Execute the command - either 'in' or 'out'"""
        if( self.args[0] == 'in' ):
            self.execute_in()
        elif( self.args[0] == 'out' ):
            self.execute_out()
        elif( self.args[0] in ['wh','what'] ):
            self.execute_wh()
        elif( self.args[0] in ['report', 'rep'] ):
            self.execute_rep()
        elif( self.args[0] in ['archive', 'ar'] ):
            self.execute_ar()
        else:
            raise PunchCommandError
        
    def search_file(self, files, paths):
        file_found = 0
        for filename in files:
            for path in paths:
                if path != None:
                    if exists(join(path, filename)):
                        file_found = 1
                        break
            if file_found:
                break
        if file_found:
            return abspath(join(path, filename))
        else:
           return None
       
    def parse_config(self):
        """Parse the user's todo.cfg file and place the elements into a dictionary"""
        try:
            paths = [ getenv("HOME"), "."]
            files = [ "todo.cfg", ".todo.cfg" ]
	    if getenv("TODOTXT_CFG_FILE") == None:
                configFileName = self.search_file(files, paths)
            else:
                configFileName = getenv("TODOTXT_CFG_FILE")
            if configFileName == None:
                raise ToDoConfigNotFoundError
            configFile = open( configFileName )
            self.propDict = dict()
            for propLine in configFile:
                propDef = propLine.strip()
                if len(propDef) == 0:
                    continue
                if propDef[0] in ( '#' ):
                    continue
                if propDef[0:6] == 'export':
                     propDef = propDef[7:]
                punctuation = [ propDef.find(c) for c in '= ' ] + [ len(propDef) ]
                found = min( [ pos for pos in punctuation if pos != -1 ] )
                name= propDef[:found].rstrip()
                value= propDef[found:].lstrip(":= ").rstrip()
                self.propDict[name]= value.strip('"')
            configFile.close()
            
            # Add the users environment variables to the propDict, unless
            # a value has already been set.
            for key in os.environ.keys():
                if self.propDict.has_key(key) == False:
                    self.propDict[key] = os.environ[key]
             
        except IOError:
            raise ToDoConfigNotFoundError    

    def resolve(self,value):
        """Replace variables in a config entry with the actual value."""
        token = value.find('$')
        if( token != -1 ):
            terminus = token + value[token:].find('/')
            ref = value[token+1:terminus]
            refValue = self.propDict[ref]
            value = refValue + value[terminus:]
            
        return value
    
    def open_todo(self):
        """Open the user's todo.txt file."""
        try:
            print self.resolve( self.propDict['TODO_FILE'])
            self.taskFile = open( self.resolve( self.propDict['TODO_FILE']), 'U' )
        except IOError:
            raise ToDoFileNotFoundError
                
    def open_file(self,filename):
        """Open a file given a filename.""" 
        try:
            name = self.resolve( self.propDict['TODO_DIR'] + "/" + filename )
            self.taskFile = open( name, 'U' )
        except IOError:
            raise TaskFileNotFoundError
        
    def close_task_file(self):
        """Close the file taskFile - either todo.txt or a user supplied file."""
        self.taskFile.close()
            
    def open_punch_file(self,mode='a'):
        """Open the output file - punch.dat - in the user's TODO_DIR."""
        name = self.resolve( self.propDict['TODO_DIR'] + "/punch.dat" )
        
        if not os.path.exists(name):
            open( name, 'w' ).close()
             
        self.punchFile = open( name, mode )
        
    def close_punch_file(self):
        """Close the output file - punch.csv."""
        self.punchFile.close()
    
    def open_punch_backup_file(self):
        """Open the backup file - punch.dat.backup - in the user's TODO_DIR."""
        name = self.resolve( self.propDict['TODO_DIR'] + "/punch.dat.backup" )
        self.backupFile = open( name, 'w' )
                
    def close_punch_backup_file(self):
        """Close the output file - punch.csv."""
        self.backupFile.close()
        
    def backup_punch_file(self):
        self.open_punch_file('r')
        self.open_punch_backup_file()
        shutil.copyfileobj(self.punchFile,self.backupFile)
        self.close_punch_backup_file()
        self.close_punch_file()

    def open_archive_file(self,mode='a'):
        """Open the archive file - punch.archive - in the user's TODO_DIR."""
        name = self.resolve( self.propDict['TODO_DIR'] + "/punch.archive" )
        self.archiveFile = open( name, mode )
        
    def close_archive_file(self):
        """Close the archive file - punch.archive."""
        self.archiveFile.close()
        
    def get_last_punch_rec(self):
        """Returns last line in the output file as a list of fields."""
        lastrec = []
        try:
            self.open_punch_file('r')
            lines = self.punchFile.readlines()
            if( len(lines) > 0):
                lastline = (lines[len(lines)-1]).strip()
                lastrec = lastline.split('\t')
            else:
                lastrec = []
            self.close_punch_file()
        except IOError:
            lastrec = []
       
        return lastrec

    def punch_rec_complete(self,rec):
        """Returns true if the punch record is complete - that
        is, contains a task, start timestamp, and end timestamp"""
         
        if len(rec) == 0:
            isComplete = True
        elif len(rec) == 3:
            isComplete = True
        else:
            isComplete = False
        
        return isComplete

    def last_punch_line_complete(self):
        lastrec = self.get_last_punch_rec()
        return self.punch_rec_complete(lastrec)
                      
    def get_time(self):
        return time.strftime( self.timestampFormat, time.localtime())
          
    def translate_time_to_secs(self,timestamp):
        return time.strptime( timestamp[0:15], self.timestampFormat )
    
    def get_duration(self,startTimestamp,endTimestamp):
        minutes = self.get_duration_in_minutes(startTimestamp, endTimestamp)
        return self.format_minutes(minutes)
        
    def get_duration_in_minutes(self,startTimestamp,endTimestamp):
        start = self.translate_time_to_secs( startTimestamp )
        end = self.translate_time_to_secs( endTimestamp )
        
        minutes = ( time.mktime(end) - time.mktime(start) ) // 60
        
        return minutes

    def format_minutes(self,minutes):
        retString = '('
        
        if( minutes > 60 ):
            hours = minutes // 60
            minutes = minutes - (hours * 60)
            retString = retString + str(int(hours)) + ' hours '
            
        retString = retString + str(int(minutes)) + ' minutes)'

        return retString
        
        
    def add_literal_line(self,line):
        """
        Add a new line to punch.dat containing task,start-timestamp<eol>
        where task is a literal string (usually in the format '+project').
        """
        
        # If previous output line wasn't closed by issuing an 'out' command, then
        # do so now.
        if self.last_punch_line_complete() == False:
            self.add_out_line()
             
        rec = '%s\t%s' % (line, self.get_time())
        self.open_punch_file()
        self.punchFile.write(rec)
        self.close_punch_file()
        print "Start timer on: " + line
        
    def add_in_line(self,line_num):
        """
        Add a new line to punch.csv containing task,start-timestamp<eol>
        where task is line 'line_num' from self.taskFile
        """
        
        # If previous output line wasn't closed by issuing an 'out' command, then
        # do so now.
        if self.last_punch_line_complete() == False:
            self.add_out_line()
        
        lines = self.taskFile.readlines()
        if( line_num > len(lines)):
            raise TaskNotFoundError
        line = lines[line_num-1].strip()        
        rec = '%s\t%s' % (line, self.get_time())
        self.open_punch_file()
        self.punchFile.write(rec)
        self.close_punch_file()
        print "Start timer on: " + line
        
    def add_out_line(self):
        """
        Add the 'out' timestamp to the last line of the file
        and append the EOL.
        """
        
        # If last output line was already closed by issuing an 'out' command, then
        # raise an exception.
        lastrec = self.get_last_punch_rec()
        if self.punch_rec_complete(lastrec):
            raise NoOpenTaskError
              
        rec = '\t%s\n' % self.get_time()
        
        self.open_punch_file()
        self.punchFile.write(rec)
        self.close_punch_file()
        
        print "Stop timer on: " + lastrec[0]  
        
    def execute_in(self):
        """The logic for the 'in' command."""
        self.parse_config()
        
        """If only argument is passed, then it is an error."""
        if( len(self.args) == 1 ):
            raise PunchCommandError
        
        """
        If only two arguments are passed, then there are three possibilities: 
        (1) An integer was passed, referencing a line in todo.txt (ie. punch in 7)
        (2) A project name was passed, using the special '+project-name' syntax
        (3) The user made a mistake.
        """
        if( len(self.args) == 2 ):
            # Check to see if the argument is number.
            try:
                line_num = int(self.args[1])
            except:
                line_num = -1
            
            if( line_num > -1 ):
                self.open_todo()
                self.add_in_line(line_num)
                self.close_task_file()
            else:
                project = self.args[1].strip()
                if( project[0] == '+' ):
                    self.add_literal_line(project)
                else:
                    raise PunchCommandError
                
        """
        If three arguments are passed, then the last argument must be a task file (eg. projects.txt)
        """
        if( len(self.args) == 3):
            # Check to see if the argument is number.
            try:
                line_num = int(self.args[1])
            except:
                line_num = -1
            
            if( line_num > -1 ):
                self.open_file(self.args[2])
                self.add_in_line(line_num)
                self.close_task_file()
            else:
                raise PunchCommandError
        
    def execute_out(self):
        """The logic for the 'out' command."""
        self.parse_config()
        if( len(self.args) == 1 ):
            self.add_out_line()
        else:
            raise PunchCommandError       

    def execute_wh(self):
        """The logic for the 'what' command."""
        self.parse_config()
        if( len(self.args) == 1 ):
            lastrec = self.get_last_punch_rec()
            if( len(lastrec) == 2 ):
                duration = self.get_duration(lastrec[1], self.get_time())
                print "Active task: " + lastrec[0] + ' ' + duration
            else:
                print "No task is active."
        else:
            raise PunchCommandError       
    
    def execute_rep(self):
        """The logic for the 'report' command."""
        self.parse_config()
        if( len(self.args) == 1 ):
            dateDict = dict()
            totalTimeDict = dict()
            self.open_punch_file('r')
            lines = self.punchFile.readlines()
            
            if( len(lines) == 0 ):
                print "There are no tasks in the data file."
            else:
                for line in lines:
                    rec = line.split('\t')
                    if( len(rec) == 3 ):
                        task = rec[0]
                        start = rec[1]
                        end = rec[2]
                        duration = self.get_duration_in_minutes(start,end)
                        dateKey = time.strftime( '%Y%m%d', self.translate_time_to_secs(start))
                        
                        # Create a tree of dates that have time reported against them
                        if( dateKey in dateDict.keys()):
                            dateValue = dateDict[dateKey]
                        else:
                            dateValue = dict()
                        
                        # Create a simple dictionary of total elapsed time per date 
                        if( dateKey in totalTimeDict.keys()):
                            totalTimeValue = int(totalTimeDict[dateKey])
                        else:
                            totalTimeValue = 0
                        
                        # For each date in the tree, store a subtree with 
                        # unique tasks for the date
                        if( task in dateValue.keys()):
                            timeList = dateValue[task]
                        else:
                            timeList = list()
                        
                        # Populate the tree nodes.
                        timeList.append(duration)
                        dateValue[task] = timeList
                        dateDict[dateKey] = dateValue
                        
                        # Store total elapsed time for the entire date.
                        totalTimeValue = totalTimeValue + duration
                        totalTimeDict[dateKey] = totalTimeValue
                
                # Returned keys are untyped. Copy into a list of strings so we can sort.
                dateNoneList = dateDict.keys()
                dateList = list()
                for dateThing in dateNoneList:
                    dateList.append(str(dateThing))
                dateList.sort()
                
                for dateKey in dateList:
                    print dateKey[0:4] + '-' + dateKey[4:6] + '-' + dateKey[6:] + ' ' + self.format_minutes(totalTimeDict[dateKey]) +':' 
                    taskDict = dateDict[dateKey]
                    taskNoneList = taskDict.keys()
                    taskList = list()
                    for taskThing in taskNoneList:
                        taskList.append(str(taskThing))
                    taskList.sort()
                    for taskKey in taskList:
                        minuteList = taskDict[taskKey]
                        sum = 0.0
                        for m in minuteList:
                            sum = sum + m
                        print '\t' + taskKey + ' ' + self.format_minutes(sum)
            # Giant else statement ends here. :)
                    
            self.close_punch_file()
        else:
            raise PunchCommandError

    def execute_ar(self):
        """The logic for the 'archive' command."""
        self.parse_config()
        if( len(self.args) == 2 ):
            #Make sure date argument can be parsed into a date
            #in the past.
            try:
                archiveTs = args[1] + "T23:59:59"
                archiveDate = time.strptime( archiveTs, '%Y-%m-%dT%H:%M:%S' )
                archiveTime = time.mktime( archiveDate )
            except:
                raise DateFormatError
                
            #Back up the punch file
            self.backup_punch_file()
            
            #Read the punch file into memory
            self.open_punch_file('r')
            lines = self.punchFile.readlines()
            self.close_punch_file()
            
            #Open the archive file in append mode
            self.open_archive_file()
            
            #Open the punch file in (destructive) write mode
            self.open_punch_file('w')
            
            #Iterate through tasks in memory, either writing to the
            #archive file or the (new) punch file, based on start timestamp
            for line in lines:
                rec = line.split('\t')
                if( self.punch_rec_complete(rec)):
                    startTime = time.mktime( time.strptime( rec[1], self.timestampFormat ))
                    if( startTime < archiveTime ):
                        self.archiveFile.write(line)
                    else:
                        self.punchFile.write(line)
                else:
                    self.punchFile.write(line)
            
            #Close the files.
            self.close_punch_file()
            self.close_archive_file()
            
        else:
            raise PunchCommandError
            
#
# The entry point for the script.
#

if __name__ == '__main__':
    try:
        usage = \
"""
Punch.py [-h] command [line-number] [filename] [archive-date]
        
  Commands:
  'in' : start the timer for a todo task [line-number]
  'out' : stop the timer for the current task
  'what' : print the current 'active' task. shortcut is 'wh'
  'report' : print a report. shortcut is 'rep'
  'archive' : archive all time records previous to [archive-date] inclusive
        
  line-number is the number of the item in the todo.txt file (or filename)
"""
        
        version = \
"""
  Punch.py - A time tracker for todo.sh
  Version 1.2
  Author: Keith Lawless (keith@keithlawless.com)
  Last updated: July 6,2009
  License: GPL, http://www.gnu.org/copyleft/gpl.html
"""
        
        parser = OptionParser(usage=usage,version=version)
        optlist, args = parser.parse_args()

        if (( len(args) < 1 ) or ( len(args) > 3 )):
            raise PunchCommandError
        else:
            punch = Punch(optlist,args)
            punch.execute()
    except PunchCommandError:
        print usage
    except ToDoConfigNotFoundError:
        print "Error: Could not find configuration file (todo.cfg)"
    except ToDoFileNotFoundError:
        print "Error: Could not find todo.txt"
    except TaskFileNotFoundError:
        print "Error: Could not find file."
    except TaskNotFoundError:
        print "Error: Item number not found in file."
    except NoOpenTaskError:
        print "Error: No incomplete task found."
    except DateFormatError:
        print "Error: Could not translate your input into a date."
        
