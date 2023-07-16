# cgiluna

## Installing
### Windows
Luna expects to be installed at C:\LUNA

### Linux

## Todo
* [ ] Modules

## Structure

- `luna/`: Main directory
	- `api/`: JSON API for use in clients
	- `libs/`: Where most of the code lives, actually
	- `native/`: Binary natives for libraries and Lua for Windows
	- `scripts/`: CGI scripts used in requests by Luna
	- `sql/`: SQL setup scripts
	- `static/`: Static assets
	- `uploads/`: Default file storage directory
	- `views/`: Page templates
	- `conf.lua`: Configuration file. This may change in the future.
	- `launch_*.lua`: CGI scripts for Windows and POSIX, respectively.
- `luna-apache.conf`: Copy or symlink this and change the values you need for Apache 2