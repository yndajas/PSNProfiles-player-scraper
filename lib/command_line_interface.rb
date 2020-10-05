class CommandLineInterface
  attr_accessor :player, :player_2

  def run
    puts "\nこんにちは！ Welcome to the PSNProfiles player scraper!"

    self.get_player

    puts "\nさようなら！ Goodbye!\n\n"
  end

  def get_player
    puts "\nPlease enter a PSN ID:"

    self.player = Player.new(self.valid_profile_data)

    puts "\nPlayer successfully scraped!"

    self.main_menu
  end

  def main_menu
    puts "\nWhat would you like to do?"
    puts "  Enter \"1\" to view player data"
    puts "  Enter \"2\" to export player data"
    puts "  Enter \"3\" to compare with another player"
    puts "  Enter \"4\" to change player"
    puts "  Enter \"exit\" to exit\n\n"

    choice = ""

    choice = gets.strip until choice == "1" || choice == "2" || choice == "3" || choice == "4" || choice.downcase == "exit"

    if choice == "1"
      self.player.view(self)
    elsif choice == "2"
      self.player.export(self)
    elsif choice == "3"
      puts "\nEnter the PSN ID of the player you wish to compare with:"

      self.player_2 = Player.new(self.valid_profile_data)

      Player.compare(self.player, self.player_2, self)
    elsif choice == "4"
      self.get_player
    end
  end

  def valid_profile_data
    psn_id = gets.strip
    valid_profile = Scraper.valid_profile(psn_id)

    until valid_profile != false
      puts "\nInvalid PSN ID. Please try again or refer to note (1) of the README for reasons you might be seeing this error"
      psn_id = gets.strip
      valid_profile = Scraper.valid_profile(psn_id)
    end

    player_data = Scraper.scrape(valid_profile)

    player_data
  end
end
