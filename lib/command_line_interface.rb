class CommandLineInterface
  def run
    puts "Welcome to the PSNProfiles player scraper!"
    puts "Enter a PSN ID"
    psn_id = gets.strip
    player_data = Scraper.scrape_profile_page(psn_id)
    # create Player instance from player_data
  end
end
