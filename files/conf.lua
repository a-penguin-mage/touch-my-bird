-- Configuration
function love.conf(t)
  SF = 1;  
	t.title = "touch my bird" -- The title of the window the game is in (string)
	t.version = "0.10.1"         -- The LÖVE version this game was made for (string)
	t.window.width = 720*SF
	t.window.height = 1080*SF

	-- For Windows debugging
	t.console = false
end