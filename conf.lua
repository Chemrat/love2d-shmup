function love.conf(t)
	t.releases = {
		title = "Generic Space Shootan Game",              -- The project title (string)
		package = "shmup",            -- The project command and package name (string)
		loveVersion = nil,        -- The project LÖVE version
		version = nil,            -- The project version
		author = nil,             -- Your name (string)
		description = nil,        -- The project description (string)
		homepage = nil,           -- The project homepage (string)
		identifier = nil,         -- The project Uniform Type Identifier (string)
		excludeFileList = {"CMakeLists.txt", ".hgignore", "./.hg/*"},     -- File patterns to exclude. (string list)
		releaseDirectory = "releases",   -- Where to store the project releases (string)
	}
end
