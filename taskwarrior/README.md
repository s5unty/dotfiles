1. client$ gpg -d ca.cert.pem.gpg > ca.cert.pem
4. client$ scp -a taskd du1abadd.org:~/taskd/
2. client$ cp -a taskrc ~/.taskrc
3. client$ cp -a task ~/.task
5. client$ task sync init

more: http://taskwarrior.org/docs/taskserver/setup.html
