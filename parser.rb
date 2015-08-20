require 'json'
$games = Hash.new(0)
$means_kill_games = Hash.new(0)
$kills_in_game=Hash.new(0)
$kill_by_means=Hash.new(0)
$number_game=1
$kill_count=0
$players=""

# metodo que adiciona um game com o total de kills, os players onlines e a quantidade de kills por player ao hash de games
# tambem adiciona a quantidade de mortes por meio ao hash de means_kill_game
def print_report()
	$games["game_#{$number_game}"] = {:total_kills => "#{$kill_count}", :players => "#{$players}", :kills => $kills_in_game}
	$means_kill_games["game_#{$number_game}"] = {:kill_by_means => $kill_by_means}
end

# metodo que concatena os players onlines para ser adiconado ao game
def concat_name_players(name)
	if not $players.include? name
		if $players != ""
			$players.concat(", ").concat(name)	
		else
			$players.concat(name)
		end 
	end
end

# zera o valor das variaveis a cada finalização de game
def reset_values()
	$players=""
	$number_game += 1
	$kill_count = 0
	$kills_in_game=Hash.new(0)
	$kill_by_means=Hash.new(0)
end

# le linha a linha do arquivo game.log
File.foreach( "games.log" ) do |line|
	# responsavel por criar o game ao fim do mesmo
	if line.include? "ShutdownGame"
		print_report()
		reset_values()
	end

	# contador de mortes por partida
	if line.include? "Kill"
		$kill_count += 1
		# valida se o word não matou o player
		if not line.include? "<world>"
			player = line[/\d: (.*?) /][2..-1]
			$kills_in_game[player] = $kills_in_game[player] + 1
			means = line[/by (.*?)$/][3..-1]
			$kill_by_means[means] = $kill_by_means[means] + 1
		end		
	end
	# extrai o nome do usuario para ser concatenado caso ele não ja tenha sido
	if line.include? "ClientUserinfoChanged" 
		player = line[/n\\(.*?)\\t/][2..-3]
		concat_name_players(player)
	end
end

#imprime os dois hash no formato JSON
puts JSON.pretty_generate($games)
puts JSON.pretty_generate($means_kill_games)
