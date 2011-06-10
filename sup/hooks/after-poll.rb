notify_cmd="/sun/.task/notify-wm "
if num>=1
    notify_body = ''
    from_and_subj.each { |f,s| notify_body << "#{f} : #{s}" }
    system "#{notify_cmd} '<(￣3￣)> You have new unread mail'"
# else # just for test
#       system "#{notify_cmd} 'sup status No new email (yet)'"
#       print "\a"
end   
