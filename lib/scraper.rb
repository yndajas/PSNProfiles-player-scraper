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

    ## ADD: g/s/b, completion percentage, platinum rarity, completion rate (if it exists, i.e. if it's not 1:1 with platinum rate/if there's DLC or no platinum)

    recent_games = []

    recent_games_scrape = profile_data.css('[id="gamesTable"] tr')

    if recent_games_scrape.length < 12 # create empty hashes for up to 12 recent games
      recent_games_scrape.length.times {recent_games << {}}
    else
      12.times {recent_games << {}}
    end

    recent_games_scrape[0..11].each_with_index do |game, i| # iterate over the most recent 12 games (`[0..11]` creates a subarray)
      recent_games[i][:game] = game.css("a.title").text

      if game.css("span.tag.platform").length > 1
        platforms = []
        game.css("span.tag.platform").each {|platform| platforms << platform.text}
        recent_games[i][:platform] = platforms.join("/")
      else
        recent_games[i][:platform] = game.css("span.tag.platform").text
      end

      platinum_class = game.css("img.icon-sprite").attribute("class").value

      if platinum_class[12] == "c"
        recent_games[i][:platinumed] = "not applicable (game has no platinum)"
      elsif platinum_class[-6..-1] == "earned"
        recent_games[i][:platinumed] = "yes"
      else
        recent_games[i][:platinumed] = "no"
      end

      # gsb

      if game.css("div.small-info")[0].text.strip[0..2] == "All" # if the trophy count text starts "All", earned and available are both taken from the first bold tag, otherwise the first and second respectively
        recent_games[i][:earned_trophies] = game.css("div.small-info b")[0].text
        recent_games[i][:available_trophies] = game.css("div.small-info b")[0].text
      else
        recent_games[i][:earned_trophies] = game.css("div.small-info b")[0].text
        recent_games[i][:available_trophies] = game.css("div.small-info b")[1].text
      end

      if game.css("div.small-info")[1].css("bullet").length > 0
        ## scrape last trophy date before bullet and time to complete/platinum after bullet
        recent_games[i][:latest_trophy_date] = game.css("div.small-info")[1].text.strip.gsub(/\n.*/,"")

        speed_text = game.css("div.small-info")[1].text.strip.gsub("\n","").gsub(/.*(\u2022)/,"").gsub("\t","").strip.gsub("                                           ","")
        recent_games[i][:speedrun_type] = speed_text.gsub(/ .*/,"")
        recent_games[i][:speedrun_time] = speed_text.gsub(/.* in /,"")
        ## check if text is platinum or complete and fill in separate attribute based on which it is
      else
        recent_games[i][:latest_trophy_date] = game.css("div.small-info")[1].text.strip
      end
    end

    player[:recent_games] = recent_games

    binding.pry

    player
  end
end
