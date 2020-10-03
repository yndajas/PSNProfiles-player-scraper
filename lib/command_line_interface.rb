class CommandLineInterface
  attr_accessor :player, :player_2

  def run
    puts "\nWelcome to the PSNProfiles player scraper!"
    puts "\nPlease enter a PSN ID:"

    psn_id = gets.strip # Scraper.validate (create this method)
    player_data = Scraper.scrape_profile_page(psn_id)
    self.player = Player.new(player_data)

    puts "\nPlayer successfully scraped!"

    self.main_menu
  end

  def main_menu
    puts "\nWhat would you like to do?"
    puts "  Enter \"1\" to view player data"
    puts "  Enter \"2\" to export player data"
    puts "  Enter \"3\" to compare with another player"
    puts "  Enter \"exit\" to exit"

    choice = ""

    choice = gets.strip until choice == "1" || choice == "2" || choice == "3" || choice.downcase == "exit"

    if choice == "1"
      self.player.view(self)
    elsif choice == "2"
      self.player.export(self)
    elsif choice == "3"
      puts "\nEnter the PSN ID of the player you wish to compare with"

      psn_id_2 = gets.strip # Scraper.validate (create this method)
      player_data_2 = Scraper.scrape_profile_page(psn_id_2)
      self.player_2 = Player.new(player_data_2)

      binding.pry

      Player.compare(self.player, self.player_2, self)
    end
  end
end
