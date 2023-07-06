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
	etc JSON,
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
	etc JSON,
	pin tinyint
);

CREATE TABLE luna.attachments (
	post bigint NOT NULL,
	position tinyint NOT NULL,
	ip char(39) NOT NULL,
	original_name text NOT NULL,
	etc JSON,
	ref UUID NOT NULL
);

CREATE TABLE luna.files (
	ref UUID NOT NULL,
	hash binary(32),
	ext char(5),
	etc JSON,
	type ENUM('image','video','text','other','special')
);

CREATE TABLE luna.users (
	username tinytext NOT NULL,
	password tinytext NOT NULL,
	role tinytext NOT NULL,
	color tinytext NOT NULL,
	id UUID NOT NULL,
	etc JSON,
	creation datetime NOT NULL
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
	html boolean,
	etc JSON,
	id UUID
);

CREATE TABLE luna.tokens (
	user UUID NOT NULL,
	token tinytext NOT NULL,
	etc JSON,
	expiration datetime NOT NULL
);

CREATE TABLE luna.miscdata (
	type ENUM('apply', 'name', 'rank', 'special') NOT NULL,
	actor tinytext NOT NULL,
	data tinytext NOT NULL,
	etc JSON
);

CREATE TABLE luna.bans (
	ip char(39) NOT NULL,
	cookie tinytext NOT NULL,
	reason text NOT NULL,
	board tinytext NOT NULL,
	post bigint NOT NULL,
	unban datetime,
	etc JSON
);

CREATE TABLE luna.warnings (
	ip char(39) NOT NULL,
	cookie tinytext NOT NULL,
	reason text NOT NULL,
	post bigint NOT NULL,
	board tinytext NOT NULL,
	etc JSON
);

INSERT INTO luna.miscdata (type, actor, data) VALUES ('special', 'engine_version', '23w26a');
INSERT INTO luna.miscdata (type, actor, data) VALUES ('special', 'db_version', '23w26a');
INSERT INTO luna.miscdata (type, actor, data) VALUES ('special', 'engine', 'luna');