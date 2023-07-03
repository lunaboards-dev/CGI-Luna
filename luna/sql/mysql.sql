CREATE DATABASE luna CHARACTER SET = 'utf8mb4' COLLATE = 'utf8mb4_unicode_ci';
CREATE TABLE luna.posts (
	board tinytext NOT NULL,
	thread bigint NOT NULL,
	id bigint NOT NULL AUTO_INCREMENT,
	body text NOT NULL,
	poster UUID,
	ip char(39) NOT NULL, -- support IPv6
	creation datetime NOT NULL,
	banmsg text,
	PRIMARY KEY (id)
);

CREATE TABLE luna.threads (
	board tinytext NOT NULL,
	id bigint NOT NULL,
	title text NOT NULL,
	poster UUID,
	creation datetime NOT NULL,
	updated datetime NOT NULL,
	ip char(39) NOT NULL,
	pin tinyint
);

CREATE TABLE luna.attachments (
	post bigint NOT NULL,
	position tinyint NOT NULL,
	ip char(39) NOT NULL,
	original_name text NOT NULL,
	ref UUID NOT NULL
);

CREATE TABLE luna.files (
	ref UUID NOT NULL,
	hash binary(32),
	ext char(5),
	type ENUM('image','video','text','other','special')
);

CREATE TABLE luna.users (
	username tinytext,
	password tinytext,
	role tinytext,
	color tinytext,
	id UUID,
	creation datetime NOT NULL
);

CREATE TABLE luna.roles (
	user UUID,
	role UUID,
	board tinytext
);

CREATE TABLE luna.rolepermissions (
	admin boolean,
	delpost boolean,
	warn boolean,
	delthread boolean,
	lockthread boolean,
	delattachment boolean,
	ban boolean,
	modifyroles boolean,
	applyroles boolean,
	id UUID
);

CREATE TABLE luna.tokens (
	user UUID,
	token tinytext,
	expiration datetime
);

CREATE TABLE luna.miscdata (
	type ENUM('apply', 'name', 'rank', 'special'),
	actor tinytext,
	data tinytext
);

CREATE TABLE luna.bans (
	ip char(39),
	cookie tinytext
);

INSERT INTO luna.miscdata (type, actor, data) VALUES ('special', 'engine_version', '23w26a');
INSERT INTO luna.miscdata (type, actor, data) VALUES ('special', 'db_version', '23w26a');
INSERT INTO luna.miscdata (type, actor, data) VALUES ('special', 'engine', 'luna');