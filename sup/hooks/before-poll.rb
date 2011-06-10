if (@last_fetchmail_time || Time.at(0)) < Time.now - 60
  say "Running fetchmail..."
  system "fetchmail > /dev/null 2>&1"
  say "Done running fetchmail."
end
@last_fetchmail_time = Time.now
