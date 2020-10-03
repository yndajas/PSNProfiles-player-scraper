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

  def trophies_by_completion
    self.completion_breakdown[:trophies_by_completion]
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
    puts "\nView the README for more information on each option"

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
    # puts data from README basic section

    self.view_menu
  end

  def view_totals
    # puts data from README totals section

    self.view_menu
  end

  def view_summaries
    # puts data from README summaries section

    self.view_menu
  end

  def view_los
    # puts data from README length of service section

    self.view_menu
  end

  def view_collections_menu
    puts "\nWhich collection would you like to view?"
    puts "  Enter \"1\" for recent trophies"
    puts "  Enter \"2\" for recent games"
    puts "  Enter \"3\" for rarest trophies"
    puts "  Enter \"view\" to return to the view menu"
    puts "  Enter \"main\" to return to the main menu"

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
    # puts recent trophies data
    self.view_collections_menu
  end

  def view_recent_games
    # puts recent games data
    self.view_collections_menu
  end

  def view_rarest_trophies
    # puts rarest trophies data
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
    # complete compare method
    cli.main_menu
  end
end
