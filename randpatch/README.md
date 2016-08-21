# Random Override Patch
GPG uses `/dev/random` to provide random data when generating keys. Thing is, this makes it take significantly longer to do this than it needs to be. This is a small library that redirects all requests going to `/dev/random` and sends them to `/dev/urandom`. **This does not make GPG any less secure.** Urandom is only more secure when using information theoretic secure algorithms, which GPG is not.

##Compiling
To compile, simply run:
    gcc -O -Wall -fPIC -shared -o randpatch.so randpatch.c -ldl
