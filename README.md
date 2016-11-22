# MI-VMM
Picture similarity retrieval with SURF

=======
## This is semestral project for subject MI-VMM@FIT-CTU
It contains 2 main parts:
* Interest points finder (folder ipfinder)
* IP matching & Web app (folder ipmatching)
 * Ruby on Rails app
 * This app will call ipfinder on every upload in order to get Interest Points for new pictures.
 
## How to run
1. Interest point finder
```sh
$ java -jar "ipfinder/dist/semestralka.jar" file1 file2 ...
```

2. Web app
 1. Rails installation (gems, ...)
 2. Run rails server
```sh
$ cd ipmatching
$ rails server
```
