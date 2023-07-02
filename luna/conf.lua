--[[return {
	config "main" {
		login_required = false;
		signup_enabled = false;
		config "boards" {
			section "nsfw" {
				name = "NSFW";
				nsfw = true;
				board "l" {
					name = "Random";
					title = {

					};
					desc = {

					};
				};
				board "u" {
					name = "Creative";
					title = {

					};
					desc = {

					};
				};
				board "a" {
					name = "Anime";
					title = {

					};
					desc = {

					};
				}
			};
		};
	};

	config "fcgi" {
		
	};

	config "db" {
		engine = "sqlite"
	};

	config "uploads" {
		fspath = "/srv/luna/uploads/";
		webpath = "/images/";
	};
}]]

return {
	main = {
		login_required = false;
		prefix = "/luna";
		registration_enabled = false;
		boards = {
			{
				name = "section lol";
				nsfw = true;
				{
					id = "l",
					name = "Random";
					title = {
						"lol lmao";
					};
					desc = {
						"get fucked retard";
					};
				},
				{
					id = "u";
					name = "Creative";
					title = {
						"made by /u/"
					};
					desc = {
						"get drawing, drawfag";
					}
				},
				{
					id = "a";
					name = "Anime";
					title = {
						"weeb"
					};
					desc = {
						"chinese cartoons"
					};
				}
			}
		}
	};
}