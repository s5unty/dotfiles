---
id: "{{id}}"
journal: job
journal-start-date: {{sh 'date -d "last monday" +"%Y-%m-%d"'}}
journal-end-date: {{sh 'date -d "this sunday" +"%Y-%m-%d"'}}
journal-section: week
---

# {{sh 'date -d "friday" +"%m/%d(%a)"'}}

##

# {{sh 'date -d "thursday" +"%m/%d(%a)"'}}

##

# {{sh 'date -d "wednesday" +"%m/%d(%a)"'}}

##

# {{sh 'date -d "tuesday" +"%m/%d(%a)"'}}

##

# {{sh 'date -d "last monday" +"%m/%d(%a)"'}}

##

