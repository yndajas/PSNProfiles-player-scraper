class Scraper
  BASE_PATH = "https://psnprofiles.com/"

  def self.scrape_profile_page(psn_id)

    profile_data = Nokogiri::HTML(open(BASE_PATH + psn_id))

    player = {}

    player[:psn_id] = profile_data.css("span.username").text.strip #this gets the username with the correct capitalisation

    player[:country] = profile_data.css("img.round-flags").attribute("title").text.gsub("<center style='font-size:11px;'>","").gsub("</center>","")

    player[:total_trophies] = profile_data.css("li.total").text.strip

    # get row of eight stats near top of profile

    stats_flex = profile_data.css("span.stat.grow")

    stats_flex_data = []

    stats_flex.each do |stat|
      stats_flex_data << stat.to_s.gsub(/(<span).*(">)/,"").gsub(/(<span>).*/,"").gsub(/(<a).*(">)/,"").gsub(/(<\/a>)/,"").gsub(/(<\/span>)/,"").strip
    end

    stats_flex_data.delete_at(5) # delete (unwanted) profile views count

    stats_flex_data_keys = [:games_played, :completed_games, :completion_rate, :unearned_trophies, :trophies_per_day, :world_rank, :country_rank]

    stats_flex_data.each_with_index do |stat, i|
      player[stats_flex_data_keys[i]] = stat
    end

    binding.pry

    player
  end
end
