---
id: "{{id}}"
journal: job
journal-start-date: {{format-date (date "this monday") "%Y-%m-%d"}}
journal-end-date: {{format-date (date "this sunday") "%Y-%m-%d"}}
journal-section: week
---

# {{sh 'date -d "this friday" +"%m/%d(%a)"'}}

##

# {{sh 'date -d "this thursday" +"%m/%d(%a)"'}}

##

# {{sh 'date -d "this wednesday" +"%m/%d(%a)"'}}

##

# {{sh 'date -d "this tuesday" +"%m/%d(%a)"'}}

##

# {{sh 'date -d "this monday" +"%m/%d(%a)"'}}

##

