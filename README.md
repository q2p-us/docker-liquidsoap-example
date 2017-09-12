# liquidsoap example

First of all you need to run any icecast server, for example:
`docker run -p 8000:8000 mtneug/icecast`

Now you can run liquidsoap example. You need to mount `var.liq` file with icecast configuration:
`docker run -v ./var.liq:/home/liquidsoap/radio/var.liq q2pus/liquidsoap-example`