class Scraper
  BASE_PATH = "https://psnprofiles.com/"

  def self.scrape_profile_page(psn_id)

    profile_data = Nokogiri::HTML(open(BASE_PATH + psn_id))

    player = {}

    # get data from top row (including mouseover extras)

    player[:psn_id] = profile_data.css("span.username").text.strip #this gets the username with the correct capitalisation

    player[:comment] = profile_data.css("span.comment").text if profile_data.css("span.comment").length > 0

    player[:level] = profile_data.css("li.icon-sprite.level").text

    player[:level_progress] = profile_data.css("div.progress-bar.level div").attribute("style").value.gsub("width: ","").gsub(";","")

    player[:next_level_in] = profile_data.search('script[type="text/javascript"]')[12].children.to_s.strip.gsub(/.*( in <b>)/,"").gsub("\n","").gsub(/(<\/b>).*/,"") + " points"

    player[:country] = profile_data.css("img.round-flags").attribute("title").text.gsub("<center style='font-size:11px;'>","").gsub("</center>","")

    player[:total_trophies] = profile_data.css("li.total").text.strip

    player[:total_platinums] = profile_data.css("li.platinum").text.strip

    player[:total_golds] = profile_data.css("li.gold").text.strip

    player[:total_silvers] = profile_data.css("li.silver").text.strip

    player[:total_bronzes] = profile_data.css("li.bronze").text.strip

    # get data from second row (of eight stats near top of profile)

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

    # get recent trophies

    recent_trophies = []

    recent_trophies_scrape = profile_data.css("ul.recent-trophies.flex li")

    recent_trophies_scrape.length.times {recent_trophies << {}} # create empty hashes for each of the up to 12 recent trophies - I use the #length instead of 12.times so that it works for players with less than 12 total trophies

    recent_trophies_scrape.each_with_index do |trophy, i|
      recent_trophies[i][:trophy] = trophy.css("div.ellipsis a.title").text.strip
      recent_trophies[i][:game] = trophy.css("div.ellipsis span.small_info_green a").text.strip
      recent_trophies[i][:description] = trophy.css("div.ellipsis span")[0].text.strip
    end

    player[:recent_trophies] = recent_trophies

    # get recent games

    ## game, N of N trophies, latest trophy date, platinum/completion time (if platinumed/completed), platform, platinumed (check which icon shows), g/s/b, completion percentage, platinum rarity, completion rate (if it exists, i.e. if it's not 1:1 with platinum rate/if there's DLC or no platinum)

    binding.pry

    player
  end
end
