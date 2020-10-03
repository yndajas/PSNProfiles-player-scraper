class Player
  attr_accessor :psn_id, :comment, :level, :level_progress, :next_level_in, :country, :total_trophies, :total_platinums, :total_golds, :total_silvers, :total_bronzes, :games_played, :completed_games, :overall_completion, :unearned_trophies, :trophies_per_day, :world_rank, :country_rank, :recent_trophies, :recent_games, :rarest_trophies, :games_by_platform, :trophies_by_type, :rarity_breakdown, :completion_breakdown, :first_trophy, :latest_trophy, :length_of_service

  # add attr_readers for all the keys in the scraped player_data hash, and add reader methods to get the sub-hashes/attributes
  # use meta-programming (#send) in #initialize to populate all the instance variables
  # add methods for putting (or returning?) each of the five collections of data outlined in the README in an easily readable format

  @@all = []

  def initialize(player_data)
    player_data.each do |key, value|
      self.send("#{key}=", value)
    end

    @@all << self
  end

  def average_rarity
    self.rarity_breakdown[:average_rarity]
  end

  def trophies_by_rarity
    self.rarity_breakdown[:trophies_by_rarity]
  end

  def average_completion
    self.completion_breakdown[:average_completion]
  end

  def games_by_completion
    self.completion_breakdown[:games_by_completion]
  end

  def self.all
    @@all
  end

  def view(cli)
    self.view_menu

    cli.main_menu
  end

  def view_menu
    puts "\nWhat data would you like to view?"
    puts "  Enter \"1\" for basics"
    puts "  Enter \"2\" for totals"
    puts "  Enter \"3\" for summaries (number of x by y)"
    puts "  Enter \"4\" for length of service (inc. first/latest trophy)"
    puts "  Enter \"5\" for collections (recent trophies/games and rarest trophies)"
    puts "  Enter \"main\" to return to the main menu"
    puts "\nView the README for more information on each option\n\n"

    choice = ""

    choice = gets.strip until choice == "1" || choice == "2" || choice == "3" || choice == "4" || choice == "5" || choice.downcase == "main"

    if choice == "1"
      self.view_basics
    elsif choice == "2"
      self.view_totals
    elsif choice == "3"
      self.view_summaries
    elsif choice == "4"
      self.view_los
    elsif choice == "5"
      self.view_collections_menu
    end
  end

  def view_basics
    puts "\n#{self.psn_id}" + (self.comment != nil ? " ~ #{self.comment}" : "")
    puts "\nLevel: #{self.level}"
    puts "Level progress: #{self.level_progress} - next level in #{self.next_level_in}"
    puts "Rank: #{self.world_rank} (world) | #{self.country_rank} (#{self.country})"
    puts "\nOverall completion rate: #{self.overall_completion}"
    puts "Average game completion: #{self.average_completion}"
    puts "Average trophy rarity: #{self.average_rarity}"
    puts "Trophies per day: #{self.trophies_per_day}"

    self.view_menu
  end

  def view_totals
    puts "\nTrophies"
    puts "  Earned: #{self.total_trophies} | Unearned: #{self.unearned_trophies}"
    puts "  Platinums: #{self.total_platinums} | Golds: #{self.total_golds} | Silvers: #{self.total_silvers} | Bronzes: #{self.total_bronzes}"

    puts "\nGames"
    puts "  Completed: #{self.completed_games} | Played: #{self.games_played}"

    self.view_menu
  end

  def view_summaries
    # puts data from README summaries section
    puts "\nTrophies by type"
    self.trophies_by_type.each {|type_data| puts "  #{type_data[:type]}: #{type_data[:trophies]}"}

    puts "\nTrophies by rarity"
    self.trophies_by_rarity.each {|rarity_data| puts "  #{rarity_data[:rarity_band]}: #{rarity_data[:trophies]}"}

    puts "\nGames by platform"
    self.games_by_platform.each {|platform_data| puts "  #{platform_data[:platform]}: #{platform_data[:trophies]}"}

    puts "\nGames by completion percentage"
    self.games_by_completion.each {|completion_data| puts "  #{completion_data[:completion_band]}: #{completion_data[:games]}"}

    self.view_menu
  end

  def view_los
    puts "\nFirst trophy"
    puts "  #{self.first_trophy[:trophy]} (#{self.first_trophy[:game]})"
    puts "  #{self.first_trophy[:description]}"
    puts "\n  Earned: #{Player.trophy_earned_date(self, "first")}"

    puts "\nLatest trophy"
    puts "  #{self.latest_trophy[:trophy]} (#{self.latest_trophy[:game]})"
    puts "  #{self.latest_trophy[:description]}"
    puts "\n  Earned: #{Player.trophy_earned_date(self, "latest")}"

    puts "\nLength of service: #{self.length_of_service}"

    self.view_menu
  end

  def view_collections_menu
    puts "\nWhich collection would you like to view?"
    puts "  Enter \"1\" for recent trophies"
    puts "  Enter \"2\" for recent games"
    puts "  Enter \"3\" for rarest trophies"
    puts "  Enter \"view\" to return to the view menu"
    puts "  Enter \"main\" to return to the main menu\n\n"

    choice = ""

    choice = gets.strip until choice == "1" || choice == "2" || choice == "3" || choice.downcase == "view" || choice.downcase == "main"

    if choice == "1"
      self.view_recent_trophies
    elsif choice == "2"
      self.view_recent_games
    elsif choice == "3"
      self.view_rarest_trophies
    elsif choice.downcase == "view"
      self.view_menu
    end
  end

  def view_recent_trophies
    puts "\nRecent trophies"

    self.recent_trophies.each_with_index do |trophy_data, i|
      puts "\n(#{i + 1})#{i > 8 ? " " : "  "}#{trophy_data[:trophy]} (#{trophy_data[:game]})"
      puts "     #{trophy_data[:description]}"
    end

    self.view_collections_menu
  end

  def view_recent_games
    puts "\nRecent games"

    self.recent_games.each_with_index do |game_data, i|
      puts "\n(#{i + 1})#{i > 8 ? " " : "  "}#{game_data[:game]} (#{game_data[:platform]})"

      if game_data[:PSNProfiles_completion_rarity] != nil && game_data[:PSNProfiles_platinum_rarity] != nil
        puts "     PSNProfiles rarities: #{game_data[:PSNProfiles_completion_rarity]} (completion) | #{game_data[:PSNProfiles_platinum_rarity]} (platinum)"
      elsif game_data[:PSNProfiles_completion_rarity] != nil
        puts "     PSNProfiles completion rarity: #{game_data[:PSNProfiles_completion_rarity]}"
      else
        puts "     PSNProfiles platinum rarity: #{game_data[:PSNProfiles_platinum_rarity]}"
      end

      if game_data[:PSNProfiles_platinum_rarity] != nil
        psnp_platinum = game_data[:PSNProfiles_platinum_rarity]
        platinumed = game_data[:platinum] == "0" ? "no" : "yes"
      else
        psnp_platinum = "not applicable (no platinum)"
        platinumed = "not applicable (no platinum)"
      end

      puts "\n     Completion: #{game_data[:completion]}"
      puts "     Platinumed: #{platinumed}"

      if game_data[:speedrun_type] != nil
        if game_data[:speedrun_type] == "Platinum" && game_data[:PSNProfiles_completion_rarity] == nil
          speedrun_type = ""
        elsif game_data[:PSNProfiles_platinum_rarity] == nil
          speedrun_type = ""
        else
          speedrun_type = " (#{game_data[:speedrun_type].downcase})"
        end

        puts "     Speedrun#{speedrun_type}: #{game_data[:speedrun_time]}"
      end

      puts "\n     Golds: #{game_data[:golds]} | Silvers: #{game_data[:silvers]} | Bronzes: #{game_data[:bronzes]}"
      puts "     Trophies earned/available: #{game_data[:earned_trophies]}/#{game_data[:available_trophies]}"

      latest_trophy_date = game_data[:latest_trophy_date].class == DateTime ? game_data[:latest_trophy_date].strftime('%-d %B %Y') : game_data[:latest_trophy_date]

      puts "     Most recent trophy date: #{latest_trophy_date}"

    end

    self.view_collections_menu
  end

  def view_rarest_trophies
    puts "\nRarest trophies"

    self.rarest_trophies.each_with_index do |trophy_data, i|
      puts "\n(#{i + 1})  #{trophy_data[:trophy]} (#{trophy_data[:game]})"
      puts "     #{trophy_data[:type]} | PSNProfiles rarity: #{trophy_data[:PSNProfiles_rarity]}"
    end

    self.view_collections_menu
  end

  def export(cli)
    puts "\nWhere would you like to export the data to?"

    directory = gets.strip

    until Dir.exist?(directory)
      puts "\nDirectory not found. Please enter a valid filepath"
      directory = gets.strip
    end

    directory += "\\" if directory[-1] != "\\" && directory[-1] != "/"

    puts "\nWhat format: XML or JSON?"

    format = gets.strip

    until format.upcase == "XML" || format.upcase == "JSON"
      puts "\nInvalid format. Please enter \"XML\" or \"JSON\""
      format = gets.strip
    end

    filename = "#{directory}PSNProfiles_data_#{self.psn_id}." + format.downcase

    if File.exists?(filename)
      i = 2
      filename = filename.gsub("."," (#{i}).")

      until !File.exists?(filename)
        filename = filename.gsub("(#{i}).","(#{i += 1}).")
      end
    end

    File.write(filename, self.hash.to_xml) if format.upcase == "XML"
    File.write(filename, JSON.pretty_generate(self.hash)) if format.upcase == "JSON"

    puts "\nData successfully exported to \"#{filename}!\n"

    cli.main_menu
  end

  def hash
    player_hash = {}
    self.instance_variables.each {|variable| player_hash[variable.to_s.delete("@").to_sym] = self.instance_variable_get(variable)}
    player_hash
  end

  def self.compare(player_one, player_two, cli)
    puts "\n#{player_one.psn_id} vs #{player_two.psn_id}"

    puts "\nLevel: #{player_one.level} | #{player_two.level}"

    if player_one.country == player_two.country
      puts "#{player_one.country} rank: #{player_one.country_rank} | #{player_two.country_rank}"
    end

    puts "World rank: #{player_one.world_rank} | #{player_two.world_rank}"

    puts "\nOverall completion rate: #{player_one.overall_completion} | #{player_two.overall_completion}"
    puts "Average game completion: #{player_one.average_completion} | #{player_two.average_completion}"
    puts "Average trophy rarity: #{player_one.average_rarity} | #{player_two.average_rarity}"
    puts "Trophies per day: #{player_one.trophies_per_day} | #{player_two.trophies_per_day}"
    puts "Rarest trophy (PSNProfiles rarity): #{player_one.rarest_trophies[0][:PSNProfiles_rarity]} | #{player_two.rarest_trophies[0][:PSNProfiles_rarity]}"

    puts "\nTrophies"
    puts "  Earned: #{player_one.total_trophies} | #{player_two.total_trophies}"
    puts "  Unearned: #{player_one.unearned_trophies} | #{player_two.unearned_trophies}"
    puts "  Platinums: #{player_one.total_platinums} | #{player_two.total_platinums}"
    puts "  Golds: #{player_one.total_golds} | #{player_two.total_golds}"
    puts "  Silvers: #{player_one.total_silvers} | #{player_two.total_silvers}"
    puts "  Bronzes: #{player_one.total_bronzes} | #{player_two.total_bronzes}"

    puts "\nGames"
    puts "  Completed: #{player_one.completed_games} | #{player_two.completed_games}"
    puts "  Played: #{player_one.games_played} | #{player_two.games_played}"

    puts "\nFirst trophy earned: #{Player.trophy_earned_date(player_one, "first")} | #{Player.trophy_earned_date(player_two, "first")}"
    puts "Latest trophy earned: #{Player.trophy_earned_date(player_one, "latest")} | #{Player.trophy_earned_date(player_two, "latest")}"
    puts "Length of service: #{player_one.length_of_service} | #{player_two.length_of_service}"

    cli.main_menu
  end

  def self.trophy_earned_date(player, first_or_latest)
    time = player.send("#{first_or_latest}_trophy")[:time]

    if time.class == DateTime
      time.strftime('%H:%M:%S on %-d %B %Y')
    else
      time
    end
  end
end
